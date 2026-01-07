#!/usr/bin/env bash
set -euxo pipefail

INSTALL_SYSTEM_DEPS=${INSTALL_SYSTEM_DEPS:-ubuntu}

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install system dependencies
if [[ $INSTALL_SYSTEM_DEPS == ubuntu ]]; then
    sudo add-apt-repository ppa:deadsnakes/ppa -y
    sudo apt-get update
    sudo apt install -y python3.11 python3.11-dev python3.11-venv rename zstd \
        libssl-dev libudev-dev pkg-config zlib1g-dev llvm clang cmake make libprotobuf-dev protobuf-compiler libclang-dev
elif [[ $INSTALL_SYSTEM_DEPS != '' ]]; then
    echo unknown system, not installing dependencies: $INSTALL_SYSTEM_DEPS
fi

git clone --depth=1 https://github.com/Syndica/sig.git sig
pushd sig/conformance
scripts/setup-env.sh get-solfuzz-agave
scripts/setup-env.sh get-test-vectors
scripts/setup-env.sh get-solana-conformance
source env/pyvenv/bin/activate
./run.py --create --no-run  # Create test fixtures
popd

# Create tarball of generated fixtures
tar --zstd -cf fixtures.tar.zst -C sig/conformance/env test-fixtures
