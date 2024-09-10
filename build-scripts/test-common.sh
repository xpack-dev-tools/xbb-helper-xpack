#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2022 Liviu Ionescu. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Included by the application `scripts/test.sh`.

source "${helper_folder_path}/build-scripts/machine.sh"
source "${helper_folder_path}/build-scripts/wrappers.sh"
source "${helper_folder_path}/build-scripts/is-something.sh"
source "${helper_folder_path}/build-scripts/xbb.sh"
source "${helper_folder_path}/build-scripts/show-libs.sh"
source "${helper_folder_path}/build-scripts/miscellaneous.sh"
source "${helper_folder_path}/build-scripts/timer.sh"
source "${helper_folder_path}/build-scripts/download.sh"
source "${helper_folder_path}/build-scripts/build-tests.sh"

# -----------------------------------------------------------------------------
# Functions used when running separate tests.

# Requires XBB_BASE_URL and lots of other variables.
function tests_install_archive()
{
  echo
  echo "[${FUNCNAME[0]} $@]"

  local tests_folder_path="$1"

  local archive_folder_name="${XBB_APPLICATION_DISTRO_LOWER_CASE_NAME}-${XBB_APPLICATION_LOWER_CASE_NAME}-${XBB_RELEASE_VERSION}"

  export XBB_ARCHIVE_INSTALL_FOLDER_PATH="${tests_folder_path}/${archive_folder_name}"

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
  run_verbose chmod ug+rw "${tests_folder_path}"

  if [ "${XBB_BASE_URL}" == "pre-release" ]
  then
    XBB_BASE_URL=https://github.com/xpack-dev-tools/pre-releases/releases/download/test
  elif [ "${XBB_BASE_URL}" == "release" ]
  then
    XBB_BASE_URL=https://github.com/xpack-dev-tools/${XBB_APPLICATION_LOWER_CASE_NAME}-xpack/releases/download/v${XBB_RELEASE_VERSION}
  fi

  if [ "${XBB_USE_CACHED_ARCHIVE}" == "y" ] && [ -f "${tests_folder_path}/../${archive_name}" ]
  then
    echo
    echo "Using cached ${archive_name}..."
  else
    echo
    echo "Downloading ${archive_name}..."
    run_verbose curl \
      --fail \
      --location \
      --output "${tests_folder_path}/../${archive_name}" \
      "${XBB_BASE_URL}/${archive_name}"

    echo
  fi

  run_verbose cd "${tests_folder_path}"

  echo
  echo "Extracting ${archive_name}..."
  if [[ "${archive_name}" == *.zip ]]
  then
    run_verbose unzip -q "${tests_folder_path}/../${archive_name}"

    # Shorten path to avoid weird error like
    # fatal error: bits/gthr-default.h: No such file or directory
    run_verbose mv "${XBB_ARCHIVE_INSTALL_FOLDER_PATH}" "${tests_folder_path}/archive"
    export XBB_ARCHIVE_INSTALL_FOLDER_PATH="${tests_folder_path}/archive"
  elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
  then
    # On Debian it fails with
    # Cannot change mode to rwxrwxrwx: Operation not permitted
    run_verbose tar xf "${tests_folder_path}/../${archive_name}" --no-same-owner
  elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
  then
    run_verbose tar xf "${tests_folder_path}/../${archive_name}"
  else
    echo "Unsupported XBB_HOST_PLATFORM=${XBB_HOST_PLATFORM} in ${FUNCNAME[0]}()"
    exit 1
  fi

  run_verbose ls -lL "${XBB_ARCHIVE_INSTALL_FOLDER_PATH}"
}

function tests_good_bye()
{
  (
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
      # Travis old images may not include CLT (like 10.15.7)
      if pkgutil --pkg-info=com.apple.pkg.CLTools_Executables 2>/dev/null >/dev/null
      then
        run_verbose pkgutil --pkg-info=com.apple.pkg.CLTools_Executables
      else
        run_verbose xcodebuild -version || true
      fi
    fi
  )
}

