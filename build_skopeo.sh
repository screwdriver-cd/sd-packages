#!/bin/bash

# Install dependencies
yum install -y epel-release
yum install -y wget git make gcc gcc-c++ jq bzip2 file

# Download and set up Go
wget -q -O go${GO_VERSION}.tar.gz https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz
tar -C /usr/local -xzf go${GO_VERSION}.tar.gz

export CURR_DIR=$(pwd)
mkdir /go && cd /go
export GOROOT=/usr/local/go
export GOPATH=/go
export PATH=${PATH}:${GOROOT}/bin

# Download skopeo source code
wget -q -O skopeo-${SKOPEO_VERSION}.tar.gz https://github.com/containers/skopeo/archive/refs/tags/v${SKOPEO_VERSION}.tar.gz
tar -xzf skopeo-${SKOPEO_VERSION}.tar.gz
cd skopeo-${SKOPEO_VERSION}

# Define the build function
build_skopeo() {
    local arch=$1
    local output_name=$2
    local verify_arch=$3
    echo "Building skopeo for architecture: ${arch}"

    # Build with the specified architecture
    make -j4 bin/${output_name} V=1 EXTRA_LDFLAGS="-s -w" DISABLE_CGO=1 BUILDTAGS=containers_image_openpgp GOARCH=${arch} GOOS=linux CGO_ENABLED=0

    # Move binary to the current directory
    mv bin/${output_name} ${CURR_DIR}/
    chmod +x ${CURR_DIR}/${output_name}

    # Verify the binary
    echo "Verifying ${output_name}..."
    ldd ${CURR_DIR}/${output_name}
    file ${CURR_DIR}/${output_name}

    if ldd ${CURR_DIR}/${output_name} 2>&1 | grep -q "not a dynamic executable"; then
        echo "The binary ${output_name} is statically linked."
    else
        echo "Error: The binary ${output_name} is not statically linked."
        exit 1
    fi

    # Check architecture
    if file ../${output_name} | grep -q "${verify_arch}, version 1 (SYSV), statically linked"; then
        echo "The binary ${output_name} is for the correct architecture (${arch})."
    else
        echo "Error: The binary ${output_name} is not for the correct architecture (expected ${arch})."
        exit 1
    fi
}

# Build for amd64
build_skopeo "amd64" "${SKOPEO_PACKAGE_AMD64}" "x86-64"

# Build for arm64
build_skopeo "arm64" "${SKOPEO_PACKAGE_ARM64}" "ARM aarch64"

cd ..
echo "Builds completed. Binaries located in ${CURR_DIR}."