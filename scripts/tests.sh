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
# Included by the application `scripts/test.sh`.

source "${helper_folder_path}/scripts/host.sh"
source "${helper_folder_path}/scripts/wrappers.sh"
source "${helper_folder_path}/scripts/xbb.sh"
source "${helper_folder_path}/scripts/show-libs.sh"

# -----------------------------------------------------------------------------
# Functions used when running separate tests.

function tests_parse_options()
{
  IS_DEBUG="n"
  IS_DEVELOP="n"

  FORCE_32_BIT="n"
  IMAGE_NAME=""
  RELEASE_VERSION="${RELEASE_VERSION:-$(xbb_get_current_version)}"
  BASE_URL="${BASE_URL:-}"
  DO_TEST_VIA_XPM="n"

  while [ $# -gt 0 ]
  do
    case "$1" in

      --help )
        echo "usage: $(basename $0) [--32] [--version X.Y.Z] [--base-url URL]"
        exit 0
        ;;

      --32 )
        FORCE_32_BIT="y"
        shift
        ;;

      --image )
        IMAGE_NAME="$2"
        shift 2
        ;;

      --version )
        if [ "$2" != "current" ]
        then
          RELEASE_VERSION="$2"
        fi
        shift 2
        ;;

      --base-url )
        BASE_URL="$2"
        shift 2
        ;;

      --xpm )
        DO_TEST_VIA_XPM="y"
        shift
        ;;

      --* )
        echo "Unsupported option $1"
        exit 1
        ;;

      * )
        echo "Unsupported arg $1"
        exit 1
        ;;

    esac
  done

  export IS_DEBUG
  export IS_DEVELOP

  export RELEASE_VERSION
  export BASE_URL
  export IMAGE_NAME
  export FORCE_32_BIT
  export DO_TEST_VIA_XPM

  if false
  then
    echo
    echo "RELEASE_VERSION=${RELEASE_VERSION}"
    echo "BASE_URL=${BASE_URL}"
    echo "FORCE_32_BIT=${FORCE_32_BIT}"
    echo "IMAGE_NAME=${IMAGE_NAME}"
    echo "DO_TEST_VIA_XPM=${DO_TEST_VIA_XPM}"
  fi
}

# Runs natively or inside a container.
#
# Sets the following variables:
#
# - TARGET_PLATFORM=node_platform={win32,linux,darwin}
# - TARGET_ARCH=node_architecture={x64,ia32,arm64,arm}
# - TARGET_BITS={32,64}
#
# It requires the host identity.

function tests_set_target()
{
  # The default case, when the target is the same as the host.
  REQUESTED_TARGET_PLATFORM="${HOST_NODE_PLATFORM}"
  REQUESTED_TARGET_ARCH="${HOST_NODE_ARCH}"
  REQUESTED_TARGET_BITS="${HOST_BITS}"
  REQUESTED_TARGET_MACHINE="${HOST_MACHINE}"

  TARGET_PLATFORM="${REQUESTED_TARGET_PLATFORM}"
  TARGET_ARCH="${REQUESTED_TARGET_ARCH}"
  TARGET_BITS="${REQUESTED_TARGET_BITS}"
  TARGET_MACHINE="${REQUESTED_TARGET_MACHINE}"

  if [ "${FORCE_32_BIT}" == "y" ]
  then
    if [ "${REQUESTED_TARGET_PLATFORM}" == "linux" ] && \
       [ "${REQUESTED_TARGET_ARCH}" == "arm64" ]
    then
      # Pretend to be a 32-bit platform.
      TARGET_ARCH="arm"
      TARGET_BITS="32"
      TARGET_MACHINE="armv8l"
    elif [ "${REQUESTED_TARGET_PLATFORM}" == "linux" ] && \
       [ "${REQUESTED_TARGET_ARCH}" == "arm" ]
    then
      echo "Already a 32-bit platform, --32 ineffective"
    else
      echo "Cannot run 32-bit tests on ${TARGET_MACHINE}"
      exit 1
    fi
  fi

  export REQUESTED_TARGET_PLATFORM
  export REQUESTED_TARGET_ARCH
  export REQUESTED_TARGET_BITS
  export REQUESTED_TARGET_MACHINE

  export TARGET_PLATFORM
  export TARGET_ARCH
  export TARGET_BITS
  export TARGET_MACHINE

  if false
  then
    echo
    echo "TARGET_PLATFORM=${TARGET_PLATFORM}"
    echo "TARGET_ARCH=${TARGET_ARCH}"
    echo "TARGET_BITS=${TARGET_BITS}"
    echo "TARGET_MACHINE=${TARGET_MACHINE}"
  fi
}

# -----------------------------------------------------------------------------

