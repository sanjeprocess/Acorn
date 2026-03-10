import type { Theme, SxProps, Breakpoint } from '@mui/material/styles';

import { Box } from '@mui/material';

import { Main } from './main';
import { stylesMode } from '../../theme/styles';
import { HeaderSection } from '../core/header-section';
import { LayoutSection } from '../core/layout-section';
import { useRouter } from '../../routes/hooks';
import useAcornStore from '../../store/store';

// ----------------------------------------------------------------------

export type AuthLayoutProps = {
  sx?: SxProps<Theme>;
  children: React.ReactNode;
  header?: {
    sx?: SxProps<Theme>;
  };
};

export function AuthLayout({ sx, children, header }: AuthLayoutProps) {
  const layoutQuery: Breakpoint = 'md';
  const router = useRouter();
  const isAuthenticated = useAcornStore((state) => state.auth.isAuthenticated);

  const handleLogoClick = () => {
    if (isAuthenticated) {
      router.push('/secured/user');
    } else {
      router.push('/sign-in');
    }
  };

  return (
    <LayoutSection
      /** **************************************
       * Header
       *************************************** */
      headerSection={
        <HeaderSection
          layoutQuery={layoutQuery}
          slotProps={{
            container: { maxWidth: false },
            toolbar: { sx: { bgcolor: 'transparent', backdropFilter: 'unset' } },
          }}
          sx={{
            position: { [layoutQuery]: 'fixed' },

            ...header?.sx,
          }}
          slots={{
            leftArea: (
              <Box sx={{ mb: 3, display: 'flex', justifyContent: 'center' }}>
                <Box
                  component="img"
                  src="/assets/logo.png"
                  alt="logo"
                  onClick={handleLogoClick}
                  sx={{
                    height: 40,
                    maxWidth: '100%',
                    objectFit: 'contain',
                    cursor: 'pointer',
                    '&:hover': {
                      opacity: 0.8,
                    },
                  }}
                />
              </Box>
            ),
          }}
        />
      }
      /** **************************************
       * Footer
       *************************************** */
      footerSection={null}
      /** **************************************
       * Style
       *************************************** */
      cssVars={{ '--layout-auth-content-width': '420px' }}
      sx={{
        '&::before': {
          width: 1,
          height: 1,
          zIndex: -1,
          content: "''",
          opacity: 0.24,
          position: 'fixed',
          backgroundSize: 'cover',
          backgroundRepeat: 'no-repeat',
          backgroundPosition: 'center center',
          backgroundImage: `url(/assets/background/overlay.jpg)`,
          [stylesMode.dark]: { opacity: 0.08 },
        },
        ...sx,
      }}
    >
      <Main layoutQuery={layoutQuery}>{children}</Main>
    </LayoutSection>
  );
}
