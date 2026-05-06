/**
 * Project: CloudKart
 * File: Logo.tsx
 * Description: React component with TypeScript.
 * How to use: Rendered as part of the UI.
 * Why it exists: To build the frontend user interface.
 * When it's used: In the browser during user interaction.
 */

import Image from "next/image";
import Link from "next/link";
import React from "react";
import { FaOpencart } from "react-icons/fa";

const Logo = () => {
  return (
    <Link href={"/"} className="flex gap-3 items-center">
      <span className="text-4xl text-primary">
        <FaOpencart />
      </span>
      <div>
        <p className="text-xl font-semibold whitespace-nowrap">
          Cloud<span className="text-primary">Kart</span>
        </p>
        {/* <p className="text-xs">Enjoy shopping</p> */}
      </div>
    </Link>
  );
};

export default Logo;
