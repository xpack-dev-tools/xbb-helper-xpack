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

  REQUEST_BUILD_WINDOWS="n"

  IS_DEBUG="n"
  IS_DEVELOP="n"
  WITH_STRIP="y"
  WITH_PDF="n"
  WITH_HTML="n"
  WITH_TESTS="n"
  WITHOUT_MULTILIB="n"
  TEST_ONLY="n"

  REQUESTED_TARGET=""
  REQUESTED_BUILD_RELATIVE_FOLDER=""

  local uname="$(uname)"
  if [ "${uname}" == "Linux" ]
  then
    JOBS="$(nproc)"
  elif [ "${uname}" == "Darwin" ]
  then
    JOBS="$(sysctl hw.ncpu | sed 's/hw.ncpu: //')"
  else
    JOBS="1"
  fi

  echo
  echo "The ${APP_DISTRO_NAME} ${APP_NAME} distribution build script"

  while [ $# -gt 0 ]
  do
    case "$1" in

      --win|--windows)
        REQUEST_BUILD_WINDOWS="y"
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

      --target)
        shift
        REQUESTED_TARGET="$1"
        shift
        ;;

      --build-folder)
        shift
        if [ "${1:0:1}" == "/" ]
        then
          echo "Only relative paths are accepted for --build-folder"
          exit 1
        fi
        REQUESTED_BUILD_RELATIVE_FOLDER="$1"
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
  if [ "${IS_DEBUG}" == "y" ]
  then
    WITH_STRIP="n"
  fi

  export IS_DEBUG
  export IS_DEVELOP
  export WITH_STRIP
  export WITH_PDF
  export WITH_HTML
  export WITH_TESTS
  export WITHOUT_MULTILIB
  export TEST_ONLY

  export REQUEST_BUILD_WINDOWS
  export REQUESTED_BUILD_RELATIVE_FOLDER
}


# Requires the host identity.
function build_set_request_target()
{
  # The default case, when the target is the same as the host.
  REQUESTED_TARGET_PLATFORM="${HOST_NODE_PLATFORM}"
  REQUESTED_TARGET_ARCH="${HOST_NODE_ARCH}"
  REQUESTED_TARGET_BITS="${HOST_BITS}"
  REQUESTED_TARGET_MACHINE="${HOST_MACHINE}"

  case "${REQUESTED_TARGET}" in
    linux-x64)
      REQUESTED_TARGET_PLATFORM="linux"
      REQUESTED_TARGET_ARCH="x64"
      REQUESTED_TARGET_BITS="64"
      REQUESTED_TARGET_MACHINE="x86_64"
      ;;

    linux-arm64)
      REQUESTED_TARGET_PLATFORM="linux"
      REQUESTED_TARGET_ARCH="arm64"
      REQUESTED_TARGET_BITS="64"
      REQUESTED_TARGET_MACHINE="aarch64"
      ;;

    linux-arm)
      REQUESTED_TARGET_PLATFORM="linux"
      REQUESTED_TARGET_ARCH="arm"
      REQUESTED_TARGET_BITS="32"
      REQUESTED_TARGET_MACHINE="armv7l"
      ;;

    darwin-x64)
      REQUESTED_TARGET_PLATFORM="darwin"
      REQUESTED_TARGET_ARCH="x64"
      REQUESTED_TARGET_BITS="64"
      REQUESTED_TARGET_MACHINE="x86_64"
      ;;

    darwin-arm64)
      REQUESTED_TARGET_PLATFORM="darwin"
      REQUESTED_TARGET_ARCH="arm64"
      REQUESTED_TARGET_BITS="64"
      REQUESTED_TARGET_MACHINE="arm64"
      ;;

    win32-x64)
      REQUEST_BUILD_WINDOWS="y"
      ;;

    "")
      # Keep the defaults.
      ;;

    *)
      echo "Unknown --target $1"
      exit 1
      ;;

  esac

  if [ "${REQUESTED_TARGET_PLATFORM}" != "${HOST_NODE_PLATFORM}" -o "${REQUESTED_TARGET_ARCH}" != "${HOST_NODE_ARCH}" ]
  then
    # TODO: allow armv7l to run on armv8l, but with a warning.
    echo "Cannot cross build --target ${REQUESTED_TARGET}"
    exit 1
  fi

  # Windows is a special case, the built runs on Linux x64.
  if [ "${REQUEST_BUILD_WINDOWS}" == "y" ]
  then
    if [ "${HOST_NODE_PLATFORM}" == "linux" ] && [ "${HOST_NODE_ARCH}" == "x64" ]
    then
      REQUESTED_TARGET_PLATFORM="win32"
      REQUESTED_TARGET_ARCH="x64"
      REQUESTED_TARGET_BITS="64"
      REQUESTED_TARGET_MACHINE="x86_64"
    else
      echo "Windows cross builds are available only on Intel GNU/Linux"
      exit 1
    fi
  fi

  export REQUESTED_TARGET_PLATFORM
  export REQUESTED_TARGET_ARCH
  export REQUESTED_TARGET_BITS
  export REQUESTED_TARGET_MACHINE
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

  (
    echo
    xbb_set_compiler_env

    echo
    echo "Here we go..."
    echo

    build_versioned_components

    if [ ! "${TEST_ONLY}" == "y" ]
    then
      (
        if [ "${TARGET_PLATFORM}" == "win32" ]
        then
          # The Windows still has a reference to libgcc_s and libwinpthread
          export DO_COPY_GCC_LIBS="y"
        fi

        # Post processing.
        make_standalone

        # strip_libs
        strip_binaries

        copy_distro_files
        copy_custom_files

        check_binaries

        create_archive
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/post-process-output-$(ndate).txt"
    fi
  )

  # ---------------------------------------------------------------------------

  # Final checks.
  # To keep everything as pristine as possible, run tests
  # only after the archive is packed.

  tests_prime_wine

  tests_run_final

  # -----------------------------------------------------------------------------

  if [ "${TEST_ONLY}" != "y" ]
  then
    (
      echo
      echo "# Build results..."

      run_verbose ls -l "${DEPLOY_FOLDER_PATH}"

      run_verbose ls -l "${APPLICATION_INSTALL_FOLDER_PATH}"
      run_verbose ls -l "${APPLICATION_INSTALL_FOLDER_PATH}/bin"

      (
        cd "${APPLICATION_INSTALL_FOLDER_PATH}/bin"

        echo
        echo "package.json xpack.bin definitions:"
        ls -1 | sed -e 's|\.exe$||' | sed -e '/\.dll$/d' | sort | sed -e 's|\(.*\)|      "\1": "./.content/bin/\1",|'
      )
    ) 2>&1 | tee "${LOGS_FOLDER_PATH}/post-lists-output-$(ndate).txt"
  fi


  # ---------------------------------------------------------------------------

  timer_stop
}

# -----------------------------------------------------------------------------
