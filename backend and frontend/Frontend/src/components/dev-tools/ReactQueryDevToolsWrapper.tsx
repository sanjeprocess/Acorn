import { ReactQueryDevtools } from '@tanstack/react-query-devtools';

/**
 * Wrapper for React Query DevTools. This file is only loaded in development
 * (via lazy import in main.tsx when import.meta.env.DEV is true),
 * so it is not included in the production bundle.
 */
export default function ReactQueryDevToolsWrapper() {
  return <ReactQueryDevtools initialIsOpen={false} />;
}
