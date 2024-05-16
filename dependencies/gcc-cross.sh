# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://gitlab.archlinux.org/archlinux/packaging/packages/arm-none-eabi-gcc/-/blob/main/PKGBUILD
# https://gitlab.archlinux.org/archlinux/packaging/packages/riscv64-elf-gcc/-/blob/main/PKGBUILD

# -----------------------------------------------------------------------------

function gcc_cross_build_common()
{
  # Build the native dependencies.

  libiconv_build "${XBB_LIBICONV_VERSION}"

  ncurses_build "${XBB_NCURSES_VERSION}" --disable-lib-suffixes

  # new makeinfo needed by binutils 2.41 and up
  # checking for suffix of object files...   MAKEINFO doc/bfd.info
  # /Users/ilg/Work/xpack-dev-tools-build/riscv-none-elf-gcc-13.2.0-1/darwin-x64/sources/binutils-2.41/bfd/doc/bfd.texi:245: Node `Sections' requires a sectioning command (e.g., @unnumberedsubsec).

  # Requires libiconf & ncurses.
  texinfo_build "${XBB_TEXINFO_VERSION}"

  # ---------------------------------------------------------------------------

  if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "win32" ]
  then
    echo
    echo "# Building a bootstrap compiler..."

    # The bootstrap compiler (like aarch64-none-elf-gcc),
    # runs on Linux and produces arm/aarch64/riscv static ELFs.
    # The executables are not distributed, but the libraries are
    # copied into the Windows distribution, since building them
    # with the Windows executable is not realistic.

    gcc_cross_build_dependencies

    gcc_cross_build_all "${XBB_APPLICATION_TARGET_TRIPLET}"
  fi

  # Switch used during development to test bootstrap.
  if [ "${XBB_APPLICATION_BOOTSTRAP_ONLY:-""}" != "y" ] ||
     [ "${XBB_REQUESTED_HOST_PLATFORM}" != "win32" ]
  then

    # -------------------------------------------------------------------------
    # Build the target dependencies.

    xbb_reset_env
    xbb_set_target "requested"

    gcc_cross_build_dependencies

    gdb_cross_build_dependencies

    # -------------------------------------------------------------------------
    # Build the application binaries.

    xbb_set_executables_install_path "${XBB_APPLICATION_INSTALL_FOLDER_PATH}"
    xbb_set_libraries_install_path "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}"

    # -------------------------------------------------------------------------

    if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "win32" ]
    then
      binutils_cross_build "${XBB_BINUTILS_VERSION}" "${XBB_APPLICATION_TARGET_TRIPLET}"

      # As usual, for Windows things require more innovative solutions.
      # In this case the libraries are copied from the bootstrap,
      # and only the executables are build for Windows.
      gcc_cross_copy_linux_libs "${XBB_APPLICATION_TARGET_TRIPLET}"

      (
        # To access the bootstrap compiler (via CC_FOR_TARGET & Co)
        xbb_activate_installed_bin

        gcc_cross_build_final "${XBB_GCC_VERSION}" "${XBB_APPLICATION_TARGET_TRIPLET}"
      )
    else
      (
        if [ "${XBB_HOST_PLATFORM}" == "darwin" ] && \
           [ "${XBB_APPLICATION_USE_GCC_FOR_GCC_ON_MACOS:-""}" == "y" ]
        then
          # Workaround for gcov failing to build with clang 17 on macOS.
          xbb_prepare_gcc_env
        fi

        # For macOS & GNU/Linux build the toolchain natively.
        gcc_cross_build_all "${XBB_APPLICATION_TARGET_TRIPLET}"
      )
    fi

    gdb_cross_build "${XBB_APPLICATION_TARGET_TRIPLET}" ""

    if [ "${XBB_WITH_GDB_PY3}" == "y" ]
    then
      if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "win32" ]
      then
        # Shortcut, use the existing python.exe instead of building
        # if from sources. It also downloads the sources.
        python3_download_win "${XBB_PYTHON3_VERSION}"
        python3_copy_win_syslibs
      else # linux or darwin
        # Copy libraries from sources and dependencies.
        python3_copy_syslibs
      fi

      gdb_cross_build "${XBB_APPLICATION_TARGET_TRIPLET}" "-py3"
    fi

  fi
}

