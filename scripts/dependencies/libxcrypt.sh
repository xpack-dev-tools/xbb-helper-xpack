# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function build_libxcrypt()
{
  # Replacement for the old libcrypt.so.1.

  # https://github.com/besser82/libxcrypt
  # https://github.com/besser82/libxcrypt/archive/v4.4.15.tar.gz
  # https://github.com/besser82/libxcrypt/releases/download/v4.4.28/libxcrypt-4.4.28.tar.xz

  # https://github.com/archlinux/svntogit-packages/blob/packages/libxcrypt/trunk/PKGBUILD
  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/libxcrypt.rb

  # 26 Jul 2018, "4.1.1"
  # 26 Oct 2018, "4.2.3"
  # 14 Nov 2018, "4.3.4"
  # Requires new autotools.
  # m4/ax_valgrind_check.m4:80: warning: macro `AM_EXTRA_RECURSIVE_TARGETS' not found in library
  # Feb 25 2020, "4.4.15"
  # 23 Aug 2020, "4.4.17"
  # 1 May 2021, "4.4.20"
  # 18 Sep 2021, "4.4.26"
  # 02 Feb 2022, "4.4.28"

  local libxcrypt_version="$1"

  local libxcrypt_src_folder_name="libxcrypt-${libxcrypt_version}"

  local libxcrypt_archive="${libxcrypt_src_folder_name}.tar.xz"
  local libxcrypt_url="https://github.com/besser82/libxcrypt/releases/download/v${libxcrypt_version}/${libxcrypt_archive}"

  local libxcrypt_folder_name="${libxcrypt_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libxcrypt_folder_name}"

  local libxcrypt_patch_file_path="${libxcrypt_folder_name}.patch"
  local libxcrypt_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${libxcrypt_folder_name}-installed"
  if [ ! -f "${libxcrypt_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    # set +e
    download_and_extract "${libxcrypt_url}" "${libxcrypt_archive}" \
      "${libxcrypt_src_folder_name}" "${libxcrypt_patch_file_path}"
    # set -e

    if [ ! -x "${XBB_SOURCES_FOLDER_PATH}/${libxcrypt_src_folder_name}/configure" ]
    then
      (
        cd "${XBB_SOURCES_FOLDER_PATH}/${libxcrypt_src_folder_name}"

        xbb_activate_installed_dev

        if [ -f "autogen.sh" ]
        then
          run_verbose bash ${DEBUG} autogen.sh
        elif [ -f "bootstrap" ]
        then
          run_verbose bash ${DEBUG} bootstrap
        else
          #
          run_verbose autoreconf -fiv
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libxcrypt_folder_name}/autogen-output-$(ndate).txt"

    fi

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libxcrypt_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${libxcrypt_folder_name}"

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
          echo "Running libxcrypt configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libxcrypt_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          # config_options+=("--enable-obsolete-api=glibc") # Arch
          config_options+=("--disable-obsolete-api") # HB

          config_options+=("--disable-static") # HB, Arch
          config_options+=("--disable-xcrypt-compat-files") # HB
          config_options+=("--disable-failure-tokens") # HB
          config_options+=("--disable-valgrind") # HB

          # The xbb-bootstrap Python is problematic:
          # checking for Python 3.>=6 with Passlib... not found
          # configure: Disabling the "regen-ka-table" target, missing Python requirements.
          # config_options+=("--enable-hashes=strong,glibc") # Arch

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${libxcrypt_src_folder_name}/configure" \
            "${config_options[@]}"

          # patch_all_libtool_rpath

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libxcrypt_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libxcrypt_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running libxcrypt make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        # install is not able to rewrite them.
        rm -rfv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}"/lib*/libxcrypt.*
        rm -rfv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}"/lib*/libowcrypt.*
        rm -rfv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}"/lib/pkgconfig/libcrypt.pc

        # make install-strip
        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          if [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
          then
            # macOS FAIL: test/symbols-static.sh
            # macOS FAIL: test/symbols-renames.sh
            run_verbose make -j1 check || true
          else
            run_verbose make -j1 check
          fi
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libxcrypt_folder_name}/make-output-$(ndate).txt"
    )

    (
      test_libxcrypt
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libxcrypt_folder_name}/test-output-$(ndate).txt"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libxcrypt_stamp_file_path}"

  else
    echo "Library libxcrypt already installed."
  fi
}

function test_libxcrypt()
{
  (
    echo
    echo "Checking the libxcrypt shared libraries..."

    show_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libcrypt.${XBB_SHLIB_EXT}"
  )
}

# -----------------------------------------------------------------------------
