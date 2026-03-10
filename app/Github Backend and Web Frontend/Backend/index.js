// Initialize dotenv FIRST - before any other imports that might need environment variables
import dotenv from "dotenv";
dotenv.config();

import express from "express";
import serverless from "serverless-http";
import helmet from "helmet";
import connectDB from "./database/dbConnection.js";
import { corsOptions } from "./config/cors/corsOptions.js";
import morgan from "morgan";
import cors from "cors";
import bodyParser from "body-parser";
import { errorHandler, notFound } from "./middleware/errorHandler.js";
import { generalLimiter, authLimiter } from "./middleware/rateLimiter.js";
import { requestLogger } from "./middleware/logger.js";
import { requestIdMiddleware } from "./middleware/requestId.js";
import swaggerUi from "swagger-ui-express";
import swaggerJsdoc from "swagger-jsdoc";
import { options } from "./swagger/swaggerOptions.js";
import { authMiddleWare } from "./middleware/authMiddleWare.js";
import authRouter from "./routes/authRoutes.js";
import csaRouter from "./routes/csaRoutes.js";
import customerRouter from "./routes/customerRoutes.js";
import feedbackRouter from "./routes/feedbackRoutes.js";
import incidentRouter from "./routes/incidentReportRoutes.js";
import travelRouter from "./routes/travelRoutes.js";
import healthRouter from "./routes/healthRoutes.js";
import forgotPasswordRouter from "./routes/forgotPasswordRoutes.js";
import ssoRouter from "./routes/ssoRoutes.js";

// Initialize app
const app = express();

// Connect DB
connectDB();

// Security middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  crossOriginEmbedderPolicy: false
}));

// Rate limiting
app.use(generalLimiter);

// Request ID middleware
app.use(requestIdMiddleware);

// Request logging
app.use(requestLogger);

// Middleware
app.use(morgan("dev"));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(cors(corsOptions));
app.use(bodyParser.urlencoded({ extended: false }));

// Routes
app.get("/", (req, res) => {
  res.status(200).send("<h1>ACORN Travels API Server</h1>");
});

// Swagger docs (no auth required)
const specs = swaggerJsdoc(options);
app.use("/api/v1/api-docs", swaggerUi.serve, swaggerUi.setup(specs));

// Health check routes (no auth required)
app.use("/api/v1/health", healthRouter);

// Apply auth rate limiting to auth routes
app.use("/api/v1/auth", authLimiter, authRouter);

// Forgot password routes (no auth required, but with rate limiting)
app.use("/api/v1/forgot-password", authLimiter, forgotPasswordRouter);

// SSO routes (no auth required for session validation, but with rate limiting)
app.use("/api/v1/sso", authLimiter, ssoRouter);

// Protected routes
app.use(authMiddleWare); // Enable authentication for protected routes
app.use("/api/v1/csa", csaRouter);
app.use("/api/v1/customer", customerRouter);
app.use("/api/v1/incidentReport", incidentRouter);
app.use("/api/v1/feedback", feedbackRouter);
app.use("/api/v1/travels", travelRouter);

// 404 handler
app.use(notFound);

// Error handler
app.use(errorHandler);

// Export for serverless (AWS Lambda)
const handleRequest = serverless(app);

export const handler = async (event, context) => {
    return await handleRequest(event, context)
}

// Render deployment configuration
const port = process.env.PORT || 8000;

// Start server for Render deployment
app.listen(port, '0.0.0.0', () => {
    console.log(`🚀 Server running on port ${port}`);
    console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`📊 Health check: http://localhost:${port}/api/v1/health`);
});

