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

# Be a nice citizen and allow the created folders to be removed by users.
# Otherwise subsequent runs will fail to remove the folders (owned by root).
function xbb_make_writable()
{
  if [ -f "/.dockerenv" ]
  then
    (
      set +e

      if [ -d "${project_folder_path}/build" ]
      then
        echo
        echo "Make the build folder writable by all..."

        run_verbose chmod -R a+w "${project_folder_path}/build"
      fi


      if [ -d "${project_folder_path}/xpacks" ]
      then
        echo
        echo "Make the xpacks folder writable by all..."

        run_verbose find "${project_folder_path}/xpacks" -type d -exec chmod a+w '{}' ';'

        # Non-recursive! (Recursive fails with exit code 2)
        # run_verbose chmod a+w "${project_folder_path}/xpacks"

        # if [ -d "${project_folder_path}/xpacks/.bin" ]
        # then
        #   run_verbose chmod a+w "${project_folder_path}/xpacks/.bin"
        # fi
      fi
    )
  fi
}

function xbb_save_env()
{
  echo
  echo_develop "[${FUNCNAME[0]} $@]"

  export XBB_SAVED_PATH="${PATH:-""}"
}

function xbb_reset_env()
{
  echo
  echo_develop "[${FUNCNAME[0]} $@]"

  # Restore it to the initial values.
  export PATH="${XBB_SAVED_PATH}"

  if [ "${XBB_BUILD_PLATFORM}" == "darwin" ]
  then
    # Setting this on macOS 10.13 is harmful, for example cmake fails to start.
    export DYLD_LIBRARY_PATH=""
  else
    export LD_LIBRARY_PATH=""
  fi

  export XBB_LIBRARY_PATH=""

  # Defaults, to ensure the variables are defined.
  export LANG="${LANG:-"C"}"
  export CI=${CI:-"false"}

  # ---------------------------------------------------------------------------

  XBB_DASH_V=""
  if [ "${XBB_IS_DEVELOP}" == "y" ]
  then
    XBB_DASH_V="-v"
  fi

  XBB_RELEASE_VERSION="${XBB_RELEASE_VERSION:-$(xbb_get_current_version)}"

  XBB_TARGET_FOLDER_NAME="${XBB_REQUESTED_TARGET_PLATFORM}-${XBB_REQUESTED_TARGET_ARCH}"

  # Decide where to run the build for the requested target.
  if is_variable_set "WORK_FOLDER_PATH"
  then
    # On the main development machine, the repos are stored in a folder
    # that is saved daily by Time Machine, and having the build folders
    # in the same place is a waste.
    # To avoid this, define a separate work folder (excluded from backup,
    # usually something like "${HOME}/Work")
    # and group all targets below a versioned application folder.
    XBB_TARGET_WORK_FOLDER_PATH="${WORK_FOLDER_PATH}/xpack-dev-tools-build/${XBB_APPLICATION_LOWER_CASE_NAME}-${XBB_RELEASE_VERSION}/${XBB_TARGET_FOLDER_NAME}"
  elif [ ! -z "${XBB_REQUESTED_BUILD_RELATIVE_FOLDER:-}" ]
  then
    # If the user provides an explicit relative folder, use it.
    XBB_TARGET_WORK_FOLDER_PATH="${project_folder_path}/${XBB_REQUESTED_BUILD_RELATIVE_FOLDER}"
  else
    # The default is inside the project build folder.
    XBB_TARGET_WORK_FOLDER_PATH="${project_folder_path}/build/${XBB_TARGET_FOLDER_NAME}"
  fi
  XBB_BUILD_GIT_PATH="${project_folder_path}"

  XBB_DOWNLOAD_FOLDER_PATH="${XBB_DOWNLOAD_FOLDER_PATH:-"${HOME}/Work/cache"}"

  XBB_SOURCES_FOLDER_NAME="${XBB_SOURCES_FOLDER_NAME:-sources}"
  XBB_SOURCES_FOLDER_PATH="${XBB_TARGET_WORK_FOLDER_PATH}/${XBB_SOURCES_FOLDER_NAME}"

  XBB_APPLICATION_INSTALL_FOLDER_PATH="${XBB_TARGET_WORK_FOLDER_PATH}/application"

  XBB_DEPLOY_FOLDER_NAME="${XBB_DEPLOY_FOLDER_NAME:-deploy}"
  XBB_DEPLOY_FOLDER_PATH="${XBB_TARGET_WORK_FOLDER_PATH}/${XBB_DEPLOY_FOLDER_NAME}"

  XBB_ARCHIVE_FOLDER_NAME="${XBB_ARCHIVE_FOLDER_NAME:-archive}"
  XBB_ARCHIVE_FOLDER_PATH="${XBB_TARGET_WORK_FOLDER_PATH}/${XBB_ARCHIVE_FOLDER_NAME}"

  XBB_DISTRO_INFO_NAME=${XBB_DISTRO_INFO_NAME:-"distro-info"}

  XBB_INSTALL_FOLDER_NAME="${XBB_INSTALL_FOLDER_NAME:-install}"

  XBB_TARGET_NATIVE_FOLDER_PATH="${XBB_TARGET_WORK_FOLDER_PATH}/${XBB_BUILD_TRIPLET}"
  XBB_NATIVE_DEPENDENCIES_INSTALL_FOLDER_PATH="${XBB_TARGET_NATIVE_FOLDER_PATH}/${XBB_INSTALL_FOLDER_NAME}"

  XBB_BOOTSTRAP_SUFFIX="-bootstrap"

  export XBB_DASH_V

  export XBB_BUILD_GIT_PATH
  export XBB_DISTRO_INFO_NAME

  export XBB_TARGET_WORK_FOLDER_PATH
  export XBB_DOWNLOAD_FOLDER_PATH
  export XBB_SOURCES_FOLDER_PATH
  export XBB_APPLICATION_INSTALL_FOLDER_PATH
  export XBB_DEPLOY_FOLDER_PATH
  export XBB_ARCHIVE_FOLDER_PATH

  export XBB_NATIVE_DEPENDENCIES_INSTALL_FOLDER_PATH

  export XBB_BOOTSTRAP_SUFFIX

  # ---------------------------------------------------------------------------

  # libtool fails with the old Ubuntu /bin/sh.
  export SHELL="$(which bash 2>/dev/null || echo "/bin/bash")"
  export CONFIG_SHELL="$(which bash 2>/dev/null || echo "/bin/bash")"

  # Prevent 'configure: error: you should not run configure as root'
  # when running inside a docker container.
  export FORCE_UNSAFE_CONFIGURE=1

  xbb_set_actual_commands
}

function xbb_set_actual_commands()
{
  # On MSYS2, which complains about the missing file.
  export M4=$(which gm4 2>/dev/null || which m4 2>/dev/null || echo m4)
  export PYTHON=$(which python3 2>/dev/null || which python 2>/dev/null || echo python)
  export SED=$(which gsed 2>/dev/null || which sed 2>/dev/null || echo sed)
  export INSTALL=$(which install 2>/dev/null || echo install)
  export REALPATH=$(which_realpath)
  export MAKEINFO=$(which makeinfo 2>/dev/null || echo makeinfo)
}

function xbb_prepare_pkg_config()
{
  if [ ! -z "$(which pkg-config)" -a "${XBB_IS_DEVELOP}" == "y" ]
  then
    # Extra: pkg-config-verbose.
    run_verbose ${INSTALL} -d -m 0755 "${XBB_NATIVE_DEPENDENCIES_INSTALL_FOLDER_PATH}/bin"
    run_verbose ${INSTALL} -v -c -m 755 "${helper_folder_path}/extras/pkg-config-verbose" \
      "${XBB_NATIVE_DEPENDENCIES_INSTALL_FOLDER_PATH}/bin"

    PKG_CONFIG="${XBB_NATIVE_DEPENDENCIES_INSTALL_FOLDER_PATH}/bin/pkg-config-verbose"
  elif [ ! -z "$(which pkg-config)" ]
  then
    PKG_CONFIG="$(which pkg-config)"
  fi

  # Hopefully defining it empty would be enough...
  PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-""}

  # Prevent pkg-config to search the system folders (configured in the
  # pkg-config at build time).
  PKG_CONFIG_LIBDIR=${PKG_CONFIG_LIBDIR:-""}

  export PKG_CONFIG
  export PKG_CONFIG_PATH
  export PKG_CONFIG_LIBDIR
}

