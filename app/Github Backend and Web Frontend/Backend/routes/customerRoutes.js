import express from 'express';
import { createCustomer, deleteCustomer, getAllCustomers, getAssignedCustomers, getSingleCustomer, searchCustomer } from '../controllers/customerController.js';

const router = express.Router();

import multer from "multer";
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

/**
 * @swagger
 * /customer:
 *   get:
 *     summary: Retrieve all customers
 *     tags: 
 *       - Customer
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Successfully fetched all customers
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "All customers fetched."
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
 *                           _id:
 *                             type: string
 *                             example: "60d0fe4f5311236168a109ca"
 *                           name:
 *                             type: string
 *                             example: "John Doe"
 *                           email:
 *                             type: string
 *                             format: email
 *                             example: "johndoe@example.com"
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
router.get('/', getAllCustomers);

/**
 * @swagger
 * /customer:
 *   post:
 *     summary: Create a new customer
 *     tags: 
 *       - Customer
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - email
 *               - csa
 *             properties:
 *               name:
 *                 type: string
 *                 example: "John Doe"
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "johndoe@example.com"
 *               csa:
 *                 type: string
 *                 example: "65a8e3f7bc13c6a42c0e5678"
 *     responses:
 *       201:
 *         description: Successfully created a new customer
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Customer created successfully."
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     customer:
 *                       type: object
 *                       properties:
 *                         customerId:
 *                           type: integer
 *                           example: 1001
 *                         name:
 *                           type: string
 *                           example: "John Doe"
 *                         email:
 *                           type: string
 *                           format: email
 *                           example: "johndoe@example.com"
 *                         csa:
 *                           type: string
 *                           example: "65a8e3f7bc13c6a42c0e5678"
 *       400:
 *         description: Bad request (missing required fields)
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Name, email, and CSA are required."
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
router.post('/', createCustomer);

/**
 * @swagger
 * /customer/{customerId}:
 *   get:
 *     summary: Retrieve a single customer by ID
 *     tags: 
 *       - Customer
 *     parameters:
 *       - in: path
 *         name: customerId
 *         required: true
 *         schema:
 *           type: string
 *         description: Unique ID of the customer
 *         example: "60d0fe4f5311236168a109ca"
 *     responses:
 *       200:
 *         description: Successfully fetched the customer
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Customer fetched."
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     customer:
 *                       type: object
 *                       properties:
 *                         _id:
 *                           type: string
 *                           example: "60d0fe4f5311236168a109ca"
 *                         name:
 *                           type: string
 *                           example: "John Doe"
 *                         email:
 *                           type: string
 *                           format: email
 *                           example: "johndoe@example.com"
 *       400:
 *         description: Invalid request (missing or malformed ID)
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
 *         description: Customer not found
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Customer not found"
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
/**
 * @swagger
 * /customer/search:
 *   get:
 *     summary: Search customers by name or email
 *     tags: 
 *       - Customer
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: csaId
 *         required: true
 *         schema:
 *           type: string
 *         description: ID of the Customer Service Agent
 *       - in: query
 *         name: searchQuery
 *         required: false
 *         schema:
 *           type: string
 *         description: Search query to filter customers by name or email
 *     responses:
 *       200:
 *         description: Successfully fetched search results
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Search results fetched."
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
 *                           name:
 *                             type: string
 *                           email:
 *                             type: string
 *                           csa:
 *                             type: string
 *       400:
 *         description: Bad request (missing csaId)
 *       500:
 *         description: Internal server error
 */
router.get('/search', searchCustomer);

/**
 * @swagger
 * /assignedCustomers/{csaId}:
 *   get:
 *     summary: Retrieve assigned customers by CSA ID
 *     description: Fetches a list of customers assigned to a specific Customer Service Agent (CSA).
 *     parameters:
 *       - in: path
 *         name: csaId
 *         required: true
 *         schema:
 *           type: string
 *         description: ID of the Customer Service Agent
 *     responses:
 *       200:
 *         description: A list of assigned customers
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     customers:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           // Define customer properties here
 *       404:
 *         description: No customers found
 */
router.get('/assignedCustomers/:csaId', getAssignedCustomers);

router.get('/:customerId', getSingleCustomer);

router.delete('/:customerId', deleteCustomer)

export default router;