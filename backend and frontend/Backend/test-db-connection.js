import dotenv from "dotenv";
import connectDB from "./database/dbConnection.js";

// Load environment variables
dotenv.config();

console.log("🧪 Testing MongoDB connection...");
console.log("=".repeat(50));

// Check environment variables
console.log("📋 Environment Check:");
console.log("MongoDB URL:", process.env.MONGO_DB_URL ? "✅ Set" : "❌ Missing");
console.log("Database Name:", process.env.DB_NAME || "❌ Missing");
console.log("App Name:", process.env.APP_NAME || "❌ Missing");

// Check if it's Atlas or local
const isAtlas = process.env.MONGO_DB_URL && process.env.MONGO_DB_URL.includes('mongodb+srv://');
console.log("Connection Type:", isAtlas ? "🌐 MongoDB Atlas" : "🏠 Local MongoDB");

if (isAtlas) {
  console.log("\n⚠️  Atlas Connection Detected!");
  console.log("Make sure your IP is whitelisted in MongoDB Atlas:");
  console.log("1. Go to https://cloud.mongodb.com/");
  console.log("2. Select your project → Security → Network Access");
  console.log("3. Add your current IP address");
  console.log("4. Or use 'Allow Access from Anywhere' (0.0.0.0/0) for development");
}

console.log("\n" + "=".repeat(50));

// Test the connection
connectDB()
  .then(() => {
    console.log("\n✅ MongoDB connection test successful!");
    console.log("🎉 You can now start your application with: npm run dev");
    process.exit(0);
  })
  .catch((error) => {
    console.error("\n❌ MongoDB connection test failed!");
    console.error("Error details:", error.message);
    
    if (isAtlas && error.message.includes('whitelist')) {
      console.error("\n🔧 Atlas IP Whitelist Issue:");
      console.error("1. Check your IP address: curl ifconfig.me");
      console.error("2. Add your IP to MongoDB Atlas Network Access");
      console.error("3. Wait 2-3 minutes for changes to take effect");
    }
    
    process.exit(1);
  });
