import admin from "firebase-admin";
import dotenv from "dotenv";

// Load environment variables
dotenv.config();

// Initialize Firebase using environment variables
admin.initializeApp({
  credential: admin.credential.cert({
    project_id: process.env.FIREBASE_PROJECT_ID,
    private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
    private_key: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"), // Fix line breaks
    client_email: process.env.FIREBASE_CLIENT_EMAIL,
    client_id: process.env.FIREBASE_CLIENT_ID,
    auth_uri: process.env.FIREBASE_AUTH_URI,
    token_uri: process.env.FIREBASE_TOKEN_URI,
    auth_provider_x509_cert_url:
      process.env.FIREBASE_AUTH_PROVIDER_X509_CERT_URL,
    client_x509_cert_url: process.env.FIREBASE_CLIENT_X509_CERT_URL,
    universe_domain: process.env.FIREBASE_UNIVERSE_DOMAIN,
  }),
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
});

export const bucket = admin.storage().bucket();

export const uploadFileToFirebase = async (file, fileName) => {
  try {
    // Validate file
    if (!file || !file.buffer) {
      throw new Error("Invalid file provided");
    }

    // Validate file size (10MB limit)
    const maxSize = 10 * 1024 * 1024; // 10MB
    if (file.buffer.length > maxSize) {
      throw new Error("File size exceeds 10MB limit");
    }

    const fileUpload = bucket.file(fileName);

    // Create write stream and upload the file
    const stream = fileUpload.createWriteStream({
      metadata: {
        contentType: file.mimetype || 'application/octet-stream',
        cacheControl: 'public, max-age=31536000', // 1 year cache
      },
      resumable: false, // For smaller files
    });

    stream.end(file.buffer);

    await new Promise((resolve, reject) => {
      stream.on("finish", resolve);
      stream.on("error", reject);
    });

    // Make file publicly accessible
    await fileUpload.makePublic();

    // Generate public URL
    const publicUrl = `https://storage.googleapis.com/${bucket.name}/${fileName}`;

    return publicUrl;
  } catch (error) {
    console.error("Error uploading to Firebase Storage:", error);
    throw new Error(`File upload failed: ${error.message}`);
  }
};

export const deleteFromFirebase = async (url) => {
  try {
    if (!url) {
      throw new Error("URL is required for file deletion");
    }

    // Get Firebase path from URL (e.g., "travels/hotels-123456.pdf")
    const path = decodeURIComponent(
      new URL(url).pathname.replace(/^\/[^/]+\//, "")
    );
    
    const file = admin.storage().bucket().file(path);
    
    // Check if file exists before attempting to delete
    const [exists] = await file.exists();
    if (!exists) {
      console.warn(`File does not exist: ${path}`);
      return; // Don't throw error if file doesn't exist
    }
    
    await file.delete();
    console.log(`Successfully deleted file: ${path}`);
  } catch (error) {
    console.error("Failed to delete file:", error.message);
    throw new Error(`File delete unsuccessful: ${error.message}`);
  }
};
