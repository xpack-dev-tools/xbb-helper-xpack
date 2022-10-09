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

function host_detect()
{
  # The original upper case name; actually not used.
  HOST_UNAME="$(uname)"
  # `uname -m` is more reliable than `uname -p`
  HOST_MACHINE="$(uname -m | tr '[:upper:]' '[:lower:]')"

  HOST_DISTRO_NAME="?" # Linux distribution name (Ubuntu|CentOS|...)
  HOST_DISTRO_LC_NAME="?" # Same, in lower case.

  # Node.js process.platform (darwin|linux|win32)
  HOST_NODE_PLATFORM="$(uname -s | tr '[:upper:]' '[:lower:]')"
  # Travis uses Msys2; git for Windows uses mingw-w64.
  if [[ "${HOST_NODE_PLATFORM}" == msys_nt* ]] \
  || [[ "${HOST_NODE_PLATFORM}" == mingw64_nt* ]] \
  || [[ "${HOST_NODE_PLATFORM}" == mingw32_nt* ]]
  then
    HOST_NODE_PLATFORM="win32"
  fi

  # Node.js process.arch (ia32|x64|arm|arm64)
  HOST_NODE_ARCH="?"

  HOST_BITS="?"

  if [ "${HOST_NODE_PLATFORM}" == "darwin" ]
  then
    # uname -p -> i386, arm
    # uname -m -> x86_64, arm64

    HOST_DISTRO_NAME=Darwin
    HOST_DISTRO_LC_NAME=darwin

    HOST_BITS="64"

    if [ "${HOST_MACHINE}" == "x86_64" ]
    then
      HOST_NODE_ARCH="x64"
    elif [ "${HOST_MACHINE}" == "arm64" ]
    then
      HOST_NODE_ARCH="arm64"
    else
      echo "Unknown uname -m ${HOST_MACHINE}"
      exit 1
    fi

  elif [ "${HOST_NODE_PLATFORM}" == "linux" ]
  then
    # ----- Determine distribution name and word size -----

    # uname -p -> x86_64|i686 (unknown in recent versions, use -m)
    # uname -m -> x86_64|i686|aarch64|armv7l

    if [ "${HOST_MACHINE}" == "x86_64" ]
    then
      HOST_BITS="64"
      HOST_NODE_ARCH="x64"
    elif [ "${HOST_MACHINE}" == "i386" -o "${HOST_MACHINE}" == "i586" -o "${HOST_MACHINE}" == "i686" ]
    then
      HOST_BITS="32"
      HOST_NODE_ARCH="ia32"
    elif [ "${HOST_MACHINE}" == "aarch64" ]
    then
      HOST_BITS="64"
      HOST_NODE_ARCH="arm64"
    elif [ "${HOST_MACHINE}" == "armv7l" -o "${HOST_MACHINE}" == "armv8l" ]
    then
      HOST_BITS="32"
      HOST_NODE_ARCH="arm"
    else
      echo "Unknown uname -m ${HOST_MACHINE}"
      exit 1
    fi

    local lsb_path=$(which lsb_release)
    if [ -z "${lsb_path}" ]
    then
      echo "Please install the lsb core package and rerun."
      exit 1
    fi

    HOST_DISTRO_NAME=$(lsb_release -si)
    HOST_DISTRO_LC_NAME=$(echo ${HOST_DISTRO_NAME} | tr "[:upper:]" "[:lower:]")

  elif [ "${HOST_NODE_PLATFORM}" == "win32" ]
  then
    if [ "${HOST_MACHINE}" == "x86_64" ]
    then
      HOST_BITS="64"
      HOST_NODE_ARCH="x64"
    elif [ "${HOST_MACHINE}" == "i386" -o "${HOST_MACHINE}" == "i586" -o "${HOST_MACHINE}" == "i686" ]
    then
      HOST_BITS="32"
      HOST_NODE_ARCH="ia32"
    else
      echo "Unknown uname -m ${HOST_MACHINE}"
      exit 1
    fi

    # Git Bash returns "Msys".
    HOST_DISTRO_NAME=$(uname -o)
    HOST_DISTRO_LC_NAME=$(echo ${HOST_DISTRO_NAME} | tr "[:upper:]" "[:lower:]")

  else
    echo "Unsupported uname ${HOST_UNAME}"
    exit 1
  fi

  echo
  echo "Running on ${HOST_DISTRO_NAME} ${HOST_NODE_ARCH} (${HOST_BITS}-bit)..."
  uname -a

  if false # Not available on Windows.
  then
    USER_ID=$(id -u)
    USER_NAME="$(id -u -n)"
    GROUP_ID=$(id -g)
    GROUP_NAME="$(id -g -n)"

    export USER_ID
    export USER_NAME
    export GROUP_ID
    export GROUP_NAME
  fi

  export HOST_UNAME # uname
  export HOST_MACHINE # lower case uname -m, x86_64|i386|i686|aarch64|armv7l|armv8l
  export HOST_DISTRO_NAME
  export HOST_DISTRO_LC_NAME
  export HOST_NODE_PLATFORM # darwin|linux|win32
  export HOST_NODE_ARCH # ia32|x64|arm|arm64
  export HOST_BITS # 64|32
}

# -----------------------------------------------------------------------------
