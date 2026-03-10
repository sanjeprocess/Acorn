/* eslint-disable @typescript-eslint/no-unused-expressions */
import type { AxiosResponse } from 'axios';

import { toast } from 'sonner';
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQueryClient } from '@tanstack/react-query';
import { useDebounce } from 'react-use';

import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import Table from '@mui/material/Table';
import Button from '@mui/material/Button';
import TableBody from '@mui/material/TableBody';
import Typography from '@mui/material/Typography';
import TableContainer from '@mui/material/TableContainer';
import TablePagination from '@mui/material/TablePagination';
import { Dialog, TableRow, DialogTitle, DialogContent, CircularProgress } from '@mui/material';

import { DashboardContent } from 'src/layouts/dashboard';

import { Iconify } from 'src/components/iconify';
import { Scrollbar } from 'src/components/scrollbar';

import { UserTableRow } from '../user-table-row';
import useAcornStore from '../../../store/store';
import UserAddNewTravel from './user-travel-add';
import { UserTableHead } from '../user-table-head';
import { useTable } from '../../../hooks/useTable';
import QueryKeys from '../../../enums/query-keys.enum';
import { UserTableToolbar } from '../user-table-toolbar';
import { emptyRows, getComparator } from '../utils';
import { TableNoData } from '../../../components/table/table-no-data';
import { useGetAssignedCustomers, useSearchCustomers } from '../../../backend/queries/queries';
import { TableEmptyRows } from '../../../components/table/table-empty-rows';
import { useNewTravel, useDeleteUser } from '../../../backend/mutations/mutations';

import type FormDataType from '../../../types/common';

// ----------------------------------------------------------------------

export type Customer = {
  id: number;
  name: string;
  email: string;
  status?: string;
  customerId?: number;
};

