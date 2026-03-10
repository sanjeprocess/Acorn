import rateLimit from 'express-rate-limit';

// General rate limiter (TESTING MODE - HIGH LIMITS)
export const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10000, // TESTING: limit each IP to 10000 requests per windowMs (was 100)
  message: {
    success: false,
    error: {
      message: 'Too many requests from this IP, please try again later'
    }
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// Auth rate limiter (TESTING MODE - HIGH LIMITS)
export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 1000, // TESTING: limit each IP to 1000 requests per windowMs (was 5)
  message: {
    success: false,
    error: {
      message: 'Too many authentication attempts, please try again later'
    }
  },
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: true, // Don't count successful requests
});

// Password reset rate limiter (TESTING MODE - HIGH LIMITS)
export const passwordResetLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 100, // TESTING: limit each IP to 100 password reset attempts per hour (was 3)
  message: {
    success: false,
    error: {
      message: 'Too many password reset attempts, please try again later'
    }
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// File upload rate limiter (TESTING MODE - HIGH LIMITS)
export const uploadLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 1000, // TESTING: limit each IP to 1000 file uploads per windowMs (was 20)
  message: {
    success: false,
    error: {
      message: 'Too many file uploads, please try again later'
    }
  },
  standardHeaders: true,
  legacyHeaders: false,
});
