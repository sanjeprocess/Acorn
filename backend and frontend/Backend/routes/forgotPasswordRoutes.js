import express from "express";
import {
  sendPasswordResetOTP,
  verifyPasswordResetOTP,
  resetPassword,
  resendPasswordResetOTP,
} from "../controllers/forgotPasswordController.js";
import { body } from "express-validator";
import { handleValidationErrors } from "../middleware/validation.js";

const router = express.Router();

// Validation middleware
const validateEmailAndUserType = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email address'),
  body('userType')
    .isIn(['CSA', 'Customer'])
    .withMessage('User type must be either CSA or Customer'),
  handleValidationErrors
];

const validateOTPVerification = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email address'),
  body('otp')
    .isLength({ min: 6, max: 6 })
    .isNumeric()
    .withMessage('OTP must be a 6-digit number'),
  body('userType')
    .isIn(['CSA', 'Customer'])
    .withMessage('User type must be either CSA or Customer'),
  handleValidationErrors
];

const validatePasswordReset = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email address'),
  body('newPassword')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters long')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage('Password must contain at least one lowercase letter, one uppercase letter, and one number'),
  body('userType')
    .isIn(['CSA', 'Customer'])
    .withMessage('User type must be either CSA or Customer'),
  handleValidationErrors
];

/**
 * @swagger
 * /forgot-password/send-otp:
 *   post:
 *     summary: Send OTP for password reset
 *     tags: 
 *       - Forgot Password
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - userType
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "user@example.com"
 *               userType:
 *                 type: string
 *                 enum: [CSA, Customer]
 *                 example: "CSA"
 *     responses:
 *       200:
 *         description: OTP sent successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "Password reset OTP sent to your email address"
 *                 data:
 *                   type: object
 *                   properties:
 *                     email:
 *                       type: string
 *                       example: "user@example.com"
 *                     expiresIn:
 *                       type: number
 *                       example: 600
 *                     userType:
 *                       type: string
 *                       example: "CSA"
 *       400:
 *         description: Bad request
 *       404:
 *         description: User not found
 *       429:
 *         description: Too many requests
 */
router.post("/send-otp", validateEmailAndUserType, sendPasswordResetOTP);

/**
 * @swagger
 * /forgot-password/verify-otp:
 *   post:
 *     summary: Verify OTP for password reset
 *     tags: 
 *       - Forgot Password
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - otp
 *               - userType
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "user@example.com"
 *               otp:
 *                 type: string
 *                 pattern: "^[0-9]{6}$"
 *                 example: "123456"
 *               userType:
 *                 type: string
 *                 enum: [CSA, Customer]
 *                 example: "CSA"
 *     responses:
 *       200:
 *         description: OTP verified successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "OTP verified successfully"
 *                 data:
 *                   type: object
 *                   properties:
 *                     email:
 *                       type: string
 *                       example: "user@example.com"
 *                     userType:
 *                       type: string
 *                       example: "CSA"
 *       400:
 *         description: Invalid or expired OTP
 */
router.post("/verify-otp", validateOTPVerification, verifyPasswordResetOTP);

/**
 * @swagger
 * /forgot-password/reset:
 *   post:
 *     summary: Reset password after OTP verification
 *     tags: 
 *       - Forgot Password
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - newPassword
 *               - userType
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "user@example.com"
 *               newPassword:
 *                 type: string
 *                 format: password
 *                 example: "NewSecurePass123"
 *               userType:
 *                 type: string
 *                 enum: [CSA, Customer]
 *                 example: "CSA"
 *     responses:
 *       200:
 *         description: Password reset successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "Password reset successfully"
 *                 data:
 *                   type: object
 *                   properties:
 *                     email:
 *                       type: string
 *                       example: "user@example.com"
 *                     userType:
 *                       type: string
 *                       example: "CSA"
 *       400:
 *         description: Invalid request or expired token
 */
router.post("/reset", validatePasswordReset, resetPassword);

/**
 * @swagger
 * /forgot-password/resend-otp:
 *   post:
 *     summary: Resend OTP for password reset
 *     tags: 
 *       - Forgot Password
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - userType
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "user@example.com"
 *               userType:
 *                 type: string
 *                 enum: [CSA, Customer]
 *                 example: "CSA"
 *     responses:
 *       200:
 *         description: New OTP sent successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "New password reset OTP sent to your email address"
 *                 data:
 *                   type: object
 *                   properties:
 *                     email:
 *                       type: string
 *                       example: "user@example.com"
 *                     expiresIn:
 *                       type: number
 *                       example: 600
 *                     userType:
 *                       type: string
 *                       example: "CSA"
 *       429:
 *         description: Too many requests
 */
router.post("/resend-otp", validateEmailAndUserType, resendPasswordResetOTP);

export default router;

