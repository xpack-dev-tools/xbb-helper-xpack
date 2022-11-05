# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function build_findutils()
{
  # https://www.gnu.org/software/findutils/
  # https://ftp.gnu.org/gnu/findutils/
  # https://ftp.gnu.org/gnu/findutils/findutils-4.8.0.tar.xz

  # 2021-01-09, "4.8.0"

  local findutils_version="$1"

  local findutils_src_folder_name="findutils-${findutils_version}"

  local findutils_archive="${findutils_src_folder_name}.tar.xz"
  local findutils_url="https://ftp.gnu.org/gnu/findutils/${findutils_archive}"

  local findutils_folder_name="${findutils_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${findutils_folder_name}"

  local findutils_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${findutils_folder_name}-installed"
  if [ ! -f "${findutils_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${findutils_url}" "${findutils_archive}" \
      "${findutils_src_folder_name}"

    (
      if [ ! -x "${XBB_SOURCES_FOLDER_PATH}/${findutils_src_folder_name}/configure" ]
      then

        cd "${XBB_SOURCES_FOLDER_PATH}/${findutils_src_folder_name}"

        xbb_activate_installed_dev

        run_verbose bash ${DEBUG} "bootstrap.sh"

      fi
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${findutils_folder_name}/autogen-output-$(ndate).txt"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${findutils_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${findutils_folder_name}"

      xbb_activate_installed_dev

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
          echo "Running findutils configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${findutils_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          config_options+=("--build=${XBB_BUILD}")
          # config_options+=("--host=${XBB_HOST}")
          # config_options+=("--target=${XBB_TARGET}")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${findutils_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${findutils_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${findutils_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running findutils make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        show_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/find"

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${findutils_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${findutils_src_folder_name}" \
        "${findutils_folder_name}"

    )

    (
      test_findutils
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${findutils_folder_name}/test-output-$(ndate).txt"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${findutils_stamp_file_path}"

  else
    echo "Component findutils already installed."
  fi
}

function test_findutils()
{
  (
    echo
    echo "Checking the findutils shared libraries..."

    show_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/find"

    echo
    echo "Checking if findutils starts..."
    "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/find" || true
  )
}

# =============================================================================

# binutils should not be used on Darwin, the build is ok, but
# there are functional issues, due to the different ld/as/etc.

function build_native_binutils()
{
  # https://www.gnu.org/software/binutils/
  # https://ftp.gnu.org/gnu/binutils/

  # https://archlinuxarm.org/packages/aarch64/binutils/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gdb-git

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-binutils
  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-binutils/PKGBUILD

  # mingw-w64
  # https://github.com/archlinux/svntogit-community/blob/packages/mingw-w64-binutils/trunk/PKGBUILD


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
  local name_suffix=${2-''}

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

    local binutils_prerequisites_download_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${binutils_folder_name}-prerequisites-downloaded"
    if false # [ ! -f "${binutils_prerequisites_download_stamp_file_path}" ]
    then
      (
        cd "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}"

        # Fool the script to think it is in the gcc folder.
        mkdir -pv gcc
        touch gcc/BASE-VER

        run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${XBB_GCC_SRC_FOLDER_NAME}/contrib/download_prerequisites"  --no-verify

        rm -rf gcc

        mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
        touch "${binutils_prerequisites_download_stamp_file_path}"

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${binutils_folder_name}/prerequisites-download-output-$(ndate).txt"
    fi

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${binutils_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${binutils_folder_name}"

      if [ "${name_suffix}" == "-bootstrap" ]
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

        if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
        then
          if [ "${XBB_TARGET_ARCH}" == "x32" -o "${XBB_TARGET_ARCH}" == "ia32" ]
          then
            # From MSYS2 MINGW
            LDFLAGS+=" -Wl,--large-address-aware"
          fi

          # Used to enable wildcard; inspired from arm-none-eabi-gcc.
          LDFLAGS+=" -Wl,${XBB_FOLDER_PATH}/usr/${XBB_CROSS_COMPILE_PREFIX}/lib/CRT_glob.o"
        elif [ "${XBB_TARGET_PLATFORM}" == "linux" ]
        then
          xbb_activate_cxx_rpath
          LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH:-${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib}"
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

          if [ "${name_suffix}" == "-bootstrap" ]
          then

            config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}")
            config_options+=("--with-sysroot=${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}")

            config_options+=("--build=${XBB_BUILD}")
            # The bootstrap binaries will run on the build machine.
            config_options+=("--host=${XBB_BUILD}")
            config_options+=("--target=${XBB_TARGET}")

            config_options+=("--with-pkgversion=${XBB_GCC_BOOTSTRAP_BRANDING}")

            config_options+=("--with-libiconv-prefix=${XBB_FOLDER_PATH}")

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

            config_options+=("--infodir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/info")
            config_options+=("--mandir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/man")
            config_options+=("--htmldir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/html")
            config_options+=("--pdfdir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/pdf")

            config_options+=("--build=${XBB_BUILD}")
            config_options+=("--host=${XBB_HOST}")
            config_options+=("--target=${XBB_TARGET}")

            config_options+=("--with-pkgversion=${XBB_BINUTILS_BRANDING}")

            if [ "${XBB_TARGET_PLATFORM}" != "linux" ]
            then
              config_options+=("--with-libiconv-prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
            fi

            config_options+=("--without-system-zlib")

            config_options+=("--with-pic")

            # error: debuginfod is missing or unusable
            config_options+=("--without-debuginfod")

            if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
            then

              config_options+=("--enable-ld")

              if [ "${XBB_TARGET_ARCH}" == "x64" ]
              then
                # From MSYS2 MINGW
                config_options+=("--enable-64-bit-bfd")
              fi

              config_options+=("--enable-shared")
              config_options+=("--enable-shared-libgcc")

            elif [ "${XBB_TARGET_PLATFORM}" == "linux" ]
            then

              config_options+=("--enable-ld")

              config_options+=("--disable-shared")
              config_options+=("--disable-shared-libgcc")

            elif [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
            then
              echo
              echo "binutils not supported on macOS"
              exit 1
            else
              echo "Unsupported ${XBB_TARGET_PLATFORM}."
              exit 1
            fi

            config_options+=("--enable-static")

            config_options+=("--enable-gold")
            config_options+=("--enable-lto")
            config_options+=("--enable-libssp")
            config_options+=("--enable-relro")
            config_options+=("--enable-threads")
            config_options+=("--enable-interwork")
            config_options+=("--enable-plugins")
            config_options+=("--enable-build-warnings=no")
            config_options+=("--enable-deterministic-archives")

            # TODO
            # config_options+=("--enable-nls")
            config_options+=("--disable-nls")

            config_options+=("--disable-new-dtags")

            config_options+=("--disable-multilib")
            config_options+=("--disable-werror")
            config_options+=("--disable-sim")

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

        if [ "${name_suffix}" == "-bootstrap" ]
        then

          show_native_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_CROSS_COMPILE_PREFIX}-ar"
          show_native_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_CROSS_COMPILE_PREFIX}-as"
          show_native_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_CROSS_COMPILE_PREFIX}-ld"
          show_native_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_CROSS_COMPILE_PREFIX}-strip"
          show_native_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_CROSS_COMPILE_PREFIX}-nm"
          show_native_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_CROSS_COMPILE_PREFIX}-objcopy"
          show_native_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_CROSS_COMPILE_PREFIX}-objdump"
          show_native_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_CROSS_COMPILE_PREFIX}-ranlib"
          show_native_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_CROSS_COMPILE_PREFIX}-size"
          show_native_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_CROSS_COMPILE_PREFIX}-strings"

        else

          if [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
          then
            : # rm -rv "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/strip"
          fi

          (
            xbb_activate_tex

            if [ "${XBB_WITH_PDF}" == "y" ]
            then
              run_verbose make pdf
              run_verbose make install-pdf
            fi

            if [ "${XBB_WITH_HTML}" == "y" ]
            then
              run_verbose make html
              run_verbose make install-html
            fi
          )

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

  if [ "${name_suffix}" == "-bootstrap" ]
  then
    :
  else
    tests_add "test_native_binutils"
  fi
}

