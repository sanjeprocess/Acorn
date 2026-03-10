import { toast } from 'sonner';
import { useState, useCallback } from 'react';

import Box from '@mui/material/Box';
import Link from '@mui/material/Link';
import TextField from '@mui/material/TextField';
import IconButton from '@mui/material/IconButton';
import Typography from '@mui/material/Typography';
import LoadingButton from '@mui/lab/LoadingButton';
import InputAdornment from '@mui/material/InputAdornment';

import { useRouter } from 'src/routes/hooks';

import { Iconify } from 'src/components/iconify';

import useAcornStore from '../../store/store';
import { useLogInCSA } from '../../backend/mutations/mutations';

// ----------------------------------------------------------------------

export function SignInView() {
  const router = useRouter();

  const [showPassword, setShowPassword] = useState(false);
  const { mutate: logInCsa, isPending } = useLogInCSA();

  const setAuthData = useAcornStore((state) => state.auth.setAuthData);

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSignIn = () => {
    if (!email || !password) {
        toast.error('Please enter email and password.');
        return;
    }

    // Basic email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        toast.error('Please enter a valid email address.');
        return;
    }

    logInCsa(
      { email, password },
      {
        onSuccess: (resData) => {
          if (resData?.data?.data) {
            const { user, accessToken, refreshToken } = resData.data.data;
            setAuthData({
              ...user,
              accessToken,
              refreshToken,
              userType: 'CSA'
            });
            toast.success("Login Successful");
            router.push('/secured/user');
          }
        },
        onError: (error: any) => {
          console.error('Login error:', error);
          const errorMessage = error?.response?.data?.error?.message || 
                              error?.response?.data?.message || 
                              'Login failed. Please try again.';
          toast.error(errorMessage);
        },
      }
    );
  };

  const handleGoToSignUp = useCallback(() => {
    router.push('/sign-up');
  }, [router]);

  const handleGoToForgotPassword = useCallback(() => {
    router.push('/forgot-password');
  }, [router]);

  const renderForm = (
    <Box display="flex" flexDirection="column" alignItems="flex-end">
      <TextField
        fullWidth
        name="email"
        label="Email address"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder='Enter a valid email address'
        InputLabelProps={{ shrink: true }}
        sx={{ mb: 3 }}
      />

      <TextField
        fullWidth
        name="password"
        label="Password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        placeholder='Enter a valid password'
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
        sx={{ mb: 2 }}
      />

      <Box display="flex" justifyContent="flex-end" sx={{ mb: 3 }}>
        <Link
          component="button"
          variant="body2"
          onClick={handleGoToForgotPassword}
          sx={{ textDecoration: 'none' }}
        >
          Forgot password?
        </Link>
      </Box>

      <LoadingButton
        fullWidth
        size="large"
        loading={isPending}
        loadingPosition="center"
        type="submit"
        color="inherit"
        variant="contained"
        onClick={handleSignIn}
      >
        Sign in
      </LoadingButton>
    </Box>
  );

  return (
    <>
      <Box gap={1.5} display="flex" flexDirection="column" alignItems="center" sx={{ mb: 5 }}>
        <Typography variant="h5">Sign in</Typography>
        <Typography variant="body2" color="text.secondary">
          Don’t have an account?
          <Link onClick={handleGoToSignUp} variant="subtitle2" sx={{ ml: 0.5 }}>
            Get started
          </Link>
        </Typography>
      </Box>

      {renderForm}
    </>
  );
}
