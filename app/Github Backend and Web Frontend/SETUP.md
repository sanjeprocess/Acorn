# ACORN Travels Mobile App - Setup Guide

## 🚀 Quick Start

### Prerequisites
- Node.js (v18 or higher)
- MongoDB (v6 or higher)
- Firebase project with Storage enabled
- Git

### Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd Backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Environment Configuration**
   ```bash
   cp env.example .env
   ```
   
   Update the `.env` file with your actual values:
   - MongoDB connection string
   - JWT secrets (generate strong random strings)
   - Firebase configuration
   - Server port and environment settings

4. **Start the development server**
   ```bash
   npm run dev
   ```

   The API will be available at `http://localhost:5000`

### Frontend Setup

1. **Navigate to frontend directory**
   ```bash
   cd Frontend
   ```

2. **Install dependencies**
   ```bash
   npm install
   # or
   yarn install
   ```

3. **Environment Configuration**
   ```bash
   cp env.example .env
   ```
   
   Update the `.env` file with your API URL:
   ```
   VITE_API_URL=http://localhost:5000/api/v1
   ```

4. **Start the development server**
   ```bash
   npm run dev
   # or
   yarn dev
   ```

   The app will be available at `http://localhost:3039`

## 🔧 Configuration

### Environment Variables

#### Backend (.env)
```env
# Database
MONGO_DB_URL=mongodb://localhost:27017
DB_NAME=acorn_travels
APP_NAME=acorn-travels-api

# JWT Secrets (generate strong random strings)
ACCESS_TOKEN_SECRET=your-access-token-secret
REFRESH_TOKEN_SECRET=your-refresh-token-secret

# Firebase
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your-client-email
FIREBASE_STORAGE_BUCKET=your-storage-bucket

# Server
PORT=5000
NODE_ENV=development
```

#### Frontend (.env)
```env
VITE_API_URL=http://localhost:5000/api/v1
VITE_APP_NAME=ACORN Travels
```

## 🗄️ Database Setup

1. **Start MongoDB**
   ```bash
   mongod
   ```

2. **Create database**
   ```bash
   mongo
   use acorn_travels
   ```

3. **The application will automatically create collections and indexes on first run**

## 🔥 Firebase Setup

1. **Create a Firebase project**
2. **Enable Storage**
3. **Generate service account key**
4. **Update environment variables with Firebase credentials**

## 📚 API Documentation

Once the backend is running, visit:
- Swagger UI: `http://localhost:5000/api-docs`
- Health Check: `http://localhost:5000/api/v1/health`

## 🧪 Testing

### Backend Tests
```bash
cd Backend
npm test
```

### Frontend Tests
```bash
cd Frontend
npm test
```

## 🚀 Production Deployment

### Backend
1. Set `NODE_ENV=production`
2. Use a production MongoDB instance
3. Configure proper CORS origins
4. Set up SSL certificates
5. Use a process manager like PM2

### Frontend
1. Build the application:
   ```bash
   npm run build
   ```
2. Deploy the `dist` folder to your hosting service
3. Configure environment variables for production

## 🔒 Security Checklist

- [ ] Change default JWT secrets
- [ ] Configure CORS properly
- [ ] Set up rate limiting
- [ ] Enable HTTPS in production
- [ ] Configure Firebase security rules
- [ ] Set up proper logging
- [ ] Configure environment-specific settings

## 📝 Available Scripts

### Backend
- `npm start` - Start production server
- `npm run dev` - Start development server with nodemon
- `npm test` - Run tests

### Frontend
- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint
- `npm run lint:fix` - Fix ESLint errors

## 🆘 Troubleshooting

### Common Issues

1. **MongoDB Connection Error**
   - Ensure MongoDB is running
   - Check connection string in .env
   - Verify database permissions

2. **Firebase Upload Error**
   - Verify Firebase credentials
   - Check storage bucket permissions
   - Ensure service account has proper roles

3. **JWT Token Error**
   - Verify JWT secrets are set
   - Check token expiry settings
   - Ensure proper token format

4. **CORS Error**
   - Update allowed origins in CORS configuration
   - Check frontend API URL

### Getting Help

- Check the logs in `Backend/logs/` directory
- Review browser console for frontend errors
- Check API documentation at `/api-docs`

## 📄 License

This project is licensed under the MIT License.
