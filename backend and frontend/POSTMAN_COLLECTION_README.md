# ACORN Travels API - Postman Collection

This Postman collection contains all the API endpoints for the ACORN Travels Mobile App Backend.

## 📦 Files Included

1. **ACORN_Travels_API.postman_collection.json** - Complete Postman collection with all endpoints
2. **ACORN_Travels_API.postman_environment.json** - Environment variables file

## 🚀 Quick Start

### Step 1: Import Collection and Environment

1. Open Postman
2. Click **Import** button (top left)
3. Import both files:
   - `ACORN_Travels_API.postman_collection.json`
   - `ACORN_Travels_API.postman_environment.json`
4. Select the environment "ACORN Travels API - Environment" from the dropdown (top right)

### Step 2: Configure Environment Variables

1. Click on the environment name in the top right
2. Click **Edit** (or click the eye icon to view variables)
3. Update the following variables:

   - **baseUrl**: Your API base URL
     - Local: `http://localhost:8000`
     - Production: `https://your-production-url.com`
   
   - **apiKey**: Your external app API key (for SSO endpoints)
     - Get this from your backend environment variable `EXTERNAL_APP_API_KEY`

### Step 3: Test Authentication Flow

1. **Register or Login as CSA**:
   - Use `Auth > Register CSA` or `Auth > Login CSA`
   - The access token will be automatically saved to `csaAccessToken` variable
   - The user ID will be saved to `csaUserId` variable

2. **Login as Customer**:
   - Use `Auth > Login Customer`
   - The access token will be automatically saved to `customerAccessToken` variable

## 🔐 Authentication

### Automatic Token Management

The collection includes **automatic token extraction** scripts that:
- Extract `accessToken` and `refreshToken` from login/register responses
- Save them to environment variables
- Automatically use them in subsequent requests via `Bearer {{csaAccessToken}}` or `Bearer {{customerAccessToken}}`

### Protected Endpoints

Most endpoints require authentication. The collection automatically includes the `Authorization` header with the appropriate token:
- **CSA endpoints**: Use `{{csaAccessToken}}`
- **Customer endpoints**: Use `{{customerAccessToken}}`

### Token Refresh

If your token expires:
1. Use `Auth > Refresh Token` endpoint
2. The new tokens will be automatically saved

## 📋 Endpoint Categories

### 1. Health
- Health Check
- Readiness Check
- Liveness Check

### 2. Auth
- Register CSA
- Login CSA
- Login Customer
- Refresh Token
- Check Customer Password
- Update Customer Password

### 3. Forgot Password
- Send OTP
- Verify OTP
- Reset Password
- Resend OTP

### 4. SSO (Single Sign-On)
- Validate Session and Login
- Create CSA from External (requires API key)
- Check User Exists
- Logout SSO
- Get SSO Session Stats
- Cleanup Expired Sessions

### 5. CSA
- Create CSA
- Get All CSAs
- Get Assigned Customers

### 6. Customer
- Get All Customers
- Create Customer
- Get Single Customer
- Get Assigned Customers by CSA
- Delete Customer

### 7. Travels
- Get All Travels
- Get Travels by Customer
- Add or Update Travel (supports file uploads)
- Upload Travel Documents
- Delete Travel Document
- Update Travel Status
- Delete Travel Record

### 8. Feedback
- Get All Feedbacks
- Add New Feedback
- Get Feedback by Customer
- Get Feedback by Travel ID

### 9. Incident Reports
- Get All Incidents
- Add New Incident (supports file uploads)
- Get Incidents by Customer

### 10. Notifications
- Get All Notifications
- Add New Notification
- Update Notification

> **Note**: Notification endpoints are included in the collection, but the controller implementation may not be complete. These endpoints may return errors until the backend implementation is finished.

## 📝 Request Examples

### Example 1: Create a Customer

1. First, login as CSA to get the access token
2. Use `Customer > Create Customer`
3. The `customerId` will be automatically saved for use in other requests

### Example 2: Add Travel with Documents

1. Ensure you have a `customerId` in your environment
2. Use `Travels > Add or Update Travel`
3. Fill in the form data fields
4. Optionally attach PDF files for hotels, flights, etc.

### Example 3: SSO Flow

