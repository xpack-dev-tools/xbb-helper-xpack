#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# binutils should not be used on Darwin, the build is ok, but
# there are functional issues, due to the different ld/as/etc.

function build_binutils()
{
  # https://www.gnu.org/software/binutils/
  # https://ftp.gnu.org/gnu/binutils/

  # https://github.com/archlinux/svntogit-packages/blob/packages/binutils/trunk/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/binutils/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gdb-git

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-binutils
  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-binutils/PKGBUILD

  # mingw-w64
  # https://github.com/archlinux/svntogit-community/blob/packages/mingw-w64-binutils/trunk/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/binutils.rb


  # 2017-07-24, "2.29"
  # 2018-01-28, "2.30"
  # 2018-07-18, "2.31.1"
  # 2019-02-02, "2.32"
  # 2019-10-12, "2.33.1"
  # 2020-02-01, "2.34"
  # 2020-07-24, "2.35"
  # 2020-09-19, "2.35.1"
  # 2021-01-24, "2.36"
  # 2021-01-30, "2.35.2"
  # 2021-02-06, "2.36.1"
  # 2021-07-18, "2.37"
  # 2022-02-09, "2.38"
  # 2022-08-05, "2.39"

  local binutils_version="$1"
  local name_suffix=${2:-''}

  local binutils_src_folder_name="binutils-${binutils_version}"
  local binutils_folder_name="${binutils_src_folder_name}${name_suffix}"

  local binutils_archive="${binutils_src_folder_name}.tar.xz"
  local binutils_url="https://ftp.gnu.org/gnu/binutils/${binutils_archive}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${binutils_folder_name}"

  local binutils_patch_file_name="binutils-${binutils_version}.patch"
  local binutils_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${binutils_folder_name}-installed"
  if [ ! -f "${binutils_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${binutils_url}" "${binutils_archive}" \
      "${binutils_src_folder_name}" "${binutils_patch_file_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${binutils_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${binutils_folder_name}"

      if [ "${name_suffix}" == "${XBB_BOOTSTRAP_SUFFIX}" ]
      then

        CPPFLAGS="${XBB_CPPFLAGS} -I${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/include"
        CFLAGS="${XBB_CFLAGS_NO_W}"
        CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

        LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC} -Wl,-rpath,${XBB_FOLDER_PATH}/lib"

      else
        # To access the newly compiled libraries.
        xbb_activate_installed_dev

        CPPFLAGS="${XBB_CPPFLAGS}"
        CFLAGS="${XBB_CFLAGS_NO_W}"
        CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

        # LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC}"
        LDFLAGS="${XBB_LDFLAGS_APP}"
        xbb_adjust_ldflags_rpath

        if [ "${XBB_HOST_PLATFORM}" == "win32" ]
        then
          if [ "${XBB_HOST_ARCH}" == "x32" -o "${XBB_HOST_ARCH}" == "ia32" ]
          then
            # From MSYS2 MINGW
            LDFLAGS+=" -Wl,--large-address-aware"
          fi

          # Used to enable wildcard; inspired from arm-none-eabi-gcc.
          LDFLAGS+=" -Wl,${XBB_FOLDER_PATH}/usr/${XBB_TARGET_TRIPLET}/lib/CRT_glob.o"
        fi
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
          echo "Running binutils${name_suffix} configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/configure" --help

            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/binutils/configure" --help
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/bfd/configure" --help
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/gas/configure" --help
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/ld/configure" --help
          fi

          # ? --without-python --without-curses, --with-expat
          config_options=()

          if [ "${name_suffix}" == "${XBB_BOOTSTRAP_SUFFIX}" ]
          then

            config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}")
            config_options+=("--with-sysroot=${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}")

            config_options+=("--build=${XBB_BUILD_TRIPLET}")
            # The bootstrap binaries will run on the build machine.
            config_options+=("--host=${XBB_BUILD_TRIPLET}")
            config_options+=("--target=${XBB_TARGET_TRIPLET}")

            config_options+=("--with-pkgversion=${XBB_GCC_BOOTSTRAP_BRANDING}")

            config_options+=("--with-libiconv-prefix=${XBB_FOLDER_PATH}")

            # ?
            config_options+=("--disable-multilib")

            config_options+=("--disable-werror")
            config_options+=("--disable-shared")
            config_options+=("--disable-nls")

            config_options+=("--enable-static")
            config_options+=("--enable-build-warnings=no")
            config_options+=("--enable-lto")
            config_options+=("--enable-plugins")
            config_options+=("--enable-deterministic-archives")
            config_options+=("--enable-libssp")

          else

            config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
            config_options+=("--with-sysroot=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
            # config_options+=("--with-lib-path=/usr/lib:/usr/local/lib")
            config_options+=("--program-suffix=")

            config_options+=("--infodir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/doc/info")
            config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/doc/man")
            config_options+=("--htmldir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/doc/html")
            config_options+=("--pdfdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/doc/pdf")

            config_options+=("--build=${XBB_BUILD_TRIPLET}")
            config_options+=("--host=${XBB_HOST_TRIPLET}")
            config_options+=("--target=${XBB_TARGET_TRIPLET}")

            config_options+=("--with-pkgversion=${XBB_BINUTILS_BRANDING}")

            if [ "${XBB_HOST_PLATFORM}" != "linux" ]
            then
              config_options+=("--with-libiconv-prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
            fi

            # Use the zlib compiled from sources.
            config_options+=("--with-system-zlib") # Arch, HB

            config_options+=("--with-pic") # Arch

            # error: debuginfod is missing or unusable
            # config_options+=("--with-debuginfod") # Arch
            config_options+=("--without-debuginfod")

            if [ "${XBB_HOST_PLATFORM}" == "win32" ]
            then

              config_options+=("--enable-ld")

              config_options+=("--enable-multilib")

              if [ "${XBB_HOST_ARCH}" == "x64" ]
              then
                # From MSYS2 MINGW
                : # config_options+=("--enable-64-bit-bfd")
              fi

            elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
            then

              config_options+=("--enable-ld=default") # Arch

              if [ "${XBB_HOST_ARCH}" == "x64" ]
              then
                config_options+=("--enable-multilib")
              else
                : # No multilib on Arm
              fi

              # config_options+=("--enable-targets=x86_64-pep,bpf-unknown-none")

            elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
            then

              config_options+=("--enable-multilib")

            else
              echo "Unsupported ${XBB_TARGET_PLATFORM}."
              exit 1
            fi

            config_options+=("--enable-64-bit-bfd") # HB
            config_options+=("--enable-cet") # Arch
            config_options+=("--enable-default-execstack=no") # Arch
            config_options+=("--enable-deterministic-archives") # Arch, HB
            config_options+=("--enable-gold") # Arch, HB
            config_options+=("--enable-install-libiberty") # Arch
            config_options+=("--enable-interwork") # HB
            # config_options+=("--enable-jansson") # Arch
            config_options+=("--enable-lto")
            config_options+=("--enable-libssp")
            config_options+=("--enable-pgo-build=lto") # Arch
            config_options+=("--enable-plugins") # Arch, HB
            config_options+=("--enable-relro") # Arch
            config_options+=("--enable-shared") # Arch
            config_options+=("--enable-static")
            config_options+=("--enable-targets=all") # HB
            config_options+=("--enable-threads") # Arch
            config_options+=("--enable-build-warnings=no")

            config_options+=("--disable-debug") # HB
            config_options+=("--disable-dependency-tracking") # HB
            if [ "${XBB_IS_DEVELOP}" == "y" ]
            then
              config_options+=("--disable-silent-rules")
            fi

            config_options+=("--disable-gdb") # Arch
            config_options+=("--disable-gdbserver") # Arch
            config_options+=("--disable-libdecnumber") # Arch
            config_options+=("--disable-readline") # Arch

            # TODO
            # config_options+=("--enable-nls")
            config_options+=("--disable-nls") # HB

            config_options+=("--disable-new-dtags")

            # config_options+=("--disable-multilib")
            config_options+=("--enable-multilib") # HB

            config_options+=("--disable-werror") # Arch, HB
            config_options+=("--disable-sim") # Arch

          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/configure" \
            ${config_options[@]}

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${binutils_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${binutils_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running binutils${name_suffix} make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          : # run_verbose make check
        fi

        # Avoid strip here, it may interfere with patchelf.
        # make install-strip
        run_verbose make install

        # install PIC version of libiberty
        libiberty_file_path="$(find "${XBB_BINARIES_INSTALL_FOLDER_PATH}" -name libiberty.a)"
        if [ -n "${libiberty_file_path}" ]
        then
          run_verbose install -v -c -m 644 libiberty/pic/libiberty.a \
            "$(dirname ${libiberty_file_path})"
        fi

        run_verbose rm -rf "${XBB_BUILD_FOLDER_PATH}/${binutils_folder_name}/doc"

        if [ "${name_suffix}" == "${XBB_BOOTSTRAP_SUFFIX}" ]
        then

          show_native_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_TARGET_TRIPLET}-ar"
          show_native_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_TARGET_TRIPLET}-as"
          show_native_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_TARGET_TRIPLET}-ld"
          show_native_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_TARGET_TRIPLET}-strip"
          show_native_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_TARGET_TRIPLET}-nm"
          show_native_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_TARGET_TRIPLET}-objcopy"
          show_native_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_TARGET_TRIPLET}-objdump"
          show_native_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_TARGET_TRIPLET}-ranlib"
          show_native_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_TARGET_TRIPLET}-size"
          show_native_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_TARGET_TRIPLET}-strings"

        else

          if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then
            : # rm -rv "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/strip"
          fi

          show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/ar"
          show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/as"
          show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/ld"
          show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/strip"
          show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/nm"
          show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/objcopy"
          show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/objdump"
          show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/ranlib"
          show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/size"
          show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/strings"

        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${binutils_folder_name}/make-output-$(ndate).txt"

      if [ -z "${name_suffix}" ]
      then
        copy_license \
          "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}" \
          "${binutils_folder_name}"
      fi

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${binutils_stamp_file_path}"

  else
    echo "Component binutils${name_suffix} already installed."
  fi

  if [ "${name_suffix}" == "${XBB_BOOTSTRAP_SUFFIX}" ]
  then
    :
  else
    tests_add "test_binutils" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
  fi
}

