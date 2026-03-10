import express from 'express';
import { addNewIncident, getAllIncidents, getIncidentByCustomer } from '../controllers/incidentReportController.js';

import multer from "multer";
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

const router = express.Router();

/**
 * @swagger
 * /incidentReport:
 *   post:
 *     summary: Report a new incident
 *     description: Creates a new incident report for a customer, including file uploads (incident photos) to Firebase.
 *     tags:
 *       - Incidents
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - customer
 *               - title
 *               - notes
 *             properties:
 *               customer:
 *                 type: string
 *                 example: "65d8f4a2ab13c54277b12345"
 *                 description: "Customer ID"
 *               title:
 *                 type: string
 *                 example: "Lost Baggage"
 *               notes:
 *                 type: string
 *                 example: "Customer reported missing baggage at the airport."
 *               incidentLocation:
 *                 type: object
 *                 properties:
 *                   longitude:
 *                     type: number
 *                     example: 79.8612
 *                   latitude:
 *                     type: number
 *                     example: 6.9271
 *               incidentPhotos:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *                   description: "Images related to the incident"
 *     responses:
 *       201:
 *         description: Incident report created successfully.
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
 *                   example: "Incident report created successfully"
 *                 incident:
 *                   type: object
 *                   properties:
 *                     incidentId:
 *                       type: integer
 *                       example: 101
 *                     customer:
 *                       type: string
 *                       example: "65d8f4a2ab13c54277b12345"
 *                     title:
 *                       type: string
 *                       example: "Lost Baggage"
 *                     notes:
 *                       type: string
 *                       example: "Customer reported missing baggage at the airport."
 *                     incidentDate:
 *                       type: string
 *                       format: date
 *                       example: "2025-03-02"
 *                     incidentTime:
 *                       type: string
 *                       format: time
 *                       example: "14:30"
 *                     incidentLocation:
 *                       type: object
 *                       properties:
 *                         longitude:
 *                           type: number
 *                           example: 79.8612
 *                         latitude:
 *                           type: number
 *                           example: 6.9271
 *                     incidentPhotos:
 *                       type: array
 *                       items:
 *                         type: string
 *                         example: "https://storage.googleapis.com/bucket/incidents/101/0.jpg"
 *                     incidentStatus:
 *                       type: string
 *                       example: "Pending"
 *       400:
 *         description: Bad Request - Missing required fields.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: false
 *                 message:
 *                   type: string
 *                   example: "Missing required fields"
 *       500:
 *         description: Internal Server Error - Failed to update incident report or customer record.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: false
 *                 message:
 *                   type: string
 *                   example: "Failed to update customer with incident report"
 */
router.post('/', upload.array("incidentPhotos", 5), addNewIncident);

/**
 * @swagger
 * /incidentReport:
 *   get:
 *     summary: Retrieve all incident reports
 *     description: Fetches all incident reports from the database, including associated customer details.
 *     tags:
 *       - Incidents
 *     responses:
 *       200:
 *         description: Successfully retrieved all incident reports.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "All incidents fetched."
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     incidents:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           incidentId:
 *                             type: integer
 *                             example: 1
 *                           title:
 *                             type: string
 *                             example: "Lost Baggage"
 *                           incidentPhotos:
 *                             type: array
 *                             items:
 *                               type: string
 *                               example: "https://storage.googleapis.com/your-bucket/incidents/171234567890-file1.jpg"
 *                           notes:
 *                             type: string
 *                             example: "An accident occurred at the main office."
 *                           incidentDate:
 *                             type: string
 *                             format: date
 *                             example: "2025-03-02"
 *                           incidentLocation:
 *                             type: object
 *                             properties:
 *                               longitude:
 *                                 type: number
 *                                 example: 79.8612
 *                               latitude:
 *                                 type: number
 *                                 example: 6.9271
 *                           incidentTime:
 *                             type: string
 *                             format: time
 *                             example: "14:30"
 *                           incidentStatus:
 *                             type: string
 *                             enum: ["Pending", "Resolved", "Closed"]
 *                             example: "Pending"
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
 *                                 example: "John Smith"
 *                                 description: "CSA name (not ID)"
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
router.get('/', getAllIncidents);

/**
 * @swagger
 * /incidentReport/{customerId}:
 *   get:
 *     summary: Get all incidents for a customer
 *     description: Retrieves all incidents associated with a given customer ID.
 *     tags:
 *       - Incidents
 *     parameters:
 *       - in: path
 *         name: customerId
 *         required: true
 *         schema:
 *           type: string
 *         example: "65d8f4a2ab13c54277b12345"
 *         description: "Customer ID"
 *     responses:
 *       200:
 *         description: List of incidents fetched successfully.
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
 *                   example: "Incidents fetched for customer 65d8f4a2ab13c54277b12345"
 *                 data:
 *                   type: object
 *                   properties:
 *                     incidents:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           incidentId:
 *                             type: integer
 *                             example: 101
 *                           title:
 *                             type: string
 *                             example: "Lost Baggage"
 *                           notes:
 *                             type: string
 *                             example: "Customer reported missing baggage at the airport."
 *                           incidentDate:
 *                             type: string
 *                             format: date
 *                             example: "2025-03-02"
 *                           incidentTime:
 *                             type: string
 *                             format: time
 *                             example: "14:30"
 *                           incidentLocation:
 *                             type: object
 *                             properties:
 *                               longitude:
 *                                 type: number
 *                                 example: 79.8612
 *                               latitude:
 *                                 type: number
 *                                 example: 6.9271
 *                           incidentPhotos:
 *                             type: array
 *                             items:
 *                               type: string
 *                               example: "https://storage.googleapis.com/bucket/incidents/101/0.jpg"
 *                           incidentStatus:
 *                             type: string
 *                             example: "Pending"
 *       404:
 *         description: No incidents found for the given customer ID.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: false
 *                 message:
 *                   type: string
 *                   example: "No incidents found for customer 65d8f4a2ab13c54277b12345"
 */
router.get('/:customerId', getIncidentByCustomer)

export default router;