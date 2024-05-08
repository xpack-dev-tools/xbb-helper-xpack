# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://zlib.net
# https://zlib.net/fossils/

# https://gitlab.archlinux.org/archlinux/packaging/packages/zlib/-/blob/main/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/zlib/files/PKGBUILD

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/z/zlib.rb

# 2013-04-28 "1.2.8"
# 2017-01-15 "1.2.11"
# 2022-03-27, "1.2.12"
# 2022-10-12, "1.2.13"

function zlib_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local zlib_version="$1"

  # The folder name as resulted after being extracted from the archive.
  local zlib_src_folder_name="zlib-${zlib_version}"

  local zlib_archive="${zlib_src_folder_name}.tar.gz"
  local zlib_url="https://zlib.net/fossils/${zlib_archive}"

  # The folder name for build, licenses, etc.
  local zlib_folder_name="${zlib_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${zlib_folder_name}"

  local zlib_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${zlib_folder_name}-installed"
  if [ ! -f "${zlib_stamp_file_path}" ]
  then

    echo
    echo "zlib in-source building..."

    mkdir -pv "${XBB_BUILD_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}"

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
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${zlib_folder_name}"

      xbb_activate_dependencies_dev

      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running zlib make..."

          # Build.
          run_verbose make -f win32/Makefile.gcc \
            PREFIX=${XBB_TARGET_TRIPLET}- \
            prefix="${XBB_LIBRARIES_INSTALL_FOLDER_PATH}" \
            CFLAGS="${XBB_CFLAGS_NO_W} -Wp,-D_FORTIFY_SOURCE=2 -fexceptions --param=ssp-buffer-size=4"

          run_verbose make -f win32/Makefile.gcc install \
            DESTDIR="${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/" \
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

            if is_develop
            then
              run_verbose bash "configure" --help
            fi

            # Hack needed for 1.2.12 on macOS
            export cc="${CC}"

            config_options=()

            config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

            config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
            config_options+=("--sharedlibdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
            config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")

            run_verbose bash ${DEBUG} "configure" \
              "${config_options[@]}"

            cp "configure.log" "${XBB_LOGS_FOLDER_PATH}/${zlib_folder_name}/configure-log-$(ndate).txt"
          ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${zlib_folder_name}/configure-output-$(ndate).txt"
        fi

        (
          echo
          echo "Running zlib make..."

          # Build.
          run_verbose make -j ${XBB_JOBS}

          if [ "${XBB_WITH_TESTS}" == "y" ]
          then
            run_verbose make -j1 test
          fi

          run_verbose make install

        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${zlib_folder_name}/make-output-$(ndate).txt"
      fi

      copy_license \
        "${XBB_BUILD_FOLDER_PATH}/${zlib_folder_name}" \
        "${zlib_folder_name}"
    )

    (
      zlib_test_libs
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${zlib_folder_name}/test-output-$(ndate).txt"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${zlib_stamp_file_path}"

  else
    echo "Library zlib already installed"
  fi
}

function zlib_test_libs()
{
  (
    if [ "${XBB_HOST_PLATFORM}" == "win32" ]
    then
      echo
      echo "No checking for the zlib shared libraries..."
    else
      echo
      echo "Checking the zlib shared libraries..."

      show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libz.${XBB_HOST_SHLIB_EXT}"
    fi
  )
}

# -----------------------------------------------------------------------------
