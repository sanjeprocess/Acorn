import { Customer } from "../models/customerModel.js";
import asyncHandler from "express-async-handler";
import { CSA } from "../models/csaModel.js";

export const createCSA = asyncHandler(async (req, res) => {
  const { name, email, mobile, password } = req.body;

  if (!name || !email || !mobile || !password) {
    res.status(400);
    throw new Error("name, email and mobile required");
  }

  const csa = new CSA({ name, email, mobile, password });
  await csa.save();

  res.status(201).json({
    message: "CSA created successfully",
    success: true,
    data: { csa },
  });
});

export const getAllCSAs = asyncHandler(async (req, res) => {
  const csas = await CSA.find().lean();
    res.json({
      message: "All CSAs fetched.",
      success: true,
      data: { csas },
    })
});

export const getCustomersByCSA = asyncHandler(async (req, res) => {
    const customer = await Customer.findById(req.params.customerId).lean();
  
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