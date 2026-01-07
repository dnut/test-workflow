#!/usr/bin/env bash
set -euxo pipefail

NEED_UBUNTU_DEPS=${NEED_UBUNTU_DEPS:-true}

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install system dependencies
if [[ $NEED_UBUNTU_DEPS == true ]]; then
    sudo add-apt-repository ppa:deadsnakes/ppa -y
    sudo apt-get update
    sudo apt install -y python3.11 python3.11-dev python3.11-venv rename zstd \
        libssl-dev libudev-dev pkg-config zlib1g-dev llvm clang cmake make libprotobuf-dev protobuf-compiler
fi

# Clone sig repo
if [[ ! -d "sig" ]]; then
    git clone --depth=1 https://github.com/Syndica/sig.git sig
fi

pushd sig/conformance

# Install conformance code
yes | scripts/setup-env.sh

# Activate the Python environment
source env/pyvenv/bin/activate

# Create fixtures without running them
./run.py --create --no-run

# Create tarball of generated fixtures
popd
tar --zstd -cf fixtures.tar.zst -C sig/conformance/env test-fixtures
