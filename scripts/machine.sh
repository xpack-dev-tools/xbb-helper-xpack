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

# Detect the machine the build runs on.

function machine_detect()
{
  # The original upper case name (Linux, Darwin).
  XBB_BUILD_UNAME="$(uname)"
  # `uname -m` is more reliable than `uname -p`
  XBB_BUILD_MACHINE="$(uname -m | tr '[:upper:]' '[:lower:]')"
  XBB_BUILD_TRIPLET="$(xbb_config_guess)"

  XBB_BUILD_DISTRO_NAME="?" # Linux distribution name (Ubuntu|CentOS|...)
  XBB_BUILD_DISTRO_LOWER_CASE_NAME="?" # Same, in lower case.

  # Node.js process.platform (darwin|linux|win32)
  XBB_BUILD_PLATFORM="$(uname -s | tr '[:upper:]' '[:lower:]')"
  # Travis uses Msys2; git for Windows uses mingw-w64.
  if [[ "${XBB_BUILD_PLATFORM}" == msys_nt* ]] \
  || [[ "${XBB_BUILD_PLATFORM}" == mingw64_nt* ]] \
  || [[ "${XBB_BUILD_PLATFORM}" == mingw32_nt* ]]
  then
    XBB_BUILD_PLATFORM="win32"
  fi

  # Node.js process.arch (ia32|x64|arm|arm64)
  XBB_BUILD_ARCH="?"

  XBB_BUILD_BITS="?"

  if [ "${XBB_BUILD_PLATFORM}" == "darwin" ]
  then
    # uname -p -> i386, arm
    # uname -m -> x86_64|arm64

    XBB_BUILD_DISTRO_NAME=Darwin
    XBB_BUILD_DISTRO_LOWER_CASE_NAME=darwin

    XBB_BUILD_BITS="64"

    if [ "${XBB_BUILD_MACHINE}" == "x86_64" ]
    then
      XBB_BUILD_ARCH="x64"
    elif [ "${XBB_BUILD_MACHINE}" == "arm64" ]
    then
      XBB_BUILD_ARCH="arm64"
    else
      echo "Unsupported uname -m ${XBB_BUILD_MACHINE} in ${FUNCNAME[0]}()"
      exit 1
    fi

  elif [ "${XBB_BUILD_PLATFORM}" == "linux" ]
  then
    # ----- Determine distribution name and word size -----

    # uname -p -> x86_64|i686 (unknown in recent versions, use -m)
    # uname -m -> x86_64|i386|i486|i586|i686|aarch64|armv7l|armv8l

    if [ "${XBB_BUILD_MACHINE}" == "x86_64" ]
    then
      XBB_BUILD_BITS="64"
      XBB_BUILD_ARCH="x64"
    elif [[ "${XBB_BUILD_MACHINE}" =~ i[3456]86  ]]
    then
      # For completeness, no longer supported.
      XBB_BUILD_BITS="32"
      XBB_BUILD_ARCH="ia32"
    elif [ "${XBB_BUILD_MACHINE}" == "aarch64" ]
    then
      XBB_BUILD_BITS="64"
      XBB_BUILD_ARCH="arm64"
    elif [ "${XBB_BUILD_MACHINE}" == "armv7l" -o "${XBB_BUILD_MACHINE}" == "armv8l" ]
    then
      XBB_BUILD_BITS="32"
      XBB_BUILD_ARCH="arm"
    else
      echo "Unsupported uname -m ${XBB_BUILD_MACHINE} in ${FUNCNAME[0]}()"
      exit 1
    fi

    local lsb_path=$(which lsb_release)
    if [ -z "${lsb_path}" ]
    then
      echo "Please install the lsb core package and rerun"
      exit 1
    fi

    XBB_BUILD_DISTRO_NAME=$(lsb_release -si)
    XBB_BUILD_DISTRO_LOWER_CASE_NAME=$(echo ${XBB_BUILD_DISTRO_NAME} | tr "[:upper:]" "[:lower:]")

  elif [ "${XBB_BUILD_PLATFORM}" == "win32" ]
  then
    if [ "${XBB_BUILD_MACHINE}" == "x86_64" ]
    then
      XBB_BUILD_BITS="64"
      XBB_BUILD_ARCH="x64"
    elif [ "${XBB_BUILD_MACHINE}" == "i386" ] ||
         [ "${XBB_BUILD_MACHINE}" == "i586" ] ||
         [ "${XBB_BUILD_MACHINE}" == "i686" ]
    then
      XBB_BUILD_BITS="32"
      XBB_BUILD_ARCH="ia32"
    else
      echo "Unsupported uname -m ${XBB_BUILD_MACHINE} in ${FUNCNAME[0]}()"
      exit 1
    fi

    # Git Bash returns "Msys".
    XBB_BUILD_DISTRO_NAME=$(uname -o)
    XBB_BUILD_DISTRO_LOWER_CASE_NAME=$(echo ${XBB_BUILD_DISTRO_NAME} | tr "[:upper:]" "[:lower:]")

  else
    echo "Unsupported uname ${XBB_BUILD_UNAME} in ${FUNCNAME[0]}()"
    exit 1
  fi

  echo
  echo "Running on ${XBB_BUILD_DISTRO_NAME} ${XBB_BUILD_ARCH} (${XBB_BUILD_BITS}-bit)..."
  uname -a

  export XBB_BUILD_UNAME # uname
  export XBB_BUILD_MACHINE # lower case uname -m, x86_64|i386|i686|aarch64|armv7l|armv8l
  export XBB_BUILD_TRIPLET
  export XBB_BUILD_DISTRO_NAME
  export XBB_BUILD_DISTRO_LOWER_CASE_NAME
  export XBB_BUILD_PLATFORM # node.js: darwin|linux|win32
  export XBB_BUILD_ARCH # node.js: ia32|x64|arm|arm64
  export XBB_BUILD_BITS # 64|32
}

# -----------------------------------------------------------------------------
