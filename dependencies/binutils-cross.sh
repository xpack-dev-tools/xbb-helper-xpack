# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://ftp.gnu.org/gnu/binutils/
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=binutils-git
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gdb-git

# https://gitlab.archlinux.org/archlinux/packaging/packages/arm-none-eabi-binutils/-/blob/main/PKGBUILD
# https://gitlab.archlinux.org/archlinux/packaging/packages/riscv32-elf-binutils/-/blob/main/PKGBUILD

# 2022-02-09, "2.38"
# 2022-08-05, "2.39"

# -----------------------------------------------------------------------------

# Environment variables:
# XBB_BINUTILS_SRC_FOLDER_NAME
# XBB_BINUTILS_ARCHIVE_NAME
# XBB_BINUTILS_URL
# XBB_BINUTILS_PATCH_FILE_NAME

function binutils_cross_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local binutils_version="$1"
  shift

  local triplet="$1"
  shift

  local name_prefix="${triplet}-"

  local name_suffix=""
  local is_nano="n"
  local nano_option=""

  while [ $# -gt 0 ]
  do
    case "$1" in
      --nano )
        is_nano="y"
        nano_option="--nano"
        name_suffix="-nano"
        shift
        ;;

      * )
        echo "Unsupported argument $1 in ${FUNCNAME[0]}()"
        exit 1
        ;;
    esac
  done


  local binutils_folder_name="${name_prefix}binutils-${binutils_version}${name_suffix}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${binutils_folder_name}"

  local binutils_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${binutils_folder_name}-installed"
  if [ ! -f "${binutils_stamp_file_path}" ]
  then

    # Download binutils.
    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${XBB_BINUTILS_ARCHIVE_URL}" "${XBB_BINUTILS_ARCHIVE_NAME}" \
        "${XBB_BINUTILS_SRC_FOLDER_NAME}" "${XBB_BINUTILS_PATCH_FILE_NAME}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${binutils_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${binutils_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS} -UFORTIFY_SOURCE" # ABE
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        # Used to enable wildcard; inspired by arm-none-eabi-gcc.
        local crt_clob_file_path="$(${CC} --print-file-name=CRT_glob.o)"
        LDFLAGS+=" -Wl,${crt_clob_file_path}"
      fi

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
          echo "Running cross ${name_prefix}binutils${name_suffix} configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${XBB_BINUTILS_SRC_FOLDER_NAME}/configure" --help
          fi

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

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

          config_options+=("--infodir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/info")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")
          config_options+=("--htmldir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/html")
          config_options+=("--pdfdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/pdf")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${triplet}")

          config_options+=("--program-prefix=${name_prefix}")
          config_options+=("--program-suffix=")

          config_options+=("--disable-nls") # Arm, AArch64
          config_options+=("--disable-gdb") # Arm, AArch64
          config_options+=("--disable-gdbtk") # Arm, AArch64

          config_options+=("--disable-sim")
          config_options+=("--disable-werror")

          config_options+=("--enable-initfini-array") # Arm, AArch64

          # ld.gold requested to compile the Android kernel.
          config_options+=("--enable-gold")
          # ld added explicitly for consistency.
          config_options+=("--enable-ld")

          config_options+=("--enable-lto")
          config_options+=("--enable-plugins") # Arm, AArch64
          config_options+=("--enable-build-warnings=no")

          if [ "${triplet}" == "aarch64-none-elf" ]
          then
            config_options+=("--enable-64-bit-bfd") # AArch64
            config_options+=("--enable-targets=arm-none-eabi,aarch64-none-linux-gnu,aarch64-none-elf") # AArch64
          fi

          config_options+=("--without-gdb") # Arm, AArch64
          config_options+=("--without-x") # Arm, AArch64
          config_options+=("--without-tcl") # Arm, AArch64
          config_options+=("--without-tk") # Arm, AArch64

          config_options+=("--with-pkgversion=${XBB_BRANDING}")

          # Use the zlib compiled from sources.
          config_options+=("--with-system-zlib")

          # Arm --with-sysroot=${sysroots}"

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${XBB_BINUTILS_SRC_FOLDER_NAME}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${binutils_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${binutils_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running cross ${name_prefix}binutils${name_suffix} make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
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

        binutils_cross_test_libs "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${name_suffix}/bin" "${triplet}"

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${binutils_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${XBB_BINUTILS_SRC_FOLDER_NAME}" \
        "binutils-${binutils_version}"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${binutils_stamp_file_path}"

  else
    echo "Component cross ${name_prefix}binutils${name_suffix} already installed"
  fi

  tests_add "binutils_cross_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin" "${triplet}"
}

function binutils_cross_test_libs()
{
  local test_bin_path="$1"
  local triplet="$2"

  show_host_libs "${test_bin_path}/${triplet}-ar"
  show_host_libs "${test_bin_path}/${triplet}-as"
  show_host_libs "${test_bin_path}/${triplet}-ld"
  show_host_libs "${test_bin_path}/${triplet}-nm"
  show_host_libs "${test_bin_path}/${triplet}-objcopy"
  show_host_libs "${test_bin_path}/${triplet}-objdump"
  show_host_libs "${test_bin_path}/${triplet}-ranlib"
  show_host_libs "${test_bin_path}/${triplet}-size"
  show_host_libs "${test_bin_path}/${triplet}-strings"
  show_host_libs "${test_bin_path}/${triplet}-strip"
}

function binutils_cross_test()
{
  local test_bin_path="$1"
  local triplet="$2"

  (
    echo
    echo "Checking the ${triplet}-binutils shared libraries..."

    show_host_libs "${test_bin_path}/${triplet}-ar"
    show_host_libs "${test_bin_path}/${triplet}-as"
    show_host_libs "${test_bin_path}/${triplet}-ld"
    show_host_libs "${test_bin_path}/${triplet}-nm"
    show_host_libs "${test_bin_path}/${triplet}-objcopy"
    show_host_libs "${test_bin_path}/${triplet}-objdump"
    show_host_libs "${test_bin_path}/${triplet}-ranlib"
    show_host_libs "${test_bin_path}/${triplet}-size"
    show_host_libs "${test_bin_path}/${triplet}-strings"
    show_host_libs "${test_bin_path}/${triplet}-strip"

    echo
    echo "Testing if ${triplet}-binutils start properly..."

    run_host_app_verbose "${test_bin_path}/${triplet}-ar" --version
    run_host_app_verbose "${test_bin_path}/${triplet}-as" --version
    run_host_app_verbose "${test_bin_path}/${triplet}-ld" --version
    run_host_app_verbose "${test_bin_path}/${triplet}-nm" --version
    run_host_app_verbose "${test_bin_path}/${triplet}-objcopy" --version
    run_host_app_verbose "${test_bin_path}/${triplet}-objdump" --version
    run_host_app_verbose "${test_bin_path}/${triplet}-ranlib" --version
    run_host_app_verbose "${test_bin_path}/${triplet}-size" --version
    run_host_app_verbose "${test_bin_path}/${triplet}-strings" --version
    run_host_app_verbose "${test_bin_path}/${triplet}-strip" --version
  )
}

# -----------------------------------------------------------------------------
