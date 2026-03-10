import { Helmet } from 'react-helmet-async';

import { CONFIG } from 'src/config-global';

import { TravelView } from '../sections/travels/view';

// ----------------------------------------------------------------------

export default function Page() {
  return (
    <>
      <Helmet>
        <title> {`Travels - ${CONFIG.appName}`}</title>
      </Helmet>

      <TravelView />
    </>
  );
}
