import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

// EmailJS Configuration using environment variables
const EMAILJS_CONFIG = {
  // Your EmailJS service ID (from .env file)
  serviceId: process.env.EMAILJS_SERVICE_ID,
  
  // Your EmailJS public key (from .env file)
  publicKey: process.env.EMAILJS_PUBLIC_KEY,
  
  // Your EmailJS private key (optional, from .env file)
  privateKey: process.env.EMAILJS_PRIVATE_KEY,
  
  // Template ID for password reset (from .env file)
  templateId: process.env.EMAILJS_TEMPLATE_ID
};

export default EMAILJS_CONFIG;
