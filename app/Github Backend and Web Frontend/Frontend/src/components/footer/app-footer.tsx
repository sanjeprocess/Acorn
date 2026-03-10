import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';

import { CONFIG } from '../../config-global';

// ----------------------------------------------------------------------

export function AppFooter() {
  const version = CONFIG.appVersion;
  const currentYear = new Date().getFullYear();

  return (
    <Box
      component="footer"
      sx={{
        position: 'fixed',
        bottom: 0,
        left: 0,
        right: 0,
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        py: 1.5,
        px: 2,
        bgcolor: 'transparent',
        zIndex: (theme) => theme.zIndex.appBar - 1,
      }}
    >
      <Typography
        variant="caption"
        sx={{
          color: 'rgba(0, 0, 0, 0.87)',
          textAlign: 'center',
          fontSize: '0.75rem',
          fontWeight: 500,
        }}
      >
        v{version} @Acorn Travels © {currentYear}
      </Typography>
    </Box>
  );
}

