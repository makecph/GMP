#!/usr/bin/env sh

# This script builds a static version of GMP ${GMP_VERSION} for the Apple Platforms

set -x

# Setup readonly variables
readonly GMP_VERSION="6.1.2"
readonly WORKING_DIR=$( cd "$( dirname "$0" )" && pwd )
readonly PRODUCT_ASSET="gmp-${GMP_VERSION}.tar.bz2"
readonly PRODUCT_DIR="${WORKING_DIR}/build/product"

function failed {
  local error=${1:-Undefined error}
  echo "Failed: $error" >&2
  exit 1
}

function download {
  curl -R "https://gmplib.org/download/gmp/${PRODUCT_ASSET}" > "${WORKING_DIR}/${PRODUCT_ASSET}"
}

function unpackage {
  tar xjf "${WORKING_DIR}/${PRODUCT_ASSET}" -C "${WORKING_DIR}/"
}

function bootstrap {
    mkdir -p ${PRODUCT_DIR}
    declare -a platforms=("arm","$(xcrun --sdk iphoneos --find clang) -isysroot $(xcrun --sdk iphoneos --show-sdk-path) -arch arm64" "x86_64","$(xcrun --sdk macosx --find clang) -isysroot $(xcrun --sdk macosx --show-sdk-path) -arch x86_64")

    for i in "${platforms[@]}"
    do
        IFS=","; 
        set $i; 
        declare config_directory=build/$1
        declare install_directory=${PRODUCT_DIR}/$1
        mkdir -p ${config_directory}
        mkdir -p ${install_directory}
        pushd ${config_directory}
            ../../gmp-${GMP_VERSION}/configure --disable-assembly --disable-shared --host $1-apple-darwin --prefix=${install_directory} --exec-prefix=${install_directory} CC=$2
        popd
    done
}

download
unpackage
bootstrap
