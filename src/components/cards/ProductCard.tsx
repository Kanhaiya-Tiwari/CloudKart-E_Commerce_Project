"use client";

import React from "react";
import { motion } from "framer-motion";
import CardOne from "./CardOne";
import CardTwo from "./CardTwo";
import CardThree from "./CardThree";
import CardFour from "./CardFour";
import BookCard from "./BookCard";

export type ProductCardVariants =
  | "default"
  | "style-1"
  | "style-2"
  | "style-3"
  | "book-card";

type ProductCardProps = {
  variants?: ProductCardVariants;
  product: AllProduct | SingleProductType;
};

const ProductCard = ({ variants = "default", product }: ProductCardProps) => {
  const getCard = () => {
    switch (variants) {
      case "style-1":
        return <CardOne {...(product as AllProduct)} />;
      case "style-2":
        return <CardTwo {...(product as AllProduct)} />;
      case "style-3":
        return <CardThree {...(product as AllProduct)} />;
      case "book-card":
        return <BookCard {...(product as SingleProductType)} />;
      default:
        return <CardFour {...(product as AllProduct)} />;
    }
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      whileHover={{ scale: 1.03 }}
      whileTap={{ scale: 0.98 }}
      transition={{ duration: 0.3 }}
    >
      {getCard()}
    </motion.div>
  );
};

export default ProductCard;
