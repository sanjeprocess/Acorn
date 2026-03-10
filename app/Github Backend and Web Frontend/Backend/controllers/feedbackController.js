import { Customer } from "../models/customerModel.js";
import asyncHandler from "express-async-handler";
import { Travel } from "../models/travelModel.js";
import { FeedBack } from "../models/feedbackModel.js";

export const getAllFeedbacks = asyncHandler(async (req, res) => {
  const feedbacks = await FeedBack.aggregate([
    {
      $addFields: {
        customerIdAsNumber: { $toInt: "$customer" },
        travelIdAsNumber: { $toInt: "$travelId" },
      },
    },
    {
      $lookup: {
        from: "customers",
        localField: "customerIdAsNumber",
        foreignField: "customerId",
        as: "customerDetails",
      },
    },
    {
      $unwind: {
        path: "$customerDetails",
        preserveNullAndEmptyArrays: true,
      },
    },
    {
      $lookup: {
        from: "travels",
        localField: "travelIdAsNumber",
        foreignField: "travelId",
        as: "travelDetails",
      },
    },
    {
      $unwind: {
        path: "$travelDetails",
        preserveNullAndEmptyArrays: true,
      },
    },
    {
      $addFields: {
        csaIdNum: { $toInt: "$customerDetails.csa" },
      },
    },
    {
      $lookup: {
        from: "csas",
        localField: "csaIdNum",
        foreignField: "csaId",
        as: "csaDetails",
      },
    },
    {
      $unwind: {
        path: "$csaDetails",
        preserveNullAndEmptyArrays: true,
      },
    },
    {
      $project: {
        _id: 0,
        feedbackId: 1,
        travelId: 1,
        rating: 1,
        feedback: 1,
        createdAt: 1,
        updatedAt: 1,
        customer: {
          name: "$customerDetails.name",
          email: "$customerDetails.email",
          csa: "$customerDetails.csa",
        },
        csa: {
          csaId: "$csaDetails.csaId",
          name: "$csaDetails.name",
        },
        travel: {
          startingLocation: "$travelDetails.startingLocation",
          destination: "$travelDetails.destination",
          travelDate: "$travelDetails.travelDate",
        },
      },
    },
  ]);

  res.json({
    message: "All feedbacks fetched.",
    success: true,
    data: { feedbacks },
  });
});

export const addNewFeedback = asyncHandler(async (req, res) => {
  const { customerId, travelId, rating, feedback } = req.body;

  if (!customerId || !travelId || !feedback) {
    res.status(400);
    throw new Error("customerId and travelId and feedback are required");
  }

  const customer = await Customer.findOne({customerId}).lean().exec();

  if (!customer) {
    res.status(404);
    throw new Error("No customer found for ID " + customerId);
  }

  const travel = await Travel.findOne({ travelId }).lean().exec();

  if (!travel) {
    res.status(404);
    throw new Error("No travel found for ID " + travelId);
  }

  const newFeedback = new FeedBack({ ...req.body, customer: customerId });
  await newFeedback.save();

  const updatedTravel = await Travel.findOneAndUpdate(
    {
      travelId,
    },
    {
      feedback: newFeedback.feedbackId,
    },
    {
      new: true,
    }
  );

  if (!updatedTravel) {
    res.status(500);
    throw new Error("Travel not updated with feedback.");
  }

  res.json({
    message: "Feedback added successfully.",
    success: true,
    data: { feedback: newFeedback },
  });
});

export const getFeedbackByCustomer = asyncHandler(async (req, res) => {
  const customerId = req.params.customerId;

  const feedbacks = await FeedBack.aggregate([
    {
      $match: { customer: customerId },
    },
    {
      $addFields: {
        customerIdAsNumber: { $toInt: "$customer" },
        travelIdAsNumber: { $toInt: "$travelId" },
      },
    },
    {
      $lookup: {
        from: "customers",
        localField: "customerIdAsNumber",
        foreignField: "customerId",
        as: "customerDetails",
      },
    },
    {
      $unwind: {
        path: "$customerDetails",
        preserveNullAndEmptyArrays: true,
      },
    },
    {
      $lookup: {
        from: "travels",
        localField: "travelIdAsNumber",
        foreignField: "travelId",
        as: "travelDetails",
      },
    },
    {
      $unwind: {
        path: "$travelDetails",
        preserveNullAndEmptyArrays: true,
      },
    },
    {
      $addFields: {
        csaIdNum: { $toInt: "$customerDetails.csa" },
      },
    },
    {
      $lookup: {
        from: "csas",
        localField: "csaIdNum",
        foreignField: "csaId",
        as: "csaDetails",
      },
    },
    {
      $unwind: {
        path: "$csaDetails",
        preserveNullAndEmptyArrays: true,
      },
    },
    {
      $project: {
        _id: 0,
        feedbackId: 1,
        travelId: 1,
        rating: 1,
        feedback: 1,
        createdAt: 1,
        updatedAt: 1,
        customer: {
          name: "$customerDetails.name",
          email: "$customerDetails.email",
          csa: "$customerDetails.csa",
        },
        csa: {
          csaId: "$csaDetails.csaId",
          name: "$csaDetails.name",
        },
        travel: {
          startingLocation: "$travelDetails.startingLocation",
          destination: "$travelDetails.destination",
          travelDate: "$travelDetails.travelDate",
        },
      },
    },
  ]);

  res.json({
    message: `Feedbacks fetched for customer ${customerId}`,
    success: true,
    data: { feedbacks },
  });
});

export const getFeedbackByTravelId = asyncHandler(async (req, res) => {
  const travelId = req.params.travelId;

  const feedbacks = await FeedBack.findOne({ travelId });

  if (!feedbacks) {
    res.status(404);
    throw new Error("No feedback found for travel ID " + travelId);
  }

  res.json({
    message: `Feedbacks fetched for travelId ${travelId}`,
    success: true,
    data: { feedbacks },
  });
});
