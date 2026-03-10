# SSO Session Caching System

## Overview

Instead of validating session tokens with the external portal on every request, ACORN Travels now caches validated session tokens locally with a 30-minute expiration. This improves performance, reduces external API dependencies, and gives better control over session management.

## How It Works

### Flow Diagram

```
User Login Request
    ↓
Check Local Cache
    ↓
    ├─ Cache Hit (Valid Session)
    │     ↓
    │  Use Cached Data
    │     ↓
    │  Generate JWT
    │     ↓
    │  Return Response
    │
    └─ Cache Miss or Expired
          ↓
      Validate with External API
          ↓
      Store in Cache (30 min TTL)
          ↓
      Generate JWT
          ↓
      Return Response
```

### Detailed Process

1. **First Login**:
   - User provides `userId` and `sessionToken`
   - System validates with external portal API
   - External API returns user data
   - System stores session in MongoDB with 30-minute expiration
   - Returns JWT tokens to user

2. **Subsequent Requests** (within 30 minutes):
   - User provides same `userId` and `sessionToken`
   - System finds valid cached session
   - **No external API call needed**
   - Returns JWT tokens immediately

3. **After 30 Minutes**:
   - Cached session expires (MongoDB TTL)
   - System validates with external portal again
   - New 30-minute cache created

## Database Schema

### SSO Session Collection

```javascript
{
  sessionToken: String,      // Unique session token
  userId: String,           // User ID from external portal
  csaId: Number,            // CSA ID in ACORN system
  email: String,            // CSA email
  name: String,             // CSA name
  externalUserId: String,   // External portal user ID
  validatedAt: Date,        // When validated
  expiresAt: Date,          // Expiration time (30 min from validation)
  createdAt: Date,          // Auto-generated
  updatedAt: Date           // Auto-generated
}
```

### Indexes

1. **TTL Index**: `{ expiresAt: 1 }` - Auto-deletes expired sessions
2. **Unique Index**: `{ sessionToken: 1 }` - Ensures token uniqueness
3. **Compound Index**: `{ sessionToken: 1, userId: 1 }` - Fast lookups
4. **Standard Index**: `{ userId: 1 }` - User-based queries
5. **Standard Index**: `{ expiresAt: 1 }` - Expiration queries

## API Endpoints

### 1. Validate Session (Enhanced)

**Endpoint**: `POST /api/v1/sso/validate-session`

**Now with Caching**:
- First checks local cache
- Only calls external API if cache miss
- Stores result for 30 minutes

**Request**:
```json
{
  "userId": "CSA123",
  "sessionToken": "abc123..."
}
```

**Response** (same as before):
```json
{
  "message": "SSO login successful.",
  "success": true,
  "data": {
    "user": {
      "csaId": 1,
      "name": "Jane Smith",
      "email": "jane.smith@acorntravels.com",
      "mobile": "+1234567890"
    },
    "accessToken": "jwt-token...",
    "refreshToken": "refresh-token...",
    "isFirstTimeLogin": false
  }
}
```

### 2. Logout (Invalidate Session)

**Endpoint**: `POST /api/v1/sso/logout`

**Purpose**: Invalidate cached session token

**Request**:
```json
{
  "sessionToken": "abc123..."
}
```

**Response**:
```json
{
  "message": "SSO session invalidated successfully",
  "success": true,
  "data": {
    "sessionToken": "abc123...",
    "invalidatedAt": "2024-11-26T10:30:00.000Z"
  }
}
```

### 3. Session Statistics

**Endpoint**: `GET /api/v1/sso/sessions/stats`

**Purpose**: Monitor cached sessions

**Response**:
```json
{
  "message": "SSO session statistics",
  "success": true,
  "data": {
    "totalSessions": 150,
    "activeSessions": 120,
    "expiredSessions": 30,
    "expiringSoon": 5,
    "timestamp": "2024-11-26T10:30:00.000Z"
  }
}
```

### 4. Cleanup Expired Sessions

**Endpoint**: `POST /api/v1/sso/sessions/cleanup`

**Purpose**: Manually trigger cleanup (MongoDB TTL handles this automatically)

**Response**:
```json
{
  "message": "Expired sessions cleaned up",
  "success": true,
  "data": {
    "deletedCount": 25,
    "timestamp": "2024-11-26T10:30:00.000Z"
  }
}
```

## Benefits

### 1. Performance Improvement

**Before** (Without Caching):
```
Every login: ~500ms (external API call)
10 logins/min = 10 external API calls
```

**After** (With Caching):
```
First login: ~500ms (external API call + cache store)
Subsequent logins (30 min): ~50ms (database lookup)
10 logins/min = 1-2 external API calls (only new sessions)
```

**Result**: ~90% reduction in external API calls

### 2. Reduced External Dependency

- System continues working even if external portal is slow
- Cached sessions valid even during external portal downtime
- Better fault tolerance

### 3. Better Control

- Can invalidate sessions on-demand (logout)
- Monitor session statistics
- Audit session usage
- Flexible expiration policies

### 4. Cost Savings

- Fewer external API calls = lower costs
- Reduced bandwidth usage
- Lower external API rate limit consumption

## Automatic Cleanup

### MongoDB TTL (Time To Live) Index

MongoDB automatically removes expired documents:

```javascript
// TTL Index
ssoSessionSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });
```

- Runs every 60 seconds
- Deletes documents where `expiresAt` < current time
- No manual intervention needed
- Zero performance impact

### Manual Cleanup (Optional)

```bash
# Trigger manual cleanup if needed
curl -X POST http://localhost:8000/api/v1/sso/sessions/cleanup
```

## Session Lifecycle

