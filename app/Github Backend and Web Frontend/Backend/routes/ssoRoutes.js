import express from 'express';
import {
  validateSessionAndLogin,
  createCSAFromExternal,
  checkUserExists,
  logoutSSO,
  getSSOSessionStats,
  cleanupExpiredSessions,
} from '../controllers/ssoController.js';
import { validateApiKey } from '../middleware/apiKeyMiddleware.js';

const router = express.Router();

/**
 * @swagger
 * /sso/validate-session:
 *   get:
 *     summary: Validate WorkHub24 card and authenticate CSA via SSO
 *     description: |
 *       This endpoint validates a WorkHub24 card ID, retrieves CSA and customer information,
 *       and authenticates the CSA in the ACORN Travels system. If the CSA doesn't exist,
 *       it will be created automatically. If the CSA exists but hasn't set a password,
 *       they will be marked as first-time login and routed to registration.
 *     tags:
 *       - SSO
 *     parameters:
 *       - in: query
 *         name: cardId
 *         required: true
 *         schema:
 *           type: string
 *         description: WorkHub24 card ID
 *         example: "CARD123456"
 *     responses:
 *       200:
 *         description: Card validated and CSA authenticated successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "SSO login successful."
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     user:
 *                       type: object
 *                       properties:
 *                         csaId:
 *                           type: number
 *                           example: 1
 *                         name:
 *                           type: string
 *                           example: "John Doe"
 *                         email:
 *                           type: string
 *                           example: "john.doe@acorntravels.com"
 *                         mobile:
 *                           type: string
 *                           nullable: true
 *                           example: "+1234567890"
 *                     accessToken:
 *                       type: string
 *                       example: "eyJhbGciOiJIUzI1NiIsInR5cCI..."
 *                     refreshToken:
 *                       type: string
 *                       example: "eyJhbGciOiJIUzI1NiIsInR5cCI..."
 *                     isFirstTimeLogin:
 *                       type: boolean
 *                       example: false
 *                       description: True if user needs to complete registration
 *       400:
 *         description: Bad request - missing cardId parameter
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "cardId is required as query parameter"
 *                 success:
 *                   type: boolean
 *                   example: false
 *       401:
 *         description: Invalid card or authentication failed
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Invalid card or authentication failed"
 *                 success:
 *                   type: boolean
 *                   example: false
 *       500:
 *         description: Internal server error
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "An unexpected error occurred"
 *                 success:
 *                   type: boolean
 *                   example: false
 */
router.get('/validate-session', validateSessionAndLogin);

/**
 * @swagger
 * /sso/create-csa:
 *   post:
 *     summary: Create CSA with customer account from WorkHub24 card
 *     description: |
 *       This endpoint validates a WorkHub24 card ID, retrieves CSA and customer information
 *       from the card, and creates/updates the CSA and customer in ACORN Travels.
 *       
 *       The card data is fetched from WorkHub24 API using the cardId. CSA information is
 *       extracted from `walletTriggerUserName` and `walletTriggerUserEmail`, and customer
 *       information from `name1` and `email3`.
 *       
 *       If CSA already exists, only the customer is created if it doesn't exist.
 *       If CSA doesn't exist, it's created with a temporary password and marked for registration.
 *       
 *       **Authentication:** Requires X-API-Key header with valid API key.
 *     tags:
 *       - SSO
 *     security:
 *       - ApiKeyAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - cardId
 *             properties:
 *               cardId:
 *                 type: string
 *                 description: WorkHub24 card ID
 *                 example: "CARD123456"
 *     responses:
 *       201:
 *         description: CSA and customer creation process completed
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "CSA and customer creation process completed"
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     csa:
 *                       type: object
 *                       properties:
 *                         csaId:
 *                           type: number
 *                           example: 1
 *                         name:
 *                           type: string
 *                           example: "Jane Smith"
 *                         email:
 *                           type: string
 *                           example: "jane.smith@acorntravels.com"
 *                         mobile:
 *                           type: string
 *                           nullable: true
 *                           example: "+1234567890"
 *                         isNewCSA:
 *                           type: boolean
 *                           example: true
 *                         needsRegistration:
 *                           type: boolean
 *                           example: true
 *                           description: True if CSA needs to complete registration
 *                     customer:
 *                       type: object
 *                       properties:
 *                         customerId:
 *                           type: number
 *                           example: 1
 *                         name:
 *                           type: string
 *                           example: "John Doe"
 *                         email:
 *                           type: string
 *                           example: "john.doe@example.com"
 *                         isNewCustomer:
 *                           type: boolean
 *                           example: true
 *       400:
 *         description: Bad request - missing or invalid cardId
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "cardId is required"
 *                 success:
 *                   type: boolean
 *                   example: false
 *       401:
 *         description: Unauthorized - missing or invalid API key
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "API key is required. Please provide X-API-Key header"
 *                 success:
 *                   type: boolean
 *                   example: false
 *       403:
 *         description: Forbidden - invalid API key
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Invalid API key"
 *                 success:
 *                   type: boolean
 *                   example: false
 *       404:
 *         description: Card not found in WorkHub24
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Card not found"
 *                 success:
 *                   type: boolean
 *                   example: false
 *       500:
 *         description: Internal server error
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Failed to create CSA"
 *                 success:
 *                   type: boolean
 *                   example: false
 */
