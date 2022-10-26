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
        echo "Make build folder writable by all..."

        run_verbose chmod -R a+w "${project_folder_path}/build"
      fi


      if [ -d "${project_folder_path}/xpacks" ]
      then
        echo
        echo "Make xpacks folder writable by all..."

        # Non-recursive! (Recursive fails with exit code 2)
        run_verbose chmod a+w "${project_folder_path}/xpacks"

        if [ -d "${project_folder_path}/xpacks/.bin" ]
        then
          run_verbose chmod a+w "${project_folder_path}/xpacks/.bin"
        fi
      fi
    )
  fi
}

function xbb_set_env()
{
  # Defaults, to ensure the variables are defined.
  PATH="${PATH:-""}"
  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-""}"
  LANG="${LANG:-"C"}"
  CI=${CI:-"false"}

  export PATH
  export LD_LIBRARY_PATH
  export LANG

  export CI

  # ---------------------------------------------------------------------------

  XBB_DASH_V=""
  if [ "${XBB_IS_DEVELOP}" == "y" ]
  then
    XBB_DASH_V="-v"
  fi

  XBB_RELEASE_VERSION="${XBB_RELEASE_VERSION:-$(xbb_get_current_version)}"

  XBB_TARGET_FOLDER_NAME="${XBB_REQUESTED_TARGET_PLATFORM}-${XBB_REQUESTED_TARGET_ARCH}"

  # Decide where to run the build for the requested target.
  if [ ! -z ${WORK_FOLDER_PATH+x} ]
  then
    # On the main development machine, the repos are stored in a folder
    # that is saved daily by Time Machine, and having the build folders
    # in the same place is a waste.
    # To avoid this, define a separate work folder (excluded from backup,
    # usually something like "${HOME}/Work")
    # and group all targets below a versioned application folder.
    XBB_TARGET_WORK_FOLDER_PATH="${WORK_FOLDER_PATH}/${XBB_APPLICATION_LOWER_CASE_NAME}-${XBB_RELEASE_VERSION}/${XBB_TARGET_FOLDER_NAME}"
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

  XBB_TARGET_NATIVE_FOLDER_PATH="${XBB_TARGET_WORK_FOLDER_PATH}/$(xbb_config_guess)"
  XBB_NATIVE_DEPENDENCIES_INSTALL_FOLDER_PATH="${XBB_TARGET_NATIVE_FOLDER_PATH}/${XBB_INSTALL_FOLDER_NAME}"

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

  # ---------------------------------------------------------------------------

  if [ ! -z "$(which pkg-config)" -a "${XBB_IS_DEVELOP}" == "y" ]
  then
    # Extra: pkg-config-verbose.
    run_verbose install -d -m 0755 "${XBB_NATIVE_DEPENDENCIES_INSTALL_FOLDER_PATH}/bin"
    run_verbose install -v -c -m 755 "${helper_folder_path}/extras/pkg-config-verbose" \
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

  # ---------------------------------------------------------------------------

  # libtool fails with the old Ubuntu /bin/sh.
  export SHELL="/bin/bash"
  export CONFIG_SHELL="/bin/bash"

  # Prevent 'configure: error: you should not run configure as root'
  # when running inside a docker container.
  export FORCE_UNSAFE_CONFIGURE=1
}

