# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.gnu.org/software/guile/
# https://ftp.gnu.org/gnu/guile/

# https://gitlab.archlinux.org/archlinux/packaging/packages/guile/-/blob/main/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/guile/files/PKGBUILD
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/g/guile.rb
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/g/guile@2.rb

# 2020-03-07, "2.2.7"
# Note: for non 2.2, update the tests!
# 2020-03-08, "3.0.1"
# 2021-05-10, "3.0.7"
# 2023-01-25, "3.0.9"

function guile_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local guile_version="$1"

  local guile_src_folder_name="guile-${guile_version}"

  local guile_archive="${guile_src_folder_name}.tar.xz"
  local guile_url="https://ftp.gnu.org/gnu/guile/${guile_archive}"

  local guile_folder_name="${guile_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${guile_folder_name}"

  local guile_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${guile_folder_name}-installed"
  if [ ! -f "${guile_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${guile_url}" "${guile_archive}" \
      "${guile_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${guile_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${guile_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP}"

      xbb_adjust_ldflags_rpath

      # Otherwise guile-config displays the verbosity.
      unset PKG_CONFIG

      # if [ "${XBB_HOST_PLATFORM}" == "linux" ]
      # then
      #   # export LD_LIBRARY_PATH="${}:${XBB_BUILD_FOLDER_PATH}/${guile_folder_name}/libguile/.libs"
      #   export LD_LIBRARY_PATH="${XBB_BUILD_FOLDER_PATH}/${guile_folder_name}/libguile/.libs"
      # fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running guile configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${guile_src_folder_name}/configure" --help
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

          # config_options+=("--disable-static") # Arch
          config_options+=("--disable-error-on-warning") # HB, Arch

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--disable-nls")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${guile_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${guile_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${guile_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running guile make..."

        # Build.
        # Requires GC with dynamic load support.
        run_verbose make -j ${XBB_JOBS}

        if false # [ "${RUN_TESTS}" == "y" ]
        then
          if is_darwin
          then
            # WARN-TEST
            run_verbose make -j1 check || true
          else
            # WARN-TEST
            run_verbose make -j1 check || true
          fi
        fi

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${guile_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${guile_src_folder_name}" \
        "${guile_folder_name}"
    )

    (
      guile_test_libs
      guile_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${guile_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${guile_stamp_file_path}"

  else
    echo "Component guile already installed"
  fi

  tests_add "guile_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function guile_test_libs()
{
  echo
  echo "Checking the guile shared libraries..."

  show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libguile-2.2.${XBB_HOST_SHLIB_EXT}"
  show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/guile/2.2/extensions/guile-readline.so"
}

function guile_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the guile shared libraries..."

    show_host_libs "${test_bin_folder_path}/guile"

    echo
    echo "Testing if guile binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/guile" --version
    run_host_app_verbose "${test_bin_folder_path}/guile-config" --version
  )
}

# -----------------------------------------------------------------------------
