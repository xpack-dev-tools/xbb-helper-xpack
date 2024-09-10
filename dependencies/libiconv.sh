# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.gnu.org/software/libiconv/
# https://ftp.gnu.org/pub/gnu/libiconv/

# https://gitlab.archlinux.org/archlinux/packaging/packages/libiconv/-/blob/main/PKGBUILD
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libiconv

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/l/libiconv.rb

# 2011-08-07 1.14"
# 2017-02-02 "1.15"
# 2019-04-26 "1.16"
# 2022-05-15 "1.17"

# Note: the build fails on Ubuntu/Debian!

# -----------------------------------------------------------------------------

function libiconv_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local libiconv_version="$1"
  shift

  local disable_shared="n"
  local suffix=""
  local bits_flags=""

  while [ $# -gt 0 ]
  do
    case "$1" in
      --disable-shared )
        disable_shared="y"
        shift
        ;;

      --suffix=* )
        suffix=$(xbb_parse_option "$1")
        shift
        ;;

      --32 )
        bits_flags=" -m32"
        shift
        ;;

      --64 )
        bits_flags=" -m64"
        shift
        ;;

      * )
        echo "Unsupported argument $1 in ${FUNCNAME[0]}()"
        exit 1
        ;;
    esac
  done

  local libiconv_src_folder_name="libiconv-${libiconv_version}"

  local libiconv_archive="${libiconv_src_folder_name}.tar.gz"
  local libiconv_url="https://ftp.gnu.org/pub/gnu/libiconv/${libiconv_archive}"

  local libiconv_folder_name="${libiconv_src_folder_name}${suffix}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libiconv_folder_name}"

  local libiconv_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${libiconv_folder_name}-installed"
  if [ ! -f "${libiconv_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libiconv_url}" "${libiconv_archive}" \
      "${libiconv_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libiconv_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${libiconv_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      # -fgnu89-inline fixes "undefined reference to `aliases2_lookup'"
      #  https://savannah.gnu.org/bugs/?47953
      CFLAGS="${XBB_CFLAGS_NO_W} -fgnu89-inline ${bits_flags}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W} ${bits_flags}"

      LDFLAGS="${XBB_LDFLAGS_LIB} ${bits_flags}"

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
          echo "Running libiconv${suffix} configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libiconv_src_folder_name}/configure" --help
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
          if is_development
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--disable-nls")

          if [ "${disable_shared}" == "y" ]
          then
            config_options+=("--disable-shared")
          fi

          config_options+=("--enable-static") # HB
          config_options+=("--enable-extra-encodings") # Arch

          # Fails on macOS:
          # /bin/bash: /Users/ilg/Work/xbb-bootstrap-4.0.0/darwin-arm64/sources/libiconv-1.16/libcharset/build-aux/libtool-reloc: No such file or directory
          # config_options+=("--enable-relocatable")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${libiconv_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libiconv_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libiconv_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running libiconv${suffix} make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

        if with_strip
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libiconv_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libiconv_src_folder_name}" \
        "${libiconv_src_folder_name}"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libiconv_stamp_file_path}"

  else
    echo "Library libiconv${suffix} already installed"
  fi
}

# -----------------------------------------------------------------------------
