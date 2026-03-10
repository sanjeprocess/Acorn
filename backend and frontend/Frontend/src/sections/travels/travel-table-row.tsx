import { useState, useCallback } from 'react';

import Popover from '@mui/material/Popover';
import TableRow from '@mui/material/TableRow';
import MenuList from '@mui/material/MenuList';
import TableCell from '@mui/material/TableCell';
import IconButton from '@mui/material/IconButton';
import MenuItem, { menuItemClasses } from '@mui/material/MenuItem';

import { Iconify } from 'src/components/iconify';

import { Label } from '../../components/label';

// ----------------------------------------------------------------------

export type TravelProps = {
  travelId: number;
  startingLocation: string;
  destination: string;
  travelDate: string;
  travelStatus: string;
};

type TravelTableRowProps = {
  row: TravelProps;
  selected: boolean;
  onSelectRow: () => void;
  handleEdit: (id: number) => void;
  handleDelete: (id: number) => void;
};

export function TravelTableRow({ row, selected, onSelectRow, handleEdit, handleDelete  }: TravelTableRowProps) {
  const [openPopover, setOpenPopover] = useState<HTMLButtonElement | null>(null);

  const handleOpenPopover = useCallback((event: React.MouseEvent<HTMLButtonElement>) => {
    setOpenPopover(event.currentTarget);
  }, []);

  const handleClosePopover = useCallback(() => {
    setOpenPopover(null);
  }, []);

  const onEditClick = useCallback((id: number) => {
    handleEdit(id);
    handleClosePopover();
  }, [handleEdit, handleClosePopover]);

  const onDeleteClick = useCallback((id: number) => {
    handleDelete(id);
    handleClosePopover();
  }, [handleDelete, handleClosePopover]);

  return (
    <>
      <TableRow hover tabIndex={-1} role="checkbox" selected={selected}>

        <TableCell>{row.travelId}</TableCell>

        <TableCell>{row.startingLocation}</TableCell>
        <TableCell>{row.destination}</TableCell>
        <TableCell>{new Date(row.travelDate).toISOString().split('T')[0]}</TableCell>

        {/* <TableCell>{row.role}</TableCell>

        <TableCell align="center">
          {row.isVerified ? (
            <Iconify width={22} icon="solar:check-circle-bold" sx={{ color: 'success.main' }} />
          ) : (
            '-'
          )}
        </TableCell> */}

        <TableCell>
          {row.travelStatus === 'COMPLETED' ? (
            <Label color="success">Completed</Label>
          ) : (
            <Label color="error">On Going</Label>
          )}
        </TableCell>

        <TableCell align="right">
          <IconButton onClick={handleOpenPopover}>
            <Iconify icon="eva:more-vertical-fill" />
          </IconButton>
        </TableCell>
      </TableRow>

      <Popover
        open={!!openPopover}
        anchorEl={openPopover}
        onClose={handleClosePopover}
        anchorOrigin={{ vertical: 'top', horizontal: 'left' }}
        transformOrigin={{ vertical: 'top', horizontal: 'right' }}
      >
        <MenuList
          disablePadding
          sx={{
            p: 0.5,
            gap: 0.5,
            width: 140,
            display: 'flex',
            flexDirection: 'column',
            [`& .${menuItemClasses.root}`]: {
              px: 1,
              gap: 2,
              borderRadius: 0.75,
              [`&.${menuItemClasses.selected}`]: { bgcolor: 'action.selected' },
            },
          }}
        >
          <MenuItem onClick={()=> onEditClick(row.travelId)} sx={{ color: 'text.secondary' }}>
            <Iconify icon="solar:pen-bold" />
            Edit
          </MenuItem>

          <MenuItem onClick={() => onDeleteClick(row.travelId)} sx={{ color: 'error.main' }}>
            <Iconify icon="solar:trash-bin-trash-bold" />
            Delete
          </MenuItem>
        </MenuList>
      </Popover>
    </>
  );
}
