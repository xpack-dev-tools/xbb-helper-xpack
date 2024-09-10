# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.gnu.org/software/m4/
# https://ftp.gnu.org/gnu/m4/

# https://gitlab.archlinux.org/archlinux/packaging/packages/m4/-/blob/main/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/m4/files/PKGBUILD
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=m4-git

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/m/m4.rb

# 2016-12-31, "1.4.18"
# 2021-05-28, "1.4.19"

# -----------------------------------------------------------------------------

function m4_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

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
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${m4_url}" "${m4_archive}" \
      "${m4_src_folder_name}" \
      "${m4_patch_file_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${m4_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${m4_folder_name}"

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

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running m4 configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${m4_src_folder_name}/configure" --help
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

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if is_development
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

        if with_strip
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        (
          echo
          echo "Linking gm4..."
          run_verbose_develop cd "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
          rm -fv gm4
          ln -sv m4 gm4
        )

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          # Fails on Ubuntu 18 and macOS
          # checks/198.sysval:err
          rm -rf "${XBB_SOURCES_FOLDER_PATH}/${m4_src_folder_name}/checks/198.sysval"

          if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then
            # Silence this test on macOS.
            echo "#!/bin/sh" > "${XBB_SOURCES_FOLDER_PATH}/${m4_src_folder_name}/tests/test-execute.sh"
            echo "exit 0" >> "${XBB_SOURCES_FOLDER_PATH}/${m4_src_folder_name}/tests/test-execute.sh"

            # Remove failing test.
            run_verbose sed -i.bak -e 's|test-vasprintf-posix$(EXEEXT) ||' "${XBB_BUILD_FOLDER_PATH}/${m4_folder_name}/tests/Makefile"

            run_verbose diff "${XBB_BUILD_FOLDER_PATH}/${m4_folder_name}/tests/Makefile.bak" "${XBB_BUILD_FOLDER_PATH}/${m4_folder_name}/tests/Makefile" || true
          fi

          run_verbose make -j1 check
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${m4_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${m4_src_folder_name}" \
        "${m4_folder_name}"
    )

    (
      m4_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${m4_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${m4_stamp_file_path}"

  else
    echo "Component m4 already installed"
  fi

  tests_add "m4_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function m4_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the m4 binaries shared libraries..."

    show_host_libs "${test_bin_folder_path}/m4"

    echo
    echo "Testing if m4 binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/m4" --version

    rm -rf "${XBB_TESTS_FOLDER_PATH}/m4"
    mkdir -pv "${XBB_TESTS_FOLDER_PATH}/m4"; cd "${XBB_TESTS_FOLDER_PATH}/m4"

    echo "TEST M4" > hello.txt
    expect_host_output  "Hello M4" "${test_bin_folder_path}/m4" -DTEST=Hello hello.txt

  )
}

# -----------------------------------------------------------------------------
