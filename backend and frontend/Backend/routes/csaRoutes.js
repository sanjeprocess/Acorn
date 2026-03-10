import express from 'express';
import { createCSA, getAllCSAs } from '../controllers/csaController.js';

const router = express.Router();

/**
 * @swagger
 * /csa:
 *   post:
 *     summary: Create a new CSA (Customer Service Agent)
 *     tags: 
 *       - CSA
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - email
 *               - mobile
 *             properties:
 *               name:
 *                 type: string
 *                 example: "John Doe"
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "john.doe@acorntravels.com"
 *               mobile:
 *                 type: string
 *                 example: "+1234567890"
 *     responses:
 *       201:
 *         description: Successfully created a new CSA
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "CSA created successfully."
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
 *                           type: integer
 *                           example: 1001
 *                         name:
 *                           type: string
 *                           example: "John Doe"
 *                         email:
 *                           type: string
 *                           format: email
 *                           example: "john.doe@acorntravels.com"
 *                         mobile:
 *                           type: string
 *                           example: "+1234567890"
 *       400:
 *         description: Bad request (missing required fields)
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Name, email, and mobile are required."
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
router.post('', createCSA);

/**
 * @swagger
 * /csa:
 *   get:
 *     summary: Retrieve all CSAs
 *     tags: 
 *       - CSA
 *     responses:
 *       200:
 *         description: Successfully fetched all CSAs
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "All CSAs fetched."
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     csas:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           csaId:
 *                             type: integer
 *                             example: 1001
 *                           name:
 *                             type: string
 *                             example: "John Doe"
 *                           email:
 *                             type: string
 *                             format: email
 *                             example: "john.doe@acorntravels.com"
 *                           mobile:
 *                             type: string
 *                             example: "+1234567890"
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
router.get('', getAllCSAs);

/**
 * @swagger
 * /csa/getAssignedCustomers:
 *   get:
 *     summary: Get assigned customers for a CSA
 *     tags: 
 *       - CSA
 *     parameters:
 *       - in: query
 *         name: csaId
 *         required: true
 *         schema:
 *           type: string
 *         description: CSA ID to get assigned customers
 *         example: "65a8e3f7bc13c6a42c0e5678"
 *     responses:
 *       200:
 *         description: Successfully fetched assigned customers
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Assigned customers fetched successfully."
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     customers:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           customerId:
 *                             type: integer
 *                             example: 1001
 *                           name:
 *                             type: string
 *                             example: "Jane Doe"
 *                           email:
 *                             type: string
 *                             format: email
 *                             example: "jane.doe@example.com"
 *       400:
 *         description: Bad request (missing CSA ID)
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "CSA ID is required."
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
router.get('/getAssignedCustomers', (req, res) => {});

export default router;