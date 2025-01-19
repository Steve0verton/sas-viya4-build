#!/bin/bash
# Build docker images to ensure dependencies contained within are up to date
# NOTE: Run from root of project repository due to directory references below

set -e

# Get root directory
root="$(pwd)"

# Cleanup up dangling Docker Images (caused by new image builds of the same name)
docker image prune -f

# Rebuild viya4-iac-azure docker image
if [[ "$(docker images -q viya4-iac-azure 2> /dev/null)" != "" ]]; then
  echo "==== Deleting viya4-iac-azure docker image"
  docker image rm viya4-iac-azure
fi

echo "==== Building viya4-iac-azure docker image"
echo "== From path: $root/modules/viya4-iac-azure"
cd $root/modules/viya4-iac-azure
docker build -t viya4-iac-azure .

# Rebuild viya4-deployment docker image
if [[ "$(docker images -q viya4-deployment 2> /dev/null)" != "" ]]; then
  echo "==== Deleting viya4-deployment docker image"
  docker image rm viya4-deployment
fi

echo "==== Building viya4-deployment docker image"
echo "== From path: $root/modules/viya4-deployment"
cd $root/modules/viya4-deployment
docker build -t viya4-deployment .
