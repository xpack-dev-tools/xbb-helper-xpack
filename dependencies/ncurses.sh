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

# https://ftp.gnu.org/gnu/ncurses/
# https://ftp.gnu.org/gnu/ncurses/ncurses-6.3.tar.gz

# https://invisible-island.net/ncurses/
# https://invisible-mirror.net/archives/ncurses/
# https://invisible-mirror.net/archives/ncurses/ncurses-6.2.tar.gz

# depends=(glibc gcc-libs)
# https://gitlab.archlinux.org/archlinux/packaging/packages/ncurses/-/blob/main/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/ncurses/files/PKGBUILD
# https://deb.debian.org/debian/pool/main/n/ncurses/ncurses_6.1+20181013.orig.tar.gz.asc

# https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-ncurses/PKGBUILD
# https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-ncurses/001-use-libsystre.patch
# https://github.com/msys2/MSYS2-packages/blob/master/ncurses/PKGBUILD

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/n/ncurses.rb

# _4421.c:1364:15: error: expected ‘)’ before ‘int’
# ../include/curses.h:1906:56: note: in definition of macro ‘mouse_trafo’
# 1906 | #define mouse_trafo(y,x,to_screen) wmouse_trafo(stdscr,y,x,to_screen)

# 26 Feb 2011, "5.8" # build fails
# 27 Jan 2018, "5.9" # build fails
# 27 Jan 2018, "6.1"
# 12 Feb 2020, "6.2"
# 2021-11-08, "6.3"

# Could not make it work on Windows.

# -----------------------------------------------------------------------------

