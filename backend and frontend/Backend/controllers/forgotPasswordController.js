import asyncHandler from "express-async-handler";
import crypto from "crypto";
import { CSA } from "../models/csaModel.js";
import { Customer } from "../models/customerModel.js";
import { OTP } from "../models/otpModel.js";
import emailService from "../services/emailService.js";
import { AppError } from "../middleware/errorHandler.js";
import bcrypt from "bcrypt";

// Send OTP for password reset
export const sendPasswordResetOTP = asyncHandler(async (req, res) => {
  const { email, userType } = req.body;

  if (!email || !userType) {
    throw new AppError("Email and user type are required", 400);
  }

  if (!["CSA", "Customer"].includes(userType)) {
    throw new AppError("Invalid user type. Must be 'CSA' or 'Customer'", 400);
  }

  // Check if user exists
  let user;
  if (userType === "CSA") {
    user = await CSA.findOne({ email }).lean().exec();
  } else {
    user = await Customer.findOne({ email }).lean().exec();
  }

  if (!user) {
    throw new AppError("No account found with this email address", 404);
  }

  // Check if user has a password set (for customers)
  if (userType === "Customer" && !user.password) {
    throw new AppError("No password set for this account. Please contact support.", 400);
  }

  try {
    // Create OTP record
    const otpRecord = await OTP.createOTP(email, userType, "PASSWORD_RESET");
    
    console.log("Created OTP record:", {
      email: otpRecord.email,
      otp: otpRecord.otp,
      userType: otpRecord.userType,
      expiresAt: otpRecord.expiresAt
    });

    // Send OTP via email
    await emailService.sendPasswordResetOTP(
      email,
      user.name,
      otpRecord.otp
    );

    res.json({
      success: true,
      message: "Password reset OTP sent to your email address",
      data: {
        email: email,
        expiresIn: 10 * 60, // 10 minutes in seconds
        userType: userType
      }
    });
  } catch (error) {
    console.error("Error sending password reset OTP:", error);
    throw new AppError("Failed to send password reset OTP. Please try again.", 500);
  }
});

// Verify OTP for password reset
export const verifyPasswordResetOTP = asyncHandler(async (req, res) => {
  const { email, otp, userType } = req.body;

  if (!email || !otp || !userType) {
    throw new AppError("Email, OTP, and user type are required", 400);
  }

  try {
    // Find the OTP record
    const otpRecord = await OTP.findOne({
      email,
      type: "PASSWORD_RESET",
      userType,
      isUsed: false
    }).exec();

    console.log("OTP verification request:", { email, otp, userType });
    console.log("Found OTP record:", otpRecord ? {
      email: otpRecord.email,
      otp: otpRecord.otp,
      isUsed: otpRecord.isUsed,
      expiresAt: otpRecord.expiresAt,
      attempts: otpRecord.attempts
    } : "No OTP record found");

    if (!otpRecord) {
      throw new AppError("Invalid or expired OTP", 400);
    }

    // Verify the OTP
    otpRecord.verifyOTP(otp);

    // Mark OTP as used and save
    otpRecord.isUsed = true;
    if (otpRecord.attempts > 0) {
      otpRecord.attempts = 0; // Reset attempts on successful verification
    }
    await otpRecord.save();

    res.json({
      success: true,
      message: "OTP verified successfully. You can now reset your password.",
      data: {
        email: email,
        userType: userType
      }
    });
  } catch (error) {
    console.error("OTP verification error:", error.message);
    if (error.message.includes("OTP") || error.message.includes("expired") || error.message.includes("used") || error.message.includes("Invalid") || error.message.includes("Maximum")) {
      throw new AppError(error.message, 400);
    }
    throw new AppError("OTP verification failed", 500);
  }
});

// Reset password with token
export const resetPassword = asyncHandler(async (req, res) => {
  const { email, newPassword, userType } = req.body;

  if (!email || !newPassword || !userType) {
    throw new AppError("Email, new password, and user type are required", 400);
  }

  // Validate password strength
  if (newPassword.length < 6) {
    throw new AppError("Password must be at least 6 characters long", 400);
  }

  if (!/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/.test(newPassword)) {
    throw new AppError("Password must contain at least one lowercase letter, one uppercase letter, and one number", 400);
  }

  try {
    // Check if there's a verified OTP for this email (recently verified)
    const otpRecord = await OTP.findOne({
      email,
      type: "PASSWORD_RESET",
      userType,
      isUsed: true
    }).sort({ updatedAt: -1 }).exec();

    if (!otpRecord) {
      throw new AppError("No verified OTP found. Please verify your OTP first.", 400);
    }

    // Check if OTP was verified recently (within last 10 minutes)
    const tenMinutesAgo = new Date(Date.now() - 10 * 60 * 1000);
    if (otpRecord.updatedAt < tenMinutesAgo) {
      throw new AppError("OTP verification has expired. Please request a new OTP.", 400);
    }

    // Hash the new password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    // Update user's password
    let user;
    if (userType === "CSA") {
      user = await CSA.findOneAndUpdate(
        { email },
        { password: hashedPassword },
        { new: true }
      );
    } else {
      user = await Customer.findOneAndUpdate(
        { email },
        { password: hashedPassword },
        { new: true }
      );
    }

    if (!user) {
      throw new AppError("User not found", 404);
    }

    // Clean up all OTP records for this email
    await OTP.deleteMany({
      email,
      type: "PASSWORD_RESET",
      userType
    });

    res.json({
      success: true,
      message: "Password reset successfully. You can now login with your new password.",
      data: {
        email: email,
        userType: userType
      }
    });
  } catch (error) {
    console.error("Password reset error:", error.message);
    if (error.message.includes("OTP") || error.message.includes("expired") || error.message.includes("Invalid") || error.message.includes("Password")) {
      throw new AppError(error.message, 400);
    }
    throw new AppError("Password reset failed", 500);
  }
});

// Resend OTP
export const resendPasswordResetOTP = asyncHandler(async (req, res) => {
  const { email, userType } = req.body;

  if (!email || !userType) {
    throw new AppError("Email and user type are required", 400);
  }

  // Check if user exists
  let user;
  if (userType === "CSA") {
    user = await CSA.findOne({ email }).lean().exec();
  } else {
    user = await Customer.findOne({ email }).lean().exec();
  }

  if (!user) {
    throw new AppError("No account found with this email address", 404);
  }

  // Check rate limiting (max 3 OTPs per hour)
  const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);
  const recentOTPs = await OTP.countDocuments({
    email,
    type: "PASSWORD_RESET",
    createdAt: { $gte: oneHourAgo }
  });

  if (recentOTPs >= 3) {
    throw new AppError("Too many OTP requests. Please try again later.", 429);
  }

  try {
    // Create new OTP record
    const otpRecord = await OTP.createOTP(email, userType, "PASSWORD_RESET");

    // Send OTP via email
    await emailService.sendPasswordResetOTP(
      email,
      user.name,
      otpRecord.otp
    );

    res.json({
      success: true,
      message: "New password reset OTP sent to your email address",
      data: {
        email: email,
        expiresIn: 10 * 60, // 10 minutes in seconds
        userType: userType
      }
    });
  } catch (error) {
    console.error("Error resending password reset OTP:", error);
    throw new AppError("Failed to resend password reset OTP. Please try again.", 500);
  }
});

