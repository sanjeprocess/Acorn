import { useLocation } from 'react-router-dom';

import { ForgotPasswordStep1View } from './forgot-password-step1-view';
import { ForgotPasswordStep2View } from './forgot-password-step2-view';
import { ForgotPasswordStep3View } from './forgot-password-step3-view';

// ----------------------------------------------------------------------

export function ForgotPasswordView() {
  const location = useLocation();

  const currentPath = location.pathname;

  // Route based on current path
  if (currentPath === '/forgot-password/verify') {
    return <ForgotPasswordStep2View />;
  }

  if (currentPath === '/forgot-password/reset') {
    return <ForgotPasswordStep3View />;
  }

  // Default to step 1 (email input)
  return <ForgotPasswordStep1View />;
}