function ncurses_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local ncurses_version="$1"
  local ncurses_version_major=$(xbb_get_version_major "${ncurses_version}")
  local ncurses_version_minor=$(xbb_get_version_minor "${ncurses_version}")

  # The folder name as resulted after being extracted from the archive.
  local ncurses_src_folder_name="ncurses-${ncurses_version}"

  local ncurses_archive="${ncurses_src_folder_name}.tar.gz"
  # local ncurses_url="https://invisible-mirror.net/archives/ncurses/${ncurses_archive}"
  local ncurses_url="https://ftp.gnu.org/gnu/ncurses/${ncurses_archive}"

  # The folder name  for build, licenses, etc.
  local ncurses_folder_name="${ncurses_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${ncurses_folder_name}"

  local ncurses_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${ncurses_folder_name}-installed"
  if [ ! -f "${ncurses_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${ncurses_url}" "${ncurses_archive}" \
      "${ncurses_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${ncurses_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${ncurses_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ "${XBB_HOST_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -ldl"
      fi

      xbb_adjust_ldflags_rpath

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      XBB_NCURSES_DISABLE_WIDEC=${XBB_NCURSES_DISABLE_WIDEC:-""}

      if [ ! -f "config.status" ]
      then
        (
          # 6.3 fails with
          # configure: error: expected a pathname, not ""
          export PKG_CONFIG_LIBDIR="no"

          xbb_show_env_develop

          echo
          echo "Running ncurses configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${ncurses_src_folder_name}/configure" --help
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

          config_options+=("--program-prefix=")

          # Not yet functional on windows.
          if [ "${XBB_HOST_PLATFORM}" == "win32" ]
          then

            # The build passes, but generally it is not expected to be
            # used on Windows.

            # export PATH_SEPARATOR=";"

            # --with-libtool \
            # /opt/xbb/bin/libtool: line 10548: gcc-8bs: command not found

            # Without --with-pkg-config-libdir= it'll try to write the .pc files in the
            # xbb folder, probbaly by using the dirname of pkg-config.

            config_options+=("--with-build-cc=${XBB_NATIVE_CC}")
            config_options+=("--with-build-cflags=${CFLAGS}")
            config_options+=("--with-build-cppflags=${CPPFLAGS}")
            config_options+=("--with-build-ldflags=${LDFLAGS}")

            config_options+=("--without-progs")

            # Only for the MinGW port, it provides a way to substitute
            # the low-level terminfo library with different terminal drivers.
            config_options+=("--enable-term-driver")

            config_options+=("--disable-termcap")
            config_options+=("--disable-home-terminfo")
            config_options+=("--disable-db-install")

          else

            # Without --with-pkg-config-libdir= it'll try to write the .pc files in the
            # xbb folder, probbaly by using the dirname of pkg-config.

            config_options+=("--with-terminfo-dirs=/etc/terminfo")
            config_options+=("--with-default-terminfo-dir=/etc/terminfo:/lib/terminfo:/usr/share/terminfo")
            config_options+=("--with-gpm")
            config_options+=("--with-versioned-syms") # Arch
            config_options+=("--with-xterm-kbs=del")

            config_options+=("--enable-termcap")
            config_options+=("--enable-const")
            config_options+=("--enable-symlinks") # HB

            config_options+=("--enable-sigwinch") # HB

          fi

          config_options+=("--with-shared") # HB, Arch
          config_options+=("--with-normal")
          config_options+=("--with-cxx")
          config_options+=("--with-cxx-binding") # Arch
          config_options+=("--with-cxx-shared") # HB
          config_options+=("--with-pkg-config-libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/pkgconfig")

          # Fails on Linux, with missing _nc_cur_term, which is there.
          config_options+=("--without-pthread")

          config_options+=("--without-ada") # HB, Arch
          config_options+=("--without-debug")
          config_options+=("--without-manpages")
          config_options+=("--without-tack")
          config_options+=("--without-tests")

          config_options+=("--enable-pc-files") # HB, Arch
          config_options+=("--enable-sp-funcs")
          config_options+=("--enable-ext-colors")
          config_options+=("--enable-interop")

          # Do not use, it disables the wide libraries.
          # config_options+=("--disable-lib-suffixes")

          # config_options+=("--disable-overwrite")

          # /bin/bash ./run_tic.sh
          # Building terminfo database, please wait...
          # mkdir: cannot create directory '/etc/terminfo:': Permission denied
          # Running sh /home/ilg/Work/xpack-dev-tools/qemu-arm-xpack.git/build/linux-x64/sources/ncurses-6.3/misc/shlib tic to install /etc/terminfo:/lib/terminfo:/usr/share/terminfo ...

          config_options+=("--disable-db-install")

          if [ "${XBB_NCURSES_DISABLE_WIDEC}" == "y" ]
          then
            config_options+=("--disable-widec")
          else
            config_options+=("--enable-widec")
          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${ncurses_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${ncurses_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${ncurses_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running ncurses make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        # The test-programs are interactive

        # Has no install-strip
        run_verbose make install

        # Expose the library to pkg_config also as `curses`.
        if [ -f "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/pkgconfig/ncurses.pc" ]
        then
          cat "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/pkgconfig/ncurses.pc" | \
            sed -e 's|Name: ncurses|Name: curses|' \
            > "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/pkgconfig/curses.pc"
        fi

        if [ -f "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/pkgconfig/ncurses++.pc" ]
        then
          cat "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/pkgconfig/ncurses++.pc" | \
            sed -e 's|Name: ncurses++|Name: curses++|' \
            > "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/pkgconfig/curses++.pc"
        fi

        if [ -f "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libncurses.${XBB_HOST_SHLIB_EXT}" ]
        then
          ln -sfv libncurses.${XBB_HOST_SHLIB_EXT} "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libcurses.${XBB_HOST_SHLIB_EXT}"
        fi

        if [ -f "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libncurses.a" ]
        then
          ln -sfv libncurses.a "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libcurses.a"
        fi

        if [ -f "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libncurses++.${XBB_HOST_SHLIB_EXT}" ]
        then
          ln -sfv libncurses++.${XBB_HOST_SHLIB_EXT} "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libcurses++.${XBB_HOST_SHLIB_EXT}"
        fi

        if [ -f "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libncurses++.a" ]
        then
          ln -sfv libncurses++.a "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libcurses++.a"
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${ncurses_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${ncurses_src_folder_name}" \
        "${ncurses_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${ncurses_stamp_file_path}"

  else
    echo "Library ncurses already installed"
  fi
}

# -----------------------------------------------------------------------------
