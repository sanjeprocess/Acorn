import express from "express";
import {
  checkIsCustomerPasswordAvailable,
  handleRefreshToken,
  loginCSA,
  loginCustomer,
  registerCSA,
  updateCustomerPassword,
} from "../controllers/authController.js";
import {
  validateRegisterCSA,
  validateLoginCSA,
  validateLoginCustomer,
  validateUpdatePassword,
  validateEmailQuery,
} from "../middleware/validation.js";

const router = express.Router();

/**
 * @swagger
 * /auth/registerCSA:
 *   post:
 *     summary: Register a new CSA
 *     tags: 
 *       - Auth
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - password
 *               - mobile
 *               - email
 *             properties:
 *               name:
 *                 type: string
 *                 example: "John Doe"
 *               password:
 *                 type: string
 *                 format: password
 *                 example: "SecurePass123"
 *               mobile:
 *                 type: string
 *                 example: "+1234567890"
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "john.doe@acorntravels.com"
 *     responses:
 *       200:
 *         description: Successfully registered a new CSA
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "User registration successful."
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     user:
 *                       type: object
 *                       example: { "_id": "60d0fe4f5311236168a109ca", "name": "John Doe", "mobile": "+1234567890" }
 *                     accessToken:
 *                       type: string
 *                       example: "eyJhbGciOiJIUzI1NiIsInR5cCI..."
 *                     refreshToken:
 *                       type: string
 *                       example: "eyJhbGciOiJIUzI1NiIsInR5cCI..."
 *       400:
 *         description: Bad request (missing fields or duplicate mobile number)
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Mobile number, name and password is required."
 *                 success:
 *                   type: boolean
 *                   example: false
 *       401:
 *         description: Unauthorized request
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Unauthorized request."
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
 *                   example: "User registration failed."
 *                 success:
 *                   type: boolean
 *                   example: false
 */
router.post("/registerCSA", validateRegisterCSA, registerCSA);

/**
 * @swagger
 * /auth/loginCSA:
 *   post:
 *     summary: Login as a CSA (Admin)
 *     tags: 
 *       - Auth
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "john.doe@acorntravels.com"
 *               password:
 *                 type: string
 *                 format: password
 *                 example: "SecurePass123"
 *     responses:
 *       200:
 *         description: Successfully logged in
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "User login successful."
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     user:
 *                       type: object
 *                       example: { "_id": "60d0fe4f5311236168a109ca", "name": "John Doe", "mobile": "+1234567890" }
 *                     accessToken:
 *                       type: string
 *                       example: "eyJhbGciOiJIUzI1NiIsInR5cCI..."
 *                     refreshToken:
 *                       type: string
 *                       example: "eyJhbGciOiJIUzI1NiIsInR5cCI..."
 *       400:
 *         description: Bad request (missing fields)
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Email and password are required."
 *                 success:
 *                   type: boolean
 *                   example: false
 *       404:
 *         description: No user found for the provided email
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "No user found for email john.doe@acorntravels.com"
 *                 success:
 *                   type: boolean
 *                   example: false
 *       403:
 *         description: Invalid credentials
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Invalid Credentials"
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
 *                   example: "An unexpected error occurred."
 *                 success:
 *                   type: boolean
 *                   example: false
 */
router.post("/loginCSA", validateLoginCSA, loginCSA);

/**
 * @swagger
 * /auth/loginCustomer:
 *   post:
 *     summary: Login as a Customer
 *     tags: 
 *       - Auth
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "customer@example.com"
 *               password:
 *                 type: string
 *                 format: password
 *                 example: "SecurePass123"
 *     responses:
 *       200:
 *         description: Successfully logged in
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Customer login successful."
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     customer:
 *                       type: object
 *                       example: { "_id": "60d0fe4f5311236168a109ca", "name": "Jane Doe", "email": "customer@example.com" }
 *                     accessToken:
 *                       type: string
 *                       example: "eyJhbGciOiJIUzI1NiIsInR5cCI..."
 *                     refreshToken:
 *                       type: string
 *                       example: "eyJhbGciOiJIUzI1NiIsInR5cCI..."
 *       400:
 *         description: Bad request (missing fields)
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Email and password are required."
 *                 success:
 *                   type: boolean
 *                   example: false
 *       404:
 *         description: No customer found for the provided email
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "No customer found for email customer@example.com"
 *                 success:
 *                   type: boolean
 *                   example: false
 *       403:
 *         description: Invalid credentials
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Invalid Credentials"
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
 *                   example: "An unexpected error occurred."
 *                 success:
 *                   type: boolean
 *                   example: false
 */