# Requires the build machine identity and the XBB_REQUESTED_TARGET variable,
# set via --target in build_common_parse_options().
function xbb_set_requested()
{
  echo
  echo_develop "[${FUNCNAME[0]} $@]"

  case "${XBB_REQUESTED_TARGET:-""}" in
    linux-x64 )
      XBB_REQUESTED_HOST_PLATFORM="linux"
      XBB_REQUESTED_HOST_ARCH="x64"
      XBB_REQUESTED_HOST_BITS="64"
      XBB_REQUESTED_HOST_MACHINE="x86_64"
      XBB_REQUESTED_HOST_TRIPLET="${XBB_BUILD_TRIPLET}"
      ;;

    linux-arm64 )
      XBB_REQUESTED_HOST_PLATFORM="linux"
      XBB_REQUESTED_HOST_ARCH="arm64"
      XBB_REQUESTED_HOST_BITS="64"
      XBB_REQUESTED_HOST_MACHINE="aarch64"
      XBB_REQUESTED_HOST_TRIPLET="${XBB_BUILD_TRIPLET}"
      ;;

    linux-arm )
      XBB_REQUESTED_HOST_PLATFORM="linux"
      XBB_REQUESTED_HOST_ARCH="arm"
      XBB_REQUESTED_HOST_BITS="32"
      XBB_REQUESTED_HOST_MACHINE="armv7l"
      XBB_REQUESTED_HOST_TRIPLET="${XBB_BUILD_TRIPLET}"
      ;;

    darwin-x64 )
      XBB_REQUESTED_HOST_PLATFORM="darwin"
      XBB_REQUESTED_HOST_ARCH="x64"
      XBB_REQUESTED_HOST_BITS="64"
      XBB_REQUESTED_HOST_MACHINE="x86_64"
      XBB_REQUESTED_HOST_TRIPLET="${XBB_BUILD_TRIPLET}"
      ;;

    darwin-arm64 )
      XBB_REQUESTED_HOST_PLATFORM="darwin"
      XBB_REQUESTED_HOST_ARCH="arm64"
      XBB_REQUESTED_HOST_BITS="64"
      XBB_REQUESTED_HOST_MACHINE="arm64"
      XBB_REQUESTED_HOST_TRIPLET="${XBB_BUILD_TRIPLET}"
      ;;

    win32-x64 )
      # The Windows build is a special case, it runs only on Linux x64.
      if [ "${XBB_BUILD_PLATFORM}" == "linux" ] && [ "${XBB_BUILD_ARCH}" == "x64" ]
      then
        XBB_REQUESTED_HOST_PLATFORM="win32"
        XBB_REQUESTED_HOST_ARCH="x64"
        XBB_REQUESTED_HOST_BITS="64"
        XBB_REQUESTED_HOST_MACHINE="x86_64"
        XBB_REQUESTED_HOST_TRIPLET="x86_64-w64-mingw32"
      else
        echo "Windows cross builds are available only on Intel GNU/Linux"
        exit 1
      fi
      ;;

    "" )
      XBB_REQUESTED_HOST_PLATFORM="${XBB_BUILD_PLATFORM}"
      XBB_REQUESTED_HOST_ARCH="${XBB_BUILD_ARCH}"
      XBB_REQUESTED_HOST_BITS="${XBB_BUILD_BITS}"
      XBB_REQUESTED_HOST_MACHINE="${XBB_BUILD_MACHINE}"
      XBB_REQUESTED_HOST_TRIPLET="${XBB_BUILD_TRIPLET}"
      ;;

    * )
      echo "Unsupported --target $1 in ${FUNCNAME[0]}()"
      exit 1
      ;;

  esac

  export XBB_REQUESTED_HOST_PLATFORM
  export XBB_REQUESTED_HOST_ARCH
  export XBB_REQUESTED_HOST_BITS
  export XBB_REQUESTED_HOST_MACHINE
  export XBB_REQUESTED_HOST_TRIPLET

  XBB_REQUESTED_TARGET_PLATFORM="${XBB_REQUESTED_HOST_PLATFORM}"
  XBB_REQUESTED_TARGET_ARCH="${XBB_REQUESTED_HOST_ARCH}"
  XBB_REQUESTED_TARGET_BITS="${XBB_REQUESTED_HOST_BITS}"
  XBB_REQUESTED_TARGET_MACHINE="${XBB_REQUESTED_HOST_MACHINE}"
  XBB_REQUESTED_TARGET_TRIPLET="${XBB_REQUESTED_HOST_TRIPLET}"

  export XBB_REQUESTED_TARGET_PLATFORM
  export XBB_REQUESTED_TARGET_ARCH
  export XBB_REQUESTED_TARGET_BITS
  export XBB_REQUESTED_TARGET_MACHINE
  export XBB_REQUESTED_TARGET_TRIPLET
}


# Sets the following variables:
#
# - XBB_HOST|TARGET_PLATFORM=node_platform={win32,linux,darwin}
# - XBB_HOST|TARGET_ARCH=node_architecture={x64,ia32,arm64,arm}
# - XBB_HOST|TARGET_BITS={32,64}
# - XBB_HOST|TARGET_MACHINE={x86_64,arm64,aarch64,armv7l,armv8l}
# - XBB_HOST|TARGET_TRIPLET={*,x86_64-w64-mingw32}

# DO NOT explicitly set the executable path again!, since for mingw
# the XBB_DEPENDENCIES_INSTALL_FOLDER_PATH variable is adjusted for
# the target libraries.

