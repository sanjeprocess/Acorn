# SSO Consistency Update - csaId Naming

## 🎯 What Was Fixed

Changed all internal references from `userId` to `csaId` for consistency throughout the codebase.

## ✅ Changes Made

### 1. Database Model (`Backend/models/ssoSessionModel.js`)

**Before**:
```javascript
{
  sessionToken: String,
  userId: String,        // ❌ Confusing
  csaId: Number,         // ❌ Had both!
  externalUserId: String,
  // ...
}
```

**After**:
```javascript
{
  sessionToken: String,
  csaId: Number,         // ✅ Primary identifier
  email: String,
  name: String,
  externalUserId: String, // ✅ Reference to external portal's userId
  // ...
}
```

**Changes**:
- ❌ Removed separate `userId` field
- ✅ Use `csaId` as primary identifier
- ✅ Keep `externalUserId` for external portal reference
- ✅ Added index on `csaId`
- ✅ Added index on `externalUserId`
- ✅ Updated compound index: `{ sessionToken: 1, csaId: 1 }`

### 2. Model Methods (`Backend/models/ssoSessionModel.js`)

**Before**:
```javascript
findValidSession(userId, sessionToken) // ❌
createOrUpdateSession({ userId, csaId, ... }) // ❌ Had both
```

**After**:
```javascript
findValidSession(csaId, sessionToken) // ✅
findValidSessionByExternalId(externalUserId, sessionToken) // ✅ New method
createOrUpdateSession({ csaId, externalUserId, ... }) // ✅ Consistent
```

**New Method Added**:
```javascript
// Find session by external portal's userId
findValidSessionByExternalId(externalUserId, sessionToken)
```

### 3. Controller (`Backend/controllers/ssoController.js`)

**Before**:
```javascript
const { userId, sessionToken } = req.body;
const cachedSession = await SSOSession.findValidSession(userId, sessionToken);
// Confusing - is userId our ID or theirs?
```

**After**:
```javascript
const { userId, sessionToken } = req.body;
const externalUserId = userId; // ✅ Clarify: this is external portal's ID

const cachedSession = await SSOSession.findValidSessionByExternalId(
  externalUserId, 
  sessionToken
);

// Then use csaId internally
const csaId = cachedSession.csaId; // ✅ Our internal ID
```

**Console Logs Updated**:
```javascript
// Before
console.log(`Using cached SSO session for userId: ${userId}`);

// After
console.log(`Using cached SSO session for csaId: ${csaId} (external: ${externalUserId})`);
```

### 4. Swagger Documentation (`Backend/routes/ssoRoutes.js`)

**Updated descriptions**:
```yaml
userId:
  description: "User ID from the external system (represents CSA ID in their system)"

externalUserId:
  description: "The userId from external portal"
```

## 📊 Field Mapping

| Field | Type | Purpose |
|-------|------|---------|
| `csaId` | Number | Primary identifier (ACORN system) |
| `externalUserId` | String | Reference to external portal's userId |
| `sessionToken` | String | Session token (same in both systems) |

## 🔄 API Flow

### Request (External Portal → ACORN)
```json
{
  "userId": "EXT123456",
  "sessionToken": "abc123"
}
```
↓
**Translation**:
```javascript
const externalUserId = userId; // External portal's ID
// Look up our csaId
const session = await SSOSession.findValidSessionByExternalId(externalUserId, sessionToken);
const csaId = session.csaId; // Our internal ID
```
↓
### Response (ACORN → Frontend)
```json
{
  "user": {
    "csaId": 1,
    "name": "Jane Smith",
    "email": "jane@acorntravels.com"
  },
  "externalUserId": "EXT123456"
}
```

## 🎨 Naming Convention

| Context | Term | Meaning |
|---------|------|---------|
| **External API Parameter** | `userId` | External portal's user ID (their naming) |
| **Internal Code** | `csaId` | ACORN Travels CSA ID (our naming) |
| **Database Field** | `csaId` | Our primary identifier |
| **Database Field** | `externalUserId` | Stored reference to external userId |
| **Response** | `csaId` | Returned to frontend |
| **Response** | `externalUserId` | For reference/debugging |

