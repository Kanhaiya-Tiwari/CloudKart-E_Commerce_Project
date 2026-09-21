// Loading state for the shops catalog page while CloudKart fetches and renders product data.

import React from "react";
import LoaderDots from "@/components/loader/LoaderDots";

const loading = () => {
  return (
    <LoaderDots className="flex justify-center items-center min-h-screen w-full" />
  );
};

export default loading;
