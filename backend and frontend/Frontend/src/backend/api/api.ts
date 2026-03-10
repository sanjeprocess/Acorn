import type { AxiosError, AxiosResponse } from "axios";

import axios from "axios";
import { toast } from "sonner";

const baseURL = import.meta.env.VITE_API_URL;

// Create axios instances
export const axiosInstance = axios.create({
  baseURL,
  headers: {
    "Content-Type": "application/json"
  },
  timeout: 5000, // 2 minutes timeout
});

export const axiosMultiPartInstance = axios.create({
  baseURL,
  headers: {
    "Content-Type": "multipart/form-data"
  },
  timeout: 5000, // 2 minutes timeout for file uploads
});

// Request interceptor to add auth token
axiosInstance.interceptors.request.use(
  (config) => {
    // Get token from localStorage
    const authData = localStorage.getItem('acorn_auth_data');
    if (authData) {
      try {
        const parsed = JSON.parse(authData);
        if (parsed.accessToken) {
          config.headers.Authorization = `Bearer ${parsed.accessToken}`;
        }
      } catch (error) {
        console.error('Failed to parse auth data:', error);
      }
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor for automatic token refresh
axiosInstance.interceptors.response.use(
  (response: AxiosResponse) => response,
  async (error: AxiosError) => {
    const originalRequest = error.config as any;

    // Handle both 401 (Unauthorized) and 403 (Forbidden) for token expiration
    // 401 = missing/invalid token, 403 = expired token
    const isTokenError = error.response?.status === 401 || error.response?.status === 403;
    const errorData = error.response?.data as any;
    const isTokenExpired = errorData?.error?.message?.includes('expired') || 
                          errorData?.message?.includes('expired') ||
                          errorData?.message?.includes('Token verification failed');

    if (isTokenError && isTokenExpired && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        const authData = localStorage.getItem('acorn_auth_data');
        if (authData) {
          const parsed = JSON.parse(authData);
          if (parsed.refreshToken) {
            const response = await axios.post(`${baseURL}/auth/refreshToken`, {
              refreshToken: parsed.refreshToken
            });

            if (response.data.success) {
              const newAuthData = {
                ...parsed,
                accessToken: response.data.data.accessToken,
                refreshToken: response.data.data.refreshToken,
              };
              localStorage.setItem('acorn_auth_data', JSON.stringify(newAuthData));
              
              // Update Zustand store if available
              try {
                const useAcornStore = (await import('../../store/store')).default;
                useAcornStore.getState().auth.setAuthData({
                  accessToken: newAuthData.accessToken,
                  refreshToken: newAuthData.refreshToken,
                });
              } catch (storeError) {
                console.warn('Could not update auth store:', storeError);
              }
              
              // Retry original request with new token
              originalRequest.headers.Authorization = `Bearer ${newAuthData.accessToken}`;
              return await axiosInstance(originalRequest);
            }
          }
        }
      } catch (refreshError) {
        console.error('Token refresh failed:', refreshError);
        // Clear auth data and logout user
        localStorage.removeItem('acorn_auth_data');
        
        // Use Zustand store logout if available
        try {
          const useAcornStore = (await import('../../store/store')).default;
          useAcornStore.getState().auth.logOut();
        } catch (storeError) {
          console.warn('Could not access auth store for logout:', storeError);
        }
        
        // Redirect to login
        window.location.href = '/sign-in';
        return Promise.reject(refreshError);
      }
    }

    // Handle critical errors only (let components handle specific errors)
    if (error.code === 'ECONNABORTED') {
      toast.error('Request timeout. Please try again.');
    } else if (!navigator.onLine) {
      toast.error('No internet connection.');
    }

    return Promise.reject(error);
  }
);

// Apply same interceptors to multipart instance
axiosMultiPartInstance.interceptors.request.use(
  (config) => {
    const authData = localStorage.getItem('acorn_auth_data');
    if (authData) {
      try {
        const parsed = JSON.parse(authData);
        if (parsed.accessToken) {
          config.headers.Authorization = `Bearer ${parsed.accessToken}`;
        }
      } catch (error) {
        console.error('Failed to parse auth data:', error);
      }
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Apply response interceptor to multipart instance
axiosMultiPartInstance.interceptors.response.use(
  (response: AxiosResponse) => response,
  async (error: AxiosError) => {
    const originalRequest = error.config as any;

    // Handle both 401 (Unauthorized) and 403 (Forbidden) for token expiration
    const isTokenError = error.response?.status === 401 || error.response?.status === 403;
    const errorData = error.response?.data as any;
    const isTokenExpired = errorData?.error?.message?.includes('expired') || 
                          errorData?.message?.includes('expired') ||
                          errorData?.message?.includes('Token verification failed');

    if (isTokenError && isTokenExpired && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        const authData = localStorage.getItem('acorn_auth_data');
        if (authData) {
          const parsed = JSON.parse(authData);
          if (parsed.refreshToken) {
            const response = await axios.post(`${baseURL}/auth/refreshToken`, {
              refreshToken: parsed.refreshToken
            });

            if (response.data.success) {
              const newAuthData = {
                ...parsed,
                accessToken: response.data.data.accessToken,
                refreshToken: response.data.data.refreshToken,
              };
              localStorage.setItem('acorn_auth_data', JSON.stringify(newAuthData));
              
              // Update Zustand store if available
              try {
                const useAcornStore = (await import('../../store/store')).default;
                useAcornStore.getState().auth.setAuthData({
                  accessToken: newAuthData.accessToken,
                  refreshToken: newAuthData.refreshToken,
                });
              } catch (storeError) {
                console.warn('Could not update auth store:', storeError);
              }
              
              // Retry original request with new token
              originalRequest.headers.Authorization = `Bearer ${newAuthData.accessToken}`;
              return await axiosMultiPartInstance(originalRequest);
            }
          }
        }
      } catch (refreshError) {
        console.error('Token refresh failed:', refreshError);
        // Clear auth data and logout user
        localStorage.removeItem('acorn_auth_data');
        
        // Use Zustand store logout if available
        try {
          const useAcornStore = (await import('../../store/store')).default;
          useAcornStore.getState().auth.logOut();
        } catch (storeError) {
          console.warn('Could not access auth store for logout:', storeError);
        }
        
        // Redirect to login
        window.location.href = '/sign-in';
        return Promise.reject(refreshError);
      }
    }

    // Handle critical errors only (let components handle specific errors)
    if (error.code === 'ECONNABORTED') {
      toast.error('Request timeout. Please try again.');
    } else if (!navigator.onLine) {
      toast.error('No internet connection.');
    }

    return Promise.reject(error);
  }
);
