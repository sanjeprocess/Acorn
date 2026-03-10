export type Customer = {
  _id: string
  name: string
  email: string
  csa: string
  incidents: any[]
  notifications: any[]
  feedbacks: any[]
  travelHistory: string[]
  createdAt: string
  updatedAt: string
  customerId: number
  __v: number
}

export type CustomerResponse = {
  success: boolean;
  message: string;
  data: {
    travels: Customer[];
  };
};