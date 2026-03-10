import { axiosInstance } from './api';

export interface SendOTPRequest {
  email: string;
  userType: 'CSA' | 'Customer';
}

export interface SendOTPResponse {
  success: boolean;
  message: string;
  data: {
    email: string;
    expiresIn: number;
    userType: string;
  };
}

export interface VerifyOTPRequest {
  email: string;
  otp: string;
  userType: 'CSA' | 'Customer';
}

export interface VerifyOTPResponse {
  success: boolean;
  message: string;
  data: {
    email: string;
    userType: string;
  };
}

export interface ResetPasswordRequest {
  email: string;
  newPassword: string;
  userType: 'CSA' | 'Customer';
}

export interface ResetPasswordResponse {
  success: boolean;
  message: string;
  data: {
    email: string;
    userType: string;
  };
}

export interface ResendOTPRequest {
  email: string;
  userType: 'CSA' | 'Customer';
}

// Send OTP for password reset
export const sendPasswordResetOTP = async (data: SendOTPRequest): Promise<SendOTPResponse> => {
  const response = await axiosInstance.post('/forgot-password/send-otp', data);
  return response.data;
};

// Verify OTP for password reset
export const verifyPasswordResetOTP = async (data: VerifyOTPRequest): Promise<VerifyOTPResponse> => {
  const response = await axiosInstance.post('/forgot-password/verify-otp', data);
  return response.data;
};

// Reset password with token
export const resetPassword = async (data: ResetPasswordRequest): Promise<ResetPasswordResponse> => {
  const response = await axiosInstance.post('/forgot-password/reset', data);
  return response.data;
};

// Resend OTP
export const resendPasswordResetOTP = async (data: ResendOTPRequest): Promise<SendOTPResponse> => {
  const response = await axiosInstance.post('/forgot-password/resend-otp', data);
  return response.data;
};

