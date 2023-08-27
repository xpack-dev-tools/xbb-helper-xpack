# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.xmlsoft.org
# ftp://xmlsoft.org/libxml2/
# https://download.gnome.org/sources/libxml2
# https://download.gnome.org/sources/libxml2/2.9/libxml2-2.9.14.tar.xz

# https://gitlab.gnome.org/GNOME/libxml2/-/releases
# https://gitlab.gnome.org/GNOME/libxml2/-/archive/v2.9.14/libxml2-v2.9.14.tar.bz2

# https://github.com/archlinux/svntogit-packages/blob/packages/libxml2/trunk/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/libxml2/files/PKGBUILD
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libxml2-git
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-libxml2

# https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-libxml2/PKGBUILD
# https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-readline/PKGBUILD

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/l/libxml2.rb

# Mar 05 2018, "2.9.8"
# Jan 03 2019, "2.9.9"
# Oct 30 2019, "2.9.10"
# May 13 2021, "2.9.11"
# May 2, 2022, "2.9.14"
# Aug 29, 2022, "2.10.2"
# 2023-Aug-09, "2.11.5"

# -----------------------------------------------------------------------------

function libxml2_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local libxml2_version="$1"
  local libxml2_version_major=$(xbb_get_version_major "${libxml2_version}")
  local libxml2_version_minor=$(xbb_get_version_minor "${libxml2_version}")
  local libxml2_version_major_minor="${libxml2_version_major}.${libxml2_version_minor}"

  local libxml2_src_folder_name="libxml2-${libxml2_version}"

  local libxml2_archive="${libxml2_src_folder_name}.tar.xz"
  # local libxml2_url="ftp://xmlsoft.org/libxml2/${libxml2_archive}"
  local libxml2_url="https://download.gnome.org/sources/libxml2/${libxml2_version_major_minor}/${libxml2_archive}"

  local libxml2_folder_name="${libxml2_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libxml2_folder_name}"

  local libxml2_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-libxml2-${libxml2_version}-installed"
  if [ ! -f "${libxml2_stamp_file_path}" ]
  then

    echo
    echo "libxml2 in-source building..."

    mkdir -pv "${XBB_BUILD_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}"

    if [ ! -d "${XBB_BUILD_FOLDER_PATH}/${libxml2_folder_name}" ]
    then
      download_and_extract "${libxml2_url}" "${libxml2_archive}" \
        "${libxml2_src_folder_name}"

      if [ "${libxml2_src_folder_name}" != "${libxml2_folder_name}" ]
      then
        mv -v "${libxml2_src_folder_name}" "${libxml2_folder_name}"
      fi
    fi

    (
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${libxml2_folder_name}"
      if [ ! -f "stamp-autoreconf" ]
      then
        run_verbose autoreconf -vfi

        touch "stamp-autoreconf"
      fi
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libxml2_folder_name}/autoreconf-output-$(ndate).txt"

    (
      # /lib added due to wrong -Llib used during make.
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libxml2_folder_name}/lib"

      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${libxml2_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ "${XBB_HOST_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -liconv"
      fi

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
          echo "Running libxml2 configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "configure" --help
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

          config_options+=("--without-python") # HB
          # config_options+=("--with-python=/usr/bin/python") # Arch

          # config_options+=("--without-lzma") # HB

          # config_options+=("--with-history") # Arch
          config_options+=("--with-iconv")
          config_options+=("--with-icu") # Arch

          # config_options+=("--disable-static") # Arch

          if [ "${XBB_HOST_PLATFORM}" == "win32" ]
          then
            config_options+=("--with-threads=win32")
            config_options+=("--without-catalog")
            config_options+=("--disable-shared")
          fi

          run_verbose bash ${DEBUG} "configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libxml2_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libxml2_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running libxml2 make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libxml2_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_BUILD_FOLDER_PATH}/${libxml2_src_folder_name}" \
        "${libxml2_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libxml2_stamp_file_path}"

  else
    echo "Library libxml2 already installed"
  fi
}

# -----------------------------------------------------------------------------
