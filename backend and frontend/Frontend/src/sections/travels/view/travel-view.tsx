import { toast } from 'sonner';
import { useState } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { useParams, useLocation } from 'react-router-dom';

import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import Table from '@mui/material/Table';
import Button from '@mui/material/Button';
import TableBody from '@mui/material/TableBody';
import Typography from '@mui/material/Typography';
import TableContainer from '@mui/material/TableContainer';
import TablePagination from '@mui/material/TablePagination';
import {
  Dialog,
  TableRow,
  TableCell,
  DialogTitle,
  DialogContent,
  CircularProgress,
} from '@mui/material';

import { DashboardContent } from 'src/layouts/dashboard';

import { Iconify } from 'src/components/iconify';
import { Scrollbar } from 'src/components/scrollbar';

import useAcornStore from '../../../store/store';
import { useTable } from '../../../hooks/useTable';
import { TravelTableRow } from '../travel-table-row';
import QueryKeys from '../../../enums/query-keys.enum';
import { UserTableHead } from '../../user/user-table-head';
import UserAddNewTravel from '../../user/view/user-travel-add';
import { emptyRows, applyFilter, getComparator } from '../utils';
import { useGetPastTravels } from '../../../backend/queries/queries';
import { TableNoData } from '../../../components/table/table-no-data';
import { TableEmptyRows } from '../../../components/table/table-empty-rows';
import {
  useNewTravel,
  useDeleteTravel,
  useUpdateTravel,
} from '../../../backend/mutations/mutations';

import type FormDataType from '../../../types/common';
// ----------------------------------------------------------------------

