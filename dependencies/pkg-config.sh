# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.freedesktop.org/wiki/Software/pkg-config/
# https://pkgconfig.freedesktop.org/releases/

# https://github.com/archlinux/svntogit-packages/blob/packages/pkgconf/trunk/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/pkgconf/files/PKGBUILD

# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=pkg-config-git

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/p/pkg-config.rb

# 2017-03-20, "0.29.2", latest

# -----------------------------------------------------------------------------

function pkg_config_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

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
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${pkg_config_url}" "${pkg_config_archive}" \
      "${pkg_config_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${pkg_config_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${pkg_config_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"

      # On macOS it fails in glib:
      # /Users/ilg/Work/pkg-config-0.29.2-2/darwin-x64/sources/pkg-config-0.29.2/glib/glib/gatomic.c:392:10: error: incompatible integer to pointer conversion passing 'gssize' (aka 'long') to parameter of type 'gpointer' (aka 'void *') [-Wint-conversion]
      #   return g_atomic_pointer_add ((volatile gpointer *) atomic, val);
      #          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # /Users/ilg/Work/pkg-config-0.29.2-2/darwin-x64/sources/pkg-config-0.29.2/glib/glib/gatomic.h:170:46: note: expanded from macro 'g_atomic_pointer_add'
      #     (gssize) __sync_fetch_and_add ((atomic), (val));                         \
      #                                              ^~~~~

      CFLAGS="${XBB_CFLAGS_NO_W} -Wno-int-conversion"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP}"

      xbb_adjust_ldflags_rpath

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          run_verbose which python3
          run_verbose python3 --version

          echo
          echo "Running pkg_config configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${pkg_config_src_folder_name}/configure" --help
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${pkg_config_src_folder_name}/glib/configure" --help
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

          config_options+=("--with-internal-glib") # HB
          config_options+=("--with-pc-path=")
          config_options+=("--with-python=$(which python3)")

          if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then
            config_options+=("--with-system-include-path=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include")
          fi

          # On Intel Linux
          # gconvert.c:61:2: error: #error GNU libiconv not in use but included iconv.h is from libiconv
          config_options+=("--with-libiconv=yes")

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-host-tool") # HB
          config_options+=("--disable-compile-warnings")

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
        run_verbose make -j ${XBB_JOBS} V=1

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

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
      pkg_config_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${pkg_config_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${pkg_config_stamp_file_path}"

  else
    echo "Component pkg_config already installed"
  fi

  tests_add "pkg_config_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function pkg_config_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the pkg_config binaries shared libraries..."

    show_host_libs "${test_bin_folder_path}/pkg-config"

    echo
    echo "Testing if pkg_config binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/pkg-config" --version
  )
}

# -----------------------------------------------------------------------------