# "requested", "native", "mingw-w64-native", "mingw-w64-cross"which_realpath
function xbb_set_target()
{
  local kind="$1"

  echo
  echo_develop "[${FUNCNAME[0]} $@]"

  if [ "${kind}" == "native" ]
  then
    # is_native=true
    # is_non_native=false
    # is_bootstrap=false
    # is_cross=false
    XBB_HOST_PLATFORM="${XBB_BUILD_PLATFORM}"
    XBB_HOST_ARCH="${XBB_BUILD_ARCH}"
    XBB_HOST_BITS="${XBB_BUILD_BITS}"
    XBB_HOST_MACHINE="${XBB_BUILD_MACHINE}"
    XBB_HOST_TRIPLET="${XBB_BUILD_TRIPLET}"

    # The target is the same as the host.
    XBB_TARGET_PLATFORM="${XBB_BUILD_PLATFORM}"
    XBB_TARGET_ARCH="${XBB_BUILD_ARCH}"
    XBB_TARGET_BITS="${XBB_BUILD_BITS}"
    XBB_TARGET_MACHINE="${XBB_BUILD_MACHINE}"
    XBB_TARGET_TRIPLET="${XBB_BUILD_TRIPLET}"
  elif [ "${kind}" == "mingw-w64-native" ]
  then
    # is_native=false (on Unix)
    # is_non_native=true (on Unix)
    # is_bootstrap=true
    # is_cross=false
    XBB_HOST_PLATFORM="${XBB_BUILD_PLATFORM}"
    XBB_HOST_ARCH="${XBB_BUILD_ARCH}"
    XBB_HOST_BITS="${XBB_BUILD_BITS}"
    XBB_HOST_MACHINE="${XBB_BUILD_MACHINE}"
    XBB_HOST_TRIPLET="${XBB_BUILD_TRIPLET}"

    XBB_TARGET_PLATFORM="win32"
    XBB_TARGET_ARCH="x64"
    XBB_TARGET_BITS="64"
    XBB_TARGET_MACHINE="x86_64"
    XBB_TARGET_TRIPLET="x86_64-w64-mingw32"
  elif [ "${kind}" == "mingw-w64-cross" ]
  then
    # is_native=false (on Unix)
    # is_non_native=true (on Unix)
    # is_bootstrap=false
    # is_cross=true
    XBB_HOST_PLATFORM="win32"
    XBB_HOST_ARCH="x64"
    XBB_HOST_BITS="64"
    XBB_HOST_MACHINE="x86_64"
    XBB_HOST_TRIPLET="x86_64-w64-mingw32"

    XBB_TARGET_PLATFORM="win32"
    XBB_TARGET_ARCH="x64"
    XBB_TARGET_BITS="64"
    XBB_TARGET_MACHINE="x86_64"
    XBB_TARGET_TRIPLET="x86_64-w64-mingw32"
  elif [ "${kind}" == "requested" ]
  then
    # Set the actual to the requested.
    # It is either native or cross (on Unix).
    XBB_HOST_PLATFORM="${XBB_REQUESTED_HOST_PLATFORM}"
    XBB_HOST_ARCH="${XBB_REQUESTED_HOST_ARCH}"
    XBB_HOST_BITS="${XBB_REQUESTED_HOST_BITS}"
    XBB_HOST_MACHINE="${XBB_REQUESTED_HOST_MACHINE}"
    XBB_HOST_TRIPLET="${XBB_REQUESTED_HOST_TRIPLET}"

    XBB_TARGET_PLATFORM="${XBB_REQUESTED_TARGET_PLATFORM}"
    XBB_TARGET_ARCH="${XBB_REQUESTED_TARGET_ARCH}"
    XBB_TARGET_BITS="${XBB_REQUESTED_TARGET_BITS}"
    XBB_TARGET_MACHINE="${XBB_REQUESTED_TARGET_MACHINE}"
    XBB_TARGET_TRIPLET="${XBB_REQUESTED_TARGET_TRIPLET}"

    if [ "${XBB_FORCE_32_BIT:-""}" == "y" ]
    then
      if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "linux" ] && \
        [ "${XBB_REQUESTED_HOST_ARCH}" == "arm64" ]
      then
        # Pretend to be a 32-bit platform.
        XBB_HOST_ARCH="arm"
        XBB_HOST_BITS="32"
        XBB_HOST_MACHINE="armv8l"

        XBB_TARGET_ARCH="arm"
        XBB_TARGET_BITS="32"
        XBB_TARGET_MACHINE="armv8l"
      elif [ "${XBB_REQUESTED_HOST_PLATFORM}" == "linux" ] && \
        [ "${XBB_REQUESTED_HOST_ARCH}" == "arm" ]
      then
        echo "Already a 32-bit platform, --32 ineffective"
      else
        echo "Cannot run 32-bit tests on ${XBB_TARGET_MACHINE}"
        exit 1
      fi
    fi
  else
    echo "Unsupported xbb_set_target ${kind} in ${FUNCNAME[0]}()"
    exit 1
  fi

  export XBB_HOST_PLATFORM
  export XBB_HOST_ARCH
  export XBB_HOST_BITS
  export XBB_HOST_MACHINE
  export XBB_HOST_TRIPLET

  export XBB_TARGET_PLATFORM
  export XBB_TARGET_ARCH
  export XBB_TARGET_BITS
  export XBB_TARGET_MACHINE
  export XBB_TARGET_TRIPLET

  # ---------------------------------------------------------------------------
  # Specific paths. Identified by the destination host[/target] triplet.
  XBB_DESTINATION_FOLDER_PATH="${XBB_TARGET_WORK_FOLDER_PATH}/${XBB_HOST_TRIPLET}"

  # Binaries are installed in the top folder.
  xbb_set_executables_install_path "${XBB_DESTINATION_FOLDER_PATH}/${XBB_INSTALL_FOLDER_NAME}"

  if [ "${XBB_HOST_TRIPLET}" != "${XBB_TARGET_TRIPLET}" ]
  then
    XBB_DESTINATION_FOLDER_PATH+="/${XBB_TARGET_TRIPLET}"
  fi

  XBB_DEPENDENCIES_INSTALL_FOLDER_PATH="${XBB_DESTINATION_FOLDER_PATH}/${XBB_INSTALL_FOLDER_NAME}"

  # Libraries are installed in the specific folder.
  xbb_set_libraries_install_path "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}"

  XBB_BUILD_FOLDER_NAME="${XBB_BUILD_FOLDER_NAME-build}"
  XBB_BUILD_FOLDER_PATH="${XBB_DESTINATION_FOLDER_PATH}/${XBB_BUILD_FOLDER_NAME}"

  XBB_STAMPS_FOLDER_NAME="${XBB_STAMPS_FOLDER_NAME:-stamps}"
  XBB_STAMPS_FOLDER_PATH="${XBB_DESTINATION_FOLDER_PATH}/${XBB_STAMPS_FOLDER_NAME}"

  XBB_LOGS_FOLDER_NAME="${XBB_LOGS_FOLDER_NAME:-logs}"
  XBB_LOGS_FOLDER_PATH="${XBB_DESTINATION_FOLDER_PATH}/${XBB_LOGS_FOLDER_NAME}"

  XBB_TESTS_FOLDER_NAME="${XBB_TESTS_FOLDER_NAME:-tests}"
  XBB_TESTS_FOLDER_PATH="${XBB_DESTINATION_FOLDER_PATH}/${XBB_TESTS_FOLDER_NAME}"

  export XBB_DEPENDENCIES_INSTALL_FOLDER_PATH

  export XBB_BUILD_FOLDER_PATH
  export XBB_STAMPS_FOLDER_PATH
  export XBB_LOGS_FOLDER_PATH
  export XBB_TESTS_FOLDER_PATH

  # ---------------------------------------------------------------------------

  XBB_HOST_DOT_EXE=""
  XBB_TARGET_DOT_EXE=""

  if [ "${XBB_HOST_PLATFORM}" == "win32" ]
  then
    # Disable tests when cross compiling for Windows.
    XBB_WITH_TESTS="n"

    XBB_HOST_DOT_EXE=".exe"
    XBB_HOST_SHLIB_EXT="dll"
  elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
  then
    XBB_HOST_SHLIB_EXT="so"
  elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
  then
    XBB_HOST_SHLIB_EXT="dylib"
  else
    echo "Unsupported XBB_HOST_PLATFORM=${XBB_HOST_PLATFORM} in ${FUNCNAME[0]}()"
    exit 1
  fi

  if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
  then
    XBB_TARGET_DOT_EXE=".exe"
    XBB_TARGET_SHLIB_EXT="dll"
  elif [ "${XBB_TARGET_PLATFORM}" == "linux" ]
  then
    XBB_TARGET_SHLIB_EXT="so"
  elif [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
  then
    XBB_TARGET_SHLIB_EXT="dylib"
  else
    echo "Unsupported XBB_TARGET_PLATFORM=${XBB_TARGET_PLATFORM} in ${FUNCNAME[0]}()"
    exit 1
  fi

  export XBB_HOST_DOT_EXE
  export XBB_HOST_SHLIB_EXT

  export XBB_TARGET_DOT_EXE
  export XBB_TARGET_SHLIB_EXT

  # ---------------------------------------------------------------------------

  xbb_set_compiler_env

  xbb_set_extra_build_env
  xbb_set_extra_host_env
  xbb_set_extra_target_env

  # ---------------------------------------------------------------------------

  tests_add "xbb_set_target" "${kind}"

  # ---------------------------------------------------------------------------

  echo
  echo "# The XBB environment..."
  xbb_show_env
}

function xbb_config_guess()
{
  echo "$(bash ${helper_folder_path}/config/config.guess)"
}

function xbb_get_current_version()
{
  local version_file_path="${scripts_folder_path}/VERSION"
  if [ $# -ge 1 ]
  then
    version_file_path="$1"
  fi

  # Extract only the first line
  cat "${version_file_path}" | sed -e '2,$d'
}

function xbb_set_compiler_env()
{
  if [ "${XBB_BUILD_PLATFORM}" == "linux" ]
  then
    if [ "${XBB_HOST_PLATFORM}" == "win32" -a "${XBB_TARGET_TRIPLET}" == "${XBB_HOST_TRIPLET}" ]
    then
      # Windows cross build case.
      export XBB_NATIVE_CC="$(which gcc 2>/dev/null || echo gcc)"
      export XBB_NATIVE_CXX="$(which g++ 2>/dev/null || echo g++)"

      export XBB_NATIVE_LD="$(which ld 2>/dev/null || echo ld)"

      export XBB_NATIVE_AR="$(which gcc-ar 2>/dev/null || which ar 2>/dev/null || echo ar)"
      export XBB_NATIVE_NM="$(which gcc-nm 2>/dev/null || which nm 2>/dev/null || echo nm)"
      export XBB_NATIVE_RANLIB="$(which gcc-ranlib 2>/dev/null || which ranlib 2>/dev/null || echo ranlib)"

      xbb_prepare_gcc_env "${XBB_TARGET_TRIPLET}-"
    else
      if [ "${XBB_APPLICATION_USE_CLANG_ON_LINUX:-}" == "y" ]
      then
        xbb_prepare_clang_env
      else
        xbb_prepare_gcc_env
      fi
    fi
  elif [ "${XBB_BUILD_PLATFORM}" == "darwin" ]
  then
    xbb_prepare_clang_env
  elif [ "${XBB_BUILD_PLATFORM}" == "win32" ]
  then
    # Basically for running tests on Windows.
    xbb_prepare_gcc_env
  else
    echo "Unsupported XBB_HOST_PLATFORM=${XBB_HOST_PLATFORM}, XBB_BUILD_PLATFORM=${XBB_BUILD_PLATFORM} in ${FUNCNAME[0]}()"
    exit 1
  fi
}

function xbb_set_extra_build_env()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]}]"

  XBB_BUILD_STRIP="$(which strip 2>/dev/null || echo strip)"
  XBB_BUILD_RANLIB="$(which ranlib 2>/dev/null || echo ranlib)"
  XBB_BUILD_OBJDUMP="$(which objdump 2>/dev/null || echo objdump)"

  export XBB_BUILD_STRIP
  export XBB_BUILD_RANLIB
  export XBB_BUILD_OBJDUMP

  if [ "${XBB_IS_DEVELOP}" == "y" ]
  then
    echo "XBB_BUILD_STRIP=${XBB_BUILD_STRIP}"
    echo "XBB_BUILD_RANLIB=${XBB_BUILD_RANLIB}"
    echo "XBB_BUILD_OBJDUMP=${XBB_BUILD_OBJDUMP}"
  fi
}

