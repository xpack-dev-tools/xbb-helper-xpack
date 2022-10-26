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
# Included by the application `scripts/build.sh`.

source "${helper_folder_path}/scripts/timer.sh"
source "${helper_folder_path}/scripts/host.sh"
source "${helper_folder_path}/scripts/wrappers.sh"
source "${helper_folder_path}/scripts/xbb.sh"
source "${helper_folder_path}/scripts/build-tests.sh"
source "${helper_folder_path}/scripts/download.sh"
source "${helper_folder_path}/scripts/post-processing.sh"
source "${helper_folder_path}/scripts/show-libs.sh"
source "${helper_folder_path}/scripts/miscellaneous.sh"

# -----------------------------------------------------------------------------

function build_parse_options()
{
  local help_message="$1"
  shift

  XBB_REQUEST_BUILD_WINDOWS="n"

  XBB_IS_DEBUG="n"
  XBB_IS_DEVELOP="n"
  XBB_WITH_STRIP="y"
  XBB_WITH_PDF="n"
  XBB_WITH_HTML="n"
  XBB_WITH_TESTS="n"
  XBB_WITHOUT_MULTILIB="n"
  XBB_TEST_ONLY="n"

  XBB_REQUESTED_TARGET=""
  XBB_REQUESTED_BUILD_RELATIVE_FOLDER=""

  local uname="$(uname)"
  if [ "${uname}" == "Linux" ]
  then
    XBB_JOBS="$(nproc)"
  elif [ "${uname}" == "Darwin" ]
  then
    XBB_JOBS="$(sysctl hw.ncpu | sed 's/hw.ncpu: //')"
  else
    XBB_JOBS="1"
  fi

  echo
  echo "The ${XBB_APPLICATION_DISTRO_NAME} ${XBB_APPLICATION_NAME} distribution build script"

  while [ $# -gt 0 ]
  do
    case "$1" in

      --win|--windows)
        XBB_REQUEST_BUILD_WINDOWS="y"
        shift
        ;;

      --debug)
        XBB_IS_DEBUG="y"
        shift
        ;;

      --develop)
        XBB_IS_DEVELOP="y"
        shift
        ;;

      --jobs)
        shift
        XBB_JOBS=$1
        shift
        ;;

      --disable-strip)
        XBB_WITH_STRIP="n"
        shift
        ;;

      --disable-tests)
        XBB_WITH_TESTS="n"
        shift
        ;;

      --test-only|--tests-only)
        XBB_TEST_ONLY="y"
        shift
        ;;

      --disable-multilib)
        XBB_WITHOUT_MULTILIB="y"
        shift
        ;;

      --target)
        shift
        XBB_REQUESTED_TARGET="$1"
        shift
        ;;

      --build-folder)
        shift
        if [ "${1:0:1}" == "/" ]
        then
          echo "Only relative paths are accepted for --build-folder"
          exit 1
        fi
        XBB_REQUESTED_BUILD_RELATIVE_FOLDER="$1"
        shift
        ;;

      --help)
        echo "Usage:"
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
  if [ "${XBB_IS_DEBUG}" == "y" ]
  then
    XBB_WITH_STRIP="n"
  fi

  export XBB_IS_DEBUG
  export XBB_IS_DEVELOP
  export XBB_WITH_STRIP
  export XBB_WITH_PDF
  export XBB_WITH_HTML
  export XBB_WITH_TESTS
  export XBB_WITHOUT_MULTILIB
  export XBB_TEST_ONLY

  export XBB_REQUEST_BUILD_WINDOWS
  export XBB_REQUESTED_BUILD_RELATIVE_FOLDER
}


