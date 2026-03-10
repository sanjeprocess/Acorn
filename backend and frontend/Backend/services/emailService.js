import emailjs from '@emailjs/nodejs';
import EMAILJS_CONFIG from '../config/emailjs.config.js';


class EmailService {
  constructor() {
    this.isInitialized = false;
  }

  async initialize() {
    try {
      // Initialize EmailJS with server-side SDK using the correct format
      const initConfig = {
        publicKey: EMAILJS_CONFIG.publicKey,
      };
      
      // Add private key if available (recommended for security)
      if (EMAILJS_CONFIG.privateKey) {
        initConfig.privateKey = EMAILJS_CONFIG.privateKey;
      }
      
      emailjs.init(initConfig);
      this.isInitialized = true;
      console.log('EmailJS service initialized with public key:', EMAILJS_CONFIG.publicKey ? 'SET' : 'MISSING');
    } catch (error) {
      console.error('Failed to initialize EmailJS:', error);
      throw new Error('Email service initialization failed');
    }
  }

  async sendPasswordResetOTP(email, userName, otp) {
    try {
      if (!this.isInitialized) {
        await this.initialize();
      }

      // Validate configuration
      if (!EMAILJS_CONFIG.serviceId || !EMAILJS_CONFIG.publicKey || !EMAILJS_CONFIG.templateId) {
        console.error('EmailJS configuration missing:', {
          serviceId: !!EMAILJS_CONFIG.serviceId,
          publicKey: !!EMAILJS_CONFIG.publicKey,
          templateId: !!EMAILJS_CONFIG.templateId
        });
        throw new Error('EmailJS configuration is incomplete. Please check your environment variables.');
      }

      // Log public key info for debugging
      console.log('Using public key:', EMAILJS_CONFIG.publicKey ? EMAILJS_CONFIG.publicKey.substring(0, 10) + '...' : 'MISSING');

      const templateParams = {
        to_email: email,        // Most common variable name for recipient email
        email: email,           // Alternative variable name
        userName: userName,
        user_name: userName,    // Alternative variable name
        otp: otp,
        fromName: 'ACORN Travels',
        replyTo: 'noreply@acorntravels.com'
      };

      // Send email using EmailJS
      console.log('Sending password reset email:', {
        to: email,
        userName: userName,
        otp: otp,
        serviceId: EMAILJS_CONFIG.serviceId,
        templateId: EMAILJS_CONFIG.templateId
      });

      const result = await emailjs.send(
        EMAILJS_CONFIG.serviceId,
        EMAILJS_CONFIG.templateId,
        templateParams
      );

      console.log('EmailJS result:', result);

      if (result.status === 200) {
        console.log('Password reset email sent successfully to:', email);
        return { success: true, message: 'OTP sent successfully' };
      } else {
        console.error('EmailJS returned non-200 status:', result);
        throw new Error(`EmailJS returned status ${result.status}`);
      }
    } catch (error) {
      console.error('Error sending password reset email:', error);
      console.error('Error details:', {
        message: error.message,
        stack: error.stack,
        config: {
          serviceId: EMAILJS_CONFIG.serviceId,
          templateId: EMAILJS_CONFIG.templateId,
          publicKey: EMAILJS_CONFIG.publicKey ? '***' + EMAILJS_CONFIG.publicKey.slice(-4) : 'undefined'
        }
      });
      throw new Error(`Failed to send password reset email: ${error.message}`);
    }
  }

}

const emailService = new EmailService();
export default emailService;

