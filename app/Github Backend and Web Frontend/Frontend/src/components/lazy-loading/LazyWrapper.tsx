import type { ComponentType } from 'react';

import { lazy, Suspense } from 'react';

import { Box, Typography, CircularProgress } from '@mui/material';

// Loading component
const LoadingFallback = () => (
  <Box
    sx={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      minHeight: '200px',
      gap: 2
    }}
  >
    <CircularProgress />
    <Typography variant="body2" color="text.secondary">
      Loading...
    </Typography>
  </Box>
);

// Error fallback component
const ErrorFallback = ({ error }: { error: Error }) => (
  <Box
    sx={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      minHeight: '200px',
      gap: 2,
      p: 2
    }}
  >
    <Typography variant="h6" color="error">
      Failed to load component
    </Typography>
    <Typography variant="body2" color="text.secondary">
      {error.message}
    </Typography>
  </Box>
);

// Higher-order component for lazy loading
export function withLazyLoading(
  importFunc: () => Promise<{ default: ComponentType<any> }>,
  fallback?: ComponentType
) {
  const LazyComponent = lazy(importFunc);
  
  return function LazyWrapper(props: any) {
    const FallbackComponent = fallback || LoadingFallback;
    return (
      <Suspense fallback={<FallbackComponent />}>
        <LazyComponent {...props} />
      </Suspense>
    );
  };
}

// Lazy load page components
export const LazyTravelView = withLazyLoading(
  () => import('../../sections/travels/view').then(module => ({ default: module.TravelView }))
);

export const LazyUserView = withLazyLoading(
  () => import('../../sections/user/view').then(module => ({ default: module.UserView }))
);

export const LazyFeedbackView = withLazyLoading(
  () => import('../../sections/feedback/view').then(module => ({ default: module.FeedbackView }))
);

export const LazyIncidentsView = withLazyLoading(
  () => import('../../sections/incidents/view').then(module => ({ default: module.IncidentView }))
);

export const LazyProductsView = withLazyLoading(
  () => import('../../sections/product/view').then(module => ({ default: module.ProductsView }))
);

export const LazyBlogView = withLazyLoading(
  () => import('../../sections/blog/view').then(module => ({ default: module.BlogView }))
);

export const LazySignInView = withLazyLoading(
  () => import('../../sections/auth/sign-in-view').then(module => ({ default: module.SignInView }))
);

export const LazySignUpView = withLazyLoading(
  () => import('../../sections/auth/sign-up-view').then(module => ({ default: module.SignUpView }))
);

export const LazyPageNotFound = withLazyLoading(
  () => import('../../pages/page-not-found').then(module => ({ default: module.default }))
);
