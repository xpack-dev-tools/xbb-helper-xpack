# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function libtasn1_build()
{
  # https://www.gnu.org/software/libtasn1/
  # https://ftp.gnu.org/gnu/libtasn1/
  # https://ftp.gnu.org/gnu/libtasn1/libtasn1-4.12.tar.gz

  # https://gitlab.archlinux.org/archlinux/packaging/packages/libtasn1/-/blob/main/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/libtasn1/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libtasn1-git

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/l/libtasn1.rb

  # 2017-11-19, "4.12"
  # 2018-01-16, "4.13"
  # 2019-11-21, "4.15.0"
  # 2021-05-13, "4.17.0"
  # 2021-11-09, "4.18.0"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local libtasn1_version="$1"

  local libtasn1_src_folder_name="libtasn1-${libtasn1_version}"

  local libtasn1_archive="${libtasn1_src_folder_name}.tar.gz"
  local libtasn1_url="ftp://ftp.gnu.org/gnu/liblibtasn1/${libtasn1_archive}"

  local libtasn1_folder_name="${libtasn1_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libtasn1_folder_name}"

  local libtasn1_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${libtasn1_folder_name}-installed"
  if [ ! -f "${libtasn1_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libtasn1_url}" "${libtasn1_archive}" \
      "${libtasn1_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libtasn1_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${libtasn1_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"

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
          echo "Running libtasn1 configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libtasn1_src_folder_name}/configure" --help
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

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${libtasn1_src_folder_name}/configure" \
            "${config_options[@]}"

          if false # is_darwin # && [ "${XBB_LAYER}" == "xbb-bootstrap" ]
          then
            # Disable failing `Test_tree` and `copynode` tests.
            run_verbose sed -i.bak \
              -e 's| Test_tree$(EXEEXT) | |' \
              -e 's| copynode$(EXEEXT) | |' \
              "tests/Makefile"

            run_verbose diff "tests/Makefile.bak" "tests/Makefile" || true
          fi

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libtasn1_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libtasn1_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running libtasn1 make..."

        # Build.
        CODE_COVERAGE_LDFLAGS=${LDFLAGS} make -j ${XBB_JOBS}

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

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libtasn1_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libtasn1_src_folder_name}" \
        "${libtasn1_folder_name}"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libtasn1_stamp_file_path}"

  else
    echo "Library libtasn1 already installed"
  fi
}


# -----------------------------------------------------------------------------

function gnutls_build()
{
  # https://www.gnutls.org/
  # https://www.gnupg.org/ftp/gcrypt/gnutls/
  # https://www.gnupg.org/ftp/gcrypt/gnutls/v3.6/gnutls-3.6.7.tar.xz

  # https://gitlab.archlinux.org/archlinux/packaging/packages/gnutls/-/blob/main/PKGBUILD

  # https://archlinuxarm.org/packages/aarch64/gnutls/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gnutls-git

  # # https://github.com/Homebrew/homebrew-core/blob/master/Formula/g/gnutls.rb

  # 2017-10-21, "3.6.1"
  # 2019-03-27, "3.6.7"
  # 2019-12-02, "3.6.11.1"
  # 2021-05-29, "3.7.2"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local gnutls_version="$1"
  # The first two digits.
  local gnutls_version_major=$(xbb_get_version_major "${gnutls_version}")
  local gnutls_version_minor=$(xbb_get_version_minor "${gnutls_version}")
  local gnutls_version_major_minor="${gnutls_version_major}.${gnutls_version_minor}"

  local gnutls_src_folder_name="gnutls-${gnutls_version}"

  local gnutls_archive="${gnutls_src_folder_name}.tar.xz"
  local gnutls_url="https://www.gnupg.org/ftp/gcrypt/gnutls/v${gnutls_version_major_minor}/${gnutls_archive}"

  local gnutls_folder_name="${gnutls_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${gnutls_folder_name}"

  local gnutls_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${gnutls_folder_name}-installed"
  if [ ! -f "${gnutls_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${gnutls_url}" "${gnutls_archive}" \
      "${gnutls_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${gnutls_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${gnutls_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
      then
        CPPFLAGS+=" -D_Noreturn="
      fi
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      LDFLAGS="${XBB_LDFLAGS_LIB}"

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running gnutls configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${gnutls_src_folder_name}/configure" --help
          fi

          # --disable-static
          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          config_options+=("--with-idn") # Arch
          config_options+=("--with-brotli") # Arch
          config_options+=("--with-zstd") # Arch
          config_options+=("--with-tpm2") # Arch
          config_options+=("--with-guile-site-dir=no") # Arch
          # configure: error: cannot use pkcs11 store without p11-kit
          # config_options+=("--with-default-trust-store-pkcs11=\"pkcs11:\"") # Arch
          # --with-default-trust-store-file=#{pkgetc}/cert.pem # HB

          config_options+=("--with-included-unistring")
          config_options+=("--without-p11-kit")
          # config_options+=("--with-p11-kit") # HB

          config_options+=("--enable-openssl-compatibility") # Arch

          # Fails on macOS with:
          # ice-9/boot-9.scm:752:25: In procedure dispatch-exception:
          # In procedure dynamic-link: file: "/Users/ilg/Work/xbb-bootstrap-4.0.0/darwin-arm64/build/libs/gnutls-3.7.2/guile/src/guile-gnutls-v-2", message: "file not found"
          config_options+=("--disable-guile")
          # config_options+=("--enable-guile") # Arch

          config_options+=("--disable-heartbeat-support") # HB

          # config_options+=("--disable-static") # Arch
          config_options+=("--disable-doc")
          config_options+=("--disable-full-test-suite")

          # config_options+=("--disable-static") # HB

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if is_development
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--disable-nls")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${gnutls_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${gnutls_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gnutls_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running gnutls make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if with_strip
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        # It takes very, very long. use --disable-full-test-suite
        # i386: FAIL: srp
        if false # [ "${RUN_LONG_TESTS}" == "y" ]
        then
          if is_darwin # && [ "${XBB_LAYER}" == "xbb-bootstrap" ]
          then
            # tests/cert-tests FAIL:  24
            run_verbose make -j1 check || true
          else
            run_verbose make -j1 check
          fi
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gnutls_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${gnutls_src_folder_name}" \
        "${gnutls_folder_name}"
    )

    (
      gnutls_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gnutls_folder_name}/test-output-$(ndate).txt"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${gnutls_stamp_file_path}"

  else
    echo "Library gnutls already installed"
  fi

  tests_add "gnutls_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function gnutls_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the gnutls shared libraries..."

    show_host_libs "${test_bin_folder_path}/psktool"
    show_host_libs "${test_bin_folder_path}/gnutls-cli-debug"
    show_host_libs "${test_bin_folder_path}/certtool"
    show_host_libs "${test_bin_folder_path}/srptool"
    show_host_libs "${test_bin_folder_path}/ocsptool"
    show_host_libs "${test_bin_folder_path}/gnutls-serv"
    show_host_libs "${test_bin_folder_path}/gnutls-cli"

    echo
    echo "Testing if gnutls binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/psktool" --version
    run_host_app_verbose "${test_bin_folder_path}/certtool" --version
  )
}

