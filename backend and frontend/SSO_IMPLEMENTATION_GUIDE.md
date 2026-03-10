# SSO (Single Sign-On) Implementation Guide

## Overview

This document describes the SSO implementation that allows users from an external client portal to seamlessly authenticate into the ACORN Travels application without requiring separate login credentials.

## Architecture

### Flow Diagram

```
External Portal → ACORN Frontend → ACORN Backend → External Portal API
                       ↓                  ↓
                  User State          Session Validation
                       ↓                  ↓
                Sign-up (First Time) ← Access Token
                       ↓
                  Landing Page
```

### Components

#### Backend Components

1. **External Session Service** (`Backend/services/externalSessionService.js`)
   - Handles API communication with external portal
   - Validates session tokens
   - Notifies external portal of successful logins (optional)

2. **SSO Controller** (`Backend/controllers/ssoController.js`)
   - `validateSessionAndLogin`: Validates external session and creates JWT tokens
   - `createCSAFromExternal`: Allows external app to create CSAs with customers
   - `checkUserExists`: Checks if user exists in the system

3. **API Key Middleware** (`Backend/middleware/apiKeyMiddleware.js`)
   - Validates API keys from external applications
   - Protects sensitive endpoints

4. **SSO Routes** (`Backend/routes/ssoRoutes.js`)
   - Public endpoint: `/api/v1/sso/validate-session`
   - Protected endpoint: `/api/v1/sso/create-csa` (requires API key)
   - Public endpoint: `/api/v1/sso/check-user`

#### Frontend Components

1. **SSO API Module** (`Frontend/src/backend/api/ssoApi.ts`)
   - API functions for session validation
   - URL parameter parsing utilities

2. **SSO Login View** (`Frontend/src/sections/auth/sso-login-view.tsx`)
   - Handles URL parameters (userId, sessionToken)
   - Validates session with backend
   - Routes users based on registration status

3. **Enhanced Sign-up View** (`Frontend/src/sections/auth/sign-up-view.tsx`)
   - Supports both regular CSA registration and SSO user completion
   - Pre-fills data for SSO users
   - Allows password setting for first-time SSO users

## User Flows

### Flow 1: Existing User Login via SSO

1. User clicks link in external portal: `https://acorn-travels.com/sso-login?userId=123&sessionToken=abc123`
2. Frontend parses URL parameters
3. Frontend calls `/api/v1/sso/validate-session`
4. Backend validates session with external API
5. Backend checks if user exists and has password
6. Backend generates JWT tokens
7. User is redirected to `/secured/user` (landing page)

### Flow 2: First-Time User Login via SSO

1. User clicks link in external portal (same as above)
2. Frontend parses URL parameters
3. Frontend calls `/api/v1/sso/validate-session`
4. Backend validates session with external API
5. Backend finds user but no password set (first login)
6. Backend generates JWT tokens and sets `isFirstTimeLogin: true`
7. User is redirected to `/sign-up` with pre-filled data
8. User sets password and mobile number
9. User is redirected to `/secured/user`

### Flow 3: External App Creates CSA with Customers

1. External application calls `/api/v1/sso/create-csa` with API key
2. Backend validates API key
3. Backend creates/updates CSA account
4. Backend creates customer accounts linked to CSA
5. Backend returns summary of created/existing/failed customers
6. Customers can now login via SSO (Flow 2)

## API Endpoints

### 1. Validate Session (Public)

**Endpoint:** `POST /api/v1/sso/validate-session`

