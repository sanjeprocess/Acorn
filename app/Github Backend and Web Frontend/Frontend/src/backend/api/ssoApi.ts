import { axiosInstance } from './api';

/**
 * SSO Authentication API Functions
 */

export interface ValidateSessionRequest {
  cardId: string;
}

export interface ValidateSessionResponse {
  message: string;
  success: boolean;
  data: {
    user: {
      csaId: number;
      name: string;
      email: string;
      mobile: string | null;
    };
    accessToken: string;
    refreshToken: string;
    isFirstTimeLogin: boolean;
  };
}

export interface CheckUserExistsResponse {
  message: string;
  success: boolean;
  data: {
    exists: boolean;
    needsRegistration: boolean;
    csaId?: number;
    name?: string;
    email?: string;
    mobile?: string;
  };
}

/**
 * Validate WorkHub24 card and authenticate user
 * @param cardId - WorkHub24 card ID
 * @returns Promise with authentication data
 */
export const validateSession = async (
  cardId: string
): Promise<ValidateSessionResponse> => {
  const response = await axiosInstance.get<ValidateSessionResponse>(
    '/sso/validate-session',
    {
      params: { cardId },
      timeout: 120000, // 2 minutes timeout for SSO validation
    }
  );
  return response.data;
};

/**
 * Check if user exists and needs registration
 * @param email - User's email address
 * @returns Promise with user status
 */
export const checkUserExists = async (
  email: string
): Promise<CheckUserExistsResponse> => {
  const response = await axiosInstance.get<CheckUserExistsResponse>(
    '/sso/check-user',
    {
      params: { email },
    }
  );
  return response.data;
};

/**
 * Parse cardId from URL search params
 * @param searchParams - URLSearchParams object
 * @returns cardId string or null
 */
export const parseSSOParams = (searchParams: URLSearchParams) => {
  const cardId = searchParams.get('cardId');

  if (cardId) {
    return { cardId };
  }

  return null;
};

