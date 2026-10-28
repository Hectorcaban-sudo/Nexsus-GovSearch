#!/usr/bin/env bash
# Deploy all NGSR components to the default org.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "Deploying NGSR components..."
sf project deploy start \
  --manifest manifest/package.xml \
  --wait 30

echo "Deploy complete."