function test_native_binutils()
{
  (
    if [ -d "xpacks/.bin" ]
    then
      XBB_TEST_BIN_PATH="$(pwd)/xpacks/.bin"
    elif [ -d "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin" ]
    then
      XBB_TEST_BIN_PATH="${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
    else
      echo "Wrong folder."
      exit 1
    fi

    show_libs "${XBB_TEST_BIN_PATH}/ar"
    show_libs "${XBB_TEST_BIN_PATH}/as"
    show_libs "${XBB_TEST_BIN_PATH}/elfedit"
    show_libs "${XBB_TEST_BIN_PATH}/gprof"
    show_libs "${XBB_TEST_BIN_PATH}/ld"
    show_libs "${XBB_TEST_BIN_PATH}/ld.gold"
    show_libs "${XBB_TEST_BIN_PATH}/strip"
    show_libs "${XBB_TEST_BIN_PATH}/nm"
    show_libs "${XBB_TEST_BIN_PATH}/objcopy"
    show_libs "${XBB_TEST_BIN_PATH}/objdump"
    show_libs "${XBB_TEST_BIN_PATH}/ranlib"
    show_libs "${XBB_TEST_BIN_PATH}/readelf"
    show_libs "${XBB_TEST_BIN_PATH}/size"
    show_libs "${XBB_TEST_BIN_PATH}/strings"
    show_libs "${XBB_TEST_BIN_PATH}/strip"

    echo
    echo "Testing if binutils starts properly..."

    run_app "${XBB_TEST_BIN_PATH}/ar" --version
    run_app "${XBB_TEST_BIN_PATH}/as" --version
    run_app "${XBB_TEST_BIN_PATH}/elfedit" --version
    run_app "${XBB_TEST_BIN_PATH}/gprof" --version
    run_app "${XBB_TEST_BIN_PATH}/ld" --version
    if [ -f  "${XBB_TEST_BIN_PATH}/ld.gold${XBB_DOT_EXE}" ]
    then
      # No ld.gold on Windows.
      run_app "${XBB_TEST_BIN_PATH}/ld.gold" --version
    fi
    run_app "${XBB_TEST_BIN_PATH}/strip" --version
    run_app "${XBB_TEST_BIN_PATH}/nm" --version
    run_app "${XBB_TEST_BIN_PATH}/objcopy" --version
    run_app "${XBB_TEST_BIN_PATH}/objdump" --version
    run_app "${XBB_TEST_BIN_PATH}/ranlib" --version
    run_app "${XBB_TEST_BIN_PATH}/readelf" --version
    run_app "${XBB_TEST_BIN_PATH}/size" --version
    run_app "${XBB_TEST_BIN_PATH}/strings" --version
    run_app "${XBB_TEST_BIN_PATH}/strip" --version
  )

  echo
  echo "Local binutils tests completed successfuly."
}

# -----------------------------------------------------------------------------

# Environment variables:
# XBB_BINUTILS_VERSION
# XBB_BINUTILS_SRC_FOLDER_NAME
# XBB_BINUTILS_ARCHIVE_NAME
# XBB_BINUTILS_URL

# https://github.com/archlinux/svntogit-community/blob/packages/arm-none-eabi-binutils/trunk/PKGBUILD
# https://github.com/archlinux/svntogit-community/blob/packages/riscv32-elf-binutils/trunk/PKGBUILD

