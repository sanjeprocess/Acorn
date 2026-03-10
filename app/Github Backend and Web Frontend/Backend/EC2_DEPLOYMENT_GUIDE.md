# Step-by-Step Guide: Deploy ACORN Travels Backend on AWS EC2

This guide walks you through deploying the ACORN Travels backend on an Amazon EC2 instance.

---

## Prerequisites

- **AWS account** with console access
- **MongoDB Atlas** cluster (or another MongoDB instance)
- **SSH client** (Terminal on macOS/Linux, or PuTTY on Windows)
- Your **backend code** in a Git repo (GitHub, GitLab, etc.) or a way to copy files to the server

---

## Part 1: Create and Configure the EC2 Instance

### Step 1: Launch an EC2 Instance

1. Log in to the **AWS Console** → **EC2** → **Instances** → **Launch instance**.

2. **Name:** e.g. `acorn-travels-backend`.

3. **AMI:** Choose **Ubuntu Server 22.04 LTS**.

4. **Instance type:**  
   - **t2.micro** (free tier) for light traffic  
   - **t2.small** or **t3.small** for production.

5. **Key pair:**
   - Create a new key pair or use an existing one.
   - Download the `.pem` file and store it safely (e.g. `~/.ssh/acorn-backend.pem`).
   - On your machine: `chmod 400 ~/.ssh/acorn-backend.pem`.

6. **Network settings:**
   - Create a **security group** (or use an existing one).
   - Add these rules:

   | Type        | Port | Source        | Purpose              |
   |------------|------|---------------|----------------------|
   | SSH        | 22   | Your IP only  | SSH access           |
   | Custom TCP | 8000 | 0.0.0.0/0     | Backend API (or use 80 with Nginx) |

   For production, restrict **Source** to your load balancer or known IPs instead of `0.0.0.0/0` where possible.

7. **Storage:** 8–20 GB is usually enough.

8. Click **Launch instance**.

---

### Step 2: Get the Instance Public IP

1. In **EC2 → Instances**, select your instance.
2. Copy the **Public IPv4 address** (e.g. `3.110.xxx.xxx`).

---

### Step 3: Connect via SSH

From your **local machine** (replace paths and key name with yours):

```bash
ssh -i ~/.ssh/acorn-backend.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

If you see a prompt about the host key, type `yes`. You should land on the Ubuntu server.

---

## Part 2: Set Up the Server

### Step 4: Update the System

```bash
sudo apt update && sudo apt upgrade -y
```

---

### Step 5: Install Node.js 18

Your backend requires Node.js `>=18` (see `package.json`).

```bash
# Add NodeSource repository for Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -

# Install Node.js
sudo apt install -y nodejs

# Verify
node -v   # Should show v18.x.x
npm -v
```

---

### Step 6: Install Git

```bash
sudo apt install -y git
```

---

## Part 3: Deploy the Backend Application

### Step 7: Clone Your Repository (or Upload Code)

**Option A – Clone from Git (recommended):**

```bash
cd /home/ubuntu
git clone https://github.com/YOUR_ORG/ACORN-Travels-Mobile-App.git
cd ACORN-Travels-Mobile-App/Backend
```

**Option B – Upload with SCP from your machine:**

```bash
# From your LOCAL machine (not on EC2)
scp -i ~/.ssh/acorn-backend.pem -r /path/to/ACORN-Travels-Mobile-App/Backend ubuntu@YOUR_EC2_IP:/home/ubuntu/
```

Then on EC2:

```bash
cd /home/ubuntu/Backend
```

---

### Step 8: Create Environment File

Create a `.env` file with all required variables. **Do not commit this file.**

```bash
nano .env
```

Paste and fill in your values (no quotes around values unless the value itself contains spaces):

```env
# Server
NODE_ENV=production
PORT=8000

# MongoDB (required)
MONGO_DB_URL=mongodb+srv://USER:PASSWORD@cluster.xxxxx.mongodb.net
DB_NAME=prod
APP_NAME=acorn-travels-backend

# JWT (required)
JWT_SECRET=your-strong-jwt-secret-min-32-chars
JWT_EXPIRE=30d
ACCESS_TOKEN_SECRET=your-access-token-secret
REFRESH_TOKEN_SECRET=your-refresh-token-secret

# SSO / External API (required for SSO)
EXTERNAL_APP_API_KEY=your-external-app-api-key

# CORS – add your frontend and app URLs
ALLOWED_ORIGINS=https://acorn-portal.netlify.app,https://wallet.acorn.lk,https://your-app.com

# Optional: Email (EmailJS)
EMAILJS_SERVICE_ID=your-service-id
EMAILJS_TEMPLATE_ID=your-template-id
EMAILJS_PUBLIC_KEY=your-public-key
EMAILJS_PRIVATE_KEY=your-private-key

# Optional: WorkHub24
WORKHUB24_CLIENT_ID=your-client-id
WORKHUB24_CLIENT_SECRET=your-client-secret
WORKHUB24_AUTH_URL=https://app.workhub24.com/api/auth/token
WORKHUB24_CARD_URL=https://app.workhub24.com/api/workflows/.../cards

