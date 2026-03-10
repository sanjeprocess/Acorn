# EmailJS Setup Guide for ACORN Travels

## Overview
This guide will help you configure EmailJS for sending password reset OTPs and email verification in your ACORN Travels application.

## Prerequisites
- EmailJS account (sign up at https://www.emailjs.com/)
- Email service provider (Gmail, Outlook, etc.)

## Step 1: EmailJS Account Setup

1. **Create EmailJS Account**
   - Go to https://www.emailjs.com/
   - Sign up for a free account
   - Verify your email address

2. **Add Email Service**
   - In your EmailJS dashboard, go to "Email Services"
   - Click "Add New Service"
   - Choose your email provider (Gmail, Outlook, etc.)
   - Follow the setup instructions for your provider
   - Note down your **Service ID**

## Step 2: Create Email Template

1. **Password Reset Template**
   - Go to "Email Templates" in your EmailJS dashboard
   - Click "Create New Template" or use your existing template
   - Make sure your template uses these variables:
     - `{{user_name}}` - User's name
     - `{{otp}}` - The 6-digit OTP code
     - `{{to_email}}` - Recipient email address
     - `{{from_name}}` - Sender name
     - `{{reply_to}}` - Reply-to email address

2. **Note down your Template ID** - You'll need this for the configuration

## Step 3: Get Your Public Key

1. Go to "Account" in your EmailJS dashboard
2. Find your **Public Key** (also called User ID)
3. Note it down

## Step 4: Update Configuration Files

### Backend Configuration Only
The configuration now uses environment variables. Create or update your `Backend/.env` file:

```env
EMAILJS_SERVICE_ID=your_actual_service_id
EMAILJS_PUBLIC_KEY=your_actual_public_key
EMAILJS_TEMPLATE_ID=your_actual_template_id
```

The `Backend/config/emailjs.config.js` file will automatically load these values from your .env file.

**Note:** Only the backend handles email sending for security reasons. The frontend does not send emails directly.

## Step 5: Template Variables

Make sure your EmailJS templates use these variables:
- `{{user_name}}` - User's name
- `{{otp}}` - The OTP code
- `{{to_email}}` - Recipient email
- `{{from_name}}` - Sender name
- `{{reply_to}}` - Reply-to email

## Step 6: Test Your Setup

1. **Backend Test**
   ```bash
   cd Backend
   npm start
   ```

2. **Frontend Test**
   ```bash
   cd Frontend
   npm run dev
   ```

3. **Test Password Reset**
   - Go to the forgot password page
   - Enter a valid email address
   - The frontend will call the backend API
   - The backend will send the OTP email via EmailJS
   - Check if you receive the OTP email

## Troubleshooting

### Common Issues:

1. **"Service not found" error**
   - Check your Service ID is correct
   - Ensure the service is active in EmailJS dashboard

2. **"Template not found" error**
   - Check your Template ID is correct
   - Ensure the template is published

3. **"Invalid public key" error**
   - Check your Public Key is correct
   - Ensure your account is verified

4. **Emails not being sent**
   - Check your email service provider settings
   - Verify your email service is properly connected
   - Check EmailJS dashboard for error logs

### EmailJS Dashboard
- Go to your EmailJS dashboard to monitor email sending
- Check the "Activity" section for delivery status
- Review any error messages

## Security Notes

1. **Never commit your actual credentials to version control**
2. **Use environment variables for production**
3. **Regularly rotate your API keys**
4. **Monitor your EmailJS usage to avoid rate limits**

## Environment Variables (Recommended for Production)

Create `.env` file for the backend only:

### Backend/.env
```
EMAILJS_SERVICE_ID=your_service_id
EMAILJS_PUBLIC_KEY=your_public_key
EMAILJS_TEMPLATE_ID=your_template_id
```

Then update your backend config file to use these environment variables.

## Support

If you encounter issues:
1. Check EmailJS documentation: https://www.emailjs.com/docs/
2. Review EmailJS dashboard for error logs
3. Test with EmailJS's built-in testing tools
4. Contact EmailJS support if needed

---

**Next Steps:**
1. Replace the placeholder values in the config files with your actual EmailJS credentials
2. Test the email functionality
3. Deploy and monitor email delivery
