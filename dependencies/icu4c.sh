# -----------------------------------------------------------------------------
#
# This file is part of the xPack project (http://xpack.github.io).
# Copyright (c) 2025 Liviu Ionescu. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
#
# If a copy of the license was not distributed with this file, it can
# be obtained from https://opensource.org/licenses/MIT.
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.gnu.org/software/icu4c/
# https://github.com/unicode-org/icu/releases

# https://gitlab.archlinux.org/archlinux/packaging/packages/icu/-/blob/main/PKGBUILD?ref_type=heads
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/i/icu4c%4077.rb

# 2025-05-25, "77.1"

# -----------------------------------------------------------------------------

function icu4c_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  # Dot separated version.
  local icu4c_version="$1"
  local icu4c_version_major=$(xbb_get_version_major "${icu4c_version}")
  local icu4c_version_minor=$(xbb_get_version_minor "${icu4c_version}")

  local icu4c_src_folder_name="icu"

  local icu4c_archive="icu4c-${icu4c_version_major}_${icu4c_version_minor}-src.tgz"
  # https://github.com/unicode-org/icu/releases/download/release-77-1/icu4c-77_1-src.tgz
  local icu4c_url="https://github.com/unicode-org/icu/releases/download/release-${icu4c_version_major}-${icu4c_version_minor}/${icu4c_archive}"

  local icu4c_folder_name="icu-${icu4c_version}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${icu4c_folder_name}"

  local icu4c_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${icu4c_folder_name}-installed"
  if [ ! -f "${icu4c_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${icu4c_url}" "${icu4c_archive}" \
      "${icu4c_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${icu4c_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${icu4c_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP}"

      xbb_adjust_ldflags_rpath

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      # export M4=gm4

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running icu4c configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${icu4c_src_folder_name}/source/configure" --help
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

          config_options+=("--disable-samples") # HB
          config_options+=("--disable-tests") # HB
          config_options+=("--enable-static") # HB

          if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then
            # Otherwise the references to libraries are not absolute and
            # using the binaries fails with missing libraries.
            config_options+=("--enable-rpath")
          fi

          if [ "${XBB_HOST_PLATFORM}" == "win32" ]
          then
            # The folder where the host build was done.
            config_options+=("--with-cross-build=${XBB_TARGET_NATIVE_FOLDER_PATH}/${XBB_BUILD_FOLDER_NAME}/${icu4c_folder_name}")
          else
            # On Linux and macOS the bitness is determined by the host.
            config_options+=("--with-library-bits=64") # HB
          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${icu4c_src_folder_name}/source/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${icu4c_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${icu4c_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running icu4c make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        run_verbose make install

        # Remove documentation
        # run_verbose rm -rfv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/share/doc" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/share/info"

        if [ "${XBB_HOST_PLATFORM}" == "win32" ]
        then
          : # /bin/bash: ./icuinfo.exe: cannot execute binary file: Exec format error
        else
          if true # [ "${RUN_LONG_TESTS}" == "y" ]
          then
            make -j1 check
          fi
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${icu4c_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${icu4c_src_folder_name}" \
        "${icu4c_folder_name}"
    )

    (
      icu4c_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${icu4c_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${icu4c_stamp_file_path}"

  else
    echo "Component icu4c already installed"
  fi

  tests_add "icu4c_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function icu4c_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the icu4c shared library..."

    show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libicuuc.${XBB_HOST_SHLIB_EXT}"
    show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libicudata.${XBB_HOST_SHLIB_EXT}"
    show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libicui18n.${XBB_HOST_SHLIB_EXT}"
    show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libicuio.${XBB_HOST_SHLIB_EXT}"
    show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libicutest.${XBB_HOST_SHLIB_EXT}"
    show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libicutu.${XBB_HOST_SHLIB_EXT}"
    show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libicuuc.${XBB_HOST_SHLIB_EXT}"

    echo
    echo "Checking the icu4c binaries shared libraries..."

    show_host_libs "${test_bin_folder_path}/gendict"
    show_host_libs "${test_bin_folder_path}/genrb"
    show_host_libs "${test_bin_folder_path}/genbrk"
    show_host_libs "${test_bin_folder_path}/gencfu"
    show_host_libs "${test_bin_folder_path}/gencnval"
    show_host_libs "${test_bin_folder_path}/icuinfo"
    show_host_libs "${test_bin_folder_path}/pkgdata"
  )

  (
    echo
    echo "Testing if icu4c binaries start properly..."

    # cd "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/"
    run_host_app_verbose "${test_bin_folder_path}/gendict" -trietype --version
    run_host_app_verbose "${test_bin_folder_path}/genrb" --version
    # run_host_app_verbose "${test_bin_folder_path}/genbrk" --version
    # run_host_app_verbose "${test_bin_folder_path}/gencfu" --version
    # run_host_app_verbose "${test_bin_folder_path}/gencnval" --version
    run_host_app_verbose "${test_bin_folder_path}/icuinfo"
    run_host_app_verbose "${test_bin_folder_path}/pkgdata" --help
  )
}
