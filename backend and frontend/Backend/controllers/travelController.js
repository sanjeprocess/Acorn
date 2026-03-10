import { Customer } from "../models/customerModel.js";
import asyncHandler from "express-async-handler";
import { Travel } from "../models/travelModel.js";
import { FeedBack } from "../models/feedbackModel.js";
import {
  deleteFromFirebase,
  uploadFileToFirebase,
} from "../utils/fireabase.js";

// export const getAllFeedbacks = asyncHandler(async (req, res) => {
//   const feedbacks = await FeedBack.aggregate([
//     {
//       $lookup: {
//         from: "customers", // Matches the Customer collection (MongoDB converts model names to lowercase and plural)
//         localField: "customer",
//         foreignField: "customerId",
//         as: "customerDetails",
//       },
//     },
//     {
//       $unwind: {
//         path: "$customerDetails",
//         preserveNullAndEmptyArrays: true, // Ensures feedbacks without a customer don't break
//       },
//     },
//     {
//       $project: {
//         _id: 0,
//         feedbackId: 1,
//         travelId: 1,
//         rating: 1,
//         feedback: 1,
//         createdAt: 1,
//         updatedAt: 1,
//         customer: {
//           name: "$customerDetails.name",
//           email: "$customerDetails.email",
//           csa: "$customerDetails.csa",
//         },
//       },
//     },
//   ]);

//   res.json({
//     message: "All feedbacks fetched.",
//     success: true,
//     data: { feedbacks },
//   });
// });

export const addOrUpdateTravel = asyncHandler(async (req, res) => {
  const { travelId, name, email, startingLocation, destination, csa, travelDate } =
    req.body;

  if (
    !email ||
    !startingLocation ||
    !destination ||
    !name ||
    !csa ||
    !travelDate
  ) {
    res.status(400);
    throw new Error(
      "email, starting location, destination, name, csa and travelDate are required"
    );
  }

  let customer = await Customer.findOne({ email }).lean().exec();

  // Handle file fields: can be either uploaded file or string URL
  const updateFieldDocs = async (fieldName, existingTravel = []) => {
    const incomingKeepUrls = (() => {
      try {
        const parsed = JSON.parse(req.body[fieldName]);
        return Array.isArray(parsed) ? parsed : [];
      } catch {
        return [];
      }
    })();

    const existingUrls = existingTravel?.[fieldName] || [];

    const toRemove = existingUrls?.filter(
      (url) => !incomingKeepUrls.includes(url)
    );

    // Delete removed files from Firebase (assume a deleteFromFirebase(url) function exists)
    await Promise.all(toRemove.map(deleteFromFirebase));

    // Upload new files
    const newFiles = req.files?.[fieldName] || [];
    const newUrls = await Promise.all(
      newFiles.map((file, index) =>
        uploadFileToFirebase(
          file,
          `travels/${fieldName}-${Date.now()}-${index}.pdf`
        )
      )
    );

    // Merge kept + newly uploaded
    return [...incomingKeepUrls, ...newUrls];
  };

  if (!customer) {
    customer = new Customer({ name, email, csa });
    await customer.save();
  }

  const travelRecord = await Travel.findOne({ travelId });

  const hotelsDoc = await updateFieldDocs("hotels", travelRecord);
  const flightsDoc = await updateFieldDocs("flights", travelRecord);
  const vehiclesDoc = await updateFieldDocs("vehicles", travelRecord);
  const tourItineraryDoc = await updateFieldDocs(
    "tourItineraries",
    travelRecord
  );
  const transfersDoc = await updateFieldDocs("transfers", travelRecord);
  const cruiseDoc = await updateFieldDocs("cruiseDocs", travelRecord);
  const otherCSADocs = await updateFieldDocs("otherCSADocs", travelRecord);

  if (travelId) {
    // Edit travel
    const updateFields = {
      startingLocation,
      destination,
      travelDate,
    };

    if (hotelsDoc) updateFields.hotels = hotelsDoc;
    if (flightsDoc) updateFields.flights = flightsDoc;
    if (vehiclesDoc) updateFields.vehicles = vehiclesDoc;
    if (tourItineraryDoc) updateFields.tourItineraries = tourItineraryDoc;
    if (transfersDoc) updateFields.transfers = transfersDoc;
    if (cruiseDoc) updateFields.cruiseDocs = cruiseDoc;
    if (otherCSADocs) updateFields.otherCSADocs = otherCSADocs;

    const updatedTravel = await Travel.findOneAndUpdate(
      { travelId },
      updateFields,
      { new: true }
    );

    if (!updatedTravel) {
      res.status(404);
      throw new Error("Travel not found.");
    }

    res.json({
      message: "Travel updated successfully.",
      success: true,
    });
  } else {
    // Add new travel
    const newTravel = new Travel({
      customer: customer.customerId,
      startingLocation,
      destination,
      travelDate,
      hotels: hotelsDoc,
      flights: flightsDoc,
      vehicles: vehiclesDoc,
      tourItineraries: tourItineraryDoc,
      transfers: transfersDoc,
      cruiseDocs: cruiseDoc,
      otherCSADocs: otherCSADocs,
    });

    const travel = await newTravel.save();

    if (!travel) {
      res.status(500);
      throw new Error("Travel not created.");
    }

    const updatedCustomer = await Customer.findOneAndUpdate(
      { customerId: customer.customerId },
      { $push: { travelHistory: newTravel.travelId } },
      { new: true }
    );

    if (!updatedCustomer) {
      res.status(500);
      throw new Error("Customer not updated with travel history.");
    }

    res.json({
      message: "Travel added successfully.",
      success: true,
    });
  }
});

