import { Customer } from "../models/customerModel.js";
import asyncHandler from "express-async-handler";
import { uploadFileToFirebase } from "../utils/fireabase.js";
import { IncidentReport } from "../models/incidentReportModel.js";
import { format } from "date-fns";

export const addNewIncident = asyncHandler(async (req, res) => {
  const { customer, notes, incidentLocation, title } = req.body;

  if (!customer || !incidentLocation || !notes || !title) {
    return res
      .status(400)
      .json({ success: false, message: "Missing required fields" });
  }

  // Create new incident report
  const newIncident = new IncidentReport({
    customer,
    notes,
    title,
    incidentDate: format(new Date(), "yyyy-MM-dd"),
    incidentLocation,
    incidentTime: format(new Date(), "HH:mm"),
  });
  const savedIncident = await newIncident.save();

  let uploadedPhotoUrls = [];

  // Upload each file to Firebase Storage
  if (req.files && req.files.length > 0) {
    uploadedPhotoUrls = await Promise.all(
      req.files.map(async (file, index) => {
        const fileUrl = await uploadFileToFirebase(
          file,
          `incidents/${newIncident.incidentId}/${index}`
        );
        return fileUrl;
      })
    );
  }

  const updateIncident = await IncidentReport.findOneAndUpdate(
    { incidentId: newIncident.incidentId },
    { incidentPhotos: uploadedPhotoUrls },
    { new: true }
  );

  if (!updateIncident) {
    return res.status(500).json({
      success: false,
      message: "Failed to update incident report with photos",
    });
  }

  const updateCustomer = await Customer.findOneAndUpdate(
    { customerId: customer },
    { $push: { incidents: savedIncident.incidentId } },
    { new: true }
  );

  if (!updateCustomer) {
    return res.status(500).json({
      success: false,
      message: "Failed to update customer with incident report",
    });
  }

  res.status(201).json({
    success: true,
    message: "Incident report created successfully",
    incident: updateIncident,
  });
});

export const getAllIncidents = asyncHandler(async (req, res) => {
  const incidents = await IncidentReport.aggregate([
    {
      $addFields: {
        customerNum: { $toInt: "$customer" },
      },
    },
    {
      $lookup: {
        from: "customers",
        localField: "customerNum",
        foreignField: "customerId",
        as: "customerDetails", // ✅ store the joined data as 'customerDetails'
      },
    },
    {
      $unwind: {
        path: "$customerDetails",
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
        incidentId: 1,
        incidentPhotos: 1,
        notes: 1,
        title: 1,
        incidentDate: 1,
        incidentLocation: 1,
        incidentTime: 1,
        incidentStatus: 1,
        createdAt: 1,
        updatedAt: 1,
        customer: {
          name: "$customerDetails.name",
          email: "$customerDetails.email",
          csa: "$csaDetails.name",
        },
      },
    },
  ]);

  res.json({
    message: `Incidents fetched for customer ${req.params.customerId}`,
    success: true,
    data: { incidents },
  });
});

export const getIncidentByCustomer = asyncHandler(async (req, res) => {
  const customerId = req.params.customerId;

  const incidents = await IncidentReport.find({ customer: customerId }).lean();

  res.json({
    message: `Incidents fetched for customer ${req.params.customerId}`,
    success: true,
    data: { incidents },
  });
});