1. Use `SSO > Validate Session and Login` with a valid session token
2. The SSO tokens will be automatically saved
3. Use other endpoints with the SSO token

## 🔧 Environment Variables

The collection uses the following environment variables:

| Variable | Description | Auto-populated |
|----------|-------------|----------------|
| `baseUrl` | API base URL | ❌ Manual |
| `apiKey` | External app API key | ❌ Manual |
| `csaAccessToken` | CSA JWT access token | ✅ Auto |
| `csaRefreshToken` | CSA refresh token | ✅ Auto |
| `csaUserId` | CSA user ID | ✅ Auto |
| `csaId` | CSA ID | ❌ Manual |
| `customerAccessToken` | Customer JWT access token | ✅ Auto |
| `customerRefreshToken` | Customer refresh token | ✅ Auto |
| `customerUserId` | Customer user ID | ✅ Auto |
| `customerId` | Customer ID | ✅ Auto (from create) |
| `travelId` | Travel ID | ✅ Auto (from create) |
| `ssoAccessToken` | SSO access token | ✅ Auto |
| `ssoRefreshToken` | SSO refresh token | ✅ Auto |
| `notificationId` | Notification ID | ❌ Manual |

## 🧪 Testing Workflow

### Recommended Testing Order

1. **Health Check** - Verify API is running
2. **Auth > Register CSA** - Create a test CSA account
3. **Auth > Login CSA** - Login and get token
4. **CSA > Get All CSAs** - Verify CSA list
5. **Customer > Create Customer** - Create a test customer
6. **Travels > Add or Update Travel** - Create a travel record
7. **Feedback > Add New Feedback** - Add feedback for the travel
8. **Incident Reports > Add New Incident** - Report an incident

## 📤 File Uploads

Some endpoints support file uploads:
- **Travels > Add or Update Travel**: Upload PDFs for hotels, flights, vehicles, etc.
- **Travels > Upload Travel Documents**: Upload insurance, vaccination, emergency docs
- **Incident Reports > Add New Incident**: Upload incident photos

In Postman:
1. Select the request
2. Go to the **Body** tab
3. Select **form-data**
4. For file fields, change type from "Text" to "File"
5. Click "Select Files" to upload

## 🔄 Token Refresh

If you get a 401/403 error:
1. Use `Auth > Refresh Token` with your refresh token
2. New tokens will be automatically saved
3. Retry your request

## ⚠️ Important Notes

1. **API Key for SSO**: The `SSO > Create CSA from External` endpoint requires an API key. Set this in your environment variables.

2. **File Uploads**: When testing file upload endpoints, make sure to:
   - Use `form-data` body type
   - Select actual files (PDFs for documents, images for photos)
   - Note: Postman may show file fields as empty in the collection, but you can add files when making the request

3. **Dummy Data**: All request bodies contain dummy/example data. Replace with actual values for your testing.

4. **Base URL**: Update the `baseUrl` variable based on your environment:
   - Development: `http://localhost:8000`
   - Staging: `https://staging-api.example.com`
   - Production: `https://api.example.com`

5. **Rate Limiting**: The API has rate limiting. If you hit rate limits, wait a few minutes before retrying.

## 🐛 Troubleshooting

### Token Not Saving
- Check that the response has `data.accessToken` in the JSON
- Verify the test script is running (check Postman console)

### 401 Unauthorized
- Verify you've logged in and the token is saved
- Check if the token has expired (use Refresh Token)
- Ensure the Authorization header format is correct: `Bearer {{token}}`

### 400 Bad Request
- Check required fields are present
- Verify data types match (e.g., email format, date format)
- Check file uploads are in correct format

### 404 Not Found
- Verify the endpoint URL is correct
- Check if the resource ID exists (customerId, travelId, etc.)

## 📚 Additional Resources

- Swagger Documentation: `{{baseUrl}}/api/v1/api-docs`
- Backend Repository: Check the routes files for detailed endpoint documentation

## 🔐 Security Notes

- Never commit environment files with real tokens/API keys
- Use different environments for dev/staging/production
- Rotate API keys regularly
- Tokens are stored as secrets in Postman (marked with `"type": "secret"`)

---

**Happy Testing! 🚀**

