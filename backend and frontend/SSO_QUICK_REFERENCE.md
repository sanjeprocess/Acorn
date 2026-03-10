# SSO Quick Reference Card

## 🚀 Quick Links

- **Full Documentation**: [SSO_IMPLEMENTATION_GUIDE.md](./SSO_IMPLEMENTATION_GUIDE.md)
- **External App Guide**: [SSO_EXTERNAL_APP_GUIDE.md](./SSO_EXTERNAL_APP_GUIDE.md)
- **Implementation Summary**: [SSO_IMPLEMENTATION_SUMMARY.md](./SSO_IMPLEMENTATION_SUMMARY.md)
- **Swagger Docs**: http://localhost:8000/api-docs (Look for "SSO" tag)

## 🔑 Environment Variables

### Backend (.env)
```bash
EXTERNAL_API_URL=https://external-portal.example.com
EXTERNAL_API_KEY=your-external-api-key-here
EXTERNAL_APP_API_KEY=your-external-app-api-key-here
```

## 🌐 API Endpoints

### 1. Validate Session (Public)
```
POST /api/v1/sso/validate-session
Body: { "userId": "string", "sessionToken": "string" }
```

### 2. Create CSA (Protected - API Key)
```
POST /api/v1/sso/create-csa
Headers: X-API-Key: your-api-key
Body: { "csaName": "string", "csaEmail": "string", "csaMobile": "string", "customers": [...] }
```

### 3. Check User (Public)
```
GET /api/v1/sso/check-user?email=user@example.com
```

## 🔗 SSO Login URL Format

```
https://acorn-travels.com/sso-login?userId={userId}&sessionToken={sessionToken}
```

## 🧪 Quick Test Commands

### Test Session Validation
```bash
curl -X POST http://localhost:8000/api/v1/sso/validate-session \
  -H "Content-Type: application/json" \
  -d '{"userId":"TEST123","sessionToken":"test-token"}'
```

### Test CSA Creation
```bash
curl -X POST http://localhost:8000/api/v1/sso/create-csa \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key" \
  -d '{
    "csaName":"Test CSA",
    "csaEmail":"test@example.com",
    "csaMobile":"+1234567890",
    "customers":[{"name":"Test","email":"test@test.com"}]
  }'
```

### Test Frontend SSO
```
Navigate to: http://localhost:5173/sso-login?userId=TEST&sessionToken=ABC123
```

## 📁 Key Files

### Backend
- `Backend/services/externalSessionService.js` - External API communication
- `Backend/controllers/ssoController.js` - SSO business logic
- `Backend/middleware/apiKeyMiddleware.js` - API key validation
- `Backend/routes/ssoRoutes.js` - SSO route definitions

### Frontend
- `Frontend/src/backend/api/ssoApi.ts` - SSO API functions
- `Frontend/src/sections/auth/sso-login-view.tsx` - SSO login component
- `Frontend/src/sections/auth/sign-up-view.tsx` - Enhanced sign-up (supports SSO)
- `Frontend/src/pages/sso-login.tsx` - SSO login page

## 🔄 User Flows

### Existing User
```
External Portal → SSO Login → Session Validation → JWT Tokens → Landing Page
```

### First-Time User
```
External Portal → SSO Login → Session Validation → JWT Tokens → Sign-up Page → Landing Page
```

### CSA Creation
```
External App → API Call → Create CSA → Create Customers → Return Summary
```

## 🛠️ Common Code Snippets

### Generate SSO Link (JavaScript)
```javascript
const link = `https://acorn-travels.com/sso-login?userId=${userId}&sessionToken=${sessionToken}`;
```

### Validate Session (Node.js)
```javascript
const response = await axios.post(
  'https://api.acorntravels.com/api/v1/sso/validate-session',
  { userId, sessionToken }
);
```

### Create CSA (Node.js)
```javascript
const response = await axios.post(
  'https://api.acorntravels.com/api/v1/sso/create-csa',
  { csaName, csaEmail, csaMobile, customers },
  { headers: { 'X-API-Key': apiKey } }
);
```

## 🐛 Troubleshooting

| Error | Cause | Solution |
|-------|-------|----------|
| Invalid session | External API rejected validation | Check external API logs |
| User not found | User not in ACORN system | Create user via `/sso/create-csa` |
| Invalid API key | Wrong/missing API key | Check `EXTERNAL_APP_API_KEY` |
| 404 on SSO endpoint | Routes not registered | Check `Backend/index.js` |

## 📊 Response Codes

- **200**: Success
- **400**: Bad request (missing parameters)
- **401**: Unauthorized (invalid session)
- **403**: Forbidden (invalid API key)
- **404**: User not found
- **500**: Server error

## 🔐 Security Checklist

- [ ] Use HTTPS in production
- [ ] Store API keys in environment variables
- [ ] Implement session token expiration
- [ ] Enable rate limiting
- [ ] Validate all inputs
- [ ] Monitor failed login attempts

## 📞 Support Contacts

- **Technical**: dev@acorntravels.com
- **API Issues**: api-support@acorntravels.com
- **Emergency**: +1-XXX-XXX-XXXX

## 🎯 Next Steps After Implementation

1. Configure environment variables
2. Test session validation endpoint
3. Create test CSA and customers
4. Test complete SSO flow
5. Monitor logs for errors
6. Update external portal integration
7. Train support team

## 📝 External Portal Requirements

Your external portal must provide:

**Endpoint**: `POST {EXTERNAL_API_URL}/api/validate-session`

**Request**:
```json
{
  "userId": "string",
  "sessionToken": "string"
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "userId": "string",
    "email": "string",
    "name": "string",
    "isValid": true
  }
}
```

## 💡 Pro Tips

1. **Testing**: Use Swagger UI for quick API testing
2. **Debugging**: Check browser console for frontend errors
3. **Logging**: Monitor backend logs for external API issues
4. **Performance**: External API should respond < 2 seconds
5. **Security**: Rotate API keys quarterly

## 🔄 Version Info

- **Version**: 1.0.0
- **Release Date**: November 26, 2024
- **Status**: ✅ Complete
- **Breaking Changes**: None (backward compatible)

---

**Need Help?** Check the full documentation or contact support!

