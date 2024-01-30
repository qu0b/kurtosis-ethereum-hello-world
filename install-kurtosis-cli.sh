#!/bin/bash

if ! command -v wget &> /dev/null; then
    echo "Wget binary not found. Please install it before running this script."
    exit 1
fi

# releases https://github.com/kurtosis-tech/kurtosis-cli-release-artifacts/releases
ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
VERSION="0.86.12"

KURTOSIS_ARCHIVE="kurtosis-cli_${VERSION}_linux_${ARCH}.tar.gz"

mkdir -p ./bin

# install kurtosis
wget "https://github.com/kurtosis-tech/kurtosis-cli-release-artifacts/releases/download/${VERSION}/$KURTOSIS_ARCHIVE" && \
tar -C ./bin -xzf $KURTOSIS_ARCHIVE kurtosis
rm $KURTOSIS_ARCHIVE


# configure kurtosis to use podman
# https://github.com/kurtosis-tech/kurtosis/issues/1072
# ls $XDG_RUNTIME_DIR/podman/podman.sock
# DOCKER_HOST="/run/user/1000/podman/podman.sock"







