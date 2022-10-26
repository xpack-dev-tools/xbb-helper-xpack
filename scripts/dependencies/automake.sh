# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function build_automake()
{
  # https://www.gnu.org/software/automake/
  # https://ftp.gnu.org/gnu/automake/

  # https://github.com/archlinux/svntogit-packages/tree/packages/automake/trunk
  # https://archlinuxarm.org/packages/any/automake/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=automake-git

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/automake.rb

  # 2015-01-05, "1.15"
  # 2018-02-25, "1.16"
  # 2020-03-21, "1.16.2"
  # 2020-11-18, "1.16.3"
  # 2021-07-26, "1.16.4"
  # 2021-10-03, "1.16.5"

  local automake_version="$1"

  local automake_src_folder_name="automake-${automake_version}"

  local automake_archive="${automake_src_folder_name}.tar.xz"
  local automake_url="https://ftp.gnu.org/gnu/automake/${automake_archive}"

  local automake_folder_name="${automake_src_folder_name}"

  # help2man: can't get `--help' info from automake-1.16
  # Try `--no-discard-stderr' if option outputs to stderr

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${automake_folder_name}"

  local automake_patch_file_name="${automake_folder_name}.patch"
  local automake_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${automake_folder_name}-installed"
  if [ ! -f "${automake_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${automake_url}" "${automake_archive}" \
      "${automake_src_folder_name}" \
      "${automake_patch_file_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${automake_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${automake_folder_name}"

      # xbb_activate_installed_dev
      # To pick autoconf
      xbb_activate_installed_bin

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
          echo "Running automake configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${automake_src_folder_name}/configure" --help
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

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${automake_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${automake_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${automake_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running automake make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        # Takes too long and some tests fail.
        # XFAIL: t/pm/Cond2.pl
        # XFAIL: t/pm/Cond3.pl
        # ...
        if false # [ "${RUN_LONG_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${automake_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${automake_src_folder_name}" \
        "${automake_folder_name}"
    )

    (
      test_automake "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${automake_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${automake_stamp_file_path}"

  else
    echo "Component automake already installed."
  fi

  tests_add "test_automake" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
}

function test_automake()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Testing if automake scripts start properly..."

    run_app "${test_bin_folder_path}/automake" --version
  )
}

# -----------------------------------------------------------------------------
