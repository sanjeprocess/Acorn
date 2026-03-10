import { toast } from 'sonner';
import { useState, useEffect } from 'react';

import Box from '@mui/material/Box';
import Link from '@mui/material/Link';
import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import IconButton from '@mui/material/IconButton';
import LoadingButton from '@mui/lab/LoadingButton';
import InputAdornment from '@mui/material/InputAdornment';
import LinearProgress from '@mui/material/LinearProgress';

import { useRouter, useSearchParams } from 'src/routes/hooks';

import { useResetPassword } from 'src/backend/mutations/forgotPasswordMutations';

import { Iconify } from 'src/components/iconify';

// ----------------------------------------------------------------------

export function ForgotPasswordStep3View() {
  const router = useRouter();
  const [searchParams] = useSearchParams();
  const { mutate: resetPassword, isPending } = useResetPassword();

  const email = searchParams.get('email') || '';
  const userType = 'CSA';

  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [passwordError, setPasswordError] = useState('');
  const [confirmPasswordError, setConfirmPasswordError] = useState('');
  const [passwordStrength, setPasswordStrength] = useState(0);

  // Password strength calculation
  useEffect(() => {
    if (!password) {
      setPasswordStrength(0);
      return;
    }

    let strength = 0;
    if (password.length >= 6) strength += 20;
    if (password.length >= 8) strength += 20;
    if (/[a-z]/.test(password)) strength += 20;
    if (/[A-Z]/.test(password)) strength += 20;
    if (/\d/.test(password)) strength += 20;

    setPasswordStrength(strength);
  }, [password]);

  const getPasswordStrengthColor = (strength: number) => {
    if (strength < 40) return 'error';
    if (strength < 80) return 'warning';
    return 'success';
  };

  const getPasswordStrengthText = (strength: number) => {
    if (strength < 40) return 'Weak';
    if (strength < 80) return 'Medium';
    return 'Strong';
  };

  const validatePassword = (passwordValue: string) => {
    if (!passwordValue) {
      setPasswordError('Password is required');
      return false;
    }
    if (passwordValue.length < 6) {
      setPasswordError('Password must be at least 6 characters long');
      return false;
    }
    if (!/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/.test(passwordValue)) {
      setPasswordError('Password must contain at least one lowercase letter, one uppercase letter, and one number');
      return false;
    }
    setPasswordError('');
    return true;
  };

  const validateConfirmPassword = (confirmPasswordValue: string) => {
    if (!confirmPasswordValue) {
      setConfirmPasswordError('Please confirm your password');
      return false;
    }
    if (confirmPasswordValue !== password) {
      setConfirmPasswordError('Passwords do not match');
      return false;
    }
    setConfirmPasswordError('');
    return true;
  };

  const handleSubmit = () => {
    const isPasswordValid = validatePassword(password);
    const isConfirmPasswordValid = validateConfirmPassword(confirmPassword);

    if (!isPasswordValid || !isConfirmPasswordValid) {
      return;
    }

    resetPassword(
      { email, newPassword: password, userType },
      {
        onSuccess: () => {
          toast.success('Password reset successfully! You can now sign in with your new password.');
          router.push('/sign-in');
        },
        onError: (error: any) => {
          console.error('Reset password error:', error);
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
            icon="solar:key-bold"
            width={64}
            sx={{ color: 'primary.main', mb: 2 }}
          />
          <Typography variant="h4" component="h1" gutterBottom>
            Create New Password
          </Typography>
          <Typography variant="body2" color="text.secondary" textAlign="center">
            Enter a new password for your account
          </Typography>
        </Box>

        <Box component="form" sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
          <Box>
            <TextField
              fullWidth
              name="password"
              label="New Password"
              type={showPassword ? 'text' : 'password'}
              value={password}
              onChange={(e) => {
                setPassword(e.target.value);
                if (passwordError) setPasswordError('');
              }}
              placeholder="Enter your new password"
              error={!!passwordError}
              helperText={passwordError}
              InputLabelProps={{ shrink: true }}
              disabled={isPending}
              InputProps={{
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton
                      onClick={() => setShowPassword(!showPassword)}
                      edge="end"
                    >
                      <Iconify icon={showPassword ? 'solar:eye-bold' : 'solar:eye-closed-bold'} />
                    </IconButton>
                  </InputAdornment>
                ),
              }}
            />
            {password && (
              <Box sx={{ mt: 1 }}>
                <Box display="flex" justifyContent="space-between" alignItems="center" sx={{ mb: 0.5 }}>
                  <Typography variant="caption" color="text.secondary">
                    Password Strength
                  </Typography>
                  <Typography 
                    variant="caption" 
                    color={`${getPasswordStrengthColor(passwordStrength)}.main`}
                    fontWeight="bold"
                  >
                    {getPasswordStrengthText(passwordStrength)}
                  </Typography>
                </Box>
                <LinearProgress
                  variant="determinate"
                  value={passwordStrength}
                  color={getPasswordStrengthColor(passwordStrength)}
                  sx={{ height: 4, borderRadius: 2 }}
                />
              </Box>
            )}
          </Box>

          <TextField
            fullWidth
            name="confirmPassword"
            label="Confirm New Password"
            type={showConfirmPassword ? 'text' : 'password'}
            value={confirmPassword}
            onChange={(e) => {
              setConfirmPassword(e.target.value);
              if (confirmPasswordError) setConfirmPasswordError('');
            }}
            placeholder="Confirm your new password"
            error={!!confirmPasswordError}
            helperText={confirmPasswordError}
            InputLabelProps={{ shrink: true }}
            disabled={isPending}
            InputProps={{
              endAdornment: (
                <InputAdornment position="end">
                  <IconButton
                    onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                    edge="end"
                  >
                    <Iconify icon={showConfirmPassword ? 'solar:eye-bold' : 'solar:eye-closed-bold'} />
                  </IconButton>
                </InputAdornment>
              ),
            }}
          />

          <Alert severity="info" sx={{ mt: 2 }}>
            <Typography variant="body2">
              <strong>Password Requirements:</strong>
              <br />
              • At least 6 characters long
              <br />
              • Contains at least one lowercase letter
              <br />
              • Contains at least one uppercase letter
              <br />
              • Contains at least one number
            </Typography>
          </Alert>

          <LoadingButton
            fullWidth
            size="large"
            loading={isPending}
            loadingPosition="center"
            type="button"
            color="primary"
            variant="contained"
            onClick={handleSubmit}
            disabled={!password || !confirmPassword || !!passwordError || !!confirmPasswordError}
          >
            Reset Password
          </LoadingButton>

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
