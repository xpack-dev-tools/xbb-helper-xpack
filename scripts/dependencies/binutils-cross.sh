# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# Environment variables:
# XBB_BINUTILS_VERSION
# XBB_BINUTILS_SRC_FOLDER_NAME
# XBB_BINUTILS_ARCHIVE_NAME
# XBB_BINUTILS_URL

# https://github.com/archlinux/svntogit-community/blob/packages/arm-none-eabi-binutils/trunk/PKGBUILD
# https://github.com/archlinux/svntogit-community/blob/packages/riscv32-elf-binutils/trunk/PKGBUILD

function build_binutils_cross()
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

  tests_add "test_binutils_cross"
}

function test_binutils_cross()
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
