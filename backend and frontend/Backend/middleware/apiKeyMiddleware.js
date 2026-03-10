import asyncHandler from 'express-async-handler';

/**
 * Middleware to validate API key for external application requests
 * This ensures only authorized external applications can create CSAs and customers
 */
export const validateApiKey = asyncHandler(async (req, res, next) => {
  // Extract API key from header
  const apiKey = req.headers['x-api-key'];

  if (!apiKey) {
    res.status(401);
    throw new Error('API key is required. Please provide X-API-Key header');
  }

  // Get the valid API key from environment variable
  // Note: dotenv.config() should be called in index.js before this middleware is used
  const validApiKey = process.env.EXTERNAL_APP_API_KEY;

  if (!validApiKey) {
    console.error('❌ EXTERNAL_APP_API_KEY is not set in environment variables');
    res.status(500);
    throw new Error('API key validation is not configured on server. Please set EXTERNAL_APP_API_KEY environment variable.');
  }

  // Validate API key
  if (apiKey !== validApiKey) {
    res.status(403);
    throw new Error('Invalid API key');
  }

  // API key is valid, proceed to next middleware/controller
  next();
});

/**
 * Middleware to validate API key or JWT token
 * Allows both external API key and regular JWT authentication
 */
export const validateApiKeyOrAuth = asyncHandler(async (req, res, next) => {
  // Check for API key first
  const apiKey = req.headers['x-api-key'];
  
  if (apiKey) {
    const validApiKey = process.env.EXTERNAL_APP_API_KEY;
    
    if (!validApiKey) {
      console.error('❌ EXTERNAL_APP_API_KEY is not set in environment variables');
      // Fall through to JWT token validation if API key is not configured
    } else if (apiKey === validApiKey) {
      req.authType = 'apiKey';
      return next();
    }
  }

  // If no valid API key, check for JWT token
  const authHeader = req.headers['authorization'];
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    res.status(401);
    throw new Error('Authentication required: Provide either X-API-Key or Bearer token');
  }

  // Token validation will be handled by authMiddleware
  req.authType = 'jwt';
  next();
});