function build_cross_binutils()
{
  # https://ftp.gnu.org/gnu/binutils/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=binutils-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gdb-git

  local binutils_folder_name="binutils-${XBB_BINUTILS_VERSION}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${binutils_folder_name}"

  local binutils_patch="${binutils_folder_name}.patch"
  local binutils_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${binutils_folder_name}-installed"
  if [ ! -f "${binutils_stamp_file_path}" ]
  then

    # Download binutils.
    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"
    download_and_extract "${XBB_BINUTILS_ARCHIVE_URL}" "${XBB_BINUTILS_ARCHIVE_NAME}" \
        "${XBB_BINUTILS_SRC_FOLDER_NAME}" "${binutils_patch}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${binutils_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${binutils_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS} -UFORTIFY_SOURCE" # ABE
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP}"
      if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
      then
        LDFLAGS+=" -Wl,${XBB_FOLDER_PATH}/mingw/lib/CRT_glob.o"
      elif [ "${XBB_TARGET_PLATFORM}" == "linux" ]
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
          echo "Running cross binutils configure..."

          bash "${XBB_SOURCES_FOLDER_PATH}/${XBB_BINUTILS_SRC_FOLDER_NAME}/configure" --help

          # 11.2-2022.02-darwin-x86_64-arm-none-eabi-manifest.txt:
          # binutils_configure='--enable-initfini-array --disable-nls
          # --without-x --disable-gdbtk --without-tcl --without-tk
          # --enable-plugins --disable-gdb --without-gdb --target=arm-none-eabi
          # --prefix=/'

          # 11.2-2022.02-darwin-x86_64-aarch64-none-elf-manifest.txt
          # binutils_configure='--enable-64-bit-bfd
          # --enable-targets=arm-none-eabi,aarch64-none-linux-gnu,aarch64-none-elf
          # --enable-initfini-array --disable-nls --without-x --disable-gdbtk
          # --without-tcl --without-tk --enable-plugins --disable-gdb
          # --without-gdb --target=aarch64-none-elf --prefix=/'

          # ? --without-python --without-curses, --with-expat

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--infodir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/info")
          config_options+=("--mandir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/man")
          config_options+=("--htmldir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/html")
          config_options+=("--pdfdir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/pdf")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_GCC_TARGET}")

          config_options+=("--disable-nls") # Arm, AArch64
          config_options+=("--disable-gdb") # Arm, AArch64
          config_options+=("--disable-gdbtk") # Arm, AArch64

          config_options+=("--disable-sim")
          config_options+=("--disable-werror")

          config_options+=("--enable-initfini-array") # Arm, AArch64
          config_options+=("--enable-lto")
          config_options+=("--enable-plugins") # Arm, AArch64
          config_options+=("--enable-build-warnings=no")

          if [ "${XBB_GCC_TARGET}" == "aarch64-none-elf" ]
          then
            config_options+=("--enable-64-bit-bfd") # AArch64
            config_options+=("--enable-targets=arm-none-eabi,aarch64-none-linux-gnu,aarch64-none-elf") # AArch64
          fi

          config_options+=("--without-gdb") # Arm, AArch64
          config_options+=("--without-x") # Arm, AArch64
          config_options+=("--without-tcl") # Arm, AArch64
          config_options+=("--without-tk") # Arm, AArch64

          config_options+=("--with-pkgversion=${XBB_BRANDING}")
          config_options+=("--with-system-zlib")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${XBB_BINUTILS_SRC_FOLDER_NAME}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${binutils_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${binutils_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running cross binutils make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          if [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
          then
            # /bin/bash: DSYMUTIL@: command not found
            :
          else
            run_verbose make check
          fi
        fi

        # Avoid strip here, it may interfere with patchelf.
        # make install-strip
        run_verbose make install

        (
          xbb_activate_tex

          if [ "${XBB_WITH_PDF}" == "y" ]
          then
            run_verbose make pdf
            run_verbose make install-pdf
          fi

          if [ "${XBB_WITH_HTML}" == "y" ]
          then
            run_verbose make html
            run_verbose make install-html
          fi
        )

        if [ -n "${APP_PREFIX_NANO:-}" ]
        then
          # Without this copy, the build for the nano version of the GCC second
          # step fails with unexpected errors, like "cannot compute suffix of
          # object files: cannot compile".
          copy_dir "${XBB_BINARIES_INSTALL_FOLDER_PATH}" "${APP_PREFIX_NANO}"
        fi

        show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/${XBB_GCC_TARGET}-ar"
        show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/${XBB_GCC_TARGET}-as"
        show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/${XBB_GCC_TARGET}-ld"
        show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/${XBB_GCC_TARGET}-nm"
        show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/${XBB_GCC_TARGET}-objcopy"
        show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/${XBB_GCC_TARGET}-objdump"
        show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/${XBB_GCC_TARGET}-ranlib"
        show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/${XBB_GCC_TARGET}-size"
        show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/${XBB_GCC_TARGET}-strings"
        show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/${XBB_GCC_TARGET}-strip"

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${binutils_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${XBB_BINUTILS_SRC_FOLDER_NAME}" \
        "${binutils_folder_name}"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${binutils_stamp_file_path}"

  else
    echo "Component cross binutils already installed."
  fi

  tests_add "test_cross_binutils"
}

function test_cross_binutils()
{
  (
    if [ -d "xpacks/.bin" ]
    then
      XBB_TEST_BIN_PATH="$(pwd)/xpacks/.bin"
    elif [ -d "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin" ]
    then
      XBB_TEST_BIN_PATH="${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
    else
      echo "Wrong folder."
      exit 1
    fi

    show_libs "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-ar"
    show_libs "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-as"
    show_libs "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-ld"
    show_libs "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-nm"
    show_libs "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-objcopy"
    show_libs "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-objdump"
    show_libs "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-ranlib"
    show_libs "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-size"
    show_libs "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-strings"
    show_libs "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-strip"

    run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-ar" --version
    run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-as" --version
    run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-ld" --version
    run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-nm" --version
    run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-objcopy" --version
    run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-objdump" --version
    run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-ranlib" --version
    run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-size" --version
    run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-strings" --version
    run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-strip" --version
  )
}

# -----------------------------------------------------------------------------

function define_flags_for_target()
{
  local optimize="${CFLAGS_OPTIMIZATIONS_FOR_TARGET}"
  if [ "$1" == "" ]
  then
    # For newlib, optimize for speed.
    optimize="$(echo ${optimize} | sed -e 's/-O[123]/-O2/g')"
    # DO NOT make this explicit, since exceptions references will always be
    # inserted in the `extab` section.
    # optimize+=" -fexceptions"
  elif [ "$1" == "-nano" ]
  then
    # For newlib-nano optimize for size and disable exceptions.
    optimize="$(echo ${optimize} | sed -e 's/-O[123]/-Os/g')"
    optimize="$(echo ${optimize} | sed -e 's/-Ofast/-Os/p')"
    optimize+=" -fno-exceptions"
  fi

  CFLAGS_FOR_TARGET="${optimize}"
  CXXFLAGS_FOR_TARGET="${optimize}"
  if [ "${XBB_IS_DEBUG}" == "y" ]
  then
    # Avoid `-g`, many local symbols cannot be removed by strip.
    CFLAGS_FOR_TARGET+=" -g"
    CXXFLAGS_FOR_TARGET+=" -g"
  fi

  if [ "${XBB_WITH_LIBS_LTO:-}" == "y" ]
  then
    CFLAGS_FOR_TARGET+=" -flto -ffat-lto-objects"
    CXXFLAGS_FOR_TARGET+=" -flto -ffat-lto-objects"
  fi

  LDFLAGS_FOR_TARGET="--specs=nosys.specs"
}

# -----------------------------------------------------------------------------

function download_cross_gcc()
{
  if [ ! -d "${XBB_SOURCES_FOLDER_PATH}/${XBB_GCC_SRC_FOLDER_NAME}" ]
  then
    (
      mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

      download_and_extract "${XBB_GCC_ARCHIVE_URL}" \
        "${XBB_GCC_ARCHIVE_NAME}" "${XBB_GCC_SRC_FOLDER_NAME}" \
        "${XBB_GCC_PATCH_FILE_NAME}"
    )
  fi
}

# Environment variables:
# XBB_GCC_VERSION
# XBB_GCC_SRC_FOLDER_NAME
# XBB_GCC_ARCHIVE_URL
# XBB_GCC_ARCHIVE_NAME
# XBB_GCC_PATCH_FILE_NAME

# https://github.com/archlinux/svntogit-community/blob/packages/arm-none-eabi-gcc/trunk/PKGBUILD
# https://github.com/archlinux/svntogit-community/blob/packages/riscv64-elf-gcc/trunk/PKGBUILD

function build_cross_gcc_first()
{
  local gcc_first_folder_name="gcc-${XBB_GCC_VERSION}-first"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${gcc_first_folder_name}"

  local gcc_first_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${gcc_first_folder_name}-installed"
  if [ ! -f "${gcc_first_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_cross_gcc

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${gcc_first_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${gcc_first_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
      then
        # The CFLAGS are set in XBB_CFLAGS, but for C++ it must be selective.
        # Without it gcc cannot identify cc1 and other binaries
        CXXFLAGS+=" -D__USE_MINGW_ACCESS"
      fi
      LDFLAGS="${XBB_LDFLAGS_APP}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        xbb_activate_cxx_rpath
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      define_flags_for_target ""

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      export CFLAGS_FOR_TARGET
      export CXXFLAGS_FOR_TARGET
      export LDFLAGS_FOR_TARGET

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running cross gcc first stage configure..."

          bash "${XBB_SOURCES_FOLDER_PATH}/${XBB_GCC_SRC_FOLDER_NAME}/configure" --help

          # 11.2-2022.02-darwin-x86_64-arm-none-eabi-manifest.txt:
          # gcc1_configure='--target=arm-none-eabi
          # --prefix=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-arm-none-eabi/install//
          # --with-gmp=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-arm-none-eabi/host-tools
          # --with-mpfr=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-arm-none-eabi/host-tools
          # --with-mpc=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-arm-none-eabi/host-tools
          # --with-isl=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-arm-none-eabi/host-tools
          # --disable-shared --disable-nls --disable-threads --disable-tls
          # --enable-checking=release --enable-languages=c --without-cloog
          # --without-isl --with-newlib --without-headers
          # --with-multilib-list=aprofile,rmprofile'

          # 11.2-2022.02-darwin-x86_64-aarch64-none-elf-manifest.txt
          # gcc1_configure='--target=aarch64-none-elf
          # --prefix=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-aarch64-none-elf/install//
          # --with-gmp=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-aarch64-none-elf/host-tools
          # --with-mpfr=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-aarch64-none-elf/host-tools
          # --with-mpc=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-aarch64-none-elf/host-tools
          # --with-isl=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-aarch64-none-elf/host-tools
          # --disable-shared --disable-nls --disable-threads --disable-tls
          # --enable-checking=release --enable-languages=c --without-cloog
          # --without-isl --with-newlib --without-headers'

          # From: https://gcc.gnu.org/install/configure.html
          # --enable-shared[=package[,…]] build shared versions of libraries
          # --enable-tls specify that the target supports TLS (Thread Local Storage).
          # --enable-nls enables Native Language Support (NLS)
          # --enable-checking=list the compiler is built to perform internal consistency checks of the requested complexity. ‘yes’ (most common checks)
          # --with-headers=dir specify that target headers are available when building a cross compiler
          # --with-newlib Specifies that ‘newlib’ is being used as the target C library. This causes `__eprintf`` to be omitted from `libgcc.a`` on the assumption that it will be provided by newlib.
          # --enable-languages=c newlib does not use C++, so C should be enough

          # --enable-checking=no ???

          # --enable-lto make it explicit, Arm uses the default.

          # Prefer an explicit libexec folder.
          # --libexecdir="${XBB_BINARIES_INSTALL_FOLDER_PATH}/lib"

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--infodir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/info")
          config_options+=("--mandir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/man")
          config_options+=("--htmldir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/html")
          config_options+=("--pdfdir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/pdf")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_GCC_TARGET}")

          config_options+=("--disable-libgomp") # ABE
          config_options+=("--disable-libmudflap") # ABE
          config_options+=("--disable-libquadmath") # ABE
          config_options+=("--disable-libsanitizer") # ABE
          config_options+=("--disable-libssp") # ABE

          config_options+=("--disable-nls") # Arm, AArch64
          config_options+=("--disable-shared") # Arm, AArch64
          config_options+=("--disable-threads") # Arm, AArch64
          config_options+=("--disable-tls") # Arm, AArch64

          config_options+=("--enable-checking=release") # Arm, AArch64
          config_options+=("--enable-languages=c") # Arm, AArch64
          # config_options+=("--enable-lto") # ABE

          config_options+=("--without-cloog") # Arm, AArch64
          config_options+=("--without-headers") # Arm, AArch64
          config_options+=("--without-isl") # Arm, AArch64

          config_options+=("--with-gnu-as") # Arm, ABE
          config_options+=("--with-gnu-ld") # Arm, ABE

          config_options+=("--with-gmp=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}") # AArch64
          config_options+=("--with-pkgversion=${XBB_BRANDING}")
          config_options+=("--with-newlib") # Arm, AArch64

          config_options+=("--with-system-zlib")

          if [ "${XBB_GCC_TARGET}" == "arm-none-eabi" ]
          then
            config_options+=("--disable-libatomic") # ABE

            if [ "${XBB_WITHOUT_MULTILIB}" == "y" ]
            then
              config_options+=("--disable-multilib")
            else
              config_options+=("--enable-multilib") # Arm
              config_options+=("--with-multilib-list=${XBB_GCC_MULTILIB_LIST}")  # Arm
            fi
          elif [ "${XBB_GCC_TARGET}" == "riscv-none-elf" ]
          then
            config_options+=("--with-abi=${XBB_GCC_ABI}")
            config_options+=("--with-arch=${XBB_GCC_ARCH}")

            if [ "${XBB_WITHOUT_MULTILIB}" == "y" ]
            then
              config_options+=("--disable-multilib")
            else
              config_options+=("--enable-multilib")
            fi
          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${XBB_GCC_SRC_FOLDER_NAME}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${gcc_first_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gcc_first_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        # Partial build, without documentation.
        echo
        echo "Running cross gcc first stage make..."

        # No need to make 'all', 'all-gcc' is enough to compile the libraries.
        # Parallel builds may fail.
        run_verbose make -j ${XBB_JOBS} all-gcc
        # make all-gcc

        # No -strip available here.
        run_verbose make install-gcc

        # Strip?

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gcc_first_folder_name}/make-output-$(ndate).txt"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${gcc_first_stamp_file_path}"

  else
    echo "Component cross gcc first stage already installed."
  fi
}

# -----------------------------------------------------------------------------

# Environment variables:
# XBB_NEWLIB_VERSION
# XBB_NEWLIB_SRC_FOLDER_NAME
# XBB_NEWLIB_ARCHIVE_URL
# XBB_NEWLIB_ARCHIVE_NAME

# https://github.com/archlinux/svntogit-community/blob/packages/arm-none-eabi-newlib/trunk/PKGBUILD
# https://github.com/archlinux/svntogit-community/blob/packages/riscv32-elf-newlib/trunk/PKGBUILD

# For the nano build, call it with "-nano".
# $1="" or $1="-nano"
function build_cross_newlib()
{
  local name_suffix=${1-''}
  local newlib_folder_name="newlib-${XBB_NEWLIB_VERSION}${name_suffix}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${newlib_folder_name}"

  local newlib_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${newlib_folder_name}-installed"
  if [ ! -f "${newlib_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    if [ ! -d "${XBB_NEWLIB_SRC_FOLDER_NAME}" ]
    then
      download_and_extract "${XBB_NEWLIB_ARCHIVE_URL}" "${XBB_NEWLIB_ARCHIVE_NAME}" \
      "${XBB_NEWLIB_SRC_FOLDER_NAME}"

      if [ "${XBB_ENABLE_NEWLIB_RISCV_NANO_CXX_PATCH:-""}" == "y" ]
      then
        echo
        echo "Patching nano.specs..."

        local nano_specs_file_path="${XBB_NEWLIB_SRC_FOLDER_NAME}/libgloss/riscv/nano.specs"
        if grep "%(nano_link)" "${nano_specs_file_path}" | grep -q "%:replace-outfile(-lstdc++ -lstdc++_nano)"
        then
          echo "-lstdc++_nano already in"
        else
          run_verbose sed -i.bak \
            -e 's|^\(%(nano_link) .*\)$|\1 %:replace-outfile(-lstdc++ -lstdc++_nano)|' \
            "${nano_specs_file_path}"
        fi
        if grep "%(nano_link)" "${nano_specs_file_path}" | grep -q "%:replace-outfile(-lsupc++ -lsupc++_nano)"
        then
          echo "-lsupc++_nano already in"
        else
          run_verbose sed -i.bak \
            -e 's|^\(%(nano_link) .*\)$|\1 %:replace-outfile(-lsupc++ -lsupc++_nano)|' \
            "${nano_specs_file_path}"
        fi
      fi
      # exit 1
    fi

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${newlib_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${newlib_folder_name}"

      xbb_activate_installed_dev

      # Add the gcc first stage binaries to the path.
      PATH="${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin:${PATH}"

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      define_flags_for_target "${name_suffix}"

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS

      export CFLAGS_FOR_TARGET
      export CXXFLAGS_FOR_TARGET
      export LDFLAGS_FOR_TARGET

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          # --disable-nls do not use Native Language Support
          # --enable-newlib-io-long-double   enable long double type support in IO functions printf/scanf
          # --enable-newlib-io-long-long   enable long long type support in IO functions like printf/scanf
          # --enable-newlib-io-c99-formats   enable C99 support in IO functions like printf/scanf
          # --enable-newlib-register-fini   enable finalization function registration using atexit
          # --disable-newlib-supplied-syscalls disable newlib from supplying syscalls (__NO_SYSCALLS__)

          # --disable-newlib-fvwrite-in-streamio    disable iov in streamio
          # --disable-newlib-fseek-optimization    disable fseek optimization
          # --disable-newlib-wide-orient    Turn off wide orientation in streamio
          # --disable-newlib-unbuf-stream-opt    disable unbuffered stream optimization in streamio
          # --enable-newlib-nano-malloc    use small-footprint nano-malloc implementation
          # --enable-lite-exit	enable light weight exit
          # --enable-newlib-global-atexit	enable atexit data structure as global
          # --enable-newlib-nano-formatted-io    Use nano version formatted IO
          # --enable-newlib-reent-small

          # --enable-newlib-retargetable-locking ???

          echo
          echo "Running cross newlib${name_suffix} configure..."

          bash "${XBB_SOURCES_FOLDER_PATH}/${XBB_NEWLIB_SRC_FOLDER_NAME}/configure" --help

          config_options=()

          if [ "${name_suffix}" == "" ]
          then

            # 11.2-2022.02-darwin-x86_64-arm-none-eabi-manifest.txt:
            # newlib_configure=' --disable-newlib-supplied-syscalls
            # --enable-newlib-io-long-long --enable-newlib-io-c99-formats
            # --enable-newlib-mb --enable-newlib-reent-check-verify
            # --target=arm-none-eabi --prefix=/'

            # 11.2-2022.02-darwin-x86_64-aarch64-none-elf-manifest.txt
            # newlib_configure=' --disable-newlib-supplied-syscalls
            # --enable-newlib-io-long-long --enable-newlib-io-c99-formats
            # --enable-newlib-mb --enable-newlib-reent-check-verify
            # --target=aarch64-none-elf --prefix=/'

            config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
            config_options+=("--infodir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/info")
            config_options+=("--mandir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/man")
            config_options+=("--htmldir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/html")
            config_options+=("--pdfdir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/pdf")

            config_options+=("--build=${XBB_BUILD}")
            config_options+=("--host=${XBB_HOST}")
            config_options+=("--target=${XBB_GCC_TARGET}")

            config_options+=("--disable-newlib-supplied-syscalls") # Arm, AArch64

            config_options+=("--enable-newlib-io-c99-formats") # Arm, AArch64

            config_options+=("--enable-newlib-io-long-long") # Arm, AArch64
            config_options+=("--enable-newlib-mb") # Arm, AArch64
            config_options+=("--enable-newlib-reent-check-verify") # Arm, AArch64

            config_options+=("--enable-newlib-register-fini") # Arm

            config_options+=("--enable-newlib-retargetable-locking") # Arm

            run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${XBB_NEWLIB_SRC_FOLDER_NAME}/configure" \
              "${config_options[@]}"

          elif [ "${name_suffix}" == "-nano" ]
          then

            # 11.2-2022.02-darwin-x86_64-arm-none-eabi-manifest.txt:
            # newlib_nano_configure=' --disable-newlib-supplied-syscalls
            # --enable-newlib-nano-malloc --disable-newlib-unbuf-stream-opt
            # --enable-newlib-reent-small --disable-newlib-fseek-optimization
            # --enable-newlib-nano-formatted-io
            # --disable-newlib-fvwrite-in-streamio --disable-newlib-wide-orient
            # --enable-lite-exit --enable-newlib-global-atexit
            # --enable-newlib-reent-check-verify
            # --target=arm-none-eabi --prefix=/'

            # --enable-newlib-io-long-long and --enable-newlib-io-c99-formats
            # are currently ignored if --enable-newlib-nano-formatted-io.
            # --enable-newlib-register-fini is debatable, was removed.

            config_options+=("--prefix=${APP_PREFIX_NANO}")

            config_options+=("--build=${XBB_BUILD}")
            config_options+=("--host=${XBB_HOST}")
            config_options+=("--target=${XBB_GCC_TARGET}")

            config_options+=("--disable-newlib-fseek-optimization") # Arm
            config_options+=("--disable-newlib-fvwrite-in-streamio") # Arm

            config_options+=("--disable-newlib-supplied-syscalls") # Arm
            config_options+=("--disable-newlib-unbuf-stream-opt") # Arm
            config_options+=("--disable-newlib-wide-orient") # Arm

            config_options+=("--enable-lite-exit") # Arm
            config_options+=("--enable-newlib-global-atexit") # Arm
            config_options+=("--enable-newlib-nano-formatted-io") # Arm
            config_options+=("--enable-newlib-nano-malloc") # Arm
            config_options+=("--enable-newlib-reent-check-verify") # Arm
            config_options+=("--enable-newlib-reent-small") # Arm

            config_options+=("--enable-newlib-retargetable-locking") # Arm

            run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${XBB_NEWLIB_SRC_FOLDER_NAME}/configure" \
              "${config_options[@]}"

          else
            echo "Unsupported build_cross_newlib name_suffix '${name_suffix}'"
            exit 1
          fi

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${newlib_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${newlib_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        # Partial build, without documentation.
        echo
        echo "Running cross newlib${name_suffix} make..."

        # Parallel builds may fail.
        run_verbose make -j ${XBB_JOBS}
        # make

        # Top make fails with install-strip due to libgloss make.
        run_verbose make install

        if [ "${name_suffix}" == "" ]
        then

          if [ "${XBB_WITH_PDF}" == "y" ]
          then

            xbb_activate_tex

            # Warning, parallel build failed on Debian 32-bit.
            run_verbose make pdf

            install -v -d "${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/pdf"

            install -v -c -m 644 \
              "${XBB_GCC_TARGET}/libgloss/doc/porting.pdf" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/pdf"
            install -v -c -m 644 \
              "${XBB_GCC_TARGET}/newlib/libc/libc.pdf" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/pdf"
            install -v -c -m 644 \
              "${XBB_GCC_TARGET}/newlib/libm/libm.pdf" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/pdf"

          fi

          if [ "${XBB_WITH_HTML}" == "y" ]
          then

            run_verbose make html

            install -v -d "${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/html"

            copy_dir "${XBB_GCC_TARGET}/newlib/libc/libc.html" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/html/libc"
            copy_dir "${XBB_GCC_TARGET}/newlib/libm/libm.html" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/html/libm"

          fi

        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${newlib_folder_name}/make-output-$(ndate).txt"

      if [ "${name_suffix}" == "" ]
      then
        copy_license \
          "${XBB_SOURCES_FOLDER_PATH}/${XBB_NEWLIB_SRC_FOLDER_NAME}" \
          "${newlib_folder_name}"
      fi

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${newlib_stamp_file_path}"

  else
    echo "Component cross newlib$1 already installed."
  fi
}

# -----------------------------------------------------------------------------

function copy_cross_nano_libs()
{
  local src_folder="$1"
  local dst_folder="$2"

  # Copy the nano variants with a distinct name, as used in nano.specs.
  cp -v -f "${src_folder}/libc.a" "${dst_folder}/libc_nano.a"
  cp -v -f "${src_folder}/libg.a" "${dst_folder}/libg_nano.a"
  cp -v -f "${src_folder}/libm.a" "${dst_folder}/libm_nano.a"


  cp -v -f "${src_folder}/libstdc++.a" "${dst_folder}/libstdc++_nano.a"
  cp -v -f "${src_folder}/libsupc++.a" "${dst_folder}/libsupc++_nano.a"

  if [ -f "${src_folder}/libgloss.a" ]
  then
    cp -v -f "${src_folder}/libgloss.a" "${dst_folder}/libgloss_nano.a"
  fi

  if [ -f "${src_folder}/librdimon.a" ]
  then
    cp -v -f "${src_folder}/librdimon.a" "${dst_folder}/librdimon_nano.a"
  fi

  if [ -f "${src_folder}/librdimon-v2m.a" ]
  then
    cp -v -f "${src_folder}/librdimon-v2m.a" "${dst_folder}/lrdimon-v2m_nano.a"
  fi
}

# Copy target libraries from each multilib folders.
# $1=source
# $2=destination
# $3=target gcc
function copy_cross_multi_libs()
{
  local -a multilibs
  local multilib
  local multi_folder
  local src_folder="$1"
  local dst_folder="$2"
  local gcc_target="$3"

  echo ${gcc_target}
  multilibs=( $("${gcc_target}" -print-multi-lib 2>/dev/null) )
  if [ ${#multilibs[@]} -gt 0 ]
  then
    for multilib in "${multilibs[@]}"
    do
      multi_folder="${multilib%%;*}"
      copy_cross_nano_libs "${src_folder}/${multi_folder}" \
        "${dst_folder}/${multi_folder}"
    done
  else
    copy_cross_nano_libs "${src_folder}" "${dst_folder}"
  fi
}

# -----------------------------------------------------------------------------

function copy_cross_linux_libs()
{
  local copy_linux_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-copy-linux-completed"
  if [ ! -f "${copy_linux_stamp_file_path}" ]
  then

    local linux_path="${LINUX_INSTALL_RELATIVE_PATH}/${XBB_APPLICATION_LOWER_CASE_NAME}"

    (
      cd "${XBB_TARGET_WORK_FOLDER_PATH}"

      copy_dir "${linux_path}/${XBB_GCC_TARGET}/lib" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/${XBB_GCC_TARGET}/lib"
      copy_dir "${linux_path}/${XBB_GCC_TARGET}/include" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/${XBB_GCC_TARGET}/include"
      copy_dir "${linux_path}/include" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/include"
      copy_dir "${linux_path}/lib" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/lib"
      copy_dir "${linux_path}/share" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/share"
    )

    (
      cd "${XBB_BINARIES_INSTALL_FOLDER_PATH}"
      find "${XBB_GCC_TARGET}/lib" "${XBB_GCC_TARGET}/include" "include" "lib" "share" \
        -perm /111 -and ! -type d \
        -exec rm '{}' ';'
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${copy_linux_stamp_file_path}"

  else
    echo "Component copy-linux-libs already processed."
  fi
}

# -----------------------------------------------------------------------------

function add_cross_linux_install_path()
{
  # Verify that the compiler is there.
  "${XBB_TARGET_WORK_FOLDER_PATH}/${LINUX_INSTALL_RELATIVE_PATH}/${XBB_APPLICATION_LOWER_CASE_NAME}/bin/${XBB_GCC_TARGET}-gcc" --version

  export PATH="${XBB_TARGET_WORK_FOLDER_PATH}/${LINUX_INSTALL_RELATIVE_PATH}/${XBB_APPLICATION_LOWER_CASE_NAME}/bin:${PATH}"
  echo ${PATH}
}

# Environment variables:
# XBB_GCC_VERSION
# XBB_GCC_SRC_FOLDER_NAME
# XBB_GCC_ARCHIVE_URL
# XBB_GCC_ARCHIVE_NAME
# XBB_GCC_PATCH_FILE_NAME

# For the nano build, call it with "-nano".
# $1="" or $1="-nano"
function build_cross_gcc_final()
{
  local name_suffix=${1-''}

  local gcc_final_folder_name="gcc-${XBB_GCC_VERSION}-final${name_suffix}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${gcc_final_folder_name}"

  local gcc_final_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${gcc_final_folder_name}-installed"
  if [ ! -f "${gcc_final_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_cross_gcc

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${gcc_final_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${gcc_final_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      # if [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
      # then
      #   # Hack to avoid spurious errors like:
      #   # fatal error: bits/nested_exception.h: No such file or directory
      #   CPPFLAGS+=" -I${XBB_BUILD_FOLDER_PATH}/${gcc_final_folder_name}/${XBB_GCC_TARGET}/libstdc++-v3/include"
      # fi
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
      then
        # The CFLAGS are set in XBB_CFLAGS, but for C++ it must be selective.
        # Without it gcc cannot identify cc1 and other binaries
        CXXFLAGS+=" -D__USE_MINGW_ACCESS"

        # Hack to prevent "too many sections", "File too big" etc in insn-emit.c
        CXXFLAGS=$(echo ${CXXFLAGS} | sed -e 's|-ffunction-sections -fdata-sections||')
      fi

      LDFLAGS="${XBB_LDFLAGS_APP}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        xbb_activate_cxx_rpath
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi
      # Do not add CRT_glob.o here, it will fail with already defined,
      # since it is already handled by --enable-mingw-wildcard.

      define_flags_for_target "${name_suffix}"

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      export CFLAGS_FOR_TARGET
      export CXXFLAGS_FOR_TARGET
      export LDFLAGS_FOR_TARGET

      if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
      then
        add_cross_linux_install_path

        export AR_FOR_TARGET=${XBB_GCC_TARGET}-ar
        export NM_FOR_TARGET=${XBB_GCC_TARGET}-nm
        export OBJDUMP_FOR_TARET=${XBB_GCC_TARGET}-objdump
        export STRIP_FOR_TARGET=${XBB_GCC_TARGET}-strip
        export CC_FOR_TARGET=${XBB_GCC_TARGET}-gcc
        export GCC_FOR_TARGET=${XBB_GCC_TARGET}-gcc
        export CXX_FOR_TARGET=${XBB_GCC_TARGET}-g++
      fi

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running cross gcc${name_suffix} final stage configure..."

          bash "${XBB_SOURCES_FOLDER_PATH}/${XBB_GCC_SRC_FOLDER_NAME}/configure" --help

          # https://gcc.gnu.org/install/configure.html
          # --enable-shared[=package[,…]] build shared versions of libraries
          # --enable-tls specify that the target supports TLS (Thread Local Storage).
          # --enable-nls enables Native Language Support (NLS)
          # --enable-checking=list the compiler is built to perform internal consistency checks of the requested complexity. ‘yes’ (most common checks)
          # --with-headers=dir specify that target headers are available when building a cross compiler
          # --with-newlib Specifies that ‘newlib’ is being used as the target C library. This causes `__eprintf`` to be omitted from `libgcc.a`` on the assumption that it will be provided by newlib.
          # --enable-languages=c,c++ Support only C/C++, ignore all other.

          # Prefer an explicit libexec folder.
          # --libexecdir="${XBB_BINARIES_INSTALL_FOLDER_PATH}/lib" \

          # --enable-lto make it explicit, Arm uses the default.
          # --with-native-system-header-dir is needed to locate stdio.h, to
          # prevent -Dinhibit_libc, which will skip some functionality,
          # like libgcov.

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}")
          if [ "${name_suffix}" == "" ]
          then
            config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
            config_options+=("--infodir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/info")
            config_options+=("--mandir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/man")
            config_options+=("--htmldir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/html")
            config_options+=("--pdfdir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/pdf")
          elif [ "${name_suffix}" == "-nano" ]
          then
            config_options+=("--prefix=${APP_PREFIX_NANO}")
          else
            echo "Unsupported name_suffix '${name_suffix}'"
            exit 1
          fi

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_GCC_TARGET}")

          config_options+=("--disable-libgomp") # ABE
          config_options+=("--disable-libmudflap") # ABE
          config_options+=("--disable-libquadmath") # ABE
          config_options+=("--disable-libsanitizer") # ABE
          config_options+=("--disable-libssp") # ABE

          config_options+=("--disable-nls") # Arm, AArch64
          config_options+=("--disable-shared") # Arm, AArch64
          config_options+=("--disable-threads") # Arm, AArch64
          config_options+=("--disable-tls") # Arm, AArch64

          config_options+=("--enable-checking=release") # Arm, AArch64
          config_options+=("--enable-languages=c,c++,fortran") # Arm, AArch64

          if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
          then
            config_options+=("--enable-mingw-wildcard")
          fi

          config_options+=("--with-gmp=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}") # AArch64

          config_options+=("--with-newlib") # Arm, AArch64
          config_options+=("--with-pkgversion=${XBB_BRANDING}")

          config_options+=("--with-gnu-as") # Arm ABE
          config_options+=("--with-gnu-ld") # Arm ABE

          config_options+=("--with-system-zlib")

          # `${with_sysroot}${native_system_header_dir}/stdio.h`
          # is checked for presence; if not present `inhibit_libc=true` and
          # libgcov.a is compiled with empty functions.
          # https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/issues/1
          config_options+=("--with-sysroot=${XBB_BINARIES_INSTALL_FOLDER_PATH}/${XBB_GCC_TARGET}")
          config_options+=("--with-native-system-header-dir=/include")

          if [ "${XBB_GCC_TARGET}" == "arm-none-eabi" ]
          then
            config_options+=("--disable-libatomic") # ABE

            if [ "${XBB_WITHOUT_MULTILIB}" == "y" ]
            then
              config_options+=("--disable-multilib")
            else
              config_options+=("--enable-multilib") # Arm
              config_options+=("--with-multilib-list=${XBB_GCC_MULTILIB_LIST}")  # Arm
            fi
          elif [ "${XBB_GCC_TARGET}" == "riscv-none-elf" ]
          then
            config_options+=("--with-abi=${XBB_GCC_ABI}")
            config_options+=("--with-arch=${XBB_GCC_ARCH}")

            if [ "${XBB_WITHOUT_MULTILIB}" == "y" ]
            then
              config_options+=("--disable-multilib")
            else
              config_options+=("--enable-multilib")
            fi
          fi

          # Practically the same.
          if [ "${name_suffix}" == "" ]
          then

            # 11.2-2022.02-darwin-x86_64-arm-none-eabi-manifest.txt:
            # gcc2_configure='--target=arm-none-eabi
            # --prefix=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-arm-none-eabi/install//
            # --with-gmp=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-arm-none-eabi/host-tools
            # --with-mpfr=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-arm-none-eabi/host-tools
            # --with-mpc=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-arm-none-eabi/host-tools
            # --with-isl=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-arm-none-eabi/host-tools
            # --disable-shared --disable-nls --disable-threads --disable-tls
            # --enable-checking=release --enable-languages=c,c++,fortran
            # --with-newlib --with-multilib-list=aprofile,rmprofile'

            # 11.2-2022.02-darwin-x86_64-aarch64-none-elf-manifest.txt
            # gcc2_configure='--target=aarch64-none-elf
            # --prefix=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-aarch64-none-elf/install//
            # --with-gmp=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-aarch64-none-elf/host-tools
            # --with-mpfr=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-aarch64-none-elf/host-tools
            # --with-mpc=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-aarch64-none-elf/host-tools
            # --with-isl=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-aarch64-none-elf/host-tools
            # --disable-shared --disable-nls --disable-threads --disable-tls
            # --enable-checking=release --enable-languages=c,c++,fortran
            # --with-newlib 			 			 			'

            run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${XBB_GCC_SRC_FOLDER_NAME}/configure" \
              "${config_options[@]}"

          elif [ "${name_suffix}" == "-nano" ]
          then

            # 11.2-2022.02-darwin-x86_64-arm-none-eabi-manifest.txt:
            # gcc2_nano_configure='--target=arm-none-eabi
            # --prefix=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-arm-none-eabi/nano_install//
            # --with-gmp=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-arm-none-eabi/host-tools
            # --with-mpfr=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-arm-none-eabi/host-tools
            # --with-mpc=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-arm-none-eabi/host-tools
            # --with-isl=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-arm-none-eabi/host-tools
            # --disable-shared --disable-nls --disable-threads --disable-tls
            # --enable-checking=release --enable-languages=c,c++,fortran
            # --with-newlib --with-multilib-list=aprofile,rmprofile'

            run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${XBB_GCC_SRC_FOLDER_NAME}/configure" \
              "${config_options[@]}"

          fi
          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${gcc_final_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gcc_final_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        # Partial build, without documentation.
        echo
        echo "Running cross gcc${name_suffix} final stage make..."

        if [ "${XBB_TARGET_PLATFORM}" != "win32" ]
        then

          # Passing USE_TM_CLONE_REGISTRY=0 via INHIBIT_LIBC_CFLAGS to disable
          # transactional memory related code in crtbegin.o.
          # This is a workaround. Better approach is have a t-* to set this flag via
          # CRTSTUFF_T_CFLAGS

          if [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
          then
            if [ "${XBB_IS_DEVELOP}" == "y" ]
            then
              run_verbose make -j ${XBB_JOBS} INHIBIT_LIBC_CFLAGS="-DUSE_TM_CLONE_REGISTRY=0"
            else
              # Retry, parallel builds do fail, headers are probably
              # used before being installed. For example:
              # fatal error: bits/string_view.tcc: No such file or directory
              run_verbose make -j ${XBB_JOBS} INHIBIT_LIBC_CFLAGS="-DUSE_TM_CLONE_REGISTRY=0" \
              || run_verbose make -j ${XBB_JOBS} INHIBIT_LIBC_CFLAGS="-DUSE_TM_CLONE_REGISTRY=0" \
              || run_verbose make -j ${XBB_JOBS} INHIBIT_LIBC_CFLAGS="-DUSE_TM_CLONE_REGISTRY=0" \
              || run_verbose make -j ${XBB_JOBS} INHIBIT_LIBC_CFLAGS="-DUSE_TM_CLONE_REGISTRY=0"
            fi
          else
            run_verbose make -j ${XBB_JOBS} INHIBIT_LIBC_CFLAGS="-DUSE_TM_CLONE_REGISTRY=0"
          fi

          # Avoid strip here, it may interfere with patchelf.
          # make install-strip
          run_verbose make install

          if [ "${name_suffix}" == "-nano" ]
          then

            local target_gcc=""
            if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
            then
              target_gcc="${XBB_GCC_TARGET}-gcc"
            else
              if [ -x "${APP_PREFIX_NANO}/bin/${XBB_GCC_TARGET}-gcc" ]
              then
                target_gcc="${APP_PREFIX_NANO}/bin/${XBB_GCC_TARGET}-gcc"
              # elif [ -x "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/${XBB_GCC_TARGET}-gcc" ]
              # then
              #   target_gcc="${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/${XBB_GCC_TARGET}-gcc"
              else
                echo "No ${XBB_GCC_TARGET}-gcc --print-multi-lib"
                exit 1
              fi
            fi

            # Copy the libraries after appending the `_nano` suffix.
            # Iterate through all multilib names.
            copy_cross_multi_libs \
              "${APP_PREFIX_NANO}/${XBB_GCC_TARGET}/lib" \
              "${XBB_BINARIES_INSTALL_FOLDER_PATH}/${XBB_GCC_TARGET}/lib" \
              "${target_gcc}"

            # Copy the nano configured newlib.h file into the location that nano.specs
            # expects it to be.
            mkdir -pv "${XBB_BINARIES_INSTALL_FOLDER_PATH}/${XBB_GCC_TARGET}/include/newlib-nano"
            cp -v -f "${APP_PREFIX_NANO}/${XBB_GCC_TARGET}/include/newlib.h" \
              "${XBB_BINARIES_INSTALL_FOLDER_PATH}/${XBB_GCC_TARGET}/include/newlib-nano/newlib.h"

          fi

        else

          # For Windows build only the GCC binaries, the libraries were copied
          # from the Linux build.
          # Parallel builds may fail.
          run_verbose make -j ${XBB_JOBS} all-gcc
          # make all-gcc

          # No -strip here.
          run_verbose make install-gcc

          # Strip?

        fi

        if [ "${name_suffix}" == "" ]
        then
          (
            xbb_activate_tex

            # Full build, with documentation.
            if [ "${XBB_WITH_PDF}" == "y" ]
            then
              run_verbose make pdf
              run_verbose make install-pdf
            fi

            if [ "${XBB_WITH_HTML}" == "y" ]
            then
              run_verbose make html
              run_verbose make install-html
            fi

            if [ "${XBB_WITH_PDF}" != "y" -a "${XBB_WITH_HTML}" != "y" ]
            then
              run_verbose rm -rf "${XBB_BINARIES_INSTALL_FOLDER_PATH}/shrare/doc"
            fi
          )
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gcc_final_folder_name}/make-output-$(ndate).txt"

      if [ "${name_suffix}" == "" ]
      then
        copy_license \
          "${XBB_SOURCES_FOLDER_PATH}/${XBB_GCC_SRC_FOLDER_NAME}" \
          "gcc-${XBB_GCC_VERSION}"
      fi

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${gcc_final_stamp_file_path}"

  else
    echo "Component cross gcc${name_suffix} final stage already installed."
  fi

  if [ "${name_suffix}" == "" ]
  then
    tests_add "test_cross_gcc"
  fi
}

function test_cross_gcc()
{
  (
    if [ -d "xpacks/.bin" ]
    then
      XBB_TEST_BIN_PATH="$(pwd)/xpacks/.bin"
    elif [ -d "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin" ]
    then
      XBB_TEST_BIN_PATH="${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
    else
      echo "Wrong folder."
      exit 1
    fi

    show_libs "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-gcc"
    show_libs "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-g++"

    if [ "${XBB_TARGET_PLATFORM}" != "win32" ]
    then
      show_libs "$(${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-gcc -print-prog-name=cc1)"
      show_libs "$(${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-gcc -print-prog-name=cc1plus)"
      show_libs "$(${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-gcc -print-prog-name=collect2)"
      show_libs "$(${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-gcc -print-prog-name=lto-wrapper)"
      show_libs "$(${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-gcc -print-prog-name=lto1)"
    fi

    run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-gcc" --help
    run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-gcc" -dumpversion
    run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-gcc" -dumpmachine
    run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-gcc" -print-multi-lib
    run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-gcc" -print-search-dirs
    # run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-gcc" -dumpspecs | wc -l

    local tmp=$(mktemp /tmp/gcc-test.XXXXX)
    rm -rf "${tmp}"

    mkdir -pv "${tmp}"
    cd "${tmp}"

    if false # [ "${XBB_TARGET_PLATFORM}" == "win32" ] && [ -z ${IS_NATIVE_TEST+x} ]
    then
      : # Skip Windows when non native (running on Wine).
    else

      if [ "${XBB_GCC_TARGET}" == "arm-none-eabi" ]
      then
        specs="-specs=rdimon.specs"
      elif [ "${XBB_GCC_TARGET}" == "aarch64-none-elf" ]
      then
        specs="-specs=rdimon.specs"
      elif [ "${XBB_GCC_TARGET}" == "riscv-none-elf" ]
      then
        specs="-specs=semihost.specs"
      else
        specs="-specs=nosys.specs"
      fi

      # Note: __EOF__ is quoted to prevent substitutions here.
      cat <<'__EOF__' > hello.c
#include <stdio.h>

int
main(int argc, char* argv[])
{
  printf("Hello World\n");
}
__EOF__

      run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-gcc" -pipe -o hello-c.elf "${specs}" hello.c -v

      run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-gcc" -pipe -o hello.c.o -c -flto hello.c
      run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-gcc" -pipe -o hello-c-lto.elf "${specs}" -flto -v hello.c.o

      # Note: __EOF__ is quoted to prevent substitutions here.
      cat <<'__EOF__' > hello.cpp
#include <iostream>

int
main(int argc, char* argv[])
{
  std::cout << "Hello World" << std::endl;
}

extern "C" void __sync_synchronize();

void
__sync_synchronize()
{
}
__EOF__

      run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-g++" -pipe -o hello-cpp.elf "${specs}" hello.cpp

      run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-g++" -pipe -o hello.cpp.o -c -flto hello.cpp
      run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-g++" -pipe -o hello-cpp-lto.elf "${specs}" -flto -v hello.cpp.o

      run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-g++" -pipe -o hello-cpp-gcov.elf "${specs}" -fprofile-arcs -ftest-coverage -lgcov hello.cpp
    fi

    cd ..
    rm -rf "${tmp}"
  )
}

# -----------------------------------------------------------------------------

# Environment variables:
# XBB_GDB_VERSION
# XBB_GDB_SRC_FOLDER_NAME
# XBB_GDB_ARCHIVE_URL
# XBB_GDB_ARCHIVE_NAME
# XBB_GDB_PATCH_FILE_NAME

# https://github.com/archlinux/svntogit-community/blob/packages/arm-none-eabi-gdb/trunk/PKGBUILD
# https://github.com/archlinux/svntogit-community/blob/packages/riscv32-elf-gdb/trunk/PKGBUILD

# Called multile times, with and without python support.
# $1="" or $1="-py" or $1="-py3"
function build_cross_gdb()
{
  local name_suffix=${1-''}

  # GDB Text User Interface
  # https://ftp.gnu.org/old-gnu/Manuals/gdb/html_chapter/gdb_19.html#SEC197

  local gdb_folder_name="gdb-${XBB_GDB_VERSION}${name_suffix}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${gdb_folder_name}"

  local gdb_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${gdb_folder_name}-installed"

  if [ ! -f "${gdb_stamp_file_path}" ]
  then

    # Download gdb
    if [ ! -d "${XBB_SOURCES_FOLDER_PATH}/${XBB_GDB_SRC_FOLDER_NAME}" ]
    then
      mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

      download_and_extract "${XBB_GDB_ARCHIVE_URL}" "${XBB_GDB_ARCHIVE_NAME}" \
          "${XBB_GDB_SRC_FOLDER_NAME}" "${XBB_GDB_PATCH_FILE_NAME}"
    fi
    # exit 1

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${gdb_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${gdb_folder_name}"

      # To pick up the python lib from XBB
      # xbb_activate_dev
      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP}"
      LIBS=""

      # libiconv is used by Python3.
      # export LIBS="-liconv"
      if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
      then
        # https://stackoverflow.com/questions/44150871/embeded-python3-6-with-mingw-in-c-fail-on-linking
        # ???
        CPPFLAGS+=" -DPy_BUILD_CORE_BUILTIN=1"

        if [ "${name_suffix}" == "-py" ]
        then
          # Definition required by python-config.sh.
          export GNURM_PYTHON_WIN_DIR="${XBB_SOURCES_FOLDER_PATH}/${XBB_PYTHON2_SRC_FOLDER_NAME}"
        fi

        # Hack to place the bcrypt library at the end of the list of libraries,
        # to avoid 'undefined reference to BCryptGenRandom'.
        # Using LIBS does not work, the order is important.
        export DEBUGINFOD_LIBS="-lbcrypt"

        # From Arm script.
        LDFLAGS+=" -v -Wl,${XBB_FOLDER_PATH}/mingw/lib/CRT_glob.o"
        # Workaround for undefined reference to `__strcpy_chk' in GCC 9.
        # https://sourceforge.net/p/mingw-w64/bugs/818/
        LIBS="-lssp -liconv"
      elif [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
      then
        : # LIBS="-liconv -lncurses"
      elif [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        xbb_activate_cxx_rpath
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      CONFIG_PYTHON_PREFIX=""

      if [ "${name_suffix}" == "-py3" ]
      then
        if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
        then
          # The source archive includes only the pyconfig.h.in, which needs
          # to be configured, which is not an easy task. Thus add the file copied
          # from a Windows install.
          cp -v "${helper_folder_path}/extras/python/pyconfig-win-${XBB_PYTHON3_VERSION}.h" \
            "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/pyconfig.h"
        else
          CONFIG_PYTHON_PREFIX="${XBB_BINARIES_INSTALL_FOLDER_PATH}"
        fi
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS

      export LDFLAGS
      export LIBS

      export CONFIG_PYTHON_PREFIX

      # python -c 'from distutils import sysconfig;print(sysconfig.PREFIX)'
      # python -c 'from distutils import sysconfig;print(sysconfig.EXEC_PREFIX)'

      # The patch to `gdb/python/python-config.py` uses CONFIG_PYTHON_PREFIX,
      # otherwise the resulting python is not relocatable:
      # Fatal Python error: init_fs_encoding: failed to get the Python codec of the filesystem encoding
      # Python runtime state: core initialized
      # ModuleNotFoundError: No module named 'encodings'

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running cross gdb${name_suffix} configure..."

          bash "${XBB_SOURCES_FOLDER_PATH}/${XBB_GDB_SRC_FOLDER_NAME}/gdb/configure" --help

          # 11.2-2022.02-darwin-x86_64-arm-none-eabi-manifest.txt:
          # gdb_configure='--enable-initfini-array --disable-nls --without-x
          # --disable-gdbtk --without-tcl --without-tk --disable-werror
          # --without-expat --without-libunwind-ia64 --without-lzma
          # --without-babeltrace --without-intel-pt --without-xxhash
          # --without-debuginfod --without-guile --disable-source-highlight
          # --disable-objc-gc --with-python=no --disable-binutils
          # --disable-sim --disable-as --disable-ld --enable-plugins
          # --target=arm-none-eabi --prefix=/ --with-mpfr
          # --with-libmpfr-prefix=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-arm-none-eabi/host-tools
          # --with-libmpfr-type=static
          # --with-libgmp-prefix=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-arm-none-eabi/host-tools
          # --with-libgmp-type=static'

          # 11.2-2022.02-darwin-x86_64-aarch64-none-elf-manifest.txt
          # gdb_configure='--enable-64-bit-bfd
          # --enable-targets=arm-none-eabi,aarch64-none-linux-gnu,aarch64-none-elf
          # --enable-initfini-array --disable-nls --without-x --disable-gdbtk
          # --without-tcl --without-tk --disable-werror --without-expat
          # --without-libunwind-ia64 --without-lzma --without-babeltrace
          # --without-intel-pt --without-xxhash  --without-debuginfod
          # --without-guile --disable-source-highlight --disable-objc-gc
          # --with-python=no --disable-binutils --disable-sim --disable-as
          # --disable-ld --enable-plugins --target=aarch64-none-elf --prefix=/
          # --with-mpfr
          # --with-libmpfr-prefix=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-aarch64-none-elf/host-tools
          # --with-libmpfr-type=static
          # --with-libgmp-prefix=/Volumes/data/jenkins/workspace/GNU-toolchain/arm-11/build-aarch64-none-elf/host-tools
          # --with-libgmp-type=static'

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--infodir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/info")
          config_options+=("--mandir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/man")
          config_options+=("--htmldir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/html")
          config_options+=("--pdfdir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/share/doc/pdf")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_GCC_TARGET}")

          config_options+=("--program-prefix=${XBB_GCC_TARGET}-")
          config_options+=("--program-suffix=${name_suffix}")

          config_options+=("--disable-binutils") # Arm, AArch64
          config_options+=("--disable-as") # Arm, AArch64
          config_options+=("--disable-gdbtk") # Arm, AArch64
          # config_options+=("--disable-gprof")
          config_options+=("--disable-ld") # Arm, AArch64
          config_options+=("--disable-nls") # Arm, AArch64
          config_options+=("--disable-objc-gc") # Arm, AArch64
          config_options+=("--disable-sim") # Arm, AArch64
          config_options+=("--disable-source-highlight") # Arm, AArch64
          config_options+=("--disable-werror") # Arm, AArch64

          config_options+=("--enable-gdb")
          config_options+=("--enable-initfini-array") # Arm, AArch64
          config_options+=("--enable-build-warnings=no")
          config_options+=("--enable-plugins") # Arm, AArch64

          if [ "${XBB_GCC_TARGET}" == "aarch64-none-elf" ]
          then
            config_options+=("--enable-64-bit-bfd") # AArch64
            config_options+=("--enable-targets=arm-none-eabi,aarch64-none-linux-gnu,aarch64-none-elf") # AArch64
          fi

          config_options+=("--without-babeltrace") # Arm, AArch64
          config_options+=("--without-debuginfod") # Arm, AArch64
          config_options+=("--without-guile") # Arm, AArch64
          config_options+=("--without-intel-pt") # Arm, AArch64
          config_options+=("--without-libunwind-ia64") # Arm, AArch64
          config_options+=("--without-lzma") # Arm, AArch64
          config_options+=("--without-tcl") # Arm, AArch64
          config_options+=("--without-tk") # Arm, AArch64
          config_options+=("--without-x") # Arm, AArch64
          config_options+=("--without-xxhash") # Arm, AArch64

          config_options+=("--with-expat") # Arm
          config_options+=("--with-gdb-datadir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/${XBB_GCC_TARGET}/share/gdb")

          # No need to, we keep track of paths to shared libraries.
          # Plus that if fails the build:
          # /opt/xbb/bin/ld: /usr/lib/x86_64-linux-gnu/libm-2.27.a(e_log.o): warning: relocation against `_dl_x86_cpu_features' in read-only section `.text'
          # /opt/xbb/bin/ld: /usr/lib/x86_64-linux-gnu/libm-2.27.a(e_pow.o): in function `__ieee754_pow_ifunc':
          # (.text+0x12b2): undefined reference to `_dl_x86_cpu_features'
          # /opt/xbb/bin/ld: /usr/lib/x86_64-linux-gnu/libm-2.27.a(e_exp.o): in function `__ieee754_exp_ifunc':
          # (.text+0x5d2): undefined reference to `_dl_x86_cpu_features'
          # /opt/xbb/bin/ld: /usr/lib/x86_64-linux-gnu/libm-2.27.a(e_log.o): in function `__ieee754_log_ifunc':
          # (.text+0x1602): undefined reference to `_dl_x86_cpu_features'
          # /opt/xbb/bin/ld: warning: creating DT_TEXTREL in a PIE

          # config_options+=("--with-libexpat-type=static") # Arm
          # config_options+=("--with-libgmp-type=static") # Arm, AArch64
          # config_options+=("--with-libmpfr-type=static") # Arm, AArch64

          config_options+=("--with-pkgversion=${XBB_BRANDING}")
          config_options+=("--with-system-gdbinit=${XBB_BINARIES_INSTALL_FOLDER_PATH}/${XBB_GCC_TARGET}/lib/gdbinit")
          config_options+=("--with-system-zlib")

          if [ "${name_suffix}" == "-py3" ]
          then
            if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
            then
              config_options+=("--with-python=${helper_folder_path}/extras/python/python${XBB_PYTHON3_VERSION_MAJOR}-config-win.sh")
            else
              config_options+=("--with-python=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/python3.${XBB_PYTHON3_VERSION_MINOR}")
            fi
          else
             config_options+=("--with-python=no")
          fi

          if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
          then
            config_options+=("--disable-tui")
          else
            config_options+=("--enable-tui")
          fi

          # Note that all components are disabled, except GDB.
          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${XBB_GDB_SRC_FOLDER_NAME}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${gdb_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gdb_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running cross gdb${name_suffix} make..."

        # Build.
        run_verbose make -j ${XBB_JOBS} all-gdb

        # install-strip fails, not only because of readline has no install-strip
        # but even after patching it tries to strip a non elf file
        # strip:.../install/riscv-none-gcc/bin/_inst.672_: file format not recognized

        # The explicit `-gdb` fixes a bug noticed with gdb 12, that builds
        # a defective `as.exe` even if instructed not to do so.
        run_verbose make install-gdb

        if [ "${name_suffix}" == "" ]
        then
          (
            xbb_activate_tex

            if [ "${XBB_WITH_PDF}" == "y" ]
            then
              run_verbose make pdf-gdb
              run_verbose make install-pdf-gdb
            fi

            if [ "${XBB_WITH_HTML}" == "y" ]
            then
              run_verbose make html-gdb
              run_verbose make install-html-gdb
            fi
          )
        fi

        rm -rfv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/pyconfig.h"

        show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/${XBB_GCC_TARGET}-gdb${name_suffix}"

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gdb_folder_name}/make-output-$(ndate).txt"

      if [ "${name_suffix}" == "" ]
      then
        copy_license \
          "${XBB_SOURCES_FOLDER_PATH}/${XBB_GDB_SRC_FOLDER_NAME}" \
          "${gdb_folder_name}"
      fi
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${gdb_stamp_file_path}"

  else
    echo "Component cross gdb${name_suffix} already installed."
  fi

  tests_add "test_cross_gdb${name_suffix}"
}

function test_cross_gdb_py()
{
  test_cross_gdb "-py"
}

function test_cross_gdb_py3()
{
  test_cross_gdb "-py3"
}

function test_cross_gdb()
{
  local suffix=""
  if [ $# -ge 1 ]
  then
    suffix="$1"
  fi

  (
    if [ -d "xpacks/.bin" ]
    then
      XBB_TEST_BIN_PATH="$(pwd)/xpacks/.bin"
    elif [ -d "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin" ]
    then
      XBB_TEST_BIN_PATH="${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
    else
      echo "Wrong folder."
      exit 1
    fi

    show_libs "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-gdb${suffix}"

    run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-gdb${suffix}" --version
    run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-gdb${suffix}" --config

    # This command is known to fail with 'Abort trap: 6' (SIGABRT)
    run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-gdb${suffix}" \
      --nh \
      --nx \
      -ex='show language' \
      -ex='set language auto' \
      -ex='quit'

    if [ "${suffix}" == "-py3" ]
    then
      # Show Python paths.
      run_app "${XBB_TEST_BIN_PATH}/${XBB_GCC_TARGET}-gdb${suffix}" \
        --nh \
        --nx \
        -ex='set pagination off' \
        -ex='python import sys; print(sys.prefix)' \
        -ex='python import sys; import os; print(os.pathsep.join(sys.path))' \
        -ex='quit'
    fi
  )
}

function tidy_up()
{
  (
    echo
    echo "# Tidying up..."

    # find: pred.c:1932: launch: Assertion `starting_desc >= 0' failed.
    cd "${XBB_BINARIES_INSTALL_FOLDER_PATH}"

    find "${XBB_BINARIES_INSTALL_FOLDER_PATH}" -name "libiberty.a" -exec rm -v '{}' ';'
    find "${XBB_BINARIES_INSTALL_FOLDER_PATH}" -name '*.la' -exec rm -v '{}' ';'

    if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
    then
      find "${XBB_BINARIES_INSTALL_FOLDER_PATH}" -name "liblto_plugin.a" -exec rm -v '{}' ';'
      find "${XBB_BINARIES_INSTALL_FOLDER_PATH}" -name "liblto_plugin.dll.a" -exec rm -v '{}' ';'
    fi
  )
}

function strip_libs()
{
  if [ "${XBB_WITH_STRIP}" == "y" ]
  then
    (
      PATH="${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin:${PATH}"

      echo
      echo "Stripping libraries..."

      cd "${XBB_TARGET_WORK_FOLDER_PATH}"

      # which "${XBB_GCC_TARGET}-objcopy"

      local libs=$(find "${XBB_BINARIES_INSTALL_FOLDER_PATH}" -name '*.[ao]')
      for lib in ${libs}
      do
        if false
        then
          echo "${XBB_GCC_TARGET}-objcopy -R ... ${lib}"
          "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/${XBB_GCC_TARGET}-objcopy" -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc "${lib}" || true
        else
          echo "[${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/${XBB_GCC_TARGET}-strip --strip-debug ${lib}]"
          "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/${XBB_GCC_TARGET}-strip" --strip-debug "${lib}"
        fi
      done
    )
  fi
}

function final_tunings()
{
  # Create the missing LTO plugin links.
  # For `ar` to work with LTO objects, it needs the plugin in lib/bfd-plugins,
  # but the build leaves it where `ld` needs it. On POSIX, make a soft link.
  if [ "${XBB_FIX_LTO_PLUGIN:-}" == "y" ]
  then
    (
      cd "${XBB_BINARIES_INSTALL_FOLDER_PATH}"

      echo
      if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
      then
        echo
        echo "Copying ${XBB_LTO_PLUGIN_ORIGINAL_NAME}..."

        mkdir -pv "$(dirname ${XBB_LTO_PLUGIN_BFD_PATH})"

        if [ ! -f "${XBB_LTO_PLUGIN_BFD_PATH}" ]
        then
          local plugin_path="$(find * -type f -name ${XBB_LTO_PLUGIN_ORIGINAL_NAME})"
          if [ ! -z "${plugin_path}" ]
          then
            cp -v "${plugin_path}" "${XBB_LTO_PLUGIN_BFD_PATH}"
          else
            echo "${XBB_LTO_PLUGIN_ORIGINAL_NAME} not found."
            exit 1
          fi
        fi
      else
        echo
        echo "Creating ${XBB_LTO_PLUGIN_ORIGINAL_NAME} link..."

        mkdir -pv "$(dirname ${XBB_LTO_PLUGIN_BFD_PATH})"
        if [ ! -f "${XBB_LTO_PLUGIN_BFD_PATH}" ]
        then
          local plugin_path="$(find * -type f -name ${XBB_LTO_PLUGIN_ORIGINAL_NAME})"
          if [ ! -z "${plugin_path}" ]
          then
            ln -s -v "../../${plugin_path}" "${XBB_LTO_PLUGIN_BFD_PATH}"
          else
            echo "${XBB_LTO_PLUGIN_ORIGINAL_NAME} not found."
            exit 1
          fi
        fi
      fi
    )
  fi
}

# -----------------------------------------------------------------------------
