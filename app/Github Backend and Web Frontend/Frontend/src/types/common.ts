type FormDataType = {
  name: string;
  email: string;
  startLocation: string;
  destination: string;
  travelDate: Date;

  flights: File[];
  existingFlightUrls: string[];

  hotels: File[];
  existingHotelUrls: string[];

  vehicles: File[];
  existingVehicleUrls: string[];

  tourItineraries: File[];
  existingTourItineraryUrls: string[];

  transfers: File[];
  existingTransferUrls: string[];

  cruiseDocs: File[];
  existingCruiseDocUrls: string[];

  otherCSADocs: File[];
  existingOtherCSADocUrls: string[];
};

export default FormDataType;
