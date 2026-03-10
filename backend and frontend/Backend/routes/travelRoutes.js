import express from "express";
import {
  addOrUpdateTravel,
  deleteCustomerDoc,
  deleteTravelRecord,
  getAllTravels,
  getTravelsByCustomer,
  updateTravelStatus,
  uploadDocs,
} from "../controllers/travelController.js";

const router = express.Router();

import multer from "multer";
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });


/**
 * @swagger
 * /travels:
 *   post:
 *     summary: Add a new travel record for a customer
 *     description: Creates a travel entry for a customer, including file uploads (hotels & flights PDFs) to Firebase.
 *     tags:
 *       - Travels
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - email
 *               - startingLocation
 *               - destination
 *               - csa
 *             properties:
 *               name:
 *                 type: string
 *                 example: "John Doe"
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "johndoe@example.com"
 *               startingLocation:
 *                 type: string
 *                 example: "New York"
 *               destination:
 *                 type: string
 *                 example: "Los Angeles"
 *               csa:
 *                 type: string
 *                 example: "65a8e3f7bc13c6a42c0e5678"
 *               travelDate:
 *                 type: string
 *                 format: date
 *                 example: "2024-12-31"
 *               hotels:
 *                 type: string
 *                 format: binary
 *                 description: "PDF file for hotel bookings"
 *               flights:
 *                 type: string
 *                 format: binary
 *                 description: "PDF file for flight bookings"
 *               vehicles:
 *                 type: string
 *                 format: binary
 *                 description: "PDF file for vehicle bookings"
 *               tourItineraries:
 *                 type: string
 *                 format: binary
 *                 description: "PDF file for tour itineraries"
 *               transfers:
 *                 type: string
 *                 format: binary
 *                 description: "PDF file for transfer bookings"
 *               cruiseDocs:
 *                 type: string
 *                 format: binary
 *                 description: "PDF file for cruise documents"
 *               otherCSADocs:
 *                 type: string
 *                 format: binary
 *                 description: "Other CSA documents"
 *     responses:
 *       201:
 *         description: Successfully added a new travel record.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Travel added successfully."
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     travelId:
 *                       type: integer
 *                       example: 1001
 *                     customer:
 *                       type: string
 *                       example: "65d8f4a2ab13c54277b12345"
 *                     startingLocation:
 *                       type: string
 *                       example: "New York"
 *                     destination:
 *                       type: string
 *                       example: "Los Angeles"
 *                     travelStatus:
 *                       type: string
 *                       example: "ON_GOING"
 *                     documents:
 *                       type: object
 *                       properties:
 *                         hotels:
 *                           type: string
 *                           example: "https://storage.googleapis.com/your-bucket/travels/hotels-171234567890.pdf"
 *                         flights:
 *                           type: string
 *                           example: "https://storage.googleapis.com/your-bucket/travels/flights-171234567890.pdf"
 *                     createdAt:
 *                       type: string
 *                       format: date-time
 *                       example: "2025-03-02T10:45:32.123Z"
 *       400:
 *         description: Bad Request - Missing required fields
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "email, starting location, destination, and name required"
 *                 success:
 *                   type: boolean
 *                   example: false
 *       500:
 *         description: Internal Server Error
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Customer not updated with travel history."
 *                 success:
 *                   type: boolean
 *                   example: false
 */
