#!/bin/bash
# Initial setup tasks, sync dependent repositories
# NOTE: Run from root of project repository due to directory references below

set -e

# Get root directory (should be root of project repository)
root="$(pwd)"
echo "==== Working from root path: $root"

# Define environment variables
export VIYA4_BUILD_ROOT=$root

# Make sure modules directory exists (if not, create it)
mkdir -p $VIYA4_BUILD_ROOT/modules

# Make sure expeted linked repository directories exist (if not, create them)
mkdir -p $VIYA4_BUILD_ROOT/modules/viya4-iac-azure
mkdir -p $VIYA4_BUILD_ROOT/modules/viya4-deployment

# Make sure directories are clear (if already created prior to this script)
echo "==== Clear modules directories "
rm -rf $VIYA4_BUILD_ROOT/modules/viya4-iac-azure/
rm -rf $VIYA4_BUILD_ROOT/modules/viya4-deployment/

# Clone dependent repositories
echo "==== Clone depdendent git repositories "
git clone https://github.com/sassoftware/viya4-iac-azure.git $VIYA4_BUILD_ROOT/modules/viya4-iac-azure/
git clone https://github.com/sassoftware/viya4-deployment.git $VIYA4_BUILD_ROOT/modules/viya4-deployment/