function gcc_cross_build_dependencies()
{
  libiconv_build "${XBB_LIBICONV_VERSION}"

  # New zlib, used in most of the tools.
  # For better control, without it some components pick the lib packed
  # inside the archive.
  # depends=('glibc')
  zlib_build "${XBB_ZLIB_VERSION}"

  # Libraries, required by gcc & other.
  # depends=('gcc-libs' 'sh')
  gmp_build "${XBB_GMP_VERSION}"

  # depends=('gmp>=5.0')
  mpfr_build "${XBB_MPFR_VERSION}"

  # depends=('mpfr')
  mpc_build "${XBB_MPC_VERSION}"

  # depends=('gmp')
  isl_build "${XBB_ISL_VERSION}"

  # depends=('sh')
  xz_build "${XBB_XZ_VERSION}"

  # depends on zlib, xz, (lz4)
  zstd_build "${XBB_ZSTD_VERSION}"
}

function gcc_cross_build_all()
{
  local triplet="$1"

  (
    # For makeinfo
    xbb_activate_installed_bin

    binutils_cross_build "${XBB_BINUTILS_VERSION}" "${triplet}"

    gcc_cross_build_first "${XBB_GCC_VERSION}" "${triplet}"

    (
      # Be sure to add the gcc first stage binaries to the path.
      # For macOS and Linux, the compiler is installed in the application folder.
      # For Windows, it is in the native dependencies folder.
      xbb_activate_installed_bin

      newlib_cross_build "${XBB_NEWLIB_VERSION}" "${triplet}"
    )

    gcc_cross_build_final "${XBB_GCC_VERSION}" "${triplet}"
  )

  # ---------------------------------------------------------------------------
  # The nano version is practically a new build installed in a
  # separate folder. Only the libraries are relevant; they are
  # copied in a separate step.
  if is_variable_set "XBB_NEWLIB_NANO_SUFFIX"
  then
    (
      local saved_path="${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}"

      # Temporarily set a distinct output folder and build again.
      xbb_set_executables_install_path "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${XBB_NEWLIB_NANO_SUFFIX}"

      # For makeinfo (binutils), flex (gcc-final)
      xbb_activate_installed_bin

      # Although in the initial versions this was a copy, it is cleaner
      # to do it again.
      binutils_cross_build "${XBB_BINUTILS_VERSION}" "${triplet}" --nano

      (
        # Add the gcc first stage binaries to the path.
        # For macOS and Linux, the compiler is installed in the application folder.
        # For Windows, it is in the native dependencies folder.
        # Also add the non-nano path, since this is where the compiler is.
        xbb_activate_installed_bin "${saved_path}/bin"

        newlib_cross_build "${XBB_NEWLIB_VERSION}" "${triplet}" --nano
      )
      gcc_cross_build_final "${XBB_GCC_VERSION}" "${triplet}" --nano
    )
    # Outside the sub-shell, since it uses the initial
    # XBB_EXECUTABLES_INSTALL_FOLDER_PATH.
    gcc_cross_copy_nano_multilibs "${triplet}"
  fi
}

# -----------------------------------------------------------------------------

