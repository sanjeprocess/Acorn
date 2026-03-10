import { toast } from "sonner";
import { useMutation } from "@tanstack/react-query";

import {
  resetPassword,
  type SendOTPRequest,
  sendPasswordResetOTP,
  type VerifyOTPRequest,
  type ResendOTPRequest,
  verifyPasswordResetOTP,
  resendPasswordResetOTP,
  type ResetPasswordRequest
} from "../api/forgotPasswordApi";

// Send OTP mutation
export const useSendPasswordResetOTP = () => useMutation({
  mutationFn: (data: SendOTPRequest) => sendPasswordResetOTP(data),
  onSuccess: (response) => {
    toast.success(response.message);
  },
  onError: (error: any) => {
    const errorMessage = error?.response?.data?.error?.message || 
                        error?.response?.data?.message || 
                        'Failed to send OTP. Please try again.';
    toast.error(errorMessage);
  },
});

// Verify OTP mutation
export const useVerifyPasswordResetOTP = () => useMutation({
  mutationFn: (data: VerifyOTPRequest) => verifyPasswordResetOTP(data),
  onSuccess: (response) => {
    toast.success(response.message);
  },
  onError: (error: any) => {
    const errorMessage = error?.response?.data?.error?.message || 
                        error?.response?.data?.message || 
                        'Invalid or expired OTP. Please try again.';
    toast.error(errorMessage);
  },
});

// Reset password mutation
export const useResetPassword = () => useMutation({
  mutationFn: (data: ResetPasswordRequest) => resetPassword(data),
  onError: (error: any) => {
    const errorMessage = error?.response?.data?.error?.message || 
                        error?.response?.data?.message || 
                        'Password reset failed. Please try again.';
    toast.error(errorMessage);
  },
});

// Resend OTP mutation
export const useResendPasswordResetOTP = () => useMutation({
  mutationFn: (data: ResendOTPRequest) => resendPasswordResetOTP(data),
  onSuccess: (response) => {
    toast.success(response.message);
  },
  onError: (error: any) => {
    const errorMessage = error?.response?.data?.error?.message || 
                        error?.response?.data?.message || 
                        'Failed to resend OTP. Please try again.';
    toast.error(errorMessage);
  },
});

