/**
 * Project: CloudKart
 * File: not-found.tsx
 * Description: React component with TypeScript.
 * How to use: Rendered as part of the UI.
 * Why it exists: To build the frontend user interface.
 * When it's used: In the browser during user interaction.
 */

import FeaturedProducts from "@/components/FeaturedProducts";
import HistoryBackBtn from "@/components/HistoryBackBtn";
import React from "react";

const NotFound = () => {
  return (
    <div className="min-h-screen py-12">
      <div className="flex justify-center items-center flex-col gap-4 min-h-[60vh]">
        <h1 className="text-4xl md:text-6xl font-semibold">404</h1>
        <p>Page is not found!</p>
        <HistoryBackBtn />
      </div>
      <FeaturedProducts />
    </div>
  );
};

export default NotFound;
