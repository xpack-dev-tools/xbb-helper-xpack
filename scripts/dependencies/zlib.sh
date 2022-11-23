# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function build_zlib()
{
  # http://zlib.net
  # http://zlib.net/fossils/

  # https://github.com/archlinux/svntogit-packages/blob/packages/zlib/trunk/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/zlib/files/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/zlib.rb

  # 2013-04-28 "1.2.8"
  # 2017-01-15 "1.2.11"
  # 2022-03-27, "1.2.12"

  local zlib_version="$1"
  local name_suffix="${2:-""}"

  # The folder name as resulted after being extracted from the archive.
  local zlib_src_folder_name="zlib-${zlib_version}"

  local zlib_archive="${zlib_src_folder_name}.tar.gz"
  local zlib_url="http://zlib.net/fossils/${zlib_archive}"

  # The folder name for build, licenses, etc.
  local zlib_folder_name="${zlib_src_folder_name}${name_suffix}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${zlib_folder_name}"

  local zlib_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${zlib_folder_name}-installed"
  if [ ! -f "${zlib_stamp_file_path}" ]
  then

    echo
    echo "zlib${name_suffix} in-source building..."

    mkdir -pv "${XBB_BUILD_FOLDER_PATH}"
    cd "${XBB_BUILD_FOLDER_PATH}"

    if [ ! -d "${XBB_BUILD_FOLDER_PATH}/${zlib_folder_name}" ]
    then
      download_and_extract "${zlib_url}" "${zlib_archive}" \
        "${zlib_src_folder_name}"

      if [ "${zlib_src_folder_name}" != "${zlib_folder_name}" ]
      then
        mv -v "${zlib_src_folder_name}" "${zlib_folder_name}"
      fi
    fi

    (
      cd "${XBB_BUILD_FOLDER_PATH}/${zlib_folder_name}"

      xbb_activate_dependencies_dev

      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running zlib${name_suffix} make..."

          # Build.
          run_verbose make -f win32/Makefile.gcc \
            PREFIX=${XBB_TARGET_TRIPLET}- \
            prefix="${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}" \
            CFLAGS="${XBB_CFLAGS_NO_W} -Wp,-D_FORTIFY_SOURCE=2 -fexceptions --param=ssp-buffer-size=4"

          run_verbose make -f win32/Makefile.gcc install \
            DESTDIR="${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/" \
            INCLUDE_PATH="include" \
            LIBRARY_PATH="lib" \
            BINARY_PATH="bin"

        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${zlib_folder_name}/make-output-$(ndate).txt"
      else

        CPPFLAGS="${XBB_CPPFLAGS}"
        CFLAGS="${XBB_CFLAGS_NO_W}"
        CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

        LDFLAGS="${XBB_LDFLAGS_LIB}"
        xbb_adjust_ldflags_rpath

        export CPPFLAGS
        export CFLAGS
        export CXXFLAGS
        export LDFLAGS

        # No config.status left, use the library.
        if [ ! -f "libz.a" ]
        then
          (
            xbb_show_env_develop

            echo
            echo "Running zlib configure..."

            if [ "${XBB_IS_DEVELOP}" == "y" ]
            then
              run_verbose bash "configure" --help
            fi

            # Hack needed for 1.2.12 on macOS
            export cc="${CC}"

            config_options=()

            config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${name_suffix}")
            config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/lib")
            config_options+=("--sharedlibdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/lib")
            config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/include")

            run_verbose bash ${DEBUG} "configure" \
              "${config_options[@]}"

            cp "configure.log" "${XBB_LOGS_FOLDER_PATH}/${zlib_folder_name}/configure-log-$(ndate).txt"
          ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${zlib_folder_name}/configure-output-$(ndate).txt"
        fi

        (
          echo
          echo "Running zlib${name_suffix} make..."

          # Build.
          run_verbose make -j ${XBB_JOBS}

          if [ "${XBB_WITH_TESTS}" == "y" ]
          then
            run_verbose make -j1 test
          fi

          run_verbose make install

        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${zlib_folder_name}/make-output-$(ndate).txt"
      fi

      if [ -z "${name_suffix}" ]
      then
        copy_license \
          "${XBB_BUILD_FOLDER_PATH}/${zlib_folder_name}" \
          "${zlib_folder_name}"
      fi
    )

    (
      test_zlib_libs "${name_suffix}"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${zlib_folder_name}/test-output-$(ndate).txt"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${zlib_stamp_file_path}"

  else
    echo "Library zlib${name_suffix} already installed."
  fi
}

function test_zlib_libs()
{
  local name_suffix="${1:-""}"

  (
    if [ "${XBB_HOST_PLATFORM}" == "win32" ]
    then
      echo
      echo "No checking for the zlib${name_suffix} shared libraries..."
    else
      echo
      echo "Checking the zlib${name_suffix} shared libraries..."

      show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/lib/libz.${XBB_HOST_SHLIB_EXT}"
    fi
  )
}

# -----------------------------------------------------------------------------
