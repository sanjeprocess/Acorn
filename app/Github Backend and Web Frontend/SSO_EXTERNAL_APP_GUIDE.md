# External Application Integration Guide

This guide is for developers of the external client portal who want to integrate SSO authentication with ACORN Travels.

## Quick Start

### Prerequisites

1. Get your API credentials from ACORN Travels team:
   - `X-API-Key` for creating CSAs
   - Provide your external portal's session validation endpoint URL
   - Provide your API key that ACORN Travels will use to validate sessions

2. Configure your environment:
   - External Portal API URL
   - Session validation endpoint
   - API key for ACORN Travels

### Step 1: Create CSA and Customers

Before users can login via SSO, they must be created in the ACORN Travels system.

**Example: Node.js/JavaScript**

```javascript
const axios = require('axios');

async function createCSAWithCustomers() {
  try {
    const response = await axios.post(
      'https://api.acorntravels.com/api/v1/sso/create-csa',
      {
        csaName: 'Jane Smith',
        csaEmail: 'jane.smith@acorntravels.com',
        csaMobile: '+1234567890',
        customers: [
          {
            name: 'John Doe',
            email: 'john.doe@example.com'
          },
          {
            name: 'Alice Johnson',
            email: 'alice.johnson@example.com'
          }
        ]
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': 'your-api-key-here'
        }
      }
    );

    console.log('CSA Creation Response:', response.data);
    return response.data;
  } catch (error) {
    console.error('Error creating CSA:', error.response?.data || error.message);
    throw error;
  }
}
```

**Example: Python**

```python
import requests

def create_csa_with_customers():
    url = 'https://api.acorntravels.com/api/v1/sso/create-csa'
    headers = {
        'Content-Type': 'application/json',
        'X-API-Key': 'your-api-key-here'
    }
    payload = {
        'csaName': 'Jane Smith',
        'csaEmail': 'jane.smith@acorntravels.com',
        'csaMobile': '+1234567890',
        'customers': [
            {
                'name': 'John Doe',
                'email': 'john.doe@example.com'
            },
            {
                'name': 'Alice Johnson',
                'email': 'alice.johnson@example.com'
            }
        ]
    }
    
    response = requests.post(url, json=payload, headers=headers)
    response.raise_for_status()
    
    print('CSA Creation Response:', response.json())
    return response.json()
```

**Example: cURL**

```bash
curl -X POST https://api.acorntravels.com/api/v1/sso/create-csa \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key-here" \
  -d '{
    "csaName": "Jane Smith",
    "csaEmail": "jane.smith@acorntravels.com",
    "csaMobile": "+1234567890",
    "customers": [
      {
        "name": "John Doe",
        "email": "john.doe@example.com"
      },
      {
        "name": "Alice Johnson",
        "email": "alice.johnson@example.com"
      }
    ]
  }'
```

### Step 2: Implement Session Validation Endpoint

Your external portal must provide an endpoint that ACORN Travels can call to validate sessions.

**Example: Node.js/Express**

```javascript
const express = require('express');
const app = express();

app.use(express.json());

// Middleware to validate API key
function validateApiKey(req, res, next) {
  const apiKey = req.headers['x-api-key'];
  
  if (apiKey !== process.env.ACORN_TRAVELS_API_KEY) {
    return res.status(403).json({
      success: false,
      message: 'Invalid API key'
    });
  }
  
  next();
}

// Session validation endpoint
app.post('/api/validate-session', validateApiKey, async (req, res) => {
  const { userId, sessionToken } = req.body;
  
  try {
    // Your logic to validate the session
    // This could involve checking Redis, database, or in-memory sessions
    const session = await validateSessionInYourSystem(userId, sessionToken);
    
    if (!session || !session.isValid) {
      return res.status(401).json({
        success: false,
        message: 'Invalid or expired session'
      });
    }
    
    // Get user details
    const user = await getUserDetails(userId);
    
    return res.json({
      success: true,
      data: {
        userId: user.id,
        email: user.email,
        name: user.name,
        isValid: true
      }
    });
  } catch (error) {
    console.error('Session validation error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

async function validateSessionInYourSystem(userId, sessionToken) {
  // Implement your session validation logic
  // Example: Check if session exists in Redis
  // const session = await redis.get(`session:${sessionToken}`);
  // return session && session.userId === userId;
  
  // Placeholder implementation
  return {
    isValid: true,
    userId: userId
  };
}

async function getUserDetails(userId) {
  // Fetch user from your database
  // const user = await db.users.findById(userId);
  
  // Placeholder implementation
  return {
    id: userId,
    email: 'user@example.com',
    name: 'John Doe'
  };
}

app.listen(3000, () => {
  console.log('External portal API running on port 3000');
});
```

