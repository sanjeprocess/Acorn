# Frontend Code Review: Best Practices Violations & Fixes

## 🔴 Critical Issues Leading to Multiple Toasts/Snackbars

### 1. **React StrictMode Causing Duplicate Requests**
**Location:** `Frontend/src/main.tsx:38`
**Issue:** StrictMode causes components to mount twice in development, leading to duplicate API calls and toasts.

**Current Code:**
```tsx
root.render(
  <StrictMode>
    <HelmetProvider>
    <QueryClientProvider client={queryClient}>
    ...
```

**Fix:** Add guards in useEffect hooks to prevent duplicate execution, OR remove StrictMode (not recommended for production).

**Recommended Fix:** Keep StrictMode but add proper guards in components.

---

### 2. **SSO Login View Missing Duplicate Request Guard**
**Location:** `Frontend/src/sections/auth/sso-login-view.tsx:54-133`
**Issue:** useEffect runs on every render and can trigger multiple validation requests, especially with StrictMode.

**Current Code:**
```tsx
useEffect(() => {
  if (!ssoData) {
    toast.error('Invalid SSO parameters');
    navigate('/sign-in');
    return;
  }
  // ... validation logic runs every time
}, [ssoData]); // Missing dependencies and guard
```

**Fix:**
```tsx
const hasValidatedRef = useRef(false);

useEffect(() => {
  // Prevent duplicate calls
  if (hasValidatedRef.current || isPending) {
    return;
  }

  if (!ssoData) {
    toast.error('Invalid SSO parameters');
    navigate('/sign-in');
    return;
  }

  // ... rest of logic
  
  hasValidatedRef.current = true;
  validateSession(/* ... */);
}, [ssoData, navigate, validateSession, isPending]);
```

---

### 3. **Duplicate Toast Notifications in Error Handling**
**Location:** Multiple files
**Issue:** Errors are shown both in Axios interceptors AND component error handlers, causing duplicate toasts.

**Files Affected:**
- `Frontend/src/backend/api/api.ts:87-91` (Interceptor shows toast)
- `Frontend/src/sections/auth/sign-in-view.tsx:66` (Component shows toast)
- `Frontend/src/sections/user/view/user-view.tsx:177` (Component shows toast)
- `Frontend/src/sections/travels/view/travel-view.tsx:233` (Component shows toast)

**Current Pattern:**
```tsx
// In api.ts interceptor
if (error.code === 'ECONNABORTED') {
  toast.error('Request timeout. Please try again.');
}

// In component
onError: (error: any) => {
  toast.error(error?.response?.data?.message || 'An error occurred');
}
```

**Fix:** Remove generic error toasts from interceptors. Only show toasts for network-level errors (timeout, offline). Let components handle API errors.

**Recommended:** Keep only network errors in interceptors:
```tsx
// In api.ts - ONLY network errors
if (error.code === 'ECONNABORTED') {
  toast.error('Request timeout. Please try again.');
} else if (!navigator.onLine) {
  toast.error('No internet connection.');
}
// Don't show toasts for 4xx/5xx - let components handle
```

---

## 🟡 Code Duplication Issues

### 4. **Duplicate Travel Form Submission Logic**
**Location:** 
- `Frontend/src/sections/user/view/user-view.tsx:140-181`
- `Frontend/src/sections/travels/view/travel-view.tsx:200-237`

**Issue:** Nearly identical FormData creation and submission logic duplicated in two files.

**Current Duplication:**
- Same `handleTravelSubmit` function
- Same FormData building logic
- Same file appending logic
- Same error handling

**Fix:** Extract to a shared hook or utility:
```tsx
// Create: Frontend/src/hooks/useTravelForm.ts
export function useTravelForm(csaId: string) {
  const { mutate: createNewTravel, isPending } = useNewTravel();
  const queryClient = useQueryClient();

  const buildFormData = (formData: FormDataType, isEditMode: boolean, travelId?: number) => {
    const formDataS = new FormData();
    formDataS.append('name', formData.name);
    formDataS.append('email', formData.email);
    formDataS.append('startingLocation', formData.startLocation);
    formDataS.append('destination', formData.destination);
    formDataS.append('travelDate', formData.travelDate.toISOString());
    formDataS.append('csa', csaId);

    const fileFields = [
      { field: 'flights', urls: 'existingFlightUrls' },
      { field: 'hotels', urls: 'existingHotelUrls' },
      // ... rest of fields
    ];

    fileFields.forEach(({ field, urls }) => {
      (formData[field as keyof FormDataType] as File[]).forEach((file) => {
        formDataS.append(field, file);
      });
      const urlArray = formData[urls as keyof FormDataType] as string[];
      formDataS.append(field, JSON.stringify(urlArray));
    });

    if (isEditMode && travelId) {
      formDataS.append('travelId', travelId.toString());
    }

    return formDataS;
  };

  const submitTravel = (formData: FormDataType, isEditMode: boolean, travelId?: number, onSuccess?: () => void) => {
    const formDataS = buildFormData(formData, isEditMode, travelId);
    
    createNewTravel(formDataS, {
      onSuccess: async (resData) => {
        toast.success(isEditMode ? 'Travel updated successfully' : 'Travel added successfully');
        await queryClient.invalidateQueries({ queryKey: [QueryKeys.TravelHistory] });
        onSuccess?.();
      },
      onError: (error: any) => {
        console.error(error);
        toast.error(error?.response?.data?.message || 'An error occurred');
      },
    });
  };

  return { submitTravel, isPending };
}
```

---