function xbb_set_extra_target_env()
{
  local triplet="${1:-"${XBB_TARGET_TRIPLET}"}"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  if [ "${triplet}" != "${XBB_BUILD_TRIPLET}" ]
  then
    if [ ! -z "$(which ${triplet}-strip 2>/dev/null)" ]
    then
      XBB_TARGET_STRIP="$(which ${triplet}-strip)"
    else
      XBB_TARGET_STRIP="${triplet}-strip"
    fi
    if [ ! -z "$(which ${triplet}-ranlib 2>/dev/null)" ]
    then
      XBB_TARGET_RANLIB="$(which ${triplet}-ranlib)"
    else
      XBB_TARGET_RANLIB="${triplet}-ranlib"
    fi
    if [ ! -z "$(which ${triplet}-objdump 2>/dev/null)" ]
    then
      XBB_TARGET_OBJDUMP="$(which ${triplet}-objdump)"
    else
      XBB_TARGET_OBJDUMP="${triplet}-objdump"
    fi

    XBB_CURRENT_TRIPLET="${triplet}"
  else
    XBB_TARGET_STRIP="$(which strip 2>/dev/null || echo strip)"
    XBB_TARGET_RANLIB="$(which ranlib 2>/dev/null || echo ranlib)"
    XBB_TARGET_OBJDUMP="$(which objdump 2>/dev/null || echo objdump)"

    XBB_CURRENT_TRIPLET=""
  fi

  export XBB_TARGET_STRIP
  export XBB_TARGET_RANLIB
  export XBB_TARGET_OBJDUMP

  export XBB_CURRENT_TRIPLET

  if [ "${XBB_IS_DEVELOP}" == "y" ]
  then
    echo "XBB_TARGET_STRIP=${XBB_TARGET_STRIP}"
    echo "XBB_TARGET_RANLIB=${XBB_TARGET_RANLIB}"
    echo "XBB_TARGET_OBJDUMP=${XBB_TARGET_OBJDUMP}"

    echo "XBB_CURRENT_TRIPLET=${XBB_CURRENT_TRIPLET}"
  fi
}

function xbb_set_extra_host_env()
{
  local triplet="${1:-"${XBB_HOST_TRIPLET}"}"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  if [ "${triplet}" != "${XBB_BUILD_TRIPLET}" ]
  then
    XBB_HOST_STRIP="$(which ${triplet}-strip 2>/dev/null || echo ${triplet}-strip)"
    XBB_HOST_RANLIB="$(which ${triplet}-ranlib 2>/dev/null || echo ${triplet}-ranlib)"
    XBB_HOST_OBJDUMP="$(which ${triplet}-objdump 2>/dev/null || echo ${triplet}-objdump)"
  else
    XBB_HOST_STRIP="$(which strip 2>/dev/null || echo strip)"
    XBB_HOST_RANLIB="$(which ranlib 2>/dev/null || echo ranlib)"
    XBB_HOST_OBJDUMP="$(which objdump 2>/dev/null || echo objdump)"
  fi

  export XBB_HOST_STRIP
  export XBB_HOST_RANLIB
  export XBB_HOST_OBJDUMP

  if [ "${XBB_IS_DEVELOP}" == "y" ]
  then
    echo "XBB_HOST_STRIP=${XBB_HOST_STRIP}"
    echo "XBB_HOST_RANLIB=${XBB_HOST_RANLIB}"
    echo "XBB_HOST_OBJDUMP=${XBB_HOST_OBJDUMP}"
  fi
}

function xbb_unset_compiler_env()
{
  unset CC
  unset CXX
  unset ADDR2LINE
  unset AR
  unset AS
  unset DLLTOOL
  unset LD
  unset NM
  unset OBJCOPY
  unset OBJDUMP
  unset RANLIB
  unset READELF
  unset SIZE
  unset STRIP
  unset WINDRES
  unset WINDMC
  unset RC

  unset XBB_CPPFLAGS

  unset XBB_CFLAGS
  unset XBB_CXXFLAGS

  unset XBB_CFLAGS_NO_W
  unset XBB_CXXFLAGS_NO_W

  unset XBB_LDFLAGS
  unset XBB_LDFLAGS_LIB
  unset XBB_LDFLAGS_APP
  unset XBB_LDFLAGS_APP_STATIC_GCC
}

