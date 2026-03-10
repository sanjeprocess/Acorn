import ReactDOM from 'react-dom/client';
import { Suspense, StrictMode, lazy } from 'react';
import { BrowserRouter } from 'react-router-dom';
import { HelmetProvider } from 'react-helmet-async';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

import App from './app';

// DevTools are lazy-loaded only in development so they are not in the production bundle
const ReactQueryDevTools = import.meta.env.DEV
  ? lazy(() => import('./components/dev-tools/ReactQueryDevToolsWrapper'))
  : () => null;

// ----------------------------------------------------------------------

const root = ReactDOM.createRoot(document.getElementById('root') as HTMLElement);

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutes
      gcTime: 10 * 60 * 1000, // 10 minutes (renamed from cacheTime in v5)
      retry: (failureCount, error: any) => {
        // Don't retry on 4xx errors
        if (error?.response?.status >= 400 && error?.response?.status < 500) {
          return false;
        }
        // Retry up to 3 times for other errors
        return failureCount < 3;
      },
      retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000),
      refetchOnWindowFocus: false,
      refetchOnReconnect: true,
    },
    mutations: {
      retry: false,
    },
  },
});

// Conditionally enable StrictMode only in development
const AppWrapper = (
  <HelmetProvider>
    <QueryClientProvider client={queryClient}>
      {import.meta.env.DEV && (
        <Suspense fallback={null}>
          <ReactQueryDevTools />
        </Suspense>
      )}
      <BrowserRouter>
        <Suspense>
          <App />
        </Suspense>
      </BrowserRouter>
    </QueryClientProvider>
  </HelmetProvider>
);

root.render(
  import.meta.env.DEV ? (
    <StrictMode>{AppWrapper}</StrictMode>
  ) : (
    AppWrapper
  )
);