**Example: Python/Flask**

```python
from flask import Flask, request, jsonify
import os

app = Flask(__name__)

def validate_api_key():
    api_key = request.headers.get('X-API-Key')
    if api_key != os.getenv('ACORN_TRAVELS_API_KEY'):
        return False
    return True

@app.route('/api/validate-session', methods=['POST'])
def validate_session():
    if not validate_api_key():
        return jsonify({
            'success': False,
            'message': 'Invalid API key'
        }), 403
    
    data = request.json
    user_id = data.get('userId')
    session_token = data.get('sessionToken')
    
    try:
        # Your logic to validate the session
        session = validate_session_in_your_system(user_id, session_token)
        
        if not session or not session.get('isValid'):
            return jsonify({
                'success': False,
                'message': 'Invalid or expired session'
            }), 401
        
        # Get user details
        user = get_user_details(user_id)
        
        return jsonify({
            'success': True,
            'data': {
                'userId': user['id'],
                'email': user['email'],
                'name': user['name'],
                'isValid': True
            }
        })
    except Exception as e:
        print(f'Session validation error: {e}')
        return jsonify({
            'success': False,
            'message': 'Internal server error'
        }), 500

def validate_session_in_your_system(user_id, session_token):
    # Implement your session validation logic
    return {'isValid': True, 'userId': user_id}

def get_user_details(user_id):
    # Fetch user from your database
    return {
        'id': user_id,
        'email': 'user@example.com',
        'name': 'John Doe'
    }

if __name__ == '__main__':
    app.run(port=3000)
```

### Step 3: Generate SSO Login Links

When a user wants to access ACORN Travels from your portal, generate a login link.

**Example: JavaScript**

```javascript
function generateACORNTravelsLink(userId) {
  // Get current user's session token
  const sessionToken = getCurrentUserSessionToken();
  
  // Generate the SSO link
  const baseUrl = 'https://acorn-travels.com/sso-login';
  const params = new URLSearchParams({
    userId: userId,
    sessionToken: sessionToken
  });
  
  return `${baseUrl}?${params.toString()}`;
}

// Usage in your application
function renderACORNTravelsButton(userId) {
  const link = generateACORNTravelsLink(userId);
  
  return `
    <a href="${link}" 
       target="_blank" 
       class="btn btn-primary">
      Access ACORN Travels
    </a>
  `;
}
```

**Example: React Component**

```jsx
import React from 'react';

function ACORNTravelsButton({ userId, sessionToken }) {
  const handleClick = () => {
    const params = new URLSearchParams({
      userId: userId,
      sessionToken: sessionToken
    });
    
    const url = `https://acorn-travels.com/sso-login?${params.toString()}`;
    window.open(url, '_blank');
  };
  
  return (
    <button 
      onClick={handleClick}
      className="acorn-travels-button"
    >
      Access ACORN Travels
    </button>
  );
}

export default ACORNTravelsButton;
```

**Example: Python**

```python
from urllib.parse import urlencode

def generate_acorn_travels_link(user_id, session_token):
    base_url = 'https://acorn-travels.com/sso-login'
    params = {
        'userId': user_id,
        'sessionToken': session_token
    }
    
    query_string = urlencode(params)
    return f'{base_url}?{query_string}'

