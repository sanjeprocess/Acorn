import { verifyAccessToken } from "../utils/jwtToken.js";
import asyncHandler from "express-async-handler";
import { AppError } from "./errorHandler.js";

export const authMiddleWare = asyncHandler(async (req, res, next) => {
  // Extract header
  const authHeader = req.headers["authorization"];

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    throw new AppError("Authorization header missing or invalid format", 401);
  }

  // Extract token
  const token = authHeader.split(" ")[1];

  if (!token) {
    throw new AppError("Access token is required", 401);
  }

  try {
    const decoded = await verifyAccessToken(token);
    req.userId = decoded.userId;
    req.userType = decoded.type;
    next();
  } catch (err) {
    // Return 401 for expired or invalid tokens (standard HTTP status)
    // Frontend will handle token refresh automatically
    // Preserve the original error name if it's a JWT error
    if (err.name === 'TokenExpiredError' || err.name === 'JsonWebTokenError') {
      throw new AppError(`Token verification failed: ${err.message}`, 401);
    }
    throw new AppError(`Token verification failed: ${err.message}`, 401);
  }
});
