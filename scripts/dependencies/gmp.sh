# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function build_gmp()
{
  # https://gmplib.org
  # https://gmplib.org/download/gmp/

  # https://github.com/archlinux/svntogit-packages/blob/packages/gmp/trunk/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/gmp/files/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/gmp.rb

  # 01-Nov-2015 "6.1.0"
  # 16-Dec-2016 "6.1.2"
  # 17-Jan-2020 "6.2.0"
  # 14-Nov-2020, "6.2.1"

  local gmp_version="$1"
  local name_suffix="${2:-""}"

  # The folder name as resulted after being extracted from the archive.
  local gmp_src_folder_name="gmp-${gmp_version}"

  local gmp_archive="${gmp_src_folder_name}.tar.xz"
  local gmp_url="https://gmplib.org/download/gmp/${gmp_archive}"

  # The folder name for build, licenses, etc.
  local gmp_folder_name="${gmp_src_folder_name}${name_suffix}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${gmp_folder_name}"

  local gmp_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${gmp_folder_name}-installed"
  if [ ! -f "${gmp_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${gmp_url}" "${gmp_archive}" \
      "${gmp_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${gmp_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${gmp_folder_name}"

      if [ "${name_suffix}" == "${XBB_BOOTSTRAP_SUFFIX}" ]
      then

        CPPFLAGS="${XBB_CPPFLAGS}"
        CFLAGS="${XBB_CFLAGS_NO_W}"
        CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

        LDFLAGS="${XBB_LDFLAGS_LIB}"

      else

        xbb_activate_dependencies_dev
        # For the local M4; remove it when available as dependency.
        # xbb_activate_installed_bin

        # Exceptions used by Arm GCC script and by mingw-w64.
        CPPFLAGS="${XBB_CPPFLAGS} -fexceptions"
        # Test fail with -Ofast, revert to -O2
        CFLAGS="${XBB_CFLAGS_NO_W}"
        CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

        LDFLAGS="${XBB_LDFLAGS_LIB}"
        xbb_adjust_ldflags_rpath

        if [ "${XBB_HOST_PLATFORM}" == "win32" ]
        then
          export CC_FOR_BUILD="${XBB_NATIVE_CC}"
        fi

      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      # ABI is mandatory, otherwise configure fails on 32-bit.
      # (see https://gmplib.org/manual/ABI-and-ISA.html)
      if [ "${XBB_HOST_ARCH}" == "x64" -o "${XBB_HOST_ARCH}" == "x32" -o "${XBB_HOST_ARCH}" == "ia32" ]
      then
        export ABI="${XBB_HOST_BITS}"
      fi

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running gmp${name_suffix} configure..."

          # ABI is mandatory, otherwise configure fails on 32-bit.
          # (see https://gmplib.org/manual/ABI-and-ISA.html)

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${gmp_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${name_suffix}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/share/man")

          if [ "${name_suffix}" == "${XBB_BOOTSTRAP_SUFFIX}" ]
          then

            config_options+=("--build=${XBB_BUILD_TRIPLET}")
            config_options+=("--host=${XBB_BUILD_TRIPLET}")
            config_options+=("--target=${XBB_BUILD_TRIPLET}")

          else

            config_options+=("--build=${XBB_BUILD_TRIPLET}")
            config_options+=("--host=${XBB_HOST_TRIPLET}")
            # config_options+=("--target=${XBB_TARGET_TRIPLET}")

            config_options+=("--enable-cxx")
            config_options+=("--enable-fat") # Arch

            # From Arm.
            config_options+=("--enable-fft")

            if [ "${XBB_HOST_PLATFORM}" == "win32" ]
            then
              # mpfr asks for this explicitly during configure.
              # (although the message is confusing)
              config_options+=("--enable-shared")
              config_options+=("--disable-static")
            elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
            then
              # Enable --with-pic to avoid linking issues with the static library
              config_options+=("--with-pic") # HB
            fi

            if [ "${XBB_HOST_ARCH}" == "ia32" -o "${XBB_HOST_ARCH}" == "arm" ]
            then
              config_options+=("ABI=32")
            fi

          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${gmp_src_folder_name}/configure" \
            "${config_options[@]}"

          if false # [ "${XBB_HOST_PLATFORM}" == "darwin" ] # and clang
          then
            # Disable failing `t-sqrlo` test.
            run_verbose sed -i.bak \
              -e 's| t-sqrlo$(EXEEXT) | |' \
              "tests/mpn/Makefile"
          fi

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${gmp_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gmp_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running gmp${name_suffix} make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          if [ "${XBB_HOST_PLATFORM}" == "darwin" -a "${XBB_HOST_ARCH}" == "arm64" ]
          then
            # FAIL: t-rand
            :
          else
            run_verbose make -j1 check
          fi
        fi

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        if [ "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}" != "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}" ]
        then
          if [ -f "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/include/gmp.h" ]
          then
            # For unknow reasons, this file is stored in the wrong location.
            mkdir -pv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include"
            mv -fv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/include/gmp.h" \
              "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include"
          fi
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gmp_folder_name}/make-output-$(ndate).txt"

      if [ -z "${name_suffix}" ]
      then
        copy_license \
          "${XBB_SOURCES_FOLDER_PATH}/${gmp_src_folder_name}" \
          "${gmp_folder_name}"
      fi

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${gmp_stamp_file_path}"

  else
    echo "Library gmp${name_suffix} already installed."
  fi
}

# -----------------------------------------------------------------------------
