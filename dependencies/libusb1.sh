# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://sourceforge.net/projects/libusb/files/libusb-1.0/
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-libusb

# 2015-09-14, 1.0.20
# 2018-03-25, 1.0.22
# 2020-12-11, 1.0.24
# 2022-04-10, "1.0.26"

# -----------------------------------------------------------------------------

function libusb1_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local libusb1_version="$1"

  local libusb1_src_folder_name="libusb-${libusb1_version}"

  local libusb1_archive="${libusb1_src_folder_name}.tar.bz2"
  local libusb1_url="https://sourceforge.net/projects/libusb/files/libusb-1.0/${libusb1_src_folder_name}/${libusb1_archive}"

  local libusb1_folder_name="${libusb1_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libusb1_folder_name}"

  local libusb1_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-libusb1-${libusb1_version}-installed"
  if [ ! -f "${libusb1_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libusb1_url}" "${libusb1_archive}" \
      "${libusb1_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libusb1_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${libusb1_folder_name}"

      xbb_activate_dependencies_dev

      # GCC-7 fails to compile Darwin USB.h:
      # error: too many #pragma options align=reset

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"

      xbb_adjust_ldflags_rpath

      # if [ "${XBB_HOST_PLATFORM}" == "linux" ]
      # then
      #   # undefined reference to `clock_gettime' on docker
      #   export LIBS="-lrt -lpthread"
      # fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then

        (
          xbb_show_env_develop

          echo
          echo "Running libusb1 configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libusb1_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${libusb1_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libusb1_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libusb1_folder_name}/configure-output-$(ndate).txt"

      fi

      (
        echo
        echo "Running libusb1 make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if with_strip
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        # The .la file is broken, it includes a bad reference to libatomic.la.
        run_verbose rm -v -f "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libusb-1.0.la"

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libusb1_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libusb1_src_folder_name}" \
        "${libusb1_folder_name}"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libusb1_stamp_file_path}"

  else
    echo "Library libusb1 already installed"
  fi
}

# -----------------------------------------------------------------------------
