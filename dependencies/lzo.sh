# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# Real-time data compression library
# https://www.oberhumer.com/opensource/lzo/
# https://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz

# https://github.com/archlinux/svntogit-packages/blob/packages/lzo/trunk/PKGBUILD

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/lzo.rb

# 01 Mar 2017 "2.10"

# -----------------------------------------------------------------------------

function lzo_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local lzo_version="$1"

  local lzo_src_folder_name="lzo-${lzo_version}"

  local lzo_archive="${lzo_src_folder_name}.tar.gz"
  local lzo_url="https://www.oberhumer.com/opensource/lzo/download/${lzo_archive}"

  local lzo_folder_name="${lzo_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${lzo_folder_name}"

  local lzo_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${lzo_folder_name}-installed"
  if [ ! -f "${lzo_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${lzo_url}" "${lzo_archive}" \
      "${lzo_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${lzo_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${lzo_folder_name}"

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
          echo "Running lzo configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${lzo_src_folder_name}/configure" --help
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

          config_options+=("--disable-dependency-tracking")
          config_options+=("--enable-shared")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${lzo_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${lzo_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${lzo_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running lzo make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${lzo_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${lzo_src_folder_name}" \
        "${lzo_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${lzo_stamp_file_path}"

  else
    echo "Library lzo already installed"
  fi
}

# -----------------------------------------------------------------------------
