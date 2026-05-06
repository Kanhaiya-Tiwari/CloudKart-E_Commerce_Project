/**
 * Project: CloudKart
 * File: next.config.cjs
 * Description: Project file.
 * How to use: Refer to the documentation.
 * Why it exists: Part of the CloudKart ecosystem.
 * When it's used: During various stages of the project lifecycle.
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