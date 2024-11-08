#!/bin/bash

# Install dependencies
apt-get update && sudo apt-get install -y build-essential wget cmake gcc-aarch64-linux-gnu g++-aarch64-linux-gnu

ARCHITECTURES=("x86_64" "aarch64")
COMPILERS=("gcc" "aarch64-linux-gnu-gcc")
OUTPUT_FILES=("${BUILD_DIR}/zstd-linux-x86_64" "${BUILD_DIR}/zstd-linux-aarch64")

# Function to check if binary is static and has correct architecture
check_binary() {
    local binary="$1"
    local arch="$2"

    # Check if binary is statically linked
    if ! ldd "$binary" 2>&1 | grep -q "not a dynamic executable"; then
        echo "Error: $binary is not statically linked."
        exit 1
    fi

    # Check if binary has the correct architecture
    if ! file "$binary" | grep -q "$arch"; then
        echo "Error: $binary does not match expected architecture: $arch."
        exit 1
    fi
}


mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

if [ ! -d "zstd-${ZSTD_VERSION}" ]; then
    echo "Downloading zstd version ${ZSTD_VERSION}..."
    wget https://github.com/facebook/zstd/releases/download/v${ZSTD_VERSION}/zstd-${ZSTD_VERSION}.tar.gz
    tar -xzf zstd-${ZSTD_VERSION}.tar.gz
fi
cd "zstd-${ZSTD_VERSION}"

# Build and verify binaries for each architecture
for i in "${!ARCHITECTURES[@]}"; do
    arch="${ARCHITECTURES[$i]}"
    compiler="${COMPILERS[$i]}"
    output_file="${OUTPUT_FILES[$i]}"

    echo "Building zstd statically for $arch..."
    make clean
    CC="$compiler" CFLAGS="-static -O2 -pthread" LDFLAGS="-static" make -j4 zstd
    cp zstd "$output_file"

    echo "Verifying $output_file..."
    check_binary "$output_file" "$arch"
done
echo "Binaries are located at ${OUTPUT_FILES[*]}."