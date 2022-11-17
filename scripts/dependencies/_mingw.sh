# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# Used to initialise options in all mingw builds:
# `config_options=("${config_options_common[@]}")`

function prepare_mingw_config_options_common()
{
  # ---------------------------------------------------------------------------
  # Used in multiple configurations.

  config_options_common=()

  # local prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}
  if [ $# -ge 1 ]
  then
    config_options_common+=("--prefix=$1")
  else
    echo "prepare_mingw_config_options_common requires a prefix path"
    exit 1
  fi

  config_options_common+=("--disable-multilib")

  # https://docs.microsoft.com/en-us/cpp/porting/modifying-winver-and-win32-winnt?view=msvc-160
  # Windows 7
  config_options_common+=("--with-default-win32-winnt=0x601")

  # `ucrt` is the new Microsoft C runtime.
  # https://support.microsoft.com/en-us/topic/update-for-universal-c-runtime-in-windows-c0514201-7fe6-95a3-b0a5-287930f3560c
  config_options_common+=("--with-default-msvcrt=${XBB_MINGW_MSVCRT:-ucrt}")
  # config_options_common+=("--with-default-msvcrt=${XBB_MINGW_MSVCRT:-msvcrt}")

  config_options_common+=("--enable-wildcard")
  config_options_common+=("--enable-warnings=0")
}

function prepare_mingw_env()
{
  export XBB_MINGW_VERSION="$1"
  export XBB_MINGW_NAME_SUFFIX="${2:-""}"

  export XBB_MINGW_VERSION_MAJOR=$(echo ${XBB_MINGW_VERSION} | sed -e 's|\([0-9][0-9]*\)\..*|\1|')

  # The original SourceForge location.
  export XBB_MINGW_SRC_FOLDER_NAME="mingw-w64-v${XBB_MINGW_VERSION}"
  export XBB_MINGW_FOLDER_NAME="${XBB_MINGW_SRC_FOLDER_NAME}${XBB_MINGW_NAME_SUFFIX}"
}

function build_mingw_headers()
{
  # http://mingw-w64.org/doku.php/start
  # https://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-headers
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-crt
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-winpthreads
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-binutils
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-gcc

  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-headers-git/PKGBUILD
  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-crt-git/PKGBUILD
  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-winpthreads-git/PKGBUILD
  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-binutils/PKGBUILD
  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-gcc/PKGBUILD

  # https://github.com/msys2/MSYS2-packages/blob/master/gcc/PKGBUILD

  # https://github.com/StephanTLavavej/mingw-distro

  # 2018-06-03, "5.0.4"
  # 2018-09-16, "6.0.0"
  # 2019-11-11, "7.0.0"
  # 2020-09-18, "8.0.0"
  # 2021-05-09, "8.0.2"
  # 2021-05-22, "9.0.0"
  # 2022-04-04, "10.0.0"

  local mingw_archive="${XBB_MINGW_SRC_FOLDER_NAME}.tar.bz2"
  local mingw_url="https://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/${mingw_archive}"

  # If SourceForge is down, there is also a GitHub mirror.
  # https://github.com/mirror/mingw-w64
  # XBB_MINGW_FOLDER_NAME="mingw-w64-${XBB_MINGW_VERSION}"
  # mingw_archive="v${XBB_MINGW_VERSION}.tar.gz"
  # mingw_url="https://github.com/mirror/mingw-w64/archive/${mingw_archive}"

  # https://sourceforge.net/p/mingw-w64/wiki2/Cross%20Win32%20and%20Win64%20compiler/
  # https://sourceforge.net/p/mingw-w64/mingw-w64/ci/master/tree/configure

  # For binutils/GCC, the official method to build the mingw-w64 toolchain
  # is to set --prefix and --with-sysroot to the same directory to allow
  # the toolchain to be relocatable.

  # Recommended GCC configuration:
  # (to disable multilib, add `--enable-targets="${XBB_TARGET_TRIPLET}"`)
  #
  # $ ../gcc-trunk/configure --{host,build}=<build triplet> \
	# --target=x86_64-w64-mingw32 --enable-multilib --enable-64bit \
	# --{prefix,with-sysroot}=<prefix> --enable-version-specific-runtime-libs \
	# --enable-shared --with-dwarf --enable-fully-dynamic-string \
	# --enable-languages=c,ada,c++,fortran,objc,obj-c++ --enable-libgomp \
	# --enable-libssp --with-host-libstdcxx="-lstdc++ -lsupc++" \
	# --with-{gmp,mpfr,mpc,cloog,ppl}=<host dir> --enable-lto
  #
  # $ make all-gcc && make install-gcc
  #
  # build mingw-w64-crt (headers, crt, tools)
  #
  # $ make all-target-libgcc && make install-target-libgcc
  #
  # build mingw-libraries (winpthreads)
  #
  # Continue the GCC build (C++)
  # $ make && make install

  # ---------------------------------------------------------------------------

  # The 'headers' step creates the 'include' folder.

  local mingw_headers_folder_name="mingw-${XBB_MINGW_VERSION}-headers${XBB_MINGW_NAME_SUFFIX}"

  mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
  cd "${XBB_SOURCES_FOLDER_PATH}"

  download_and_extract "${mingw_url}" "${mingw_archive}" \
    "${XBB_MINGW_SRC_FOLDER_NAME}"

  # The docs recommend to add several links, but for non-multilib
  # configurations there are no target or lib32/lib64 specific folders.

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${XBB_MINGW_FOLDER_NAME}"

  # ---------------------------------------------------------------------------

  # https://github.com/archlinux/svntogit-community/blob/packages/mingw-w64-headers/trunk/PKGBUILD

  local mingw_headers_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${mingw_headers_folder_name}-installed"
  if [ ! -f "${mingw_headers_stamp_file_path}" ]
  then
    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${mingw_headers_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${mingw_headers_folder_name}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running mingw-w64-headers${XBB_MINGW_NAME_SUFFIX} configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${XBB_MINGW_SRC_FOLDER_NAME}/mingw-w64-headers/configure" --help
          fi

          if [ "${XBB_MINGW_NAME_SUFFIX}" == "${XBB_BOOTSTRAP_SUFFIX}" ]
          then
            prepare_mingw_config_options_common "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${XBB_MINGW_NAME_SUFFIX}"
            config_options=("${config_options_common[@]}")

            config_options+=("--build=${XBB_BUILD_TRIPLET}")
            # The bootstrap binaries will run on the build machine.
            config_options+=("--host=${XBB_TARGET_TRIPLET}")
            config_options+=("--target=${XBB_TARGET_TRIPLET}")
          else
            prepare_mingw_config_options_common "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${XBB_MINGW_NAME_SUFFIX}/${XBB_TARGET_TRIPLET}"
            config_options=("${config_options_common[@]}")

            config_options+=("--build=${XBB_BUILD_TRIPLET}")
            config_options+=("--host=${XBB_HOST_TRIPLET}")
            config_options+=("--target=${XBB_TARGET_TRIPLET}")
          fi

          config_options+=("--with-tune=generic")

          config_options+=("--enable-sdk=all")
          config_options+=("--enable-idl")
          config_options+=("--without-widl")

          # From Arch, but not recognised.
          # config_options+=("--enable-secure-api")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${XBB_MINGW_SRC_FOLDER_NAME}/mingw-w64-headers/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${XBB_MINGW_FOLDER_NAME}/config-headers-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${XBB_MINGW_FOLDER_NAME}/configure-headers-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running mingw-w64-headers${XBB_MINGW_NAME_SUFFIX} make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        run_verbose make install-strip

        if [ "${XBB_MINGW_NAME_SUFFIX}" == "${XBB_BOOTSTRAP_SUFFIX}" ]
        then
          mkdir -pv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${XBB_MINGW_NAME_SUFFIX}/${XBB_TARGET_TRIPLET}"
          (
            cd "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${XBB_MINGW_NAME_SUFFIX}/${XBB_TARGET_TRIPLET}"
            run_verbose ln -sv ../include include
          )

          # This is this needed by the GCC bootstrap; otherwise:
          # The directory that should contain system headers does not exist:
          # /Host/home/ilg/Work/gcc-11.1.0-1/win32-x64/install/gcc-bootstrap/mingw/include

          rm -rf "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${XBB_MINGW_NAME_SUFFIX}/mingw"
          (
            cd "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${XBB_MINGW_NAME_SUFFIX}"
            run_verbose ln -sv "${XBB_TARGET_TRIPLET}" "mingw"
          )
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${XBB_MINGW_FOLDER_NAME}/make-headers-output-$(ndate).txt"

      # No need to do it again for each component.
      if [ -z "${XBB_MINGW_NAME_SUFFIX}" ]
      then
        copy_license \
          "${XBB_SOURCES_FOLDER_PATH}/${XBB_MINGW_SRC_FOLDER_NAME}" \
          "${XBB_MINGW_FOLDER_NAME}"
      fi

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${mingw_headers_stamp_file_path}"

  else
    echo "Component mingw-w64-headers${XBB_MINGW_NAME_SUFFIX} already installed."
  fi
}

function build_mingw_crt()
{
  # ---------------------------------------------------------------------------

  # The 'crt' step creates the C run-time in the 'lib' folder.

  # https://github.com/archlinux/svntogit-community/blob/packages/mingw-w64-crt/trunk/PKGBUILD

  local mingw_crt_folder_name="mingw-${XBB_MINGW_VERSION}-crt${XBB_MINGW_NAME_SUFFIX}"

  local mingw_crt_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${mingw_crt_folder_name}-installed"
  if [ ! -f "${mingw_crt_stamp_file_path}" ]
  then
    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${mingw_crt_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${mingw_crt_folder_name}"

      # -ffunction-sections -fdata-sections fail with:
      # Error: .seh_endproc used in segment '.text' instead of expected '.text$WinMainCRTStartup'
      CPPFLAGS=""
      CFLAGS="-O2 -pipe -w"
      CXXFLAGS="-O2 -pipe -w"

      LDFLAGS=""

      if [ "${XBB_IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      # Without it, apparently a bug in autoconf/c.m4, function AC_PROG_CC, results in:
      # checking for _mingw_mac.h... no
      # configure: error: Please check if the mingw-w64 header set and the build/host option are set properly.
      # (https://github.com/henry0312/build_gcc/issues/1)
      # export CC=""
      # Alternately it is possible to define CC to the mingw-gcc.

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running mingw-w64-crt${XBB_MINGW_NAME_SUFFIX} configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${XBB_MINGW_SRC_FOLDER_NAME}/mingw-w64-crt/configure" --help
          fi

          prepare_mingw_config_options_common "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${XBB_MINGW_NAME_SUFFIX}/${XBB_TARGET_TRIPLET}"
          config_options=("${config_options_common[@]}")
          config_options+=("--with-sysroot=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${XBB_MINGW_NAME_SUFFIX}")

          if [ "${XBB_MINGW_NAME_SUFFIX}" == "${XBB_BOOTSTRAP_SUFFIX}" ]
          then
            config_options+=("--build=${XBB_BUILD_TRIPLET}")
            # The bootstrap binaries will run on the build machine.
            config_options+=("--host=${XBB_TARGET_TRIPLET}")
            config_options+=("--target=${XBB_TARGET_TRIPLET}")
          else
            config_options+=("--build=${XBB_BUILD_TRIPLET}")
            config_options+=("--host=${XBB_HOST_TRIPLET}")
            config_options+=("--target=${XBB_TARGET_TRIPLET}")
          fi

          if [ "${XBB_HOST_ARCH}" == "x64" ]
          then
            config_options+=("--disable-lib32")
            config_options+=("--enable-lib64")
          elif [ "${XBB_HOST_ARCH}" == "x32" -o "${XBB_HOST_ARCH}" == "ia32" ]
          then
            config_options+=("--enable-lib32")
            config_options+=("--disable-lib64")
          else
            echo "Unsupported XBB_HOST_ARCH=${XBB_HOST_ARCH} in ${FUNCNAME[0]}()"
            exit 1
          fi

          config_options+=("--enable-wildcard")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${XBB_MINGW_SRC_FOLDER_NAME}/mingw-w64-crt/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${XBB_MINGW_FOLDER_NAME}/config-crt-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${XBB_MINGW_FOLDER_NAME}/configure-crt-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running mingw-w64-crt${XBB_MINGW_NAME_SUFFIX} make..."

        # Build.
        # On Linux it fails with weird messages.
        # run_verbose make -j ${XBB_JOBS}
        run_verbose make -j1

        run_verbose make install-strip

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${XBB_MINGW_FOLDER_NAME}/make-crt-output-$(ndate).txt"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${mingw_crt_stamp_file_path}"

  else
    echo "Component mingw-w64-crt${XBB_MINGW_NAME_SUFFIX} already installed."
  fi
}


function build_mingw_winpthreads()
{
  # https://github.com/archlinux/svntogit-community/blob/packages/mingw-w64-winpthreads/trunk/PKGBUILD

  local mingw_winpthreads_folder_name="mingw-${XBB_MINGW_VERSION}-winpthreads${XBB_MINGW_NAME_SUFFIX}"

  local mingw_winpthreads_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${mingw_winpthreads_folder_name}-installed"
  if [ ! -f "${mingw_winpthreads_stamp_file_path}" ]
  then
    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${mingw_winpthreads_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${mingw_winpthreads_folder_name}"

      # -ffunction-sections -fdata-sections fail with:
      # Error: .seh_endproc used in segment '.text' instead of expected '.text$WinMainCRTStartup'
      CPPFLAGS=""
      CFLAGS="-O2 -pipe -w"
      CXXFLAGS="-O2 -pipe -w"

      LDFLAGS=""

      if [ "${XBB_IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running mingw-w64-winpthreads${XBB_MINGW_NAME_SUFFIX} configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${XBB_MINGW_SRC_FOLDER_NAME}/mingw-w64-libraries/winpthreads/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${XBB_MINGW_NAME_SUFFIX}/${XBB_TARGET_TRIPLET}")
          config_options+=("--with-sysroot=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${XBB_MINGW_NAME_SUFFIX}")

          config_options+=("--libdir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${XBB_MINGW_NAME_SUFFIX}/${XBB_TARGET_TRIPLET}/lib")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          # This prevents references to libwinpthread-1.dll, which is
          # particularly useful with -static-libstdc++, otherwise the
          # result is not exactly static.
          # This also requires disabling shared in the GCC configuration.
          config_options+=("--disable-shared")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${XBB_MINGW_SRC_FOLDER_NAME}/mingw-w64-libraries/winpthreads/configure" \
            "${config_options[@]}"

         cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${XBB_MINGW_FOLDER_NAME}/config-winpthreads-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${XBB_MINGW_FOLDER_NAME}/configure-winpthreads-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running mingw-w64-winpthreads${XBB_MINGW_NAME_SUFFIX} make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        run_verbose make install-strip

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${XBB_MINGW_FOLDER_NAME}/make-winpthreads-output-$(ndate).txt"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${mingw_winpthreads_stamp_file_path}"

  else
    echo "Component mingw-w64-winpthreads${XBB_MINGW_NAME_SUFFIX} already installed."
  fi
}

function build_mingw_winstorecompat()
{
  local mingw_winstorecompat_folder_name="mingw-${XBB_MINGW_VERSION}-winstorecompat${XBB_MINGW_NAME_SUFFIX}"

  local mingw_winstorecompat_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${mingw_winstorecompat_folder_name}-installed"
  if [ ! -f "${mingw_winstorecompat_stamp_file_path}" ]
  then

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${mingw_winstorecompat_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${mingw_winstorecompat_folder_name}"

      CPPFLAGS=""
      CFLAGS="-O2 -pipe -w"
      CXXFLAGS="-O2 -pipe -w"

      LDFLAGS=""

      if [ "${XBB_IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running mingw-w64-winstorecompat${XBB_MINGW_NAME_SUFFIX} configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${XBB_MINGW_SRC_FOLDER_NAME}/mingw-w64-libraries/winstorecompat/configure" --help
          fi

          config_options=()
          # Note: native library.

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${XBB_MINGW_NAME_SUFFIX}/${XBB_TARGET_TRIPLET}")
          config_options+=("--libdir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${XBB_MINGW_NAME_SUFFIX}/${XBB_TARGET_TRIPLET}/lib")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${XBB_MINGW_SRC_FOLDER_NAME}/mingw-w64-libraries/winstorecompat/configure" \
            "${config_options[@]}"

         cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${XBB_MINGW_FOLDER_NAME}/config-winstorecompat-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${XBB_MINGW_FOLDER_NAME}/configure-winstorecompat-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running mingw-w64-winstorecompat${XBB_MINGW_NAME_SUFFIX} make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        run_verbose make install-strip

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${XBB_MINGW_FOLDER_NAME}/make-winstorecompat-output-$(ndate).txt"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${mingw_winstorecompat_stamp_file_path}"

  else
    echo "Component mingw-w64-winstorecompat${XBB_MINGW_NAME_SUFFIX} already installed."
  fi
}

function build_mingw_libmangle()
{
  local mingw_libmangle_folder_name="mingw-${XBB_MINGW_VERSION}-libmangle${XBB_MINGW_NAME_SUFFIX}"

  local mingw_libmangle_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${mingw_libmangle_folder_name}-installed"
  if [ ! -f "${mingw_libmangle_stamp_file_path}" ]
  then

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${mingw_libmangle_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${mingw_libmangle_folder_name}"

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS}"

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running mingw-w64-libmangle${XBB_MINGW_NAME_SUFFIX} configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${XBB_MINGW_SRC_FOLDER_NAME}/mingw-w64-libraries/libmangle/configure" --help
          fi

          config_options=()
          # Note: native library.
          config_options+=("--prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${XBB_MINGW_NAME_SUFFIX}")

          if [ "${XBB_MINGW_NAME_SUFFIX}" == "${XBB_BOOTSTRAP_SUFFIX}" ]
          then
            config_options+=("--build=${XBB_BUILD_TRIPLET}")
            config_options+=("--host=${XBB_BUILD_TRIPLET}")
            config_options+=("--target=${XBB_BUILD_TRIPLET}")
          else
            config_options+=("--build=${XBB_BUILD_TRIPLET}")
            config_options+=("--host=${XBB_HOST_TRIPLET}")
            config_options+=("--target=${XBB_TARGET_TRIPLET}")
          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${XBB_MINGW_SRC_FOLDER_NAME}/mingw-w64-libraries/libmangle/configure" \
            "${config_options[@]}"

         cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${XBB_MINGW_FOLDER_NAME}/config-libmangle-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${XBB_MINGW_FOLDER_NAME}/configure-libmangle-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running mingw-w64-libmangle${XBB_MINGW_NAME_SUFFIX} make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        run_verbose make install-strip

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${XBB_MINGW_FOLDER_NAME}/make-libmangle-output-$(ndate).txt"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${mingw_libmangle_stamp_file_path}"

  else
    echo "Component mingw-w64-libmangle${XBB_MINGW_NAME_SUFFIX} already installed."
  fi
}


function build_mingw_gendef()
{
  local mingw_gendef_folder_name="mingw-${XBB_MINGW_VERSION}-gendef${XBB_MINGW_NAME_SUFFIX}"

  local mingw_gendef_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${mingw_gendef_folder_name}-installed"
  if [ ! -f "${mingw_gendef_stamp_file_path}" ]
  then

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${mingw_gendef_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${mingw_gendef_folder_name}"

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      # LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC}"
      LDFLAGS="${XBB_LDFLAGS_APP}"

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running mingw-w64-gendef${XBB_MINGW_NAME_SUFFIX} configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${XBB_MINGW_SRC_FOLDER_NAME}/mingw-w64-tools/gendef/configure" --help
          fi

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${XBB_MINGW_NAME_SUFFIX}")

          if [ "${XBB_MINGW_NAME_SUFFIX}" == "${XBB_BOOTSTRAP_SUFFIX}" ]
          then
            config_options+=("--build=${XBB_BUILD_TRIPLET}")
            config_options+=("--host=${XBB_BUILD_TRIPLET}")
            config_options+=("--target=${XBB_BUILD_TRIPLET}")
          else
            config_options+=("--build=${XBB_BUILD_TRIPLET}")
            config_options+=("--host=${XBB_HOST_TRIPLET}")
            config_options+=("--target=${XBB_TARGET_TRIPLET}")
          fi

          config_options+=("--with-mangle=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${XBB_MINGW_NAME_SUFFIX}")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${XBB_MINGW_SRC_FOLDER_NAME}/mingw-w64-tools/gendef/configure" \
            "${config_options[@]}"

         cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${XBB_MINGW_FOLDER_NAME}/config-gendef-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${XBB_MINGW_FOLDER_NAME}/configure-gendef-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running mingw-w64-gendef${XBB_MINGW_NAME_SUFFIX} make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        run_verbose make install-strip

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${XBB_MINGW_FOLDER_NAME}/make-gendef-output-$(ndate).txt"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${mingw_gendef_stamp_file_path}"

  else
    echo "Component mingw-w64-gendef${XBB_MINGW_NAME_SUFFIX} already installed."
  fi
}


function build_mingw_widl()
{
  local mingw_widl_folder_name="mingw-${XBB_MINGW_VERSION}-widl${XBB_MINGW_NAME_SUFFIX}"

  local mingw_widl_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${mingw_widl_folder_name}-installed"
  if [ ! -f "${mingw_widl_stamp_file_path}" ]
  then

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${mingw_widl_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${mingw_widl_folder_name}"

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      # LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC}"
      LDFLAGS="${XBB_LDFLAGS_APP}"

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running mingw-w64-widl${XBB_MINGW_NAME_SUFFIX} configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${XBB_MINGW_SRC_FOLDER_NAME}/mingw-w64-tools/widl/configure" --help
          fi

          config_options=()
          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${XBB_MINGW_NAME_SUFFIX}")

          if [ "${XBB_MINGW_NAME_SUFFIX}" == "${XBB_BOOTSTRAP_SUFFIX}" ]
          then
            config_options+=("--build=${XBB_BUILD_TRIPLET}")
            config_options+=("--host=${XBB_HOST_TRIPLET}") # Native!
            config_options+=("--target=${XBB_TARGET_TRIPLET}")

          else
            config_options+=("--build=${XBB_BUILD_TRIPLET}")
            config_options+=("--host=${XBB_HOST_TRIPLET}")
            config_options+=("--target=${XBB_TARGET_TRIPLET}")

            # To remove any target specific prefix and leave only widl.exe.
            config_options+=("--program-prefix=")
          fi

          config_options+=("--with-widl-includedir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${XBB_MINGW_NAME_SUFFIX}/${XBB_TARGET_TRIPLET}/include")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${XBB_MINGW_SRC_FOLDER_NAME}/mingw-w64-tools/widl/configure" \
            "${config_options[@]}"

         cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${XBB_MINGW_FOLDER_NAME}/config-widl-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${XBB_MINGW_FOLDER_NAME}/configure-widl-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running mingw-w64-widl${XBB_MINGW_NAME_SUFFIX} make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        run_verbose make install-strip

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${XBB_MINGW_FOLDER_NAME}/make-widl-output-$(ndate).txt"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${mingw_widl_stamp_file_path}"

  else
    echo "Component mingw-w64-widl${XBB_MINGW_NAME_SUFFIX} already installed."
  fi
}

# -----------------------------------------------------------------------------

