# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function build_autoconf()
{
  # https://www.gnu.org/software/autoconf/
  # https://ftp.gnu.org/gnu/autoconf/

  # https://archlinuxarm.org/packages/any/autoconf2.13/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=autoconf-git

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/autoconf.rb

  # 2012-04-24, "2.69"
  # 2021-01-28, "2.71"

  local autoconf_version="$1"

  local autoconf_src_folder_name="autoconf-${autoconf_version}"

  local autoconf_archive="${autoconf_src_folder_name}.tar.xz"
  local autoconf_url="https://ftp.gnu.org/gnu/autoconf/${autoconf_archive}"

  local autoconf_folder_name="${autoconf_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${autoconf_folder_name}"

  local autoconf_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${autoconf_folder_name}-installed"
  if [ ! -f "${autoconf_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${autoconf_url}" "${autoconf_archive}" \
      "${autoconf_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${autoconf_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${autoconf_folder_name}"

      # xbb_activate_installed_dev
      # For the local M4; remove it when available as dependency.
      # xbb_activate_installed_bin

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      # LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC}"
      LDFLAGS="${XBB_LDFLAGS_APP}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" -o "${XBB_TARGET_PLATFORM}" == "darwin" ]
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
          echo "Running autoconf configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${autoconf_src_folder_name}/configure" --help
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

          config_options+=("--with-universal-archs=${XBB_TARGET_BITS}-bit")
          config_options+=("--with-computed-gotos")
          config_options+=("--with-dbmliborder=gdbm:ndbm")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${autoconf_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${autoconf_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${autoconf_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running autoconf make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        if false # [ "${RUN_LONG_TESTS}" == "y" ]
        then
          # 500 tests, 7 fail.
          make -j1 check
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${autoconf_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${autoconf_src_folder_name}" \
        "${autoconf_folder_name}"
    )

    (
      test_autoconf "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${autoconf_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${autoconf_stamp_file_path}"

  else
    echo "Component autoconf already installed."
  fi

  tests_add "test_autoconf" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
}

function test_autoconf()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Testing if autoconf scripts start properly..."

    run_app "${test_bin_folder_path}/autoconf" --version

    # Can't locate Autom4te/ChannelDefs.pm in @INC (you may need to install the Autom4te::ChannelDefs module) (@INC contains: /Users/ilg/Work/xbb-bootstrap-4.0.0/darwin-x64/install/libs/share/autoconf /Users/ilg/.local/xbb/lib/perl5/site_perl/5.34.0/darwin-thread-multi-2level /Users/ilg/.local/xbb/lib/perl5/site_perl/5.34.0 /Users/ilg/.local/xbb/lib/perl5/5.34.0/darwin-thread-multi-2level /Users/ilg/.local/xbb/lib/perl5/5.34.0) at /Users/ilg/Work/xbb-bootstrap-4.0.0/darwin-x64/install/xbb-bootstrap/bin/autoheader line 45.
    # BEGIN failed--compilation aborted at /Users/ilg/Work/xbb-bootstrap-4.0.0/darwin-x64/install/xbb-bootstrap/bin/autoheader line 45.
    # run_app "${test_bin_folder_path}/autoheader" --version

    # run_app "${test_bin_folder_path}/autoscan" --version
    # run_app "${test_bin_folder_path}/autoupdate" --version

    # No ELFs, only scripts.
  )
}

# -----------------------------------------------------------------------------
