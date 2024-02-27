#!/bin/bash
set -x

#################################################################
# Download and install the latest release of Argo CLI from GitHub
#################################################################

ARGO_DOWNLOAD_FILE="argocd-linux-amd64"
ARGO_DOWNLOAD_URL="https://github.com/argoproj/argo-cd/releases/download"
ARGO_INSTALL_PATH="${HOME}/bin"
ARGO_RELEASE_URL="https://github.com/argoproj/argo-cd/releases/latest"

# Make sure install path exists
if [ ! -d $ARGO_INSTALL_PATH ]; then
  echo "$ARGO_INSTALL_PATH does not exist..."
  exit 1
fi

# Determine latest release
ARGO_RELEASE_LATEST=$(curl -sI $ARGO_RELEASE_URL | sed -En 's/^location: .*\/(.*)/\1/p' | tr -d '\r')

# Download latest release
echo "Downloading release $ARGO_RELEASE_LATEST to $ARGO_INSTALL_PATH/argo"
curl -Lso $ARGO_INSTALL_PATH/argo $ARGO_DOWNLOAD_URL/$ARGO_RELEASE_LATEST/$ARGO_DOWNLOAD_FILE
chmod +x $ARGO_INSTALL_PATH/argo
