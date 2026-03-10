export type TravelItem =  {
  _id: string
  customer: string
  startingLocation: string
  destination: string
  travelDate: string
  travelStatus: string
  hotels: any[]
  flights: string[]
  vehicles: any[]
  tourItineraries: any[]
  transfers: any[]
  cruiseDocs: any[]
  otherCSADocs: any[]
  otherDocs: OtherDocs
  createdAt: string
  updatedAt: string
  travelId: number
  __v: number
}

type OtherDocs = {
  insurance: string[]
  vaccinate: string[]
  emergency: string[]
  destinationInfo: any[]
}

export type TravelResponse = {
  success: boolean;
  message: string;
  data: {
    travels: TravelItem[];
  };
};