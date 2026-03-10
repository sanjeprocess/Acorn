import mongoose from "mongoose";
import mongooseSequence from "mongoose-sequence";
import bcrypt from "bcrypt";

const AutoIncrement = mongooseSequence(mongoose);

// Declare the Schema of the Mongo model
const csaSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "Name is required."],
    },
    mobile: {
      type: String,
      // Mobile is optional - required only during registration (not for SSO temp users)
    },
    password: {
        type: String,
        required: [true, "Password is required"],
        minLength: [6, 'Password length should be greater than 6 characters'],
      },
    email: {
      type: String,
      required: [true, "Email number is required."],
      unique: [true, "Email number already exists."],
    },
    isTempPassword: {
      type: Boolean,
      default: false,
    },
    customers: [
      {
        type: String,
      },
    ],
  },
  {
    timestamps: true,
    toJSON: {
      virtuals: true,
      transform: function (doc, ret) {
        delete ret._id;
        delete ret.id;
        delete ret.password;
        delete ret.createdAt;
        delete ret.updatedAt;
        delete ret.__v;
        return ret;
      },
    },
    toObject: {
      virtuals: true,
      transform: function (doc, ret) {
        delete ret._id;
        delete ret.id;
        delete ret.password;
        delete ret.createdAt;
        delete ret.updatedAt;
        delete ret.__v;
        return ret;
      },
    },
  }
);

csaSchema.plugin(AutoIncrement, {
  inc_field: "csaId",
  id: "csa",
  start_seq: 1,
});

// Add indexes for better query performance
// Note: email index is already created by unique: true
// Mobile index is sparse since mobile is optional (for SSO temp users)
csaSchema.index({ mobile: 1 }, { sparse: true });
csaSchema.index({ createdAt: -1 });

csaSchema.pre("save", async function (next) {
  if (!this.isModified('password')) return next(); 
  const salt = bcrypt.genSaltSync(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

csaSchema.methods.isPasswordMatched = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

//Export the model
export const CSA = mongoose.model("CSA", csaSchema);
