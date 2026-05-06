/**
 * Project: CloudKart
 * File: product.ts
 * Description: TypeScript source code file.
 * How to use: Part of the application logic.
 * Why it exists: To implement features or utility functions.
 * When it's used: During application execution.
 */

import mongoose from 'mongoose';

const productSchema = new mongoose.Schema({
  originalId: {
    type: String,
    required: true,
    unique: true
  },
  title: { 
    type: String, 
    required: true 
  },
  description: { 
    type: String, 
    required: true 
  },
  price: { 
    type: Number, 
    required: true 
  },
  oldPrice: { 
    type: Number 
  },
  categories: [{ 
    type: String 
  }],
  image: [{ 
    type: String 
  }],
  rating: { 
    type: Number, 
    default: 0 
  },
  sales: {
    type: Number,
    default: 0
  },
  amount: { 
    type: Number, 
    required: true 
  },
  shop_category: { 
    type: String, 
    required: true 
  },
  unit_of_measure: { 
    type: String 
  },
  colors: [{ 
    type: String 
  }],
  sizes: [{ 
    type: String 
  }]
}, {
  timestamps: true
});

export default mongoose.models.Product || mongoose.model('Product', productSchema);
