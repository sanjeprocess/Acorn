import 'src/global.css';

import { Toaster } from 'sonner';
import { useEffect } from 'react';

import useAcornStore from './store/store';
import { Router } from './routes/sections';
import { ThemeProvider } from './theme/theme-provider';
import { useScrollToTop } from './hooks/use-scroll-to-top';
import ErrorBoundary from './components/error-boundary/ErrorBoundary';
import { AppFooter } from './components/footer/app-footer';

// ----------------------------------------------------------------------

export default function App() {
  useScrollToTop();
  
  const initializeAuth = useAcornStore((state) => state.auth.initializeAuth);

  // Initialize auth once when app starts
  useEffect(() => {
    initializeAuth();
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  return (
    <ErrorBoundary>
      <ThemeProvider>
        <Router />
        <AppFooter />
        <Toaster position="top-right" richColors duration={1300} />
      </ThemeProvider>
    </ErrorBoundary>
  );
}
