import mongoose from "mongoose";
import mongooseSequence from "mongoose-sequence";

const AutoIncrement = mongooseSequence(mongoose);

// Declare the Schema of the Mongo model
const notificationSchema = new mongoose.Schema({
  customerId: {
    type: String,
    required: [true, "Name is required."],
  },
  title: {
    type: String,
  },
  message: {
    type: String,
  },
},{
    timestamps: true,
});

notificationSchema.plugin(AutoIncrement, {
  inc_field: "notificationId",
  id: "notifications",
  start_seq: 1,
},{
    timestamps: true,
});

//Export the model
export const Notification = mongoose.model("Notification", notificationSchema);
