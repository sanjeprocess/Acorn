# SSO Architecture & Flow Diagrams

This document contains visual representations of the SSO implementation architecture and flows.

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         ACORN Travels System                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────────┐              ┌───────────────────┐            │
│  │                  │              │                   │            │
│  │   Frontend       │◄────────────►│    Backend        │            │
│  │   React/TS       │   REST API   │    Node.js        │            │
│  │                  │              │    Express        │            │
│  └────────┬─────────┘              └─────────┬─────────┘            │
│           │                                  │                       │
│           │                                  │                       │
│           ▼                                  ▼                       │
│  ┌──────────────────┐              ┌───────────────────┐            │
│  │  SSO Components  │              │  SSO Endpoints    │            │
│  │  - sso-login     │              │  - validate       │            │
│  │  - sign-up       │              │  - create-csa     │            │
│  │  - routing       │              │  - check-user     │            │
│  └──────────────────┘              └─────────┬─────────┘            │
│                                              │                       │
└──────────────────────────────────────────────┼───────────────────────┘
                                               │
                                               │ External API Call
                                               │
                                               ▼
                        ┌───────────────────────────────────┐
                        │   External Client Portal          │
                        ├───────────────────────────────────┤
                        │  - Session Management             │
                        │  - User Database                  │
                        │  - Validation Endpoint            │
                        │  - SSO Link Generation            │
                        └───────────────────────────────────┘
```

## Component Interaction Diagram

```
┌─────────────┐         ┌─────────────┐         ┌──────────────┐
│   Browser   │         │   ACORN     │         │   External   │
│   (User)    │         │   Backend   │         │   Portal     │
└──────┬──────┘         └──────┬──────┘         └──────┬───────┘
       │                       │                       │
       │  1. Click SSO Link    │                       │
       ├──────────────────────►│                       │
       │  (userId+token)        │                       │
       │                       │                       │
       │                       │  2. Validate Session  │
       │                       ├──────────────────────►│
       │                       │   (userId+token)      │
       │                       │                       │
       │                       │  3. Session Valid     │
       │                       │◄──────────────────────┤
       │                       │   (user data)         │
       │                       │                       │
       │                       │  4. Check User DB     │
       │                       ├───────┐               │
       │                       │       │               │
       │                       │◄──────┘               │
       │                       │                       │
       │  5. JWT Tokens        │                       │
       │◄──────────────────────┤                       │
       │  + isFirstTimeLogin   │                       │
       │                       │                       │
       │  6. Route User        │                       │
       ├───────┐               │                       │
       │       │               │                       │
       │◄──────┘               │                       │
       │  (/user or /sign-up)  │                       │
       │                       │                       │
```

## Flow 1: Existing User SSO Login

```
┌──────────┐
│  Start   │
└────┬─────┘
     │
     ▼
┌─────────────────────────────────┐
│ User clicks SSO link in         │
│ External Portal                  │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│ Frontend: Parse URL parameters  │
│ (userId, sessionToken)           │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│ Call: POST /sso/validate-session│
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│ Backend: Validate with External │
│ Portal API                       │
└────────────┬────────────────────┘
             │
             ▼
        ┌────┴────┐
        │ Valid?  │
        └────┬────┘
             │
      ┌──────┴──────┐
      │             │
      ▼             ▼
   ┌─────┐      ┌──────┐
   │ No  │      │ Yes  │
   └──┬──┘      └───┬──┘
      │             │
      ▼             ▼
┌──────────┐  ┌────────────────────┐
│  Error   │  │ Check if user has  │
│ Message  │  │ password set       │
└──────────┘  └─────────┬──────────┘
                        │
                   ┌────┴────┐
                   │Password?│
                   └────┬────┘
                        │
                 ┌──────┴──────┐
                 │             │
                 ▼             ▼
             ┌──────┐      ┌──────┐
             │ Yes  │      │  No  │
             └───┬──┘      └───┬──┘
                 │             │
                 ▼             ▼
        ┌─────────────┐  ┌──────────────┐
        │Generate JWT │  │ Generate JWT │
        │isFirstTime: │  │ isFirstTime: │
        │   false     │  │    true      │
        └──────┬──────┘  └──────┬───────┘
               │                │
               ▼                ▼
        ┌────────────┐   ┌──────────────┐
        │ Redirect   │   │  Redirect    │
        │ to /user   │   │ to /sign-up  │
        └──────┬─────┘   └──────┬───────┘
               │                │
               └────────┬───────┘
                        │
                        ▼
                   ┌─────────┐
                   │   End   │
                   └─────────┘
```

## Flow 2: External App Creates CSA

```
┌──────────────────┐
│  External App    │
└────────┬─────────┘
         │
         ▼