**Request Body:**
```json
{
  "userId": "EXT123456",
  "sessionToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (Success - Existing User):**
```json
{
  "message": "SSO login successful.",
  "success": true,
  "data": {
    "customer": {
      "customerId": 1,
      "name": "John Doe",
      "email": "john.doe@example.com",
      "csa": {
        "name": "Jane Smith",
        "email": "jane.smith@acorntravels.com",
        "mobile": "+1234567890"
      }
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI...",
    "isFirstTimeLogin": false,
    "externalUserId": "EXT123456"
  }
}
```

**Response (Success - First Time User):**
```json
{
  "message": "Session validated. Please complete your registration.",
  "success": true,
  "data": {
    "customer": {
      "customerId": 1,
      "name": "John Doe",
      "email": "john.doe@example.com",
      "csa": null
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI...",
    "isFirstTimeLogin": true,
    "externalUserId": "EXT123456"
  }
}
```

**Error Responses:**
- `400`: Missing userId or sessionToken
- `401`: Invalid or expired session
- `404`: User not found in system
- `500`: Server error

### 2. Create CSA from External App (Protected - API Key)

**Endpoint:** `POST /api/v1/sso/create-csa`

**Headers:**
```
X-API-Key: your-api-key-here
Content-Type: application/json
```

**Request Body:**
```json
{
  "csaName": "Jane Smith",
  "csaEmail": "jane.smith@acorntravels.com",
  "csaMobile": "+1234567890",
  "customers": [
    {
      "name": "John Doe",
      "email": "john.doe@example.com"
    },
    {
      "name": "Jane Doe",
      "email": "jane.doe@example.com"
    }
  ]
}
```

**Response:**
```json
{
  "message": "CSA and customer creation process completed",
  "success": true,
  "data": {
    "csa": {
      "csaId": 1,
      "name": "Jane Smith",
      "email": "jane.smith@acorntravels.com",
      "mobile": "+1234567890",
      "isNewCSA": true
    },
    "createdCustomers": [
      {
        "customerId": 1,
        "name": "John Doe",
        "email": "john.doe@example.com"
      }
    ],
    "existingCustomers": [
      {
        "email": "jane.doe@example.com",
        "customerId": 2,
        "message": "Customer already exists"
      }
    ],
    "failedCustomers": [],
    "summary": {
      "totalProcessed": 2,
      "created": 1,
      "alreadyExisting": 1,
      "failed": 0
    }
  }
}
```

**Error Responses:**
- `400`: Missing required fields or invalid data
- `401`: Missing API key
- `403`: Invalid API key
- `500`: Server error during creation

### 3. Check User Exists (Public)

**Endpoint:** `GET /api/v1/sso/check-user?email=user@example.com`

**Response:**
```json
{
  "message": "User check completed",
  "success": true,
  "data": {
    "exists": true,
    "needsRegistration": false,
    "customerId": 1,
    "name": "John Doe",
    "email": "john.doe@example.com"
  }
}
```

## Environment Variables

### Backend (.env)

Add the following environment variables to your `Backend/.env` file:

```bash
# SSO and External API Configuration
# URL of the external client portal API for session validation
EXTERNAL_API_URL=https://external-portal.example.com

# API key for authenticating requests TO external portal
EXTERNAL_API_KEY=your-external-api-key-here

# API key that external portal uses to authenticate requests TO this API
EXTERNAL_APP_API_KEY=your-external-app-api-key-here
```

### Frontend

No additional frontend environment variables are required. The frontend uses the existing `VITE_API_URL`.

## External Portal Integration Requirements

### 1. Session Validation Endpoint

The external portal must provide an endpoint that ACORN Travels backend can call to validate sessions:

**Endpoint:** `POST {EXTERNAL_API_URL}/api/validate-session`

**Headers:**
```
Content-Type: application/json
X-API-Key: {EXTERNAL_API_KEY}
```

**Request Body:**
```json
{
  "userId": "string",
  "sessionToken": "string"
}
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "userId": "123",
    "email": "user@example.com",
    "name": "John Doe",
    "isValid": true
  }
}
```

### 2. Login Link Format

The external portal should generate links in the following format:

```
https://acorn-travels.com/sso-login?userId={userId}&sessionToken={sessionToken}
```

**Parameters:**
- `userId`: The user's ID in the external system
- `sessionToken`: A valid session token that can be validated by the external portal's API

## Security Considerations

1. **Session Token Validation**: Always validate session tokens with the external portal before granting access
2. **API Key Protection**: Store API keys securely in environment variables, never in code
3. **HTTPS Only**: All SSO communications should occur over HTTPS in production
4. **Token Expiration**: Session tokens should have reasonable expiration times
5. **Rate Limiting**: SSO endpoints are protected by rate limiting middleware
6. **Password Requirements**: First-time users must set passwords with minimum 6 characters

## Testing the Implementation

### 1. Test Session Validation

```bash
curl -X POST http://localhost:8000/api/v1/sso/validate-session \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "TEST123",
    "sessionToken": "test-token-here"
  }'
```

### 2. Test CSA Creation

```bash
curl -X POST http://localhost:8000/api/v1/sso/create-csa \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key-here" \
  -d '{
    "csaName": "Test CSA",
    "csaEmail": "test.csa@acorntravels.com",
    "csaMobile": "+1234567890",
    "customers": [
      {
        "name": "Test Customer",
        "email": "test.customer@example.com"
      }
    ]
  }'
```

### 3. Test Frontend SSO Login

Navigate to:
```
http://localhost:5173/sso-login?userId=TEST123&sessionToken=test-token-here
```

## Troubleshooting

### Issue: "Invalid session or session expired"

**Cause:** The external portal API rejected the session validation request

**Solutions:**
1. Check that `EXTERNAL_API_URL` is correctly configured
2. Verify the session token is valid in the external portal
3. Check external portal API logs for validation failures
4. Ensure `EXTERNAL_API_KEY` is correct

### Issue: "User not found. Please contact your CSA"

**Cause:** User doesn't exist in ACORN Travels database

**Solutions:**
1. First create the user via `/api/v1/sso/create-csa` endpoint
2. Ensure the email matches between systems
3. Check customer database for the user

### Issue: "Invalid API key"

**Cause:** Wrong API key provided for protected endpoints

**Solutions:**
1. Verify `EXTERNAL_APP_API_KEY` in backend .env
2. Ensure external app is sending correct `X-API-Key` header
3. Check for typos or whitespace in API keys

## Swagger Documentation

All SSO endpoints are documented in Swagger. Access the documentation at:

```
http://localhost:8000/api-docs
```

Look for the "SSO" tag to find all SSO-related endpoints.

## Maintenance and Updates

### Adding New SSO Providers

To add support for additional SSO providers:

1. Update `externalSessionService.js` to support multiple providers
2. Add provider-specific configuration to environment variables
3. Update validation logic in `ssoController.js`
4. Update frontend to handle provider-specific parameters

### Modifying User Data

If you need to sync additional user data from the external portal:

1. Update the expected response format in `externalSessionService.js`
2. Modify the customer model if new fields are needed
3. Update the `validateSessionAndLogin` controller to handle new fields
4. Update frontend TypeScript interfaces

## Support

For questions or issues related to SSO implementation, please contact:
- Backend Team: backend@acorntravels.com
- Frontend Team: frontend@acorntravels.com
- DevOps: devops@acorntravels.com

