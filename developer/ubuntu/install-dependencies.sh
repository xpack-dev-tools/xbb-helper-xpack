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

# This script installs the same packages as those available in the new
# Ubuntu 18 Docker images used for xPack builds (XBB v5.0).

export DEBIAN_FRONTEND=noninteractive

# For older systems (like Ubuntu 18 Bionic) it might be also needed to
# update the `/etc/apt/sources.lists` with newer URLs, like
# "https://archive.ubuntu.com/ubuntu/" (for Intel)
# "https://ports.ubuntu.com/ubuntu-ports/" (for Arm)

sudo apt-get update

# https://www.thomas-krenn.com/en/wiki/Configure_Locales_in_Ubuntu
sudo apt-get install --yes locales
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8

# Must be passed as `ENV TZ=UTC` in Dockerfile.
# export TZ=UTC
# ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

sudo apt-get --yes install tzdata

sudo apt-get -qq install -y \
  \
  autoconf \
  automake \
  bison \
  bzip2 \
  ca-certificates \
  coreutils \
  cpio \
  curl \
  diffutils \
  dos2unix \
  file \
  flex \
  gawk \
  gettext \
  git \
  gzip \
  help2man \
  libatomic1 \
  libc6-dev \
  libtool \
  linux-headers-generic \
  lsb-release \
  m4 \
  make \
  patch \
  perl \
  pkg-config \
  python \
  python3 \
  python3-pip \
  re2c \
  rhash \
  rsync \
  systemd \
  tar \
  tcl \
  texinfo \
  time \
  unzip \
  wget \
  xz-utils \
  zip \
  zlib1g-dev

if [ "$(uname -m)" == "x86_64" ]
then
  # Multilib required for 32-bit tools, like gcc, mingw-gcc, wine, qemu.
  sudo apt-get install --yes g++-multilib
fi

# For QEMU
sudo apt-get install --yes \
  libx11-dev \
  libxext-dev \
  mesa-common-dev

# For QEMU & OpenOCD
sudo apt-get install --yes \
  libudev-dev

# -----------------------------------------------------------------------------
