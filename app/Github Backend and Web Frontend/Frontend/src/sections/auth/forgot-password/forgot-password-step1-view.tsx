import { toast } from 'sonner';
import { useState } from 'react';

import Box from '@mui/material/Box';
import Link from '@mui/material/Link';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import LoadingButton from '@mui/lab/LoadingButton';

import { useRouter } from 'src/routes/hooks';

import { useSendPasswordResetOTP } from 'src/backend/mutations/forgotPasswordMutations';

import { Iconify } from 'src/components/iconify';

// ----------------------------------------------------------------------

export function ForgotPasswordStep1View() {
  const router = useRouter();
  const { mutate: sendOTP, isPending } = useSendPasswordResetOTP();

  const [email, setEmail] = useState('');
  const [emailError, setEmailError] = useState('');

  const validateEmail = (emailToValidate: string) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailToValidate) {
      setEmailError('Email is required');
      return false;
    }
    if (!emailRegex.test(emailToValidate)) {
      setEmailError('Please enter a valid email address');
      return false;
    }
    setEmailError('');
    return true;
  };

  const handleSubmit = () => {
    if (!validateEmail(email)) {
      return;
    }

    sendOTP(
      { email, userType: 'CSA' },
      {
        onSuccess: (response) => {
          // Navigate to OTP verification step
          router.push(`/forgot-password/verify?email=${encodeURIComponent(email)}&userType=CSA`);
        },
        onError: (error: any) => {
          console.error('Send OTP error:', error);
          // Error handling is already done in the mutation hook, no need to show toast here
        },
      }
    );
  };

  const handleGoToSignIn = () => {
    router.push('/sign-in');
  };

  return (
    <Box sx={{ maxWidth: 500, mx: 'auto', mt: 4, p: 4 }}>
        <Box display="flex" flexDirection="column" alignItems="center" sx={{ mb: 4 }}>
          <Iconify
            icon="solar:lock-password-bold"
            width={64}
            sx={{ color: 'primary.main', mb: 2 }}
          />
          <Typography variant="h4" component="h1" gutterBottom>
            Forgot Password?
          </Typography>
          <Typography variant="body2" color="text.secondary" textAlign="center">
            Don&apos;t worry! Enter your email address and we&apos;ll send you an OTP to reset your password.
          </Typography>
        </Box>

        <Box component="form" sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
          <TextField
            fullWidth
            name="email"
            label="Email Address"
            value={email}
            onChange={(e) => {
              setEmail(e.target.value);
              if (emailError) setEmailError('');
            }}
            placeholder="Enter your email address"
            error={!!emailError}
            helperText={emailError}
            InputLabelProps={{ shrink: true }}
            disabled={isPending}
          />

          <LoadingButton
            fullWidth
            size="large"
            loading={isPending}
            loadingPosition="center"
            type="button"
            color="primary"
            variant="contained"
            onClick={handleSubmit}
            disabled={!email || !!emailError}
          >
            Send Reset Code
          </LoadingButton>

          <Box textAlign="center">
            <Typography variant="body2" color="text.secondary">
              Remember your password?{' '}
              <Link
                component="button"
                variant="subtitle2"
                onClick={handleGoToSignIn}
                sx={{ textDecoration: 'none' }}
              >
                Sign in
              </Link>
            </Typography>
          </Box>
        </Box>
    </Box>
  );
}