# Optional: Firebase (if used)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY_ID=your-private-key-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your-service-account@project.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your-client-id
FIREBASE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
FIREBASE_TOKEN_URI=https://oauth2.googleapis.com/token
FIREBASE_AUTH_PROVIDER_X509_CERT_URL=https://www.googleapis.com/oauth2/v1/certs
FIREBASE_CLIENT_X509_CERT_URL=https://www.googleapis.com/robot/v1/metadata/x509/...
FIREBASE_UNIVERSE_DOMAIN=googleapis.com
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
```

Save and exit: `Ctrl+O`, `Enter`, then `Ctrl+X`.

Restrict permissions:

```bash
chmod 600 .env
```

---

### Step 9: Install Dependencies and Test

```bash
npm install
```

Optional quick checks:

```bash
npm run test-db
```

If that succeeds, try starting the app manually:

```bash
npm start
```

You should see something like:

- `🚀 Server running on port 8000`
- `MongoDB connected to ...`

Stop the server with `Ctrl+C` before continuing.

---

## Part 4: Run the App with PM2 (Always On)

PM2 keeps the Node process running and restarts it if it crashes.

### Step 10: Install PM2

```bash
sudo npm install -g pm2
```

### Step 11: Start the App with PM2

```bash
cd /home/ubuntu/ACORN-Travels-Mobile-App/Backend
# Or: cd /home/ubuntu/Backend if you uploaded only Backend

pm2 start index.js --name "acorn-backend"
```

Useful PM2 commands:

```bash
pm2 status              # List processes
pm2 logs acorn-backend  # View logs
pm2 restart acorn-backend
pm2 stop acorn-backend
```

### Step 12: Start PM2 on Boot

```bash
pm2 startup
# Run the command it prints (e.g. sudo env PATH=...)

pm2 save
```

After a reboot, the backend should start automatically.

---

## Part 5: Open the API to the Internet

- If you opened **port 8000** in the security group (Step 1), the API is reachable at:
  - `http://YOUR_EC2_PUBLIC_IP:8000`
- Test health:
  - `http://YOUR_EC2_PUBLIC_IP:8000/api/v1/health`

---

## Part 6 (Optional): Nginx Reverse Proxy and HTTPS

Using Nginx gives you:

- Serve on port 80/443
- Optional SSL with Let’s Encrypt
- Single place to add headers or rate limiting later

### Install Nginx

```bash
sudo apt install -y nginx
```

### Create Nginx Config

```bash
sudo nano /etc/nginx/sites-available/acorn-backend
```

Paste (replace `YOUR_DOMAIN_OR_IP` with your domain or EC2 public IP):

```nginx
server {
    listen 80;
    server_name YOUR_DOMAIN_OR_IP;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Enable the site and test:

```bash
sudo ln -s /etc/nginx/sites-available/acorn-backend /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

- Open **port 80** (and **443** if using SSL) in the EC2 security group.
- API base URL becomes: `http://YOUR_DOMAIN_OR_IP` (e.g. `http://YOUR_DOMAIN_OR_IP/api/v1/health`).

### Optional: HTTPS with Let’s Encrypt (only if you have a domain)

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

Follow the prompts. Certbot will configure Nginx for HTTPS and auto-renewal.

---

## Part 7: MongoDB Atlas (If You Use Atlas)

1. In **MongoDB Atlas** → your project → **Network Access**.
2. **Add IP Address**.
3. Either:
   - Add your **EC2 instance public IP**, or  
   - For simplicity in dev: **Allow access from anywhere** `0.0.0.0/0` (tighten this in production).
4. Ensure the database user and password in `MONGO_DB_URL` in `.env` are correct and have read/write access to the database.

---

## Checklist Summary

| Step | Action |
|------|--------|
| 1 | Launch EC2 (Ubuntu 22.04, open SSH + 8000 or 80/443) |
| 2 | SSH in and run `apt update && apt upgrade` |
| 3 | Install Node.js 18 and Git |
| 4 | Clone or upload Backend code |
| 5 | Create `.env` with all required variables |
| 6 | Run `npm install` and optionally `npm run test-db` |
| 7 | Start app with PM2 and run `pm2 startup` + `pm2 save` |
| 8 | Whitelist EC2 IP in MongoDB Atlas (if using Atlas) |
| 9 | (Optional) Install Nginx and/or Certbot for HTTPS |

---

## Updating the Backend Later

```bash
cd /home/ubuntu/ACORN-Travels-Mobile-App/Backend
git pull
npm install
pm2 restart acorn-backend
```

---

## Troubleshooting

| Issue | What to check |
|-------|----------------|
| **Cannot SSH** | Security group allows port 22 from your IP; key has correct permissions (`chmod 400 .pem`). |
| **API not reachable** | Security group allows 8000 (or 80/443); PM2 is running (`pm2 status`). |
| **MongoDB connection error** | `.env` has correct `MONGO_DB_URL`, `DB_NAME`, `APP_NAME`; Atlas Network Access includes EC2 IP. |
| **502 Bad Gateway (Nginx)** | Backend is listening on 8000: `pm2 status` and `pm2 logs acorn-backend`. |
| **CORS errors** | Add your frontend origin to `ALLOWED_ORIGINS` in `.env` and restart: `pm2 restart acorn-backend`. |

---

## Security Reminders

- Prefer **restricting** SSH and API ports to known IPs in production.
- Use **strong secrets** for `JWT_SECRET`, `EXTERNAL_APP_API_KEY`, etc.
- Never commit `.env`; keep it only on the server.
- Prefer a **domain + HTTPS** (Certbot) for production.

---

For required environment variables and app behavior, see:

- `ENVIRONMENT_SETUP.md`
- `RENDER_DEPLOYMENT_GUIDE.md` (same variables apply)