router.post('/create-csa', validateApiKey, createCSAFromExternal);

/**
 * @swagger
 * /sso/check-user:
 *   get:
 *     summary: Check if CSA exists and needs registration
 *     description: |
 *       This endpoint checks if a CSA exists in the system and whether they
 *       need to complete registration (set password).
 *     tags:
 *       - SSO
 *     parameters:
 *       - in: query
 *         name: email
 *         required: true
 *         schema:
 *           type: string
 *           format: email
 *         description: CSA's email address
 *         example: "john.doe@acorntravels.com"
 *     responses:
 *       200:
 *         description: CSA check completed
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "CSA check completed"
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     exists:
 *                       type: boolean
 *                       example: true
 *                     needsRegistration:
 *                       type: boolean
 *                       example: false
 *                     csaId:
 *                       type: number
 *                       example: 1
 *                     name:
 *                       type: string
 *                       example: "John Doe"
 *                     email:
 *                       type: string
 *                       example: "john.doe@acorntravels.com"
 *                     mobile:
 *                       type: string
 *                       example: "+1234567890"
 *       400:
 *         description: Bad request - missing email parameter
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Email is required"
 *                 success:
 *                   type: boolean
 *                   example: false
 */
router.get('/check-user', checkUserExists);

/**
 * @swagger
 * /sso/logout:
 *   post:
 *     summary: Invalidate SSO session (logout)
 *     description: |
 *       This endpoint invalidates a cached SSO session by cardId, effectively logging
 *       the user out. The session will be removed from the cache.
 *     tags:
 *       - SSO
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - cardId
 *             properties:
 *               cardId:
 *                 type: string
 *                 description: The card ID to invalidate
 *                 example: "CARD123456"
 *     responses:
 *       200:
 *         description: Session invalidated successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "SSO session invalidated successfully"
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     cardId:
 *                       type: string
 *                     invalidatedAt:
 *                       type: string
 *                       format: date-time
 *       400:
 *         description: Missing cardId
 */
router.post('/logout', logoutSSO);

/**
 * @swagger
 * /sso/sessions/stats:
 *   get:
 *     summary: Get SSO session statistics
 *     description: |
 *       Returns statistics about cached SSO sessions including total, active,
 *       expired, and sessions expiring soon.
 *     tags:
 *       - SSO
 *     responses:
 *       200:
 *         description: Session statistics retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "SSO session statistics"
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     totalSessions:
 *                       type: number
 *                       example: 150
 *                     activeSessions:
 *                       type: number
 *                       example: 120
 *                     expiredSessions:
 *                       type: number
 *                       example: 30
 *                     expiringSoon:
 *                       type: number
 *                       example: 5
 *                     timestamp:
 *                       type: string
 *                       format: date-time
 */
router.get('/sessions/stats', getSSOSessionStats);

/**
 * @swagger
 * /sso/sessions/cleanup:
 *   post:
 *     summary: Manually cleanup expired sessions
 *     description: |
 *       Manually triggers cleanup of expired SSO sessions. Note that MongoDB's
 *       TTL index automatically removes expired sessions, but this endpoint can
 *       be used for immediate cleanup if needed.
 *     tags:
 *       - SSO
 *     responses:
 *       200:
 *         description: Expired sessions cleaned up
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Expired sessions cleaned up"
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     deletedCount:
 *                       type: number
 *                       example: 25
 *                     timestamp:
 *                       type: string
 *                       format: date-time
 */
router.post('/sessions/cleanup', cleanupExpiredSessions);

export default router;

