#!/usr/bin/env bash
# Remove all NGSR components from the default org.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "WARNING: This will delete all NGSR objects, classes, LWCs, and related metadata."
echo "Data in NGSR objects will be permanently deleted."
read -r -p "Type YES to continue: " confirm
if [[ "$confirm" != "YES" ]]; then
  echo "Aborted."
  exit 1
fi

echo "Destroying NGSR components..."
sf project deploy start \
  --manifest manifest/destructivePackage.xml \
  --pre-destructive-changes manifest/destructiveChanges.xml \
  --wait 30

echo "Destroy complete."
