import mongoose from "mongoose";
import mongooseSequence from "mongoose-sequence";

const AutoIncrement = mongooseSequence(mongoose);

// Declare the Schema of the Mongo model
const feedbackSchema = new mongoose.Schema({
  customer: {
    type: Number,
    required: [true, "Customer Id is required."],
    ref: 'Customer'
  },
  travelId: {
    type: Number,
    required: [true, "Travel ID is required."],
    ref: 'Travel'
  },
  rating: {
    type: Number,
    required: [true, "Rating is required."],
    min: [1, "Rating must be at least 1"],
    max: [5, "Rating must be at most 5"]
  },
  feedback: {
    type: String,
    required: [true, "Feedback is required."],
    maxLength: [500, "Feedback cannot exceed 500 characters"]
  },
},{
    timestamps: true,
});

feedbackSchema.plugin(AutoIncrement, {
  inc_field: "feedbackId",
  id: "feedbacks",
  start_seq: 1,
});

// Add indexes for better query performance
feedbackSchema.index({ customer: 1 });
feedbackSchema.index({ travelId: 1 });
feedbackSchema.index({ rating: 1 });
feedbackSchema.index({ createdAt: -1 });

//Export the model
export const FeedBack = mongoose.model("FeedBack", feedbackSchema);
