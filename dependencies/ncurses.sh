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
# 2022-12-31, "6.4"

# Could not make it work on Windows.

# -----------------------------------------------------------------------------

function ncurses_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local ncurses_version="$1"
  shift

  local disable_widec="${XBB_NCURSES_DISABLE_WIDEC:-""}"
  local enable_lib_suffixes="n"
  local with_termlib=""
  local hack_links=""

  while [ $# -gt 0 ]
  do
    case "$1" in
      --disable-widec )
        disable_widec="y"
        shift
        ;;

      --enable-lib-suffixes )
        enable_lib_suffixes="y"
        shift
        ;;

      # absolute "/usr/lib/libncurses.5.4.dylib" not one of the allowed libs
      --disable-lib-suffixes )
        enable_lib_suffixes="n"
        shift
        ;;

      --with-termlib )
        with_termlib="y"
        shift
        ;;

      --hack-links )
        hack_links="y"
        shift
        ;;

      * )
        echo "Unsupported argument $1 in ${FUNCNAME[0]}()"
        exit 1
        ;;
    esac
  done

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

      xbb_adjust_ldflags_rpath

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          # 6.3 fails with
          # configure: error: expected a pathname, not ""
          export PKG_CONFIG_LIBDIR="no"

          xbb_show_env_develop

          echo
          echo "Running ncurses configure..."

          if is_development
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
            config_options+=("--with-build-cflags=${CFLAGS} -D_XOPEN_SOURCE_EXTENDED")
            config_options+=("--with-build-cppflags=${CPPFLAGS}")
            config_options+=("--with-build-ldflags=${LDFLAGS}")

            config_options+=("--with-ticlib") # msys2

            config_options+=("--without-progs")
            config_options+=("--without-termlib") # msys2

            # Only for the MinGW port, it provides a way to substitute
            # the low-level terminfo library with different terminal drivers.
            config_options+=("--enable-term-driver")
            # config_options+=("--disable-term-driver") # msys2
            
            config_options+=("--enable-sigwinch") # msys2

            config_options+=("--disable-termcap") # msys2
            config_options+=("--disable-home-terminfo")
            config_options+=("--disable-db-install")

            config_options+=("--disable-relink") # msys2
            config_options+=("--disable-mixed-case") # msys2

          else

            # Without --with-pkg-config-libdir= it'll try to write the .pc files in the
            # xbb folder, probbaly by using the dirname of pkg-config.

            config_options+=("--with-terminfo-dirs=/etc/terminfo")
            config_options+=("--with-default-terminfo-dir=/etc/terminfo:/lib/terminfo:/usr/share/terminfo")
            config_options+=("--with-gpm")

            # libform.so: undefined reference to `_nc_wcrtomb'
            # config_options+=("--with-versioned-syms") # Arch

            config_options+=("--with-xterm-kbs=del") # Arch

            config_options+=("--disable-root-access") # Arch
            config_options+=("--disable-root-environ") # Arch
            config_options+=("--disable-setuid-environ") # Arch

            config_options+=("--enable-termcap")
            config_options+=("--enable-const")
            config_options+=("--enable-symlinks") # HB

            config_options+=("--enable-sigwinch") # HB
            config_options+=("--enable-pc-files")

            if [ "${with_termlib}" == "y" ]
            then
              # To create the tinfo library, that defines the `UP` symbol
              # referred by readline when included by python 3.12.
              # libreadline.so.7: undefined symbol: UP
              # https://stackoverflow.com/a/68556326/3073330
              config_options+=("--with-termlib")
            fi

          fi

          config_options+=("--with-shared") # HB, Arch
          config_options+=("--with-normal")
          config_options+=("--with-cxx")
          config_options+=("--with-cxx-binding") # Arch
          config_options+=("--with-cxx-shared") # Arch, HB
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

          # config_options+=("--disable-overwrite")
          config_options+=("--enable-overwrite")

          # /bin/bash ./run_tic.sh
          # Building terminfo database, please wait...
          # mkdir: cannot create directory '/etc/terminfo:': Permission denied
          # Running sh /home/ilg/Work/xpack-dev-tools/qemu-arm-xpack.git/build/linux-x64/sources/ncurses-6.3/misc/shlib tic to install /etc/terminfo:/lib/terminfo:/usr/share/terminfo ...

          config_options+=("--disable-db-install")

          if [ "${disable_widec}" == "y" ]
          then
            config_options+=("--disable-widec")
          else
            config_options+=("--enable-widec") # Arch

            if [ "${enable_lib_suffixes}" == "y" ]
            then
              config_options+=("--enable-lib-suffixes")
            else
              # Suppress the "w", "t" or "tw" suffixes which normally would be added
              # to the library names for the wide/pthread variants.
              config_options+=("--disable-lib-suffixes")
            fi
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

        # ---------------------------------------------------------------------

        if [ "${hack_links}" == "y" ] &&
           [ "${disable_widec}" != "y" ] &&
           [ "${enable_lib_suffixes}" == "y" ]
        then
          echo
          echo "Creating links as wide..."

          # Fool packages looking to link to wide-character ncurses libraries
          if [ ! -d "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/ncursesw" ] &&
             [ -d "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/ncurses" ]
          then
            ln -sfv ncurses "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/ncursesw"
          fi

          for lib in ncurses ncurses++ form panel menu tinfo
          do
            if [ ! -f "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/lib${lib}w.${XBB_HOST_SHLIB_EXT}" ] &&
               [ -f "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/lib${lib}.${XBB_HOST_SHLIB_EXT}" ]
            then
              ln -sfv lib${lib}.${XBB_HOST_SHLIB_EXT} "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/lib${lib}w.${XBB_HOST_SHLIB_EXT}"
            fi

            if [ ! -f "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/lib${lib}w.a" ] &&
               [ -f "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/lib${lib}.a" ]
            then
              ln -sfv lib${lib}.a "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/lib${lib}w.a"
            fi

            # ln -sv ${lib}.pc "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/pkgconfig/${lib}w.pc"
            if [ ! -f "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/pkgconfig/${lib}w.pc" ] &&
               [ -f "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/pkgconfig/${lib}.pc" ]
            then
              cat "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/pkgconfig/${lib}.pc" | \
                sed \
                  -e "s|Name: ${lib}|Name: ${lib}w|" \
                  -e "s|-l${lib}|-l${lib}w|" \
                > "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/pkgconfig/${lib}w.pc"
            fi
          done
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
