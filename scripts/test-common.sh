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

source "${helper_folder_path}/scripts/machine.sh"
source "${helper_folder_path}/scripts/wrappers.sh"
source "${helper_folder_path}/scripts/xbb.sh"
source "${helper_folder_path}/scripts/show-libs.sh"

# -----------------------------------------------------------------------------
# Functions used when running separate tests.

function tests_parse_options()
{
  XBB_IS_DEBUG="n"
  XBB_IS_DEVELOP="n"

  XBB_FORCE_32_BIT="n"
  XBB_IMAGE_NAME=""
  XBB_RELEASE_VERSION="${XBB_RELEASE_VERSION:-$(xbb_get_current_version)}"
  XBB_BASE_URL="${XBB_BASE_URL:-}"
  XBB_DO_TEST_VIA_XPM="n"

  while [ $# -gt 0 ]
  do
    case "$1" in

      --help )
        echo "usage: $(basename $0) [--32] [--version X.Y.Z] [--base-url URL]"
        exit 0
        ;;

      --32 )
        XBB_FORCE_32_BIT="y"
        shift
        ;;

      --image )
        XBB_IMAGE_NAME="$2"
        shift 2
        ;;

      --version )
        if [ "$2" != "current" ]
        then
          XBB_RELEASE_VERSION="$2"
        fi
        shift 2
        ;;

      --base-url )
        XBB_BASE_URL="$2"
        shift 2
        ;;

      --xpm )
        XBB_DO_TEST_VIA_XPM="y"
        shift
        ;;

      --* )
        echo "Unsupported option $1 in ${FUNCNAME[0]}()"
        exit 1
        ;;

      * )
        echo "Unsupported arg $1 in ${FUNCNAME[0]}()"
        exit 1
        ;;

    esac
  done

  export XBB_IS_DEBUG
  export XBB_IS_DEVELOP

  export XBB_RELEASE_VERSION
  export XBB_BASE_URL
  export XBB_IMAGE_NAME
  export XBB_FORCE_32_BIT
  export XBB_DO_TEST_VIA_XPM

  if false
  then
    echo
    echo "XBB_RELEASE_VERSION=${XBB_RELEASE_VERSION}"
    echo "XBB_BASE_URL=${XBB_BASE_URL}"
    echo "XBB_FORCE_32_BIT=${XBB_FORCE_32_BIT}"
    echo "XBB_IMAGE_NAME=${XBB_IMAGE_NAME}"
    echo "XBB_DO_TEST_VIA_XPM=${XBB_DO_TEST_VIA_XPM}"
  fi
}

# -----------------------------------------------------------------------------

# Requires XBB_BASE_URL and lots of other variables.
function tests_install_archive()
{
  local tests_folder_path="$1"

  local archive_folder_name="${XBB_APPLICATION_DISTRO_LOWER_CASE_NAME}-${XBB_APPLICATION_LOWER_CASE_NAME}-${XBB_RELEASE_VERSION}"

  export XBB_ARCHIVE_INSTALL_FOLDER_PATH="${tests_folder_path}/${archive_folder_name}"

  (
    local archive_extension
    local archive_architecture="${XBB_BUILD_ARCH}"
    if [ "${XBB_BUILD_PLATFORM}" == "win32" ]
    then
      archive_extension="zip"
      if [ "${XBB_FORCE_32_BIT}" == "y" ]
      then
        archive_architecture="ia32"
      fi
    else
      archive_extension="tar.gz"
    fi
    local archive_name="${XBB_APPLICATION_DISTRO_LOWER_CASE_NAME}-${XBB_APPLICATION_LOWER_CASE_NAME}-${XBB_RELEASE_VERSION}-${XBB_BUILD_PLATFORM}-${archive_architecture}.${archive_extension}"

    run_verbose rm -rf "${tests_folder_path}"

    run_verbose mkdir -pv "${tests_folder_path}"

    if [ "${XBB_BASE_URL}" == "pre-release" ]
    then
      XBB_BASE_URL=https://github.com/xpack-dev-tools/pre-releases/releases/download/test
    elif [ "${XBB_BASE_URL}" == "release" ]
    then
      XBB_BASE_URL=https://github.com/xpack-dev-tools/${XBB_APPLICATION_LOWER_CASE_NAME}-xpack/releases/download/${XBB_RELEASE_VERSION}
    fi

    echo
    echo "Downloading ${archive_name}..."
    run_verbose curl \
      --fail \
      --location \
      --output "${tests_folder_path}/${archive_name}" \
      "${XBB_BASE_URL}/${archive_name}"

    echo

    run_verbose cd "${tests_folder_path}"

    echo
    echo "Extracting ${archive_name}..."
    if [[ "${archive_name}" == *.zip ]]
    then
      run_verbose unzip -q "${tests_folder_path}/${archive_name}"
    else
      run_verbose tar xf "${tests_folder_path}/${archive_name}"
    fi

    run_verbose ls -lL "${XBB_ARCHIVE_INSTALL_FOLDER_PATH}"
  )
}

