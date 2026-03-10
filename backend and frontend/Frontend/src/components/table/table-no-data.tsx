import type { TableRowProps } from '@mui/material/TableRow';

import Box from '@mui/material/Box';
import TableRow from '@mui/material/TableRow';
import TableCell from '@mui/material/TableCell';
import Typography from '@mui/material/Typography';

// ----------------------------------------------------------------------

type TableNoDataProps = TableRowProps & {
  searchQuery: string;
};

export function TableNoData({ searchQuery, ...other }: TableNoDataProps) {
  return (
    <TableRow {...other}>
      <TableCell align="center" colSpan={7}>
        <Box sx={{ py: 15, textAlign: 'center' }}>
          {searchQuery ? (
            <Typography variant="body2">
              No results found for &nbsp;
              <strong>&quot;{searchQuery}&quot;</strong>.
            </Typography>
          ) : (
            <Typography variant="subtitle1" align="center" sx={{ py: 5, color: 'text.secondary' }}>
              No data available
            </Typography>
          )}
        </Box>
      </TableCell>
    </TableRow>
  );
}
