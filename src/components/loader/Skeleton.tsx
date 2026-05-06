/**
 * Project: CloudKart
 * File: Skeleton.tsx
 * Description: React component with TypeScript.
 * How to use: Rendered as part of the UI.
 * Why it exists: To build the frontend user interface.
 * When it's used: In the browser during user interaction.
 */

import { cn } from "@/lib/utils";

type SkeletonProps = {
  className?: string;
};
const Skeleton = ({ className }: SkeletonProps) => {
  return (
    <div
      className={cn("skeleton-container overflow-hidden bg-accent", className)}
    >
      <div className="inner-skeleton w-4/5 h-full" />
    </div>
  );
};

export default Skeleton;
