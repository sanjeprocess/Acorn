import asyncHandler from "express-async-handler";
import mongoose from "mongoose";

export const healthCheck = asyncHandler(async (req, res) => {
  const healthStatus = {
    status: "OK",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
    version: process.env.npm_package_version || '1.0.0',
    services: {
      database: mongoose.connection.readyState === 1 ? "connected" : "disconnected",
      memory: {
        used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024) + " MB",
        total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024) + " MB"
      }
    }
  };

  res.status(200).json({
    success: true,
    data: healthStatus
  });
});

export const readinessCheck = asyncHandler(async (req, res) => {
  const isReady = mongoose.connection.readyState === 1;
  
  if (isReady) {
    res.status(200).json({
      success: true,
      message: "Service is ready"
    });
  } else {
    res.status(503).json({
      success: false,
      message: "Service is not ready"
    });
  }
});

export const livenessCheck = asyncHandler(async (req, res) => {
  res.status(200).json({
    success: true,
    message: "Service is alive"
  });
});
