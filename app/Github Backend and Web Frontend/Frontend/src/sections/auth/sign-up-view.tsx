import { toast } from 'sonner';
import { useState, useCallback, useEffect } from 'react';
import { useLocation } from 'react-router-dom';

import Box from '@mui/material/Box';
import Link from '@mui/material/Link';
import Alert from '@mui/material/Alert';
import TextField from '@mui/material/TextField';
import IconButton from '@mui/material/IconButton';
import Typography from '@mui/material/Typography';
import LoadingButton from '@mui/lab/LoadingButton';
import InputAdornment from '@mui/material/InputAdornment';

import { useRouter } from 'src/routes/hooks';

import { Iconify } from 'src/components/iconify';

import useAcornStore from '../../store/store';
import { useRegisterCSA } from '../../backend/mutations/mutations';

// ----------------------------------------------------------------------

interface SSOUserState {
  isSSOUser: boolean;
  email: string;
  name: string;
  mobile: string;
  csaId: number;
}

export function SignUpView() {
  const router = useRouter();
  const location = useLocation();
  const ssoState = location.state as SSOUserState | null;

  const [showPassword, setShowPassword] = useState(false);
  const [name, setName] = useState(ssoState?.name || '');
  const [mobile, setMobile] = useState<Number | null>(ssoState?.mobile ? Number(ssoState.mobile) : null);
  const [email, setEmail] = useState(ssoState?.email || '');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');

  const { mutate: registerCSA, isPending } = useRegisterCSA();

  const setAuthData = useAcornStore((state) => state.auth.setAuthData);
  const authData = useAcornStore((state) => state.auth);

  // Check if this is an SSO user completing their profile
  const isSSOUser = ssoState?.isSSOUser || false;

  useEffect(() => {
    if (isSSOUser && ssoState) {
      // Pre-fill SSO user data
      setName(ssoState.name);
      setEmail(ssoState.email);
      if (ssoState.mobile) {
        setMobile(Number(ssoState.mobile));
      }
    }
  }, [isSSOUser, ssoState]);

  const handleGoToSignIn = useCallback(() => {
    router.push('/sign-in');
  }, [router]);

  const handleSSOUserComplete = () => {
    if (!password || !confirmPassword || !mobile) {
      toast.error('Please fill in all required fields (password, confirm password, and mobile number)');
      return;
    }

    if (password !== confirmPassword) {
      toast.error('Passwords do not match');
      return;
    }

    if (password.length < 6) {
      toast.error('Password must be at least 6 characters');
      return;
    }

    // Use registerCSA mutation - it will update existing CSA with temp password and mobile
    registerCSA(
      { email, password, name, mobile: mobile.toString() },
      {
        onSuccess: (resData) => {
          if (resData) {
            // Update auth data with new tokens
            setAuthData({
              ...resData.data.data.user,
              accessToken: resData.data.data.accessToken,
              refreshToken: resData.data.data.refreshToken,
              userType: 'CSA',
              isAuthenticated: true,
            });
            toast.success('Registration completed successfully!');
            router.push('/secured/user');
          }
        },
        onError: (error: any) => {
          console.error('Error completing SSO registration:', error);
          const errorMessage =
            error?.response?.data?.error?.message ||
            error?.response?.data?.message ||
            'Failed to complete registration';
          toast.error(errorMessage);
        },
      }
    );
  };

  const handleSignUp = () => {
    // If SSO user, use different handler
    if (isSSOUser) {
      handleSSOUserComplete();
      return;
    }

    // Regular CSA registration
    if (!email || !password || !confirmPassword || !mobile) {
      toast.error('Fill the sign up form.');
      return;
    }

    if (password !== confirmPassword) {
      toast.error('Passwords do not match');
      return;
    }

    registerCSA(
      { email, password, name, mobile },
      {
        onSuccess: (resData) => {
          if (resData) {
            setAuthData(resData.data.data.user);
            toast.success('Login Successful');
            router.push('/secured/user');
          }
        },
        onError: (error: any) => {
          const errorMessage =
            error?.response?.data?.error?.message ||
            error?.response?.data?.message ||
            'An error occurred';
          toast.error(errorMessage);
        },
      }
    );
  };

  const renderForm = (
    <Box display="flex" flexDirection="column" alignItems="flex-end">
      {isSSOUser && (
        <Alert severity="success" sx={{ mb: 3, width: '100%' }}>
          Welcome! Please complete your registration by setting a password.
        </Alert>
      )}
      
      <TextField
        fullWidth
        name="name"
        label="Name"
        value={name}
        onChange={(e) => setName(e.target.value)}
        placeholder="Enter name"
        InputLabelProps={{ shrink: true }}
        disabled={isSSOUser}
        sx={{ mb: 3 }}
      />
      <TextField
        fullWidth
        name="mobile"
        label="Mobile Number"
        value={mobile || ''}
        onChange={(e) => setMobile(Number(e.target.value))}
        type="number"
        placeholder="Enter your mobile number"
        InputLabelProps={{ shrink: true }}
        required={isSSOUser}
        sx={{ mb: 3 }}
      />
      <TextField
        fullWidth
        name="email"
        label="Email address"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="Enter a valid email address"
        InputLabelProps={{ shrink: true }}
        disabled={isSSOUser}
        sx={{ mb: 3 }}
      />
      <TextField
        fullWidth
        name="password"
        label="Password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        placeholder="Enter a valid password"
        InputLabelProps={{ shrink: true }}
        type={showPassword ? 'text' : 'password'}
        InputProps={{
          endAdornment: (
            <InputAdornment position="end">
              <IconButton onClick={() => setShowPassword(!showPassword)} edge="end">
                <Iconify icon={showPassword ? 'solar:eye-bold' : 'solar:eye-closed-bold'} />
              </IconButton>
            </InputAdornment>
          ),
        }}
        sx={{ mb: 3 }}
      />

      <TextField
        fullWidth
        name="confirmPassword"
        label="Confirm Password"
        placeholder="Confirm Password"
        value={confirmPassword}
        onChange={(e) => setConfirmPassword(e.target.value)}
        InputLabelProps={{ shrink: true }}
        type={showPassword ? 'text' : 'password'}
        InputProps={{
          endAdornment: (
            <InputAdornment position="end">
              <IconButton onClick={() => setShowPassword(!showPassword)} edge="end">
                <Iconify icon={showPassword ? 'solar:eye-bold' : 'solar:eye-closed-bold'} />
              </IconButton>
            </InputAdornment>
          ),
        }}
        sx={{ mb: 3 }}
      />

      <LoadingButton
        fullWidth
        size="large"
        type="submit"
        loading={isPending}
        loadingPosition="center"
        color="inherit"
        variant="contained"
        onClick={handleSignUp}
      >
        {isSSOUser ? 'Complete Registration' : 'Sign Up'}
      </LoadingButton>
    </Box>
  );

  return (
    <>
      <Box gap={1.5} display="flex" flexDirection="column" alignItems="center" sx={{ mb: 5 }}>
        <Typography variant="h5">
          {isSSOUser ? 'Complete Your Profile' : 'Sign up'}
        </Typography>
        {!isSSOUser && (
          <Typography variant="body2" color="text.secondary">
            Already have an account?
            <Link variant="subtitle2" onClick={handleGoToSignIn} sx={{ ml: 0.5 }}>
              Get started
            </Link>
          </Typography>
        )}
      </Box>

      {renderForm}
    </>
  );
}
