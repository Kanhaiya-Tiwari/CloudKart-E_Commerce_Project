/**
 * Project: CloudKart
 * File: route.ts
 * Description: TypeScript source code file.
 * How to use: Part of the application logic.
 * Why it exists: To implement features or utility functions.
 * When it's used: During application execution.
 */

import { NextResponse } from 'next/server';
import dbConnect from '@/lib/db';
import Product from '@/lib/models/product';

export async function GET(request: Request) {
  try {
    await dbConnect();
    
    const products = await Product.find({ shop_category: 'books' })
      .sort({ createdAt: -1 })
      .limit(10);

    return NextResponse.json({ products });
  } catch (error) {
    console.error('Error fetching books:', error);
    return NextResponse.json(
      { error: 'Failed to fetch books' },
      { status: 500 }
    );
  }
}
