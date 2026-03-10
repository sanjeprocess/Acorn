import {axiosInstance} from "../api/api";

import type { TravelResponse } from "../../types/travels";

export const getAssignedCustomers = async (csaId: string) => axiosInstance.get(`/customer/assignedCustomers/${csaId}`);

export const searchCustomers = async (csaId: string, searchQuery: string) => 
  axiosInstance.get(`/customer/search?csaId=${csaId}&searchQuery=${encodeURIComponent(searchQuery)}`);

export const getCustomerFeedback = async () => axiosInstance.get(`/feedback`);

export const getIncidents = async () => axiosInstance.get(`/incidentReport`);

export const getCustomerTravelHistory = async (customerId: string): Promise<TravelResponse> => {
  const res = await axiosInstance.get<TravelResponse>(`/travels/${customerId}`);
  return res.data; // ⬅️ return only the response body
};