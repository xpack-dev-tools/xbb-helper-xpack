# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

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

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        # The CFLAGS are set in XBB_CFLAGS, but for C++ it must be selective.
        # Without it gcc cannot identify cc1 and other binaries
        CXXFLAGS+=" -D__USE_MINGW_ACCESS"
      fi

      LDFLAGS="${XBB_LDFLAGS_APP}"
      xbb_adjust_ldflags_rpath

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
          # --libexecdir="${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib"

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")
          config_options+=("--infodir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/share/doc/info")
          config_options+=("--mandir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/share/doc/man")
          config_options+=("--htmldir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/share/doc/html")
          config_options+=("--pdfdir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/share/doc/pdf")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
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

          # Use the zlib compiled from sources.
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

function copy_cross_linux_libs()
{
  local copy_linux_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-copy-linux-completed"
  if [ ! -f "${copy_linux_stamp_file_path}" ]
  then

    local linux_path="${LINUX_INSTALL_RELATIVE_PATH}/${XBB_APPLICATION_LOWER_CASE_NAME}"

    (
      cd "${XBB_TARGET_WORK_FOLDER_PATH}"

      copy_dir "${linux_path}/${XBB_GCC_TARGET}/lib" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/${XBB_GCC_TARGET}/lib"
      copy_dir "${linux_path}/${XBB_GCC_TARGET}/include" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/${XBB_GCC_TARGET}/include"
      copy_dir "${linux_path}/include" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/include"
      copy_dir "${linux_path}/lib" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib"
      copy_dir "${linux_path}/share" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/share"
    )

    (
      cd "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}"
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
  local name_suffix="${1:-""}"

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

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      # if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
      # then
      #   # Hack to avoid spurious errors like:
      #   # fatal error: bits/nested_exception.h: No such file or directory
      #   CPPFLAGS+=" -I${XBB_BUILD_FOLDER_PATH}/${gcc_final_folder_name}/${XBB_GCC_TARGET}/libstdc++-v3/include"
      # fi
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        # The CFLAGS are set in XBB_CFLAGS, but for C++ it must be selective.
        # Without it gcc cannot identify cc1 and other binaries
        CXXFLAGS+=" -D__USE_MINGW_ACCESS"

        # Hack to prevent "too many sections", "File too big" etc in insn-emit.c
        CXXFLAGS=$(echo ${CXXFLAGS} | sed -e 's|-ffunction-sections -fdata-sections||')
      fi

      LDFLAGS="${XBB_LDFLAGS_APP}"
      xbb_adjust_ldflags_rpath
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

      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
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
          # --libexecdir="${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib" \

          # --enable-lto make it explicit, Arm uses the default.
          # --with-native-system-header-dir is needed to locate stdio.h, to
          # prevent -Dinhibit_libc, which will skip some functionality,
          # like libgcov.

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${name_suffix}")
          if [ -z "${name_suffix}" ]
          then
            config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")
            config_options+=("--infodir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/share/doc/info")
            config_options+=("--mandir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/share/doc/man")
            config_options+=("--htmldir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/share/doc/html")
            config_options+=("--pdfdir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/share/doc/pdf")
          elif [ "${name_suffix}" == "-nano" ]
          then
            config_options+=("--prefix=${APP_PREFIX_NANO}")
          else
            echo "Unsupported name_suffix '${name_suffix}' in ${FUNCNAME[0]}()"
            exit 1
          fi

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
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

          if [ "${XBB_HOST_PLATFORM}" == "win32" ]
          then
            config_options+=("--enable-mingw-wildcard")
          fi

          config_options+=("--with-gmp=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}") # AArch64

          config_options+=("--with-newlib") # Arm, AArch64
          config_options+=("--with-pkgversion=${XBB_BRANDING}")

          config_options+=("--with-gnu-as") # Arm ABE
          config_options+=("--with-gnu-ld") # Arm ABE

          # Use the zlib compiled from sources.
          config_options+=("--with-system-zlib")

          # `${with_sysroot}${native_system_header_dir}/stdio.h`
          # is checked for presence; if not present `inhibit_libc=true` and
          # libgcov.a is compiled with empty functions.
          # https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/issues/1
          config_options+=("--with-sysroot=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/${XBB_GCC_TARGET}")
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

        if [ "${XBB_HOST_PLATFORM}" != "win32" ]
        then

          # Passing USE_TM_CLONE_REGISTRY=0 via INHIBIT_LIBC_CFLAGS to disable
          # transactional memory related code in crtbegin.o.
          # This is a workaround. Better approach is have a t-* to set this flag via
          # CRTSTUFF_T_CFLAGS

          if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
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
            if [ "${XBB_HOST_PLATFORM}" == "win32" ]
            then
              target_gcc="${XBB_GCC_TARGET}-gcc"
            else
              if [ -x "${APP_PREFIX_NANO}/bin/${XBB_GCC_TARGET}-gcc" ]
              then
                target_gcc="${APP_PREFIX_NANO}/bin/${XBB_GCC_TARGET}-gcc"
              # elif [ -x "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${XBB_GCC_TARGET}-gcc" ]
              # then
              #   target_gcc="${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${XBB_GCC_TARGET}-gcc"
              else
                echo "No ${XBB_GCC_TARGET}-gcc --print-multi-lib"
                exit 1
              fi
            fi

            # Copy the libraries after appending the `_nano` suffix.
            # Iterate through all multilib names.
            copy_cross_multi_libs \
              "${APP_PREFIX_NANO}/${XBB_GCC_TARGET}/lib" \
              "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/${XBB_GCC_TARGET}/lib" \
              "${target_gcc}"

            # Copy the nano configured newlib.h file into the location that nano.specs
            # expects it to be.
            mkdir -pv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/${XBB_GCC_TARGET}/include/newlib-nano"
            cp -v -f "${APP_PREFIX_NANO}/${XBB_GCC_TARGET}/include/newlib.h" \
              "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/${XBB_GCC_TARGET}/include/newlib-nano/newlib.h"

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
    tests_add "test_cross_gcc" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${name_suffix}"
  fi
}

function test_cross_gcc()
{
  local test_bin_path="$1"

  (
    show_host_libs "${test_bin_path}/${XBB_GCC_TARGET}-gcc"
    show_host_libs "${test_bin_path}/${XBB_GCC_TARGET}-g++"

    if [ "${XBB_HOST_PLATFORM}" != "win32" ]
    then
      show_host_libs "$(${test_bin_path}/${XBB_GCC_TARGET}-gcc -print-prog-name=cc1)"
      show_host_libs "$(${test_bin_path}/${XBB_GCC_TARGET}-gcc -print-prog-name=cc1plus)"
      show_host_libs "$(${test_bin_path}/${XBB_GCC_TARGET}-gcc -print-prog-name=collect2)"
      show_host_libs "$(${test_bin_path}/${XBB_GCC_TARGET}-gcc -print-prog-name=lto-wrapper)"
      show_host_libs "$(${test_bin_path}/${XBB_GCC_TARGET}-gcc -print-prog-name=lto1)"
    fi

    run_app_verbose "${test_bin_path}/${XBB_GCC_TARGET}-gcc" --help
    run_app_verbose "${test_bin_path}/${XBB_GCC_TARGET}-gcc" -dumpversion
    run_app_verbose "${test_bin_path}/${XBB_GCC_TARGET}-gcc" -dumpmachine
    run_app_verbose "${test_bin_path}/${XBB_GCC_TARGET}-gcc" -print-multi-lib
    run_app_verbose "${test_bin_path}/${XBB_GCC_TARGET}-gcc" -print-search-dirs
    # run_app_verbose "${test_bin_path}/${XBB_GCC_TARGET}-gcc" -dumpspecs | wc -l

    local tmp=$(mktemp /tmp/gcc-test.XXXXX)
    rm -rf "${tmp}"

    mkdir -pv "${tmp}"
    cd "${tmp}"

    if false # [ "${XBB_HOST_PLATFORM}" == "win32" ] && [ -z ${IS_NATIVE_TEST+x} ]
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

      run_app_verbose "${test_bin_path}/${XBB_GCC_TARGET}-gcc" -pipe -o hello-c.elf "${specs}" hello.c -v

      run_app_verbose "${test_bin_path}/${XBB_GCC_TARGET}-gcc" -pipe -o hello.c.o -c -flto hello.c
      run_app_verbose "${test_bin_path}/${XBB_GCC_TARGET}-gcc" -pipe -o hello-c-lto.elf "${specs}" -flto -v hello.c.o

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

      run_app_verbose "${test_bin_path}/${XBB_GCC_TARGET}-g++" -pipe -o hello-cpp.elf "${specs}" hello.cpp

      run_app_verbose "${test_bin_path}/${XBB_GCC_TARGET}-g++" -pipe -o hello.cpp.o -c -flto hello.cpp
      run_app_verbose "${test_bin_path}/${XBB_GCC_TARGET}-g++" -pipe -o hello-cpp-lto.elf "${specs}" -flto -v hello.cpp.o

      run_app_verbose "${test_bin_path}/${XBB_GCC_TARGET}-g++" -pipe -o hello-cpp-gcov.elf "${specs}" -fprofile-arcs -ftest-coverage -lgcov hello.cpp
    fi

    cd ..
    rm -rf "${tmp}"
  )
}

# -----------------------------------------------------------------------------

function cross_tidy_up()
{
  (
    echo
    echo "# Tidying up..."

    # find: pred.c:1932: launch: Assertion `starting_desc >= 0' failed.
    cd "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}"

    find "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}" -name "libiberty.a" -exec rm -v '{}' ';'
    find "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}" -name '*.la' -exec rm -v '{}' ';'

    if [ "${XBB_HOST_PLATFORM}" == "win32" ]
    then
      find "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}" -name "liblto_plugin.a" -exec rm -v '{}' ';'
      find "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}" -name "liblto_plugin.dll.a" -exec rm -v '{}' ';'
    fi
  )
}

function cross_strip_libs()
{
  if [ "${XBB_WITH_STRIP}" == "y" ]
  then
    (
      # TODO!
      PATH="${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin:${PATH}"

      echo
      echo "Stripping libraries..."

      cd "${XBB_TARGET_WORK_FOLDER_PATH}"

      # which "${XBB_GCC_TARGET}-objcopy"

      local libs=$(find "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}" -name '*.[ao]')
      for lib in ${libs}
      do
        if false
        then
          echo "${XBB_GCC_TARGET}-objcopy -R ... ${lib}"
          "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${XBB_GCC_TARGET}-objcopy" -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc "${lib}" || true
        else
          echo "[${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${XBB_GCC_TARGET}-strip --strip-debug ${lib}]"
          "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${XBB_GCC_TARGET}-strip" --strip-debug "${lib}"
        fi
      done
    )
  fi
}

function cross_final_tunings()
{
  # Create the missing LTO plugin links.
  # For `ar` to work with LTO objects, it needs the plugin in lib/bfd-plugins,
  # but the build leaves it where `ld` needs it. On POSIX, make a soft link.
  if [ "${XBB_FIX_LTO_PLUGIN:-}" == "y" ]
  then
    (
      cd "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}"

      echo
      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
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
