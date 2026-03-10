import { toast } from 'sonner';
import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';

import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import CircularProgress from '@mui/material/CircularProgress';

import { useValidateSSOSession } from '../../backend/mutations/mutations';
import useAcornStore from '../../store/store';

// ----------------------------------------------------------------------

/**
 * Parse cardId from URL format: SSO=<cardId> or just <cardId>
 * The cardId can be passed directly or base64 encoded
 */
function parseSSOData(ssoParam: string): string | undefined {
  try {
    // Try to decode as base64 first (for backward compatibility)
    try {
      const decoded = atob(ssoParam);
      // If decoding succeeds, check if it looks like a cardId (no colons)
      if (!decoded.includes(':')) {
        return decoded;
      }
      // If it has colons, it's the old format - return undefined
      return undefined;
    } catch {
      // Not base64, use as-is
      return ssoParam;
    }
  } catch (error) {
    console.error('Error parsing SSO data:', error);
    return undefined;
  }
}

export function SSOLoginView() {
  const navigate = useNavigate();
  const { ssoData } = useParams<{ ssoData: string }>();
  const [error, setError] = useState<string | null>(null);

  const { mutate: validateSession, isPending } = useValidateSSOSession();
  const setAuthData = useAcornStore((state) => state.auth.setAuthData);

  useEffect(() => {
    if (!ssoData) {
      toast.error('Invalid SSO parameters');
      navigate('/sign-in');
      return;
    }

    // Extract SSO parameter (remove "SSO=" prefix if present)
    const ssoParam = ssoData.startsWith('SSO=') ? ssoData.substring(4) : ssoData;
    
    // Parse cardId from SSO data
    const cardId = parseSSOData(ssoParam);

    if (!cardId) {
      toast.error('Invalid SSO parameters - cardId not found');
      navigate('/sign-in');
      return;
    }

    // Validate card and authenticate with backend
    validateSession(
      { cardId },
      {
        onSuccess: (resData) => {
          if (resData && resData.success) {
            const { user, accessToken, refreshToken, isFirstTimeLogin } = resData.data;

            // Store auth data
            setAuthData({
              accessToken,
              refreshToken,
              name: user.name,
              email: user.email,
              mobile: user.mobile || '',
              csaId: user.csaId.toString(),
              userType: 'CSA',
              isAuthenticated: true,
            });

            // Route based on first-time login status
            if (isFirstTimeLogin) {
              // First-time login - route to sign-up
              toast.info('Please Register!');
              navigate('/sign-up', { 
                state: { 
                  isSSOUser: true, 
                  email: user.email,
                  name: user.name,
                  mobile: user.mobile,
                  csaId: user.csaId
                } 
              });
            } else {
              // Existing user - route to dashboard
              toast.success('Login successful!');
              navigate('/secured/user');
            }
          }
        },
        onError: (err: any) => {
          console.error('SSO validation error:', err);
          const errorMessage =
            err?.response?.data?.message ||
            err?.response?.data?.error?.message ||
            'Username or session is invalid';
          
          setError(errorMessage);
          toast.error(errorMessage);

          // Redirect to login page
          setTimeout(() => {
            navigate('/sign-in');
          }, 2000);
        },
      }
    );
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [ssoData]);

  if (error) {
    return (
      <Box
        display="flex"
        flexDirection="column"
        alignItems="center"
        justifyContent="center"
        minHeight="100vh"
        gap={3}
      >
        <CircularProgress size={60} color="error" />
        <Typography variant="h6" color="error">
          {error}
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Redirecting to login page...
        </Typography>
      </Box>
    );
  }

  return (
    <Box
      display="flex"
      flexDirection="column"
      alignItems="center"
      justifyContent="center"
      minHeight="100vh"
      gap={3}
    >
      <CircularProgress size={60} />
      <Typography variant="h5">Authenticating...</Typography>
      <Typography variant="body2" color="text.secondary">
        Please wait while we validate your session
      </Typography>
    </Box>
  );
}

