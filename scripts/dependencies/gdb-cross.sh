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
  local name_suffix="${1:-""}"

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
      xbb_adjust_ldflags_rpath

      LIBS=""

      # libiconv is used by Python3.
      # export LIBS="-liconv"
      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
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
      fi

      CONFIG_PYTHON_PREFIX=""

      if [ "${name_suffix}" == "-py3" ]
      then
        if [ "${XBB_HOST_PLATFORM}" == "win32" ]
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

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
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

          # Use the zlib compiled from sources.
          config_options+=("--with-system-zlib")

          if [ "${name_suffix}" == "-py3" ]
          then
            if [ "${XBB_HOST_PLATFORM}" == "win32" ]
            then
              config_options+=("--with-python=${helper_folder_path}/extras/python/python${XBB_PYTHON3_VERSION_MAJOR}-config-win.sh")
            else
              config_options+=("--with-python=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/python3.${XBB_PYTHON3_VERSION_MINOR}")
            fi
          else
             config_options+=("--with-python=no")
          fi

          if [ "${XBB_HOST_PLATFORM}" == "win32" ]
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

  tests_add "test_cross_gdb${name_suffix}" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
}

function test_cross_gdb_py()
{
  local test_bin_path="$1"

  test_cross_gdb "${test_bin_path}" "-py"
}

function test_cross_gdb_py3()
{
  local test_bin_path="$1"

  test_cross_gdb "${test_bin_path}" "-py3"
}

function test_cross_gdb()
{
  local test_bin_path="$1"
  local suffix="${2:-}"

  (
    show_libs "${test_bin_path}/${XBB_GCC_TARGET}-gdb${suffix}"

    run_app "${test_bin_path}/${XBB_GCC_TARGET}-gdb${suffix}" --version
    run_app "${test_bin_path}/${XBB_GCC_TARGET}-gdb${suffix}" --config

    # This command is known to fail with 'Abort trap: 6' (SIGABRT)
    run_app "${test_bin_path}/${XBB_GCC_TARGET}-gdb${suffix}" \
      --nh \
      --nx \
      -ex='show language' \
      -ex='set language auto' \
      -ex='quit'

    if [ "${suffix}" == "-py3" ]
    then
      # Show Python paths.
      run_app "${test_bin_path}/${XBB_GCC_TARGET}-gdb${suffix}" \
        --nh \
        --nx \
        -ex='set pagination off' \
        -ex='python import sys; print(sys.prefix)' \
        -ex='python import sys; import os; print(os.pathsep.join(sys.path))' \
        -ex='quit'
    fi
  )
}

