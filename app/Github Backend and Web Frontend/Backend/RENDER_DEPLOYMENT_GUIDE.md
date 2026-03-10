# 🚀 Render Deployment Guide for ACORN Travels Backend

## ✅ **Fixed Issues:**
- ✅ **Port Binding**: Server now binds to `0.0.0.0:PORT` for Render
- ✅ **Environment Detection**: Removed local-only condition
- ✅ **Proper Logging**: Added deployment-friendly console logs

## 🔧 **Required Environment Variables in Render:**

### **1. Database Configuration:**
```
MONGO_DB_URL=mongodb+srv://username:password@acornwallet.lkqu4.mongodb.net
DB_NAME=prod
APP_NAME=acorn-travels-backend
```

### **2. JWT Configuration:**
```
JWT_SECRET=your-super-secret-jwt-key-here
JWT_EXPIRE=30d
```

### **3. Email Configuration (if using email features):**
```
EMAILJS_SERVICE_ID=your-emailjs-service-id
EMAILJS_TEMPLATE_ID=your-emailjs-template-id
EMAILJS_PUBLIC_KEY=your-emailjs-public-key
EMAILJS_PRIVATE_KEY=your-emailjs-private-key
```

### **4. Firebase Configuration (if using Firebase):**
```
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_PRIVATE_KEY=your-firebase-private-key
FIREBASE_CLIENT_EMAIL=your-firebase-client-email
```

### **5. Optional Configuration:**
```
NODE_ENV=production
PORT=10000
```

## 📋 **Render Service Configuration:**

### **Build Command:**
```bash
npm install
```

### **Start Command:**
```bash
npm start
```

### **Node Version:**
```
18.0.0 or higher
```

## 🔍 **Health Check Endpoint:**
Your API will be available at:
```
https://your-render-app.onrender.com/api/v1/health
```

## 🚨 **Important Notes:**

1. **Port Binding**: The server now automatically binds to `process.env.PORT` on `0.0.0.0`
2. **MongoDB Connection**: Make sure your MongoDB Atlas allows connections from Render's IP ranges
3. **Environment Variables**: Set all required environment variables in Render dashboard
4. **Health Check**: Use `/api/v1/health` endpoint to verify deployment

## 🎯 **Deployment Steps:**

1. **Push your code** to GitHub
2. **Connect Render** to your GitHub repository
3. **Set environment variables** in Render dashboard
4. **Deploy** and monitor logs
5. **Test health endpoint** to verify deployment

## 🔧 **Troubleshooting:**

### **If you get "No open ports detected":**
- ✅ **Fixed**: Server now binds to `0.0.0.0:PORT`
- ✅ **Fixed**: Removed local-only condition

### **If MongoDB connection fails:**
- Check MongoDB Atlas IP whitelist (add `0.0.0.0/0` for testing)
- Verify environment variables are set correctly
- Check MongoDB connection string format

### **If JWT errors occur:**
- Ensure `JWT_SECRET` is set and is a strong secret
- Verify `JWT_EXPIRE` is set to a valid duration

## 🎉 **Success Indicators:**
- ✅ Server logs show "🚀 Server running on port XXXX"
- ✅ MongoDB connection successful
- ✅ Health endpoint returns 200 OK
- ✅ No "No open ports detected" errors
