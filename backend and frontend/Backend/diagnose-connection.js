import dotenv from "dotenv";

// Load environment variables
dotenv.config();

console.log("🔍 MongoDB Atlas Connection Diagnostic");
console.log("=".repeat(60));

// Check environment variables
console.log("📋 Environment Variables:");
console.log("MONGO_DB_URL:", process.env.MONGO_DB_URL ? "✅ Set" : "❌ Missing");
console.log("DB_NAME:", process.env.DB_NAME || "❌ Missing");
console.log("APP_NAME:", process.env.APP_NAME || "❌ Missing");

if (process.env.MONGO_DB_URL) {
  console.log("\n🔗 Connection String Analysis:");
  const url = process.env.MONGO_DB_URL;
  
  // Check if it's Atlas format
  const isAtlas = url.includes('mongodb+srv://');
  console.log("Is Atlas format:", isAtlas ? "✅ Yes" : "❌ No");
  
  if (isAtlas) {
    // Extract hostname
    const match = url.match(/mongodb\+srv:\/\/[^@]+@([^\/\?]+)/);
    if (match) {
      const hostname = match[1];
      console.log("Hostname:", hostname);
      
      // Check if hostname is correct
      if (hostname.endsWith('.mongodb.net')) {
        console.log("Hostname format:", "✅ Correct (.mongodb.net)");
      } else if (hostname.endsWith('.mongodb.netprod')) {
        console.log("Hostname format:", "❌ Incorrect (.mongodb.netprod)");
        console.log("🔧 Fix: Change to .mongodb.net");
      } else {
        console.log("Hostname format:", "❌ Unknown format");
      }
      
      // Check for common issues
      if (hostname.includes('cluster0')) {
        console.log("Cluster format:", "✅ Standard cluster0 format");
      } else {
        console.log("Cluster format:", "⚠️  Non-standard cluster name");
      }
    } else {
      console.log("❌ Could not parse hostname from connection string");
    }
    
    // Check for credentials
    const hasCredentials = url.includes('://') && url.includes('@');
    console.log("Has credentials:", hasCredentials ? "✅ Yes" : "❌ No");
    
    if (!hasCredentials) {
      console.log("🔧 Fix: Add username:password@ before the hostname");
    }
  }
}

console.log("\n📝 Expected Format:");
console.log("mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/");

console.log("\n🔧 Common Issues & Fixes:");
console.log("1. Wrong hostname ending: .mongodb.netprod → .mongodb.net");
console.log("2. Missing credentials: Add username:password@");
console.log("3. Missing trailing slash: Add / at the end");
console.log("4. IP not whitelisted: Add your IP to Atlas Network Access");

console.log("\n" + "=".repeat(60));
console.log("💡 Next Steps:");
console.log("1. Fix your connection string in .env file");
console.log("2. Run: npm run test-db");
console.log("3. If still failing, check IP whitelist in MongoDB Atlas");
