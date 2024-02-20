#!/bin/bash
set -x

###########################################################
# Download and install the latest release of yq from GitHub
###########################################################

YQ_DOWNLOAD_FILE="yq_linux_amd64"
YQ_DOWNLOAD_URL="https://github.com/mikefarah/yq/releases/download"
YQ_INSTALL_PATH="${HOME}/bin"
YQ_RELEASE_URL="https://github.com/mikefarah/yq/releases/latest"

# Make sure install path exists
if [ ! -d $YQ_INSTALL_PATH ]; then
  echo "$YQ_INSTALL_PATH does not exist..."
  exit 1
fi

# Determine latest release
YQ_RELEASE_LATEST=$(curl -sI $YQ_RELEASE_URL | sed -En 's/^location: .*\/(.*)/\1/p' | tr -d '\r')

# Download latest release
echo "Downloading release $YQ_RELEASE_LATEST to $YQ_INSTALL_PATH/yq..."
curl -Lso $YQ_INSTALL_PATH/yq $YQ_DOWNLOAD_URL/$YQ_RELEASE_LATEST/$YQ_DOWNLOAD_FILE
chmod +x $YQ_INSTALL_PATH/yq

