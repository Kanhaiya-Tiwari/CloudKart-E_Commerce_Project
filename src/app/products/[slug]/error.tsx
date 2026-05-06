/**
 * Project: CloudKart
 * File: error.tsx
 * Description: React component with TypeScript.
 * How to use: Rendered as part of the UI.
 * Why it exists: To build the frontend user interface.
 * When it's used: In the browser during user interaction.
 */

"use client"; // Error components must be Client Components

import { Button } from "@/components/ui/button";
import { useEffect } from "react";
import { BiError } from "react-icons/bi";

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    // Log the error to an error reporting service
    console.error(error);
  }, [error]);

  return (
    <div className="flex justify-center items-center flex-col gap-5 h-screen">
      <p className="text-6xl text-primary">
        <BiError />
      </p>
      <p className="text-3xl font-semibold">Something went wrong!</p>
      <Button variant={"outline"} onClick={() => reset()}>
        Try Again
      </Button>
    </div>
  );
}
