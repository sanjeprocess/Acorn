import mongoose from "mongoose";
import mongooseSequence from "mongoose-sequence";

const AutoIncrement = mongooseSequence(mongoose);

// Declare the Schema of the Mongo model
const travelSchema = new mongoose.Schema(
  {
    customer: {
      type: Number,
      required: [true, "Customer is required."],
      ref: 'Customer'
    },
    startingLocation: {
      type: String,
      required: [true, "Starting location is required."],
    },
    destination: {
      type: String,
      required: [true, "Destination is required."],
    },
    travelDate: {
      type: Date,
      required: [true, "Travel date is required."],
    },
    travelStatus: {
      type: String,
      enum: ["ON_GOING", "COMPLETED", "CANCELLED"],
      default: "ON_GOING",
    },
    hotels:[ {
      type: String,
    }],
    flights: [{
      type: String,
    }],
    vehicles: [{
        type: String,
      }],
    tourItineraries: [{
        type: String,
      }],
    transfers: [{
        type: String,
      }],
    cruiseDocs: [{
      type: String,
    }],
    otherCSADocs: [{
      type: String,
    }],
    feedback: {
      type: String,
    },
    otherDocs: {
      type: Map,
      of: [String],
      default: {},
    },
  },
  {
    timestamps: true,
  }
);

travelSchema.plugin(AutoIncrement, {
  inc_field: "travelId",
  id: "travels",
  start_seq: 1,
});

// Add indexes for better query performance
travelSchema.index({ customer: 1 });
travelSchema.index({ travelStatus: 1 });
travelSchema.index({ customer: 1, travelStatus: 1 });
travelSchema.index({ startingLocation: 1 });
travelSchema.index({ destination: 1 });
travelSchema.index({ createdAt: -1 });

//Export the model
export const Travel = mongoose.model("Travel", travelSchema);
