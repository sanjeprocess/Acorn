import mongoose from "mongoose";
import mongooseSequence from "mongoose-sequence";

const AutoIncrement = mongooseSequence(mongoose);

// Declare the Schema of the Mongo model
const customerSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "Name is required."],
    },
    email: {
      type: String,
      required: [true, "Email is required."],
      unique: [true, "User with email already exists."],
    },
    password: {
      type: String,
    },
    csa: {
      type: Number,
      required: true,
      ref: 'CSA'
    },
    incidents: [
      {
        type: String,
      },
    ],
    notifications: [
      {
        type: String,
      },
    ],
    feedbacks: [
      {
        type: String,
      },
    ],
    travelHistory: [
      {
        type: String,
      },
    ]
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

customerSchema.plugin(AutoIncrement, {
  inc_field: "customerId",
  id: "customers",
  start_seq: 1,
});

// Add indexes for better query performance
// Note: email index is already created by unique: true
customerSchema.index({ csa: 1 });
customerSchema.index({ createdAt: -1 });

//Export the model
export const Customer = mongoose.model("Customer", customerSchema);
