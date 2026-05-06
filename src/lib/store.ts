/**
 * Project: CloudKart
 * File: store.ts
 * Description: TypeScript source code file.
 * How to use: Part of the application logic.
 * Why it exists: To implement features or utility functions.
 * When it's used: During application execution.
 */

import { configureStore } from "@reduxjs/toolkit";
import cartSlice from "./features/cart/cartSlice";
import authSlice from "./features/auth/authSlice";
import sidebarSlice from "./features/sidebar/sidebarSlice";

export const makeStore = () => {
  return configureStore({
    reducer: {
      authSlice,
      cartSlice,
      sidebarSlice,
    },
  });
};

export type AppStore = ReturnType<typeof makeStore>;
export type RootState = ReturnType<AppStore["getState"]>;
export type AppDispatch = AppStore["dispatch"];
