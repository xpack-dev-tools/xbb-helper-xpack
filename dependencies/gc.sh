# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.hboehm.info/gc

# https://github.com/ivmai/bdwgc/releases/
# https://github.com/ivmai/bdwgc/releases/download/v8.0.4/gc-8.0.4.tar.gz
# https://github.com/ivmai/bdwgc/releases/download/v8.2.0/gc-8.2.0.tar.gz

# https://gitlab.archlinux.org/archlinux/packaging/packages/gc/-/blob/main/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/gc/files/PKGBUILD

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/b/bdw-gc.rb

# 2 Mar 2019 "8.0.4"
# 28 Sep 2021, "8.0.6"
# 29 Sep 2021, "8.2.0"

# On linux 8.2.0 fails with
# extra/../pthread_support.c:365:13: error: too few arguments to function 'pthread_setname_np'
# 365 |       (void)pthread_setname_np(name_buf);

function gc_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local gc_version="$1"

  local gc_src_folder_name="gc-${gc_version}"

  local gc_archive="${gc_src_folder_name}.tar.gz"
  local gc_url="https://github.com/ivmai/bdwgc/releases/download/v${gc_version}/${gc_archive}"

  local gc_folder_name="${gc_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${gc_folder_name}"

  local gc_patch_file_name="${gc_folder_name}.git.patch"
  local gc_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${gc_folder_name}-installed"
  if [ ! -f "${gc_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${gc_url}" "${gc_archive}" \
      "${gc_src_folder_name}" "${gc_patch_file_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${gc_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${gc_folder_name}"

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
          echo "Running gc configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${gc_src_folder_name}/configure" --help
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

          config_options+=("--enable-cplusplus") # HB
          config_options+=("--enable-large-config") # HB

          config_options+=("--enable-static") # HB
          # config_options+=("--disable-static") # Arch

          config_options+=("--disable-docs")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${gc_src_folder_name}/configure" \
            "${config_options[@]}"

          if false # is_linux
          then
            # Skip the tests folder from patching, since the tests use
            # internal shared libraries.
            run_verbose find . \
              -name "libtool" \
              ! -path 'tests' \
              -print \
              -exec bash patch_file_libtool_rpath {} \;
          fi

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${gc_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gc_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running gc make..."

        # TODO: check if required
        # make clean

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if with_strip
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
        then
          # Otherwise guile fails.
          mkdir -pv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include"
          cp -v "${XBB_SOURCES_FOLDER_PATH}/${gc_src_folder_name}/include/gc_pthread_redirects.h" \
            "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include"
        fi

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          if [ "${XBB_HOST_PLATFORM}" == "linux" ] && [ "${XBB_HOST_ARCH}" == "arm" ]
          then
            : # FAIL: gctest (on Ubuntu 18)
          else
            run_verbose make -j1 check
          fi
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gc_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${gc_src_folder_name}" \
        "${gc_folder_name}"
    )

    (
      gc_test_libs
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gc_folder_name}/test-output-$(ndate).txt"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${gc_stamp_file_path}"

  else
    echo "Library gc already installed"
  fi

  # tests_add "test_gc"
}

function gc_test_libs()
{
  (
    echo
    echo "Checking the gc shared libraries..."

    show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libgc.${XBB_HOST_SHLIB_EXT}"
    show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libgccpp.${XBB_HOST_SHLIB_EXT}"
    show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libcord.${XBB_HOST_SHLIB_EXT}"
  )
}

# -----------------------------------------------------------------------------
