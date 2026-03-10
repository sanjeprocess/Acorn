import asyncHandler from 'express-async-handler';
import { Customer } from '../models/customerModel.js';
import { CSA } from '../models/csaModel.js';
import { SSOSession } from '../models/ssoSessionModel.js';
import { validateCardAndGetData } from '../services/externalSessionService.js';
import { generateAccessToken, generateRefreshToken } from '../utils/jwtToken.js';
import { UserTypes } from '../enums/userTypes.js';

/**
 * @desc    Validate card and authenticate CSA via SSO
 * @route   GET /api/v1/sso/validate-session?cardId={cardId}
 * @access  Public
 */
export const validateSessionAndLogin = asyncHandler(async (req, res) => {
  const { cardId } = req.query;

  // Validate input
  if (!cardId) {
    res.status(400);
    throw new Error('cardId is required as query parameter');
  }

  // First, check if we have a valid cached session (not expired)
  let cachedSession = await SSOSession.findValidSessionByCardId(cardId);
  
  // If no valid session, check if there's an expired session (for reuse)
  let existingSession = null;
  if (!cachedSession) {
    existingSession = await SSOSession.findSessionByCardId(cardId);
    
    // If session exists but is expired, we'll refresh it after validation
    if (existingSession && existingSession.isExpired) {
      console.log(`Found expired session for cardId: ${cardId}, will refresh after validation`);
    } else if (!existingSession) {
      // No session at all - cardId was never registered by WorkHub24
      res.status(404);
      throw new Error(
        'Card ID not found. Please ensure the card has been registered through WorkHub24 first.'
      );
    }
  }

  // Validate card with WorkHub24 API (always validate to ensure card is still valid)
  console.log(`Validating cardId: ${cardId} with WorkHub24 API`);
  
  const cardData = await validateCardAndGetData(cardId);
  const { csa: csaData } = cardData;

  // Check if CSA exists in the database by email from WorkHub24 response
  const csa = await CSA.findOne({ email: csaData.email }).lean().exec();

  if (!csa) {
    res.status(404);
    throw new Error('CSA not found. Please ensure your account has been created.');
  }

  // If session was expired or doesn't exist, create/refresh it
  if (!cachedSession) {
    await SSOSession.createOrUpdateSession({
      cardId,
      csaId: csa.csaId,
    });
    console.log(`Refreshed SSO session for cardId: ${cardId}, csaId: ${csa.csaId}, expires in 30 minutes`);
  } else {
    console.log(`Using existing valid session for cardId: ${cardId}, csaId: ${cachedSession.csaId}`);
  }

  // Check if CSA has completed registration (uses temp password flag)
  const isFirstTimeLogin = !!csa.isTempPassword;

  // Generate tokens for CSA
  const accessToken = generateAccessToken(csa.csaId, UserTypes.CSA);
  const refreshToken = generateRefreshToken(csa.csaId, UserTypes.CSA);

  // Send response
  res.json({
    message: isFirstTimeLogin
      ? 'Session validated. Please complete your registration.'
      : 'SSO login successful.',
    success: true,
    data: {
      user: {
        csaId: csa.csaId,
        name: csa.name,
        email: csa.email,
        mobile: csa.mobile || null,
      },
      accessToken,
      refreshToken,
      isFirstTimeLogin,
    },
  });
});

/**
 * @desc    Create CSA with customer account from WorkHub24 card
 * @route   POST /api/v1/sso/create-csa
 * @access  Protected (API Key from external application)
 */
