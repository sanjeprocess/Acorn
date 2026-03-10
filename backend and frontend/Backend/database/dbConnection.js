import mongoose from "mongoose";
import colors from "colors";

// Disable mongoose buffering globally for better error handling
mongoose.set('bufferCommands', false);

const connectDB = async () => {
  try {
    // Check if already connected
    if (mongoose.connection.readyState === 1) {
      console.log('MongoDB already connected'.bgGreen.black);
      return;
    }

    // Build connection URI - handle both local and Atlas connections
    let dbUri;
    if (process.env.MONGO_DB_URL.includes('mongodb+srv://')) {
      // MongoDB Atlas connection - check if database name is already in URL
      if (process.env.MONGO_DB_URL.includes('/' + process.env.DB_NAME)) {
        // Database name already in URL, just add query parameters
        dbUri = `${process.env.MONGO_DB_URL}?retryWrites=true&w=majority&appName=${process.env.APP_NAME}`;
      } else {
        // Add database name to URL
        const baseUrl = process.env.MONGO_DB_URL.endsWith('/') 
          ? process.env.MONGO_DB_URL.slice(0, -1) 
          : process.env.MONGO_DB_URL;
        dbUri = `${baseUrl}/${process.env.DB_NAME}?retryWrites=true&w=majority&appName=${process.env.APP_NAME}`;
      }
    } else {
      // Local MongoDB connection
      dbUri = `${process.env.MONGO_DB_URL}/${process.env.DB_NAME}?retryWrites=true&w=majority&appName=${process.env.APP_NAME}`;
    }
    
    const options = {
      maxPoolSize: 10, // Maintain up to 10 socket connections
      serverSelectionTimeoutMS: 30000, // Increased for Atlas (30 seconds)
      socketTimeoutMS: 45000, // Close sockets after 45 seconds of inactivity
      bufferCommands: false, // Disable mongoose buffering
      // Modern Mongoose options
      connectTimeoutMS: 30000, // Increased for Atlas (30 seconds)
      heartbeatFrequencyMS: 10000, // Send a ping every 10 seconds
      // Atlas-specific options
      retryWrites: true,
      w: 'majority',
      // Note: bufferMaxEntries is deprecated in newer Mongoose versions
      // Use bufferCommands: false instead
    };

    console.log('Attempting to connect to MongoDB...');
    console.log('Connection URI:', dbUri.replace(/\/\/.*@/, '//***:***@')); // Hide credentials in logs
    
    await mongoose.connect(dbUri, options);
    
    console.log(`MongoDB connected to ${mongoose.connection.host}`.bgCyan.black);
    console.log(`Database: ${mongoose.connection.name}`.bgCyan.black);
    
    // Handle connection events
    mongoose.connection.on('error', (err) => {
      console.error('MongoDB connection error:', err);
    });
    
    mongoose.connection.on('disconnected', () => {
      console.log('MongoDB disconnected'.bgYellow.black);
    });

    mongoose.connection.on('reconnected', () => {
      console.log('MongoDB reconnected'.bgGreen.black);
    });
    
    // Graceful shutdown
    process.on('SIGINT', async () => {
      try {
        await mongoose.connection.close();
        console.log('MongoDB connection closed through app termination'.bgRed.black);
        process.exit(0);
      } catch (err) {
        console.error('Error closing MongoDB connection:', err);
        process.exit(1);
      }
    });
    
  } catch (error) {
    console.error(`MongoDB connection error: ${error.message}`.bgRed.white);
    console.error('Full error:', error);
    process.exit(1);
  }
};

export default connectDB;