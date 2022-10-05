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
  HOST_UNAME="$(uname)"
  HOST_MACHINE="$(uname -m)" # More reliable than uname -p

  HOST_DISTRO_NAME="?" # Linux distribution name (Ubuntu|CentOS|...)
  HOST_DISTRO_LC_NAME="?" # Same, in lower case.

  HOST_NODE_PLATFORM="?" # Node.js process.platform (darwin|linux|win32)
  HOST_NODE_ARCH="?" # Node.js process.arch (ia32|x64|arm|arm64)

  HOST_BITS="?"

  if [ "${HOST_UNAME}" == "Darwin" ]
  then
    # uname -p -> i386, arm
    # uname -m -> x86_64, arm64

    HOST_DISTRO_NAME=Darwin
    HOST_DISTRO_LC_NAME=darwin

    HOST_BITS="64"

    HOST_NODE_PLATFORM="darwin"
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

  elif [ "${HOST_UNAME}" == "Linux" ]
  then
    # ----- Determine distribution name and word size -----

    # uname -p -> x86_64|i686 (unknown in recent versions, use -m)
    # uname -m -> x86_64|i686|aarch64|armv7l

    HOST_NODE_PLATFORM="linux"

    if [ "${HOST_MACHINE}" == "x86_64" ]
    then
      HOST_BITS="64"
      HOST_NODE_ARCH="x64"
    elif [ "${HOST_MACHINE}" == "i386" -o "${HOST_MACHINE}" == "i686" ]
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

  else
    echo "Unsupported uname ${HOST_UNAME}"
    exit 1
  fi

  echo
  echo "Running on ${HOST_DISTRO_NAME} ${HOST_NODE_ARCH} (${HOST_BITS}-bit)."
  uname -a

  USER_ID=$(id -u)
  USER_NAME="$(id -u -n)"
  GROUP_ID=$(id -g)
  GROUP_NAME="$(id -g -n)"
}


function host_parse_options()
{
  local help_message="$1"
  shift

  ACTION=""

  DO_BUILD_WIN="n"
  IS_DEBUG="n"
  IS_DEVELOP=""
  WITH_STRIP="y"
  WITH_PDF="n"
  WITH_HTML="n"
  WITH_TESTS="n"
  IS_NATIVE="y"
  WITHOUT_MULTILIB="n"
  TEST_ONLY="n"

  if [ "$(uname)" == "Linux" ]
  then
    JOBS="$(nproc)"
  elif [ "$(uname)" == "Darwin" ]
  then
    JOBS="$(sysctl hw.ncpu | sed 's/hw.ncpu: //')"
  else
    JOBS="1"
  fi

  echo
  echo "The ${DISTRO_NAME} ${APP_NAME} distribution build script"

  while [ $# -gt 0 ]
  do
    case "$1" in

      --win|--windows)
        DO_BUILD_WIN="y"
        shift
        ;;

      --debug)
        IS_DEBUG="y"
        shift
        ;;

      --develop)
        IS_DEVELOP="y"
        shift
        ;;

      --jobs)
        shift
        JOBS=$1
        shift
        ;;

      --disable-strip)
        WITH_STRIP="n"
        shift
        ;;

      --disable-tests)
        WITH_TESTS="n"
        shift
        ;;

      --test-only|--tests-only)
        TEST_ONLY="y"
        shift
        ;;

      --disable-multilib)
        WITHOUT_MULTILIB="y"
        shift
        ;;

      --help)
        echo "Usage:"
        # Some of the options are processed by the container script.
        echo "${help_message}"
        echo
        exit 0
        ;;

      *)
        echo "Unknown action/option $1"
        exit 1
        ;;

    esac

  done

  # Debug automatically disables strip.
  if [ "${IS_DEBUG}" == "y" ]
  then
    WITH_STRIP="n"
  fi

  if [ "${DO_BUILD_WIN}" == "y" ]
  then
    if [ "${HOST_NODE_PLATFORM}" == "linux" ] && [ "${HOST_NODE_ARCH}" == "x64" ]
    then
      TARGET_PLATFORM="win32"
    else
      echo "Windows cross builds are available only on Intel GNU/Linux."
      exit 1
    fi
  fi
}

# -----------------------------------------------------------------------------
