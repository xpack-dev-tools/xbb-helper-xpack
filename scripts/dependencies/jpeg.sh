
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# See also
# https://archlinuxarm.org/packages/aarch64/libjpeg-turbo/files/PKGBUILD

function build_jpeg()
{
  # http://www.ijg.org
  # http://www.ijg.org/files/

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libjpeg9

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/jpeg.rb

  # Jan 19 10:26 2014 "9a"
  # Jan 17 10:46 2016 "9b"
  # Jan 14 10:10 2018 "9c"
  # Jan 12 10:07 2020 "9d"
  # Jan 16 10:12 2022 "9e"

  local jpeg_version="$1"

  local jpeg_src_folder_name="jpeg-${jpeg_version}"

  local jpeg_archive="jpegsrc.v${jpeg_version}.tar.gz"
  local jpeg_url="http://www.ijg.org/files/${jpeg_archive}"

  local jpeg_folder_name="${jpeg_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${jpeg_folder_name}"

  local jpeg_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-jpeg-${jpeg_version}-installed"
  if [ ! -f "${jpeg_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${jpeg_url}" "${jpeg_archive}" \
        "${jpeg_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${jpeg_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${jpeg_folder_name}"

      xbb_activate_installed_dev

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
          echo "Running jpeg configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${jpeg_src_folder_name}/configure" --help
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

          # --enable-shared needed by sdl2_image on CentOS 64-bit and Ubuntu.
          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${jpeg_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${jpeg_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${jpeg_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running jpeg make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${jpeg_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${jpeg_src_folder_name}" \
        "${jpeg_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${jpeg_stamp_file_path}"

  else
    echo "Library jpeg already installed."
  fi
}

# -----------------------------------------------------------------------------