function gcc_cross_define_flags_for_target()
{
  local is_nano="n"

  while [ $# -gt 0 ]
  do
    case "$1" in
      --nano )
        is_nano="y"
        shift
        ;;

      "" )
        shift
        ;;

      * )
        echo "Unsupported argument $1 in ${FUNCNAME[0]}()"
        exit 1
        ;;
    esac
  done

  local optimize="${XBB_CFLAGS_OPTIMIZATIONS_FOR_TARGET}"
  if [ "${is_nano}" != "y" ]
  then
    # For newlib, optimize for speed.
    optimize="$(echo ${optimize} | sed -e 's/-O[123]/-O2/g')"
    # DO NOT make this explicit, since exceptions references will always be
    # inserted in the `extab` section.
    # optimize+=" -fexceptions"
  else
    # For newlib-nano optimize for size and disable exceptions.
    optimize="$(echo ${optimize} | sed -e 's/-O[123]/-Os/g')"
    optimize="$(echo ${optimize} | sed -e 's/-Ofast/-Os/p')"
    optimize+=" -fno-exceptions"
  fi

  CFLAGS_FOR_TARGET="${optimize}"
  CXXFLAGS_FOR_TARGET="${optimize}"

  if [ "${XBB_IS_DEBUG}" == "y" ]
  then
    # Generally avoid `-g`, many local symbols cannot be removed by strip.
    CFLAGS_FOR_TARGET+=" -g"
    CXXFLAGS_FOR_TARGET+=" -g"
  fi

  # if [ "${XBB_WITH_LIBS_LTO:-}" == "y" ]
  # then
  #   CFLAGS_FOR_TARGET+=" -flto -ffat-lto-objects"
  #   CXXFLAGS_FOR_TARGET+=" -flto -ffat-lto-objects"
  # fi

  LDFLAGS_FOR_TARGET="--specs=nosys.specs"

  export CFLAGS_FOR_TARGET
  export CXXFLAGS_FOR_TARGET
  export LDFLAGS_FOR_TARGET
}

# -----------------------------------------------------------------------------

function gcc_cross_download()
{
  if [ ! -d "${XBB_SOURCES_FOLDER_PATH}/${XBB_GCC_SRC_FOLDER_NAME}" ]
  then
    (
      mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
      run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

      if [ "${XBB_APPLICATION_TEST_PRERELEASE:-""}" == "y" ]
      then
        run_verbose git_clone \
          "${XBB_GCC_GIT_URL}" \
          "${XBB_GCC_GIT_BRANCH:-"master"}" \
          "${XBB_GCC_GIT_COMMIT:-""}" \
          "${XBB_GCC_SRC_FOLDER_NAME}"
      else
        download_and_extract "${XBB_GCC_ARCHIVE_URL}" \
          "${XBB_GCC_ARCHIVE_NAME}" "${XBB_GCC_SRC_FOLDER_NAME}" \
          "${XBB_GCC_PATCH_FILE_NAME}"
      fi
    )
  fi
}

function gcc_cross_generate_riscv_multilib_file()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  # Not inside the previous if to allow multilib changes after download.
  if [ "${XBB_APPLICATION_WITHOUT_MULTILIB:-""}" != "y" ]
  then
    (
      echo
      echo "Running the multilib generator..."

      run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}/${XBB_GCC_SRC_FOLDER_NAME}/gcc/config/riscv"

      xbb_activate_dependencies_dev

      GCC_MULTILIB_FILE=${GCC_MULTILIB_FILE:-"t-elf-multilib"}

      # Be sure the ${XBB_GCC_MULTILIB_LIST} has no quotes, since it defines
      # multiple strings.

      # Change IFS temporarily so that we can pass a simple string of
      # whitespace delimited multilib tokens to multilib-generator
      local IFS=$' '
      echo
      echo "[python3 ./multilib-generator ${XBB_GCC_MULTILIB_LIST}]"
      python3 ./multilib-generator ${XBB_GCC_MULTILIB_LIST} > "${GCC_MULTILIB_FILE}"

      echo "----------------------------------------------------------------"
      cat "${GCC_MULTILIB_FILE}"
      echo "----------------------------------------------------------------"
    )
  fi
}

# Environment variables:
# XBB_GCC_SRC_FOLDER_NAME
# XBB_GCC_ARCHIVE_URL
# XBB_GCC_ARCHIVE_NAME
# XBB_GCC_PATCH_FILE_NAME