┌─────────────────────────────────┐
│ POST /sso/create-csa             │
│ Headers: X-API-Key               │
│ Body: CSA + Customers data       │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│ Backend: Validate API Key        │
└────────────┬────────────────────┘
             │
             ▼
        ┌────┴────┐
        │ Valid?  │
        └────┬────┘
             │
      ┌──────┴──────┐
      │             │
      ▼             ▼
   ┌─────┐      ┌──────┐
   │ No  │      │ Yes  │
   └──┬──┘      └───┬──┘
      │             │
      ▼             ▼
┌──────────┐  ┌────────────────────┐
│ 403      │  │ Check if CSA       │
│ Error    │  │ already exists     │
└──────────┘  └─────────┬──────────┘
                        │
                   ┌────┴────┐
                   │ Exists? │
                   └────┬────┘
                        │
                 ┌──────┴──────┐
                 │             │
                 ▼             ▼
             ┌──────┐      ┌──────────┐
             │ Yes  │      │   No     │
             └───┬──┘      └───┬──────┘
                 │             │
                 ▼             ▼
        ┌─────────────┐  ┌──────────────┐
        │ Use Existing│  │ Create New   │
        │    CSA      │  │    CSA       │
        └──────┬──────┘  └──────┬───────┘
               │                │
               └────────┬───────┘
                        │
                        ▼
           ┌─────────────────────────┐
           │ For each customer:      │
           │ - Check if exists       │
           │ - Create if not exists  │
           │ - Track results         │
           └────────────┬────────────┘
                        │
                        ▼
           ┌─────────────────────────┐
           │ Return Summary:         │
           │ - Created customers     │
           │ - Existing customers    │
           │ - Failed customers      │
           └────────────┬────────────┘
                        │
                        ▼
                   ┌─────────┐
                   │   End   │
                   └─────────┘
```

## Data Flow Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                     External Portal                            │
│                                                                 │
│  ┌──────────┐         ┌────────────┐       ┌──────────────┐  │
│  │   User   │────────►│  Session   │──────►│  Generate    │  │
│  │  Clicks  │         │   Token    │       │  SSO Link    │  │
│  └──────────┘         └────────────┘       └──────┬───────┘  │
│                                                    │           │
└────────────────────────────────────────────────────┼───────────┘
                                                     │
                                                     │ userId
                                                     │ sessionToken
                                                     ▼
┌────────────────────────────────────────────────────────────────┐
│                    ACORN Travels Frontend                       │
│                                                                 │
│  ┌──────────────┐      ┌───────────────┐    ┌──────────────┐ │
│  │Parse URL     │─────►│  Validate     │───►│   Store      │ │
│  │Parameters    │      │  Session API  │    │   Tokens     │ │
│  └──────────────┘      └───────┬───────┘    └──────┬───────┘ │
│                                │                    │          │
└────────────────────────────────┼────────────────────┼──────────┘
                                 │                    │
                                 ▼                    │
┌────────────────────────────────────────────────────┼───────────┐
│                    ACORN Travels Backend           │           │
│                                                     │           │
│  ┌──────────────┐      ┌───────────────┐    ┌─────▼──────────┐│
│  │ SSO          │─────►│  Validate     │───►│  Generate JWT  ││
│  │ Controller   │      │  with Portal  │    │  Tokens        ││
│  └──────────────┘      └───────┬───────┘    └────────────────┘│
│                                │                               │
│                                ▼                               │
│                       ┌─────────────────┐                      │
│                       │  Check User DB  │                      │
│                       └────────┬────────┘                      │
│                                │                               │
└────────────────────────────────┼───────────────────────────────┘
                                 │
                                 ▼
                        ┌─────────────────┐
                        │   MongoDB       │
                        │   - Customers   │
                        │   - CSAs        │
                        └─────────────────┘
```

## Security Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                     Security Layers                           │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  Layer 1: HTTPS/TLS                                          │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  All communications encrypted in transit               │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                               │
│  Layer 2: Rate Limiting                                      │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  - 100 requests per 15 minutes (general)              │ │
│  │  - Lower limits on auth endpoints                      │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                               │
│  Layer 3: Authentication                                     │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  - API Key validation (external apps)                 │ │
│  │  - Session token validation (SSO)                     │ │
│  │  - JWT tokens (authenticated users)                   │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                               │
│  Layer 4: Input Validation                                   │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  - Email format validation                            │ │
│  │  - Required field checks                              │ │
│  │  - Data type validation                               │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                               │
│  Layer 5: Database Security                                  │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  - Password hashing (bcrypt)                          │ │
│  │  - Parameterized queries                              │ │
│  │  - Access control                                     │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

## Database Schema Relationships

