# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function build_openssl()
{
  # https://www.openssl.org
  # https://www.openssl.org/source/

  # https://www.openssl.org/source/openssl-1.1.1n.tar.gz

  # https://github.com/archlinux/svntogit-packages/blob/packages/openssl/trunk/PKGBUILD

  # https://archlinuxarm.org/packages/aarch64/openssl/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=openssl-static
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=openssl-git

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/openssl@1.1.rb

  # 2017-Nov-02
  # XBB_OPENSSL_VERSION="1.1.0g"
  # The new version deprecated CRYPTO_set_locking_callback, and yum fails with
  # /usr/lib64/python2.6/site-packages/pycurl.so: undefined symbol: CRYPTO_set_locking_callback

  # 2017-Dec-07, "1.0.2n"
  # 2019-Feb-26, "1.0.2r"
  # 2019-Feb-26, "1.1.1b"
  # 2019-Sep-10, "1.1.1d"
  # 2019-Dec-20, "1.0.2u"
  # 2020-Sep-22, "1.1.1h"
  # 2021-Mar-25, "1.1.1k"
  # 2021-Aug-24, "1.1.1l"
  # 2022-Mar-15, "1.1.1n"
  # "1.1.1q"

  local openssl_version="$1"
  # Numbers
  local openssl_version_major=$(echo ${openssl_version} | sed -e 's|\([0-9][0-9]*\)\.\([0-9][0-9]*\)\..*|\1|')
  local openssl_version_minor=$(echo ${openssl_version} | sed -e 's|\([0-9][0-9]*\)\.\([0-9][0-9]*\)\..*|\2|')

  local openssl_src_folder_name="openssl-${openssl_version}"

  local openssl_archive="${openssl_src_folder_name}.tar.gz"
  local openssl_url="https://www.openssl.org/source/${openssl_archive}"

  local openssl_folder_name="${openssl_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${openssl_folder_name}"

  local openssl_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${openssl_folder_name}-installed"
  if [ ! -f "${openssl_stamp_file_path}" ]
  then

    echo
    echo "openssl in-source building..."

    mkdir -pv "${XBB_BUILD_FOLDER_PATH}"
    cd "${XBB_BUILD_FOLDER_PATH}"

    if [ ! -d "${XBB_BUILD_FOLDER_PATH}/${openssl_folder_name}" ]
    then
      download_and_extract "${openssl_url}" "${openssl_archive}" \
        "${openssl_src_folder_name}"

      if [ "${openssl_src_folder_name}" != "${openssl_folder_name}" ]
      then
        mv -v "${openssl_src_folder_name}" "${openssl_folder_name}"
      fi
    fi

    (
      cd "${XBB_BUILD_FOLDER_PATH}/${openssl_folder_name}"

      xbb_activate_dependencies_dev

      #  -Wno-unused-command-line-argument

      # export CPPFLAGS="${XBB_CPPFLAGS} -I${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/${openssl_folder_name}/include"
      CPPFLAGS="${XBB_CPPFLAGS}"
      if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
      then
        # /usr/include/CommonCrypto/CommonRandom.h:35:9: error: unknown type name 'CCCryptorStatus'
        # typedef CCCryptorStatus CCRNGStatus;
        : # CPPFLAGS+=" -I/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include"
      fi

      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        # test/drbg_cavs_data.o: too many sections (40327)
        CFLAGS+=" -Wa,-mbig-obj"
        CXXFLAGS+=" -Wa,-mbig-obj"
      fi

      # LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC}"
      LDFLAGS="${XBB_LDFLAGS_APP}"
      xbb_adjust_ldflags_rpath

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f config.stamp ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running openssl configure..."

          echo
          if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then

            # Older versions do not support the KERNEL_BITS trick and require
            # the separate configurator.

            if [ ${openssl_version_minor} -eq 0 ]
            then

              # This config does not use the standard GNU environment definitions.
              # `Configure` is a Perl script.
              if [ "${XBB_IS_DEVELOP}" == "y" ]
              then
                run_verbose "./Configure" --help || true
              fi

              run_verbose "./Configure" "darwin64-x86_64-cc" \
                --prefix="${XBB_LIBRARIES_INSTALL_FOLDER_PATH}" \
                \
                --openssldir="${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/openssl" \
                shared \
                enable-md2 \
                enable-rc5 \
                enable-tls \
                enable-tls1_3 \
                enable-tls1_2 \
                enable-tls1_1 \
                zlib \
                "${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"

              run_verbose make depend

            else

              if [ "${XBB_IS_DEVELOP}" == "y" ]
              then
                run_verbose "./config" --help
              fi

              # From HomeBrew
              # SSLv2 died with 1.1.0, so no-ssl2 no longer required.
              # SSLv3 & zlib are off by default with 1.1.0 but this may not
              # be obvious to everyone, so explicitly state it for now to
              # help debug inevitable breakage.

              config_options=()

              config_options+=("--prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
              # DO NOT USE --libdir

              config_options+=("--openssldir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/openssl")
              config_options+=("shared")
              config_options+=("enable-md2")
              config_options+=("enable-rc5")
              config_options+=("enable-tls")
              config_options+=("enable-tls1_3")
              config_options+=("enable-tls1_2")
              config_options+=("enable-tls1_1")
              config_options+=("no-ssl3")
              config_options+=("no-ssl3-method")
              config_options+=("no-zlib")
              config_options+=("${CPPFLAGS}")
              config_options+=("${CFLAGS}")
              config_options+=("${LDFLAGS}")

              export KERNEL_BITS=64
              run_verbose "./config" \
                "${config_options[@]}"

            fi

          elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
          then

            config_options=()

            config_options+=("--prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
            # DO NOT USE --libdir

            config_options+=("--openssldir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/openssl")
            config_options+=("shared")
            config_options+=("enable-md2")
            config_options+=("enable-rc5")
            config_options+=("enable-tls")
            config_options+=("enable-tls1_3")
            config_options+=("enable-tls1_2")
            config_options+=("enable-tls1_1")
            config_options+=("no-ssl3")
            config_options+=("no-ssl3-method")
            config_options+=("no-zlib")

            if [ "${XBB_HOST_ARCH}" == "x64" ]
            then
              config_options+=("enable-ec_nistp_64_gcc_128")
            elif [ "${XBB_HOST_ARCH}" == "arm64" ]
            then
              config_options+=("no-afalgeng")
            fi

            config_options+=("${CPPFLAGS}")
            config_options+=("${CFLAGS}")
            config_options+=("${LDFLAGS}")

            # config_options+=("-Wa,--noexecstack ${CPPFLAGS} ${CFLAGS} ${LDFLAGS}")
            config_options+=("-Wa,--noexecstack")

            set +u

            # undefined reference to EVP_md2
            #  enable-md2

            # perl, do not start with bash.
            run_verbose "./config" \
              "${config_options[@]}"

            set -u

            if [ ${openssl_version_minor} -eq 0 ]
            then
              run_verbose make depend
            fi

          elif [ "${XBB_HOST_PLATFORM}" == "win32" ]
          then

            run_verbose "./Configure" --help || true

            config_options=()

            if [ "${XBB_HOST_ARCH}" == "x64" ]
            then
              config_options+=("mingw64")
            elif [ "${XBB_HOST_ARCH}" == "ia32" ]
            then
              config_options+=("mingw")
            else
              echo "Unsupported XBB_HOST_ARCH=${XBB_HOST_ARCH} in ${FUNCNAME[0]}()"
              exit 1
            fi

            config_options+=("--prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
            # DO NOT USE --libdir

            # Not needed, the CC/CXX macros already define the target.
            # config_options+=("--cross-compile-prefix=${XBB_TARGET_TRIPLET}")

            config_options+=("--openssldir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/openssl")

            config_options+=("shared")
            config_options+=("zlib-dynamic")
            config_options+=("enable-camellia")
            config_options+=("enable-capieng")
            config_options+=("enable-idea")
            config_options+=("enable-mdc2")
            config_options+=("enable-rc5")
            config_options+=("enable-rfc3779")
            config_options+=("-D__MINGW_USE_VC2005_COMPAT")

            config_options+=("${CPPFLAGS}")
            config_options+=("${CFLAGS}")
            config_options+=("${LDFLAGS}")

            run_verbose "./Configure" \
              "${config_options[@]}"

            run_verbose make -j ${XBB_JOBS}

          else
            echo "Unsupported XBB_HOST_PLATFORM=${XBB_HOST_PLATFORM} in ${FUNCNAME[0]}()"
            exit 1
          fi

          touch config.stamp

          # cp "configure.log" "${XBB_LOGS_FOLDER_PATH}/configure-openssl-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${openssl_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running openssl make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        run_verbose make install_sw

        # Copy openssl to APP_INSTALL
        if [ "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}" != "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}" ]
        then
          mkdir -pv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
          cp -v "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/openssl" \
            "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
          cp -v "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/c_rehash" \
            "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
        fi

        if false
        then
          mkdir -pv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/openssl"

          if [ -f "${XBB_FOLDER_PATH}/openssl/cert.pem" ]
          then
            install -v -c -m 644 "${XBB_FOLDER_PATH}/openssl/ca-bundle.crt" "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/openssl"
            install -v -c -m 644 "${XBB_FOLDER_PATH}/openssl/cert.pem" "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/openssl"
          elif [ -f "/private/etc/ssl/cert.pem" ]
          then
            install -v -c -m 644 "/private/etc/ssl/cert.pem" "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/openssl"
          fi

          curl --location http://curl.haxx.se/ca/cacert.pem -o cacert.pem
          install -v -c -m 644 cacert.pem "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/openssl"
        fi

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 test
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${openssl_folder_name}/make-output-$(ndate).txt"

      (
        test_openssl_libs
        test_openssl "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${openssl_folder_name}/test-output-$(ndate).txt"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${openssl_stamp_file_path}"

  else
    echo "Component openssl already installed."
  fi

  tests_add test_openssl "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function test_openssl_libs()
{
  (
    echo
    echo "Checking the openssl shared libraries..."

    show_libs "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/openssl"

    if [ -f "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib64/libcrypto.${XBB_HOST_SHLIB_EXT}" ]
    then
      show_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib64/libcrypto.${XBB_HOST_SHLIB_EXT}"
    else
      show_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libcrypto.${XBB_HOST_SHLIB_EXT}"
    fi

    if [ -f "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib64/libssl.${XBB_HOST_SHLIB_EXT}" ]
    then
      show_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib64/libssl.${XBB_HOST_SHLIB_EXT}"
    else
      show_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libssl.${XBB_HOST_SHLIB_EXT}"
    fi
  )
}

function test_openssl()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Testing if the openssl binaries start properly..."

    run_app "${test_bin_folder_path}/openssl" version

    rm -rf "${XBB_TESTS_FOLDER_PATH}/openssl"
    mkdir -pv "${XBB_TESTS_FOLDER_PATH}/openssl"; cd "${XBB_TESTS_FOLDER_PATH}/openssl"

    echo "This is a test file" >testfile.txt
    test_expect "SHA256(testfile.txt)= c87e2ca771bab6024c269b933389d2a92d4941c848c52f155b9b84e1f109fe35" "${test_bin_folder_path}/openssl" dgst -sha256 testfile.txt
  )
}

# -----------------------------------------------------------------------------
