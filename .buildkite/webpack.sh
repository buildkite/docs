#!/bin/bash
set -euo pipefail

echo "--- :webpack: Building Webpack assets for production"
yarn run build-production

echo "--- :javascript: Checking valid JS"
node --check dist/*.js

echo "👍 JavaScript looks valid!"