export const getAllTravels = asyncHandler(async (req, res) => {
  const travels = await Travel.aggregate([
    {
      $lookup: {
        from: "customers", // must match the collection name in MongoDB
        localField: "customer", // this is a string in Travel
        foreignField: "customerId", // numeric field in Customer
        as: "customerDetails", // this will be an array
      },
    },
    {
      $unwind: {
        path: "$customerDetails", // this will be an array",
        preserveNullAndEmptyArrays: true, // just in case some travels have no matching customer
      },
    },
    {
      $project: {
        _id: 0,
        travelId: 1,
        customer: "$customerDetails", // this will be an array", // populate customer as an object
        startingLocation: 1,
        destination: 1,
        travelDate: 1,
        travelStatus: 1,
        hotels: 1,
        flights: 1,
        vehicles: 1,
        otherCSADocs: 1,
        feedback: 1,
        createdAt: 1,
        updatedAt: 1,
      },
    },
  ]);

  res.json({
    message: "All travel records with customer details fetched.",
    success: true,
    data: { travels },
  });
});

//   export const getTravelsByCustomer = asyncHandler(async (req, res) => {
//     const customerId = req.params.customerId;

//     const travels = await Travel.aggregate([
//       // Match travels for the given customerId
//       {
//         $match: { customer: customerId }
//       },
//       // Convert customer string to int for lookup
//       {
//         $addFields: {
//           customerNum: { $toInt: "$customer" }
//         }
//       },
//       // Lookup using the converted customerNum field
//       {
//         $lookup: {
//           from: "customers",
//           localField: "customerNum",
//           foreignField: "customerId",
//           as: "customer"
//         }
//       },
//       {
//         $unwind: {
//           path: "$customer",
//           preserveNullAndEmptyArrays: true
//         }
//       },
//       {
//         $project: {
//           _id: 0,
//           travelId: 1,
//           customer: 1,
//           startingLocation: 1,
//           destination: 1,
//           travelStatus: 1,
//           hotels: 1,
//           flights: 1,
//           vehicles: 1,
//           feedback: 1,
//           createdAt: 1,
//           updatedAt: 1
//         }
//       }
//     ]);

//     res.json({
//       message: `Travel history fetched for customer ${customerId}`,
//       success: true,
//       data: { travels }
//     });
//   });
export const getTravelsByCustomer = asyncHandler(async (req, res) => {
  const customerId = req.params.customerId;

  // Find all travels for the customer
  const travels = await Travel.find({ customer: customerId }).lean().exec();

  res.json({
    message: `Travel history fetched for customer ${req.params.customerId}`,
    success: true,
    data: { travels },
  });
});

export const deleteTravelRecord = asyncHandler(async (req, res) => {
  const travelId = req.params.travelId;

  if (!travelId) {
    res.status(400);
    throw new Error("Travel ID is required.");
  }

  const deletedTravel = await Travel.findOneAndDelete({
    travelId: Number(travelId),
  });

  if (!deletedTravel) {
    res.status(404);
    throw new Error("Travel not found.");
  }

  res.json({
    message: "Travel record deleted successfully.",
    success: true,
  });
});


export const uploadDocs = asyncHandler(async (req, res) => {
  const { travelId } = req.body;

  if (!travelId) {
    return res.status(400).json({ message: "Travel Id is required." });
  }

  const travel = await Travel.findOne({ travelId });
  if (!travel) {
    return res.status(404).json({ message: "Travel not found." });
  }

  const docFields = ["insurance", "vaccinate", "emergency", "destinationInfo"];
  const uploadedResults = {};

  for (const field of docFields) {
    const existingFiles = travel.otherDocs?.[field] || [];
    const newFiles = req.files?.[field] || [];

    if (!Array.isArray(newFiles) || newFiles.length === 0) {
      // Nothing new uploaded for this field – preserve existing files
      uploadedResults[field] = existingFiles;
      continue;
    }

    const uploadedUrls = await Promise.all(
      newFiles.map((file, index) =>
        uploadFileToFirebase(
          file,
          `travels/${field}-${Date.now()}-${index}.pdf`
        )
      )
    );

    uploadedResults[field] = [...existingFiles, ...uploadedUrls];
  }

  travel.otherDocs = {
    ...travel.otherDocs,
    ...uploadedResults,
  };

  const updated = await travel.save();

  if (!updated) {
    return res.status(500).json({ message: "Internal server error while saving travel" });
  }

  res.json({
    message: "Travel updated successfully.",
    success: true,
  });
});

export const deleteCustomerDoc = asyncHandler(async (req, res) => {
  const { travelId, field, url } = req.body;

  if (!travelId || !field || !url) {
    throw new Error("travel Id, field and url required.");
  }

  const travel = await Travel.findOne({ travelId });

  if (!travel) {
    res.status(404);
    throw new Error("Travel not found");
  }

  const travelFieldDocs = travel?.otherDocs[field];

  const filteredFieldDocs = travelFieldDocs.filter((item) => item !== url);

  travel.otherDocs[field] = filteredFieldDocs;

  await travel.save();

  await deleteFromFirebase(url);

  res.json({
    message: "document deleted.",
    success: true,
  });
});

export const updateTravelStatus = asyncHandler(async (req, res) => {
  const { travelId } = req.body;

  if (!travelId) {
    throw new Error("Travel Id required.");
  }

  const travel = await Travel.findOne({ travelId });

  if (!travel) {
    throw new Error("No travel found.");
  }

  travel.travelStatus = "COMPLETED";

  const travelUpdate = await travel.save();

  if (!travelUpdate) {
    throw new Error("Travel update failed.");
  }

  res.json({
    message: "Travel updated.",
    success: true,
  });
});
