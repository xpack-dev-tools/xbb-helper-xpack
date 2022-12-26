# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.gnu.org/software/libtool/
# http://ftpmirror.gnu.org/libtool/
# http://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.xz

# https://archlinuxarm.org/packages/aarch64/libtool/files/PKGBUILD
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libtool-git

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/libtool.rb

# 15-Feb-2015, "2.4.6" # Fails on macOS 12.6
# 2022-03-17, "2.4.7"

# -----------------------------------------------------------------------------

function libtool_build()
{
  local libtool_version="$1"

  local step="${2:-}"

  local libtool_src_folder_name="libtool-${libtool_version}"

  local libtool_archive="${libtool_src_folder_name}.tar.xz"
  local libtool_url="http://ftp.hosteurope.de/mirror/ftp.gnu.org/gnu/libtool/${libtool_archive}"

  local libtool_folder_name="libtool${step}-${libtool_version}"

  local libtool_patch_file_name="${libtool_folder_name}.patch"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libtool_folder_name}"

  local libtool_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${libtool_folder_name}-installed"
  if [ ! -f "${libtool_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libtool_url}" "${libtool_archive}" \
      "${libtool_src_folder_name}" "${libtool_patch_file_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libtool_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${libtool_folder_name}"

      # The new CC was set before the call.

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      # LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC}"
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

          echo
          echo "Running libtool configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libtool_src_folder_name}/configure" --help
          fi

          # From HomeBrew: Ensure configure is happy with the patched files
          for f in aclocal.m4 libltdl/aclocal.m4 Makefile.in libltdl/Makefile.in config-h.in libltdl/config-h.in configure libltdl/configure
          do
            touch "${XBB_SOURCES_FOLDER_PATH}/${libtool_src_folder_name}/$f"
          done

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          config_options+=("--disable-dependency-tracking") # HB
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--enable-ltdl-install") # HB
          # config_options+=("--program-prefix=g") # HB

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${libtool_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libtool_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libtool_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running libtool make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        (
          echo
          echo "Linking glibtool..."
          cd "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
          rm -fv glibtool glibtoolize
          ln -sv libtool glibtool
          ln -sv libtoolize glibtoolize
        )

        # amd64: ERROR: 139 tests were run,
        # 11 failed (5 expected failures).
        # 31 tests were skipped.
        # It takes too long (170 tests).
        if false # [ "${RUN_LONG_TESTS}" == "y" ]
        then
          make -j1 check gl_public_submodule_commit=
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libtool_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libtool_src_folder_name}" \
        "${libtool_folder_name}"
    )

    (
      libtool_test_libs
      libtool_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libtool_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libtool_stamp_file_path}"

  else
    echo "Component libtool already installed"
  fi

  if [ -z "${step}" ]
  then
    tests_add "libtool_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
  fi
}

function libtool_test_libs()
{
  echo
  echo "Checking the libtool shared libraries..."

  show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libltdl.${XBB_HOST_SHLIB_EXT}"
}

function libtool_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Testing if libtool binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/libtool" --version

    echo
    echo "Testing if libtool binaries display help..."

    run_host_app_verbose "${test_bin_folder_path}/libtool" --help
  )
}

# -----------------------------------------------------------------------------
