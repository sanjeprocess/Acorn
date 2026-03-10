# SSO Update: CSA Authentication Flow

## Important Clarification (Updated: Nov 26, 2024)

### User Role Clarification

In the external portal:
- **Users = CSAs** (Customer Service Agents)
- **Customers = End customers created by CSAs in the portal**

### What Changed

The SSO implementation has been updated to correctly handle **CSAs** as the users logging in from the external portal, not customers.

## Updated Flow

### 1. CSA Login via SSO

```
External Portal (CSA User) 
    ↓
Clicks SSO Link (userId + sessionToken)
    ↓
ACORN Travels validates session
    ↓
Checks CSA table (not Customer table)
    ↓
Generates JWT tokens for CSA (UserTypes.CSA)
    ↓
CSA logged in to ACORN Travels with CSA privileges
```

## Updated API Responses

### Validate Session Response

**Before (Incorrect):**
```json
{
  "data": {
    "customer": {
      "customerId": 1,
      "name": "John Doe",
      "email": "john.doe@example.com"
    },
    "accessToken": "...",
    "refreshToken": "..."
  }
}
```

**After (Correct):**
```json
{
  "data": {
    "user": {
      "csaId": 1,
      "name": "John Doe",
      "email": "john.doe@acorntravels.com",
      "mobile": "+1234567890"
    },
    "accessToken": "...",
    "refreshToken": "..."
  }
}
```

### Check User Response

**Before (Incorrect):**
```json
{
  "data": {
    "exists": true,
    "customerId": 1,
    "name": "John Doe"
  }
}
```

**After (Correct):**
```json
{
  "data": {
    "exists": true,
    "csaId": 1,
    "name": "John Doe",
    "email": "john.doe@acorntravels.com",
    "mobile": "+1234567890"
  }
}
```

## Updated Frontend

### TypeScript Interfaces

```typescript
// Updated interface
export interface ValidateSessionResponse {
  message: string;
  success: boolean;
  data: {
    user: {
      csaId: number;
      name: string;
      email: string;
      mobile: string;
    };
    accessToken: string;
    refreshToken: string;
    isFirstTimeLogin: boolean;
    externalUserId: string;
  };
}
```

### Auth Store

When CSA logs in via SSO, the auth store is populated with:
```typescript
{
  accessToken: "...",
  refreshToken: "...",
  name: user.name,
  email: user.email,
  mobile: user.mobile,
  csaId: user.csaId.toString(),
  userType: 'CSA',  // Important: CSA, not Customer
  isAuthenticated: true
}
```

## Complete User Journey

### Journey 1: Existing CSA Login

1. CSA is already created in ACORN Travels (via `/sso/create-csa` endpoint)
2. CSA clicks link in external portal: `https://acorn-travels.com/sso-login?userId=123&sessionToken=abc`
3. Frontend sends userId and sessionToken to backend
4. Backend validates with external portal API
5. Backend checks if CSA exists by email
6. Backend generates JWT tokens with `UserTypes.CSA`
7. CSA is redirected to `/secured/user` dashboard
8. CSA can now manage their customers

### Journey 2: First-Time CSA Login (Edge Case)

1. CSA created in external app calls `/sso/create-csa`
2. CSA account created but password not set (edge case)
3. CSA clicks SSO link
4. Backend detects `isFirstTimeLogin = true`
5. CSA redirected to `/sign-up` to set password
6. Name, email, and mobile are pre-filled and disabled
7. CSA only needs to set password
8. CSA redirected to dashboard

### Journey 3: External App Creates CSA

1. External app calls `POST /api/v1/sso/create-csa` with API key
2. Sends CSA data (name, email, mobile) + customer list
3. Backend creates/updates CSA account
4. Backend creates customer accounts linked to CSA
5. Returns summary of operations
6. CSA can now login via SSO

## Key Points

✅ **CSAs are the users** logging in from external portal
✅ **Customers are created by CSAs** in the external portal
✅ **JWT tokens use UserTypes.CSA** for proper authorization
✅ **CSAs access the dashboard** at `/secured/user`
✅ **CSAs manage customers** they created in the portal

## What Stays The Same

- The `/sso/create-csa` endpoint still creates both CSA and customers
- Customers can still be created and linked to CSAs
- The customer management flow remains unchanged
- CSAs still use the same dashboard to manage their customers

## Testing

### Test CSA Login

```bash
# 1. First, create a CSA via API
curl -X POST http://localhost:8000/api/v1/sso/create-csa \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key" \
  -d '{
    "csaName": "Jane Smith",
    "csaEmail": "jane.smith@acorntravels.com",
    "csaMobile": "+1234567890",
    "customers": [
      {
        "name": "Customer One",
        "email": "customer1@example.com"
      }
    ]
  }'

# 2. Then test SSO login
# Navigate to: http://localhost:5173/sso-login?userId=JANE123&sessionToken=test-token

# 3. Backend will validate with external portal
# 4. CSA will be logged in and redirected to dashboard
```

### Verify CSA Authentication

After SSO login, check browser localStorage:
```javascript
const authData = JSON.parse(localStorage.getItem('acorn_auth_data'));
console.log(authData.userType); // Should be 'CSA'
console.log(authData.csaId);    // Should have CSA ID
```

## Migration Notes

If you have any existing test data or documentation that refers to "customers" logging in via SSO, update them to refer to "CSAs" instead.

### No Database Migration Required

The database schema didn't change - we're just using the CSA table correctly now instead of the Customer table.

## Summary of Files Changed

### Backend
- ✅ `Backend/controllers/ssoController.js` - Updated to use CSA model
- ✅ `Backend/routes/ssoRoutes.js` - Updated Swagger docs

### Frontend
- ✅ `Frontend/src/backend/api/ssoApi.ts` - Updated TypeScript interfaces
- ✅ `Frontend/src/sections/auth/sso-login-view.tsx` - Updated to handle CSA data
- ✅ `Frontend/src/sections/auth/sign-up-view.tsx` - Updated for CSA completion flow

## Questions?

This update ensures the SSO flow correctly handles the actual user roles in your system:
- **External Portal Users = CSAs** (who manage customers)
- **External Portal Customers = Customers** (created by CSAs)

The implementation now correctly authenticates CSAs and gives them access to manage their customers in the ACORN Travels system.

