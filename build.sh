#!/bin/bash

set -eu -o pipefail

project_dir="$(cd "$(dirname "$0")" && pwd)"
output_dir="${project_dir}/output"
# e.g. raspberrypi3_64_custom_defconfig
config_name="$1"

export BR2_EXTERNAL="${project_dir}"
# export ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-
# export BASE_DIR="${project_dir}/output"

pushd "${project_dir}/deps/buildroot" > /dev/null
  make clean
  make "${config_name}"
  make

  rm -rf ${output_dir}/*
  rsync -l -r output/images/ "${output_dir}/"
  rm -rf output/
popd > /dev/null