function gcc_cross_build_first()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local gcc_version="$1"
  shift

  local triplet="$1"
  shift

  local name_prefix="${triplet}-"

  local gcc_first_folder_name="${name_prefix}gcc-${gcc_version}-first"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${gcc_first_folder_name}"

  local gcc_first_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${gcc_first_folder_name}-installed"
  if [ ! -f "${gcc_first_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    gcc_cross_download

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${gcc_first_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${gcc_first_folder_name}"

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

      gcc_cross_define_flags_for_target

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running cross ${name_prefix}gcc first stage configure..."

          if is_develop
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${XBB_GCC_SRC_FOLDER_NAME}/configure" --help
          fi

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

          config_options+=("--infodir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/info")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")
          config_options+=("--htmldir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/html")
          config_options+=("--pdfdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/pdf")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${triplet}")

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
          config_options+=("--with-mpfr=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--with-mpc=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--with-isl=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--with-libiconv-prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          config_options+=("--with-zstd=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          config_options+=("--with-pkgversion=${XBB_BRANDING}")
          config_options+=("--with-newlib") # Arm, AArch64

          # Use the zlib compiled from sources.
          config_options+=("--with-system-zlib")

          if [ "${triplet}" == "arm-none-eabi" ]
          then
            config_options+=("--disable-libatomic") # ABE

            if [ "${XBB_WITHOUT_MULTILIB}" == "y" ]
            then
              config_options+=("--disable-multilib")
            else
              config_options+=("--enable-multilib") # Arm
              config_options+=("--with-multilib-list=${XBB_GCC_MULTILIB_LIST}")  # Arm
            fi
          elif [ "${triplet}" == "aarch64-none-elf" ]
          then
            config_options+=("--disable-libatomic") # ABE
          elif [ "${triplet}" == "riscv-none-elf" ]
          then
            config_options+=("--with-abi=${XBB_APPLICATION_GCC_ABI}")
            config_options+=("--with-arch=${XBB_APPLICATION_GCC_ARCH}")

            if [ "${XBB_WITHOUT_MULTILIB}" == "y" ]
            then
              config_options+=("--disable-multilib")
            else
              config_options+=("--enable-multilib")
            fi
          else
            echo "Unsupported triplet ${triplet} in ${FUNCNAME[0]}()"
            exit 1
          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${XBB_GCC_SRC_FOLDER_NAME}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${gcc_first_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gcc_first_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        # Partial build, without documentation.
        echo
        echo "Running cross ${name_prefix}gcc first stage make..."

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
    echo "Component cross ${name_prefix}gcc first stage already installed"
  fi
}

# -----------------------------------------------------------------------------

function gcc_cross_copy_linux_libs()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local triplet="$1"

  local copy_linux_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-copy-linux-libs-completed"
  if [ ! -f "${copy_linux_stamp_file_path}" ]
  then

    local linux_path="${XBB_NATIVE_DEPENDENCIES_INSTALL_FOLDER_PATH}"

    (
      run_verbose_develop cd "${XBB_TARGET_WORK_FOLDER_PATH}"

      copy_folder "${linux_path}/${triplet}/lib" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/${triplet}/lib"
      copy_folder "${linux_path}/${triplet}/include" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/${triplet}/include"

      copy_folder "${linux_path}/include" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/include"
      copy_folder "${linux_path}/lib" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib"
      copy_folder "${linux_path}/share" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/share"
    )

    (
      run_verbose_develop cd "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}"
      find "${triplet}/lib" "${triplet}/include" "include" "lib" "share" \
        -perm /111 -and ! -type d \
        -exec rm '{}' ';'
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${copy_linux_stamp_file_path}"

  else
    echo "Component copy-linux-libs already processed"
  fi
}

# -----------------------------------------------------------------------------

# Environment variables:
# XBB_GCC_SRC_FOLDER_NAME
# XBB_GCC_ARCHIVE_URL
# XBB_GCC_ARCHIVE_NAME
# XBB_GCC_PATCH_FILE_NAME

function gcc_cross_build_final()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local gcc_version="$1"
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

  local gcc_final_folder_name="${name_prefix}gcc-${gcc_version}-final${name_suffix}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${gcc_final_folder_name}"

  local gcc_final_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${gcc_final_folder_name}-installed"
  if [ ! -f "${gcc_final_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    gcc_cross_download

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${gcc_final_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${gcc_final_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      # if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
      # then
      #   # Hack to avoid spurious errors like:
      #   # fatal error: bits/nested_exception.h: No such file or directory
      #   CPPFLAGS+=" -I${XBB_BUILD_FOLDER_PATH}/${gcc_final_folder_name}/${triplet}/libstdc++-v3/include"
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

      # Do not add CRT_glob.o here, it will fail with already defined,
      # since it is already handled by --enable-mingw-wildcard.

      xbb_adjust_ldflags_rpath

      gcc_cross_define_flags_for_target "${nano_option}"

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        export AR_FOR_TARGET="$(which ${name_prefix}ar)"
        export NM_FOR_TARGET="$(which ${name_prefix}nm)"
        export OBJDUMP_FOR_TARET="$(which ${name_prefix}objdump)"
        export STRIP_FOR_TARGET="$(which ${name_prefix}strip)"
        export CC_FOR_TARGET="$(which ${name_prefix}gcc)"
        export GCC_FOR_TARGET="$(which ${name_prefix}gcc)"
        export CXX_FOR_TARGET="$(which ${name_prefix}g++)"

        # There are some internal tools that must be compiled natively for the
        # build machine (Linux).
        export CC_FOR_BUILD="${XBB_NATIVE_CC}"
        export CXX_FOR_BUILD="${XBB_NATIVE_CXX}"
        export AR_FOR_BUILD="${XBB_NATIVE_AR}"
        export LD_FOR_BUILD="${XBB_NATIVE_LD}"
        export NM_FOR_BUILD="${XBB_NATIVE_NM}"
        export RANLIB_FOR_BUILD="${XBB_NATIVE_RANLIB}"

        export CFLAGS_FOR_BUILD="$(echo "${XBB_CFLAGS_NO_W}" | sed -e 's|-D__USE_MINGW_ACCESS||')"
        export CXXFLAGS_FOR_BUILD="${XBB_CXXFLAGS_NO_W}"
        export CPPFLAGS_FOR_BUILD=""
        LDFLAGS_FOR_BUILD="-O2 -v -Wl,--gc-sections"
        local libs_path="$(xbb_get_toolchain_library_path "${CC_FOR_BUILD}")"

        export LDFLAGS_FOR_BUILD+=" $(xbb_expand_linker_rpaths "${libs_path}")"
      fi

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running cross ${name_prefix}gcc${name_suffix} final stage configure..."

          if is_develop
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${XBB_GCC_SRC_FOLDER_NAME}/configure" --help
          fi

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

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")
          # `${with_sysroot}${native_system_header_dir}/stdio.h`
          # is checked for presence; if not present `inhibit_libc=true` and
          # libgcov.a is compiled with empty functions.
          # https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/issues/1
          config_options+=("--with-sysroot=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/${triplet}")
          config_options+=("--with-native-system-header-dir=/include")

          config_options+=("--infodir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/info")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")
          config_options+=("--htmldir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/html")
          config_options+=("--pdfdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/pdf")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${triplet}")

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

          if [ "${triplet}" == "arm-none-eabi" ]
          then
            config_options+=("--disable-libatomic") # ABE

            if [ "${XBB_WITHOUT_MULTILIB}" == "y" ]
            then
              config_options+=("--disable-multilib")
            else
              config_options+=("--enable-multilib") # Arm
              config_options+=("--with-multilib-list=${XBB_GCC_MULTILIB_LIST}")  # Arm
            fi
          elif [ "${triplet}" == "aarch64-none-elf" ]
          then
            config_options+=("--disable-libatomic") # ABE
          elif [ "${triplet}" == "riscv-none-elf" ]
          then
            config_options+=("--with-abi=${XBB_APPLICATION_GCC_ABI}")
            config_options+=("--with-arch=${XBB_APPLICATION_GCC_ARCH}")

            if [ "${XBB_WITHOUT_MULTILIB}" == "y" ]
            then
              config_options+=("--disable-multilib")
            else
              config_options+=("--enable-multilib")
            fi
          else
            echo "Unsupported triplet ${triplet} in ${FUNCNAME[0]}()"
            exit 1
          fi

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

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${gcc_final_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gcc_final_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        # Partial build, without documentation.
        echo
        echo "Running cross ${name_prefix}gcc${name_suffix} final stage make..."

        if [ "${XBB_HOST_PLATFORM}" != "win32" ]
        then

          # Passing USE_TM_CLONE_REGISTRY=0 via INHIBIT_LIBC_CFLAGS to disable
          # transactional memory related code in crtbegin.o.
          # This is a workaround. Better approach is have a t-* to set this flag via
          # CRTSTUFF_T_CFLAGS

          if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then
            if is_develop
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

          # if [ "${is_nano}" == "y" ]
          # then
          #   cross_copy_nono_libs "${name_prefix}"
          # fi

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

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${XBB_GCC_SRC_FOLDER_NAME}" \
        "gcc-${gcc_version}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${gcc_final_stamp_file_path}"

  else
    echo "Component cross ${name_prefix}gcc${name_suffix} final stage already installed"
  fi

  if [ "${is_nano}" != "y" ]
  then
    tests_add "gcc_cross_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin" "${triplet}"
  fi
}

function gcc_cross_test()
{
  local test_bin_path="$1"
  local triplet="$2"

  (
    CC="${test_bin_path}/${triplet}-gcc"
    CXX="${test_bin_path}/${triplet}-g++"

    if [ "${XBB_BUILD_PLATFORM}" != "win32" ]
    then
      echo
      echo "Checking the ${triplet}-gcc shared libraries..."

      show_host_libs "${CC}"
      show_host_libs "${CXX}"

      if [ "${XBB_HOST_PLATFORM}" != "win32" ]
      then
        show_host_libs "$(${CC} -print-prog-name=cc1)"
        show_host_libs "$(${CC} -print-prog-name=cc1plus)"
        show_host_libs "$(${CC} -print-prog-name=collect2)"
        show_host_libs "$(${CC} -print-prog-name=lto-wrapper)"
        show_host_libs "$(${CC} -print-prog-name=lto1)"
      fi
    fi

    echo
    echo "Testing the ${triplet}-gcc configuration..."

    run_host_app_verbose "${CC}" --help
    run_host_app_verbose "${CC}" -v
    run_host_app_verbose "${CC}" -dumpversion
    run_host_app_verbose "${CC}" -dumpmachine

    run_host_app_verbose "${CC}" -print-search-dirs
    run_host_app_verbose "${CC}" -print-libgcc-file-name
    run_host_app_verbose "${CC}" -print-multi-directory
    run_host_app_verbose "${CC}" -print-multi-lib
    run_host_app_verbose "${CC}" -print-multi-os-directory
    run_host_app_verbose "${CC}" -print-sysroot

    echo
    echo "Testing if ${triplet}-gcc compiles simple programs..."

    rm -rf "${XBB_TESTS_FOLDER_PATH}/${triplet}-gcc"
    mkdir -pv "${XBB_TESTS_FOLDER_PATH}/${triplet}-gcc"
    run_verbose_develop cd "${XBB_TESTS_FOLDER_PATH}/${triplet}-gcc"

    echo
    echo "pwd: $(pwd)"

    # -------------------------------------------------------------------------

    if [ "${triplet}" == "arm-none-eabi" ]
    then
      # /Users/ilg/Work/xpack-dev-tools-build/arm-none-eabi-gcc-13.2.1-1.1/darwin-x64/application/lib/gcc/arm-none-eabi/13.2.1/../../../../arm-none-eabi/bin/ld: /Users/ilg/Work/xpack-dev-tools-build/arm-none-eabi-gcc-13.2.1-1.1/darwin-x64/application/lib/gcc/arm-none-eabi/13.2.1/../../../../arm-none-eabi/lib/libg.a(libc_a-getentropyr.o): in function `_getentropy_r':
      # (.text._getentropy_r+0x1c): undefined reference to `_getentropy'
      # specs="-specs=rdimon.specs"
      specs="-specs=nosys.specs"
    elif [ "${triplet}" == "aarch64-none-elf" ]
    then
      # specs="-specs=rdimon.specs"
      specs="-specs=nosys.specs"
    elif [ "${triplet}" == "riscv-none-elf" ]
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

    VERBOSE=""
    if is_develop
    then
      VERBOSE="-v"
    fi

    # Only compile tests, running the binaries via qemu is possible,
    # but requires a minimum startup code.

    run_host_app_verbose "${CC}" hello.c -o hello-c.elf "${specs}" -g -v
    run_verbose file hello-c.elf

    run_host_app_verbose "${CC}" -c hello.c -o hello.c.o -flto ${VERBOSE}
    run_host_app_verbose "${CC}" hello.c.o -o hello-c-lto.elf "${specs}" -flto ${VERBOSE}
    run_verbose file hello-c-lto.elf

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

// Newlib 4.4
extern "C" int
_getentropy (void *, size_t);

int
_getentropy (void *, size_t)
{
}
__EOF__

    run_host_app_verbose "${CXX}" hello.cpp -o hello-cpp.elf "${specs}" -g ${VERBOSE}
    run_verbose file hello-cpp.elf

    run_host_app_verbose "${CXX}" -c hello.cpp -o hello.cpp.o  -flto
    run_host_app_verbose "${CXX}" hello.cpp.o -o hello-cpp-lto.elf "${specs}" -flto ${VERBOSE}
    run_verbose file hello-cpp-lto.elf

    run_host_app_verbose "${CXX}" hello.cpp -o hello-cpp-gcov.elf "${specs}" -fprofile-arcs -ftest-coverage -lgcov ${VERBOSE}
    run_verbose file hello-cpp-gcov.elf

  )
}

# -----------------------------------------------------------------------------

function gcc_cross_copy_nano_multilibs()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local triplet="$1"

  echo
  echo "# Copying newlib${XBB_NEWLIB_NANO_SUFFIX} libraries..."

  # local name_prefix="${triplet}-"

  # if [ "${XBB_HOST_PLATFORM}" == "win32" ]
  # then
  #   target_gcc="${triplet}-gcc"
  # else
  #   if [ -x "${APP_PREFIX_NANO}/bin/${name_prefix}gcc" ]
  #   then
  #     target_gcc="${APP_PREFIX_NANO}/bin/${name_prefix}gcc"
  #   # elif [ -x "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${name_prefix}gcc" ]
  #   # then
  #   #   target_gcc="${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${name_prefix}gcc"
  #   else
  #     echo "No ${name_prefix}gcc --print-multi-lib"
  #     exit 1
  #   fi
  # fi

  # Copy the libraries after appending the `_nano` suffix.
  # Iterate through all multilib names.
  local src_folder="${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${XBB_NEWLIB_NANO_SUFFIX}/${triplet}/lib" \
  local dst_folder="${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/${triplet}/lib" \
  local target_gcc="${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${XBB_NEWLIB_NANO_SUFFIX}/bin/${triplet}-gcc"

  echo ${target_gcc}
  multilibs=( $("${target_gcc}" -print-multi-lib 2>/dev/null) )
  if [ ${#multilibs[@]} -gt 0 ]
  then
    for multilib in "${multilibs[@]}"
    do
      multi_folder="${multilib%%;*}"
      newlib_cross_copy_nano_libs "${src_folder}/${multi_folder}" \
        "${dst_folder}/${multi_folder}"
    done
  else
    newlib_cross_copy_nano_libs "${src_folder}" "${dst_folder}"
  fi

  # Copy the nano configured newlib.h file into the location that nano.specs
  # expects it to be.
  mkdir -pv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/${triplet}/include/newlib${XBB_NEWLIB_NANO_SUFFIX}"
  cp -v -f "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}${XBB_NEWLIB_NANO_SUFFIX}/${triplet}/include/newlib.h" \
    "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/${triplet}/include/newlib${XBB_NEWLIB_NANO_SUFFIX}/newlib.h"
}

function gcc_cross_tidy_up()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  (
    echo
    echo "# Tidying up..."

    # find: pred.c:1932: launch: Assertion `starting_desc >= 0' failed.
    run_verbose_develop cd "${XBB_APPLICATION_INSTALL_FOLDER_PATH}"

    find "${XBB_APPLICATION_INSTALL_FOLDER_PATH}" -name "libiberty.a" -exec rm -v '{}' ';'
    find "${XBB_APPLICATION_INSTALL_FOLDER_PATH}" -name '*.la' -exec rm -v '{}' ';'

    if [ "${XBB_HOST_PLATFORM}" == "win32" ]
    then
      find "${XBB_APPLICATION_INSTALL_FOLDER_PATH}" -name "liblto_plugin.a" -exec rm -v '{}' ';'
      find "${XBB_APPLICATION_INSTALL_FOLDER_PATH}" -name "liblto_plugin.dll.a" -exec rm -v '{}' ';'
    fi
  )
}

function gcc_cross_strip_libs()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local triplet="$1"

  if with_strip
  then
    (
      echo
      echo "# Stripping libraries..."

      run_verbose_develop cd "${XBB_TARGET_WORK_FOLDER_PATH}"

      # which "${triplet}-objcopy"

      local libs=$(find "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/${triplet}/lib" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib/gcc" -name '*.[ao]')
      for lib in ${libs}
      do
        if false
        then
          echo "${triplet}-objcopy -R ... ${lib}"
          "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/bin/${triplet}-objcopy" -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc "${lib}" || true
        else
          echo "[${XBB_APPLICATION_INSTALL_FOLDER_PATH}/bin/${triplet}-strip --strip-debug ${lib}]"
          "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/bin/${triplet}-strip" --strip-debug "${lib}"
        fi
      done
    )
  else
    echo "gcc_cross_strip_libs() skipped"
  fi
}

function gcc_cross_final_tunings()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  # Create the missing LTO plugin links.
  # For `ar` to work with LTO objects, it needs the plugin in lib/bfd-plugins,
  # but the build leaves it where `ld` needs it. On POSIX, make a soft link.
  if [ "${XBB_FIX_LTO_PLUGIN:-}" == "y" ]
  then
    (
      run_verbose_develop cd "${XBB_APPLICATION_INSTALL_FOLDER_PATH}"

      echo
      if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "win32" ]
      then
        xbb_lto_plugin_original_name="${XBB_LTO_PLUGIN_ORIGINAL_NAME:-liblto_plugin.dll}"
        xbb_lto_plugin_bfd_path="${XBB_LTO_PLUGIN_BFD_PATH:-lib/bfd-plugins/liblto_plugin.dll}"

        echo
        echo "# Copying ${xbb_lto_plugin_original_name}..."

        mkdir -pv "$(dirname ${xbb_lto_plugin_bfd_path})"

        if [ ! -f "${xbb_lto_plugin_bfd_path}" ]
        then
          local plugin_path="$(find * -type f -name ${xbb_lto_plugin_original_name})"
          if [ ! -z "${plugin_path}" ]
          then
            cp -v "${plugin_path}" "${xbb_lto_plugin_bfd_path}"
          else
            echo "${xbb_lto_plugin_original_name} not found"
            exit 1
          fi
        fi
      else
        # macOS or Linux
        xbb_lto_plugin_original_name="${XBB_LTO_PLUGIN_ORIGINAL_NAME:-liblto_plugin.so}"
        xbb_lto_plugin_bfd_path="${XBB_LTO_PLUGIN_BFD_PATH:-lib/bfd-plugins/liblto_plugin.so}"

        echo
        echo "# Creating ${xbb_lto_plugin_original_name} link..."

        mkdir -pv "$(dirname ${xbb_lto_plugin_bfd_path})"
        if [ ! -f "${xbb_lto_plugin_bfd_path}" ]
        then
          local plugin_path="$(find * -type f -name ${xbb_lto_plugin_original_name})"
          if [ ! -z "${plugin_path}" ]
          then
            ln -s -v "../../${plugin_path}" "${xbb_lto_plugin_bfd_path}"
          else
            echo "${xbb_lto_plugin_original_name} not found"
            exit 1
          fi
        fi
      fi
    )
  fi
}

# -----------------------------------------------------------------------------
