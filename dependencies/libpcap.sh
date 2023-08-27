# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# Portable library for network traffic capture
# https://www.tcpdump.org/
# https://www.tcpdump.org/release/
# https://www.tcpdump.org/release/libpcap-1.10.1.tar.gz

# https://github.com/archlinux/svntogit-packages/blob/packages/libpcap/trunk/PKGBUILD

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/l/libpcap.rb

# June 9, 2021 "1.10.1"

# -----------------------------------------------------------------------------

function libpcap_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local libpcap_version="$1"

  local libpcap_src_folder_name="libpcap-${libpcap_version}"

  local libpcap_archive="${libpcap_src_folder_name}.tar.gz"
  local libpcap_url="https://www.tcpdump.org/release/${libpcap_archive}"

  local libpcap_folder_name="${libpcap_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libpcap_folder_name}"

  local libpcap_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${libpcap_folder_name}-installed"
  if [ ! -f "${libpcap_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libpcap_url}" "${libpcap_archive}" \
      "${libpcap_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libpcap_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${libpcap_folder_name}"

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
          echo "Running libpcap configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libpcap_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          # HomeBrew
          config_options+=("--disable-universal")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${libpcap_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libpcap_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libpcap_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running libpcap make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        run_verbose make install

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libpcap_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libpcap_src_folder_name}" \
        "${libpcap_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libpcap_stamp_file_path}"

  else
    echo "Library libpcap already installed"
  fi
}

# -----------------------------------------------------------------------------
