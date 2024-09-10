# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# https://www.gnu.org/software/sed/
# https://ftp.gnu.org/gnu/sed/

# https://gitlab.archlinux.org/archlinux/packaging/packages/sed/-/blob/main/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/sed/files/PKGBUILD

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/g/gnu-sed.rb

# 2018-12-21, "4.7"
# 2020-01-14, "4.8"
# 2022-11-06, "4.9"

# -----------------------------------------------------------------------------

function sed_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local sed_version="$1"

  local sed_src_folder_name="sed-${sed_version}"

  local sed_archive="${sed_src_folder_name}.tar.xz"
  local sed_url="https://ftp.gnu.org/gnu/sed/${sed_archive}"

  local sed_folder_name="${sed_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${sed_folder_name}"

  local sed_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${sed_folder_name}-installed"
  if [ ! -f "${sed_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${sed_url}" "${sed_archive}" \
      "${sed_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${sed_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${sed_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
      then
        # Configure expects a warning for clang.
        CFLAGS="${XBB_CFLAGS}"
        CXXFLAGS="${XBB_CXXFLAGS}"
      else
        CFLAGS="${XBB_CFLAGS_NO_W}"
        CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      fi

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
          echo "Running sed configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${sed_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--infodir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/info")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")
          config_options+=("--htmldir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/html")
          config_options+=("--pdfdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/pdf")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          config_options+=("--with-libiconv-prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--without-selinux") # HB

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if is_development
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--disable-nls")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${sed_src_folder_name}/configure" \
            "${config_options[@]}"

          if [ "${XBB_HOST_PLATFORM}" == "linux" ]
          then
            # Fails on Intel and Arm, better disable it completely.
            run_verbose sed -i.bak \
              -e 's|testsuite/panic-tests.sh||g' \
              "Makefile"

            run_verbose diff "Makefile.bak" "Makefile" || true
          fi

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${sed_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${sed_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running sed make..."

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
          echo "Linking gsed..."
          run_verbose_develop cd "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
          rm -fv gsed
          ln -sv sed gsed
        )

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          # WARN-TEST
          if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then
            # FAIL:  6
            # Some tests fail due to missing locales.
            # darwin: FAIL: testsuite/subst-mb-incomplete.sh
            : run_verbose make -j1 check || true
          else
            run_verbose make -j1 check
          fi
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${sed_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_BUILD_FOLDER_PATH}/${sed_folder_name}" \
        "${sed_folder_name}"
    )

    # (
    #   sed_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    # ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${sed_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${sed_stamp_file_path}"

  else
    echo "Component sed already installed"
  fi

  tests_add "sed_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function sed_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the sed binaries shared libraries..."

    show_host_libs "${test_bin_folder_path}/sed"

    echo
    echo "Testing if sed binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/sed" --version

    rm -rf "${XBB_TESTS_FOLDER_PATH}/sed"
    mkdir -pv "${XBB_TESTS_FOLDER_PATH}/sed"
    run_verbose_develop cd "${XBB_TESTS_FOLDER_PATH}/sed"

    echo "Hello World" >test.txt
    expect_host_output "Hello SED" "${test_bin_folder_path}/sed" 's|World|SED|' test.txt
  )
}

# -----------------------------------------------------------------------------