function tests_install_via_xpm()
{
  echo
  echo "[${FUNCNAME[0]} $@]"

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
  echo
  echo "[${FUNCNAME[0]} $@]"

  local image_name="$1"

  # Make sure that the minimum prerequisites are met.
  if [[ ${image_name} == github-actions-ubuntu* ]]
  then
    run_verbose sudo apt-get update
    # To make 32-bit tests possible.
    run_verbose sudo apt-get -qq install --yes g++ g++-multilib
  elif [[ ${image_name} == *raspbian* ]]
  then
    run_verbose apt-get -qq update
    run_verbose apt-get -qq install --yes g++
  elif [[ ${image_name} == *ubuntu* ]] || [[ ${image_name} == *debian* ]] || [[ ${image_name} == *raspbian* ]]
  then
    run_verbose apt-get -qq update
    run_verbose apt-get -qq install --yes \
      git-core curl tar gzip lsb-release binutils file \
      build-essential g++ libc6-dev libstdc++6
    if [ "$(uname -m)" == "x86_64" ]
    then
      run_verbose apt-get -qq install --yes g++-multilib
    fi
  elif [[ ${image_name} == *centos* ]] || [[ ${image_name} == *redhat* ]] || [[ ${image_name} == *fedora* ]]
  then
    run_verbose yum update --assumeyes --quiet
    run_verbose yum install --assumeyes --quiet \
      git curl tar gzip redhat-lsb-core binutils which \
      gcc-c++ glibc glibc-common glibc-static libstdc++ libstdc++-static libatomic libgfortran glibc-devel libstdc++-devel make
    if [ "$(uname -m)" == "x86_64" ]
    then
      run_verbose yum install --assumeyes --quiet libgcc*i686 libstdc++*i686 glibc*i686 libatomic*i686 libgfortran*i686
    fi
  elif [[ ${image_name} == *suse* ]]
  then
    run_verbose zypper --quiet --no-gpg-checks update --no-confirm
    run_verbose zypper --quiet --no-gpg-checks install --no-confirm \
      git-core curl tar gzip lsb-release binutils findutils util-linux \
      gcc-c++ glibc glibc-devel-static glibc-devel libstdc++6 make which
    if [ "$(uname -m)" == "x86_64" ]
    then
      run_verbose zypper --quiet --no-gpg-checks install --no-confirm gcc-32bit gcc-c++-32bit glibc-devel-32bit glibc-devel-static-32bit
    fi
  elif [[ ${image_name} == *archlinux* ]] || [[ ${image_name} == *manjaro* ]]
  then
    #
    run_verbose pacman-key --init
    run_verbose pacman-key --populate archlinux
    run_verbose pacman --sync --noconfirm --refresh # -yy
    # For just in case the keys get messed.
    run_verbose pacman --sync --noconfirm archlinux-keyring
    run_verbose pacman --sync --noconfirm --sysupgrade # -u

    run_verbose pacman --sync --noconfirm --noprogressbar \
      git curl tar gzip lsb-release binutils which \
      gcc gcc-libs make
    if [ "$(uname -m)" == "x86_64" ]
    then
      run_verbose pacman --sync --quiet --noconfirm --noprogressbar lib32-gcc-libs
    fi
  fi

  echo
  echo "The system C/C++ libraries..."
  find /usr/lib* /lib -name 'libc.*' -o -name 'libstdc++.*' -o -name 'libgcc_s.*' -name 'libm.*'
}

# Redefine it in the application if more updates are needed.
function tests_update_system()
{
  :
}

# =============================================================================

function tests_perform_common()
{
  echo
  echo "[${FUNCNAME[0]} $@]"

  # Avoid leaving files that cannot be removed by users.
  trap xbb_make_writable EXIT

  timer_start

  # ---------------------------------------------------------------------------

  if [ -f "/.dockerenv" ]
  then
    # Inside a Docker container.
    if [ -n "${XBB_IMAGE_NAME}" ]
    then
      # When running in a Docker container, the system may be minimal; update it.
      export LANG="C"
      tests_update_system_common "${XBB_IMAGE_NAME}"
      tests_update_system "${XBB_IMAGE_NAME}"
      # Do not run this in a sub-shell!
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
      # Currently "ubuntu20".
      export LANG="C"
      tests_update_system_common "${XBB_IMAGE_NAME}"
      tests_update_system "github-actions-${ImageOS}"
      # Do not run this in a sub-shell!
    fi
  fi

  # ---------------------------------------------------------------------------

  machine_detect

  xbb_save_env
  xbb_set_requested
  xbb_reset_env
  xbb_set_target "requested"

  tests_initialize

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
  local archive_suffix="${XBB_BUILD_PLATFORM}-${archive_architecture}.${archive_extension}"

  # The XBB_LOGS_FOLDER_PATH must be set at this point.
  mkdir -pv "${XBB_LOGS_FOLDER_PATH}"
  mkdir -pv "${XBB_TESTS_FOLDER_PATH}"

  (
    if [ "${XBB_TEST_SYSTEM_TOOLS}" == "y" ]
    then
      run_verbose cd "${XBB_TESTS_FOLDER_PATH}"
      tests_run_all ""
    elif [ ! -z "${XBB_EXTERNAL_BIN_PATH}" ]
    then
      run_verbose cd "${XBB_TESTS_FOLDER_PATH}"
      tests_run_all "${XBB_EXTERNAL_BIN_PATH}"
    elif [ "${XBB_DO_TEST_VIA_XPM}" == "y" ]
    then
      tests_install_via_xpm "${XBB_TESTS_FOLDER_PATH}"
      tests_install_dependencies "${XBB_TESTS_FOLDER_PATH}" "${archive_suffix}"
      run_verbose cd "${XBB_TESTS_FOLDER_PATH}"
      tests_run_all "${XBB_XPACK_FOLDER_PATH}/xpacks/.bin"
    elif [ ! -z "${XBB_BASE_URL}" ]
    then
      # Download archive and test its binaries.
      tests_install_archive "${XBB_TESTS_FOLDER_PATH}"
      tests_install_dependencies "${XBB_TESTS_FOLDER_PATH}" "${archive_suffix}"
      run_verbose cd "${XBB_TESTS_FOLDER_PATH}"
      tests_run_all "${XBB_ARCHIVE_INSTALL_FOLDER_PATH}/bin"
    else
      # Test the locally built binaries.
      tests_install_dependencies "${XBB_TESTS_FOLDER_PATH}" "${archive_suffix}"
      run_verbose cd "${XBB_TESTS_FOLDER_PATH}"
      tests_run_all "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/bin"
    fi

    tests_report_results

    tests_good_bye
    timer_stop

  ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${XBB_OUTPUT_FILE_NAME}-output-$(ndate).txt"
}

# Called by xbb_set_target.
function tests_add()
{
  :
}

# Redefine it in update.sh to add functionality.
function tests_install_dependencies()
{
  :
}

# -----------------------------------------------------------------------------
