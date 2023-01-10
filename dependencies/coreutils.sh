# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.gnu.org/software/coreutils/
# https://ftp.gnu.org/gnu/coreutils/

# https://github.com/archlinux/svntogit-packages/blob/packages/coreutils/trunk/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/coreutils/files/PKGBUILD

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/coreutils.rb

# 2018-07-01, "8.30"
# 2019-03-10 "8.31"
# 2020-03-05, "8.32"
# 2021-09-24, "9.0"
# 2022-04-15, "9.1"

# -----------------------------------------------------------------------------

function coreutils_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local coreutils_version="$1"

  local coreutils_src_folder_name="coreutils-${coreutils_version}"

  local coreutils_archive="${coreutils_src_folder_name}.tar.xz"
  local coreutils_url="https://ftp.gnu.org/gnu/coreutils/${coreutils_archive}"

  local coreutils_folder_name="${coreutils_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${coreutils_folder_name}"

  local coreutils_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${coreutils_folder_name}-installed"
  if [ ! -f "${coreutils_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${coreutils_url}" "${coreutils_archive}" \
      "${coreutils_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${coreutils_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${coreutils_folder_name}"

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
          echo "Running coreutils configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${coreutils_src_folder_name}/configure" --help
          fi

          # configure: error: you should not run configure as root
          # (set FORCE_UNSAFE_CONFIGURE=1 in environment to bypass this check)

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          config_options+=("--without-selinux") # HB

          config_options+=("--with-universal-archs=${XBB_TARGET_BITS}-bit")
          config_options+=("--with-computed-gotos")
          config_options+=("--with-dbmliborder=gdbm:ndbm")

          # config_options+=("--with-openssl") # Arch
          config_options+=("--with-openssl=no")

          config_options+=("--with-gmp") # HB

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--disable-nls")

          if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then
            # This is debatable, to either keep the original names
            # (and avoid ar) or to prefix everything with g (like HB).

            # config_options+=("--program-prefix=g") # HB
            # `ar` must be excluded, it interferes with Apple similar program.
            config_options+=("--enable-no-install-program=ar")
          fi

          # --enable-no-install-program=groups,hostname,kill,uptime # Arch

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${coreutils_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${coreutils_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${coreutils_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running coreutils make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_COREUTILS_INSTALL_REALPATH_ONLY:-}" == "y" ]
        then
          run_verbose ${INSTALL} -v -d \
            "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
          run_verbose ${INSTALL} -v -c -m 755 src/realpath \
            "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/grealpath"
          run_verbose ${INSTALL} -v -c -m 755 src/readlink \
            "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/greadlink"
        else
          if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then
            # Strip fails with:
            # 2022-10-01T12:53:19.6394770Z /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip: error: symbols referenced by indirect symbol table entries that can't be stripped in: /Users/ilg/Work/xbb-bootstrap-4.0/darwin-arm64/install/xbb-bootstrap/libexec/coreutils/_inst.24110_
            run_verbose make install
          else
            if [ "${XBB_WITH_STRIP}" == "y" ]
            then
              run_verbose make install-strip
            else
              run_verbose make install
            fi
          fi
        fi

        # Takes very long and fails.
        # x86_64: FAIL: tests/misc/chroot-credentials.sh
        # x86_64: ERROR: tests/du/long-from-unreadable.sh
        # WARN-TEST
        # make -j1 check

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${coreutils_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${coreutils_src_folder_name}" \
        "${coreutils_folder_name}"
    )

    (
      if [ "${XBB_COREUTILS_INSTALL_REALPATH_ONLY:-}" == "y" ]
      then
        coreutils_test_realpath "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
      else
        coreutils_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
      fi
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${coreutils_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${coreutils_stamp_file_path}"

  else
    echo "Component coreutils already installed"
  fi

  if [ "${XBB_COREUTILS_INSTALL_REALPATH_ONLY:-}" == "y" ]
  then
    tests_add "coreutils_test_realpath" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
  else
    tests_add "coreutils_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
  fi
}

function coreutils_test()
{
  local test_bin_folder_path="$1"

  local prefix=""

  (
    echo
    echo "Checking the coreutils binaries shared libraries..."

    show_host_libs "${test_bin_folder_path}/${prefix}basename"
    show_host_libs "${test_bin_folder_path}/${prefix}cat"
    show_host_libs "${test_bin_folder_path}/${prefix}chmod"
    show_host_libs "${test_bin_folder_path}/${prefix}chown"
    show_host_libs "${test_bin_folder_path}/${prefix}cp"
    show_host_libs "${test_bin_folder_path}/${prefix}dirname"
    show_host_libs "${test_bin_folder_path}/${prefix}ln"
    show_host_libs "${test_bin_folder_path}/${prefix}ls"
    show_host_libs "${test_bin_folder_path}/${prefix}mkdir"
    show_host_libs "${test_bin_folder_path}/${prefix}mv"
    show_host_libs "${test_bin_folder_path}/${prefix}printf"
    show_host_libs "${test_bin_folder_path}/${prefix}realpath"
    show_host_libs "${test_bin_folder_path}/${prefix}rm"
    show_host_libs "${test_bin_folder_path}/${prefix}rmdir"
    show_host_libs "${test_bin_folder_path}/${prefix}sha256sum"
    show_host_libs "${test_bin_folder_path}/${prefix}sort"
    show_host_libs "${test_bin_folder_path}/${prefix}touch"
    show_host_libs "${test_bin_folder_path}/${prefix}tr"
    show_host_libs "${test_bin_folder_path}/${prefix}wc"

    echo
    echo "Testing if coreutils binaries start properly..."

    echo
    run_host_app_verbose "${test_bin_folder_path}/${prefix}basename" --version
    run_host_app_verbose "${test_bin_folder_path}/${prefix}cat" --version
    run_host_app_verbose "${test_bin_folder_path}/${prefix}chmod" --version
    run_host_app_verbose "${test_bin_folder_path}/${prefix}chown" --version
    run_host_app_verbose "${test_bin_folder_path}/${prefix}cp" --version
    run_host_app_verbose "${test_bin_folder_path}/${prefix}dirname" --version
    run_host_app_verbose "${test_bin_folder_path}/${prefix}ln" --version
    run_host_app_verbose "${test_bin_folder_path}/${prefix}ls" --version
    run_host_app_verbose "${test_bin_folder_path}/${prefix}mkdir" --version
    run_host_app_verbose "${test_bin_folder_path}/${prefix}mv" --version
    run_host_app_verbose "${test_bin_folder_path}/${prefix}printf" --version
    run_host_app_verbose "${test_bin_folder_path}/${prefix}realpath" --version
    run_host_app_verbose "${test_bin_folder_path}/${prefix}rm" --version
    run_host_app_verbose "${test_bin_folder_path}/${prefix}rmdir" --version
    run_host_app_verbose "${test_bin_folder_path}/${prefix}sha256sum" --version
    run_host_app_verbose "${test_bin_folder_path}/${prefix}sort" --version
    run_host_app_verbose "${test_bin_folder_path}/${prefix}touch" --version
    run_host_app_verbose "${test_bin_folder_path}/${prefix}tr" --version
    run_host_app_verbose "${test_bin_folder_path}/${prefix}wc" --version
  )
}

function coreutils_test_realpath()
{
  local test_bin_folder_path="$1"

  local prefix="g"

  (
    echo
    echo "Checking the coreutils realpath binaries shared libraries..."

    show_host_libs "${test_bin_folder_path}/${prefix}realpath"
    show_host_libs "${test_bin_folder_path}/${prefix}readlink"

    echo
    echo "Testing if coreutils realpath binaries start properly..."

    echo
    run_host_app_verbose "${test_bin_folder_path}/${prefix}realpath" --version
    run_host_app_verbose "${test_bin_folder_path}/${prefix}readlink" --version
  )
}

# -----------------------------------------------------------------------------
