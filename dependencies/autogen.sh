# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.gnu.org/software/autogen/
# https://ftp.gnu.org/gnu/autogen/
# https://ftp.gnu.org/gnu/autogen/rel5.18.16/autogen-5.18.16.tar.xz

# https://gitlab.archlinux.org/archlinux/packaging/packages/autogen/-/blob/main/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/autogen/files/PKGBUILD

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/a/autogen.rb

# 2018-08-26, "5.18.16"

function autogen_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local autogen_version="$1"

  local autogen_src_folder_name="autogen-${autogen_version}"

  local autogen_archive="${autogen_src_folder_name}.tar.xz"
  local autogen_url="https://ftp.gnu.org/gnu/autogen/rel${autogen_version}/${autogen_archive}"

  local autogen_folder_name="${autogen_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${autogen_folder_name}"

  local autogen_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${autogen_folder_name}-installed"
  if [ ! -f "${autogen_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${autogen_url}" "${autogen_archive}" \
      "${autogen_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${autogen_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${autogen_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS} -D_POSIX_C_SOURCE"
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
          echo "Running autogen configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${autogen_src_folder_name}/configure" --help
          fi

          # config.status: error: in `/root/Work/xbb-3.2-ubuntu-12.04-x86_64/build/autogen-5.18.16':
          # config.status: error: Something went wrong bootstrapping makefile fragments
          #   for automatic dependency tracking.  Try re-running configure with the
          #   '--disable-dependency-tracking' option to at least be able to build
          #   the package (albeit without support for automatic dependency tracking).


          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          config_options+=("--program-prefix=")

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if is_development
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--disable-nls")

          if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then
            # It fails on macOS with:
            # /Users/ilg/Work/xbb-bootstrap-4.0.0/darwin-arm64/sources/autogen-5.18.16/agen5/expExtract.c:48:46: error: 'struct stat' has no member named 'st_mtim'
            # if (time_is_before(outfile_time, stbf.st_mtime))
            config_options+=("ac_cv_func_utimensat=no") # HB
          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${autogen_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${autogen_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${autogen_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running autogen make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if with_strip
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          if is_development
          then
            # FAIL: cond.test
            run_verbose make -j1 check || true
          fi
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${autogen_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${autogen_src_folder_name}" \
        "${autogen_folder_name}"
    )

    (
      autogen_test_libs
      autogen_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${autogen_folder_name}/test-output-$(ndate).txt"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${autogen_stamp_file_path}"

  else
    echo "Component autogen already installed"
  fi

  tests_add "autogen_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function autogen_test_libs()
{
  show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libopts.${XBB_HOST_SHLIB_EXT}"
}

function autogen_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the autogen shared libraries..."

    show_host_libs "${test_bin_folder_path}/autogen"
    show_host_libs "${test_bin_folder_path}/columns"
    show_host_libs "${test_bin_folder_path}/getdefs"

    echo
    echo "Testing if autogen binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/autogen" --version
    run_host_app_verbose "${test_bin_folder_path}/autoopts-config" --version
    run_host_app_verbose "${test_bin_folder_path}/columns" --version
    run_host_app_verbose "${test_bin_folder_path}/getdefs" --version

    echo
    echo "Testing if autogen binaries display help..."

    run_host_app_verbose "${test_bin_folder_path}/autogen" --help

    # getdefs error:  invalid option descriptor for version
    run_host_app_verbose "${test_bin_folder_path}/getdefs" --help || true
  )
}

# -----------------------------------------------------------------------------