# Requires the host identity.
function build_set_request_target()
{
  # The default case, when the target is the same as the host.
  XBB_REQUESTED_TARGET_PLATFORM="${XBB_HOST_NODE_PLATFORM}"
  XBB_REQUESTED_TARGET_ARCH="${XBB_HOST_NODE_ARCH}"
  XBB_REQUESTED_TARGET_BITS="${XBB_HOST_BITS}"
  XBB_REQUESTED_TARGET_MACHINE="${XBB_HOST_MACHINE}"
  XBB_REQUESTED_TARGET_PREFIX=$(xbb_config_guess)

  case "${XBB_REQUESTED_TARGET}" in
    linux-x64 )
      XBB_REQUESTED_TARGET_PLATFORM="linux"
      XBB_REQUESTED_TARGET_ARCH="x64"
      XBB_REQUESTED_TARGET_BITS="64"
      XBB_REQUESTED_TARGET_MACHINE="x86_64"
      ;;

    linux-arm64 )
      XBB_REQUESTED_TARGET_PLATFORM="linux"
      XBB_REQUESTED_TARGET_ARCH="arm64"
      XBB_REQUESTED_TARGET_BITS="64"
      XBB_REQUESTED_TARGET_MACHINE="aarch64"
      ;;

    linux-arm )
      XBB_REQUESTED_TARGET_PLATFORM="linux"
      XBB_REQUESTED_TARGET_ARCH="arm"
      XBB_REQUESTED_TARGET_BITS="32"
      XBB_REQUESTED_TARGET_MACHINE="armv7l"
      ;;

    darwin-x64 )
      XBB_REQUESTED_TARGET_PLATFORM="darwin"
      XBB_REQUESTED_TARGET_ARCH="x64"
      XBB_REQUESTED_TARGET_BITS="64"
      XBB_REQUESTED_TARGET_MACHINE="x86_64"
      ;;

    darwin-arm64 )
      XBB_REQUESTED_TARGET_PLATFORM="darwin"
      XBB_REQUESTED_TARGET_ARCH="arm64"
      XBB_REQUESTED_TARGET_BITS="64"
      XBB_REQUESTED_TARGET_MACHINE="arm64"
      ;;

    win32-x64 )
      XBB_REQUEST_BUILD_WINDOWS="y"
      ;;

    "" )
      # Keep the defaults.
      ;;

    * )
      echo "Unknown --target $1"
      exit 1
      ;;

  esac

  if [ "${XBB_REQUESTED_TARGET_PLATFORM}" != "${XBB_HOST_NODE_PLATFORM}" ] ||
     [ "${XBB_REQUESTED_TARGET_ARCH}" != "${XBB_HOST_NODE_ARCH}" ]
  then
    # TODO: allow armv7l to run on armv8l, but with a warning.
    echo "Cannot cross build --target ${XBB_REQUESTED_TARGET}"
    exit 1
  fi

  # Windows is a special case, the built runs on Linux x64.
  if [ "${XBB_REQUEST_BUILD_WINDOWS}" == "y" ]
  then
    if [ "${XBB_HOST_NODE_PLATFORM}" == "linux" ] && [ "${XBB_HOST_NODE_ARCH}" == "x64" ]
    then
      XBB_REQUESTED_TARGET_PLATFORM="win32"
      XBB_REQUESTED_TARGET_ARCH="x64"
      XBB_REQUESTED_TARGET_BITS="64"
      XBB_REQUESTED_TARGET_MACHINE="x86_64"
      XBB_REQUESTED_TARGET_PREFIX="x86_64-w64-mingw32"
    else
      echo "Windows cross builds are available only on Intel GNU/Linux"
      exit 1
    fi
  fi

  export XBB_REQUESTED_TARGET_PLATFORM
  export XBB_REQUESTED_TARGET_ARCH
  export XBB_REQUESTED_TARGET_BITS
  export XBB_REQUESTED_TARGET_MACHINE
  export XBB_REQUESTED_TARGET_PREFIX
}

# =============================================================================

function build_perform_common()
{
  # Must be after host_parse_options, for a simple --help.
  timer_start

  host_detect

  build_set_request_target

  xbb_set_env

  # Avoid leaving files that cannot be removed by users.
  trap xbb_make_writable EXIT

  tests_initialize

  copy_build_files

  # ---------------------------------------------------------------------------

  echo
  xbb_set_compiler_env

  echo
  echo "Here we go..."
  echo

  # Cannot run in a sub-shell, it sets environment variables.
  build_application_versioned_components

  if [ ! "${XBB_TEST_ONLY}" == "y" ]
  then
    (
      if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
      then
        # The Windows still has a reference to libgcc_s and libwinpthread
        export XBB_DO_COPY_GCC_LIBS="y"
      fi

      # Post processing.
      make_standalone

      # strip_libs
      strip_binaries

      copy_distro_files
      copy_custom_files

      check_binaries

      create_archive
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/post-process-output-$(ndate).txt"
  fi

  # ---------------------------------------------------------------------------

  # Final checks.
  # To keep everything as pristine as possible, run tests
  # only after the archive is packed.

  tests_prime_wine

  tests_run_final

  # ---------------------------------------------------------------------------

  if [ "${XBB_TEST_ONLY}" != "y" ]
  then
    (
      echo
      echo "# Build results..."

      run_verbose ls -l "${XBB_DEPLOY_FOLDER_PATH}"

      run_verbose ls -l "${XBB_APPLICATION_INSTALL_FOLDER_PATH}"
      run_verbose ls -l "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/bin"

      (
        cd "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/bin"

        echo
        echo "package.json xpack.bin definitions:"
        ls -1 | sed -e 's|\.exe$||' | sed -e '/\.dll$/d' | sort | sed -e 's|\(.*\)|      "\1": "./.content/bin/\1",|'
      )
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/post-lists-output-$(ndate).txt"
  fi


  # ---------------------------------------------------------------------------

  timer_stop
}

# -----------------------------------------------------------------------------
