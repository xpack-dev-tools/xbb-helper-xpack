# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function scons_build()
{
  # https://scons.org
  # https://prdownloads.sourceforge.net/scons/
  # https://sourceforge.net/projects/scons/files/scons/3.1.2/scons-3.1.2.tar.gz/download
  # https://sourceforge.net/projects/scons/files/latest/download
  # https://prdownloads.sourceforge.net/scons/scons-3.1.2.tar.gz

  # https://archlinuxarm.org/packages/any/scons/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=python2-scons

  # 2017-09-16, "3.0.1" (sourceforge)
  # 2019-03-27, "3.0.5" (sourceforge)
  # 2019-08-08, "3.1.1"
  # 2019-12-17, "3.1.2"
  # 2021-01-19, "4.1.0"
  # 2021-08-01, "4.2.0"
  # 2021-11-17, "4.3.0"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local scons_version="$1"

  # Previous versions used lower case.
  local scons_src_folder_name="SCons-${scons_version}"

  local scons_archive="${scons_src_folder_name}.tar.gz"

  local scons_url
  scons_url="https://sourceforge.net/projects/scons/files/scons/${scons_version}/${scons_archive}"

  local scons_folder_name="scons-${scons_version}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${scons_folder_name}"

  local scons_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${scons_folder_name}-installed"
  if [ ! -f "${scons_stamp_file_path}" ]
  then

    echo
    echo "scons in-source building..."

    mkdir -pv "${XBB_BUILD_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}"

    if [ ! -d "${XBB_BUILD_FOLDER_PATH}/${scons_folder_name}" ]
    then
      download_and_extract "${scons_url}" "${scons_archive}" \
        "${scons_src_folder_name}"

      if [ "${scons_src_folder_name}" != "${scons_folder_name}" ]
      then
        # Trick to avoid
        # mv: cannot move 'SCons-4.4.0' to a subdirectory of itself, 'scons-4.4.0/SCons-4.4.0'
        mv -v "${scons_src_folder_name}" "${scons_folder_name}-tmp"
        mv -v "${scons_folder_name}-tmp" "${scons_folder_name}"
      fi
    fi

    (
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${scons_folder_name}"

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

      xbb_show_env_develop

      echo
      echo "Running scons install..."

      echo
      which python3

      echo
      run_verbose python3 setup.py install \
        --prefix="${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}" \
        \
        --optimize=1 \

    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${scons_folder_name}/install-output-$(ndate).txt"

    (
      scons_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${scons_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${scons_stamp_file_path}"

  else
    echo "Component scons already installed"
  fi

  tests_add "scons_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function scons_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Testing if scons binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/scons" --version
  )
}

# -----------------------------------------------------------------------------


function curl_build()
{
  # https://curl.haxx.se
  # https://curl.haxx.se/download/
  # https://curl.haxx.se/download/curl-7.64.1.tar.xz

  # https://gitlab.archlinux.org/archlinux/packaging/packages/curl/-/blob/main/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/curl/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=curl-git

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/c/curl.rb

  # 2017-10-23, "7.56.1"
  # 2017-11-29, "7.57.0"
  # 2019-03-27, "7.64.1"
  # 2019-11-06, "7.67.0"
  # 2020-01-08, "7.68.0"
  # May 26 2021, "7.77.0"
  # Nov 10, 2021, "7.80.0"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local curl_version="$1"

  local curl_src_folder_name="curl-${curl_version}"

  local curl_archive="${curl_src_folder_name}.tar.xz"
  local curl_url="https://curl.haxx.se/download/${curl_archive}"

  local curl_folder_name="curl-${curl_version}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${curl_folder_name}"

  local curl_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${curl_folder_name}-installed"
  if [ ! -f "${curl_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${curl_url}" "${curl_archive}" \
      "${curl_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${curl_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${curl_folder_name}"

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
          echo "Running curl configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${curl_src_folder_name}/configure" --help
          fi

          # HomeBrew options failed:
          # --with-secure-transport
          # --without-libpsl
          # --disable-silent-rules

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          config_options+=("--with-gssapi") # Arch, HB
          config_options+=("--with-default-ssl-backend=openssl") # HB

          # config_options+=("--with-libidn2") # HB
          # config_options+=("--with-librtmp") # HB

          if false
          then
            config_options+=("--with-ca-bundle=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/openssl/ca-bundle.crt") # Arch
          else
            config_options+=("--without-ca-bundle") # HB

            # DO NOT enable it
            # curl: (60) SSL certificate problem: unable to get local issuer certificate
            # config_options+=("--without-ca-path") # HB

            # Use the built in CA store of the SSL library
            config_options+=("--with-ca-fallback") # HB
          fi

          config_options+=("--with-ssl")

          # Failed on macOS Arm:
          # from /Users/ilg/Work/xbb-bootstrap-4.0.0/darwin-arm64/sources/curl-7.80.0/lib/vtls/sectransp.c:48:
          # /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/Security.framework/Headers/Authorization.h:193:14: error: variably modified 'bytes' at file scope
          # char bytes[kAuthorizationExternalFormLength];
          # config_options+=("--with-secure-transport") # HB

          # config_options+=("--with-libssh2") # Arch
          config_options+=("--with-openssl") # Arch
          config_options+=("--with-random='/dev/urandom'") # Arch

          config_options+=("--enable-optimize")
          config_options+=("--enable-threaded-resolver") # Arch
          # config_options+=("--enable-ipv6") # Arch

          # config_options+=("--enable-versioned-symbols") # Arch
          config_options+=("--disable-versioned-symbols")

          config_options+=("--disable-manual") # Arch
          config_options+=("--disable-ldap") # Arch
          config_options+=("--disable-ldaps") # Arch
          config_options+=("--disable-werror")
          config_options+=("--disable-warnings")

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if is_development
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${curl_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${curl_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${curl_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running curl make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if with_strip
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        if false # [ "${XBB_WITH_TESTS}" == "y" ]
        then
          # It takes very long (1200+ tests).
          if is_darwin
          then
            run_verbose make -j1 check || true
          else
            run_verbose make -j1 check
          fi
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${curl_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${curl_src_folder_name}" \
        "${curl_folder_name}"
    )

    (
      curl_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${curl_folder_name}/test-output-$(ndate).txt"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${curl_stamp_file_path}"

  else
    echo "Component curl already installed"
  fi

  tests_add "curl_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function curl_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the curl shared libraries..."

    show_host_libs "${test_bin_folder_path}/curl"

    echo
    echo "Testing if curl binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/curl" --version

    rm -rf "${XBB_TESTS_FOLDER_PATH}/curl"
    mkdir -pv "${XBB_TESTS_FOLDER_PATH}/curl"; cd "${XBB_TESTS_FOLDER_PATH}/curl"

    run_host_app_verbose "${test_bin_folder_path}/curl" \
      -L https://github.com/xpack-dev-tools/.github/raw/master/README.md \
      --insecure \
      --output test-output.md
  )
}

# -----------------------------------------------------------------------------

function tar_build()
{
  # https://www.gnu.org/software/tar/
  # https://ftp.gnu.org/gnu/tar/

  # https://gitlab.archlinux.org/archlinux/packaging/packages/tar/-/blob/main/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/tar/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=tar-git

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/g/gnu-tar.rb

  # 2016-05-16 "1.29"
  # 2017-12-17 "1.30"
  # 2019-02-23 "1.32"
  # 2021-02-13, "1.34"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local tar_version="$1"

  local tar_src_folder_name="tar-${tar_version}"

  local tar_archive="${tar_src_folder_name}.tar.xz"
  local tar_url="https://ftp.gnu.org/gnu/tar/${tar_archive}"

  local tar_folder_name="${tar_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${tar_folder_name}"

  local tar_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${tar_folder_name}-installed"
  if [ ! -f "${tar_stamp_file_path}" ]
  then

    echo
    echo "tar in-source building..."

    mkdir -pv "${XBB_BUILD_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}"

    if [ ! -d "${XBB_BUILD_FOLDER_PATH}/${tar_folder_name}" ]
    then
      download_and_extract "${tar_url}" "${tar_archive}" \
        "${tar_src_folder_name}"

      if [ "${tar_src_folder_name}" != "${tar_folder_name}" ]
      then
        mv -v "${tar_src_folder_name}" "${tar_folder_name}"
      fi
    fi

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${tar_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${tar_folder_name}"

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
          echo "Running tar configure..."

          if is_development
          then
            run_verbose bash "configure" --help
          fi

          if [ "${HOME}" == "/root" ]
          then
            # configure: error: you should not run configure as root
            # (set FORCE_UNSAFE_CONFIGURE=1 in environment to bypass this check)
            export FORCE_UNSAFE_CONFIGURE=1
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

          config_options+=("--disable-nls")

          run_verbose bash ${DEBUG} "configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${tar_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${tar_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running tar make..."

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
          echo "Linking gnutar..."
          run_verbose_develop cd "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
          rm -fv gnutar
          ln -sv tar gnutar
        )

        # It takes very long (220 tests).
        # arm64: 118: explicitly named directory removed before reading FAILED (dirrem02.at:34)
        # amd64: 92: link mismatch FAILED (difflink.at:19)
        # 10.15
        # darwin: 92: link mismatch FAILED (difflink.at:19)
        # darwin: 175: remove-files with compression FAILED (remfiles01.at:32)
        # darwin: 176: remove-files with compression: grand-child FAILED (remfiles02.at:32)
        # 10.10
        # darwin: 172: sparse file truncated while archiving           FAILED (sptrcreat.at:36)
        # darwin: 173: file truncated in sparse region while comparing FAILED (sptrdiff00.at:30)
        # darwin: 174: file truncated in data region while comparing   FAILED (sptrdiff01.at:30)

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          # TODO: remove tests on darwin
          if false # is_linux && [ "${RUN_LONG_TESTS}" == "y" ]
          then
            # WARN-TEST
            run_verbose make -j1 check # || true
          fi
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${tar_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_BUILD_FOLDER_PATH}/${tar_folder_name}" \
        "${tar_folder_name}"
    )

    (
      tar_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${tar_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${tar_stamp_file_path}"

  else
    echo "Component tar already installed"
  fi

  tests_add "tar_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function tar_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the tar shared libraries..."

    show_host_libs "${test_bin_folder_path}/tar"

    echo
    echo "Testing if tar binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/tar" --version

    rm -rf "${XBB_TESTS_FOLDER_PATH}/tar"
    mkdir -pv "${XBB_TESTS_FOLDER_PATH}/tar"; cd "${XBB_TESTS_FOLDER_PATH}/tar"

    echo "hello" >hello.txt

    run_host_app_verbose "${test_bin_folder_path}/tar" -czvf hello.tar.gz hello.txt
    run_host_app_verbose "${test_bin_folder_path}/tar" -cJvf hello.tar.xz hello.txt

    mv hello.txt hello.txt.orig


    run_host_app_verbose "${test_bin_folder_path}/tar" -xzvf hello.tar.gz hello.txt
    cmp hello.txt hello.txt.orig

    (
      rm hello.txt
      run_host_app_verbose "${test_bin_folder_path}/tar" -xJvf hello.tar.xz hello.txt
      cmp hello.txt hello.txt.orig
    )

  )
}


# -----------------------------------------------------------------------------


function gawk_build()
{
  # https://www.gnu.org/software/gawk/
  # https://ftp.gnu.org/gnu/gawk/

  # https://gitlab.archlinux.org/archlinux/packaging/packages/gawk/-/blob/main/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/gawk/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gawk-git

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/g/gawk.rb

  # 2017-10-19, "4.2.0"
  # 2018-02-25, "4.2.1"
  # 2019-06-18, "5.0.1"
  # 2020-04-14, "5.1.0"
  # 2021-10-28, "5.1.1"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local gawk_version="$1"

  local gawk_src_folder_name="gawk-${gawk_version}"

  local gawk_archive="${gawk_src_folder_name}.tar.xz"
  local gawk_url="https://ftp.gnu.org/gnu/gawk/${gawk_archive}"

  local gawk_folder_name="${gawk_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${gawk_folder_name}"

  local gawk_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${gawk_folder_name}-installed"
  if [ ! -f "${gawk_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${gawk_url}" "${gawk_archive}" \
      "${gawk_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${gawk_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${gawk_folder_name}"

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
          echo "Running gawk configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${gawk_src_folder_name}/configure" --help
          fi

          # --disable-extensions
          # Extension tests fail:
          # apiterm
          # /root/Work/xbb-bootstrap-3.2-ubuntu-12.04-i686/sources/gawk-4.2.1/test/apiterm.ok _apiterm differ: byte 1, line 1
          # filefuncs
          # cmp: EOF on /root/Work/xbb-bootstrap-3.2-ubuntu-12.04-i686/sources/gawk-4.2.1/test/filefuncs.ok
          # fnmatch
          # /root/Work/xbb-bootstrap-3.2-ubuntu-12.04-i686/sources/gawk-4.2.1/test/fnmatch.ok _fnmatch differ: byte 1, line 1
          # fork
          # cmp: EOF on /root/Work/xbb-bootstrap-3.2-ubuntu-12.04-i686/sources/gawk-4.2.1/test/fork.ok
          # fork2
          # cmp: EOF on /root/Work/xbb-bootstrap-3.2-ubuntu-12.04-i686/sources/gawk-4.2.1/test/fork2.ok
          # fts
          # gawk: /root/Work/xbb-bootstrap-3.2-ubuntu-12.04-i686/sources/gawk-4.2.1/test/fts.awk:2: fatal: load_ext: library `../extension/.libs/filefuncs.so': does not define `plugin_is_GPL_compatible' (../extension/.libs/filefuncs.so: undefined symbol: plugin_is_GPL_compatible)

          # --enable-builtin-intdiv0
          # ! gawk: mpfrsqrt.awk:13: error: can't open shared library `intdiv' for reading (No such file or directory)
          # ! EXIT CODE: 1

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          config_options+=("--without-libsigsegv") # Arch
          # config_options+=("--without-libsigsegv-prefix") # HB
          config_options+=("--disable-extensions")
          config_options+=("--enable-builtin-intdiv0")

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if is_development
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--disable-nls")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${gawk_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${gawk_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gawk_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running gawk make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if with_strip
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        # Multiple failures, no time to investigate.
        # WARN-TEST
        if false # [ "${RUN_LONG_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gawk_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${gawk_src_folder_name}" \
        "${gawk_folder_name}"
    )

    (
      gawk_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gawk_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${gawk_stamp_file_path}"

  else
    echo "Component gawk already installed"
  fi

  tests_add "gawk_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function gawk_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the gawk binaries shared libraries..."

    show_host_libs "${test_bin_folder_path}/gawk"

    echo
    echo "Testing if gawk binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/gawk" --version

    rm -rf "${XBB_TESTS_FOLDER_PATH}/gawk"
    mkdir -pv "${XBB_TESTS_FOLDER_PATH}/gawk"; cd "${XBB_TESTS_FOLDER_PATH}/gawk"

    echo "Macro AWK" >hello.txt
    expect_host_output "Hello AWK" "${test_bin_folder_path}/gawk" '{ gsub(/Macro/, "Hello"); print }' hello.txt
  )
}

# -----------------------------------------------------------------------------


function patch_build()
{
  # https://www.gnu.org/software/patch/
  # https://ftp.gnu.org/gnu/patch/

  # https://gitlab.archlinux.org/archlinux/packaging/packages/patch/-/blob/main/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/patch/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=patch-git

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/g/gpatch.rb

  # 2015-03-06, "2.7.5"
  # 2018-02-06, "2.7.6" (latest)

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local patch_version="$1"

  local patch_src_folder_name="patch-${patch_version}"

  local patch_archive="${patch_src_folder_name}.tar.xz"
  local patch_url="https://ftp.gnu.org/gnu/patch/${patch_archive}"

  local patch_folder_name="${patch_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${patch_folder_name}"

  local patch_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${patch_folder_name}-installed"
  if [ ! -f "${patch_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${patch_url}" "${patch_archive}" \
      "${patch_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${patch_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${patch_folder_name}"

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
          echo "Running patch configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${patch_src_folder_name}/configure" --help
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

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${patch_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${patch_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${patch_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running patch make..."

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
          run_verbose make -j1 check
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${patch_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${patch_src_folder_name}" \
        "${patch_folder_name}"
    )

    (
      patch_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${patch_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${patch_stamp_file_path}"

  else
    echo "Component patch already installed"
  fi

  tests_add "patch_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function patch_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the patch binaries shared libraries..."

    show_host_libs "${test_bin_folder_path}/patch"

    echo
    echo "Testing if patch binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/patch" --version
  )
}

# -----------------------------------------------------------------------------

function diffutils_build()
{
  # https://www.gnu.org/software/diffutils/
  # https://ftp.gnu.org/gnu/diffutils/

  # https://gitlab.archlinux.org/archlinux/packaging/packages/diffutils/-/blob/main/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/diffutils/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=diffutils-git

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/d/diffutils.rb

  # 2017-05-21, "3.6"
  # 2018-12-31, "3.7"
  # 2021-08-01, "3.8"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local diffutils_version="$1"

  local diffutils_src_folder_name="diffutils-${diffutils_version}"

  local diffutils_archive="${diffutils_src_folder_name}.tar.xz"
  local diffutils_url="https://ftp.gnu.org/gnu/diffutils/${diffutils_archive}"

  local diffutils_folder_name="${diffutils_src_folder_name}"

   mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${diffutils_folder_name}"

  local diffutils_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${diffutils_folder_name}-installed"
  if [ ! -f "${diffutils_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${diffutils_url}" "${diffutils_archive}" \
      "${diffutils_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${diffutils_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${diffutils_folder_name}"

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
          echo "Running diffutils configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${diffutils_src_folder_name}/configure" --help
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

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${diffutils_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${diffutils_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${diffutils_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running diffutils make..."

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
          if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then
            # Silence these tests on macOS.
            echo "#!/bin/sh" > "${XBB_SOURCES_FOLDER_PATH}/${diffutils_folder_name}/tests/colors"
            echo "exit 0" >> "${XBB_SOURCES_FOLDER_PATH}/${diffutils_folder_name}/tests/colors"

            echo "#!/bin/sh" > "${XBB_SOURCES_FOLDER_PATH}/${diffutils_folder_name}/tests/large-subopt"
            echo "exit 1" >> "${XBB_SOURCES_FOLDER_PATH}/${diffutils_folder_name}/tests/large-subopt"
          fi

          run_verbose make -j1 check
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${diffutils_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${diffutils_src_folder_name}" \
        "${diffutils_folder_name}"
    )

    (
      diffutils_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${diffutils_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${diffutils_stamp_file_path}"

  else
    echo "Component diffutils already installed"
  fi

  tests_add "diffutils_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function diffutils_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the diffutils binaries shared libraries..."

    show_host_libs "${test_bin_folder_path}/diff"
    show_host_libs "${test_bin_folder_path}/cmp"
    show_host_libs "${test_bin_folder_path}/diff3"
    show_host_libs "${test_bin_folder_path}/sdiff"

    echo
    echo "Testing if diffutils binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/diff" --version
    run_host_app_verbose "${test_bin_folder_path}/cmp" --version
    run_host_app_verbose "${test_bin_folder_path}/diff3" --version
    run_host_app_verbose "${test_bin_folder_path}/sdiff" --version
  )
}

# -----------------------------------------------------------------------------

function make_build()
{
  # https://www.gnu.org/software/make/
  # https://ftp.gnu.org/gnu/make/

  # https://gitlab.archlinux.org/archlinux/packaging/packages/make/-/blob/main/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/make/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=make-git

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/m/make.rb

  # 2016-06-10, "4.2.1"
  # 2020-01-19, "4.3"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local make_version="$1"

  local make_src_folder_name="make-${make_version}"

  # bz2 available up to 4.2.1, gz available on all.
  local make_archive="${make_src_folder_name}.tar.gz"
  local make_url="https://ftp.gnu.org/gnu/make/${make_archive}"

  local make_folder_name="${make_src_folder_name}"

  # Patch to fix the alloca bug.
  # glob/libglob.a(glob.o): In function `glob_in_dir':
  # glob.c:(.text.glob_in_dir+0x90): undefined reference to `__alloca'

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${make_folder_name}"

  local make_patch_file_name="${make_folder_name}.patch"
  local make_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${make_folder_name}-installed"
  if [ ! -f "${make_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${make_url}" "${make_archive}" \
      "${make_src_folder_name}" \
      "${make_patch_file_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${make_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${make_folder_name}"

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
          echo "Running make configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${make_src_folder_name}/configure" --help
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

          config_options+=("--program-prefix=g")

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if is_development
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--disable-nls")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${make_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${make_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${make_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running make make..."

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
          echo "Linking gmake -> make..."
          run_verbose_develop cd "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
          rm -fv make
          ln -sv gmake make
        )

        # Takes too long.
        if false # [ "${RUN_LONG_TESTS}" == "y" ]
        then
          # 2 wildcard tests fail
          # WARN-TEST
          make -k check
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${make_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${make_src_folder_name}" \
        "${make_folder_name}"
    )

    (
      make_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${make_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${make_stamp_file_path}"

  else
    echo "Component make already installed"
  fi

  tests_add "make_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function make_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the make binaries shared libraries..."

    show_host_libs "${test_bin_folder_path}/gmake"

    echo
    echo "Testing if make binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/gmake" --version
  )
}

# -----------------------------------------------------------------------------

function bash_build()
{
  # https://www.gnu.org/software/bash/
  # https://ftp.gnu.org/gnu/bash/
  # https://ftp.gnu.org/gnu/bash/bash-5.0.tar.gz

  # https://gitlab.archlinux.org/archlinux/packaging/packages/bash/-/blob/main/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/bash/files/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/b/bash.rb

  # 2018-01-30, "4.4.18"
  # 2019-01-07, "5.0"
  # 2020-12-06, "5.1"
  # 2021-06-15, "5.1.8"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local bash_version="$1"

  local bash_src_folder_name="bash-${bash_version}"

  local bash_archive="${bash_src_folder_name}.tar.gz"
  local bash_url="https://ftp.gnu.org/gnu/bash/${bash_archive}"

  local bash_folder_name="${bash_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${bash_folder_name}"

  local bash_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${bash_folder_name}-installed"
  if [ ! -f "${bash_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${bash_url}" "${bash_archive}" \
      "${bash_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${bash_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${bash_folder_name}"

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
          echo "Running bash configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${bash_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

          # config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          config_options+=("--without-bash-malloc") # Arch
          config_options+=("--with-curses") # Arch
          config_options+=("--with-installed-readline") # Arch

          config_options+=("--enable-readline") # Arch

          config_options+=("--disable-nls")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${bash_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${bash_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${bash_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running bash make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if with_strip
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        if false # [ "${RUN_LONG_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${bash_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${bash_src_folder_name}" \
        "${bash_folder_name}"
    )

    (
      bash_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${bash_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${bash_stamp_file_path}"

  else
    echo "Component bash already installed"
  fi

  tests_add "bash_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function bash_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the bash binaries shared libraries..."

    show_host_libs "${test_bin_folder_path}/bash"

    echo
    echo "Testing if bash binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/bash" --version

    echo
    echo "Testing if bash binaries display help..."

    run_host_app_verbose "${test_bin_folder_path}/bash" --help
  )
}

# -----------------------------------------------------------------------------

function wget_build()
{
  # https://www.gnu.org/software/wget/
  # https://ftp.gnu.org/gnu/wget/

  # https://gitlab.archlinux.org/archlinux/packaging/packages/wget/-/blob/main/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/wget/files/PKGBUILD
  # https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/wget
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=wget-git

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/w/wget.rb

  # 2016-06-10, "1.19"
  # 2018-12-26, "1.20.1"
  # 2019-04-05, "1.20.3"

  # fails on macOS with
  # lib/malloc/dynarray-skeleton.c:195:13: error: expected identifier or '(' before numeric constant
  # 195 | __nonnull ((1))
  # 2021-01-09, "1.21.1"
  # 2021-09-07, "1.21.2"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local wget_version="$1"

  local wget_src_folder_name="wget-${wget_version}"

  local wget_archive="${wget_src_folder_name}.tar.gz"
  local wget_url="https://ftp.gnu.org/gnu/wget/${wget_archive}"

  local wget_folder_name="${wget_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${wget_folder_name}"

  local wget_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${wget_folder_name}-installed"
  if [ ! -f "${wget_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${wget_url}" "${wget_archive}" \
      "${wget_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${wget_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${wget_folder_name}"

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
          echo "Running wget configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${wget_src_folder_name}/configure" --help
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

          # config_options+=("--with-ssl=openssl") # HB
          config_options+=("--with-ssl=gnutls") # Arch

          config_options+=("--with-metalink")
          config_options+=("--without-libpsl") # HB

          # config_options+=("--without-included-regex") # HB

          config_options+=("--disable-pcre") # HB
          config_options+=("--disable-pcre2") # HB

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if is_development
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--disable-nls")

          # libpsl is not available anyway.
          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${wget_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${wget_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${wget_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running wget make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if with_strip
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        # Fails
        # x86_64: FAIL:  65
        # WARN-TEST
        # make -j1 check

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${wget_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${wget_src_folder_name}" \
        "${wget_folder_name}"
    )

    (
      wget_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${wget_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${wget_stamp_file_path}"

  else
    echo "Component wget already installed"
  fi

  tests_add "wget_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function wget_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the wget binaries shared libraries..."

    show_host_libs "${test_bin_folder_path}/wget"

    echo
    echo "Testing if wget binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/wget" --version

    rm -rf "${XBB_TESTS_FOLDER_PATH}/wget"
    mkdir -pv "${XBB_TESTS_FOLDER_PATH}/wget"; cd "${XBB_TESTS_FOLDER_PATH}/wget"

    run_host_app_verbose "${test_bin_folder_path}/wget" \
      -O test-output.md \
      https://github.com/xpack-dev-tools/.github/raw/master/README.md \

  )
}

# -----------------------------------------------------------------------------


function dos2unix_build()
{
  # https://waterlan.home.xs4all.nl/dos2unix.html
  # https://dos2unix.sourceforge.net
  # https://waterlan.home.xs4all.nl/dos2unix/dos2unix-7.4.0.tar.

  # https://gitlab.archlinux.org/archlinux/packaging/packages/dos2unix/-/blob/main/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/dos2unix/files/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/d/dos2unix.rb

  # 30-Oct-2017, "7.4.0"
  # 2019-09-24, "7.4.1"
  # 2020-10-12, "7.4.2"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local dos2unix_version="$1"

  local dos2unix_src_folder_name="dos2unix-${dos2unix_version}"

  local dos2unix_archive="${dos2unix_src_folder_name}.tar.gz"
  local dos2unix_url="https://waterlan.home.xs4all.nl/dos2unix/${dos2unix_archive}"

  local dos2unix_folder_name="${dos2unix_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${dos2unix_folder_name}"

  local dos2unix_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${dos2unix_folder_name}-installed"
  if [ ! -f "${dos2unix_stamp_file_path}" ]
  then

    echo
    echo "dos2unix in-source building..."

    mkdir -pv "${XBB_BUILD_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}"

    if [ ! -d "${XBB_BUILD_FOLDER_PATH}/${dos2unix_folder_name}" ]
    then
      download_and_extract "${dos2unix_url}" "${dos2unix_archive}" \
        "${dos2unix_src_folder_name}"

      if [ "${dos2unix_src_folder_name}" != "${dos2unix_folder_name}" ]
      then
        mv -v "${dos2unix_src_folder_name}" "${dos2unix_folder_name}"
      fi
    fi

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${dos2unix_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${dos2unix_folder_name}"

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

      (
        xbb_show_env_develop

        echo
        echo "Running dos2unix make..."

        # Build.
        run_verbose make -j ${XBB_JOBS} prefix="${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}" ENABLE_NLS=

        run_verbose make prefix="${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}" install # No strip.

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then
            #   Failed test 'dos2unix convert DOS UTF-16LE to Unix GB18030'
            #   at utf16_gb.t line 27.
            #   Failed test 'dos2unix convert DOS UTF-16LE to Unix GB18030, keep BOM'
            #   at utf16_gb.t line 30.
            #   Failed test 'unix2dos convert DOS UTF-16BE to DOS GB18030, keep BOM'
            #   at utf16_gb.t line 33.
            : # run_verbose make -j1 check || true
          else
            run_verbose make -j1 check
          fi
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${dos2unix_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_BUILD_FOLDER_PATH}/${dos2unix_folder_name}" \
        "${dos2unix_folder_name}"
    )

    (
      dos2unix_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${dos2unix_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${dos2unix_stamp_file_path}"

  else
    echo "Component dos2unix already installed"
  fi

  tests_add "dos2unix_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function dos2unix_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the dos2unix binaries shared libraries..."

    show_host_libs "${test_bin_folder_path}/unix2dos"
    show_host_libs "${test_bin_folder_path}/dos2unix"

    echo
    echo "Testing if dos2unix binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/unix2dos" --version
    run_host_app_verbose "${test_bin_folder_path}/dos2unix" --version
  )
}

# -----------------------------------------------------------------------------

function perl_build()
{
  # https://www.cpan.org
  # https://www.cpan.org/src/

  # https://gitlab.archlinux.org/archlinux/packaging/packages/perl/-/blob/main/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/perl/files/PKGBUILD
  # https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/perl

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/p/perl.rb

  # Fails to build on macOS

  # 2014-10-02, "5.18.4" (10.10 uses 5.18.2)
  # 2015-09-12, "5.20.3"
  # 2017-07-15, "5.22.4"
  # 2018-04-14, "5.24.4" # Fails in bootstrap on mac.
  # 2018-11-29, "5.26.3" # Fails in bootstrap on mac.
  # 2019-04-19, "5.28.2" # Fails in bootstrap on mac.
  # 2019-11-10, "5.30.1"
  # 2021-05-20, "5.34.0"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  XBB_PERL_VERSION="$1"
  local perl_version_major=$(xbb_get_version_major "${XBB_PERL_VERSION}")

  local perl_src_folder_name="perl-${XBB_PERL_VERSION}"

  local perl_archive="${perl_src_folder_name}.tar.gz"
  local perl_url="https://www.cpan.org/src/${perl_version_major}/${perl_archive}"

  local perl_folder_name="${perl_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${perl_folder_name}"

  # Fix an incompatibility with libxcrypt and glibc.
  # https://groups.google.com/forum/#!topic/perl.perl5.porters/BTMp2fQg8q4
  local perl_patch_file_name="${perl_folder_name}.patch"
  local perl_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${perl_folder_name}-installed"
  if [ ! -f "${perl_stamp_file_path}" ]
  then

    echo
    echo "perl in-source building..."

    mkdir -pv "${XBB_BUILD_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}"

    if [ ! -d "${XBB_BUILD_FOLDER_PATH}/${perl_folder_name}" ]
    then
      download_and_extract "${perl_url}" "${perl_archive}" \
        "${perl_src_folder_name}" \
        "${perl_patch_file_name}"

      if [ "${perl_src_folder_name}" != "${perl_folder_name}" ]
      then
        mv -v "${perl_src_folder_name}" "${perl_folder_name}"
      fi
    fi

    (
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${perl_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      # -Wno-null-pointer-arithmetic
      CFLAGS="${XBB_CPPFLAGS} ${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CPPFLAGS} ${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP}"

      xbb_adjust_ldflags_rpath

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.h" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running perl configure..."

          if is_development
          then
            run_verbose bash "./Configure" --help || true
          fi

          # -Uusedl prevents building libperl.so and so there is no need
          # worry about the weird rpath.

          run_verbose bash ${DEBUG} "./Configure" -d -e -s \
            -Dprefix="${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}" \
            \
            -Dcc="${CC}" \
            -Dccflags="${CFLAGS}" \
            -Dcppflags="${CPPFLAGS}" \
            -Dlddlflags="-shared ${LDFLAGS}" \
            -Dldflags="${LDFLAGS}" \
            -Duseshrplib \
            -Duselargefiles \
            -Dusethreads \
            -Uusedl \

        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${perl_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running perl make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if with_strip
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        # Takes very, very long, and some fail.
        if false # [ "${RUN_LONG_TESTS}" == "y" ]
        then
          # re/regexp_nonull.t                                               (Wstat: 512 Tests: 0 Failed: 0)
          # Non-zero exit status: 2
          # Parse errors: No plan found in TAP output
          # op/sub.t                                                         (Wstat: 512 Tests: 61 Failed: 0)
          # Non-zero exit status: 2
          # Parse errors: Bad plan.  You planned 62 tests but ran 61.
          # porting/manifest.t                                               (Wstat: 0 Tests: 10399 Failed: 2)
          # Failed tests:  9648, 9930
          # porting/test_bootstrap.t                                         (Wstat: 512 Tests: 407 Failed: 0)
          # Non-zero exit status: 2

          # WARN-TEST
          rm -rf t/re/regexp_nonull.t
          rm -rf t/op/sub.t

          run_verbose make -j1 test_harness
          run_verbose make -j1 test
        fi

        (
          # TODO!
          xbb_activate_installed_bin

          if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then
            # Remove any existing .cpan
            rm -rf ${HOME}/.cpan
          fi

          # https://www.cpan.org/modules/INSTALL.html
          # Convince cpan not to ask confirmations.
          export PERL_MM_USE_DEFAULT=true
          # cpanminus is a quiet version of cpan.
          run_verbose cpan App::cpanminus
        )

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${perl_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_BUILD_FOLDER_PATH}/${perl_folder_name}" \
        "${perl_folder_name}"
    )

    (
      perl_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${perl_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${perl_stamp_file_path}"

  else
    echo "Component perl already installed"
  fi

  tests_add "perl_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function perl_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the perl binaries shared libraries..."

    show_host_libs "${test_bin_folder_path}/perl"

    echo
    echo "Testing if perl binaries start properly..."

    (
      # To find libssp.so.0.
      # /opt/xbb/bin/perl: error while loading shared libraries: libssp.so.0: cannot open shared object file: No such file or directory
      # if [ "${XBB_HOST_PLATFORM}" == "linux" ]
      # then
      #   export LD_LIBRARY_PATH="${}"
      # fi

      run_host_app_verbose "${test_bin_folder_path}/perl" --version
    )

    rm -rf "${XBB_TESTS_FOLDER_PATH}/perl"
    mkdir -pv "${XBB_TESTS_FOLDER_PATH}/perl"; cd "${XBB_TESTS_FOLDER_PATH}/perl"

    echo "print 'Hello Perl';" >test.pl
    expect_host_output "Hello Perl" "${test_bin_folder_path}/perl"  test.pl
  )
}

# -----------------------------------------------------------------------------

function tcl_build()
{
  # https://www.tcl.tk/
  # https://sourceforge.net/projects/tcl/files/Tcl/
  # https://www.tcl.tk/doc/howto/compile.html

  # https://prdownloads.sourceforge.net/tcl/tcl8.6.10-src.tar.gz
  # https://sourceforge.net/projects/tcl/files/Tcl/8.6.10/tcl8.6.10-src.tar.gz/download

  # https://gitlab.archlinux.org/archlinux/packaging/packages/tcl/-/blob/main/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/tcl/files/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/t/tcl-tk.rb

  # 2019-11-21, "8.6.10"
  # 2021-01-02, "8.6.11"
  # 2021-11-05, "8.6.12"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local tcl_version="$1"

  TCL_VERSION_MAJOR=$(xbb_get_version_major "${tcl_version}")
  TCL_VERSION_MINOR=$(xbb_get_version_minor "${tcl_version}")

  local tcl_src_folder_name="tcl${tcl_version}"

  local tcl_archive="tcl${tcl_version}-src.tar.gz"
  local tcl_url="https://sourceforge.net/projects/tcl/files/Tcl/${tcl_version}/${tcl_archive}"

  local tcl_folder_name="${tcl_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${tcl_folder_name}"

  local tcl_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${tcl_folder_name}-installed"
  if [ ! -f "${tcl_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${tcl_url}" "${tcl_archive}" \
      "${tcl_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${tcl_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${tcl_folder_name}"

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
          echo "Running tcl configure..."

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          if [ "${XBB_HOST_PLATFORM}" == "linux" ]
          then
            if is_development
            then
              run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${tcl_src_folder_name}/unix/configure" --help
            fi

            config_options+=("--enable-threads")
            if [ "${XBB_HOST_BITS}" == "64" ]
            then
              config_options+=("--enable-64bit")
            fi

            run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${tcl_src_folder_name}/unix/configure" \
              "${config_options[@]}"

          elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then

            if is_development
            then
              run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${tcl_src_folder_name}/macosx/configure" --help
            fi

            if [ "${XBB_HOST_ARCH}" == "arm64" ]
            then
              # The current GCC 11.2 generates wrong code for this illegal option.
              run_verbose sed -i.bak \
                -e 's|EXTRA_APP_CC_SWITCHES=.-mdynamic-no-pic.|EXTRA_APP_CC_SWITCHES=""|' \
                "${XBB_SOURCES_FOLDER_PATH}/${tcl_src_folder_name}/macosx/configure"

              run_verbose diff "${XBB_SOURCES_FOLDER_PATH}/${tcl_src_folder_name}/macosx/configure.bak" "${XBB_SOURCES_FOLDER_PATH}/${tcl_src_folder_name}/macosx/configure" || true
            fi

            config_options+=("--enable-threads") # HB
            config_options+=("--enable-64bit") # HB

            run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${tcl_src_folder_name}/macosx/configure" \
              "${config_options[@]}"

          fi

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${tcl_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${tcl_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running tcl make..."

        # Build.
        run_verbose make -j 1 # ${XBB_JOBS}

        # strip: /Host/home/ilg/Work/xbb-bootstrap-4.0.0/linux-x64/install/xbb-bootstrap/bin/_inst.15581_: file format not recognized
        if false # with_strip
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        if false # [ "${RUN_LONG_TESTS}" == "y" ]
        then
          run_verbose make -j1 test
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${tcl_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${tcl_src_folder_name}" \
        "${tcl_folder_name}"
    )

    (
      tcl_test_libs
      tcl_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${tcl_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${tcl_stamp_file_path}"

  else
    echo "Component tcl already installed"
  fi

  tests_add "tcl_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function tcl_test_libs()
{
  (
    echo
    echo "Checking the tcl binaries shared libraries..."

    if [ "${XBB_HOST_PLATFORM}" == "linux" ]
    then
      show_host_libs "$(find ${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/thread* -name 'libthread*.so')"
      for lib in $(find ${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/tdb* -name 'libtdb*.so')
      do
        show_host_libs "${lib}"
      done
      show_host_libs "$(find ${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/itcl* -name 'libitcl*.so')"
      show_host_libs "$(find ${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/sqlite* -name 'libsqlite*.so')"
    elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
    then
      show_host_libs "$(find ${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/thread* -name 'libthread*.dylib')"
      for lib in $(find ${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/tdb* -name 'libtdb*.dylib')
      do
        show_host_libs "${lib}"
      done
      show_host_libs "$(find ${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/itcl* -name 'libitcl*.dylib')"
      show_host_libs "$(find ${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/sqlite* -name 'libsqlite*.dylib')"
    else
      echo "Unsupported platform in ${FUNCNAME[0]}()"
      exit 1
    fi
  )
}

function tcl_test()
{
  local test_bin_folder_path="$1"

  (

    show_host_libs "${test_bin_folder_path}/tclsh"*

    echo
    echo "Testing if tcl binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/tclsh"* <<< 'puts [info patchlevel]'
  )
}

# -----------------------------------------------------------------------------

function git_build()
{
  # https://git-scm.com/
  # https://www.kernel.org/pub/software/scm/git/

  # https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/git

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/g/git.rb

  # 30-Oct-2017, "2.15.0"
  # 24-Feb-2019, "2.21.0"
  # 13-Jan-2020, "2.25.0"
  # 06-Jun-2021, "2.32.0"
  # 12-Oct-2021, "2.33.1"
  # 24-Nov-2021, "2.34.1"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local git_version="$1"

  local git_src_folder_name="git-${git_version}"

  local git_archive="${git_src_folder_name}.tar.xz"
  local git_url="https://www.kernel.org/pub/software/scm/git/${git_archive}"

  local git_folder_name="${git_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${git_folder_name}"

  local git_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${git_folder_name}-installed"
  if [ ! -f "${git_stamp_file_path}" ]
  then

    echo
    echo "git in-source building..."

    mkdir -pv "${XBB_BUILD_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}"

    if [ ! -d "${XBB_BUILD_FOLDER_PATH}/${git_folder_name}" ]
    then
      download_and_extract "${git_url}" "${git_archive}" \
        "${git_src_folder_name}"

      if [ "${git_src_folder_name}" != "${git_folder_name}" ]
      then
        mv -v "${git_src_folder_name}" "${git_folder_name}"
      fi
    fi

    (
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${git_folder_name}"

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

      if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
      then
        export NO_OPENSSL=1
        export APPLE_COMMON_CRYPTO=1
      fi

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running git configure..."

          if is_development
          then
            run_verbose bash "./configure" --help
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

          run_verbose bash ${DEBUG} "./configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${git_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${git_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running git make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if with_strip
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        # Tests are quite complicated

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${git_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_BUILD_FOLDER_PATH}/${git_folder_name}" \
        "${git_folder_name}"
    )

    (
      git_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${git_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${git_stamp_file_path}"

  else
    echo "Component git already installed"
  fi

  tests_add "git_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function git_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the git binaries shared libraries..."

    show_host_libs "${test_bin_folder_path}/git"

    echo
    echo "Testing if git binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/git" --version

    rm -rf content.git
    run_host_app_verbose "${test_bin_folder_path}/git" clone \
      https://github.com/xpack-dev-tools/.github.git \
      .github.git
  )
}

# -----------------------------------------------------------------------------

function p7zip_build()
{
  # For future versions use the fork:
  # https://github.com/jinfeihan57/p7zip

  # https://github.com/jinfeihan57/p7zip/archive/refs/tags/v17.04.tar.gz

  # Deprecated
  # https://sourceforge.net/projects/p7zip/files/p7zip
  # https://sourceforge.net/projects/p7zip/files/p7zip/16.02/p7zip_16.02_src_all.tar.bz2/download

  # https://gitlab.archlinux.org/archlinux/packaging/packages/p7zip/-/blob/main/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/p7zip/files/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/p/p7zip.rb

  # 2016-07-14, "16.02"
  # 04 Apr 2021, "17.04"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local p7zip_version="$1"

  # local p7zip_src_folder_name="p7zip_${p7zip_version}"

  # local p7zip_archive="${p7zip_src_folder_name}_src_all.tar.bz2"
  # local p7zip_url="https://sourceforge.net/projects/p7zip/files/p7zip/${p7zip_version}/${p7zip_archive}"

  local p7zip_src_folder_name="p7zip-${p7zip_version}"
  local p7zip_archive="${p7zip_src_folder_name}.tar.gz"
  local p7zip_github_archive="v${p7zip_version}.tar.gz"
  local p7zip_url="https://github.com/jinfeihan57/p7zip/archive/refs/tags/${p7zip_github_archive}"

  local p7zip_folder_name="p7zip-${p7zip_version}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${p7zip_folder_name}"

  local p7zip_patch_file_name="p7zip-${p7zip_version}.git.patch"
  local p7zip_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${p7zip_folder_name}-installed"
  if [ ! -f "${p7zip_stamp_file_path}" ]
  then

    echo
    echo "p7zip in-source building..."

    mkdir -pv "${XBB_BUILD_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}"

    if [ ! -d "${XBB_BUILD_FOLDER_PATH}/${p7zip_folder_name}" ]
    then
      download_and_extract "${p7zip_url}" "${p7zip_archive}" \
        "${p7zip_src_folder_name}" "${p7zip_patch_file_name}"

      if [ "${p7zip_src_folder_name}" != "${p7zip_folder_name}" ]
      then
        mv -v "${p7zip_src_folder_name}" "${p7zip_folder_name}"
      fi
    fi

    (
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${p7zip_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
      then
        CPPFLAGS+=" -DENV_MACOSX"
      fi
      CFLAGS="${XBB_CFLAGS_NO_W} -std=c99"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W} -std=c++11"

      LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ "${XBB_HOST_PLATFORM}" == "linux" -o "${XBB_HOST_PLATFORM}" == "darwin" ]
      then
        LDFLAGS+=" -liconv"
      fi

      xbb_adjust_ldflags_rpath

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      xbb_show_env_develop

      echo
      echo "Running p7zip make..."

      if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
      then
        run_verbose cp -v "makefile.macosx_llvm_64bits" "makefile.machine"
      fi

      run_verbose make -j ${XBB_JOBS} all3 \
        CC="${CC} ${CPPFLAGS} ${CFLAGS}" \
        CXX="${CXX} ${CPPFLAGS} ${CXXFLAGS}" \

      # Otherwise the install script will ask to delete it.
      run_verbose rm -rf "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man/man1/"7z*

      run_verbose make -j1 \
        DEST_HOME="${XBB_LIBRARIES_INSTALL_FOLDER_PATH}" \
        DEST_SHARE="${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib" \
        DEST_MAN="${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man" \
        install

      if [ "${XBB_WITH_TESTS}" == "y" ]
      then
        # 7za433_7zip_zstd.7z disabled, it fails on Arm 32-bit.
        run_verbose make -j1 test test_7z test_7zr # all_test
      fi

      run_verbose ${INSTALL} -c -m 755 "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/7z" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
      run_verbose ${INSTALL} -c -m 755 "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/7za" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
      run_verbose ${INSTALL} -c -m 755 "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/7zr" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"

    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${p7zip_folder_name}/install-output-$(ndate).txt"

    copy_license \
      "${XBB_BUILD_FOLDER_PATH}/${p7zip_folder_name}" \
      "${p7zip_folder_name}"

    (
      p7zip_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${p7zip_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${p7zip_stamp_file_path}"

  else
    echo "Component p7zip already installed"
  fi

  tests_add "p7zip_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function p7zip_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the 7za shared libraries..."

      show_host_libs "${test_bin_folder_path}/7z"
      show_host_libs "${test_bin_folder_path}/7za"
      show_host_libs "${test_bin_folder_path}/7zr"

    echo
    echo "Testing if 7za binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/7z" --help
    run_host_app_verbose "${test_bin_folder_path}/7za" --help
    run_host_app_verbose "${test_bin_folder_path}/7zr" --help
  )
}

# -----------------------------------------------------------------------------

function rhash_build()
{
  # https://github.com/rhash/RHash
  # https://github.com/rhash/RHash/releases
  # https://github.com/rhash/RHash/archive/v1.3.9.tar.gz

  # https://gitlab.archlinux.org/archlinux/packaging/packages/rhash/-/blob/main/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/rhash/files/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/r/rhash.rb

  # 14 Dec 2019, "1.3.9"
  # Jan 7, 2021, "1.4.1"
  # Jul 15, 2021, "1.4.2"
  # 14 Jun 2022, "1.4.3" # Apple Silicon support added

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local rhash_version="$1"

  local rhash_src_folder_name="RHash-${rhash_version}"

  local rhash_archive="${rhash_src_folder_name}.tar.gz"
  local rhash_url="https://github.com/rhash/RHash/archive/v${rhash_version}.tar.gz"

  local rhash_folder_name="rhash-${rhash_version}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${rhash_folder_name}"

  local rhash_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${rhash_folder_name}-installed"
  if [ ! -f "${rhash_stamp_file_path}" ]
  then

    echo
    echo "rhash in-source building..."

    mkdir -pv "${XBB_BUILD_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}"

    if [ ! -d "${XBB_BUILD_FOLDER_PATH}/${rhash_folder_name}" ]
    then
      download_and_extract "${rhash_url}" "${rhash_archive}" \
        "${rhash_src_folder_name}"

      if [ "${rhash_src_folder_name}" != "${rhash_folder_name}" ]
      then
        # mv: cannot move 'RHash-1.4.2' to a subdirectory of itself, 'rhash-1.4.2/RHash-1.4.2'
        mv -v "${rhash_src_folder_name}" "${rhash_folder_name}-tmp"
        mv -v "${rhash_folder_name}-tmp" "${rhash_folder_name}"
      fi
    fi

    (
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${rhash_folder_name}"

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

      if [ ! -f "stamp-configure" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running rhash configure..."

          if is_development
          then
            run_verbose bash configure --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          # Does not support these options.
          # config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          # config_options+=("--build=${XBB_BUILD_TRIPLET}")
          # config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          config_options+=("--cc=${CC}")
          config_options+=("--extra-cflags=${CFLAGS} ${CPPFLAGS}")
          config_options+=("--extra-ldflags=${LDFLAGS}")

          run_verbose bash ${DEBUG} configure \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${rhash_folder_name}/config-log-$(ndate).txt"

          touch "stamp-configure"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${rhash_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running rhash make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        run_verbose make install # strip not available.

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 test test-lib
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${rhash_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_BUILD_FOLDER_PATH}/${rhash_folder_name}" \
        "${rhash_folder_name}"
    )

    (
      rhash_test_libs

      rhash_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${rhash_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${rhash_stamp_file_path}"

  else
    echo "Component rhash already installed"
  fi

  # tests_add "rhash_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function rhash_test_libs()
{
  echo
  echo "Checking the rhash shared libraries..."

  if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
  then
    show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/librhash.0.dylib"
  else
    show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/librhash.so.0"
  fi
}

function rhash_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the rhash shared libraries..."

    show_host_libs "${test_bin_folder_path}/rhash"

    echo
    echo "Testing if rhash binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/rhash" --version
  )
}

# -----------------------------------------------------------------------------

function re2c_build()
{
  # https://github.com/skvadrik/re2c
  # https://github.com/skvadrik/re2c/releases
  # https://github.com/skvadrik/re2c/releases/download/1.3/re2c-1.3.tar.xz

  # https://gitlab.archlinux.org/archlinux/packaging/packages/re2c/-/blob/main/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/re2c/files/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/r/re2c.rb

  # 14 Dec 2019, "1.3"
  # Mar 27, 2021, "2.1.1"
  # 01 Aug 2021, "2.2"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local re2c_version="$1"

  local re2c_src_folder_name="re2c-${re2c_version}"

  local re2c_archive="${re2c_src_folder_name}.tar.xz"
  local re2c_url="https://github.com/skvadrik/re2c/releases/download/${re2c_version}/${re2c_archive}"

  local re2c_folder_name="${re2c_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${re2c_folder_name}"

  local re2c_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${re2c_folder_name}-installed"
  if [ ! -f "${re2c_stamp_file_path}" ]
  then

    echo
    echo "re2c in-source building..."

    mkdir -pv "${XBB_BUILD_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}"

    if [ ! -d "${XBB_BUILD_FOLDER_PATH}/${re2c_folder_name}" ]
    then
      download_and_extract "${re2c_url}" "${re2c_archive}" \
        "${re2c_src_folder_name}"

      if [ "${re2c_src_folder_name}" != "${re2c_folder_name}" ]
      then
        mv -v "${re2c_src_folder_name}" "${re2c_folder_name}"
      fi
    fi

    (
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${re2c_folder_name}"
      if false # [ ! -f "stamp-autogen" ]
      then

        xbb_activate_dependencies_dev

        run_verbose bash ${DEBUG} "autogen.sh"

        touch "stamp-autogen"

      fi
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${re2c_folder_name}/autogen-output-$(ndate).txt"

    (
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${re2c_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      # Without STATIC all tests fail.
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
          echo "Running re2c configure..."

          if is_development
          then
            run_verbose bash configure --help
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

          run_verbose bash ${DEBUG} configure \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${re2c_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${re2c_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running re2c make..."

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
          run_verbose make -j1 tests
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${re2c_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_BUILD_FOLDER_PATH}/${re2c_folder_name}" \
        "${re2c_folder_name}"
    )

    (
      re2c_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${re2c_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${re2c_stamp_file_path}"

  else
    echo "Component re2c already installed"
  fi

  tests_add "re2c_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function re2c_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the re2c shared libraries..."

    show_host_libs "${test_bin_folder_path}/re2c"

    echo
    echo "Testing if re2c binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/re2c" --version

    rm -rf "${XBB_TESTS_FOLDER_PATH}/re2c"
    mkdir -pv "${XBB_TESTS_FOLDER_PATH}/re2c"; cd "${XBB_TESTS_FOLDER_PATH}/re2c"

    # Note: __EOF__ is quoted to prevent substitutions here.
    cat <<'__EOF__' > test.c
unsigned int stou (const char * s)
{
#   define YYCTYPE char
    const YYCTYPE * YYCURSOR = s;
    unsigned int result = 0;
    for (;;)
    {
        /*!re2c
            re2c:yyfill:enable = 0;
            "\x00" { return result; }
            [0-9]  { result = result * 10 + yych; continue; }
        */
    }
}
__EOF__

    run_host_app_verbose "${test_bin_folder_path}/re2c" -is -o test-out.c test.c

    (
      export LD_LIBRARY_PATH="$(xbb_get_toolchain_library_path "${CXX}")"

      run_verbose "${CC}" -c test-out.c
    )
  )
}

# -----------------------------------------------------------------------------


function gnupg_build()
{
  # https://www.gnupg.org
  # https://www.gnupg.org/ftp/gcrypt/gnupg/gnupg-2.2.19.tar.bz2

  # https://gitlab.archlinux.org/archlinux/packaging/packages/gnupg/-/blob/main/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/gnupg/files/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/g/gnupg.rb

  # 2021-06-10, "2.2.28"
  # 2021-04-20, "2.3.1" fails on macOS
  # 2021-10-12, "2.3.3"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local gnupg_version="$1"

  local gnupg_src_folder_name="gnupg-${gnupg_version}"

  local gnupg_archive="${gnupg_src_folder_name}.tar.bz2"
  local gnupg_url="https://www.gnupg.org/ftp/gcrypt/gnupg/${gnupg_archive}"

  local gnupg_folder_name="${gnupg_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${gnupg_folder_name}"

  local gnupg_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${gnupg_folder_name}-installed"
  if [ ! -f "${gnupg_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${gnupg_url}" "${gnupg_archive}" \
      "${gnupg_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${gnupg_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${gnupg_folder_name}"

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
          echo "Running gnupg configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${gnupg_src_folder_name}/configure" --help
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

          config_options+=("--with-libgpg-error-prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--with-libgcrypt-prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--with-libassuan-prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--with-ksba-prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--with-npth-prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          # config_options+=("--enable-maintainer-mode") # Arch
          config_options+=("--disable-maintainer-mode")

          config_options+=("--enable-symcryptrun")

          # config_options+=("--enable-all-tests") # HB

          # On macOS Arm, it fails to load libbz2.1.0.8.dylib
          config_options+=("--disable-bzip2")

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if is_development
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--disable-nls")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${gnupg_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${gnupg_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gnupg_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running gnupg make..."

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
          if false # [ "${XBB_HOST_PLATFORM}" == "darwin" ] && [ "${XBB_HOST_ARCH}" == "arm64" ]
          then
            : # Fails with:
            # dyld: Library not loaded: libbz2.1.0.8.dylib
            # Referenced from: /Users/ilg/Work/xbb-bootstrap-4.0.0/darwin-arm64/build/gnupg-2.3.3/g10/./t-keydb
            # Reason: image not found
            # /bin/bash: line 5: 67557 Abort trap: 6           abs_top_srcdir=/Users/ilg/Work/xbb-bootstrap-4.0.0/darwin-arm64/sources/gnupg-2.3.3 ${dir}$tst
          else
            run_verbose make -j1 check
          fi
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gnupg_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_BUILD_FOLDER_PATH}/${gnupg_folder_name}" \
        "${gnupg_folder_name}"
    )

    (
      gpg_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gnupg_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${gnupg_stamp_file_path}"

  else
    echo "Component gnupg already installed"
  fi

  tests_add "gpg_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function gpg_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the gpg binaries shared libraries..."

    show_host_libs "${test_bin_folder_path}/gpg"

    echo
    echo "Testing if gpg binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/gpg" --version
    run_host_app_verbose "${test_bin_folder_path}/gpgv" --version
    run_host_app_verbose "${test_bin_folder_path}/gpgsm" --version
    run_host_app_verbose "${test_bin_folder_path}/gpg-agent" --version

    run_host_app_verbose "${test_bin_folder_path}/kbxutil" --version

    run_host_app_verbose "${test_bin_folder_path}/gpgconf" --version
    run_host_app_verbose "${test_bin_folder_path}/gpg-connect-agent" --version
    if [ -f "${test_bin_folder_path}/symcryptrun" ]
    then
      # clang did not create it.
      run_host_app_verbose "${test_bin_folder_path}/symcryptrun" --version
    fi
    run_host_app_verbose "${test_bin_folder_path}/watchgnupg" --version
    # run_host_app_verbose "${test_bin_folder_path}/gpgparsemail" --version
    run_host_app_verbose "${test_bin_folder_path}/gpg-wks-server" --version
    run_host_app_verbose "${test_bin_folder_path}/gpgtar" --version

    # run_host_app_verbose "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/sbin/addgnupghome" --version
    # run_host_app_verbose "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/sbin/applygnupgdefaults" --version

    # TODO: add functional tests from HomeBrew.
  )
}

# -----------------------------------------------------------------------------

function makedepend_build()
{
  # https://www.linuxfromscratch.org/blfs/view/7.4/x/makedepend.html
  # https://xorg.freedesktop.org/archive/individual/util
  # https://xorg.freedesktop.org/archive/individual/util/makedepend-1.0.5.tar.bz2

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=makedepend

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/m/makedepend.rb

  # 2013-07-23, 1.0.5
  # 2019-03-16, 1.0.6

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local makedepend_version="$1"

  local makedepend_src_folder_name="makedepend-${makedepend_version}"

  local makedepend_archive="${makedepend_src_folder_name}.tar.bz2"
  local makedepend_url="https://xorg.freedesktop.org/archive/individual/util/${makedepend_archive}"

  local makedepend_folder_name="${makedepend_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${makedepend_folder_name}"

  local makedepend_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${makedepend_folder_name}-installed"
  if [ ! -f "${makedepend_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${makedepend_url}" "${makedepend_archive}" \
      "${makedepend_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${makedepend_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${makedepend_folder_name}"

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
          echo "Running makedepend configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${makedepend_src_folder_name}/configure" --help
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

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${makedepend_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${makedepend_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${makedepend_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running makedepend make..."

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
          run_verbose make -j1 check
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${makedepend_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_BUILD_FOLDER_PATH}/${makedepend_folder_name}" \
        "${makedepend_folder_name}"
    )

    (
      makedepend_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${makedepend_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${makedepend_stamp_file_path}"

  else
    echo "Component makedepend already installed"
  fi

  tests_add "makedepend_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function makedepend_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Testing if makedepend binaries start properly..."

    rm -rf "${XBB_TESTS_FOLDER_PATH}/makedepend"
    mkdir -pv "${XBB_TESTS_FOLDER_PATH}/makedepend"; cd "${XBB_TESTS_FOLDER_PATH}/makedepend"

    touch Makefile
    run_host_app_verbose "${test_bin_folder_path}/makedepend"
  )
}

# -----------------------------------------------------------------------------
