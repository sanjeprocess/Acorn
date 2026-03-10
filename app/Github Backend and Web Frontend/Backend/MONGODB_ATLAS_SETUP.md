# 🌐 MongoDB Atlas Connection Setup

## 🚨 **Current Issue**
**Error**: `querySrv ENOTFOUND _mongodb._tcp.cluster0.85v4vl7.mongodb.netprod`

## 🔍 **Root Cause**
The MongoDB Atlas connection string is malformed. The hostname should end with `.mongodb.net` not `.mongodb.netprod`.

## ✅ **Solutions**

### **Solution 1: Fix Your Connection String (IMMEDIATE FIX)**

#### **Step 1: Check Your Current Connection String**
Your connection string appears to be malformed. It should look like this:
```
mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/
```

**NOT like this:**
```
mongodb+srv://username:password@cluster0.85v4vl7.mongodb.netprod/
```

#### **Step 2: Get the Correct Connection String from MongoDB Atlas**
1. **Login to MongoDB Atlas**: https://cloud.mongodb.com/
2. **Select your project** and cluster
3. **Click "Connect"**
4. **Choose "Connect your application"**
5. **Select "Node.js" as driver**
6. **Copy the connection string** - it should end with `.mongodb.net/`

#### **Step 3: Update Your .env File**
```env
# Correct format
MONGO_DB_URL=mongodb+srv://your-username:your-password@cluster0.xxxxx.mongodb.net/
DB_NAME=acorn_travels
APP_NAME=acorn-travels-api
```

### **Solution 2: Whitelist Your IP Address**

#### **Step 1: Get Your Current IP Address**
```bash
# Method 1: Using curl
curl ifconfig.me

# Method 2: Using wget
wget -qO- ifconfig.me

# Method 3: Using dig
dig +short myip.opendns.com @resolver1.opendns.com

# Method 4: Visit this website
# https://whatismyipaddress.com/
```

#### **Step 2: Add IP to MongoDB Atlas Whitelist**
1. **Login to MongoDB Atlas**: https://cloud.mongodb.com/
2. **Select your project** and cluster
3. **Go to Security → Network Access**
4. **Click "Add IP Address"**
5. **Choose one of these options**:
   - **Add Current IP Address** (recommended for development)
   - **Add IP Address** (enter the IP you got from Step 1)
   - **Allow Access from Anywhere** (0.0.0.0/0) - ⚠️ **Less secure, use only for development**

#### **Step 3: Wait for Changes to Take Effect**
- Changes can take up to 2-3 minutes to propagate
- You'll see a "Pending" status until it's active

### **Solution 2: Allow Access from Anywhere (Development Only)**

⚠️ **WARNING**: This is less secure and should only be used for development!

1. **In MongoDB Atlas Network Access**:
   - Click "Add IP Address"
   - Select "Allow Access from Anywhere"
   - Enter `0.0.0.0/0` as the IP address
   - Add a comment like "Development - All IPs"

### **Solution 3: Use MongoDB Atlas Connection String**

#### **Step 1: Get Your Connection String**
1. **In MongoDB Atlas**:
   - Go to your cluster
   - Click "Connect"
   - Choose "Connect your application"
   - Select "Node.js" as driver
   - Copy the connection string

#### **Step 2: Update Your Environment Variables**
```env
# Replace with your actual Atlas connection string
MONGO_DB_URL=mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/
DB_NAME=acorn_travels
APP_NAME=acorn-travels-api
```

#### **Step 3: Update Connection String Format**
The connection string should look like:
```
mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/acorn_travels?retryWrites=true&w=majority
```

## 🔧 **Updated Database Connection Configuration**

Let me update the database connection to better handle Atlas connections:
