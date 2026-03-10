import { useState, useCallback } from 'react';

import Box from '@mui/material/Box';
import Avatar from '@mui/material/Avatar';
import { Typography } from '@mui/material';
import Popover from '@mui/material/Popover';
import TableRow from '@mui/material/TableRow';
import MenuList from '@mui/material/MenuList';
import TableCell from '@mui/material/TableCell';
import IconButton from '@mui/material/IconButton';
import MenuItem, { menuItemClasses } from '@mui/material/MenuItem';

import { Iconify } from 'src/components/iconify';

import { Label } from '../../components/label';

// ----------------------------------------------------------------------

export type UserProps = {
  customerId: string;
  name: string;
  email: string;
};

type UserTableRowProps = {
  row: UserProps;
  selected: boolean;
  onSelectRow: () => void;
  handleDelete: (userId: number) => void;
};

export function UserTableRow({ row, selected, onSelectRow, handleDelete }: UserTableRowProps) {
  const [openPopover, setOpenPopover] = useState<HTMLButtonElement | null>(null);

  const handleOpenPopover = useCallback((event: React.MouseEvent<HTMLButtonElement>) => {
    setOpenPopover(event.currentTarget);
  }, []);

  const handleClosePopover = useCallback(() => {
    setOpenPopover(null);
  }, []);

   const onDeleteClick = useCallback((id: number) => {
    handleDelete(id);
    handleClosePopover();
  }, [handleDelete, handleClosePopover]);


  return (
    <>
      <TableRow hover tabIndex={-1} role="checkbox" selected={selected}>

        <TableCell component="th" scope="row" onClick={onSelectRow}>
           <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
        <Avatar sx={{ bgcolor: 'primary.main' }}>
          {row.name.charAt(0)}
        </Avatar>

        <Box>
          <Typography variant="subtitle1" fontWeight={600}>
            {row.name}
          </Typography>
          <Typography variant="body2" color="text.secondary">
            {row.email}
          </Typography>
        </Box>
          </Box>
        </TableCell>

        <TableCell>{row.email}</TableCell>

        <TableCell>
          <Label color="success">active</Label>
        </TableCell>

        <TableCell align="right">
          <IconButton onClick={handleOpenPopover} >
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
          <MenuItem onClick= {() => onDeleteClick(Number(row.customerId))} sx={{ color: 'error.main' }} >
            <Iconify icon="solar:trash-bin-trash-bold" />
            Delete
          </MenuItem>
        </MenuList>
      </Popover>
    </>
  );
}
