# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://sourceforge.net/projects/libusb/files/libusb-compat-0.1/

# 2013-05-21, 0.1.5
# 2022-11-18, 0.1.8

# Required by GNU/Linux and macOS.

# -----------------------------------------------------------------------------

function libusb0_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local libusb0_version="$1"

  local libusb0_src_folder_name="libusb-compat-${libusb0_version}"

  local libusb0_archive="${libusb0_src_folder_name}.tar.bz2"
  local libusb0_url="https://sourceforge.net/projects/libusb/files/libusb-compat-0.1/${libusb0_src_folder_name}/${libusb0_archive}"

  local libusb0_folder_name="${libusb0_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libusb0_folder_name}"

  local libusb0_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-libusb0-${libusb0_version}-installed"
  if [ ! -f "${libusb0_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libusb0_url}" "${libusb0_archive}" \
      "${libusb0_src_folder_name}"

    (
      if [ ! -x "${XBB_SOURCES_FOLDER_PATH}/${libusb0_src_folder_name}/configure" ]
      then

        run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}/${libusb0_src_folder_name}"

        xbb_activate_dependencies_dev

        run_verbose bash ${DEBUG} "bootstrap.sh"

      fi
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libusb0_folder_name}/bootstrap-output-$(ndate).txt"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libusb0_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${libusb0_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"

      xbb_adjust_ldflags_rpath

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then

        (
          xbb_show_env_develop

          echo
          echo "Running libusb0 configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libusb0_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${libusb0_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libusb0_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libusb0_folder_name}/configure-output-$(ndate).txt"

      fi

      (
        echo
        echo "Running libusb0 make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if with_strip
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libusb0_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libusb0_src_folder_name}" \
        "${libusb0_folder_name}"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libusb0_stamp_file_path}"

  else
    echo "Library libusb0 already installed"
  fi
}

# -----------------------------------------------------------------------------
