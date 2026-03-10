# SSO Naming Convention

## Overview

For consistency throughout the ACORN Travels codebase, we use `csaId` to identify CSAs in our system. The external portal uses `userId`, which maps to our `csaId`.

## Naming Convention

### External Portal (API Parameters)
- **`userId`**: The user ID in the external portal system
- This represents a CSA in their system

### ACORN Travels (Internal)
- **`csaId`**: The CSA ID in our database
- **`externalUserId`**: Stored reference to the external portal's userId

## Field Mapping

```
External Portal          →    ACORN Travels
─────────────────────────────────────────────
userId (their ID)        →    externalUserId (reference)
                         →    csaId (our internal ID)
sessionToken             →    sessionToken (same)
```

## Database Schema

### SSO Session Collection

```javascript
{
  sessionToken: String,      // Session token from external portal
  csaId: Number,            // CSA ID in ACORN system (primary identifier)
  email: String,            // CSA email
  name: String,             // CSA name
  externalUserId: String,   // userId from external portal (for reference)
  validatedAt: Date,
  expiresAt: Date
}
```

**Note**: We removed the separate `userId` field to avoid confusion. We now use:
- `csaId` as the primary identifier (our system)
- `externalUserId` as the reference to external portal's userId

## Code Examples

### Backend: Session Cache Lookup

**Before (Inconsistent)**:
```javascript
// Confusing - what is userId?
const session = await SSOSession.findValidSession(userId, sessionToken);
```

**After (Consistent)**:
```javascript
// Clear - external portal's userId
const externalUserId = userId; // from API request

// Find by external ID
const session = await SSOSession.findValidSessionByExternalId(
  externalUserId, 
  sessionToken
);

// Or find by our csaId
const session = await SSOSession.findValidSession(
  csaId, 
  sessionToken
);
```

### Backend: Creating Session

**Before (Inconsistent)**:
```javascript
await SSOSession.createOrUpdateSession({
  sessionToken,
  userId,           // Confusing
  csaId,           // Also had this
  email,
  name,
  externalUserId
});
```

**After (Consistent)**:
```javascript
await SSOSession.createOrUpdateSession({
  sessionToken,
  csaId,           // Our internal ID
  email,
  name,
  externalUserId   // External portal's userId
});
```

### Controller Flow

```javascript
export const validateSessionAndLogin = async (req, res) => {
  // 1. Receive from external API (their naming)
  const { userId, sessionToken } = req.body;
  
  // 2. Immediately clarify naming
  const externalUserId = userId; // This is external portal's userId
  
  // 3. Check cache by external ID
  const cachedSession = await SSOSession.findValidSessionByExternalId(
    externalUserId, 
    sessionToken
  );
  
  if (cachedSession) {
    // 4. Use our csaId internally
    const csaId = cachedSession.csaId;
    console.log(`Using cached session for csaId: ${csaId}`);
  } else {
    // 5. Validate and map to our csaId
    const result = await validateExternalSession(externalUserId, sessionToken);
    const csa = await CSA.findOne({ email: result.userData.email });
    
    // 6. Store with both IDs for reference
    await SSOSession.createOrUpdateSession({
      sessionToken,
      csaId: csa.csaId,        // Our ID
      email: csa.email,
      name: csa.name,
      externalUserId           // Their ID (for reference)
    });
  }
};
```

## API Documentation

### Request Parameter (External Naming)

```json
{
  "userId": "EXT123456",
  "sessionToken": "abc123..."
}
```

**Note**: `userId` is the parameter name expected by external portal conventions, but it represents a CSA.

### Response (Our Naming)

```json
{
  "data": {
    "user": {
      "csaId": 1,              // Our internal CSA ID
      "name": "Jane Smith",
      "email": "jane@acorntravels.com",
      "mobile": "+1234567890"
    },
    "externalUserId": "EXT123456"  // Their userId (for reference)
  }
}
```

## Benefits of This Convention

### 1. Consistency
- All internal code uses `csaId`
- Clear what each ID represents
- No confusion between systems

### 2. Clarity
- `csaId` = Our system's CSA identifier
- `externalUserId` = External portal's identifier
- Clear separation of concerns

### 3. Maintainability
- Easy to understand code
- Self-documenting variable names
- Reduces bugs from ID confusion

### 4. Scalability
- Easy to add more external portals
- Each can have their own `externalUserId`
- Our `csaId` remains consistent

## Migration Notes

### What Changed

1. **Removed**: Separate `userId` field from database schema
2. **Added**: `findValidSessionByExternalId()` method
3. **Updated**: All internal references to use `csaId`
4. **Clarified**: `externalUserId` is for external portal reference

### No Breaking Changes

- External API still accepts `userId` parameter
- Response format unchanged
- Database automatically handles field removal
- Existing sessions remain valid

## Quick Reference

| Term | Meaning | Where Used |
|------|---------|------------|
| `userId` | External portal's user ID (in API params) | API request from external portal |
| `csaId` | ACORN Travels CSA ID | Everywhere internally |
| `externalUserId` | Stored reference to external userId | Database, for reference/mapping |

## Summary

✅ **API accepts**: `userId` (external portal's naming)  
✅ **Internally use**: `csaId` (our naming)  
✅ **Store both**: `csaId` + `externalUserId` (for mapping)  
✅ **Responses use**: `csaId` (consistent with our system)  
✅ **No confusion**: Clear separation between external and internal IDs  

---

**Version**: 1.2.0  
**Last Updated**: November 26, 2024  
**Status**: ✅ Implemented

