
export const errorConstants = {
  VALIDATION_ERROR: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  SERVER_ERROR: 500,
};

// Custom Error Class
export class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}

// Not Found Handler
export const notFound = (req, res, next) => {
  const error = new AppError(`Route ${req.originalUrl} not found`, 404);
  next(error);
};

// Error Handler
export const errorHandler = (err, req, res, next) => {
  let error = err;

  // Log the error using Winston
  import('./logger.js').then(({ logError }) => {
    logError(err, req);
  });

  // If error is already an AppError, use it directly
  if (err instanceof AppError) {
    error = err;
  }
  // Mongoose bad ObjectId
  else if (err.name === 'CastError') {
    const message = 'Resource not found';
    error = new AppError(message, 404);
  }
  // Mongoose duplicate key
  else if (err.code === 11000) {
    const message = 'Duplicate field value entered';
    error = new AppError(message, 400);
  }
  // Mongoose validation error
  else if (err.name === 'ValidationError') {
    const message = Object.values(err.errors).map(val => val.message).join(', ');
    error = new AppError(message, 400);
  }
  // JWT errors - check these before wrapping in AppError
  else if (err.name === 'JsonWebTokenError') {
    const message = 'Invalid token';
    error = new AppError(message, 401);
  }
  else if (err.name === 'TokenExpiredError') {
    const message = 'Token expired';
    error = new AppError(message, 401);
  }
  // If error has statusCode property, preserve it
  else if (err.statusCode) {
    error = new AppError(err.message || 'An error occurred', err.statusCode);
  }
  // Default to 500 for unknown errors
  else {
    error = new AppError(err.message || 'Internal Server Error', 500);
  }

  const status = error.statusCode || 500;
  const message = error.message || 'Internal Server Error';

  res.status(status).json({
    success: false,
    error: {
      message,
      ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    }
  });
};
