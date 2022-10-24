# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function build_pkg_config()
{
  # https://www.freedesktop.org/wiki/Software/pkg-config/
  # https://pkgconfig.freedesktop.org/releases/

  # https://github.com/archlinux/svntogit-packages/blob/packages/pkgconf/trunk/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/pkgconf/files/PKGBUILD

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=pkg-config-git

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/pkg-config.rb

  # 2017-03-20, "0.29.2", latest

  local pkg_config_version="$1"

  local pkg_config_src_folder_name="pkg-config-${pkg_config_version}"

  local pkg_config_archive="${pkg_config_src_folder_name}.tar.gz"
  local pkg_config_url="https://pkgconfig.freedesktop.org/releases/${pkg_config_archive}"
  # local pkg_config_url="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${pkg_config_archive}"

  local pkg_config_folder_name="${pkg_config_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${pkg_config_folder_name}"

  local pkg_config_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${pkg_config_folder_name}-installed"
  if [ ! -f "${pkg_config_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${pkg_config_url}" "${pkg_config_archive}" \
      "${pkg_config_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${pkg_config_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${pkg_config_folder_name}"

      if [ "${XBB_TARGET_PLATFORM}" == "darwin" ] && [[ ${CC} =~ .*gcc.* ]]
      then
        # error: variably modified 'bytes' at file scope
        prepare_clang_env ""
      fi

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      # LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC}"
      LDFLAGS="${XBB_LDFLAGS_APP}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        xbb_activate_cxx_rpath
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running pkg_config configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${pkg_config_src_folder_name}/configure" --help
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${pkg_config_src_folder_name}/glib/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          config_options+=("--with-internal-glib") # HB
          config_options+=("--with-pc-path=")

          # On Intel Linux
          # gconvert.c:61:2: error: #error GNU libiconv not in use but included iconv.h is from libiconv
          config_options+=("--with-libiconv=yes")

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-host-tool") # HB

          # --with-internal-glib fails with
          # gconvert.c:61:2: error: #error GNU libiconv not in use but included iconv.h is from libiconv
          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${pkg_config_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${pkg_config_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${pkg_config_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running pkg_config make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        # Extra: pkg-config-verbose
        run_verbose cp -v "${helper_folder_path}/extras/pkg-config-verbose" \
          "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
        run_verbose chmod +x "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/pkg-config-verbose"

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${pkg_config_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${pkg_config_src_folder_name}" \
        "${pkg_config_folder_name}"
    )

    (
      test_pkg_config "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${pkg_config_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${pkg_config_stamp_file_path}"

  else
    echo "Component pkg_config already installed."
  fi

  tests_add "test_pkg_config" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
}

function test_pkg_config()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the pkg_config binaries shared libraries..."

    show_libs "${test_bin_folder_path}/pkg-config"

    echo
    echo "Testing if pkg_config binaries start properly..."

    run_app "${test_bin_folder_path}/pkg-config" --version
    (
      xbb_activate_installed_bin
      run_app "${test_bin_folder_path}/pkg-config-verbose" --version
    )
  )
}

# -----------------------------------------------------------------------------
