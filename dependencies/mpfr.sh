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

# https://www.mpfr.org
# https://www.mpfr.org/history.html

# https://gitlab.archlinux.org/archlinux/packaging/packages/mpfr/-/blob/main/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/mpfr/files/PKGBUILD

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/m/mpfr.rb

# 6 March 2016 "3.1.4"
# 7 September 2017 "3.1.6"
# 31 January 2019 "4.0.2"
# 10 July 2020 "4.1.0"

# Depends on gmp.

# -----------------------------------------------------------------------------

function mpfr_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local mpfr_version="$1"
  local mpfr_version_major=$(xbb_get_version_major "${mpfr_version}")

  # The folder name as resulted after being extracted from the archive.
  local mpfr_src_folder_name="mpfr-${mpfr_version}"

  local mpfr_archive="${mpfr_src_folder_name}.tar.xz"
  local mpfr_url="https://www.mpfr.org/${mpfr_src_folder_name}/${mpfr_archive}"

  # The folder name for build, licenses, etc.
  local mpfr_folder_name="${mpfr_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${mpfr_folder_name}"

  local mpfr_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${mpfr_folder_name}-installed"
  if [ ! -f "${mpfr_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${mpfr_url}" "${mpfr_archive}" \
      "${mpfr_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${mpfr_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${mpfr_folder_name}"

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
          echo "Running mpfr configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${mpfr_src_folder_name}/configure" --help
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

          config_options+=("--with-gmp=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          config_options+=("--enable-shared") # Arch
          config_options+=("--enable-thread-safe") # Arch

          config_options+=("--disable-maintainer-mode")
          config_options+=("--disable-warnings")

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if is_development
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${mpfr_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${mpfr_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${mpfr_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running mpfr make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check # Arch
          if [ ${mpfr_version_major} -ge 4 ]
          then
            run_verbose make -j1 check-exported-symbols # Arch
          fi
        fi

        if with_strip
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${mpfr_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${mpfr_src_folder_name}" \
        "${mpfr_folder_name}"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${mpfr_stamp_file_path}"

  else
    echo "Library mpfr already installed"
  fi
}

# -----------------------------------------------------------------------------