## 📝 Code Examples

### Creating a Session
```javascript
// ✅ Consistent - only csaId internally
await SSOSession.createOrUpdateSession({
  sessionToken: "abc123",
  csaId: 1,                    // Our ID
  email: "jane@acorntravels.com",
  name: "Jane Smith",
  externalUserId: "EXT123456"  // Their ID (reference)
});
```

### Finding a Session
```javascript
// By our csaId
const session = await SSOSession.findValidSession(csaId, sessionToken);

// By external portal's userId
const session = await SSOSession.findValidSessionByExternalId(
  externalUserId, 
  sessionToken
);
```

### Controller Pattern
```javascript
// 1. Receive from external API
const { userId, sessionToken } = req.body;

// 2. Clarify naming immediately
const externalUserId = userId;

// 3. Find session by external ID
const cachedSession = await SSOSession.findValidSessionByExternalId(
  externalUserId, 
  sessionToken
);

// 4. Use our csaId internally
if (cachedSession) {
  const csaId = cachedSession.csaId;
  // Work with csaId everywhere
}
```

## ✨ Benefits

### 1. Consistency ✅
- All internal code uses `csaId`
- No mixing of `userId` and `csaId`
- Clear what each identifier represents

### 2. Clarity ✅
- `csaId` = Our system
- `externalUserId` = Their system
- No confusion

### 3. Maintainability ✅
- Self-documenting code
- Easy to understand
- Reduces bugs

### 4. Scalability ✅
- Easy to support multiple external portals
- Each can have different `externalUserId`
- Our `csaId` stays consistent

## 🔍 Database Indexes

### Updated Indexes
```javascript
// Primary lookup
{ csaId: 1 }                    // ✅ New
{ externalUserId: 1 }           // ✅ New
{ sessionToken: 1 }             // ✅ Existing (unique)

// Compound indexes
{ sessionToken: 1, csaId: 1 }   // ✅ Updated from userId
{ expiresAt: 1 }                // ✅ TTL index
```

## 🚫 No Breaking Changes

✅ External API still accepts `userId` parameter  
✅ Response format unchanged  
✅ Frontend code unchanged  
✅ Existing sessions remain valid  
✅ MongoDB handles field changes gracefully  

## 📚 Documentation Updated

1. ✅ `SSO_NAMING_CONVENTION.md` - Complete naming guide
2. ✅ `SSO_CONSISTENCY_UPDATE.md` - This summary
3. ✅ Updated Swagger documentation
4. ✅ Updated code comments

## 🧪 Testing

### Verify Consistency

```bash
# 1. Create session
curl -X POST http://localhost:8000/api/v1/sso/validate-session \
  -H "Content-Type: application/json" \
  -d '{"userId":"EXT123","sessionToken":"abc123"}'

# 2. Check MongoDB
db.ssosessions.findOne()
# Should see:
# {
#   csaId: 1,
#   externalUserId: "EXT123",
#   // No separate userId field
# }

# 3. Check logs
# Should see: "Using cached SSO session for csaId: 1 (external: EXT123)"
```

## 📋 Summary

| Aspect | Before | After |
|--------|--------|-------|
| **Database** | Had both `userId` and `csaId` | Only `csaId` + `externalUserId` |
| **Internal Code** | Mixed `userId` and `csaId` | Always use `csaId` |
| **Clarity** | Confusing | Crystal clear |
| **Consistency** | Inconsistent | 100% consistent |

## ✅ Checklist

- [x] Removed `userId` field from database model
- [x] Updated all indexes to use `csaId`
- [x] Added `findValidSessionByExternalId()` method
- [x] Updated controller to clarify naming
- [x] Updated all console logs
- [x] Updated Swagger documentation
- [x] Created comprehensive documentation
- [x] No linter errors
- [x] Backward compatible

---

**Status**: ✅ Complete  
**Breaking Changes**: None  
**Migration**: Automatic  
**Version**: 1.2.0  
**Last Updated**: November 26, 2024

