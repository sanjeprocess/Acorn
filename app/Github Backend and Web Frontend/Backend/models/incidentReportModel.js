import mongoose from "mongoose";
import mongooseSequence from "mongoose-sequence";

const AutoIncrement = mongooseSequence(mongoose);

// Declare the Schema of the Mongo model
const incidentSchema = new mongoose.Schema({
  customer: {
    type: String,
    required: [true, "Customer is required."],
  },
  incidentId: {
    type: Number,
  },
  incidentPhotos: [{
    type: String,
  }],
  title: {
    type: String,
    required: [true, "Title is required."],
  },
  notes: {
    type: String,
  },
  incidentDate: {
    type: Date,
    required: [true, "Incident date is required."],
  },
  incidentLocation: {
    longitude: {
      type: Number,
    },
    latitude: {
      type: Number,
    },
  },
  incidentTime: {
    type: String,
    required: [true, "Incident time is required."],
  },
  incidentStatus: {
    type: String,
    default: "Pending",
    enum: ["Pending", "Resolved", "Closed"],
  },
},{
    timestamps: true,
});

incidentSchema.plugin(AutoIncrement, {
  inc_field: "incidentId",
  id: "incidents",
  start_seq: 1,
},{
    timestamps: true,
});

//Export the model
export const IncidentReport = mongoose.model("IncidentReport", incidentSchema);
