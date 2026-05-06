/**
 * Project: CloudKart
 * File: page.tsx
 * Description: React component with TypeScript.
 * How to use: Rendered as part of the UI.
 * Why it exists: To build the frontend user interface.
 * When it's used: In the browser during user interaction.
 */

import ProductGrid from "@/components/ProductGrid";
import SelectedFilters from "@/components/filters/SelectedFilters";
import ProductLoader from "@/components/loader/ProductLoader";
import { Suspense } from "react";

type CategoryPageProps = {
  searchParams: SearchParamsType;
  params: {
    category: string;
    shop: string;
  };
};

const CategoryPage = ({ params, searchParams }: CategoryPageProps) => {
  return (
    <section className="category-page">
      <SelectedFilters />
      <Suspense fallback={<ProductLoader />}>
        <ProductGrid searchParams={searchParams} params={params} />
      </Suspense>
    </section>
  );
};

export default CategoryPage;