export const createCSAFromExternal = asyncHandler(async (req, res) => {
  const { cardId } = req.body;

  // Validate input
  if (!cardId) {
    res.status(400);
    throw new Error('cardId is required');
  }

  // Get card data from WorkHub24
  const cardData = await validateCardAndGetData(cardId);
  const { csa: csaData, customer: customerData } = cardData;

  // Check if CSA already exists with the email
  const existingCSA = await CSA.findOne({ email: csaData.email }).lean().exec();

  let csa;
  let isNewCSA = false;

  if (existingCSA) {
    // CSA exists - use existing CSA
    csa = existingCSA;
    console.log(`CSA already exists with email: ${csaData.email}`);
  } else {
    // CSA doesn't exist - create new CSA with temp password
    const tempPassword = `Acorn${Math.random().toString(36).slice(-8)}!`;

    csa = await CSA.create({
      name: csaData.name,
      email: csaData.email,
      password: tempPassword,
      isTempPassword: true,
      // Mobile will be set during registration
    });

    if (!csa) {
      res.status(500);
      throw new Error('Failed to create CSA');
    }

    isNewCSA = true;
    console.log(`New CSA created with email: ${csaData.email}`);
  }

  // Handle customer creation
  let customer;
  let isNewCustomer = false;

  // Check if customer already exists
  const existingCustomer = await Customer.findOne({
    email: customerData.email,
  })
    .lean()
    .exec();

  if (existingCustomer) {
    customer = existingCustomer;
    console.log(`Customer already exists with email: ${customerData.email}`);
  } else {
    // Create new customer
    customer = await Customer.create({
      name: customerData.name,
      email: customerData.email,
      csa: csa.csaId,
    });

    isNewCustomer = true;
    console.log(`New customer created with email: ${customerData.email}`);
  }

  // Save cardId to SSO session for 30 minutes
  await SSOSession.createOrUpdateSession({
    cardId,
    csaId: csa.csaId,
  });

  console.log(`Cached SSO session for cardId: ${cardId}, csaId: ${csa.csaId}, expires in 30 minutes`);

  res.status(201).json({
    message: 'CSA and customer creation process completed',
    success: true,
    data: {
      csa: {
        csaId: csa.csaId,
        name: csa.name,
        email: csa.email,
        mobile: csa.mobile || null,
        isNewCSA,
        needsRegistration: isNewCSA || !!csa.isTempPassword,
      },
      customer: {
        customerId: customer.customerId,
        name: customer.name,
        email: customer.email,
        isNewCustomer,
      },
    },
  });
});

/**
 * @desc    Check if CSA exists and needs registration
 * @route   GET /api/v1/sso/check-user
 * @access  Public
 */
export const checkUserExists = asyncHandler(async (req, res) => {
  const { email } = req.query;

  if (!email) {
    res.status(400);
    throw new Error('Email is required');
  }

  const csa = await CSA.findOne({ email }).lean().exec();

  if (!csa) {
    return res.json({
      message: 'CSA not found',
      success: true,
      data: {
        exists: false,
        needsRegistration: true,
      },
    });
  }

  const needsRegistration = !!csa.isTempPassword;

  res.json({
    message: 'CSA check completed',
    success: true,
    data: {
      exists: true,
        needsRegistration,
      csaId: csa.csaId,
      name: csa.name,
      email: csa.email,
      mobile: csa.mobile,
    },
  });
});

/**
 * @desc    Invalidate SSO session (logout)
 * @route   POST /api/v1/sso/logout
 * @access  Public
 */
export const logoutSSO = asyncHandler(async (req, res) => {
  const { cardId } = req.body;

  if (!cardId) {
    res.status(400);
    throw new Error('cardId is required');
  }

  // Remove session from cache
  await SSOSession.invalidateSession(cardId);

  res.json({
    message: 'SSO session invalidated successfully',
    success: true,
    data: {
      cardId,
      invalidatedAt: new Date().toISOString(),
    },
  });
});

/**
 * @desc    Get SSO session statistics (for monitoring/debugging)
 * @route   GET /api/v1/sso/sessions/stats
 * @access  Protected (could add admin middleware)
 */
export const getSSOSessionStats = asyncHandler(async (req, res) => {
  const totalSessions = await SSOSession.countDocuments();
  const activeSessions = await SSOSession.countDocuments({
    expiresAt: { $gt: new Date() },
  });
  const expiredSessions = totalSessions - activeSessions;

  // Get sessions expiring soon (within 5 minutes)
  const expiringSoon = await SSOSession.countDocuments({
    expiresAt: {
      $gt: new Date(),
      $lt: new Date(Date.now() + 5 * 60 * 1000),
    },
  });

  res.json({
    message: 'SSO session statistics',
    success: true,
    data: {
      totalSessions,
      activeSessions,
      expiredSessions,
      expiringSoon,
      timestamp: new Date().toISOString(),
    },
  });
});

/**
 * @desc    Manually cleanup expired sessions
 * @route   POST /api/v1/sso/sessions/cleanup
 * @access  Protected (could add admin middleware)
 */
export const cleanupExpiredSessions = asyncHandler(async (req, res) => {
  const deletedCount = await SSOSession.cleanupExpired();

  res.json({
    message: 'Expired sessions cleaned up',
    success: true,
    data: {
      deletedCount,
      timestamp: new Date().toISOString(),
    },
  });
});