# To get the gcc-* variants, pass --lto as the first argument.
function xbb_prepare_gcc_env()
{
  local with_lto="n"
  if [ $# -ge 1 ]
  then
    if [ "${1}" == "--lto" ]
    then
      with_lto="y"
      shift
    fi
  fi

  local prefix="${1:-}"
  local suffix="${2:-}"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  xbb_unset_compiler_env

  # Absolute paths are used to avoid picking the wrong binaries in case
  # the PATH changes.
  export CC="$(which ${prefix}gcc${suffix} 2>/dev/null || echo ${prefix}gcc${suffix})"
  export CXX="$(which ${prefix}g++${suffix} 2>/dev/null || echo ${prefix}g++${suffix})"

  # These are the special GCC versions, not the binutils ones.
  if [ "${with_lto}" == "y" ]
  then
    export AR="$(which ${prefix}gcc-ar${suffix} 2>/dev/null || which ${prefix}ar${suffix} 2>/dev/null || echo ${prefix}ar${suffix})"
    export NM="$(which ${prefix}gcc-nm${suffix} 2>/dev/null || which ${prefix}nm${suffix} 2>/dev/null || echo ${prefix}nm${suffix})"
    export RANLIB="$(which ${prefix}gcc-ranlib${suffix} 2>/dev/null || which ${prefix}ranlib${suffix} 2>/dev/null || echo ${prefix}ranlib${suffix})"
  else
    export AR="$(which ${prefix}ar${suffix} 2>/dev/null || echo ${prefix}ar${suffix})"
    export NM="$(which ${prefix}nm${suffix} 2>/dev/null || echo ${prefix}nm${suffix})"
    export RANLIB="$(which ${prefix}ranlib${suffix} 2>/dev/null || echo ${prefix}ranlib${suffix})"
  fi

  # From binutils.
  export ADDR2LINE="$(which ${prefix}addr2line 2>/dev/null || echo ${prefix}addr2line)"
  export AS="$(which ${prefix}as 2>/dev/null || echo ${prefix}as)"

  local dlltool="$(which ${prefix}dlltool 2>/dev/null)"
  if [ ! -z "${dlltool}" ]
  then
    export DLLTOOL="${dlltool}"
  fi

  export LD="$(which ${prefix}ld 2>/dev/null || echo ${prefix}ld)"

  local objcopy="$(which ${prefix}objcopy 2>/dev/null)"
  if [ ! -z "${objcopy}" ]
  then
    export OBJCOPY="${objcopy}"
  fi

  local objdump="$(which ${prefix}objdump 2>/dev/null)"
  if [ ! -z "${objdump}" ]
  then
    export OBJDUMP="${objdump}"
  fi

  local readelf="$(which ${prefix}readelf 2>/dev/null)"
  if [ ! -z "${readelf}" ]
  then
    export READELF="${readelf}"
  fi

  export SIZE="$(which ${prefix}size 2>/dev/null || echo ${prefix}size)"
  export STRIP="$(which ${prefix}strip 2>/dev/null || echo ${prefix}strip)"

  local windmc="$(which ${prefix}windmc 2>/dev/null)"
  if [ ! -z "${windmc}" ]
  then
    export WINDMC="${windmc}"
  fi

  local windres="$(which ${prefix}windres 2>/dev/null)"
  if [ ! -z "${windres}" ]
  then
    export WINDRES="${windres}"
    export RC="${windres}"
  fi

  export LEX="$(which flex 2>/dev/null || echo flex)"

  xbb_set_compiler_flags
}

function xbb_prepare_clang_env()
{
  local prefix="${1:-}"
  local suffix="${2:-}"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  xbb_unset_compiler_env

  export CC="$(which ${prefix}clang${suffix} 2>/dev/null || echo ${prefix}clang${suffix})"
  export CXX="$(which ${prefix}clang++${suffix} 2>/dev/null || echo ${prefix}clang++${suffix})"

  export ADDR2LINE="$(which ${prefix}llvm-addr2line 2>/dev/null || which ${prefix}addr2line 2>/dev/null || echo ${prefix}addr2line)"
  export AR="$(which ${prefix}llvm-ar 2>/dev/null || which ${prefix}ar 2>/dev/null || echo ${prefix}ar)"

  local dlltool="$(which ${prefix}llvm-dlltool 2>/dev/null || which ${prefix}dlltool 2>/dev/null)"
  if [ ! -z "${dlltool}" ]
  then
    export DLLTOOL="${dlltool}"
  fi

  if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
  then
    # Stick to system tools on macOS.
    # with llvm-as -> configure: error: cannot compute suffix of object files: cannot compile
    export AS="$(which ${prefix}as 2>/dev/null || echo ${prefix}as)"
    export LD="$(which ${prefix}ld 2>/dev/null || echo ${prefix}ld)"
  else
    export AS="$(which ${prefix}llvm-as 2>/dev/null || which ${prefix}as 2>/dev/null || echo ${prefix}as)"
    export LD="$(which ${prefix}ld.lld 2>/dev/null || which ${prefix}ld 2>/dev/null || echo ${prefix}ld)"
  fi

  export NM="$(which ${prefix}llvm-nm 2>/dev/null || which ${prefix}nm 2>/dev/null || echo ${prefix}nm)"

  local objcopy="$(which ${prefix}llvm-objcopy 2>/dev/null || which ${prefix}objcopy 2>/dev/null)"
  if [ ! -z "${objcopy}" ]
  then
    export OBJCOPY="${objcopy}"
  fi

  local objdump="$(which ${prefix}llvm-objdump 2>/dev/null || which ${prefix}objdump 2>/dev/null)"
  if [ ! -z "${objdump}" ]
  then
  export OBJDUMP="${objdump}"
  fi

  export RANLIB="$(which ${prefix}llvm-ranlib 2>/dev/null || which ${prefix}ranlib 2>/dev/null || echo ${prefix}ranlib)"

  local readelf="$(which ${prefix}llvm-readelf 2>/dev/null || which ${prefix}readelf 2>/dev/null)"
  if [ ! -z "${readelf}" ]
  then
    export READELF="${readelf}"
  fi

  export SIZE="$(which ${prefix}llvm-size 2>/dev/null || which ${prefix}size 2>/dev/null || echo ${prefix}size)"

  if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
  then
    # Stick to system tool on macOS.
    # libtool: install: /Users/ilg/Work/xpack-dev-tools/clang-xpack.git/build/darwin-arm64/xpacks/.bin/llvm-strip --strip-unneeded /Users/ilg/Work/xpack-dev-tools/clang-xpack.git/build/darwin-arm64/aarch64-apple-darwin20.6.0/install/lib/libltdl.7.dylib
    # /Users/ilg/Work/xpack-dev-tools/clang-xpack.git/build/darwin-arm64/xpacks/.bin/llvm-strip: error: option not supported by llvm-objcopy for MachO
    export STRIP="$(which ${prefix}strip 2>/dev/null || echo ${prefix}strip)"
  else
    export STRIP="$(which ${prefix}llvm-strip 2>/dev/null || which ${prefix}strip 2>/dev/null || echo ${prefix}strip)"
  fi

  local windmc=$(which ${prefix}windmc 2>/dev/null)
  if [ ! -z "${windmc}" ]
  then
    export WINDMC="${windmc}"
  fi

  local windres="$(which ${prefix}llvm-windres 2>/dev/null || which ${prefix}windres 2>/dev/null)"
  if [ ! -z "${windres}" ]
  then
    export WINDRES="${windres}"
    export RC="${windres}"
  fi

  export LEX="$(which flex 2>/dev/null || echo flex)"

  xbb_set_compiler_flags
}

function xbb_prepare_apple_clang_env()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  xbb_unset_compiler_env

  export CC="/usr/bin/clang"
  export CXX="/usr/bin/clang++"

  export ADDR2LINE="$(which llvm-addr2line 2>/dev/null || which addr2line 2>/dev/null || echo addr2line)"
  export AR="/usr/bin/ar"

  local dlltool="$(which llvm-dlltool 2>/dev/null || which dlltool 2>/dev/null)"
  if [ ! -z "${dlltool}" ]
  then
    export DLLTOOL="${dlltool}"
  fi

  export AS="/usr/bin/as"
  export LD="/usr/bin/ld"

  export NM="/usr/bin/nm"

  local objcopy="$(which llvm-objcopy 2>/dev/null || which objcopy 2>/dev/null)"
  if [ ! -z "${objcopy}" ]
  then
    export OBJCOPY="${objcopy}"
  fi

  local objdump="/usr/bin/objdump"
  if [ ! -z "${objdump}" ]
  then
  export OBJDUMP="${objdump}"
  fi

  export RANLIB="/usr/bin/ranlib"

  local readelf="$(which llvm-readelf 2>/dev/null || which readelf 2>/dev/null)"
  if [ ! -z "${readelf}" ]
  then
    export READELF="${readelf}"
  fi

  export SIZE="/usr/bin/size"

  export STRIP="/usr/bin/strip"

  local windmc=$(which windmc 2>/dev/null)
  if [ ! -z "${windmc}" ]
  then
    export WINDMC="${windmc}"
  fi

  local windres="$(which llvm-windres 2>/dev/null || which windres 2>/dev/null)"
  if [ ! -z "${windres}" ]
  then
    export WINDRES="${windres}"
    export RC="${windres}"
  fi

  export LEX="$(which flex 2>/dev/null || echo flex)"

  xbb_set_compiler_flags
}