function test_binutils()
{
  local test_bin_path="$1"

  (
    show_libs "${test_bin_path}/ar"
    show_libs "${test_bin_path}/as"
    show_libs "${test_bin_path}/elfedit"
    show_libs "${test_bin_path}/gprof"
    show_libs "${test_bin_path}/ld"
    show_libs "${test_bin_path}/ld.gold"
    show_libs "${test_bin_path}/strip"
    show_libs "${test_bin_path}/nm"
    show_libs "${test_bin_path}/objcopy"
    show_libs "${test_bin_path}/objdump"
    show_libs "${test_bin_path}/ranlib"
    show_libs "${test_bin_path}/readelf"
    show_libs "${test_bin_path}/size"
    show_libs "${test_bin_path}/strings"
    show_libs "${test_bin_path}/strip"

    echo
    echo "Testing if binutils starts properly..."

    run_app "${test_bin_path}/ar" --version
    run_app "${test_bin_path}/as" --version
    run_app "${test_bin_path}/elfedit" --version
    run_app "${test_bin_path}/gprof" --version
    run_app "${test_bin_path}/ld" --version
    if [ -f  "${test_bin_path}/ld.gold${XBB_HOST_DOT_EXE}" ]
    then
      # No ld.gold on Windows.
      run_app "${test_bin_path}/ld.gold" --version
    fi
    run_app "${test_bin_path}/strip" --version
    run_app "${test_bin_path}/nm" --version
    run_app "${test_bin_path}/objcopy" --version
    run_app "${test_bin_path}/objdump" --version
    run_app "${test_bin_path}/ranlib" --version
    run_app "${test_bin_path}/readelf" --version
    run_app "${test_bin_path}/size" --version
    run_app "${test_bin_path}/strings" --version
    run_app "${test_bin_path}/strip" --version
  )

  echo
  echo "Local binutils tests completed successfuly."
}

# -----------------------------------------------------------------------------