# Usage
user_id = '123'
session_token = get_current_user_session_token()
link = generate_acorn_travels_link(user_id, session_token)
print(f'ACORN Travels Link: {link}')
```

## Integration Checklist

- [ ] Configure API credentials
- [ ] Implement session validation endpoint
- [ ] Test session validation with ACORN Travels team
- [ ] Create initial CSAs and customers via API
- [ ] Generate SSO login links in your application
- [ ] Test end-to-end SSO flow
- [ ] Set up error handling and logging
- [ ] Configure production environment variables
- [ ] Implement session token security best practices
- [ ] Document integration for your team

## Best Practices

### Security

1. **Use HTTPS Only**: All SSO communications must occur over HTTPS in production
2. **Session Token Security**:
   - Use cryptographically secure session tokens
   - Implement reasonable token expiration (15-30 minutes recommended)
   - Invalidate tokens after use if possible
3. **API Key Protection**:
   - Store API keys in environment variables
   - Never commit API keys to version control
   - Rotate API keys periodically
4. **Rate Limiting**:
   - Implement rate limiting on your session validation endpoint
   - Monitor for unusual activity patterns

### User Experience

1. **Clear Communication**: Inform users they're being redirected to ACORN Travels
2. **Handle Errors Gracefully**: 
   - Show user-friendly error messages
   - Provide alternative login methods
   - Log errors for debugging
3. **Session Synchronization**:
   - Ensure session states are synchronized
   - Handle session expiration appropriately

### Monitoring

1. **Log All SSO Attempts**: Track successful and failed SSO attempts
2. **Monitor API Usage**: Keep track of API endpoint usage and errors
3. **Alert on Failures**: Set up alerts for high failure rates

## Common Issues and Solutions

### Issue: "Failed to validate session with external portal"

**Possible Causes:**
- Session validation endpoint is down
- API key is incorrect
- Network connectivity issues
- Session token format is invalid

**Solutions:**
- Verify endpoint is accessible
- Check API key configuration
- Review endpoint logs
- Validate session token format

### Issue: Users getting "User not found" error

**Possible Causes:**
- User hasn't been created in ACORN Travels system
- Email mismatch between systems

**Solutions:**
- Ensure user was created via `/api/v1/sso/create-csa`
- Verify email addresses match exactly
- Check ACORN Travels database

### Issue: Session tokens expiring too quickly

**Possible Causes:**
- Session timeout too short
- Token validation timing issues

**Solutions:**
- Increase session timeout duration
- Implement token refresh mechanism
- Coordinate timing with ACORN Travels team

## Testing

### Test Endpoints

Use the following test endpoints provided by ACORN Travels:

- Development: `http://localhost:8000/api/v1/sso`
- Staging: `https://staging-api.acorntravels.com/api/v1/sso`
- Production: `https://api.acorntravels.com/api/v1/sso`

### Test Data

For testing, you can use these sample credentials:

```javascript
const testData = {
  csaName: 'Test CSA',
  csaEmail: 'test.csa@acorntravels.com',
  csaMobile: '+1234567890',
  customers: [
    {
      name: 'Test Customer',
      email: 'test.customer@example.com'
    }
  ]
};
```

### Postman Collection

Request a Postman collection from the ACORN Travels team for easy API testing.

## Support

For integration support, contact:

- **Technical Support**: dev@acorntravels.com
- **API Issues**: api-support@acorntravels.com
- **Emergency**: +1-XXX-XXX-XXXX

## Appendix

### Complete Integration Example

Here's a complete example of integrating SSO in a Node.js/Express application:

```javascript
const express = require('express');
const axios = require('axios');
const session = require('express-session');

const app = express();
app.use(express.json());
app.use(session({
  secret: 'your-session-secret',
  resave: false,
  saveUninitialized: false
}));

// Configuration
const ACORN_API_URL = 'https://api.acorntravels.com/api/v1';
const ACORN_API_KEY = process.env.ACORN_API_KEY;
const ACORN_TRAVELS_API_KEY = process.env.ACORN_TRAVELS_API_KEY;

// Create CSA when a new agent is registered in your system
app.post('/api/agents/create', async (req, res) => {
  const { name, email, mobile, customers } = req.body;
  
  try {
    const response = await axios.post(
      `${ACORN_API_URL}/sso/create-csa`,
      {
        csaName: name,
        csaEmail: email,
        csaMobile: mobile,
        customers: customers
      },
      {
        headers: {
          'X-API-Key': ACORN_API_KEY
        }
      }
    );
    
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Session validation endpoint for ACORN Travels
app.post('/api/validate-session', (req, res) => {
  const apiKey = req.headers['x-api-key'];
  
  if (apiKey !== ACORN_TRAVELS_API_KEY) {
    return res.status(403).json({ success: false });
  }
  
  const { userId, sessionToken } = req.body;
  
  // Validate session (implement your logic)
  const user = validateUserSession(userId, sessionToken);
  
  if (user) {
    res.json({
      success: true,
      data: {
        userId: user.id,
        email: user.email,
        name: user.name,
        isValid: true
      }
    });
  } else {
    res.status(401).json({ success: false });
  }
});

// Generate ACORN Travels link
app.get('/api/acorn-travels-link', (req, res) => {
  const userId = req.session.userId;
  const sessionToken = req.session.token;
  
  const link = `https://acorn-travels.com/sso-login?userId=${userId}&sessionToken=${sessionToken}`;
  
  res.json({ link });
});

function validateUserSession(userId, sessionToken) {
  // Implement your session validation logic
  return {
    id: userId,
    email: 'user@example.com',
    name: 'John Doe'
  };
}

app.listen(3000);
```

## Change Log

- **v1.0** (2024-11-26): Initial SSO implementation
  - Session validation endpoint
  - CSA creation API
  - Frontend SSO login flow

