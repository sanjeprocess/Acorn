/* eslint-disable @typescript-eslint/no-unused-expressions */
import { useEffect } from 'react';

import { LoadingButton } from '@mui/lab';
import {
  Box,
  Grid,
  Button,
  TextField,
  IconButton,
  DialogActions,
} from '@mui/material';

import { Iconify } from '../../../components/iconify';

import type FormDataType from '../../../types/common';

type UserAddNewTravelProps = {
  handleTravelSubmit?: (e: any) => void;
  formData?: FormDataType;
  isEditMode?: boolean;
  handleChange?: (e: any) => void;
  setFormData?: (formData: any) => void;
  isPending?: boolean;
  handleClose?: () => void;
  customerData?: {
    name: string;
    email: string;
  };
};

const fileFields = [
  { key: 'flights', label: 'Upload Flights PDF', existingKey: 'existingFlightUrls' },
  { key: 'hotels', label: 'Upload Hotels PDF', existingKey: 'existingHotelUrls' },
  { key: 'vehicles', label: 'Upload Vehicles PDF', existingKey: 'existingVehicleUrls' },
  { key: 'tourItineraries', label: 'Upload Tour Itinerary PDF', existingKey: 'existingTourItineraryUrls' },
  { key: 'transfers', label: 'Upload Transfers PDF', existingKey: 'existingTransferUrls' },
  { key: 'cruiseDocs', label: 'Upload Cruise Documents', existingKey: 'existingCruiseDocUrls' },
  { key: 'otherCSADocs', label: 'Other Documents', existingKey: 'existingOtherCSADocUrls' },
] as const;

const UserAddNewTravel = ({
  handleTravelSubmit,
  formData,
  handleChange,
  setFormData,
  isPending,
  handleClose,
  customerData,
  isEditMode,
}: UserAddNewTravelProps) => {
  const { name, email } = customerData || {};

  useEffect(() => {
    if (name && email) {
      setFormData?.((prevData: any) => ({
        ...prevData,
        name,
        email,
      }));
    }
  }, [name, email, setFormData]);

  return (
    <Box component="form" onSubmit={handleTravelSubmit} sx={{ mt: 2, maxHeight: '80vh', overflowY: 'auto', pr: 2 }}>
      <Grid container spacing={2} sx={{mt: 1}}>
        <Grid item xs={12} sm={6}>
          <TextField
            name="email"
            label="Customer Email"
            value={formData?.email}
            onChange={handleChange}
            disabled={!!email}
            fullWidth
            InputLabelProps={{ shrink: true }}
            required
          />
        </Grid>
        <Grid item xs={12} sm={6}>
          <TextField
            fullWidth
            label="Customer Name"
            name="name"
            value={formData?.name}
            onChange={handleChange}
            disabled={!!name}
            InputLabelProps={{ shrink: true }}
            required
          />
        </Grid>
        <Grid item xs={12} sm={6}>
          <TextField
            label="Start Location"
            name="startLocation"
            value={formData?.startLocation}
            onChange={handleChange}
            fullWidth
            InputLabelProps={{ shrink: true }}
            required
          />
        </Grid>
        <Grid item xs={12} sm={6}>
          <TextField
            label="Destination"
            name="destination"
            value={formData?.destination}
            onChange={handleChange}
            fullWidth
            InputLabelProps={{ shrink: true }}
            required
          />
        </Grid>
        <Grid item xs={12} sm={6}>
          <TextField
            label="Travel Date"
            name="travelDate"
            type="date"
            value={formData?.travelDate ? new Date(formData.travelDate).toISOString().split('T')[0] : ''}
            onChange={(e) => {
              const dateValue = e.target.value ? new Date(e.target.value) : new Date();
              handleChange?.({
                target: { name: 'travelDate', value: dateValue }
              } as unknown as React.ChangeEvent<HTMLInputElement>);
            }}
            fullWidth
            InputLabelProps={{ shrink: true }}
            required
          />
        </Grid>
        <Grid item xs={12}>
          <Box mt={2}>
            <strong>Upload Travel Documents</strong>
          </Box>
        </Grid>

        {fileFields.map(({ key, label, existingKey }) => (
          <Grid item xs={12} sm={6} key={key}>
            <Button
              variant="outlined"
              component="label"
              startIcon={<Iconify icon="mdi:file-upload-outline" />}
              sx={{ color: '#000000', borderColor: '000000' }}
              fullWidth
            >
              {label}
              <input
                type="file"
                name={key}
                accept="application/pdf"
                multiple
                hidden
                onChange={handleChange}
              />
            </Button>

            {/* Existing Files */}
            {Array.isArray(formData?.[existingKey]) && formData[existingKey].length > 0 && (
              <Box mt={1}>
                {formData[existingKey].map((url: string, index: number) => (
                  <Box key={`existing-${key}-${index}`} display="flex" alignItems="center" mt={0.5}>
                    <a href={url} target="_blank" rel="noopener noreferrer">
                      {`Existing ${label.replace('Upload ', '')} ${index + 1}`}
                    </a>
                    <IconButton
                      size="small"
                      onClick={() => {
                        const updated = [...formData[existingKey]];
                        updated.splice(index, 1);
                        setFormData?.((prevData: any) => ({
                          ...prevData,
                          [existingKey]: updated,
                        }));
                      }}
                    >
                      <Iconify icon="mdi:close" />
                    </IconButton>
                  </Box>
                ))}
              </Box>
            )}

            {/* New Files */}
            {Array.isArray(formData?.[key]) && formData[key].length > 0 && (
              <Box mt={1}>
                {formData[key].map((file: File, index: number) => (
                  <Box key={`new-${key}-${index}`} display="flex" alignItems="center" mt={0.5}>
                    <Iconify icon="mdi:file-pdf-box" width={24} height={24} />
                    <Box ml={1}>{file.name}</Box>
                    <IconButton
                      size="small"
                      onClick={() => {
                        const updated = [...formData[key]];
                        updated.splice(index, 1);
                        setFormData?.((prevData: any) => ({
                          ...prevData,
                          [key]: updated,
                        }));
                      }}
                    >
                      <Iconify icon="mdi:close" />
                    </IconButton>
                  </Box>
                ))}
              </Box>
            )}
          </Grid>
        ))}
      </Grid>

      <DialogActions sx={{ mt: 2 }}>
        <LoadingButton size="large" onClick={handleClose} color="inherit" variant="contained">
          Cancel
        </LoadingButton>
        <LoadingButton
          size="large"
          type="submit"
          loading={isPending}
          loadingPosition="center"
          color="inherit"
          variant="contained"
          onClick={handleTravelSubmit}
        >
          {isEditMode ? 'Save Travel' : 'Add new Travel'}
        </LoadingButton>
      </DialogActions>
    </Box>
  );
};

export default UserAddNewTravel;