export const TravelView = () => {
  const table = useTable();

  const [filterName, setFilterName] = useState('');
  const [isEditMode, setIsEditMode] = useState(false);
  const [selectedTravelId, setSelectedTravelId] = useState<number | null>(null);

  const csaId = useAcornStore((state) => state.auth.csaId);

  const { mutate: createNewTravel, isPending: creationPending } = useNewTravel();
  const { mutate: editTravel, isPending: editingPending } = useUpdateTravel();
  const { mutate: deleteTravel, isPending: deletePending } = useDeleteTravel();

  const params = useParams();
  const location = useLocation();

  const { data: travelResponse, isLoading } = useGetPastTravels(params?.customerId || '');
const travels = travelResponse?.data?.travels
  const queryClient = useQueryClient();

  const dataFiltered: any[] = applyFilter({
    inputData: travelResponse?.data?.travels || [],
    comparator: getComparator(table.order, table.orderBy),
    filterName,
  });

  const notFound =
    (!dataFiltered.length && !!filterName) || !travels?.length;

  const initialFormData: FormDataType = {
    name: '',
    email: '',
    startLocation: '',
    destination: '',
    travelDate: new Date(),

    flights: [],
    existingFlightUrls: [],

    hotels: [],
    existingHotelUrls: [],

    vehicles: [],
    existingVehicleUrls: [],

    tourItineraries: [],
    existingTourItineraryUrls: [],

    transfers: [],
    existingTransferUrls: [],

    cruiseDocs: [],
    existingCruiseDocUrls: [],

    otherCSADocs: [],
    existingOtherCSADocUrls: [],
  };

  const [open, setOpen] = useState(false);
  const [formData, setFormData] = useState<FormDataType>(initialFormData);

  const handleClickOpen = () => {
    setOpen(true);
  };

  const handleClose = () => {
    setOpen(false);
    setFormData(initialFormData);
    setIsEditMode(false);
  };

  const handleTravelEdit = (travelId: number) => {
    const travel = travels?.find(
      (travelRecord) => travelRecord.travelId === travelId
    );
    if (travel) {
      setFormData({
        name: location.state?.name,
        email: location.state?.email,
        startLocation: travel.startingLocation,
        destination: travel.destination,
        travelDate: new Date(travel.travelDate),

        flights: [],
        existingFlightUrls: travel.flights || [],

        hotels: [],
        existingHotelUrls: travel.hotels || [],

        vehicles: [],
        existingVehicleUrls: travel.vehicles || [],

        tourItineraries: [],
        existingTourItineraryUrls: travel.tourItineraries || [],

        transfers: [],
        existingTransferUrls: travel.transfers || [],

        cruiseDocs: [],
        existingCruiseDocUrls: travel.cruiseDocs || [],

        otherCSADocs: [],
        existingOtherCSADocUrls: travel.otherCSADocs || [],
      });
    }
    setSelectedTravelId(travelId);
    setIsEditMode(true);
    setOpen(true);
  };

  const handleTravelDelete = (travelId: number) => {
    deleteTravel(travelId, {
      onSuccess: async (resData) => {
        if (resData) {
          toast.success('Travel deleted Successful');
          await queryClient.invalidateQueries({ queryKey: [QueryKeys.TravelHistory] });
          handleClose();
        }
      },
      onError: (error: any) => {
        toast.error(error?.response?.data?.message || 'An error occurred');
        // After deletion, you may want to invalidate the query to refresh the data
        queryClient.invalidateQueries({ queryKey: [QueryKeys.TravelHistory] });
      },
    });
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value, files } = e.target;

    if (files) {
      setFormData((prev) => ({
        ...prev,
        [name]: [...(prev[name as keyof FormDataType] as File[]), ...Array.from(files)],
      }));
    } else {
      setFormData((prev) => ({
        ...prev,
        [name]: value,
      }));
    }
  };
  const fileFields = [
    { field: 'flights', urls: 'existingFlightUrls' },
    { field: 'hotels', urls: 'existingHotelUrls' },
    { field: 'vehicles', urls: 'existingVehicleUrls' },
    { field: 'tourItineraries', urls: 'existingTourItineraryUrls' },
    { field: 'transfers', urls: 'existingTransferUrls' },
    { field: 'cruiseDocs', urls: 'existingCruiseDocUrls' },
    { field: 'otherCSADocs', urls: 'existingOtherCSADocUrls' },
  ];

  const handleTravelSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    const formDataS = new FormData();
    formDataS.append('name', formData.name);
    formDataS.append('email', formData.email);
    formDataS.append('startingLocation', formData.startLocation);
    formDataS.append('destination', formData.destination);
    formDataS.append('travelDate', formData.travelDate.toISOString());
    formDataS.append('csa', csaId);

    // Append all files and URLs dynamically
    fileFields.forEach(({ field, urls }) => {
      (formData[field as keyof FormDataType] as File[]).forEach((file) => {
        formDataS.append(field, file);
      });

      const urlArray = formData[urls as keyof FormDataType] as string[];
      formDataS.append(field, JSON.stringify(urlArray));
    });

    if (isEditMode && selectedTravelId) {
      formDataS.append('travelId', selectedTravelId.toString());
    }

    createNewTravel(formDataS, {
      onSuccess: async (resData) => {
        toast.success(isEditMode ? 'Travel updated successfully' : 'Travel added successfully');
        await queryClient.invalidateQueries({ queryKey: [QueryKeys.TravelHistory] });
        handleClose();
      },
      onError: (error: any) => {
        console.error(error);
        toast.error(error?.response?.data?.message || 'An error occurred');
        handleClose();
      },
    });
  };

  return (
    <DashboardContent>
      <Box display="flex" alignItems="center" mb={5}>
        <Typography variant="h4" flexGrow={1}>
          Travels history: {location.state?.name}
        </Typography>
        <Button
          onClick={handleClickOpen}
          variant="contained"
          color="inherit"
          startIcon={<Iconify icon="mingcute:add-line" />}
        >
          New Travel
        </Button>
      </Box>

      <Card>
        {/* <UserTableToolbar
          numSelected={table.selected.length}
          filterName={filterName}
          onFilterName={(event: React.ChangeEvent<HTMLInputElement>) => {
            setFilterName(event.target.value);
            table.onResetPage();
          }}
        /> */}

        <Scrollbar>
          <TableContainer sx={{ overflow: 'unset' }}>
            <Table sx={{ minWidth: 800 }}>
              <UserTableHead
                order={table.order}
                orderBy={table.orderBy}
                rowCount={travels?.length || 0}
                numSelected={table.selected.length}
                onSort={table.onSort}
                onSelectAllRows={(checked) =>
                  table.onSelectAllRows(
                    checked,
                    travels || [].map((user:any) => user.id)
                  )
                }
                headLabel={[
                  { id: 'travelId', label: 'Travel Id' },
                  { id: 'startingLocation', label: 'Origin' },
                  { id: 'destination', label: 'Destination' },
                  { id: 'travelDate', label: 'Travel Date' },
                  { id: 'travelStatus', label: 'Status' },
                  { id: '' },
                ]}
              />
              <TableBody>
                {isLoading ? (
                  <TableRow>
                    <TableCell colSpan={7} align="center">
                      <CircularProgress />
                    </TableCell>
                  </TableRow>
                ) : (
                  dataFiltered
                    .slice(
                      table.page * table.rowsPerPage,
                      table.page * table.rowsPerPage + table.rowsPerPage
                    )
                    .map((row, index) => (
                      <TravelTableRow
                        key={index}
                        row={row}
                        selected={table.selected.includes(row.id)}
                        onSelectRow={() => table.onSelectRow(row.id)}
                        handleDelete={handleTravelDelete}
                        handleEdit={handleTravelEdit}
                      />
                    ))
                )}

                <TableEmptyRows
                  height={68}
                  emptyRows={emptyRows(table.page, table.rowsPerPage, dataFiltered.length)}
                />

                {notFound && <TableNoData searchQuery={filterName} />}
              </TableBody>
            </Table>
          </TableContainer>
        </Scrollbar>

        <TablePagination
          component="div"
          page={table.page}
          count={travels?.length || [].length}
          rowsPerPage={table.rowsPerPage}
          onPageChange={table.onChangePage}
          rowsPerPageOptions={[5, 10, 25]}
          onRowsPerPageChange={table.onChangeRowsPerPage}
        />
      </Card>
      <Dialog open={open} onClose={handleClose}>
        <DialogTitle>{isEditMode ? 'Update Travel' : 'Add New Travel'}</DialogTitle>
        <DialogContent>
          <UserAddNewTravel
            isEditMode={isEditMode}
            handleTravelSubmit={handleTravelSubmit}
            formData={formData}
            handleChange={handleChange}
            setFormData={setFormData}
            isPending={creationPending || editingPending || deletePending}
            handleClose={handleClose}
            customerData={{
              name: location.state?.name,
              email: location.state?.email,
            }}
          />
        </DialogContent>
      </Dialog>
    </DashboardContent>
  );
};
