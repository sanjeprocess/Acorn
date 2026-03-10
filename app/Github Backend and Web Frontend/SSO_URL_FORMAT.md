# SSO URL Format Guide

## Overview

The SSO login uses a single URL path with encoded authentication data. When users click the SSO link from the external portal, they are automatically authenticated and routed to the appropriate page.

## URL Format

```
https://acorn-travels.com/SSOLogin/SSO=<encodedData>
```

### Encoded Data Format

The `<encodedData>` is a **Base64-encoded string** with the following format:

```
USERID:<userId>:TOKEN:<sessionToken>
```

**Example** (before encoding):
```
USERID:CSA123:TOKEN:abc123def456ghi789
```

**After Base64 encoding**:
```
VVNFUklEOkNTQTEyMzpUT0tFTjphYmMxMjNkZWY0NTZnaGk3ODk=
```

**Final URL**:
```
https://acorn-travels.com/SSOLogin/SSO=VVNFUklEOkNTQTEyMzpUT0tFTjphYmMxMjNkZWY0NTZnaGk3ODk=
```

## User Flow

### Flow Diagram

```
User clicks SSO link
    ↓
Shows loader "Authenticating..."
    ↓
Validates session with backend
    ↓
    ├─ Valid & First Time
    │     ↓
    │  Toast: "Please Register!"
    │     ↓
    │  Route to Sign-Up (pre-filled)
    │
    ├─ Valid & Existing User
    │     ↓
    │  Toast: "Login successful!"
    │     ↓
    │  Route to Dashboard
    │
    └─ Invalid Session/User
          ↓
       Toast: "Username or session is invalid"
          ↓
       Route to Login Page
```

## Code Examples

### JavaScript/Node.js

```javascript
function generateSSOUrl(userId, sessionToken) {
  // Format: USERID:<userId>:TOKEN:<sessionToken>
  const data = `USERID:${userId}:TOKEN:${sessionToken}`;
  
  // Base64 encode
  const encoded = Buffer.from(data).toString('base64');
  
  // Build URL
  const baseUrl = 'https://acorn-travels.com';
  return `${baseUrl}/SSOLogin/SSO=${encoded}`;
}

// Example usage
const userId = 'CSA123';
const sessionToken = 'abc123def456ghi789';
const ssoUrl = generateSSOUrl(userId, sessionToken);

console.log(ssoUrl);
// Output: https://acorn-travels.com/SSOLogin/SSO=VVNFUklEOkNTQTEyMzpUT0tFTjphYmMxMjNkZWY0NTZnaGk3ODk=
```

### Python

```python
import base64

def generate_sso_url(user_id, session_token):
    # Format: USERID:<userId>:TOKEN:<sessionToken>
    data = f"USERID:{user_id}:TOKEN:{session_token}"
    
    # Base64 encode
    encoded = base64.b64encode(data.encode()).decode()
    
    # Build URL
    base_url = "https://acorn-travels.com"
    return f"{base_url}/SSOLogin/SSO={encoded}"

# Example usage
user_id = "CSA123"
session_token = "abc123def456ghi789"
sso_url = generate_sso_url(user_id, session_token)

print(sso_url)
# Output: https://acorn-travels.com/SSOLogin/SSO=VVNFUklEOkNTQTEyMzpUT0tFTjphYmMxMjNkZWY0NTZnaGk3ODk=
```

### PHP

```php
<?php
function generateSSOUrl($userId, $sessionToken) {
    // Format: USERID:<userId>:TOKEN:<sessionToken>
    $data = "USERID:{$userId}:TOKEN:{$sessionToken}";
    
    // Base64 encode
    $encoded = base64_encode($data);
    
    // Build URL
    $baseUrl = "https://acorn-travels.com";
    return "{$baseUrl}/SSOLogin/SSO={$encoded}";
}

// Example usage
$userId = "CSA123";
$sessionToken = "abc123def456ghi789";
$ssoUrl = generateSSOUrl($userId, $sessionToken);

echo $ssoUrl;
// Output: https://acorn-travels.com/SSOLogin/SSO=VVNFUklEOkNTQTEyMzpUT0tFTjphYmMxMjNkZWY0NTZnaGk3ODk=
?>
```

