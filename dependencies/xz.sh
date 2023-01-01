#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://tukaani.org/xz/
# https://sourceforge.net/projects/lzmautils/files/

# https://archlinuxarm.org/packages/aarch64/xz/files/PKGBUILD
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=xz-git

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/xz.rb

# 2016-12-30 "5.2.3"
# 2018-04-29 "5.2.4"
# 2020-03-17 "5.2.5"
# 2022-08-12 "5.2.6"

# -----------------------------------------------------------------------------

function xz_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local xz_version="$1"

  local xz_src_folder_name="xz-${xz_version}"
  local xz_archive="${xz_src_folder_name}.tar.xz"
  local xz_url="https://sourceforge.net/projects/lzmautils/files/${xz_archive}"

  local xz_folder_name="${xz_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${xz_folder_name}"

  local xz_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${xz_folder_name}-installed"
  if [ ! -f "${xz_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${xz_url}" "${xz_archive}" \
      "${xz_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${xz_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${xz_folder_name}"

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
          echo "Running xz configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${xz_src_folder_name}/configure" --help
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

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--disable-nls")

          # config_options+=("--enable-werror") # Arch
          config_options+=("--disable-werror")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${xz_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${xz_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${xz_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running xz make..."

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

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${xz_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${xz_src_folder_name}" \
        "${xz_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${xz_stamp_file_path}"

  else
    echo "Library xz already installed"
  fi
}

# -----------------------------------------------------------------------------
