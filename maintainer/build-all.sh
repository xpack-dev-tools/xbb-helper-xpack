#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2022 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Safety settings (see https://gist.github.com/ilg-ul/383869cbb01f61a51c4d).

if [[ ! -z ${DEBUG} ]]
then
  set ${DEBUG} # Activate the expand mode if DEBUG is anything but empty.
else
  DEBUG=""
fi

set -o errexit # Exit if command failed.
set -o pipefail # Exit if pipe failed.
set -o nounset # Exit if variable not set.

# Remove the initial space and instead use '\n'.
IFS=$'\n\t'

# -----------------------------------------------------------------------------
# Identify the script location, to reach, for example, the helper scripts.

build_script_path="$0"
if [[ "${build_script_path}" != /* ]]
then
  # Make relative path absolute.
  build_script_path="$(pwd)/$0"
fi

script_folder_path="$(dirname "${build_script_path}")"
script_folder_name="$(basename "${script_folder_path}")"

# =============================================================================

# Maintenance script used to build all packages available on a given platform.
# To run it, clone the helper project and then run:
#
# bash ~/Work/xbb-helper-xpack.git/maintainer/build-all.sh
# bash ~/Work/xbb-helper-xpack.git/maintainer/build-all.sh --windows

# -----------------------------------------------------------------------------

do_windows=""
do_clone=""
do_dry=""

while [ $# -gt 0 ]
do
  case "$1" in
    --windows )
      do_windows="y"
      shift
      ;;

    --clone )
      do_clone="y"
      shift
      ;;

    --dry )
      do_dry="y"
      shift
      ;;

    * )
      echo "Unsupported argument $1 in ${FUNCNAME[0]}()"
      exit 1
      ;;
  esac
done

# -----------------------------------------------------------------------------

if [ "$(uname)" == "Darwin" ]
then
  if [ "$(uname -m)" == "x86_64" ]
  then
    config=darwin-x64
  elif [ "$(uname -m)" == "arm64" ]
  then
    config=darwin-arm64
  else
    echo "Unsupported architecture $(uname -m)"
    exit 1
  fi
elif [ "$(uname)" == "Linux" ]
then
  if [ "$(uname -m)" == "x86_64" ]
  then
    if [ "${do_windows}" == "y" ]
    then
      config=win32-x64
    else
      config=linux-x64
    fi
  elif [ "$(uname -m)" == "aarch64" ]
  then
    config=linux-arm64
  elif [ "$(uname -m)" == "armv7l" -o "$(uname -m)" == "armv8l" ]
  then
    config=linux-arm
  else
    echo "Unsupported architecture $(uname -m)"
    exit 1
  fi
else
  echo "Unsupported machine $(uname)"
  exit 1
fi

names=()
names+=( gcc clang mingw-w64-gcc )
names+=( cmake meson-build ninja-build )
names+=( openocd qemu-arm qemu-riscv )
names+=( arm-none-eabi-gcc aarch64-none-elf-gcc riscv-none-elf-gcc )

if [ "${do_windows}" == "y" ]
then
  echo "Skip Linux only packages"
else
  names+=( patchelf pkg-config realpath m4 sed )
fi

if [ "${do_clone}" == "y" ]
then

  # Preload clean repos.
  for name in ${names[@]}
  do

    rm -rf ~/Work/${name}-xpack.git && \
    mkdir -p ~/Work && \
    git clone \
      --branch xpack-develop \
      https://github.com/xpack-dev-tools/${name}-xpack.git \
      ~/Work/${name}-xpack.git

  done

  exit 0
fi

git -C ~/Work/xbb-helper-xpack.git pull
xpm link -C ~/Work/xbb-helper-xpack.git

for name in ${names[@]}
do

  git -C ~/Work/${name}-xpack.git pull

  xpm run deep-clean -C ~/Work/${name}-xpack.git

  if [ "$(uname)" == "Darwin" ]
  then
    xpm install -C ~/Work/${name}-xpack.git
    xpm run link-deps -C ~/Work/${name}-xpack.git

    if [ "${do_dry}" == "y" ]
    then
      echo "Skipping real action for ${name}..."
    else
      xpm run deep-clean --config ${config}  -C ~/Work/${name}-xpack.git
      xpm install --config ${config} -C ~/Work/${name}-xpack.git
      xpm run build-develop --config ${config} -C ~/Work/${name}-xpack.git
    fi
  elif [ "$(uname)" == "Linux" ]
  then
    xpm run deep-clean --config ${config} -C ~/Work/${name}-xpack.git
    xpm run docker-prepare --config ${config} -C ~/Work/${name}-xpack.git
    xpm run docker-link-deps --config ${config} -C ~/Work/${name}-xpack.git

    if [ "${do_dry}" == "y" ]
    then
      echo "Skipping real action for ${name}..."
    else
      xpm run docker-build-develop --config ${config} -C ~/Work/${name}-xpack.git
    fi
  fi

done

find ~/Work -name 'duration-*-*.txt' -print -exec cat '{}' ';'

# -----------------------------------------------------------------------------