### 5. **Duplicate Error Message Extraction**
**Location:** Multiple components
**Issue:** Same error message extraction pattern repeated across files.

**Current Pattern (repeated 10+ times):**
```tsx
const errorMessage = 
  error?.response?.data?.error?.message || 
  error?.response?.data?.message || 
  'An error occurred';
```

**Fix:** Create utility function:
```tsx
// Create: Frontend/src/utils/error-handler.ts
export function extractErrorMessage(error: any, defaultMessage = 'An error occurred'): string {
  return error?.response?.data?.error?.message || 
         error?.response?.data?.message || 
         error?.message ||
         defaultMessage;
}
```

**Usage:**
```tsx
onError: (error: any) => {
  toast.error(extractErrorMessage(error, 'Login failed. Please try again.'));
}
```

---

### 6. **Duplicate FormData Initialization**
**Location:**
- `Frontend/src/sections/user/view/user-view.tsx:78-105`
- `Frontend/src/sections/travels/view/travel-view.tsx:76-103`

**Issue:** Same `initialFormData` object duplicated.

**Fix:** Extract to shared constant:
```tsx
// Create: Frontend/src/constants/travelForm.ts
export const INITIAL_TRAVEL_FORM_DATA: FormDataType = {
  name: '',
  email: '',
  startLocation: '',
  destination: '',
  travelDate: new Date(),
  flights: [],
  existingFlightUrls: [],
  // ... rest of fields
};
```

---

## 🟠 Best Practice Violations

### 7. **Missing useEffect Dependencies**
**Location:** Multiple files
**Issue:** useEffect hooks missing dependencies, causing stale closures or unnecessary re-renders.

**Examples:**
- `Frontend/src/sections/auth/sso-login-view.tsx:132` - Missing `navigate`, `validateSession`, `setAuthData`
- `Frontend/src/sections/auth/sign-up-view.tsx:62` - Missing `ssoState` properties in dependency check

**Fix:** Add all dependencies or use `useCallback` for functions:
```tsx
const validateSession = useCallback((data) => {
  // ... validation logic
}, [/* dependencies */]);

useEffect(() => {
  // ... use validateSession
}, [ssoData, validateSession, navigate]);
```

---

### 8. **Toast Notifications in Mutation Hooks**
**Location:** `Frontend/src/backend/mutations/forgotPasswordMutations.ts`
**Issue:** Toasts in mutation hooks cause duplicate notifications when components also show toasts.

**Current Code:**
```tsx
export const useSendPasswordResetOTP = () => useMutation({
  mutationFn: (data: SendOTPRequest) => sendPasswordResetOTP(data),
  onSuccess: (response) => {
    toast.success(response.message); // ❌ Toast in hook
  },
  onError: (error: any) => {
    toast.error(errorMessage); // ❌ Toast in hook
  },
});
```

**Fix:** Remove toasts from hooks, let components handle them:
```tsx
export const useSendPasswordResetOTP = () => useMutation({
  mutationFn: (data: SendOTPRequest) => sendPasswordResetOTP(data),
  // Remove onSuccess/onError toasts - let components handle
});
```

**Then in components:**
```tsx
const { mutate: sendOTP } = useSendPasswordResetOTP();

sendOTP(data, {
  onSuccess: (response) => {
    toast.success(response.message); // ✅ Component handles toast
  },
  onError: (error) => {
    toast.error(extractErrorMessage(error));
  },
});
```

---

### 9. **Inconsistent Error Handling**
**Location:** Multiple files
**Issue:** Different error message extraction patterns across components.

**Patterns Found:**
1. `error?.response?.data?.error?.message || error?.response?.data?.message`
2. `error?.response?.data?.message || 'An error occurred'`
3. `error?.response?.data?.error?.message || error?.response?.data?.message || 'Login failed'`

**Fix:** Standardize using the utility function from Issue #5.

---

### 10. **Missing Loading States in Some Components**
**Location:** `Frontend/src/sections/auth/sign-up-view.tsx:68-110`
**Issue:** `handleSSOUserComplete` uses `isSubmitting` but doesn't prevent double submissions.

**Fix:** Add guard:
```tsx
const handleSSOUserComplete = async () => {
  if (isSubmitting) return; // Prevent double submission
  
  // ... rest of logic
};
```

---

## 📋 Summary of Recommended Fixes

### Priority 1 (Critical - Causes Multiple Toasts):
1. ✅ Add duplicate request guard to SSO login view
2. ✅ Remove generic error toasts from Axios interceptors
3. ✅ Remove toasts from mutation hooks (forgotPasswordMutations.ts)

### Priority 2 (Code Quality - Reduces Duplication):
4. ✅ Extract travel form submission to shared hook
5. ✅ Create error message extraction utility
6. ✅ Extract initial form data to shared constant

### Priority 3 (Best Practices):
7. ✅ Fix useEffect dependencies
8. ✅ Standardize error handling patterns
9. ✅ Add loading state guards

---

## 🛠️ Implementation Order

1. **First:** Fix duplicate toasts (Issues #1, #2, #3) - Immediate user impact
2. **Second:** Extract shared utilities (Issues #4, #5, #6) - Reduces maintenance
3. **Third:** Fix best practices (Issues #7, #8, #9, #10) - Long-term code quality

---

## 📝 Notes

- **StrictMode:** Keep it enabled for development to catch issues early, but ensure all components handle double-renders properly
- **Error Handling:** Centralize error handling but allow components to override for specific cases
- **Code Duplication:** When extracting shared code, ensure it's flexible enough for different use cases


