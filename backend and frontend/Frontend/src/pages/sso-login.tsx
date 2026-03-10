import { Helmet } from 'react-helmet-async';

import { CONFIG } from 'src/config-global';

import { SSOLoginView } from 'src/sections/auth';

// ----------------------------------------------------------------------

export default function Page() {
  return (
    <>
      <Helmet>
        <title> {`SSO Login - ${CONFIG.appName}`}</title>
      </Helmet>

      <SSOLoginView />
    </>
  );
}

