/**
 * Project: CloudKart
 * File: authSlice.ts
 * Description: TypeScript source code file.
 * How to use: Part of the application logic.
 * Why it exists: To implement features or utility functions.
 * When it's used: During application execution.
 */

import { createSlice, PayloadAction } from "@reduxjs/toolkit";

// Define a type for the slice state
export type User = {
  id: number;
  name: string;
  email: string;
};

export interface AuthState {
  isAuthenticated: boolean;
  currentUser: User | null;
}

// Define the initial state using that type
const initialState: AuthState = {
  isAuthenticated: false,
  currentUser:
    (typeof window !== "undefined" &&
      JSON.parse(localStorage.getItem("currentUser") as string)) ||
    null,
};

export const authSlice = createSlice({
  name: "auth",
  initialState,
  reducers: {
    setAuthenticated: (state, action: PayloadAction<boolean>) => {
      state.isAuthenticated = action.payload;
    },

    removeCurrentUser: (state) => {
      state.currentUser = null;
    },

    setCurrentUser: (state, action: PayloadAction<User | null>) => {
      state.currentUser = action.payload;
      if (action.payload) {
        localStorage.setItem("currentUser", JSON.stringify(action.payload));
      } else {
        localStorage.removeItem("currentUser");
      }
    },
  },
});

export const { setAuthenticated, removeCurrentUser, setCurrentUser } =
  authSlice.actions;
export default authSlice.reducer;
