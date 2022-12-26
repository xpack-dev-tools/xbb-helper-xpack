# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# http://ftp.gnome.org/pub/GNOME/sources/glib

# https://github.com/archlinux/svntogit-packages/blob/packages/glib2/trunk/PKGBUILD
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=glib2-git
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-glib2

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/glib.rb

# https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-glib2/PKGBUILD

# 2015-May-13, "2.44.1"
# 2017-Mar-13, "2.51.5"
# 2018-Sep-21, "2.56.3"
# 2018-Dec-18, "2.56.4"
# --- Starting with 2.57, the build was migrated to meson (TODO) ---
# 2018-Aug-23, "2.57.3"
# 2019-Sep-02, "2.60.7"
# 2021-May-11, "2.68.4"
# 2021-Sep-17, "2.70.0"
# 2021-Dec-03, "2.70.2"
# 2022-Apr-14, "2.72.1"
# 2022-Aug-05, "2.73.3"
# 2022-Oct-25, "2.74.1"

# -----------------------------------------------------------------------------

function glib_build()
{
  local glib_version="$1"
  local glib_major_version=$(echo ${glib_version} | sed -e 's|\([0-9][0-9]*\)\.\([0-9][0-9]*\)\.[0-9].*|\1|')
  local glib_minor_version=$(echo ${glib_version} | sed -e 's|\([0-9][0-9]*\)\.\([0-9][0-9]*\)\.[0-9].*|\2|')
  local glib_major_minor_version="$(echo ${glib_version} | sed -e 's|\([0-9][0-9]*\)\.\([0-9][0-9]*\)\.[0-9].*|\1.\2|')"

  local glib_src_folder_name="glib-${glib_version}"

  local glib_archive="${glib_src_folder_name}.tar.xz"

  local glib_url="http://ftp.gnome.org/pub/GNOME/sources/glib/${glib_major_minor_version}/${glib_archive}"

  local glib_folder_name="${glib_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${glib_folder_name}"

  local glib_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-glib-${glib_version}-installed"
  if [ ! -f "${glib_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    if [ ! -d "${glib_src_folder_name}" ]
    then
      download_and_extract "${glib_url}" "${glib_archive}" \
        "${glib_src_folder_name}"

      # When resolving the path to python, meson gets confused and
      # returns the path to itself; thus make the path explicit.
      which python3
      which_python=$(which python3)
      run_verbose sed -i.bak \
        -e "s|python = import('python').find_installation()|python = import('python').find_installation('${which_python}')|"   \
        "${glib_src_folder_name}/meson.build"

      diff "${glib_src_folder_name}/meson.build.bak" "${glib_src_folder_name}/meson.build" || true

      # When invoking python scripts, meson gets confused and
      # tries to use itself; thus invoke python explicitly.
      run_verbose sed -i.bak \
        -e "s|command: \[gengiotypefuncs_prog, '@OUTPUT@', '@INPUT@'\])|command: [find_program('python3'), gengiotypefuncs_prog.full_path(), '@OUTPUT@', '@INPUT@'])|" \
        "${glib_src_folder_name}/gio/tests/meson.build"

      diff "${glib_src_folder_name}/gio/tests/meson.build.bak" "${glib_src_folder_name}/gio/tests/meson.build" || true
    fi

    (
      # Hack, /gio/lib added because libtool needs it on Win32.
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${glib_folder_name}"/gio/lib
      cd "${XBB_BUILD_FOLDER_PATH}/${glib_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      LIBS=""

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      xbb_adjust_ldflags_rpath

      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        LDFLAGS+=" -Wl,--allow-multiple-definition"
      fi

      if [ "${XBB_HOST_PLATFORM}" == "linux" -o  "${XBB_HOST_PLATFORM}" == "darwin" ]
      then
        LDFLAGS+=" -liconv"
        # LIBS="-liconv"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS
      export LIBS

      if [ ${glib_major_version} -eq 2 -a ${glib_minor_version} -le 56 ]
      then
        # Up to 2.56 use the old configure.
        if [ ! -f "config.status" ]
        then
          (
            xbb_show_env_develop

            echo
            echo "Running glib configure..."

            if [ "${XBB_IS_DEVELOP}" == "y" ]
            then
              run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${glib_src_folder_name}/configure" --help
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

            # --with-libiconv=gnu required on Linux
            config_options+=("--with-libiconv=gnu")
            config_options+=("--without-pcre")

            config_options+=("--disable-selinux")
            config_options+=("--disable-fam")
            config_options+=("--disable-xattr")
            config_options+=("--disable-libelf")
            config_options+=("--disable-libmount")
            config_options+=("--disable-dtrace")
            config_options+=("--disable-systemtap")
            config_options+=("--disable-coverage")
            config_options+=("--disable-Bsymbolic")
            config_options+=("--disable-znodelete")
            config_options+=("--disable-compile-warnings")
            config_options+=("--disable-installed-tests")
            config_options+=("--disable-always-build-tests")

            run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${glib_src_folder_name}/configure" \
              "${config_options[@]}"

            # Disable SPLICE, it fails on CentOS.
            local sed_path=$(which gsed || whioch sed || echo sed)
            run_verbose "${sed_path}" -i -e '/#define HAVE_SPLICE 1/d' config.h

            cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${glib_folder_name}/config-log-$(ndate).txt"
          ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${glib_folder_name}/configure-output-$(ndate).txt"
        fi

        (
          echo
          echo "Running glib make..."

          # Build.
          run_verbose make -j ${XBB_JOBS}

          if [ "${XBB_WITH_STRIP}" == "y" ]
          then
            run_verbose make install-strip
          else
            run_verbose make install
          fi

        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${glib_folder_name}/make-output-$(ndate).txt"
      else
        if [ ! -f "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/${glib_folder_name}/build.ninja" ]
        then
          (
            xbb_show_env_develop

            echo
            echo "Running glib meson setup..."

            cd "${XBB_SOURCES_FOLDER_PATH}/${glib_src_folder_name}"

            # https://mesonbuild.com/Commands.html#setup
            config_options=()

            config_options+=("--prefix" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")
            config_options+=("--includedir" "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
            config_options+=("--libdir" "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
            config_options+=("--backend" "ninja")

            if [ "${XBB_HOST_PLATFORM}" == "win32" ]
            then
              config_options+=("--cross" "${helper_folder_path}/extras/meson/mingw-w64-gcc.ini")
            fi

            run_verbose meson setup \
              "${config_options[@]}" \
              "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/${glib_folder_name}"

          ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${glib_folder_name}/meson-setup-output-$(ndate).txt"
        fi

        (
          echo
          echo "Running glib meson compile..."

          # Build.
          run_verbose meson compile -C "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/${glib_folder_name}"

          run_verbose meson install -C "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/${glib_folder_name}"

        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${glib_folder_name}/meson-compile-output-$(ndate).txt"

        # exit 1
      fi

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${glib_src_folder_name}" \
        "${glib_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${glib_stamp_file_path}"

  else
    echo "Library glib already installed"
  fi
}

# -----------------------------------------------------------------------------

