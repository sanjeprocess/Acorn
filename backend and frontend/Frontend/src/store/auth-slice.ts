import type { StateCreator } from 'zustand';

import type { Store } from '../types/store';

// Define authentication state structure
export type AuthState = {
    accessToken: string;
    refreshToken: string;
    name: string;
    csaId: string;
    mobile: string;
    email: string;
    userType: 'CSA' | 'Customer' | null;
    isAuthenticated: boolean;
};

// Define authentication actions
type AuthAction = {
    setAuthData: (authData: Partial<AuthState>) => void;
    logOut: () => void;
    refreshAuthToken: () => Promise<boolean>;
    initializeAuth: () => void;
};

// Initial state for authentication
const initialAuthState: AuthState = {
    name: '',
    accessToken: '',
    refreshToken: '',
    csaId: '',
    mobile: '',
    email: '',
    userType: null,
    isAuthenticated: false,
};

// Define Zustand store slice for authentication
export type AuthSlice = AuthState & AuthAction;

// Helper functions for localStorage
const AUTH_STORAGE_KEY = 'acorn_auth_data';

const saveAuthToStorage = (authData: AuthState) => {
    try {
        localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(authData));
    } catch (error) {
        console.error('Failed to save auth data to localStorage:', error);
    }
};

const loadAuthFromStorage = (): AuthState | null => {
    try {
        const stored = localStorage.getItem(AUTH_STORAGE_KEY);
        return stored ? JSON.parse(stored) : null;
    } catch (error) {
        console.error('Failed to load auth data from localStorage:', error);
        return null;
    }
};

const clearAuthFromStorage = () => {
    try {
        localStorage.removeItem(AUTH_STORAGE_KEY);
    } catch (error) {
        console.error('Failed to clear auth data from localStorage:', error);
    }
};

export const createAuthSlice: StateCreator<
    Store,
    [['zustand/immer', never]], // Zustand middleware type
    [],
    AuthSlice
> = (set, get) => ({
    ...initialAuthState,

    // Initialize auth from localStorage
    initializeAuth: () => {
        const storedAuth = loadAuthFromStorage();
        if (storedAuth && storedAuth.accessToken) {
            set((state) => {
                Object.assign(state.auth, {
                    ...storedAuth,
                    isAuthenticated: true
                });
            });
        }
    },

    // Set authentication data
    setAuthData: (authData) => {
        const newAuthState = {
            ...get().auth,
            ...authData,
            isAuthenticated: true
        };
        
        set((state) => {
            Object.assign(state.auth, newAuthState);
        });
        
        saveAuthToStorage(newAuthState);
    },

    // Refresh token function
    refreshAuthToken: async (): Promise<boolean> => {
        const { refreshToken } = get().auth;
        if (!refreshToken) return false;
        
        try {
            const response = await fetch(`${import.meta.env.VITE_API_URL}/api/v1/auth/refreshToken`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ refreshToken }),
            });
            
            if (response.ok) {
                const data = await response.json();
                get().auth.setAuthData({
                    accessToken: data.data.accessToken,
                    refreshToken: data.data.refreshToken,
                });
                return true;
            } 
                get().auth.logOut();
                return false;
            
        } catch (error) {
            console.error('Token refresh failed:', error);
            get().auth.logOut();
            return false;
        }
    },

    // Logout function: Reset to initial state
    logOut: () => {
        set((state) => {
            Object.assign(state.auth, initialAuthState);
        });
        clearAuthFromStorage();
    },
});
