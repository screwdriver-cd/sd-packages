#!/bin/bash

# Install dependencies
apt-get update && apt-get install -y build-essential wget cmake gcc-aarch64-linux-gnu g++-aarch64-linux-gnu file

ARCHITECTURES=("x86_64" "aarch64")
COMPILERS=("gcc" "aarch64-linux-gnu-gcc")
OUTPUT_FILES=("zstd-linux-x86_64" "zstd-linux-aarch64")
VERIFY=("x86-64", "ARM aarch64")
STRIP=("strip" "aarch64-linux-gnu-strip")
CURR_DIR=$(pwd)

# Function to check if binary is static and has correct architecture
check_binary() {
    local binary="$1"
    local arch="$2"

    # Verify the binary
    echo "Verifying $binary..."
    ldd $binary
    file $binary
    
    # Check if binary is statically linked
    if ldd "$binary" 2>&1 | grep -q "not a dynamic executable"; then
        echo "The binary $binary is statically linked."
    else
        echo "Error: The binary $binary is not statically linked."
        exit 1
    fi

    # Check architecture
    if file "$binary" | grep -q "$arch, version 1 (GNU/Linux), statically linked"; then
        echo "The binary $binary is for the correct architecture $arch."
    else
        echo "Error: The binary $binary is not for the correct architecture (expected $arch)."
        exit 1
    fi
}

# Ensure BUILD_DIR and ZSTD_VERSION are set
if [ -z "$BUILD_DIR" ] || [ -z "$ZSTD_VERSION" ]; then
    echo "BUILD_DIR and ZSTD_VERSION must be set."
    exit 1
fi

if [ ! -d "zstd-${ZSTD_VERSION}" ]; then
    echo "Downloading zstd version ${ZSTD_VERSION}..."
    wget https://github.com/facebook/zstd/releases/download/v${ZSTD_VERSION}/zstd-${ZSTD_VERSION}.tar.gz
    tar -xzf zstd-${ZSTD_VERSION}.tar.gz
fi

mkdir -p "$BUILD_DIR"

# Build and verify binaries for each architecture
for i in "${!ARCHITECTURES[@]}"; do
    arch="${ARCHITECTURES[$i]}"
    verify="${VERIFY[$i]}"
    compiler="${COMPILERS[$i]}"
    output_file="${OUTPUT_FILES[$i]}"
    strip_cmd="${STRIP[$i]}"

    cp -r "zstd-${ZSTD_VERSION}" "$BUILD_DIR"
    cd "$BUILD_DIR"
    ls -lrt

    echo "Building zstd statically for $arch..."
    make clean -C "zstd-${ZSTD_VERSION}"
    CC="$compiler" CFLAGS="-static -O2 -pthread" LDFLAGS="-static" make -j4 -C "zstd-${ZSTD_VERSION}" zstd
    "$strip_cmd" -s "zstd-${ZSTD_VERSION}/programs/zstd"
    mv "zstd-${ZSTD_VERSION}/programs/zstd" "$CURR_DIR/$output_file"

    chmod +x $CURR_DIR/$output_file
    rm -rf *
    cd "$CURR_DIR"
    echo "Verifying $output_file..."
    check_binary "$output_file" "$verify"
done
echo "Binaries are located at ${OUTPUT_FILES[*]}."