router.post("/loginCustomer", validateLoginCustomer, loginCustomer);

/**
 * @swagger
 * /auth/refreshToken:
 *   post:
 *     summary: Refresh access and refresh tokens
 *     tags: 
 *       - Auth
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - refreshToken
 *             properties:
 *               refreshToken:
 *                 type: string
 *                 example: "eyJhbGciOiJIUzI1NiIsInR5cCI..."
 *     responses:
 *       200:
 *         description: Successfully refreshed tokens
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Login refreshed."
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     user:
 *                       type: object
 *                       example: { "_id": "60d0fe4f5311236168a109ca", "name": "John Doe", "userType": "CSA" }
 *                     accessToken:
 *                       type: string
 *                       example: "eyJhbGciOiJIUzI1NiIsInR5cCI..."
 *                     refreshToken:
 *                       type: string
 *                       example: "eyJhbGciOiJIUzI1NiIsInR5cCI..."
 *       400:
 *         description: Bad request (missing fields)
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Refresh token is required."
 *                 success:
 *                   type: boolean
 *                   example: false
 *       404:
 *         description: No user found for the provided refresh token
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "No user with provided refresh token"
 *                 success:
 *                   type: boolean
 *                   example: false
 *       403:
 *         description: Invalid or expired refresh token
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Invalid refresh token."
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
 *                   example: "An unexpected error occurred."
 *                 success:
 *                   type: boolean
 *                   example: false
 */
router.post("/refreshToken", handleRefreshToken);

/**
 * @swagger
 * /auth/checkPassword:
 *   get:
 *     summary: Check if a customer has set a password
 *     tags: 
 *       - Auth
 *     parameters:
 *       - in: query
 *         name: email
 *         required: true
 *         schema:
 *           type: string
 *           format: email
 *         description: Customer's email address to check password availability
 *         example: "customer@example.com"
 *     responses:
 *       200:
 *         description: Successfully checked password availability
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Password available for customer."
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     isPasswordAvailable:
 *                       type: boolean
 *                       example: true
 *       400:
 *         description: Bad request (missing email parameter)
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Email query parameter is required."
 *                 success:
 *                   type: boolean
 *                   example: false
 *       404:
 *         description: No customer found for the provided email
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "No customer found for email customer@example.com"
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
 *                   example: "An unexpected error occurred."
 *                 success:
 *                   type: boolean
 *                   example: false
 */
router.get("/checkPassword", validateEmailQuery, checkIsCustomerPasswordAvailable);

/**
 * @swagger
 * /auth/updateCustomerPassword:
 *   patch:
 *     summary: Update customer's password
 *     tags: 
 *       - Auth
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "customer@example.com"
 *               password:
 *                 type: string
 *                 format: password
 *                 example: "NewSecurePass123"
 *     responses:
 *       200:
 *         description: Successfully updated password
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Password updated successfully."
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     updatedCustomer:
 *                       type: object
 *                       example: { "_id": "60d0fe4f5311236168a109ca", "name": "Jane Doe", "email": "customer@example.com" }
 *                     accessToken:
 *                       type: string
 *                       example: "eyJhbGciOiJIUzI1NiIsInR5cCI..."
 *                     refreshToken:
 *                       type: string
 *                       example: "eyJhbGciOiJIUzI1NiIsInR5cCI..."
 *       400:
 *         description: Bad request (missing fields or customer not found)
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Email and password is required."
 *                 success:
 *                   type: boolean
 *                   example: false
 *       404:
 *         description: No customer found with the provided email
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Customer is not added to the system with customer@example.com"
 *                 success:
 *                   type: boolean
 *                   example: false
 *       500:
 *         description: Internal server error (failed to update password)
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Password update failed."
 *                 success:
 *                   type: boolean
 *                   example: false
 */
router.patch("/updateCustomerPassword", validateUpdatePassword, updateCustomerPassword);

export default router;