function tests_good_bye()
{
  (
    echo
    echo "All ${XBB_APPLICATION_LOWER_CASE_NAME} ${XBB_RELEASE_VERSION} tests completed successfully."

    run_verbose uname -a
    if [ "${XBB_BUILD_PLATFORM}" == "linux" ]
    then
      # On opensuse/tumbleweed:latest it fails:
      # /usr/bin/lsb_release: line 122: getopt: command not found
      # install gnu-getopt.
      run_verbose lsb_release -a
      run_verbose ldd --version
    elif [ "${XBB_BUILD_PLATFORM}" == "darwin" ]
    then
      run_verbose sw_vers
    fi
  )
}

function tests_install_via_xpm()
{
  local tests_folder_path="$1"

  export XBB_XPACK_FOLDER_PATH="${tests_folder_path}/${XBB_APPLICATION_LOWER_CASE_NAME}-xpack"

  (
    rm -rf "${tests_folder_path}"
    mkdir -pv "${XBB_XPACK_FOLDER_PATH}"
    cd "${XBB_XPACK_FOLDER_PATH}"
    run_verbose pwd

    run_verbose npm install --location=global xpm@latest

    run_verbose xpm init
    if [ "${XBB_FORCE_32_BIT}" == "y" ]
    then
      # `XBB_NPM_PACKAGE` comes from `definitions.sh`.
      run_verbose xpm install ${XBB_NPM_PACKAGE} --force-32bit
    else
      run_verbose xpm install ${XBB_NPM_PACKAGE}
    fi
  )
}

# -----------------------------------------------------------------------------

function tests_update_system_common()
{
  local image_name="$1"

  # Make sure that the minimum prerequisites are met.
  if [[ ${image_name} == github-actions-ubuntu* ]]
  then
    : # sudo apt-get -qq install -y XXX
  elif [[ ${image_name} == *ubuntu* ]] || [[ ${image_name} == *debian* ]] || [[ ${image_name} == *raspbian* ]]
  then
    run_verbose apt-get -qq update
    run_verbose apt-get -qq install -y git-core curl tar gzip lsb-release binutils
  elif [[ ${image_name} == *centos* ]] || [[ ${image_name} == *redhat* ]] || [[ ${image_name} == *fedora* ]]
  then
    run_verbose yum install -y -q git curl tar gzip redhat-lsb-core binutils which
  elif [[ ${image_name} == *suse* ]]
  then
    run_verbose zypper -q --no-gpg-checks in -y git-core curl tar gzip lsb-release binutils findutils util-linux
  elif [[ ${image_name} == *manjaro* ]]
  then
    # run_verbose pacman-mirrors -g
    run_verbose pacman -S -y -q --noconfirm

    # Update even if up to date (-yy) & upgrade (-u).
    # pacman -S -yy -u -q --noconfirm
    run_verbose pacman -S -q --noconfirm --noprogressbar git curl tar gzip lsb-release binutils which
  elif [[ ${image_name} == *archlinux* ]]
  then
    run_verbose pacman -S -y -q --noconfirm

    # Update even if up to date (-yy) & upgrade (-u).
    # pacman -S -yy -u -q --noconfirm
    run_verbose pacman -S -q --noconfirm --noprogressbar git curl tar gzip lsb-release binutils which
  fi
}

# Redefine it in the application if more updates are needed.
function tests_update_system()
{
  :
}

# =============================================================================

function tests_perform_common()
{
  # Avoid leaving files that cannot be removed by users.
  trap xbb_make_writable EXIT

  # ---------------------------------------------------------------------------

  if [ -f "/.dockerenv" ]
  then
    # Inside a Docker container.
    if [ -n "${XBB_IMAGE_NAME}" ]
    then
      (
        # When running in a Docker container, the system may be minimal; update it.
        export LANG="C"
        tests_update_system_common "${XBB_IMAGE_NAME}"
        tests_update_system "${XBB_IMAGE_NAME}"
      )
    fi

    # The first XBB docker images have nvm installed in the /root folder;
    # import the nvm settings into the current user environment to
    # get access to node/npm. No longer needed with v5.0 or later.
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
        tests_update_system_common "${XBB_IMAGE_NAME}"
        tests_update_system "github-actions-${ImageOS}"
      )
    fi
  fi

  # ---------------------------------------------------------------------------

  machine_detect

  xbb_save_env
  xbb_set_requested
  xbb_reset_env
  xbb_set_target

  if [ "${XBB_DO_TEST_VIA_XPM}" == "y" ]
  then
    tests_install_via_xpm "${XBB_TESTS_FOLDER_PATH}"
    tests_run_all "${XBB_XPACK_FOLDER_PATH}/xpacks/.bin"
  elif [ ! -z "${XBB_BASE_URL}" ]
  then
    # Download archive and test its binaries.
    tests_install_archive "${XBB_TESTS_FOLDER_PATH}"
    tests_run_all "${XBB_ARCHIVE_INSTALL_FOLDER_PATH}/bin"
  else
    # Test the locally built binaries.
    tests_run_all "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/bin"
  fi

  tests_good_bye
}

# Called by xbb_set_target.
function tests_add()
{
  :
}

# -----------------------------------------------------------------------------
