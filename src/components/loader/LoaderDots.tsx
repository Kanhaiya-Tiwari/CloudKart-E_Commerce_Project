/**
 * Project: CloudKart
 * File: LoaderDots.tsx
 * Description: React component with TypeScript.
 * How to use: Rendered as part of the UI.
 * Why it exists: To build the frontend user interface.
 * When it's used: In the browser during user interaction.
 */

import { cn } from "@/lib/utils";
import React from "react";

const LoaderDots = ({ className }: { className?: string }) => {
  return (
    <div className={cn("", className)}>
      <div className="loader_dots">
        <div className="circle" />
        <div className="circle" />
        <div className="circle" />
        <div className="circle" />
      </div>
    </div>
  );
};

export default LoaderDots;