### React (for generating links in UI)

```typescript
function generateSSOUrl(userId: string, sessionToken: string): string {
  // Format: USERID:<userId>:TOKEN:<sessionToken>
  const data = `USERID:${userId}:TOKEN:${sessionToken}`;
  
  // Base64 encode
  const encoded = btoa(data);
  
  // Build URL
  const baseUrl = 'https://acorn-travels.com';
  return `${baseUrl}/SSOLogin/SSO=${encoded}`;
}

// React component example
function SSOLink({ userId, sessionToken }: { userId: string; sessionToken: string }) {
  const ssoUrl = generateSSOUrl(userId, sessionToken);
  
  return (
    <a 
      href={ssoUrl} 
      target="_blank" 
      rel="noopener noreferrer"
      className="btn btn-primary"
    >
      Access ACORN Travels
    </a>
  );
}
```

## Frontend Parsing

The ACORN Travels frontend automatically parses the URL:

```typescript
// Frontend parsing logic
function parseSSOData(ssoParam: string): { userId: string; sessionToken: string } | null {
  try {
    // Decode base64
    const decoded = atob(ssoParam);
    
    // Expected format: USERID:<userId>:TOKEN:<sessionToken>
    const parts = decoded.split(':');
    
    if (parts.length === 4 && parts[0] === 'USERID' && parts[2] === 'TOKEN') {
      return {
        userId: parts[1],
        sessionToken: parts[3],
      };
    }
    
    return null;
  } catch (error) {
    console.error('Error parsing SSO data:', error);
    return null;
  }
}
```

## Response Scenarios

### Scenario 1: Valid Session - First Time Login

**User Action**: Clicks SSO link  
**Backend Response**: Session valid, user exists, no password set  
**Frontend Action**: 
- Shows loader
- Toast: "Please Register!"
- Routes to `/sign-up` with pre-filled data (name, email, mobile)
- User sets password
- Routes to dashboard

### Scenario 2: Valid Session - Existing User

**User Action**: Clicks SSO link  
**Backend Response**: Session valid, user exists, password set  
**Frontend Action**: 
- Shows loader
- Toast: "Login successful!"
- Routes to `/secured/user` (dashboard)

### Scenario 3: Invalid Session

**User Action**: Clicks SSO link  
**Backend Response**: Session invalid or expired  
**Frontend Action**: 
- Shows loader
- Toast: "Username or session is invalid"
- Routes to `/sign-in` (login page)

### Scenario 4: User Not Found

**User Action**: Clicks SSO link  
**Backend Response**: User doesn't exist in ACORN system  
**Frontend Action**: 
- Shows loader
- Toast: "CSA account not found. Please ensure your account has been created in the system first."
- Routes to `/sign-in` (login page)

## Testing

### Generate Test URL

```javascript
// Test credentials
const userId = 'TEST_CSA';
const sessionToken = 'test_token_123';

// Generate URL
const data = `USERID:${userId}:TOKEN:${sessionToken}`;
const encoded = Buffer.from(data).toString('base64');
const testUrl = `http://localhost:5173/SSOLogin/SSO=${encoded}`;

console.log('Test URL:', testUrl);
// http://localhost:5173/SSOLogin/SSO=VVNFUklEOlRFU1RfQ1NBOlRPS0VOOnRlc3RfdG9rZW5fMTIz
```

### Verify Encoding/Decoding

```javascript
// Original data
const original = 'USERID:CSA123:TOKEN:abc123';

// Encode
const encoded = Buffer.from(original).toString('base64');
console.log('Encoded:', encoded);

