# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.lysator.liu.se/~nisse/nettle/
# https://ftp.gnu.org/gnu/nettle/

# https://gitlab.archlinux.org/archlinux/packaging/packages/nettle/-/blob/main/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/nettle/files/PKGBUILD
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=nettle-git

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/n/nettle.rb

# 2017-11-19, "3.4"
# 2018-12-04, "3.4.1"
# 2019-06-27, "3.5.1"
# 2021-06-07, "3.7.3"
# 2022-07-27, "3.8.1"

# -----------------------------------------------------------------------------

function nettle_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local nettle_version="$1"

  local nettle_src_folder_name="nettle-${nettle_version}"

  local nettle_archive="${nettle_src_folder_name}.tar.gz"
  local nettle_url="ftp://ftp.gnu.org/gnu/nettle/${nettle_archive}"

  local nettle_folder_name="${nettle_src_folder_name}"

  local nettle_patch_file_path="${nettle_folder_name}.patch"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${nettle_folder_name}"

  local nettle_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${nettle_folder_name}-installed"
  if [ ! -f "${nettle_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${nettle_url}" "${nettle_archive}" \
      "${nettle_src_folder_name}" "${nettle_patch_file_path}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${nettle_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${nettle_folder_name}"

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
          echo "Running nettle configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${nettle_src_folder_name}/configure" --help
          fi

          # -disable-static

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          # config_options+=("--enable-mini-gmp")
          config_options+=("--enable-shared") # HB

          # config_options+=("--disable-shared") # Arch

          config_options+=("--disable-documentation")
          config_options+=("--disable-arm-neon")
          config_options+=("--disable-assembler")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${nettle_src_folder_name}/configure" \
            "${config_options[@]}"

          if false # is_darwin # && [ "${XBB_LAYER}" == "xbb-bootstrap" ]
          then
            # dlopen failed: dlopen(../libnettle.so, 2): image not found
            # /Users/ilg/Work/xbb-3.1-macosx-x86_64/sources/nettle-3.5.1/run-tests: line 57: 46731 Abort trap: 6           "$1" $testflags
            # darwin: FAIL: dlopen
            run_verbose sed -i.bak \
              -e 's| dlopen-test$(EXEEXT)||' \
              "testsuite/Makefile"

            run_verbose diff "testsuite/Makefile.bak" "testsuite/Makefile"
          fi

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${nettle_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${nettle_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running nettle make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        # make install-strip
        # For unknown reasons, on 32-bits make install-info fails
        # (`install-info --info-dir="/opt/xbb/share/info" nettle.info` returns 1)
        # Make the other install targets.
        run_verbose make install-headers install-static install-pkgconfig install-shared-nettle install-shared-hogweed

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          if false # is_darwin
          then
            # dlopen failed: dlopen(../libnettle.so, 2): image not found
            # /Users/ilg/Work/xbb-3.1-macosx-x86_64/sources/nettle-3.5.1/run-tests: line 57: 46731 Abort trap: 6           "$1" $testflags
            # darwin: FAIL: dlopen
            # WARN-TEST
            run_verbose make -j1 -k check
          else
            # Takes very long on armhf.
            run_verbose make -j1 -k check
          fi
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${nettle_folder_name}/make-output-$(ndate).txt"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${nettle_stamp_file_path}"

  else
    echo "Library nettle already installed"
  fi
}

# -----------------------------------------------------------------------------
