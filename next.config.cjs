/**
 * CloudKart Next.js config: keeps the app optimized for standalone deployment and JSON handling in production.
 */

/** @type {import('next').NextConfig} */
const config = {
  output: 'standalone',
  swcMinify: true,
  webpack: (config) => {
    config.module.rules.push({
      test: /\.json$/,
      type: 'json',
    });
    return config;
  }
};

module.exports = config;