```
┌─────────────────────────────────────────────────────────────┐
│                    Database Schema                           │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────┐
│         CSA             │
├─────────────────────────┤
│ csaId (PK)              │◄──────┐
│ name                    │       │
│ email (unique)          │       │
│ mobile                  │       │
│ password (hashed)       │       │
│ customers (array)       │       │
│ createdAt               │       │
│ updatedAt               │       │
└─────────────────────────┘       │
                                  │
                                  │ 1:N
                                  │ (csa field)
                                  │
┌─────────────────────────┐       │
│      Customer           │       │
├─────────────────────────┤       │
│ customerId (PK)         │       │
│ name                    │       │
│ email (unique)          │       │
│ password (nullable)     │───────┘
│ csa (FK) ───────────────┘
│ incidents (array)       │
│ notifications (array)   │
│ feedbacks (array)       │
│ travelHistory (array)   │
│ createdAt               │
│ updatedAt               │
└─────────────────────────┘

Notes:
- password is NULL for customers created via SSO
  until they complete registration
- csa field links to CSA.csaId
```

## Mermaid Diagrams

If your markdown renderer supports Mermaid, here are interactive diagrams:

### SSO Login Sequence Diagram

```mermaid
sequenceDiagram
    participant U as User
    participant EP as External Portal
    participant AF as ACORN Frontend
    participant AB as ACORN Backend
    participant EPA as External Portal API
    participant DB as Database

    U->>EP: Access ACORN Travels
    EP->>EP: Generate session token
    EP->>U: Redirect with SSO link
    U->>AF: Click link (userId+token)
    AF->>AF: Parse URL parameters
    AF->>AB: POST /sso/validate-session
    AB->>EPA: Validate session
    EPA->>AB: User data + valid status
    AB->>DB: Check user exists
    DB->>AB: User record
    AB->>AB: Generate JWT tokens
    AB->>AF: JWT + isFirstTimeLogin flag
    
    alt First time login
        AF->>AF: Route to /sign-up
        U->>AF: Set password + mobile
        AF->>AB: PATCH /updateCustomerPassword
        AB->>DB: Update customer
        DB->>AB: Success
        AB->>AF: Success response
        AF->>AF: Route to /user
    else Regular login
        AF->>AF: Route to /user
    end
    
    AF->>U: Show dashboard
```

### CSA Creation Flow

```mermaid
flowchart TD
    A[External App] -->|POST /sso/create-csa| B{Validate API Key}
    B -->|Invalid| C[Return 403 Error]
    B -->|Valid| D{CSA Exists?}
    D -->|Yes| E[Use Existing CSA]
    D -->|No| F[Create New CSA]
    E --> G[Process Customers]
    F --> G
    G --> H{For Each Customer}
    H -->|Check| I{Customer Exists?}
    I -->|Yes| J[Add to Existing List]
    I -->|No| K[Create Customer]
    K --> L{Created?}
    L -->|Yes| M[Add to Created List]
    L -->|No| N[Add to Failed List]
    J --> O[Continue]
    M --> O
    N --> O
    O --> P{More Customers?}
    P -->|Yes| H
    P -->|No| Q[Return Summary]
    Q --> R[End]
```

### System Component Interaction

```mermaid
graph TB
    subgraph "External Portal"
        EP[External Portal]
        EPAPI[Validation API]
    end
    
    subgraph "ACORN Travels Frontend"
        SL[SSO Login View]
        SU[Sign Up View]
        LP[Landing Page]
    end
    
    subgraph "ACORN Travels Backend"
        SSO[SSO Controller]
        AUTH[Auth Middleware]
        APIK[API Key Middleware]
    end
    
    subgraph "Database"
        CSA[CSA Collection]
        CUST[Customer Collection]
    end
    
    EP -.->|Generate SSO Link| SL
    SL -->|Validate Session| SSO
    SSO -->|Check Session| EPAPI
    SSO -->|Query User| CUST
    SSO -->|First Time?| SU
    SSO -->|Authenticated| LP
    SU -->|Update Password| AUTH
    AUTH -->|Update| CUST
    EP -->|Create CSA| APIK
    APIK -->|Validated| SSO
    SSO -->|Create/Update| CSA
    SSO -->|Create| CUST
    
    style EP fill:#e1f5ff
    style EPAPI fill:#e1f5ff
    style SL fill:#fff4e1
    style SU fill:#fff4e1
    style LP fill:#fff4e1
    style SSO fill:#e8f5e9
    style AUTH fill:#e8f5e9
    style APIK fill:#e8f5e9
    style CSA fill:#f3e5f5
    style CUST fill:#f3e5f5
```

---

## Legend

```
┌─────────┐
│Component│  = System component or module
└─────────┘

    │
    ▼         = Data/Control flow

───────►     = Direct communication

··········►  = Indirect/Optional communication

┌────────┐
│ Decision│  = Conditional logic
└────────┘

[Database]   = Data storage
```

## Notes

1. All diagrams show the happy path. Error handling flows are omitted for clarity.
2. External Portal API details may vary based on implementation.
3. Database schema shows only SSO-relevant fields.
4. Mermaid diagrams require a Mermaid-compatible renderer to display properly.

---

**Last Updated**: November 26, 2024  
**Version**: 1.0.0