function xbb_set_compiler_flags()
{
  XBB_CPPFLAGS=""

  XBB_CFLAGS="-ffunction-sections -fdata-sections -pipe"
  XBB_CXXFLAGS="-ffunction-sections -fdata-sections -pipe"

  # No longer set -m64/-m32, since it may interfere with multilib builds,
  # like wine.

  XBB_LDFLAGS=""

  if [ "${XBB_IS_DEBUG}" == "y" ]
  then
    XBB_CFLAGS+=" -g -O0"
    XBB_CXXFLAGS+=" -g -O0"
    XBB_LDFLAGS+=" -g -O0"
  else
    XBB_CFLAGS+=" -O2"
    XBB_CXXFLAGS+=" -O2"
    XBB_LDFLAGS+=" -O2"
  fi

  if [ "${XBB_IS_DEVELOP}" == "y" ]
  then
    XBB_LDFLAGS+=" -v"
  fi

  if [ "${XBB_HOST_PLATFORM}" == "linux" ]
  then
    if [[ $(basename "${CC}") =~ .*clang.* ]]
    then
      # Starting with clang 16, the new libraries seem ready for prime time.
      if [ "${XBB_APPLICATION_USE_CLANG_LIBCXX:-}" == "y" ]
      then
        XBB_CXXFLAGS+=" -stdlib=libc++"
        XBB_LDFLAGS+=" -stdlib=libc++ -rtlib=compiler-rt -lunwind"
      fi
      if [ "${XBB_APPLICATION_USE_CLANG_LLD:-}" == "y" ]
      then
        XBB_LDFLAGS+=" -fuse-ld=lld"
      fi
    elif [[ $(basename "${CC}") =~ .*gcc.* ]]
    then
      # Many configure steps fail with:
      # warning: libpthread.so.0, needed by /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/install/lib/libzstd.so, not found (try using -rpath or -rpath-link)
      # resulting in incomplete configurations like `gdb_cv_var_elf`

      # linux-tdep.c:(.text._ZL25linux_make_corefile_notesP7gdbarchP3bfdPi+0x4a9): undefined reference to `gcore_elf_make_tdesc_note(bfd*, std::unique_ptr<char, gdb::xfree_deleter<char> >*, int*)'
      # https://sourceware.org/bugzilla/show_bug.cgi?id=30295
      XBB_LDFLAGS+=" -lpthread"
    fi

    if [ "${XBB_HOST_ARCH}" == "arm" ]
    then
      # /opt/armv7-gcc-2017/arm-linux-gnueabihf/include/c++/7.2.0/bits/vector.tcc:394:7: note: parameter passing for argument of type '...' changed in GCC 7.1
      XBB_CXXFLAGS+=" -Wno-psabi"
    fi
    # Do not add -static here, it fails.
    # Do not try to link pthread statically, it must match the system glibc.
    XBB_LDFLAGS_LIB="${XBB_LDFLAGS}"
    XBB_LDFLAGS_APP="${XBB_LDFLAGS} -Wl,--gc-sections"
    XBB_LDFLAGS_APP_STATIC_GCC="${XBB_LDFLAGS_APP} -static-libgcc -static-libstdc++"

    xbb_update_ld_library_path

  elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
  then
    if [ "${XBB_HOST_ARCH}" == "x64" ]
    then
      export MACOSX_DEPLOYMENT_TARGET="${XBB_APPLICATION_MACOSX_DEPLOYMENT_TARGET_X64:-"10.13"}"
    elif [ "${XBB_HOST_ARCH}" == "arm64" ]
    then
      export MACOSX_DEPLOYMENT_TARGET="${XBB_APPLICATION_MACOSX_DEPLOYMENT_TARGET_ARM64:-"11.0"}"
    else
      echo "Unsupported XBB_HOST_ARCH=${XBB_HOST_ARCH} in ${FUNCNAME[0]}()"
      exit 1
    fi

    if [[ $(basename "${CC}") =~ .*clang.* ]]
    then
      XBB_CFLAGS+=" -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
      XBB_CXXFLAGS+=" -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
    fi

    # Note: macOS linker ignores -static-libstdc++, so
    # libstdc++.6.dylib should be handled.
    XBB_LDFLAGS+=" -Wl,-macosx_version_min,${MACOSX_DEPLOYMENT_TARGET}"

    # With GCC 11.2 path are longer, and post-processing may fail:
    # error: /Library/Developer/CommandLineTools/usr/bin/install_name_tool: changing install names or rpaths can't be redone for: /Users/ilg/Work/gcc-11.2.0-2/darwin-x64/install/gcc/libexec/gcc/x86_64-apple-darwin17.7.0/11.2.0/g++-mapper-server (for architecture x86_64) because larger updated load commands do not fit (the program must be relinked, and you may need to use -headerpad or -headerpad_max_install_names)
    XBB_LDFLAGS+=" -Wl,-headerpad_max_install_names"

    XBB_LDFLAGS_LIB="${XBB_LDFLAGS}"
    XBB_LDFLAGS_APP="${XBB_LDFLAGS} -Wl,-dead_strip"
    XBB_LDFLAGS_APP_STATIC_GCC="${XBB_LDFLAGS_APP} -static-libstdc++"
    if [[ $(basename "${CC}") =~ .*gcc.* ]]
    then
      XBB_LDFLAGS_APP_STATIC_GCC+=" -static-libgcc"
    fi

    xbb_update_ld_library_path

  elif [ "${XBB_HOST_PLATFORM}" == "win32" ]
  then

    # Note: use this explcitly in the application.
    # prepare_gcc_env "${XBB_TARGET_TRIPLET}-"

    # To make `access()` not fail when passing a non-zero mode.
    # https://sourceforge.net/p/mingw-w64/mailman/message/37372220/
    # Do not add it to XBB_CPPFLAGS, since the current macro
    # crashes C++ code, like in `llvm/lib/Support/LockFileManager.cpp`:
    # `if (sys::fs::access(LockFileName.c_str(), sys::fs::AccessMode::Exist) ==`
    XBB_CFLAGS+=" -D__USE_MINGW_ACCESS"

    # To prevent "too many sections", "File too big" etc try to add `-mbig-obj`
    # to the compiler flags.
    # export CFLAGS+=" -Wa,-mbig-obj"
    # export CXXFLAGS+=" -Wa,-mbig-obj"
    # If this fails (like for GCC), remove the `-ffunction-sections` `-fdata-sections`
    # CXXFLAGS=$(echo ${CXXFLAGS} | sed -e 's|-ffunction-sections -fdata-sections||')

    # CRT_glob is from Arm script
    # -static avoids libwinpthread-1.dll
    # -static-libgcc avoids libgcc_s_sjlj-1.dll
    XBB_LDFLAGS_LIB="${XBB_LDFLAGS}"
    XBB_LDFLAGS_APP="${XBB_LDFLAGS} -Wl,--gc-sections"
    XBB_LDFLAGS_APP_STATIC_GCC="${XBB_LDFLAGS_APP} -static-libgcc -static-libstdc++"
  else
    echo "Unsupported XBB_HOST_PLATFORM=${XBB_HOST_PLATFORM} in ${FUNCNAME[0]}()"
    exit 1
  fi

  XBB_CFLAGS_NO_W="${XBB_CFLAGS} -w"
  XBB_CXXFLAGS_NO_W="${XBB_CXXFLAGS} -w"

  if [ "${XBB_IS_DEVELOP}" == "y" ]
  then
    (
      set +u
      echo "CC=${CC}"
      echo "CXX=${CXX}"
      echo
      echo "ADDR2LINE=${ADDR2LINE}"
      echo "AR=${AR}"
      echo "AS=${AS}"
      echo "DLLTOOL=${DLLTOOL}"
      echo "LD=${LD}"
      echo "LEX=${LEX}"
      echo "NM=${NM}"
      echo "OBJCOPY=${OBJCOPY}"
      echo "OBJDUMP=${OBJDUMP}"
      echo "RANLIB=${RANLIB}"
      echo "READELF=${READELF}"
      echo "SIZE=${SIZE}"
      echo "STRIP=${STRIP}"
      echo "WINDRES=${WINDRES}"
      echo "WINDMC=${WINDMC}"
      echo "RC=${RC}"
      echo
      echo "XBB_CPPFLAGS=${XBB_CPPFLAGS}"
      echo "XBB_CFLAGS=${XBB_CFLAGS}"
      echo "XBB_CXXFLAGS=${XBB_CXXFLAGS}"

      echo "XBB_LDFLAGS_LIB=${XBB_LDFLAGS_LIB}"
      echo "XBB_LDFLAGS_APP=${XBB_LDFLAGS_APP}"
      echo "XBB_LDFLAGS_APP_STATIC_GCC=${XBB_LDFLAGS_APP_STATIC_GCC}"
    )
  fi

  # ---------------------------------------------------------------------------

  # CC & co were exported by prepare_gcc_env.
  export XBB_CPPFLAGS

  export XBB_CFLAGS
  export XBB_CXXFLAGS

  export XBB_CFLAGS_NO_W
  export XBB_CXXFLAGS_NO_W

  export XBB_LDFLAGS
  export XBB_LDFLAGS_LIB
  export XBB_LDFLAGS_APP
  export XBB_LDFLAGS_APP_STATIC_GCC
}

function xbb_set_executables_install_path()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  export XBB_EXECUTABLES_INSTALL_FOLDER_PATH="$1"

  echo_develop "XBB_EXECUTABLES_INSTALL_FOLDER_PATH=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}"
}

function xbb_set_libraries_install_path()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  export XBB_LIBRARIES_INSTALL_FOLDER_PATH="$1"

  echo_develop "XBB_LIBRARIES_INSTALL_FOLDER_PATH=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}"
}

