/* *
 * Copyright 2024 Mubasher Financial Services (DIFC) Limited. All rights reserved.
 *
 * Unauthorized access, copying, publishing, sharing, reuse of algorithms, concepts, design patterns
 * and code level demonstrations are strictly prohibited without any written approval of
 * Mubasher Financial Services (DIFC) Limited.
 */

import { Outlet, Navigate, useLocation } from 'react-router-dom';

import useAcornStore from '../../store/store';

const ProtectedRoutes = () => {
  const location = useLocation();
  const isAuthenticated = useAcornStore((state) => state.auth.isAuthenticated);

  if (!isAuthenticated) {
    return <Navigate to="/sign-in" state={{ from: location }} replace />;
  }

  return <Outlet />;
};

export default ProtectedRoutes;