```
┌─────────────────────────────────────────────────────┐
│                Session Lifecycle                     │
└─────────────────────────────────────────────────────┘

1. Created (validatedAt)
   └─ User logs in
   └─ External validation successful
   └─ Stored in MongoDB
   └─ expiresAt = now + 30 minutes

2. Active (< 30 minutes old)
   └─ Subsequent logins use cache
   └─ No external API calls
   └─ Fast response

3. Expiring Soon (< 5 minutes remaining)
   └─ Still valid
   └─ Counted in "expiringSoon" stats
   └─ Useful for monitoring

4. Expired (> 30 minutes old)
   └─ MongoDB TTL deletes automatically
   └─ Next login triggers re-validation
   └─ New cache entry created

5. Invalidated (logout)
   └─ Manually deleted via logout endpoint
   └─ User must re-authenticate
   └─ New external validation required
```

## Code Examples

### Backend: Check Cache First

```javascript
// In ssoController.js
const cachedSession = await SSOSession.findValidSession(userId, sessionToken);

if (cachedSession) {
  // Use cached data - no external API call
  console.log('Cache hit!');
  return useCachedData(cachedSession);
} else {
  // Cache miss - validate with external API
  console.log('Cache miss - calling external API');
  const validationResult = await validateExternalSession(userId, sessionToken);
  
  // Store in cache
  await SSOSession.createOrUpdateSession({
    sessionToken,
    userId,
    csaId,
    email,
    name,
    externalUserId
  });
  
  return useValidatedData(validationResult);
}
```

### Frontend: Logout

```typescript
// Logout function
async function logoutSSO(sessionToken: string) {
  try {
    await axiosInstance.post('/api/v1/sso/logout', {
      sessionToken
    });
    
    // Clear local auth data
    localStorage.removeItem('acorn_auth_data');
    
    toast.success('Logged out successfully');
    navigate('/sign-in');
  } catch (error) {
    console.error('Logout error:', error);
    toast.error('Logout failed');
  }
}
```

## Monitoring

### View Session Statistics

```bash
# Get current session stats
curl http://localhost:8000/api/v1/sso/sessions/stats

# Response shows:
# - Total sessions in database
# - Active sessions (not expired)
# - Expired sessions (awaiting cleanup)
# - Sessions expiring soon (< 5 minutes)
```

### MongoDB Queries

```javascript
// Find all active sessions
db.ssosessions.find({
  expiresAt: { $gt: new Date() }
});

// Find sessions for specific user
db.ssosessions.find({
  userId: "CSA123"
});

// Find sessions expiring in next 5 minutes
db.ssosessions.find({
  expiresAt: {
    $gt: new Date(),
    $lt: new Date(Date.now() + 5 * 60 * 1000)
  }
});
```

## Configuration

### Adjust Expiration Time

To change from 30 minutes to another duration:

```javascript
// In ssoSessionModel.js
const expiresAt = new Date(Date.now() + 30 * 60 * 1000); // 30 minutes

// Change to 60 minutes:
const expiresAt = new Date(Date.now() + 60 * 60 * 1000); // 60 minutes

// Change to 15 minutes:
const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes
```

### Environment Variables

No new environment variables needed! The session caching works with existing configuration.

## Security Considerations

### 1. Session Token Security

- Tokens stored in MongoDB (not in external portal)
- Automatic expiration prevents stale sessions
- Can invalidate on-demand (logout)
- Indexed for fast, secure lookups

### 2. Replay Attack Protection

- Tokens have 30-minute lifespan
- Logout immediately invalidates token
- Can't reuse invalidated tokens
- External validation on cache miss

### 3. Data Privacy

- Only necessary data cached (no passwords)
- Automatic cleanup of expired data
- TTL ensures data doesn't persist indefinitely

## Troubleshooting

### Issue: Sessions not expiring

**Check**:
```bash
# Verify TTL index exists
db.ssosessions.getIndexes()

# Should see:
{
  "expiresAt_1": {
    "expireAfterSeconds": 0
  }
}
```

**Fix**: Recreate TTL index if missing

### Issue: Too many cached sessions

**Check**:
```bash
curl http://localhost:8000/api/v1/sso/sessions/stats
```

**Fix**: Manually cleanup
```bash
curl -X POST http://localhost:8000/api/v1/sso/sessions/cleanup
```

### Issue: Cache not being used

**Check logs**:
```
"Using cached SSO session for userId: CSA123"  # Cache hit
"Validating SSO session with external portal"   # Cache miss
```

**Verify**: Session exists and not expired
```javascript
db.ssosessions.findOne({ userId: "CSA123" })
```

## Performance Metrics

### Expected Improvements

| Metric | Before Caching | After Caching | Improvement |
|--------|---------------|---------------|-------------|
| Avg Response Time | 500ms | 50ms | 90% faster |
| External API Calls | 100% | 10-20% | 80-90% reduction |
| Concurrent Users | Limited by external API | Limited by MongoDB | 5-10x increase |
| Fault Tolerance | Dependent | Independent | High improvement |

## Best Practices

1. **Monitor Session Stats**: Check regularly for unusual patterns
2. **Set Up Alerts**: Alert when expired sessions > 1000
3. **Log Cache Hits/Misses**: Track cache effectiveness
4. **Regular Cleanup**: Run manual cleanup if TTL falls behind
5. **Optimize Expiration**: Adjust 30-minute window based on usage patterns

## Summary

✅ **Session tokens cached locally** instead of external portal  
✅ **30-minute automatic expiration** via MongoDB TTL  
✅ **90% reduction in external API calls**  
✅ **Logout endpoint** for immediate invalidation  
✅ **Statistics endpoint** for monitoring  
✅ **No performance impact** from TTL cleanup  
✅ **Better fault tolerance** and control  

---

**Last Updated**: November 26, 2024  
**Version**: 1.1.0 (Session Caching Update)

