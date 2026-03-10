import express from 'express';
import { addNewFeedback, getAllFeedbacks, getFeedbackByCustomer, getFeedbackByTravelId } from '../controllers/feedbackController.js';

const router = express.Router();

/**
 * @swagger
 * /feedback:
 *   post:
 *     summary: Submit a new travel feedback
 *     description: Adds a new feedback entry linked to a customer and travel ID, updating the associated travel record.
 *     tags:
 *       - Feedback
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - customerId
 *               - travelId
 *               - feedback
 *             properties:
 *               customerId:
 *                 type: string
 *                 description: Unique ID of the customer submitting the feedback
 *                 example: "65d8f4a2ab13c54277b12345"
 *               travelId:
 *                 type: string
 *                 description: Unique travel ID associated with the feedback
 *                 example: "TRVL123456"
 *               rating:
 *                 type: integer
 *                 description: Rating given by the customer (1-5)
 *                 example: 5
 *               feedback:
 *                 type: string
 *                 description: Detailed feedback message from the customer
 *                 example: "The trip was amazing! Everything was well-organized."
 *     responses:
 *       200:
 *         description: Feedback submitted successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Feedback added successfully."
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     feedback:
 *                       type: object
 *                       properties:
 *                         _id:
 *                           type: string
 *                           example: "65d9e3a2bc13c54277b67890"
 *                         customerId:
 *                           type: string
 *                           example: "65d8f4a2ab13c54277b12345"
 *                         travelId:
 *                           type: string
 *                           example: "TRVL123456"
 *                         rating:
 *                           type: integer
 *                           example: 5
 *                         feedback:
 *                           type: string
 *                           example: "The trip was amazing! Everything was well-organized."
 *                         createdAt:
 *                           type: string
 *                           format: date-time
 *                           example: "2025-03-02T10:45:32.123Z"
 *       400:
 *         description: Invalid request - missing required fields
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "customerId, travelId, and feedback are required"
 *                 success:
 *                   type: boolean
 *                   example: false
 *       404:
 *         description: Customer or travel record not found
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "No customer found for ID {customerId} or no travel found for ID {travelId}"
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
router.post('/', addNewFeedback);

/**
 * @swagger
 * /feedback:
 *   get:
 *     summary: Retrieve all feedback records
 *     description: Fetches all feedback entries from the database, including associated customer details.
 *     tags:
 *       - Feedback
 *     responses:
 *       200:
 *         description: Successfully retrieved all feedback records.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "All feedbacks fetched."
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     feedbacks:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           feedbackId:
 *                             type: integer
 *                             example: 1
 *                           travelId:
 *                             type: string
 *                             example: "TRVL123456"
 *                           rating:
 *                             type: integer
 *                             example: 5
 *                           feedback:
 *                             type: string
 *                             example: "The trip was excellent! Everything was well-planned."
 *                           createdAt:
 *                             type: string
 *                             format: date-time
 *                             example: "2025-03-02T10:45:32.123Z"
 *                           updatedAt:
 *                             type: string
 *                             format: date-time
 *                             example: "2025-03-02T11:15:32.123Z"
 *                           customer:
 *                             type: object
 *                             properties:
 *                               name:
 *                                 type: string
 *                                 example: "John Doe"
 *                               email:
 *                                 type: string
 *                                 format: email
 *                                 example: "johndoe@example.com"
 *                               csa:
 *                                 type: string
 *                                 example: "65a8e3f7bc13c6a42c0e5678"
 *                                 description: "CSA ID (legacy field)"
 *                           csa:
 *                             type: object
 *                             properties:
 *                               csaId:
 *                                 type: number
 *                                 example: 1
 *                               name:
 *                                 type: string
 *                                 example: "Jane Smith"
 *                           travel:
 *                             type: object
 *                             properties:
 *                               startingLocation:
 *                                 type: string
 *                                 example: "New York"
 *                               destination:
 *                                 type: string
 *                                 example: "Los Angeles"
 *                               travelDate:
 *                                 type: string
 *                                 format: date
 *                                 example: "2025-03-15"
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
router.get('/', getAllFeedbacks);

/**
 * @swagger
 * /feedback/customer/{customerId}:
 *   get:
 *     summary: Retrieve all feedback for a specific customer
 *     description: Fetches feedback entries linked to a customer, including customer details.
 *     tags:
 *       - Feedback
 *     parameters:
 *       - in: path
 *         name: customerId
 *         required: true
 *         schema:
 *           type: string
 *         description: Unique ID of the customer whose feedback is being retrieved
 *         example: "65d8f4a2ab13c54277b12345"
 *     responses:
 *       200:
 *         description: Successfully fetched feedback records for the customer.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Feedbacks fetched for customer 65d8f4a2ab13c54277b12345"
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     feedbacks:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           feedbackId:
 *                             type: integer
 *                             example: 1
 *                           travelId:
 *                             type: string
 *                             example: "TRVL123456"
 *                           rating:
 *                             type: integer
 *                             example: 5
 *                           feedback:
 *                             type: string
 *                             example: "The trip was fantastic! Everything was well-organized."
 *                           createdAt:
 *                             type: string
 *                             format: date-time
 *                             example: "2025-03-02T10:45:32.123Z"
 *                           updatedAt:
 *                             type: string
 *                             format: date-time
 *                             example: "2025-03-02T11:15:32.123Z"
 *                           customer:
 *                             type: object
 *                             properties:
 *                               name:
 *                                 type: string
 *                                 example: "John Doe"
 *                               email:
 *                                 type: string
 *                                 format: email
 *                                 example: "johndoe@example.com"
 *                               csa:
 *                                 type: string
 *                                 example: "65a8e3f7bc13c6a42c0e5678"
 *                                 description: "CSA ID (legacy field)"
 *                           csa:
 *                             type: object
 *                             properties:
 *                               csaId:
 *                                 type: number
 *                                 example: 1
 *                               name:
 *                                 type: string
 *                                 example: "Jane Smith"
 *                           travel:
 *                             type: object
 *                             properties:
 *                               startingLocation:
 *                                 type: string
 *                                 example: "New York"
 *                               destination:
 *                                 type: string
 *                                 example: "Los Angeles"
 *                               travelDate:
 *                                 type: string
 *                                 format: date
 *                                 example: "2025-03-15"
 *       400:
 *         description: Invalid request (missing or malformed customer ID)
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Invalid customer ID."
 *                 success:
 *                   type: boolean
 *                   example: false
 *       404:
 *         description: No feedback records found for the customer
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "No feedback found for customer 65d8f4a2ab13c54277b12345"
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
router.get('/customer/:customerId', getFeedbackByCustomer);

/**
 * @swagger
 * /feedback/travel/{travelId}:
 *   get:
 *     summary: Get feedback for a specific travel record
 *     description: Fetches feedback for a given travel ID.
 *     tags:
 *       - Feedback
 *     parameters:
 *       - in: path
 *         name: travelId
 *         required: true
 *         schema:
 *           type: integer
 *         description: The ID of the travel record to fetch feedback for.
 *     responses:
 *       200:
 *         description: Successfully retrieved feedback for the specified travel ID.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Feedbacks fetched for travelId 123"
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     feedbacks:
 *                       type: object
 *                       properties:
 *                         feedbackId:
 *                           type: integer
 *                           example: 1
 *                         travelId:
 *                           type: integer
 *                           example: 123
 *                         customer:
 *                           type: string
 *                           example: "65d8f4a2ab13c54277b12345"
 *                         rating:
 *                           type: integer
 *                           example: 5
 *                         feedback:
 *                           type: string
 *                           example: "Great experience!"
 *                         createdAt:
 *                           type: string
 *                           format: date-time
 *                           example: "2025-03-02T10:45:32.123Z"
 *       404:
 *         description: No feedback found for the given travel ID.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "No feedback found for travel ID 123"
 *                 success:
 *                   type: boolean
 *                   example: false
 *       500:
 *         description: Internal server error.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "An error occurred while fetching feedback."
 *                 success:
 *                   type: boolean
 *                   example: false
 */
router.get('/travel/:travelId', getFeedbackByTravelId);

export default router;