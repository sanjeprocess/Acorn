import {
  generateAccessToken,
  verifyRefreshToken,
  generateRefreshToken,
} from "../utils/jwtToken.js";
import * as dotenv from "dotenv";
import asyncHandler from "express-async-handler";
import { CSA } from "../models/csaModel.js";
import { UserTypes } from "../enums/userTypes.js";
import { Customer } from "../models/customerModel.js";
import bcrypt from "bcrypt";

dotenv.config();

export const registerCSA = asyncHandler(async (req, res) => {
  const { name, password, mobile, email } = req.body;

  // Validate required fields - mobile is required for new registrations, optional for SSO completion
  if (!name || !password || !email) {
    res.status(400);
    throw new Error("Name, email and password are required.");
  }

  // Check if CSA already exists
  const existingCSA = await CSA.findOne({ email }).exec();

  let user;

  if (existingCSA) {
    // CSA exists - check if it's an SSO user with temp password
    if (existingCSA.isTempPassword) {
      // Update existing CSA with new password and mobile (completing registration)
      existingCSA.password = password;
      existingCSA.mobile = mobile;
      existingCSA.isTempPassword = false;
      // Update name if provided (in case it changed)
      if (name) {
        existingCSA.name = name;
      }
      
      await existingCSA.save();
      user = existingCSA;
      
      console.log(`SSO user registration completed for email: ${email}`);
    } else {
      // CSA exists with permanent password - duplicate registration attempt
      res.status(400);
      throw new Error(`Email already exists for ${email}. Please sign in instead.`);
    }
  } else {
    // CSA doesn't exist - create new CSA
    user = await CSA.create(req.body);

    if (!user) {
      res.status(500);
      throw new Error("User registration failed.");
    }

    console.log(`New CSA registered with email: ${email}`);
  }

  const newRefreshToken = generateRefreshToken(user?.csaId, UserTypes.CSA);
  const newAccessToken = generateAccessToken(user?.csaId, UserTypes.CSA);

  res.json({
    message: "User registration successful.",
    success: true,
    data: {
      user,
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    },
  });
});

export const loginCSA = asyncHandler(async (req, res) => {
  const { email, password } = req.body;
  
  // Validate input
  if (!email || !password) {
    res.status(400);
    throw new Error("Email and password are required");
  }

  // Check if user exists or not
  const user = await CSA.findOne({ email }).exec();

  if (!user) {
    res.status(401);
    throw new Error("Invalid email or password");
  }

  // Verify password
  const isPasswordValid = await user.isPasswordMatched(password);
  
  if (!isPasswordValid) {
    res.status(401);
    throw new Error("Invalid email or password");
  }

  // Generate tokens
  const newRefreshToken = generateRefreshToken(user?.csaId, UserTypes.CSA);
  const newAccessToken = generateAccessToken(user?.csaId, UserTypes.CSA);

  res.json({
    message: "User login successful.",
    success: true,
    data: {
      user,
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    },
  });
});

export const loginCustomer = asyncHandler(async (req, res) => {
    const { email, password } = req.body;
    
    // Validate input
    if (!email || !password) {
      res.status(400);
      throw new Error("Email and password are required");
    }
  
    // Find customer and populate CSA using aggregation
    const customerAggregation = await Customer.aggregate([
      {
        $match: { email }, // Find customer by email
      },
      {
        $addFields: { csa: { $toInt: "$csa" } } // Convert csa to Integer for matching
      },
      {
        $lookup: {
          from: "csas", // CSA collection (MongoDB uses lowercase & plural)
          localField: "csa", // ✅ Ensure this is a Number
          foreignField: "csaId", // ✅ Match with csaId in CSA collection
          as: "csaDetails",
        },
      },
      {
        $unwind: {
          path: "$csaDetails",
          preserveNullAndEmptyArrays: true, // Allows empty CSA without breaking
        },
      },
      {
        $project: {
          _id: 0,
          customerId: 1,
          name: 1,
          email: 1,
          password: 1,
          csa: {
            $cond: { // ✅ Handle empty CSA case
              if: { $eq: ["$csaDetails", {}] },
              then: null,
              else: {
                name: "$csaDetails.name",
                email: "$csaDetails.email",
                mobile: "$csaDetails.mobile"
              }
            }
          },
        },
      },
    ]);
  
    if (!customerAggregation.length) {
      res.status(401);
      throw new Error("Invalid email or password");
    }
  
    const customer = customerAggregation[0];
    
    // Check if password exists
    if (!customer.password) {
      res.status(401);
      throw new Error("Invalid email or password");
    }
  
    // Check if password matches
    const isPasswordMatched = await bcrypt.compare(password, customer.password);
  
    if (!isPasswordMatched) {
      res.status(401);
      throw new Error("Invalid email or password");
    }
    
    // Generate tokens
    const newRefreshToken = generateRefreshToken(
      customer.customerId,
      UserTypes.Customer
    );
    const newAccessToken = generateAccessToken(
      customer.customerId,
      UserTypes.Customer
    );

    res.json({
      message: "Customer login successful.",
      success: true,
      data: {
        customer: {
          customerId: customer.customerId,
          name: customer.name,
          email: customer.email,
          csa: customer.csa || null, // ✅ Ensure `null` if no CSA found
        },
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      },
    });
  });
  
export const checkIsCustomerPasswordAvailable = asyncHandler(
  async (req, res) => {
    const { email } = req.query;

    const customer = await Customer.findOne({ email }).lean().exec();

    if (!customer) {
      res.status(404);
      throw new Error("No customer found for email " + email);
    }

    if (customer.password) {
      res.json({
        message: "Password available for customer.",
        success: true,
        data: {
          isPasswordAvailable: true,
        },
      });
    } else {
      res.json({
        message: "Password not available for customer.",
        success: true,
        data: {
          isPasswordAvailable: false,
        },
      });
    }
  }
);

export const updateCustomerPassword = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    res.status(400);
    throw new Error("Email and password is required.");
  }

  const customer = await Customer.findOne({ email }).lean().exec();

  if (!customer) {
    res.status(400);
    throw new Error(`Customer is not added to the system with ${email}`);
  }

  const salt = bcrypt.genSaltSync(10);
  const hashedPassword = await bcrypt.hash(password, salt);

  const updatedCustomer = await Customer.findOneAndUpdate(
    {
      email,
    },
    {
      password: hashedPassword,
    },
    {
      new: true,
    }
  );

  if (!updatedCustomer) {
    res.status(500);
    throw new Error("Password update failed.");
  }

  res.json({
    message: "Password updated successfully.",
    success: true,
    data: {
      customer: updatedCustomer,
    },
  });
});

export const handleRefreshToken = asyncHandler(async (req, res) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    res.status(404);
    throw new Error("No refresh token found!");
  }

  const { userId, type } = await verifyRefreshToken(refreshToken);

  let user;
  if (type === UserTypes.CSA) {
    user = await CSA.findOne({ csaId: userId }).lean().exec();
  } else if (type === UserTypes.Customer) {
    user = await Customer.findOne({ customerId: userId }).lean().exec();
  }

  if (!user) {
    res.status(404);
    throw new Error("No user with provided refresh token");
  }

  // Generate new Access Token
  const newRefreshToken = generateRefreshToken(user?.userId || user?.csaId || user?.customerId, type);
  const newAccessToken = generateAccessToken(user?.userId || user?.csaId || user?.customerId, type);

  res.json({
    message: "login refreshed.",
    success: true,
    data: {
      user: user,
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    },
  });
});