# Must be called after xxbb_set_target() and
# xbb_set_compiler_flags(), xbb_prepare_*_env(), xbb_set_compiler_env().
function xbb_set_flex_package_paths()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  # Adjust environent to refer to the flex xPack dependency.
  local flex_realpath="$(${REALPATH} "$(which flex)")"
  XBB_FLEX_PACKAGE_PATH="$(dirname $(dirname "${flex_realpath}"))"

  export XBB_CPPFLAGS+=" -I${XBB_FLEX_PACKAGE_PATH}/include"
  export XBB_LDFLAGS+=" -L${XBB_FLEX_PACKAGE_PATH}/lib"
  export XBB_LDFLAGS_LIB+=" -L${XBB_FLEX_PACKAGE_PATH}/lib"
  export XBB_LDFLAGS_APP+=" -L${XBB_FLEX_PACKAGE_PATH}/lib"
  export XBB_LDFLAGS_APP_STATIC_GCC+=" -L${XBB_FLEX_PACKAGE_PATH}/lib"
  echo_develop "XBB_FLEX_PACKAGE_PATH=${XBB_FLEX_PACKAGE_PATH}"
}

# Add the freshly built binaries.
function xbb_activate_installed_bin()
{
  local folder_path="${1:-}"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  if [ "${XBB_HOST_PLATFORM}" == "win32" ]
  then
    # Add the native XBB bin to the PATH.
    if is_variable_set "XBB_NATIVE_DEPENDENCIES_INSTALL_FOLDER_PATH" &&
       [ -d "${XBB_NATIVE_DEPENDENCIES_INSTALL_FOLDER_PATH}/bin" ]
    then
      PATH="${XBB_NATIVE_DEPENDENCIES_INSTALL_FOLDER_PATH}/bin:$PATH"
    fi
  else
    # Add the dependencies bin to the PATH.
    if is_variable_set "XBB_DEPENDENCIES_INSTALL_FOLDER_PATH"
    then
      PATH="${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/bin:${PATH}"
    fi
    # Add the executables bin to the PATH, if different.
    if is_variable_set "XBB_EXECUTABLES_INSTALL_FOLDER_PATH" &&
       [ -d "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin" ] &&
       [ "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}" != "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}" ]
    then
      PATH="${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin:${PATH}"
    fi
  fi

  if [ ! -z "${folder_path}" ]
  then
    PATH="${folder_path}:${PATH}"
  fi

  if is_variable_set "XBB_TEST_BIN_PATH"
  then
    PATH="${XBB_TEST_BIN_PATH}:${PATH}"
  fi

  export PATH
  echo_develop "PATH=${PATH}"

  hash -r

  # Update PKG_CONFIG, in case it was compiled locally
  # and now it shows up in the new PATH.
  if [ ! -z "$(which pkg-config-verbose)" -a "${XBB_IS_DEVELOP}" == "y" ]
  then
    export PKG_CONFIG="$(which pkg-config-verbose)"
    echo_develop "PKG_CONFIG=${PKG_CONFIG}"
  elif [ ! -z "$(which pkg-config)" ]
  then
    export PKG_CONFIG="$(which pkg-config)"
    echo_develop "PKG_CONFIG=${PKG_CONFIG}"
  fi

  xbb_set_actual_commands
}

# Add the application binaries to the PATH.
function xbb_activate_application_bin()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]}]"

  if is_variable_set "XBB_APPLICATION_INSTALL_FOLDER_PATH"
  then
    PATH="${XBB_APPLICATION_INSTALL_FOLDER_PATH}/bin:${XBB_APPLICATION_INSTALL_FOLDER_PATH}/usr/bin:${PATH}"
  fi

  export PATH
  echo_develop "PATH=${PATH}"

  xbb_set_actual_commands

  hash -r
}

# Add the freshly built dependencies (headers and libraries) to the
# XBB environment variables.
function xbb_activate_dependencies_dev()
{
  local priority_path="${1:-""}"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  # XBB_LIBRARY_PATH must be already set before (xbb_set_compiler_flags),
  # and the deps path comes in front of it,
  # otherwise compiler libraries may take precedence.

  # Add XBB include in front of XBB_CPPFLAGS.
  XBB_CPPFLAGS="-I${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/include ${XBB_CPPFLAGS}"

  if [ -d "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/lib" ]
  then
    # Add XBB lib in front of XBB_LDFLAGS.
    XBB_LDFLAGS="-L${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/lib ${XBB_LDFLAGS}"
    XBB_LDFLAGS_LIB="-L${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/lib ${XBB_LDFLAGS_LIB}"
    XBB_LDFLAGS_APP="-L${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/lib ${XBB_LDFLAGS_APP}"
    XBB_LDFLAGS_APP_STATIC_GCC="-L${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/lib ${XBB_LDFLAGS_APP_STATIC_GCC}"

    # Add XBB lib in front of PKG_CONFIG_PATH.
    PKG_CONFIG_PATH="${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/lib/pkgconfig:${PKG_CONFIG_PATH}"

    if [ "${XBB_HOST_PLATFORM}" != "win32" ]
    then
      # Needed by internal binaries, like the bootstrap compiler, which do not
      # have a rpath.
      if [ -z "${XBB_LIBRARY_PATH}" ]
      then
        XBB_LIBRARY_PATH="${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/lib"
      else
        # Insert our dependencies before any other.
        XBB_LIBRARY_PATH="${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/lib:${XBB_LIBRARY_PATH}"
      fi
    fi
  fi

  # Used by libffi, for example.
  if [ -d "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/lib64" ]
  then
    # For 64-bit systems, add XBB lib64 in front of paths.
    XBB_LDFLAGS="-L${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/lib64 ${XBB_LDFLAGS_LIB}"
    XBB_LDFLAGS_LIB="-L${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/lib64 ${XBB_LDFLAGS_LIB}"
    XBB_LDFLAGS_APP="-L${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/lib64 ${XBB_LDFLAGS_APP}"
    XBB_LDFLAGS_APP_STATIC_GCC="-L${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/lib64 ${XBB_LDFLAGS_APP_STATIC_GCC}"

    PKG_CONFIG_PATH="${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/lib64/pkgconfig:${PKG_CONFIG_PATH}"

    if [ "${XBB_HOST_PLATFORM}" != "win32" ]
    then
      if [ -z "${XBB_LIBRARY_PATH}" ]
      then
        XBB_LIBRARY_PATH="${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/lib64"
      else
        # Insert our dependencies before any other.
        XBB_LIBRARY_PATH="${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/lib64:${XBB_LIBRARY_PATH}"
      fi
    fi
  fi

  if [ -n "${priority_path}" ] &&
     [ "${priority_path}" != "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/lib" ]
  then
    mkdir -pv "${priority_path}"

    # Add given path in front of XBB_LDFLAGS.
    XBB_LDFLAGS="-L${priority_path}/lib ${XBB_LDFLAGS}"
    XBB_LDFLAGS_LIB="-L${priority_path}/lib ${XBB_LDFLAGS_LIB}"
    XBB_LDFLAGS_APP="-L${priority_path}/lib ${XBB_LDFLAGS_APP}"
    XBB_LDFLAGS_APP_STATIC_GCC="-L${priority_path}/lib ${XBB_LDFLAGS_APP_STATIC_GCC}"

    # Add XBB lib in front of PKG_CONFIG_PATH.
    PKG_CONFIG_PATH="${priority_path}/lib/pkgconfig:${PKG_CONFIG_PATH}"

    if [ "${XBB_HOST_PLATFORM}" != "win32" ]
    then
      # Needed by internal binaries, like the bootstrap compiler, which do not
      # have a rpath.
      if [ -z "${XBB_LIBRARY_PATH}" ]
      then
        XBB_LIBRARY_PATH="${priority_path}/lib"
      else
        # Insert our dependencies before any other.
        XBB_LIBRARY_PATH="${priority_path}/lib:${XBB_LIBRARY_PATH}"
      fi
    fi
  fi

  if [ "${XBB_HOST_PLATFORM}" != "win32" ]
  then
    # The order is important, it must be:
    # dev-path:gcc-path:system-path
    echo_develop "XBB_LIBRARY_PATH=${XBB_LIBRARY_PATH}"

    # Do not export it on Windows.
    export XBB_LIBRARY_PATH
  fi

  export XBB_CPPFLAGS

  export XBB_LDFLAGS
  export XBB_LDFLAGS_LIB
  export XBB_LDFLAGS_APP
  export XBB_LDFLAGS_APP_STATIC_GCC

  export PKG_CONFIG_PATH
}

