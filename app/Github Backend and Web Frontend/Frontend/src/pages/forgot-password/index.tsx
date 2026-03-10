import { Helmet } from 'react-helmet-async';

import { ForgotPasswordView } from 'src/sections/auth/forgot-password';

// ----------------------------------------------------------------------

export default function ForgotPasswordPage() {
  return (
    <>
      <Helmet>
        <title> Forgot Password | ACORN Travels</title>
      </Helmet>

      <ForgotPasswordView />
    </>
  );
}