# Requires the host identity.
function xbb_set_request_target()
{
  # The default case, when the target is the same as the host.
  XBB_REQUESTED_TARGET_PLATFORM="${XBB_HOST_NODE_PLATFORM}"
  XBB_REQUESTED_TARGET_ARCH="${XBB_HOST_NODE_ARCH}"
  XBB_REQUESTED_TARGET_BITS="${XBB_HOST_BITS}"
  XBB_REQUESTED_TARGET_MACHINE="${XBB_HOST_MACHINE}"
  XBB_REQUESTED_TARGET_PREFIX=$(xbb_config_guess)

  case "${XBB_REQUESTED_TARGET:-""}" in
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

function xbb_set_target()
{
  local kind="${1:-"requested"}"

  if [ "${kind}" == "native" ]
  then
    # The target is the same as the host.
    XBB_TARGET_PLATFORM="${XBB_HOST_NODE_PLATFORM}"
    XBB_TARGET_ARCH="${XBB_HOST_NODE_ARCH}"
    XBB_TARGET_BITS="${XBB_HOST_BITS}"
    XBB_TARGET_MACHINE="${XBB_HOST_MACHINE}"
    XBB_TARGET_PREFIX="$(xbb_config_guess)"
  elif [ "${kind}" == "cross" ]
  then
    XBB_TARGET_PLATFORM="win32"
    XBB_TARGET_ARCH="x64"
    XBB_TARGET_BITS="64"
    XBB_TARGET_MACHINE="x86_64"
    XBB_TARGET_PREFIX="x86_64-w64-mingw32"
  elif [ "${kind}" == "requested" ]
  then
    # Set the actual to the requested.
    XBB_TARGET_PLATFORM="${XBB_REQUESTED_TARGET_PLATFORM}"
    XBB_TARGET_ARCH="${XBB_REQUESTED_TARGET_ARCH}"
    XBB_TARGET_BITS="${XBB_REQUESTED_TARGET_BITS}"
    XBB_TARGET_MACHINE="${XBB_REQUESTED_TARGET_MACHINE}"
    XBB_TARGET_PREFIX="${XBB_REQUESTED_TARGET_PREFIX}"
  else
    echo "Unsupported xbb_set_target ${kind}"
    exit 1
  fi

  export XBB_TARGET_PLATFORM
  export XBB_TARGET_ARCH
  export XBB_TARGET_BITS
  export XBB_TARGET_MACHINE
  export XBB_TARGET_SUFFIX

  # ---------------------------------------------------------------------------
  # Prefixed paths.
  XBB_TARGET_PREFIXED_FOLDER_PATH="${XBB_TARGET_WORK_FOLDER_PATH}/${XBB_TARGET_PREFIX}"

  XBB_BUILD_FOLDER_NAME="${XBB_BUILD_FOLDER_NAME-build}"
  XBB_BUILD_FOLDER_PATH="${XBB_TARGET_PREFIXED_FOLDER_PATH}/${XBB_BUILD_FOLDER_NAME}"

  XBB_DEPENDENCIES_INSTALL_FOLDER_PATH="${XBB_TARGET_PREFIXED_FOLDER_PATH}/${XBB_INSTALL_FOLDER_NAME}"

  XBB_STAMPS_FOLDER_NAME="${XBB_STAMPS_FOLDER_NAME:-stamps}"
  XBB_STAMPS_FOLDER_PATH="${XBB_TARGET_PREFIXED_FOLDER_PATH}/${XBB_STAMPS_FOLDER_NAME}"

  XBB_LOGS_FOLDER_NAME="${XBB_LOGS_FOLDER_NAME:-logs}"
  XBB_LOGS_FOLDER_PATH="${XBB_TARGET_PREFIXED_FOLDER_PATH}/${XBB_LOGS_FOLDER_NAME}"

  XBB_TESTS_FOLDER_NAME="${XBB_TESTS_FOLDER_NAME:-tests}"
  XBB_TESTS_FOLDER_PATH="${XBB_TARGET_PREFIXED_FOLDER_PATH}/${XBB_TESTS_FOLDER_NAME}"

  export XBB_BUILD_FOLDER_PATH
  export XBB_DEPENDENCIES_INSTALL_FOLDER_PATH
  export XBB_STAMPS_FOLDER_PATH
  export XBB_LOGS_FOLDER_PATH
  export XBB_TESTS_FOLDER_PATH

  # ---------------------------------------------------------------------------

  XBB_DOT_EXE=""
  # Compute the XBB_BUILD/XBB_HOST/XBB_TARGET for configure.
  XBB_CROSS_COMPILE_PREFIX=""
  if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
  then

    # Disable tests when cross compiling for Windows.
    XBB_WITH_TESTS="n"

    XBB_DOT_EXE=".exe"

    XBB_SHLIB_EXT="dll"

    # Use the 64-bit mingw-w64 gcc to compile Windows binaries.
    XBB_CROSS_COMPILE_PREFIX="x86_64-w64-mingw32"

    XBB_BUILD=$(xbb_config_guess)
    XBB_HOST="${XBB_CROSS_COMPILE_PREFIX}"
    XBB_TARGET="${XBB_HOST}"

  elif [ "${XBB_TARGET_PLATFORM}" == "linux" ]
  then

    XBB_SHLIB_EXT="so"

    XBB_BUILD=$(xbb_config_guess)
    XBB_HOST="${XBB_BUILD}"
    XBB_TARGET="${XBB_HOST}"

  elif [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
  then

    XBB_SHLIB_EXT="dylib"

    XBB_BUILD=$(xbb_config_guess)
    XBB_HOST="${XBB_BUILD}"
    XBB_TARGET="${XBB_HOST}"

  else
    echo "Unsupported XBB_TARGET_PLATFORM=${XBB_TARGET_PLATFORM}."
    exit 1
  fi

  export XBB_DOT_EXE
  export XBB_SHLIB_EXT

  export XBB_BUILD
  export XBB_HOST
  export XBB_TARGET

  # ---------------------------------------------------------------------------

  xbb_set_compiler_env

  # ---------------------------------------------------------------------------

  tests_add "xbb_set_target" "${kind}"

  # ---------------------------------------------------------------------------

  echo
  echo "XBB environment..."
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
  if [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
  then
    xbb_prepare_clang_env
  elif [ "${XBB_TARGET_PLATFORM}" == "linux" ]
  then
    xbb_prepare_gcc_env
  elif [ "${XBB_TARGET_PLATFORM}" == "win32" ]
  then
    export XBB_NATIVE_CC="gcc"
    export XBB_NATIVE_CXX="g++"

    xbb_prepare_gcc_env "${XBB_CROSS_COMPILE_PREFIX}-"
  else
    echo "Unsupported XBB_TARGET_PLATFORM=${XBB_TARGET_PLATFORM}."
    exit 1
  fi
}

function xbb_unset_compiler_env()
{
  unset CC
  unset CXX
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

function xbb_prepare_gcc_env()
{
  local prefix="${1:-}"
  local suffix="${2:-}"

  echo_develop
  echo_develop "[xbb_prepare_gcc_env]"

  xbb_unset_compiler_env

  export CC="${prefix}gcc${suffix}"
  export CXX="${prefix}g++${suffix}"

  # These are the special GCC versions, not the binutils ones.
  export AR="${prefix}gcc-ar${suffix}"
  export NM="${prefix}gcc-nm${suffix}"
  export RANLIB="${prefix}gcc-ranlib${suffix}"

  # From binutils.
  export AS="${prefix}as"
  export DLLTOOL="${prefix}dlltool"
  export LD="${prefix}ld"
  export OBJCOPY="${prefix}objcopy"
  export OBJDUMP="${prefix}objdump"
  export READELF="${prefix}readelf"
  export SIZE="${prefix}size"
  export STRIP="${prefix}strip"
  export WINDRES="${prefix}windres"
  export WINDMC="${prefix}windmc"
  export RC="${prefix}windres"

  xbb_set_compiler_flags
}

function xbb_prepare_clang_env()
{
  local prefix="${1:-}"
  local suffix="${2:-}"

  echo_develop
  echo_develop "[xbb_prepare_clang_env]"

  xbb_unset_compiler_env

  export CC="${prefix}clang${suffix}"
  export CXX="${prefix}clang++${suffix}"

  export AR="${prefix}ar"
  export AS="${prefix}as"
  # export DLLTOOL="${prefix}dlltool"
  export LD="${prefix}ld"
  export NM="${prefix}nm"
  # export OBJCOPY="${prefix}objcopy"
  export OBJDUMP="${prefix}objdump"
  export RANLIB="${prefix}ranlib"
  # export READELF="${prefix}readelf"
  export SIZE="${prefix}size"
  export STRIP="${prefix}strip"
  # export WINDRES="${prefix}windres"
  # export WINDMC="${prefix}windmc"
  # export RC="${prefix}windres"

  xbb_set_compiler_flags
}

function xbb_set_compiler_flags()
{
  XBB_CPPFLAGS=""

  XBB_CFLAGS="-ffunction-sections -fdata-sections -pipe"
  XBB_CXXFLAGS="-ffunction-sections -fdata-sections -pipe"

  if [ "${XBB_TARGET_ARCH}" == "x64" -o "${XBB_TARGET_ARCH}" == "x32" -o "${XBB_TARGET_ARCH}" == "ia32" ]
  then
    XBB_CFLAGS+=" -m${XBB_TARGET_BITS}"
    XBB_CXXFLAGS+=" -m${XBB_TARGET_BITS}"
  fi

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

  if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
  then
    # Do not add -static here, it fails.
    # Do not try to link pthread statically, it must match the system glibc.
    XBB_LDFLAGS_LIB="${XBB_LDFLAGS}"
    XBB_LDFLAGS_APP="${XBB_LDFLAGS} -Wl,--gc-sections"
    XBB_LDFLAGS_APP_STATIC_GCC="${XBB_LDFLAGS_APP} -static-libgcc -static-libstdc++"
  elif [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
  then
    if [ "${XBB_TARGET_ARCH}" == "x64" ]
    then
      export XBB_MACOSX_DEPLOYMENT_TARGET="10.13"
    elif [ "${XBB_TARGET_ARCH}" == "arm64" ]
    then
      export XBB_MACOSX_DEPLOYMENT_TARGET="11.0"
    else
      echo "Unknown XBB_TARGET_ARCH ${XBB_TARGET_ARCH}"
      exit 1
    fi

    if [[ ${CC} =~ .*clang.* ]]
    then
      XBB_CFLAGS+=" -mmacosx-version-min=${XBB_MACOSX_DEPLOYMENT_TARGET}"
      XBB_CXXFLAGS+=" -mmacosx-version-min=${XBB_MACOSX_DEPLOYMENT_TARGET}"
    fi

    # Note: macOS linker ignores -static-libstdc++, so
    # libstdc++.6.dylib should be handled.
    XBB_LDFLAGS+=" -Wl,-macosx_version_min,${XBB_MACOSX_DEPLOYMENT_TARGET}"

    # With GCC 11.2 path are longer, and post-processing may fail:
    # error: /Library/Developer/CommandLineTools/usr/bin/install_name_tool: changing install names or rpaths can't be redone for: /Users/ilg/Work/gcc-11.2.0-2/darwin-x64/install/gcc/libexec/gcc/x86_64-apple-darwin17.7.0/11.2.0/g++-mapper-server (for architecture x86_64) because larger updated load commands do not fit (the program must be relinked, and you may need to use -headerpad or -headerpad_max_install_names)
    XBB_LDFLAGS+=" -Wl,-headerpad_max_install_names"

    XBB_LDFLAGS_LIB="${XBB_LDFLAGS}"
    XBB_LDFLAGS_APP="${XBB_LDFLAGS} -Wl,-dead_strip"
    XBB_LDFLAGS_APP_STATIC_GCC="${XBB_LDFLAGS_APP} -static-libstdc++"
    if [[ ${CC} =~ .*gcc.* ]]
    then
      XBB_LDFLAGS_APP_STATIC_GCC+=" -static-libgcc"
    fi
  elif [ "${XBB_TARGET_PLATFORM}" == "win32" ]
  then

    # Note: use this explcitly in the application.
    # prepare_gcc_env "${XBB_CROSS_COMPILE_PREFIX}-"

    # To make `access()` not fail when passing a non-zero mode.
    # https://sourceforge.net/p/mingw-w64/mailman/message/37372220/
    # Do not add it to XBB_CPPFLAGS, since the current macro
    # crashes C++ code, like in `llvm/lib/Support/LockFileManager.cpp`:
    # `if (sys::fs::access(LockFileName.c_str(), sys::fs::AccessMode::Exist) ==`
    XBB_CFLAGS+=" -D__USE_MINGW_ACCESS"

    # llvm fails. Enable it only when needed.
    if false
    then
      # To prevent "too many sections", "File too big" etc.
      # Unfortunately some builds fail, so it must be used explictly.
      # TODO: check if the RISC-V toolchain no longer fails.
      XBB_CFLAGS+=" -Wa,-mbig-obj"
      XBB_CXXFLAGS+=" -Wa,-mbig-obj"
    fi

    # CRT_glob is from Arm script
    # -static avoids libwinpthread-1.dll
    # -static-libgcc avoids libgcc_s_sjlj-1.dll
    XBB_LDFLAGS_LIB="${XBB_LDFLAGS}"
    XBB_LDFLAGS_APP="${XBB_LDFLAGS} -Wl,--gc-sections"
    XBB_LDFLAGS_APP_STATIC_GCC="${XBB_LDFLAGS_APP} -static-libgcc -static-libstdc++"
  else
    echo "Unsupported XBB_TARGET_PLATFORM=${XBB_TARGET_PLATFORM}."
    exit 1
  fi

  XBB_CFLAGS_NO_W="${XBB_CFLAGS} -w"
  XBB_CXXFLAGS_NO_W="${XBB_CXXFLAGS} -w"

  if [ "${XBB_IS_DEVELOP}" == "y" ]
  then
    (
      set +u
      echo
      echo "CC=${CC}"
      echo "CXX=${CXX}"
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

function xbb_set_binaries_install()
{
  export XBB_BINARIES_INSTALL_FOLDER_PATH="$1"

  # tests_add "xbb_set_binaries_install" "$1"
}

function xbb_set_libraries_install()
{
  export XBB_LIBRARIES_INSTALL_FOLDER_PATH="$1"

  # tests_add "xbb_set_libraries_install" "$1"
}

# Add the freshly built binaries.
function xbb_activate_installed_bin()
{
  echo_develop
  echo_develop "[xbb_activate_installed_bin]"

  # Add the XBB bin to the PATH.
  if [ ! -z ${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH+x} ]
  then
    # When invoked from tests, the libs are not available.
    PATH="${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/bin:${PATH}"
  fi

  if [ ! -z ${XBB_APPLICATION_INSTALL_FOLDER_PATH+x} ]
  then
    PATH="${XBB_APPLICATION_INSTALL_FOLDER_PATH}/bin:${XBB_APPLICATION_INSTALL_FOLDER_PATH}/usr/bin:${PATH}"
  fi

  if [ ! -z ${XBB_TEST_BIN_PATH+x} ]
  then
    PATH="${XBB_TEST_BIN_PATH}:${PATH}"
  fi

  hash -r

  # Update PKG_CONFIG, in case it was compiled locally.
  if [ ! -z "$(which pkg-config-verbose)" -a "${XBB_IS_DEVELOP}" == "y" ]
  then
    PKG_CONFIG="$(which pkg-config-verbose)"
  elif [ ! -z "$(which pkg-config)" ]
  then
    PKG_CONFIG="$(which pkg-config)"
  fi

  export PATH
}

# Add the freshly built headers and libraries.
function xbb_activate_installed_dev()
{
  local name_suffix=${1-''}

  echo_develop
  echo_develop "[xbb_activate_installed_dev${name_suffix}]"

  # Add XBB include in front of XBB_CPPFLAGS.
  XBB_CPPFLAGS="-I${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/include ${XBB_CPPFLAGS}"

  if [ -d "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib" ]
  then
    # Add XBB lib in front of XBB_LDFLAGS.
    XBB_LDFLAGS="-L${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib ${XBB_LDFLAGS}"
    XBB_LDFLAGS_LIB="-L${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib ${XBB_LDFLAGS_LIB}"
    XBB_LDFLAGS_APP="-L${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib ${XBB_LDFLAGS_APP}"
    XBB_LDFLAGS_APP_STATIC_GCC="-L${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib ${XBB_LDFLAGS_APP_STATIC_GCC}"

    # Add XBB lib in front of PKG_CONFIG_PATH.
    PKG_CONFIG_PATH="${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib/pkgconfig:${PKG_CONFIG_PATH}"

    # Needed by internal binaries, like the bootstrap compiler, which do not
    # have a rpath.
    if [ -z "${LD_LIBRARY_PATH}" ]
    then
      LD_LIBRARY_PATH="${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib"
    else
      LD_LIBRARY_PATH="${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib:${LD_LIBRARY_PATH}"
    fi
  fi

  # Used by libffi, for example.
  if [ -d "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib64" ]
  then
    # For 64-bit systems, add XBB lib64 in front of paths.
    XBB_LDFLAGS="-L${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib64 ${XBB_LDFLAGS_LIB}"
    XBB_LDFLAGS_LIB="-L${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib64 ${XBB_LDFLAGS_LIB}"
    XBB_LDFLAGS_APP="-L${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib64 ${XBB_LDFLAGS_APP}"
    XBB_LDFLAGS_APP_STATIC_GCC="-L${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib64 ${XBB_LDFLAGS_APP_STATIC_GCC}"

    PKG_CONFIG_PATH="${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib64/pkgconfig:${PKG_CONFIG_PATH}"

    if [ -z "${LD_LIBRARY_PATH}" ]
    then
      LD_LIBRARY_PATH="${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib64"
    else
      LD_LIBRARY_PATH="${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib64:${LD_LIBRARY_PATH}"
    fi
  fi

  export XBB_CPPFLAGS

  export XBB_LDFLAGS
  export XBB_LDFLAGS_LIB
  export XBB_LDFLAGS_APP
  export XBB_LDFLAGS_APP_STATIC_GCC

  export PKG_CONFIG_PATH
  export LD_LIBRARY_PATH

  if [ "${XBB_IS_DEVELOP}" == "y" ]
  then
    echo
    env | sort
  fi
}

function xbb_activate_cxx_rpath()
{
  local cxx_lib_path=""

  local realpath=$(which grealpath || which realpath || echo realpath)

  if [[ ${CC} =~ .*gcc.* ]]
  then
    cxx_lib_path="$(${realpath} $(dirname $(${CXX} -print-file-name=libstdc++.so.6)))"
    echo_develop
    echo_develop "libstdc++.so.6 -> ${cxx_lib_path}"
    if [ "${cxx_lib_path}" == "libstdc++.so.6" ]
    then
      return
    fi
  fi

  if [ -z "${cxx_lib_path}" ]
  then
    return
  fi

  if [ -z "${LD_LIBRARY_PATH}" ]
  then
    LD_LIBRARY_PATH="${cxx_lib_path}"
  else
    LD_LIBRARY_PATH="${cxx_lib_path}:${LD_LIBRARY_PATH}"
  fi

  export LD_LIBRARY_PATH
}

function xbb_get_current_package_version()
{
  local package_file_path="${1:-"${project_folder_path}/package.json"}"

  # Extract only the first line
  grep '"version":' "${package_file_path}" | sed -e 's|.*"version": "\(.*\)".*|\1|'
}

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

    if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
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
