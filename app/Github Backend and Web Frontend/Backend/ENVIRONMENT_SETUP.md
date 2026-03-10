# Environment Variables Setup Guide

## Required Environment Variables

### EXTERNAL_APP_API_KEY

This environment variable is required for SSO (Single Sign-On) functionality, specifically for the `/api/v1/sso/create-csa` endpoint.

#### What it does:
- Validates API key from external applications that want to create CSAs and customers
- Ensures only authorized external systems can access protected SSO endpoints

#### How to set it up:

**1. Local Development (.env file):**

Create or update a `.env` file in the `Backend` directory:

```env
EXTERNAL_APP_API_KEY=your-secure-api-key-here
```

**Example:**
```env
EXTERNAL_APP_API_KEY=acorn-travels-external-api-key-2024-secure-random-string
```

**2. Production/Deployment (Render, AWS, etc.):**

Set the environment variable in your hosting platform:

- **Render**: Go to your service → Environment → Add `EXTERNAL_APP_API_KEY`
- **AWS Lambda**: Set in Lambda environment variables
- **Heroku**: Use `heroku config:set EXTERNAL_APP_API_KEY=your-key`
- **Docker**: Add to your `docker-compose.yml` or `Dockerfile`

#### Generating a Secure API Key:

You can generate a secure API key using:

**Node.js:**
```javascript
const crypto = require('crypto');
console.log(crypto.randomBytes(32).toString('hex'));
```

**Online tools:**
- Use a UUID generator
- Use a secure random string generator

**Example secure key:**
```
a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6
```

#### Verification:

After setting the environment variable:

1. Restart your server
2. Check the console - you should NOT see the error: `❌ EXTERNAL_APP_API_KEY is not set in environment variables`
3. Test the SSO endpoint with the API key in the `X-API-Key` header

#### Testing in Postman:

1. Set `apiKey` variable in your Postman environment
2. Use it in the `X-API-Key` header for SSO endpoints
3. The collection automatically includes this header for protected SSO endpoints

#### Troubleshooting:

**Issue: `EXTERNAL_APP_API_KEY` is undefined**

1. ✅ Check that `.env` file exists in the `Backend` directory
2. ✅ Verify the variable name is exactly `EXTERNAL_APP_API_KEY` (case-sensitive)
3. ✅ Ensure there are no spaces around the `=` sign: `EXTERNAL_APP_API_KEY=value` (not `EXTERNAL_APP_API_KEY = value`)
4. ✅ Restart your server after adding the variable
5. ✅ Check that `dotenv.config()` is called in `index.js` (it should be at the top)
6. ✅ For production, verify the environment variable is set in your hosting platform

**Issue: API key validation fails**

1. ✅ Ensure the API key in your request header matches exactly (no extra spaces)
2. ✅ Check that the key in `.env` matches the key you're sending
3. ✅ Verify the header name is `X-API-Key` (case-sensitive)

#### Security Best Practices:

1. 🔒 **Never commit `.env` files to git** - add `.env` to `.gitignore`
2. 🔒 **Use different keys for development and production**
3. 🔒 **Rotate keys periodically** (every 90 days recommended)
4. 🔒 **Use strong, random keys** (at least 32 characters)
5. 🔒 **Don't share keys in chat/email** - use secure secret management tools

---

### WORKHUB24_CLIENT_ID

Client ID for WorkHub24 API authentication.

**Example:**
```env
WORKHUB24_CLIENT_ID=your-client-id-here
```

---

### WORKHUB24_CLIENT_SECRET

Client secret for WorkHub24 API authentication.

**Example:**
```env
WORKHUB24_CLIENT_SECRET=your-client-secret-here
```

---

### WORKHUB24_AUTH_URL

WorkHub24 authentication endpoint URL. Defaults to `https://app.workhub24.com/api/auth/token` if not set.

**Example:**
```env
WORKHUB24_AUTH_URL=https://app.workhub24.com/api/auth/token
```

---

### WORKHUB24_CARD_URL

WorkHub24 card data endpoint URL. Defaults to `https://app.workhub24.com/api/workflows/JCYMSV6JQ67R2WLXEOQYFHL6W5NMJ2A7/w44ac8c80c1/cards` if not set.

**Example:**
```env
WORKHUB24_CARD_URL=https://app.workhub24.com/api/workflows/JCYMSV6JQ67R2WLXEOQYFHL6W5NMJ2A7/w44ac8c80c1/cards
```

---

### ALLOWED_ORIGINS

Comma-separated list of allowed CORS origins. These are the frontend URLs that are allowed to make requests to the backend API.

**Format:** Comma-separated URLs (no spaces around commas, or spaces will be trimmed)

**Example:**
```env
ALLOWED_ORIGINS=http://localhost:3039,http://localhost:5173,https://acorn-portal.netlify.app,https://wallet.acorn.lk
```

**Default (if not set):**
- `http://localhost:3039`
- `http://localhost:5173`
- `https://acorn-portal.netlify.app`
- `https://acorn-dev-2.dtcmzb2rieufg.amplifyapp.com`
- `https://wallet.acorn.lk`

**Note:** If you don't set this variable, the default development origins will be used. For production, always set this explicitly.

---

## Other Environment Variables

For a complete list of all environment variables used in the project, see:
- `RENDER_DEPLOYMENT_GUIDE.md` - Contains deployment-specific variables
- Check individual config files in `Backend/config/` for other required variables

