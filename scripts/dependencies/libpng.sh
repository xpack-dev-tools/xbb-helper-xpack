# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function build_libpng()
{
  # To ensure builds stability, use slightly older releases.
  # https://sourceforge.net/projects/libpng/files/libpng16/
  # https://sourceforge.net/projects/libpng/files/libpng16/older-releases/

  # https://github.com/archlinux/svntogit-packages/blob/packages/libpng/trunk/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/libpng/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libpng-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-libpng

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/libpng.rb

  # libpng_version="1.2.53"
  # libpng_version="1.6.17"
  # libpng_version="1.6.23" # 2016-06-09
  # libpng_version="1.6.36" # 2018-12-01
  # 2019-04-15, "1.6.37"
  # libpng_SFOLDER="libpng12"
  # libpng_SFOLDER="libpng16"
  # 2022-09-16, "1.6.38"

  local libpng_version="$1"
  local libpng_major_minor_version="$(echo ${libpng_version} | sed -e 's|\([0-9][0-9]*\)\.\([0-9][0-9]*\)\.[0-9].*|\1\2|')"

  local libpng_src_folder_name="libpng-${libpng_version}"

  local libpng_archive="${libpng_src_folder_name}.tar.xz"
  # local libpng_url="https://sourceforge.net/projects/libpng/files/${libpng_SFOLDER}/older-releases/${libpng_version}/${libpng_archive}"
  local libpng_url="https://sourceforge.net/projects/libpng/files/libpng${libpng_major_minor_version}/${libpng_version}/${libpng_archive}"

  local libpng_folder_name="${libpng_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libpng_folder_name}"

  local libpng_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-libpng-${libpng_version}-installed"
  if [ ! -f "${libpng_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libpng_url}" "${libpng_archive}" \
      "${libpng_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libpng_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${libpng_folder_name}"

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
          echo "Running libpng configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libpng_src_folder_name}/configure" --help
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

          # config_options+=("--disable-static")
          # From Arm Arch.
          config_options+=("--enable-arm-neon=no")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${libpng_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libpng_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libpng_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running libpng make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libpng_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libpng_src_folder_name}" \
        "${libpng_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libpng_stamp_file_path}"

  else
    echo "Library libpng already installed"
  fi
}

# -----------------------------------------------------------------------------
