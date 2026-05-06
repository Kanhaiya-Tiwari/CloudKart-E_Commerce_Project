/**
 * Project: CloudKart
 * File: loading.tsx
 * Description: React component with TypeScript.
 * How to use: Rendered as part of the UI.
 * Why it exists: To build the frontend user interface.
 * When it's used: In the browser during user interaction.
 */

import LoaderDots from "@/components/loader/LoaderDots";
import React from "react";

const loading = () => {
  return (
    <LoaderDots className="flex justify-center items-center min-h-screen w-full" />
  );
};

export default loading;
