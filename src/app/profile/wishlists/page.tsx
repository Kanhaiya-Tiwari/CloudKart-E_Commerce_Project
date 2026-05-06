/**
 * Project: CloudKart
 * File: page.tsx
 * Description: React component with TypeScript.
 * How to use: Rendered as part of the UI.
 * Why it exists: To build the frontend user interface.
 * When it's used: In the browser during user interaction.
 */

import React from "react";
import Wishlists from "./Wishlists";
import { Metadata } from "next";

export const metadata: Metadata = {
  title: "Wishlists",
  description:
    "CloudKart is the user-friendly Next.js eCommerce template perfect for launching your online store. With its clean design and customizable options, CloudKart makes selling online a breeze. Start building your dream store today and boost your online presence effortlessly!",
};

const WishlistPage = () => {
  return <Wishlists />;
};

export default WishlistPage;
