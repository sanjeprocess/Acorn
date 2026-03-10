import mongoose from "mongoose";

/**
 * SSO Session Model
 * Stores cardId-based sessions with automatic expiration after 30 minutes
 * CardId is saved when WorkHub24 calls createCSAFromExternal
 */
const ssoSessionSchema = new mongoose.Schema(
  {
    cardId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    csaId: {
      type: Number,
      required: true,
      ref: 'CSA',
      index: true,
    },
    validatedAt: {
      type: Date,
      default: Date.now,
    },
    expiresAt: {
      type: Date,
      required: true,
      index: true,
    },
    isExpired: {
      type: Boolean,
      default: false,
      index: true,
    },
  },
  {
    timestamps: true,
  }
);

// Compound index for efficient lookups (including expired status)
ssoSessionSchema.index({ cardId: 1, isExpired: 1 });
ssoSessionSchema.index({ expiresAt: 1, isExpired: 1 });

// Compound index for efficient lookups
ssoSessionSchema.index({ cardId: 1, expiresAt: 1 });

// Method to check if session is expired by time (checks expiresAt, not the isExpired flag)
ssoSessionSchema.methods.hasExpiredByTime = function () {
  return Date.now() > this.expiresAt.getTime();
};

// Static method to mark sessions as expired based on expiresAt time
ssoSessionSchema.statics.markExpiredSessions = async function () {
  const now = new Date();
  const result = await this.updateMany(
    {
      isExpired: false,
      expiresAt: { $lt: now }, // Expired by time
    },
    {
      $set: { isExpired: true },
    }
  );
  
  return result.modifiedCount;
};

// Static method to find valid (non-expired) session by cardId
ssoSessionSchema.statics.findValidSessionByCardId = async function (cardId) {
  const session = await this.findOne({
    cardId,
    isExpired: false,
    expiresAt: { $gt: new Date() }, // Not expired
  });
  
  return session;
};

// Static method to find any session by cardId (including expired ones)
ssoSessionSchema.statics.findSessionByCardId = async function (cardId) {
  const session = await this.findOne({ cardId });
  return session;
};

// Static method to create or update session (refresh if expired)
ssoSessionSchema.statics.createOrUpdateSession = async function (sessionData) {
  const { cardId, csaId } = sessionData;
  
  if (!cardId || !csaId) {
    throw new Error('cardId and csaId are required');
  }
  
  // Calculate expiration (30 minutes from now)
  const expiresAt = new Date(Date.now() + 30 * 60 * 1000); // 30 minutes
  
  // Upsert - update if exists (including expired ones), create if not
  // This allows refreshing expired sessions
  const session = await this.findOneAndUpdate(
    { cardId },
    {
      cardId,
      csaId,
      validatedAt: new Date(),
      expiresAt,
      isExpired: false, // Mark as not expired when refreshed
    },
    {
      upsert: true,
      new: true,
      setDefaultsOnInsert: true,
    }
  );
  
  return session;
};

// Static method to mark session as expired (instead of deleting)
ssoSessionSchema.statics.markAsExpired = async function (cardId) {
  const session = await this.findOneAndUpdate(
    { cardId },
    { isExpired: true },
    { new: true }
  );
  return session;
};

// Static method to invalidate session by cardId (logout) - marks as expired instead of deleting
ssoSessionSchema.statics.invalidateSession = async function (cardId) {
  const result = await this.updateOne(
    { cardId },
    { isExpired: true }
  );
  return result;
};

// Static method to mark old expired sessions (older than 7 days) for potential cleanup
// This keeps recent expired sessions for audit but marks very old ones
ssoSessionSchema.statics.cleanupOldExpired = async function () {
  const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
  const result = await this.updateMany(
    {
      isExpired: true,
      expiresAt: { $lt: sevenDaysAgo },
    },
    {
      $set: { isExpired: true }, // Already expired, just ensure flag is set
    }
  );
  
  return result.modifiedCount;
};

// Static method to delete very old expired sessions (optional cleanup, older than 30 days)
ssoSessionSchema.statics.deleteVeryOldExpired = async function () {
  const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
  const result = await this.deleteMany({
    isExpired: true,
    expiresAt: { $lt: thirtyDaysAgo },
  });
  
  return result.deletedCount;
};

export const SSOSession = mongoose.model("SSOSession", ssoSessionSchema);

