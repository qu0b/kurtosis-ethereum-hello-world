#!/bin/bash

if ! command -v wget &> /dev/null; then
    echo "Wget binary not found. Please install it before running this script."
    exit 1
fi

if ! command -v podman &> /dev/null; then
    echo "podman binary not found. Please install it before running this script."
    exit 1
fi

if [ ! "$(id -u)" -eq 0 ]; then
    echo "This script is not running as root."
    exit 1
fi

# releases https://github.com/kurtosis-tech/kurtosis-cli-release-artifacts/releases
ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
VERSION="0.86.12"
KURTOSIS_ARCHIVE="kurtosis-cli_${VERSION}_linux_${ARCH}.tar.gz"



if [ ! -d "./bin" ]; then 
    mkdir -p ./bin
fi

if [ ! -f "./bin/kurtosis" ]; then
    echo "installing kurtosis"
    # install kurtosis
    wget "https://github.com/kurtosis-tech/kurtosis-cli-release-artifacts/releases/download/${VERSION}/$KURTOSIS_ARCHIVE" && \
    tar -C ./bin -xzf $KURTOSIS_ARCHIVE kurtosis
    rm $KURTOSIS_ARCHIVE

    ./bin/kurtosis analytics disable
fi

# kurtosistech/engine:$VERSION
# kurtosistech/core:$VERSION
# kurtosistech/files-artifacts-expander:$VERSION

# configure kurtosis to use podman
# https://github.com/kurtosis-tech/kurtosis/issues/1072
# ls $XDG_RUNTIME_DIR/podman/podman.sock
# export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock
PODMAN_SOCK=$(podman info --debug | grep sock | awk '{ print $2;}')
# CONTAINER_SOCKET="unix:///run/containerd/containerd.sock"
CONTAINER_SOCKET="unix:///var/run/podman/podman.sock"
# echo "using podman socket $CONTAINER_SOCKET"
export DOCKER_HOST="$CONTAINER_SOCKET"

# create a bridge network
podman create network bridge

# set the default network to bridge
sed s/default_network=podman/podman/bridge /var/lib/containers/storage

./bin/kurtosis engine start
./bin/kurtosis enclave create -n hello

./bin/kurtosis run --enclave hello ./ethereum-package "$(cat ./config.yaml)"


# ./bin/kurtosis run --enclave hello ./ethereum-package "$(cat ./config.yaml)"


# tear down
#./bin/kurtosis enclave rm -f my-testnet



