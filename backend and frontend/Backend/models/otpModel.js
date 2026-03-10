import mongoose from "mongoose";
import mongooseSequence from "mongoose-sequence";

const AutoIncrement = mongooseSequence(mongoose);

// OTP Schema for password reset
const otpSchema = new mongoose.Schema({
  email: {
    type: String,
    required: [true, "Email is required"],
    lowercase: true,
    trim: true,
    index: true
  },
  otp: {
    type: String,
    required: [true, "OTP is required"],
    length: 6
  },
  type: {
    type: String,
    enum: ["PASSWORD_RESET", "EMAIL_VERIFICATION"],
    default: "PASSWORD_RESET"
  },
  userType: {
    type: String,
    enum: ["CSA", "Customer"],
    required: [true, "User type is required"]
  },
  isUsed: {
    type: Boolean,
    default: false
  },
  expiresAt: {
    type: Date,
    required: true
  },
  attempts: {
    type: Number,
    default: 0,
    max: 3
  }
}, {
  timestamps: true
});

// Add indexes for better query performance
otpSchema.index({ email: 1, type: 1 });
otpSchema.index({ email: 1, userType: 1 });
otpSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 }); // TTL index - removes document when expiresAt is reached

// Add sequence plugin
otpSchema.plugin(AutoIncrement, {
  inc_field: "otpId",
  id: "otps",
  start_seq: 1,
});

// Static method to generate OTP
otpSchema.statics.generateOTP = function() {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

// Static method to create OTP record
otpSchema.statics.createOTP = async function(email, userType, type = "PASSWORD_RESET") {
  // Invalidate any existing OTPs for this email
  await this.updateMany(
    { email, type, isUsed: false },
    { isUsed: true }
  );

  const otp = this.generateOTP();
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 2 minutes

  return await this.create({
    email,
    otp,
    type,
    userType,
    expiresAt
  });
};

// Instance method to verify OTP
otpSchema.methods.verifyOTP = function(inputOTP) {
  if (this.isUsed) {
    throw new Error("OTP has already been used");
  }
  
  if (this.expiresAt < new Date()) {
    throw new Error("OTP has expired");
  }
  
  if (this.attempts >= 3) {
    throw new Error("Maximum verification attempts exceeded");
  }
  
  if (this.otp !== inputOTP) {
    this.attempts += 1;
    throw new Error("Invalid OTP");
  }
  
  this.isUsed = true;
  return true;
};

export const OTP = mongoose.model("OTP", otpSchema);