export function UserView() {
  const table = useTable();

  const [filterName, setFilterName] = useState('');
  const [debouncedSearchQuery, setDebouncedSearchQuery] = useState('');

  const csaId = useAcornStore((state) => state.auth.csaId);

  const { mutate: createNewTravel, isPending } = useNewTravel();
  const { mutate: deleteUser, isPending: userLoading } = useDeleteUser();

  // Use search query if there's a debounced search, otherwise use regular fetch
  const hasSearchQuery = debouncedSearchQuery.trim().length > 0;
  
  const { data: cusResponse = [], isLoading: isLoadingAll } = useGetAssignedCustomers(
    csaId,
    { enabled: !hasSearchQuery }
  );
  
  const { data: searchResponse = [], isLoading: isLoadingSearch } = useSearchCustomers(
    csaId,
    debouncedSearchQuery,
    hasSearchQuery
  );

  const queryClient = useQueryClient();

  const navigate = useNavigate();

  // Debounce the search query with 0.5 second delay
  const [, cancel] = useDebounce(
    () => {
      setDebouncedSearchQuery(filterName);
    },
    500,
    [filterName]
  );

  // Immediately clear search if input is cleared (no debounce delay)
  useEffect(() => {
    if (filterName.trim().length === 0) {
      cancel();
      setDebouncedSearchQuery('');
    }
  }, [filterName, cancel]);

  // Determine which data source to use
  const customers = (
    hasSearchQuery
      ? ((searchResponse as AxiosResponse)?.data?.data?.customers || [])
      : ((cusResponse as AxiosResponse)?.data?.data?.customers || [])
  ) as Customer[];

  const isLoading = hasSearchQuery ? isLoadingSearch : isLoadingAll;

  // Apply sorting only (no filtering, as that's done on server)
  const dataFiltered: any[] = customers
    .slice()
    .sort(getComparator(table.order, table.orderBy));

  const notFound =
    (!dataFiltered.length && !!debouncedSearchQuery) || (!dataFiltered.length && !hasSearchQuery && !isLoading);

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

  const handleRowSelect = (row: any) => {
    table.onSelectRow(row.customerId);
    navigate(`/secured/travels/${row.customerId}`, { state: { name: row.name, email: row.email } });
  };

  const handleTravelSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    const formDataS = new FormData();
    formDataS.append('name', formData.name);
    formDataS.append('email', formData.email);
    formDataS.append('startingLocation', formData.startLocation);
    formDataS.append('destination', formData.destination);
    formDataS.append('travelDate', formData.travelDate.toISOString());
    formDataS.append('csa', csaId);

    // Type-safe file appender
    const appendMultipleFiles = (key: keyof FormDataType) => {
      const value = formData[key];
      if (Array.isArray(value)) {
        value.forEach((file) => {
          formDataS.append(key, file);
        });
      }
    };

    appendMultipleFiles('flights');
    appendMultipleFiles('hotels');
    appendMultipleFiles('vehicles');
    appendMultipleFiles('tourItineraries');
    appendMultipleFiles('transfers');
    appendMultipleFiles('cruiseDocs');
    appendMultipleFiles('otherCSADocs');

    createNewTravel(formDataS, {
      onSuccess: async (resData) => {
        toast.success('Travel added successfully');
        await queryClient.invalidateQueries({ queryKey: [QueryKeys.Customers] });
        handleClose();
      },
      onError: (error: any) => {
        console.error(error);
        toast.error(error?.response?.data?.message || 'An error occurred');
        handleClose();
      },
    });
  };

  const handleUserDelete = (userId: number) => {
    deleteUser(userId, {
      onSuccess: async (resData) => {
        if (resData) {
          toast.success('Customer deleted Successful');
          await queryClient.invalidateQueries({ queryKey: [QueryKeys.Customers] });
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

  return (
    <DashboardContent>
      <Box display="flex" alignItems="center" mb={5}>
        <Typography variant="h4" flexGrow={1}>
          Customers
        </Typography>
        <Button
          onClick={handleClickOpen}
          variant="contained"
          color="inherit"
          startIcon={<Iconify icon="mingcute:add-line" />}
        >
          New user
        </Button>
      </Box>

      <Card>
        <UserTableToolbar
          numSelected={table.selected.length}
          filterName={filterName}
          onFilterName={(event: React.ChangeEvent<HTMLInputElement>) => {
            setFilterName(event.target.value);
            table.onResetPage();
          }}
        />

        <Scrollbar>
          <TableContainer sx={{ overflow: 'unset' }}>
            <Table sx={{ minWidth: 800 }}>
              <UserTableHead
                order={table.order}
                orderBy={table.orderBy}
                rowCount={customers?.length}
                numSelected={table.selected.length}
                onSort={table.onSort}
                onSelectAllRows={(checked) =>
                  table.onSelectAllRows(
                    checked,
                    (customers || []).map((user) => String(user.id))
                  )
                }
                headLabel={[
                  { id: 'name', label: 'Name' },
                  { id: 'email', label: 'Email' },
                  { id: 'status', label: 'Status' },
                  { id: '' },
                ]}
              />
              <TableBody>
                {isLoading ? (
                  <TableRow>
                    <Box
                      sx={{
                        display: 'flex',
                        justifyContent: 'center',
                        alignItems: 'center',
                        minHeight: 200,
                        marginLeft: 50,
                      }}
                    >
                      <CircularProgress />
                    </Box>
                  </TableRow>
                ) : (
                  dataFiltered
                    .slice(
                      table.page * table.rowsPerPage,
                      table.page * table.rowsPerPage + table.rowsPerPage
                    )
                    .map((row, index) => (
                      <UserTableRow
                        key={index}
                        row={row}
                        selected={table.selected.includes(row.id)}
                        onSelectRow={() => handleRowSelect(row)}
                        handleDelete={handleUserDelete}
                      />
                    ))
                )}

                <TableEmptyRows
                  height={68}
                  emptyRows={emptyRows(table.page, table.rowsPerPage, dataFiltered.length)}
                />

                {notFound && <TableNoData searchQuery={debouncedSearchQuery || filterName} />}
              </TableBody>
            </Table>
          </TableContainer>
        </Scrollbar>

        <TablePagination
          component="div"
          page={table.page}
          count={customers?.length || [].length}
          rowsPerPage={table.rowsPerPage}
          onPageChange={table.onChangePage}
          rowsPerPageOptions={[5, 10, 25]}
          onRowsPerPageChange={table.onChangeRowsPerPage}
        />
      </Card>
      <Dialog open={open} onClose={handleClose}>
        <DialogTitle>Add New Customer</DialogTitle>
        <DialogContent>
          <UserAddNewTravel
            handleTravelSubmit={handleTravelSubmit}
            formData={formData}
            handleChange={handleChange}
            setFormData={setFormData}
            isPending={isPending || userLoading}
            handleClose={handleClose}
          />
        </DialogContent>
      </Dialog>
    </DashboardContent>
  );
}
