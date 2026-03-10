import { Customer } from "../models/customerModel.js";
import asyncHandler from "express-async-handler";
import { deleteFromFirebase, uploadFileToFirebase } from "../utils/fireabase.js";

export const getAllCustomers = asyncHandler(async (req, res) => {
  const customers = await Customer.find().lean();
  res.json({
    message: "All customers fetched.",
    success: true,
    data: { customers },
  });
});

export const createCustomer = asyncHandler(async (req, res) => {
  const { name, email, csa } = req.body;

  if (!name || !email || !csa) {
    res.status(400);
    throw new Error("name, email and csa required");
  }

  const customer = new Customer({ name, email, csa });
  await customer.save();

  res.status(201).json({
    message: "Customer created successfully",
    success: true,
    data: { customer },
  });
});

export const getSingleCustomer = asyncHandler(async (req, res) => {
  const customer = await Customer.findOne({ customerId: req.params.customerId }).lean();

  if (!customer) {
    res.status(404);
    throw new Error("Customer not found");
  }

  res.json({
    message: "Customer fetched.",
    success: true,
    data: { customer },
  });
});

export const getAssignedCustomers = asyncHandler(async (req, res) => {
  const csaId = req.params.csaId;

  if (!csaId) {
    throw new Error("CsaId not provided!");
  }

  const customers = await Customer.find({ csa: csaId }).lean().exec();

  if (!customers) {
    throw new Error("No customers found!");
  }

  res.json({
    message: "Customers fetched.",
    success: true,
    data: { customers },
  });
});

export const updateCustomer = asyncHandler(async (req, res) => {});
export const deleteCustomer = asyncHandler(async (req, res) => {

    const {customerId} = req.params;

    if (!customerId ){
        throw new Error ("Customer not found!")
    }

    const deletedCustomer = await Customer.findOneAndDelete({customerId});

    if (!deletedCustomer) {
        throw new Error ("Customer delete unsuccessful!")
    }

    res.json({
        message: "Customer Deleted!",
        success: true,
    })
});

export const searchCustomer = asyncHandler(async (req, res) => {
  const { csaId, searchQuery } = req.query;

  if (!csaId) {
    res.status(400);
    throw new Error("csaId is required");
  }

  if (!searchQuery || searchQuery.trim() === '') {
    // If no search query, return all assigned customers
    const customers = await Customer.find({ csa: csaId }).lean().exec();
    return res.json({
      message: "Customers fetched.",
      success: true,
      data: { customers },
    });
  }

  // Search by name or email (case-insensitive)
  const searchRegex = new RegExp(searchQuery.trim(), 'i');
  
  const customers = await Customer.find({
    csa: csaId,
    $or: [
      { name: { $regex: searchRegex } },
      { email: { $regex: searchRegex } },
    ],
  })
    .lean()
    .exec();

  res.json({
    message: "Search results fetched.",
    success: true,
    data: { customers },
  });
});