# -----------------------------------------------------------------------------

function xorg_util_macros_build()
{
  # https://www.linuxfromscratch.org/blfs/view/
  # https://www.linuxfromscratch.org/blfs/view/7.4/x/util-macros.html

  # https://xorg.freedesktop.org/releases/individual/util
  # https://xorg.freedesktop.org/releases/individual/util/util-macros-1.17.1.tar.bz2

  # https://gitlab.archlinux.org/archlinux/packaging/packages/xorg-util-macros/-/blob/main/PKGBUILD
  # https://archlinuxarm.org/packages/any/xorg-util-macros/files/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/u/util-macros.rb

  # 2013-09-07, "1.17.1"
  # 2018-03-05, "1.19.2"
  # 2021-01-24, "1.19.3"

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local xorg_util_macros_version="$1"

  local xorg_util_macros_src_folder_name="util-macros-${xorg_util_macros_version}"

  local xorg_util_macros_archive="${xorg_util_macros_src_folder_name}.tar.bz2"
  local xorg_util_macros_url="https://xorg.freedesktop.org/releases/individual/util/${xorg_util_macros_archive}"

  local xorg_util_macros_folder_name="${xorg_util_macros_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${xorg_util_macros_folder_name}"

  local xorg_util_macros_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${xorg_util_macros_folder_name}-installed"
  if [ ! -f "${xorg_util_macros_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${xorg_util_macros_url}" "${xorg_util_macros_archive}" \
      "${xorg_util_macros_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${xorg_util_macros_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${xorg_util_macros_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"

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
          echo "Running xorg_util_macros configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${xorg_util_macros_src_folder_name}/configure" --help
          fi

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

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${xorg_util_macros_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${xorg_util_macros_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${xorg_util_macros_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running xorg_util_macros make..."

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

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${xorg_util_macros_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${xorg_util_macros_src_folder_name}" \
        "${xorg_util_macros_folder_name}"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${xorg_util_macros_stamp_file_path}"

  else
    echo "Library xorg_util_macros already installed"
  fi
}

# -----------------------------------------------------------------------------

function xorg_xproto_build()
{
  # https://www.x.org/releases/individual/proto/
  # https://www.x.org/releases/individual/proto/xproto-7.0.31.tar.bz2

  # https://gitlab.archlinux.org/archlinux/packaging/packages/xorgproto/-/blob/main/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=xorgproto-git

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/x/xorgproto.rb

  # 2016-09-23, "7.0.31" (latest)

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local xorg_xproto_version="$1"

  local xorg_xproto_src_folder_name="xproto-${xorg_xproto_version}"

  local xorg_xproto_archive="${xorg_xproto_src_folder_name}.tar.bz2"
  local xorg_xproto_url="https://www.x.org/releases/individual/proto/${xorg_xproto_archive}"

  local xorg_xproto_folder_name="${xorg_xproto_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${xorg_xproto_folder_name}"

  # Add aarch64 to the list of Arm architectures.
  local xorg_xproto_patch_file_name="${xorg_xproto_folder_name}.patch"
  local xorg_xproto_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${xorg_xproto_folder_name}-installed"
  if [ ! -f "${xorg_xproto_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${xorg_xproto_url}" "${xorg_xproto_archive}" \
      "${xorg_xproto_src_folder_name}" "${xorg_xproto_patch_file_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${xorg_xproto_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${xorg_xproto_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"

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
          echo "Running xorg_xproto configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${xorg_xproto_src_folder_name}/configure" --help
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

          config_options+=("--without-xmlt")
          config_options+=("--without-xsltproc")
          config_options+=("--without-fop")

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if is_development
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${xorg_xproto_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${xorg_xproto_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${xorg_xproto_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running xorg_xproto make..."

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

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${xorg_xproto_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${xorg_xproto_src_folder_name}" \
        "${xorg_xproto_folder_name}"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${xorg_xproto_stamp_file_path}"

  else
    echo "Library xorg_xproto already installed"
  fi
}

# -----------------------------------------------------------------------------