// Decode
const decoded = Buffer.from(encoded, 'base64').toString();
console.log('Decoded:', decoded);
console.log('Match:', original === decoded); // Should be true
```

## URL Length Considerations

### Maximum URL Length

Most browsers support URLs up to 2,083 characters. The SSO URL structure:

```
Base: https://acorn-travels.com/SSOLogin/SSO= (46 chars)
Data: USERID:<userId>:TOKEN:<sessionToken>
Encoded: Base64 of data (~33% longer)
```

**Example Calculation**:
- userId: 20 chars
- sessionToken: 200 chars
- Format overhead: 14 chars (`USERID::TOKEN:`)
- Total before encoding: 234 chars
- After Base64: ~312 chars
- Final URL: ~358 chars ✅ Well within limit

### Recommendations

- Keep userId < 50 characters
- Keep sessionToken < 500 characters
- Total URL will be ~730 characters (safe)

## Security Considerations

### 1. HTTPS Required

Always use HTTPS in production:
```
✅ https://acorn-travels.com/SSOLogin/SSO=...
❌ http://acorn-travels.com/SSOLogin/SSO=...
```

### 2. Session Token Security

- Use cryptographically secure tokens
- Tokens should be unique per session
- Implement reasonable expiration (30 minutes in cache)

### 3. URL Encoding

- Base64 encoding is for format, not security
- Don't rely on encoding for security
- Session validation happens server-side

### 4. Validation

- ACORN backend validates with external portal
- Session must be active in external system
- Token cached for 30 minutes after validation

## Error Handling

### Invalid URL Format

If URL doesn't match expected format:
```
Bad: https://acorn-travels.com/SSOLogin/invalid-data
Result: Toast "Invalid SSO parameters" → Route to login
```

### Malformed Base64

If Base64 is corrupted:
```
Bad: https://acorn-travels.com/SSOLogin/SSO=invalid!!!base64
Result: Toast "Invalid SSO parameters" → Route to login
```

### Missing Components

If decoded data missing USERID or TOKEN:
```
Bad: USERID:CSA123 (missing TOKEN part)
Result: Toast "Invalid SSO parameters" → Route to login
```

## Integration Checklist

For external portal developers:

- [ ] Implement SSO URL generation function
- [ ] Use correct format: `USERID:<userId>:TOKEN:<sessionToken>`
- [ ] Base64 encode the data string
- [ ] Append to base URL: `/SSOLogin/SSO=<encoded>`
- [ ] Use HTTPS in production
- [ ] Test with valid session tokens
- [ ] Test with invalid/expired tokens
- [ ] Verify user experience for first-time vs existing users
- [ ] Handle edge cases (missing users, network errors)

## Example Integration

### External Portal Button

```html
<!-- HTML Example -->
<button onclick="openACORNTravels()">
  Access ACORN Travels
</button>

<script>
function openACORNTravels() {
  // Get current user's ID and session token
  const userId = getCurrentUserId(); // Your function
  const sessionToken = getCurrentSessionToken(); // Your function
  
  // Generate SSO URL
  const data = `USERID:${userId}:TOKEN:${sessionToken}`;
  const encoded = btoa(data);
  const ssoUrl = `https://acorn-travels.com/SSOLogin/SSO=${encoded}`;
  
  // Open in new tab
  window.open(ssoUrl, '_blank');
}
</script>
```

## Summary

✅ **URL Format**: `/SSOLogin/SSO=<base64EncodedData>`  
✅ **Data Format**: `USERID:<userId>:TOKEN:<sessionToken>`  
✅ **Encoding**: Base64  
✅ **Behavior**: Shows loader → validates → routes based on result  
✅ **First Time**: Toast "Please Register!" → Sign-up page  
✅ **Existing User**: Toast "Login successful!" → Dashboard  
✅ **Invalid**: Toast "Username or session is invalid" → Login page  

---

**Last Updated**: November 26, 2024  
**Version**: 1.3.0 (URL-based SSO)