# Requires BASE_URL and lots of other variables.
function tests_install_archive()
{
  local tests_folder_path="$1"

  local archive_extension
  local archive_architecture="${HOST_NODE_ARCH}"
  if [ "${HOST_NODE_PLATFORM}" == "win32" ]
  then
    archive_extension="zip"
    if [ "${FORCE_32_BIT}" == "y" ]
    then
      archive_architecture="ia32"
    fi
  else
    archive_extension="tar.gz"
  fi
  local archive_name="${APP_DISTRO_LC_NAME}-${APP_LC_NAME}-${RELEASE_VERSION}-${HOST_NODE_PLATFORM}-${archive_architecture}.${archive_extension}"
  local archive_folder_name="${APP_DISTRO_LC_NAME}-${APP_LC_NAME}-${RELEASE_VERSION}"

  run_verbose rm -rf "${tests_folder_path}"

  run_verbose mkdir -pv "${tests_folder_path}"

  if [ "${BASE_URL}" == "pre-release" ]
  then
    BASE_URL=https://github.com/xpack-dev-tools/pre-releases/releases/download/test
  elif [ "${BASE_URL}" == "release" ]
  then
    BASE_URL=https://github.com/xpack-dev-tools/${APP_LC_NAME}-xpack/releases/download/${RELEASE_VERSION}
  fi

  echo
  echo "Downloading ${archive_name}..."
  run_verbose curl \
    --fail \
    --location \
    --output "${tests_folder_path}/${archive_name}" \
    "${BASE_URL}/${archive_name}"

  echo

  ARCHIVE_INSTALL_FOLDER_PATH="${tests_folder_path}/${archive_folder_name}"

  run_verbose cd "${tests_folder_path}"

  echo
  echo "Extracting ${archive_name}..."
  if [[ "${archive_name}" == *.zip ]]
  then
    run_verbose unzip -q "${tests_folder_path}/${archive_name}"
  else
    run_verbose tar xf "${tests_folder_path}/${archive_name}"
  fi

  run_verbose ls -lL "${ARCHIVE_INSTALL_FOLDER_PATH}"
}

function tests_good_bye()
{
  echo
  echo "All ${APP_LC_NAME} ${RELEASE_VERSION} tests completed successfully."

  run_verbose uname -a
  if [ "${HOST_NODE_PLATFORM}" == "linux" ]
  then
    # On opensuse/tumbleweed:latest it fails:
    # /usr/bin/lsb_release: line 122: getopt: command not found
    # install gnu-getopt.
    run_verbose lsb_release -a
    run_verbose ldd --version
  elif [ "${HOST_NODE_PLATFORM}" == "darwin" ]
  then
    run_verbose sw_vers
  fi

  if false # [ ! -f "/.dockerenv" -a "${CI:-""}" != "true" ]
  then
    echo
    echo "To remove the temporary folders, use: ' rm -rf ${tests_xpacks_folder_path} '."
    echo "This test also leaves a folder in ~/Downloads and an archive in ${cache_folder_path}."
  fi
}

function tests_install_via_xpm()
{
  local tests_folder_path="$1"

  XPACK_FOLDER_PATH="${tests_folder_path}/${APP_LC_NAME}-xpack"

  rm -rf "${tests_folder_path}"
  mkdir -p "${XPACK_FOLDER_PATH}"
  cd "${XPACK_FOLDER_PATH}"
  run_verbose pwd

  run_verbose npm install --location=global xpm@latest

  run_verbose xpm init
  if [ "${FORCE_32_BIT}" == "y" ]
  then
    # `NPM_PACKAGE` comes from `definitions.sh`.
    run_verbose xpm install ${NPM_PACKAGE} --force-32bit
  else
    run_verbose xpm install ${NPM_PACKAGE}
  fi

}

# =============================================================================

function tests_perform_common()
{
  host_detect

  # ---------------------------------------------------------------------------

  if [ -f "/.dockerenv" ]
  then
    # Inside a Docker container.
    if [ -n "${IMAGE_NAME}" ]
    then
      (
        # When running in a Docker container, the system may be minimal; update it.
        export LANG="C"
        tests_update_system "${IMAGE_NAME}"
      )
    fi

    # The Debian npm docker images have nvm installed in the /root folder;
    # import the nvm settings into the environment to get access to node/npm.
    if [ -d "/root/.nvm" ]
    then
      export NVM_DIR="/root/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

      hash -r
    fi
  else
    # Not inside a Docker; perhaps a GitHub Actions VM.
    if [ "${GITHUB_ACTIONS:-""}" == "true" -a "${RUNNER_OS:-""}" == "Linux" ]
    then
      (
        # Currently "ubuntu20".
        export LANG="C"
        tests_update_system "github-actions-${ImageOS}"
      )
    fi
  fi

  # ---------------------------------------------------------------------------

  tests_set_target

  xbb_set_env

  if [ "${DO_TEST_VIA_XPM}" == "y" ]
  then
    tests_install_via_xpm "${TESTS_FOLDER_PATH}"
    tests_run_all "${XPACK_FOLDER_PATH}/xpacks/.bin"
  elif [ ! -z "${BASE_URL}" ]
  then
    # Download archive and test its binaries.
    tests_install_archive "${TESTS_FOLDER_PATH}"
    tests_run_all "${ARCHIVE_INSTALL_FOLDER_PATH}/bin"
  else
    # Test the locally built binaries.
    tests_run_all "${APPLICATION_INSTALL_FOLDER_PATH}/bin"
  fi

  tests_good_bye
}

# -----------------------------------------------------------------------------
