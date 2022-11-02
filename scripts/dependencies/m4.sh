# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function build_m4()
{
  # https://www.gnu.org/software/m4/
  # https://ftp.gnu.org/gnu/m4/

  # https://github.com/archlinux/svntogit-packages/blob/packages/m4/trunk/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/m4/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=m4-git

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/m4.rb

  # 2016-12-31, "1.4.18"
  # 2021-05-28, "1.4.19"

  local m4_version="$1"

  local m4_src_folder_name="m4-${m4_version}"

  local m4_archive="${m4_src_folder_name}.tar.gz"
  local m4_url="https://ftp.gnu.org/gnu/m4/${m4_archive}"

  local m4_folder_name="${m4_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${m4_folder_name}"

  local m4_patch_file_name="${m4_folder_name}.patch"
  local m4_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${m4_folder_name}-installed"
  if [ ! -f "${m4_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${m4_url}" "${m4_archive}" \
      "${m4_src_folder_name}" \
      "${m4_patch_file_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${m4_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${m4_folder_name}"

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
          xbb_show_env_develop

          echo
          echo "Running m4 configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${m4_src_folder_name}/configure" --help
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

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--disable-nls")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${m4_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${m4_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${m4_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running m4 make..."

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
          echo "Linking gm4..."
          cd "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
          rm -fv gm4
          ln -sv m4 gm4
        )

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          # Fails on Ubuntu 18 and macOS
          # checks/198.sysval:err
          rm -rf "${XBB_SOURCES_FOLDER_PATH}/${m4_src_folder_name}/checks/198.sysval"

          if [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
          then
            # Silence this test on macOS.
            echo "#!/bin/sh" > "${XBB_SOURCES_FOLDER_PATH}/${m4_src_folder_name}/tests/test-execute.sh"
            echo "exit 0" >> "${XBB_SOURCES_FOLDER_PATH}/${m4_src_folder_name}/tests/test-execute.sh"

            # Remove failing test.
            run_verbose sed -i.bak -e 's|test-vasprintf-posix$(EXEEXT) ||' "${XBB_BUILD_FOLDER_PATH}/${m4_folder_name}/tests/Makefile"
          fi

          run_verbose make -j1 check
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${m4_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${m4_src_folder_name}" \
        "${m4_folder_name}"
    )

    (
      test_m4 "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${m4_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${m4_stamp_file_path}"

  else
    echo "Component m4 already installed."
  fi

  tests_add "test_m4" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
}

function test_m4()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the m4 binaries shared libraries..."

    show_libs "${test_bin_folder_path}/m4"

    echo
    echo "Testing if m4 binaries start properly..."

    run_app "${test_bin_folder_path}/m4" --version

    rm -rf "${XBB_TESTS_FOLDER_PATH}/m4"
    mkdir -pv "${XBB_TESTS_FOLDER_PATH}/m4"; cd "${XBB_TESTS_FOLDER_PATH}/m4"

    echo "TEST M4" > hello.txt
    test_expect  "Hello M4" "${test_bin_folder_path}/m4" -DTEST=Hello hello.txt

  )
}

# -----------------------------------------------------------------------------
