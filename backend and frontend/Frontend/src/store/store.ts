import { create } from 'zustand';
import { devtools } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';

import { createAuthSlice } from './auth-slice';

import type { Store } from '../types/store';

// Define the main store using Zustand with immer and devtools middleware
const useAcornStore = create<Store>()(
    devtools(
        immer((set, get, api) => ({
            auth: createAuthSlice(set, get, api), // Attach authentication slice
        }))
    )
);

export default useAcornStore;
