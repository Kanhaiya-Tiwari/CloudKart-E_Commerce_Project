/**
 * Project: CloudKart
 * File: sidebarSlice.ts
 * Description: TypeScript source code file.
 * How to use: Part of the application logic.
 * Why it exists: To implement features or utility functions.
 * When it's used: During application execution.
 */

import { createSlice, PayloadAction } from "@reduxjs/toolkit";

export interface SidebarState {
  isFilterOpen: boolean;
  isProfileNavOpen: boolean;
}

// Define the initial state using that type
const initialState: SidebarState = {
  isFilterOpen: false,
  isProfileNavOpen: false,
};

export const sidebarSlice = createSlice({
  name: "sidebar",
  initialState,
  reducers: {
    toggleFilterOpen: (state) => {
      state.isFilterOpen = !state.isFilterOpen;
    },
    toggleProfileNav: (state) => {
      state.isProfileNavOpen = !state.isProfileNavOpen;
    },
  },
});

export const { toggleFilterOpen, toggleProfileNav } = sidebarSlice.actions;
export default sidebarSlice.reducer;
