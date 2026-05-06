/**
 * Project: CloudKart
 * File: ecosystem.config.cjs
 * Description: Project file.
 * How to use: Refer to the documentation.
 * Why it exists: Part of the CloudKart ecosystem.
 * When it's used: During various stages of the project lifecycle.
 */

const config = {
  apps: [{
    name: 'cloudkart-frontend',
    script: './server.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    }
  }]
};

module.exports = config;