router.post(
  "/",
  upload.fields([
    { name: "hotels", maxCount: 5 },
    { name: "flights", maxCount: 5 },
    { name: "vehicles", maxCount: 5 },
    { name: "tourItineraries", maxCount: 5 },
    { name: "transfers", maxCount: 5 },
    { name: "cruiseDocs", maxCount: 5 },
    { name: "otherCSADocs", maxCount: 5 },
  ]),
  addOrUpdateTravel
);
/**
 * @swagger
 * /travels/{customerId}:
 *   get:
 *     summary: Retrieve all travel records for a specific customer
 *     description: Fetches all travel records associated with a given customer ID.
 *     tags:
 *       - Travels
 *     parameters:
 *       - in: path
 *         name: customerId
 *         required: true
 *         schema:
 *           type: string
 *         description: Unique ID of the customer
 *         example: "65d8f4a2ab13c54277b12345"
 *     responses:
 *       200:
 *         description: Successfully fetched all travel records.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Travel history fetched for customer 65d8f4a2ab13c54277b12345"
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     travels:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           travelId:
 *                             type: integer
 *                             example: 1001
 *                           startingLocation:
 *                             type: string
 *                             example: "New York"
 *                           destination:
 *                             type: string
 *                             example: "Los Angeles"
 *                           travelStatus:
 *                             type: string
 *                             enum: ["ON_GOING", "COMPLETED", "CANCELLED"]
 *                             example: "ON_GOING"
 *                           createdAt:
 *                             type: string
 *                             format: date-time
 *                             example: "2025-03-02T10:45:32.123Z"
 *                           updatedAt:
 *                             type: string
 *                             format: date-time
 *                             example: "2025-03-02T12:00:00.123Z"
 *                           documents:
 *                             type: object
 *                             properties:
 *                               hotels:
 *                                 type: string
 *                                 example: "https://storage.googleapis.com/your-bucket/travels/hotels-171234567890.pdf"
 *                               flights:
 *                                 type: string
 *                                 example: "https://storage.googleapis.com/your-bucket/travels/flights-171234567890.pdf"
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
 *       404:
 *         description: No travel records found for the given customer ID
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "No travels found for customer ID 65d8f4a2ab13c54277b12345"
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
router.get("/:customerId", getTravelsByCustomer);
/**
 * @swagger
 * /travels:
 *   get:
 *     summary: Retrieve all travel records
 *     description: Fetches all travel records from the database.
 *     tags:
 *       - Travels
 *     responses:
 *       200:
 *         description: Successfully fetched all travel records.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "All travels fetched."
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     travels:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           travelId:
 *                             type: integer
 *                             example: 1001
 *                           startingLocation:
 *                             type: string
 *                             example: "New York"
 *                           destination:
 *                             type: string
 *                             example: "Los Angeles"
 *                           travelStatus:
 *                             type: string
 *                             enum: ["ON_GOING", "COMPLETED", "CANCELLED"]
 *                             example: "ON_GOING"
 *                           createdAt:
 *                             type: string
 *                             format: date-time
 *                             example: "2025-03-02T10:45:32.123Z"
 *                           updatedAt:
 *                             type: string
 *                             format: date-time
 *                             example: "2025-03-02T12:00:00.123Z"
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
router.get("/", getAllTravels);

/**
 * @swagger
 * /travels/docs:
 *   delete:
 *     summary: Delete a specific document from a travel record
 *     description: Delete a specific document URL from a travel record's otherDocs field and remove the file from Firebase storage.
 *     tags:
 *       - Travels
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - travelId
 *               - field
 *               - url
 *             properties:
 *               travelId:
 *                 type: string
 *                 description: "The travel ID containing the document"
 *                 example: "1"
 *               field:
 *                 type: string
 *                 enum: ["insurance", "vaccinate", "emergency", "destinationInfo"]
 *                 description: "The document field type to delete from"
 *                 example: "insurance"
 *               url:
 *                 type: string
 *                 description: "The specific document URL to delete"
 *                 example: "https://firebase.com/storage/travels/insurance-123456789.pdf"
 *     responses:
 *       200:
 *         description: Document deleted successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "document deleted."
 *                 success:
 *                   type: boolean
 *                   example: true
 *       400:
 *         description: Bad Request - Missing required parameters
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "travel Id, field and url required."
 *                 success:
 *                   type: boolean
 *                   example: false
 *       404:
 *         description: Travel not found
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Travel not found"
 *                 success:
 *                   type: boolean
 *                   example: false
 *       500:
 *         description: Internal Server Error
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
router.delete("/docs", deleteCustomerDoc);

/**
 * @swagger
 * /travels/upload:
 *   post:
 *     summary: Upload documents for a travel record
 *     description: Upload multiple document types (insurance, vaccinate, emergency, destinationInfo) for an existing travel record. Supports both file uploads and keeping existing URLs.
 *     tags:
 *       - Travels
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - travelId
 *             properties:
 *               travelId:
 *                 type: string
 *                 description: "The travel ID to update documents for"
 *                 example: "1"
 *               insurance:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *                 description: "Insurance document files (max 5 files)"
 *               vaccinate:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *                 description: "Vaccination document files (max 5 files)"
 *               emergency:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *                 description: "Emergency document files (max 5 files)"
 *               destinationInfo:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *                 description: "Destination info document files (max 5 files)"
 *     responses:
 *       200:
 *         description: Travel documents updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Travel Updated Successfully."
 *                 success:
 *                   type: boolean
 *                   example: true
 *       400:
 *         description: Bad Request - Travel ID is required
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Travel Id is required."
 *                 success:
 *                   type: boolean
 *                   example: false
 *       404:
 *         description: Travel not found or Internal server error
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Travel not found."
 *                 success:
 *                   type: boolean
 *                   example: false
 *       500:
 *         description: Internal Server Error
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Internal server Error"
 *                 success:
 *                   type: boolean
 *                   example: false
 */
router.post(
  "/upload",
  upload.fields([
    { name: "insurance", maxCount: 5 },
    { name: "vaccinate", maxCount: 5 },
    { name: "emergency", maxCount: 5 },
    { name: "destinationInfo", maxCount: 5 },
  ]),
  uploadDocs
);

router.delete("/:travelId", deleteTravelRecord);
export default router;

router.post("/updateTravel", updateTravelStatus)
