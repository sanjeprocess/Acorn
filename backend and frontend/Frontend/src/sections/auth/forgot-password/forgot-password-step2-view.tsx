import { useState, useEffect } from 'react';

import Box from '@mui/material/Box';
import Link from '@mui/material/Link';
import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import LoadingButton from '@mui/lab/LoadingButton';

import { useRouter, useSearchParams } from 'src/routes/hooks';

import { useVerifyPasswordResetOTP, useResendPasswordResetOTP } from 'src/backend/mutations/forgotPasswordMutations';

import { Iconify } from 'src/components/iconify';

// ----------------------------------------------------------------------

export function ForgotPasswordStep2View() {
  const router = useRouter();
  const [searchParams] = useSearchParams();
  const { mutate: verifyOTP, isPending: isVerifying } = useVerifyPasswordResetOTP();
  const { mutate: resendOTP, isPending: isResending } = useResendPasswordResetOTP();

  const email = searchParams.get('email') || '';
  const userType = 'CSA';

  const [otp, setOtp] = useState('');
  const [otpError, setOtpError] = useState('');
  const [timeLeft, setTimeLeft] = useState(60); // 1 minute in seconds
  const [canResend, setCanResend] = useState(false);

  // Countdown timer
  useEffect(() => {
    if (timeLeft > 0) {
      const timer = setTimeout(() => setTimeLeft(timeLeft - 1), 1000);
      return () => clearTimeout(timer);
    }
    setCanResend(true);
    return undefined;
  }, [timeLeft]);

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  const validateOTP = (otpValue: string) => {
    if (!otpValue) {
      setOtpError('OTP is required');
      return false;
    }
    if (!/^\d{6}$/.test(otpValue)) {
      setOtpError('OTP must be a 6-digit number');
      return false;
    }
    setOtpError('');
    return true;
  };

  const handleVerifyOTP = () => {
    if (!validateOTP(otp)) {
      return;
    }

    verifyOTP(
      { email, otp, userType },
      {
        onSuccess: (response) => {
          // Navigate to password reset step
          router.push(`/forgot-password/reset?email=${encodeURIComponent(email)}&userType=CSA`);
        },
        onError: (error: any) => {
          console.error('Verify OTP error:', error);
        },
      }
    );
  };

  const handleResendOTP = () => {
    resendOTP(
      { email, userType },
      {
        onSuccess: () => {
          setTimeLeft(60); // Reset timer to 1 minute (matching OTP expiration)
          setCanResend(false);
          setOtp('');
          setOtpError('');
        },
        onError: (error: any) => {
          console.error('Resend OTP error:', error);
        },
      }
    );
  };

  const handleGoBack = () => {
    router.push('/forgot-password');
  };

  if (!email) {
    return (
      <Box sx={{ maxWidth: 500, mx: 'auto', mt: 4, p: 4, textAlign: 'center' }}>
        <Alert severity="error" sx={{ mb: 2 }}>
          Invalid request. Please start the password reset process again.
        </Alert>
        <Button variant="contained" onClick={handleGoBack}>
          Go Back
        </Button>
      </Box>
    );
  }

  return (
    <Box sx={{ maxWidth: 500, mx: 'auto', mt: 4, p: 4 }}>
      <Box display="flex" flexDirection="column" alignItems="center" sx={{ mb: 4 }}>
        <Iconify
          icon="solar:shield-check-bold"
          width={64}
          sx={{ color: 'primary.main', mb: 2 }}
        />
        <Typography variant="h4" component="h1" gutterBottom>
          Verify Your Email
        </Typography>
        <Typography variant="body2" color="text.secondary" textAlign="center">
          We&apos;ve sent a 6-digit verification code to{' '}
          <Typography component="span" variant="body2" fontWeight="bold">
            {email}
          </Typography>
        </Typography>
      </Box>

      <Box component="form" sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
          <TextField
            fullWidth
            name="otp"
            label="Verification Code"
            value={otp}
            onChange={(e) => {
              const value = e.target.value.replace(/\D/g, '').slice(0, 6);
              setOtp(value);
              if (otpError) setOtpError('');
            }}
            placeholder="Enter 6-digit code"
            error={!!otpError}
            helperText={otpError}
            InputLabelProps={{ shrink: true }}
            disabled={isVerifying}
            inputProps={{
              maxLength: 6,
              style: { textAlign: 'center', fontSize: '1.5rem', letterSpacing: '0.5rem' }
            }}
          />

          {timeLeft > 0 && (
            <Typography variant="body2" color="text.secondary" textAlign="center">
              Code expires in: <strong>{formatTime(timeLeft)}</strong>
            </Typography>
          )}

          <LoadingButton
            fullWidth
            size="large"
            loading={isVerifying}
            loadingPosition="center"
            type="button"
            color="primary"
            variant="contained"
            onClick={handleVerifyOTP}
            disabled={!otp || !!otpError || otp.length !== 6}
          >
            Verify Code
          </LoadingButton>

          <Box textAlign="center">
            {canResend ? (
              <LoadingButton
                loading={isResending}
                onClick={handleResendOTP}
                variant="text"
                color="primary"
              >
                Resend Code
              </LoadingButton>
            ) : (
              <Typography variant="body2" color="text.secondary">
                Didn&apos;t receive the code?{' '}
                <Typography
                  component="span"
                  variant="body2"
                  color="text.secondary"
                >
                  Resend available in {formatTime(timeLeft)}
                </Typography>
              </Typography>
            )}
          </Box>

          <Box textAlign="center">
            <Link
              component="button"
              variant="body2"
              onClick={handleGoBack}
              sx={{ textDecoration: 'none' }}
            >
              ← Back to email input
            </Link>
          </Box>
      </Box>
    </Box>
  );
}

