import { useState } from 'react';

import { Dialog, DialogTitle, DialogContent } from '@mui/material';

import { DashboardContent } from 'src/layouts/dashboard';

import IncidentDetails from '../incident-details';
import { IncidentTable } from '../../overview/incident-table';
import { useGetAllIncidents } from '../../../backend/queries/queries';

// ----------------------------------------------------------------------

export function IncidentView() {
  const { data: incidentRes, isLoading } = useGetAllIncidents();

  const [open, setOpen] = useState(false);

  const handleClose = () => {
    setOpen(false);
  };

  return (
    <DashboardContent>
      <IncidentTable
        title="Reported Incidents"
        list={incidentRes?.data.data.incidents}
        isLoading={isLoading}
      />

      <Dialog open={open} onClose={handleClose}>
        <DialogTitle>Add New Customer</DialogTitle>
        <DialogContent>
          <IncidentDetails />
        </DialogContent>
      </Dialog>
    </DashboardContent>
  );
}