# Call it with -m64/-m32 for multilib use cases.
function xbb_get_libs_path()
{
  ${CXX} "$@" -print-search-dirs | grep 'libraries: =' | sed -e 's|libraries: =||'
}

function xbb_update_ld_library_path()
{
  local libs_path=""
  if [ "${XBB_HOST_PLATFORM}" == "linux" ] ||
     [ "${XBB_HOST_PLATFORM}" == "darwin" ]
  then

    if [[ "$(basename ${CC})" =~ .*gcc.* ]]
    then
      # This is maximal, it adds lots of folders.
      libs_path="$(xbb_get_libs_path)"
    elif [[ "$(basename ${CC})" =~ .*clang.* ]]
    then
      # find . -name '*.so'
      # lib/x86_64-pc-linux-gnu/libc++abi.so.1
      # lib/x86_64-pc-linux-gnu/libc++abi.so.1.0
      # lib/x86_64-pc-linux-gnu/libunwind.so.1
      # lib/x86_64-pc-linux-gnu/libc++.so
      # lib/x86_64-pc-linux-gnu/libunwind.so.1.0
      # lib/x86_64-pc-linux-gnu/libc++abi.so
      # lib/x86_64-pc-linux-gnu/libunwind.so
      # lib/x86_64-pc-linux-gnu/libc++.so.1
      # lib/x86_64-pc-linux-gnu/libc++.so.1.0
      # lib/clang/15.0.6/lib/x86_64-pc-linux-gnu/libclang_rt.memprof.so

      # clang -print-file-name=libc++.so
      # /home/ilg/Work/xpack-dev-tools/clang-xpack.git/build/linux-x64/application/bin/../lib/x86_64-pc-linux-gnu/libc++.so
      # libs_path="$(dirname $(${CC} -print-file-name=libc++.so))"

      # clang -print-runtime-dir
      # /home/ilg/Work/xpack-dev-tools/clang-xpack.git/build/linux-x64/application/lib/clang/15.0.6/lib/x86_64-pc-linux-gnu

      # clang -print-search-dirs
      # programs: =/home/ilg/Work/xpack-dev-tools/clang-xpack.git/build/linux-x64/application/bin:/usr/lib/gcc/x86_64-linux-gnu/10/../../../../x86_64-linux-gnu/bin
      # libraries: =/home/ilg/Work/xpack-dev-tools/clang-xpack.git/build/linux-x64/application/lib/clang/15.0.6:/home/ilg/Work/xpack-dev-tools/clang-xpack.git/build/linux-x64/application/bin/../lib/x86_64-pc-linux-gnu:/usr/lib/gcc/x86_64-linux-gnu/10:/usr/lib/gcc/x86_64-linux-gnu/10/../../../../lib64:/lib/x86_64-linux-gnu:/lib/../lib64:/usr/lib/x86_64-linux-gnu:/usr/lib/../lib64:/lib:/usr/lib
      libs_path="$(xbb_get_libs_path)"
    else
      echo "TODO: compute rpath for ${CC}"
      exit 1
    fi

    if [ -z "${XBB_LIBRARY_PATH}" ]
    then
      XBB_LIBRARY_PATH="${libs_path}"
    else
      # This is debatable, since the libs path may include many system paths,
      # but normally the initial XBB_LIBRARY_PATH should be empty.
      XBB_LIBRARY_PATH="${libs_path}:${XBB_LIBRARY_PATH}"
    fi

    echo_develop "XBB_LIBRARY_PATH=${XBB_LIBRARY_PATH}"

    export XBB_LIBRARY_PATH

  fi
}

# Note: it adds only folder that are present!
# For futures, create empty folders before.
function xbb_adjust_ldflags_rpath()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]}]"

  local path="${XBB_LIBRARY_PATH:-${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib}"

  local priority_path="${1:-""}"
  if [ -n "${priority_path}" ]
  then
    mkdir -pv "${priority_path}"
    path="${priority_path}:${path}"

    export XBB_LIBRARY_PATH="${path}"
  fi

  IFS=: read -r -d '' -a path_array < <(printf '%s:\0' "${path}")

  if [ "${XBB_HOST_PLATFORM}" == "linux" ]
  then
    for p in "${path_array[@]}"
    do
      if [ -d "${p}" ]
      then
        LDFLAGS+=" -Wl,-rpath-link,$(${REALPATH} ${p})"
        LDFLAGS+=" -Wl,-rpath,$(${REALPATH} ${p})"
      fi
    done
    echo_develop "LDFLAGS=${LDFLAGS}"
  elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
  then
    for p in "${path_array[@]}"
    do
      if [ -d "${p}" ]
      then
        LDFLAGS+=" -Wl,-rpath,$(${REALPATH} ${p})"
      fi
    done
    echo_develop "LDFLAGS=${LDFLAGS}"
  fi
}

# STDOUT!
function xbb_expand_rpath()
{
  local path="$1"

  IFS=: read -r -d '' -a path_array < <(printf '%s:\0' "${path}")

  local output=""

  # Compare the platform where the build is performed.
  if [ "${XBB_BUILD_PLATFORM}" == "linux" ]
  then
    for p in "${path_array[@]}"
    do
      if [ -d "${p}" ]
      then
        output+=" -Wl,-rpath-link,$(${REALPATH} ${p})"
        output+=" -Wl,-rpath,$(${REALPATH} ${p})"
      fi
    done
  elif [ "${XBB_BUILD_PLATFORM}" == "darwin" ]
  then
    for p in "${path_array[@]}"
    do
      if [ -d "${p}" ]
      then
        output+=" -Wl,-rpath,$(${REALPATH} ${p})"
      fi
    done
  fi

  echo "${output}"
}

# STDOUT!
function xbb_get_current_package_version()
{
  local package_file_path="${1:-"${project_folder_path}/package.json"}"

  # Extract only the first line
  grep '"version":' "${package_file_path}" | sed -e 's|.*"version": "\(.*\)".*|\1|'
}

# STDOUT!
function xbb_get_current_helper_version()
{
  local package_file_path="${1:-"${project_folder_path}/package.json"}"

  # Extract the semver.
  grep '"@xpack-dev-tools/xbb-helper": "' "${package_file_path}" | sed -e 's|.*"\^\([0-9.]*\).*|\1|'
}

function xbb_show_tools_versions()
{
  echo

  (
    set +e

    if [ "${XBB_HOST_PLATFORM}" == "win32" ]
    then
      which ${XBB_NATIVE_CXX} && ${XBB_NATIVE_CXX} --version && echo || true
    fi

    which ${CXX} && ${CXX} --version && echo || true

    if [ "${XBB_IS_DEVELOP}" == "y" ]
    then
      which bash && bash --version && echo || true
      which curl && curl --version && echo || true
      which flex && flex --version && echo || true
      which git && git --version && echo || true
      which m4 && m4 --version && echo || true
      which make && make --version && echo || true
      which perl && perl --version && echo || true
      which python && python --version && echo || true
      which python3 && python3 --version && echo || true
      which tar && tar --version && echo || true
      which zip && zip --version && echo || true
      which yacc && yacc --version && echo || true
    fi
  )
}

function xbb_show_env()
{
  echo
  echo "pwd: $(pwd)"
  echo
  env | sort | egrep '^[^ \t]+='
}

function xbb_show_env_develop()
{
  if [ "${XBB_IS_DEVELOP}" == "y" ]
  then
    xbb_show_env
  fi
}

# -----------------------------------------------------------------------------

function xbb_parse_option()
{
  echo "$1" | sed -e 's|--[a-zA-Z0-9-]*=||'
}

function xbb_strip_version_pre_release()
{
  echo "$1" | sed -e 's|-.*||'
}

function xbb_get_version_major()
{
  echo "$1" | sed -e 's|\([0-9][0-9]*\).*|\1|'
}

function xbb_get_version_minor()
{
  echo "$1" | sed -e 's|\([0-9][0-9]*\)[.]\([0-9][0-9]*\).*|\2|'
}

function xbb_get_version_patch()
{
  echo "$1" | sed -e 's|\([0-9][0-9]*\)[.]\([0-9][0-9]*\)[.]\([0-9][0-9]*\).*|\3|'
}

function xbb_strip_macosx_version_min()
{
  echo "$1" | sed -e 's|-mmacosx-version-min=[0-9]*[.][0-9]*||'
}

# -----------------------------------------------------------------------------
