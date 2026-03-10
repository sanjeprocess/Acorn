import * as dotenv from 'dotenv';

dotenv.config();

/**
 * Get allowed origins from environment variable
 * Format: Comma-separated list of URLs
 * Example: ALLOWED_ORIGINS=http://localhost:3039,https://acorn-portal.netlify.app
 * 
 * Falls back to default development origins if not set
 */
const getAllowedOrigins = () => {
  const envOrigins = process.env.ALLOWED_ORIGINS;
  
  if (envOrigins) {
    // Split by comma, trim whitespace, and strip surrounding quotes
    return envOrigins
      .split(',')
      .map(origin => origin.trim().replace(/^["']|["']$/g, ''))
      .filter(origin => origin.length > 0);
  }
  throw new Error('ALLOWED_ORIGINS is not set');
};

export const allowedOrigins = getAllowedOrigins();
  