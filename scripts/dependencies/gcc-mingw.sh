# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# The configurations generally follow the Linux Arch configurations, but
# also MSYS2 and HomeBrew were considered.

# The difference is the install location, which no longer uses `/usr`.

# https://gcc.gnu.org
# https://gcc.gnu.org/wiki/InstallingGCC

# https://github.com/archlinux/svntogit-community/blob/packages/mingw-w64-gcc/trunk/PKGBUILD

# MSYS2 uses a lot of patches.
# https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-gcc/PKGBUILD

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/mingw-w64.rb

# https://ftp.gnu.org/gnu/gcc/
# 2019-02-22, "8.3.0"
# 2019-05-03, "9.1.0"
# 2019-08-12, "9.2.0"
# 2019-11-14, "7.5.0" *
# 2020-03-04, "8.4.0"
# 2020-03-12, "9.3.0"
# 2021-04-08, "10.3.0"
# 2021-04-27, "11.1.0" +
# 2021-05-14, "8.5.0" *
# 2021-07-28, "11.2.0"
# 2022-04-21, "11.3.0"
# 2022-05-06, "12.1.0"
# 2022-08-19, "12.2.0"

# -----------------------------------------------------------------------------


function build_mingw_gcc_dependencies()
{
  build_libiconv "${XBB_LIBICONV_VERSION}"

  # New zlib, used in most of the tools.
  # depends=('glibc')
  build_zlib "${XBB_ZLIB_VERSION}"

  # Libraries, required by gcc & other.
  # depends=('gcc-libs' 'sh')
  build_gmp "${XBB_GMP_VERSION}"

  # depends=('gmp>=5.0')
  build_mpfr "${XBB_MPFR_VERSION}"

  # depends=('mpfr')
  build_mpc "${XBB_MPC_VERSION}"

  # depends=('gmp')
  build_isl "${XBB_ISL_VERSION}"

  # depends=('sh')
  build_xz "${XBB_XZ_VERSION}"

  # depends on zlib, xz, (lz4)
  build_zstd "${XBB_ZSTD_VERSION}"
}

function build_mingw_gcc_all_triplets()
{
  for triplet in "${XBB_MINGW_TRIPLETS[@]}"
  do

    # Set XBB_TARGET_STRIP, _RANLIB & _OBJDUMP
    xbb_set_extra_target_env "${triplet}"

    build_binutils "${XBB_BINUTILS_VERSION}" --triplet="${triplet}" --program-prefix="${triplet}"

    # Deploy the headers, they are needed by the compiler.
    build_mingw_headers --triplet="${triplet}"

    # Build only the compiler, without libraries.
    build_mingw_gcc_first "${XBB_GCC_VERSION}" --triplet="${triplet}"

    # Refers to mingw headers.
    build_mingw_widl --triplet="${triplet}"

    # Build some native tools.
    build_mingw_libmangle --triplet="${triplet}"
    build_mingw_gendef --triplet="${triplet}"

    (
      xbb_activate_installed_bin
      (
        # Fails if CC is defined to a native compiler.
        xbb_prepare_gcc_env "${triplet}-"

        build_mingw_crt --triplet="${triplet}"
        build_mingw_winpthreads --triplet="${triplet}"
      )

      # With the run-time available, build the C/C++ libraries and the rest.
      build_mingw_gcc_final --triplet="${triplet}" # "${XBB_BOOTSTRAP_SUFFIX}"
    )

  done
}

# -----------------------------------------------------------------------------

# XBB_MINGW_GCC_PATCH_FILE_NAME
function build_mingw_gcc_first()
{
  export mingw_gcc_version="$1"
  shift

  local triplet="${XBB_TARGET_TRIPLET}" # "x86_64-w64-mingw32"
  local name_prefix

  while [ $# -gt 0 ]
  do
    case "$1" in
      --triplet=* )
        triplet=$(xbb_parse_option "$1")
        ;;

      * )
        echo "Unsupported argument $1 in ${FUNCNAME[0]}()"
        exit 1
        ;;
    esac
    shift
  done

  name_prefix="${triplet}-"

  # Number
  local mingw_gcc_version_major=$(echo ${mingw_gcc_version} | sed -e 's|\([0-9][0-9]*\)\..*|\1|')

  local mingw_gcc_src_folder_name="gcc-${mingw_gcc_version}"

  local mingw_gcc_archive="${mingw_gcc_src_folder_name}.tar.xz"
  local mingw_gcc_url="https://ftp.gnu.org/gnu/gcc/gcc-${mingw_gcc_version}/${mingw_gcc_archive}"

  export mingw_gcc_folder_name="${name_prefix}gcc-${mingw_gcc_version}"

  local mingw_gcc_step1_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${name_prefix}gcc-first-${mingw_gcc_version}-installed"
  if [ ! -f "${mingw_gcc_step1_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${mingw_gcc_url}" "${mingw_gcc_archive}" \
      "${mingw_gcc_src_folder_name}" \
      "${XBB_MINGW_GCC_PATCH_FILE_NAME:-none}"

    mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${mingw_gcc_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${mingw_gcc_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${mingw_gcc_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        # x86_64-w64-mingw32/bin/as: insn-emit.o: too many sections (32823)
        # `-Wa,-mbig-obj` is passed to the wrong compiler, and fails
        CXXFLAGS=$(echo ${CXXFLAGS} | sed -e 's|-ffunction-sections -fdata-sections||')

        # Without it gcc cannot identify cc1 and other binaries
        CXXFLAGS+=" -D__USE_MINGW_ACCESS"
      fi

      # LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC}"
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
          echo "Running ${name_prefix}gcc first configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            # For the native build, --disable-shared failed with errors in libstdc++-v3
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${mingw_gcc_src_folder_name}/configure" --help
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${mingw_gcc_src_folder_name}/gcc/configure" --help

            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${mingw_gcc_src_folder_name}/libgcc/configure" --help
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${mingw_gcc_src_folder_name}/libstdc++-v3/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}") # Arch /usr
          config_options+=("--libexecdir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib") # Arch /usr/lib
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}") # Same as BUILD for bootstrap
          config_options+=("--target=${triplet}") # Arch

          if [ "${XBB_HOST_PLATFORM}" == "win32" ]
          then
            config_options+=("--program-prefix=${triplet}-")

            # config_options+=("--with-arch=x86-64")
            # config_options+=("--with-tune=generic")

            config_options+=("--enable-mingw-wildcard")

            # This should point to the location where mingw headers are,
            # relative to --prefix, but starting with /.
            # config_options+=("--with-native-system-header-dir=${triplet}/include")

            # Disable look up installations paths in the registry.
            config_options+=("--disable-win32-registry")
            # Turn off symbol versioning in the shared library
            config_options+=("--disable-symvers")
          fi

          # config_options+=("--with-sysroot=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")
          config_options+=("--with-pkgversion=${XBB_GCC_BRANDING}")

          config_options+=("--with-default-libstdcxx-abi=new")
          config_options+=("--with-diagnostics-color=auto")
          config_options+=("--with-dwarf2") # Arch

          # In file included from /Host/home/ilg/Work/mingw-w64-gcc-11.3.0-1/win32-x64/sources/gcc-11.3.0/libcc1/findcomp.cc:28:
          # /Host/home/ilg/Work/mingw-w64-gcc-11.3.0-1/win32-x64/sources/gcc-11.3.0/libcc1/../gcc/system.h:698:10: fatal error: gmp.h: No such file or directory
          config_options+=("--with-gmp=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--with-mpfr=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--with-mpc=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--with-isl=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--with-libiconv-prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--with-zstd=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          # Use the zlib compiled from sources.
          config_options+=("--with-system-zlib")

          config_options+=("--without-cuda-driver")

          config_options+=("--enable-languages=c,c++,fortran,objc,obj-c++,lto") # Arch

          if true
          then
            # undefined reference to `__imp_pthread_mutex_lock'
            config_options+=("--enable-shared") # Arch
          else
            config_options+=("--disable-shared")
          fi

          config_options+=("--enable-static") # Arch

          config_options+=("--enable-__cxa_atexit")
          config_options+=("--enable-checking=release") # Arch
          config_options+=("--enable-cloog-backend=isl") # Arch
          config_options+=("--enable-fully-dynamic-string") # Arch
          config_options+=("--enable-libgomp") # Arch
          config_options+=("--enable-libatomic")
          config_options+=("--enable-graphite")
          config_options+=("--enable-libquadmath")
          config_options+=("--enable-libquadmath-support")
          config_options+=("--enable-libssp")

          config_options+=("--enable-libstdcxx")
          config_options+=("--enable-libstdcxx-time=yes")
          config_options+=("--enable-libstdcxx-visibility")
          config_options+=("--enable-libstdcxx-threads")
          config_options+=("--enable-libstdcxx-filesystem-ts=yes") # Arch
          config_options+=("--enable-libstdcxx-time=yes") # Arch
          config_options+=("--enable-lto") # Arch
          config_options+=("--enable-pie-tools")
          config_options+=("--enable-threads=posix") # Arch

          # Fails with:
          # x86_64-w64-mingw32/bin/ld: cannot find -lgcc_s: No such file or directory
          # config_options+=("--enable-version-specific-runtime-libs")

          # Apparently innefective, on i686 libgcc_s_dw2-1.dll is used anyway.
          # config_options+=("--disable-dw2-exceptions")
          config_options+=("--disable-install-libiberty")
          config_options+=("--disable-libstdcxx-debug")
          config_options+=("--disable-libstdcxx-pch")
          config_options+=("--disable-multilib") # Arch
          config_options+=("--disable-nls")
          config_options+=("--disable-sjlj-exceptions") # Arch
          config_options+=("--disable-werror")

          # Arch configures only the gcc folder, but in this case it
          # fails with missing libiberty.a.
          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${mingw_gcc_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${mingw_gcc_folder_name}/config-step1-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${mingw_gcc_folder_name}/configure-step1-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running ${name_prefix}gcc first make..."

        # Build.
        run_verbose make -j ${XBB_JOBS} all-gcc

        run_verbose make install-strip-gcc

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${mingw_gcc_folder_name}/make-step1-output-$(ndate).txt"
    )

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${mingw_gcc_step1_stamp_file_path}"

  else
    echo "Component ${name_prefix}gcc first already installed."
  fi
}

function build_mingw_gcc_final()
{
  local triplet="${XBB_TARGET_TRIPLET}" # "x86_64-w64-mingw32"
  local name_prefix

  while [ $# -gt 0 ]
  do
    case "$1" in
      --triplet=* )
        triplet=$(xbb_parse_option "$1")
        ;;

      * )
        echo "Unsupported argument $1 in ${FUNCNAME[0]}()"
        exit 1
        ;;
    esac
    shift
  done

  name_prefix="${triplet}-"

  local mingw_gcc_final_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${name_prefix}gcc-final-${mingw_gcc_version}-installed"
  if [ ! -f "${mingw_gcc_final_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${mingw_gcc_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${mingw_gcc_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${mingw_gcc_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      # LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC}"
      LDFLAGS="${XBB_LDFLAGS_APP}"
      xbb_adjust_ldflags_rpath

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      xbb_show_env_develop

      echo
      echo "Running ${name_prefix}gcc final configure..."

      run_verbose make -j configure-target-libgcc

      if false # [ -f "${triplet}/libgcc/auto-target.h" ]
      then
        # Might no longer be needed with modern GCC.
        run_verbose grep 'HAVE_SYS_MMAN_H' "${triplet}/libgcc/auto-target.h"
        run_verbose sed -i.bak -e 's|#define HAVE_SYS_MMAN_H 1|#define HAVE_SYS_MMAN_H 0|' \
          "${triplet}/libgcc/auto-target.h"
        run_verbose diff "${triplet}/libgcc/auto-target.h.bak" "${triplet}/libgcc/auto-target.h" || true
      fi

      echo
      echo "Running ${name_prefix}gcc final make..."

      # Build.
      run_verbose make -j ${XBB_JOBS}

      # make install-strip
      run_verbose make install-strip

      (
        cd "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}"
        run_verbose find . -name '*.dll'
        # The DLLs are expected to be in the /${triplet}/lib folder.
        run_verbose find bin lib -name '*.dll' -exec cp -v '{}' "${triplet}/lib" ';'
      )

      # Remove weird files like x86_64-w64-mingw32-x86_64-w64-mingw32-c++.exe
      run_verbose rm -rf "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${triplet}-${triplet}-"*

    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${mingw_gcc_folder_name}/make-final-output-$(ndate).txt"

    (
      if true
      then

        # TODO!
        # For *-w64-mingw32-strip
        xbb_activate_installed_bin

        echo
        echo "Stripping ${name_prefix}gcc libraries..."

        cd "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}" # ! usr

        set +e
        find ${triplet} \
          -name '*.so' -type f \
          -print \
          -exec "${triplet}-strip" --strip-debug '{}' ';'
        find ${triplet} \
          -name '*.so.*'  \
          -type f \
          -print \
          -exec "${triplet}-strip" --strip-debug '{}' ';'
        # Note: without ranlib, windows builds failed.
        find ${triplet} lib/gcc/${triplet} \
          -name '*.a'  \
          -type f  \
          -print \
          -exec "${triplet}-strip" --strip-debug '{}' ';' \
          -exec "${triplet}-ranlib" '{}' ';'
        set -e

      fi
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${mingw_gcc_folder_name}/strip-final-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${mingw_gcc_final_stamp_file_path}"

  else
    echo "Component ${name_prefix}gcc final already installed."
  fi

  tests_add "test_mingw_gcc" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin" "${triplet}"
}

function test_mingw_gcc()
{
  local test_bin_path="$1"
  local triplet="$2"

  xbb_set_extra_target_env "${triplet}"

  (
    CC="${test_bin_path}/${triplet}-gcc${XBB_HOST_DOT_EXE}"
    CXX="${test_bin_path}/${triplet}-g++${XBB_HOST_DOT_EXE}"
    F90="${test_bin_path}/${triplet}-gfortran${XBB_HOST_DOT_EXE}"

    AR="${test_bin_path}/${triplet}-gcc-ar${XBB_HOST_DOT_EXE}"
    NM="${test_bin_path}/${triplet}-gcc-nm${XBB_HOST_DOT_EXE}"
    RANLIB="${test_bin_path}/${triplet}-gcc-ranlib${XBB_HOST_DOT_EXE}"

    OBJDUMP="${test_bin_path}/${triplet}-objdump${XBB_HOST_DOT_EXE}"

    GCOV="${test_bin_path}/${triplet}-gcov${XBB_HOST_DOT_EXE}"
    GCOV_DUMP="${test_bin_path}/${triplet}-gcov-dump${XBB_HOST_DOT_EXE}"
    GCOV_TOOL="${test_bin_path}/${triplet}-gcov-tool${XBB_HOST_DOT_EXE}"

    DLLTOOL="${test_bin_path}/${triplet}-dlltool${XBB_HOST_DOT_EXE}"
    GENDEF="${test_bin_path}/${triplet}-gendef${XBB_HOST_DOT_EXE}"
    WIDL="${test_bin_path}/${triplet}-widl${XBB_HOST_DOT_EXE}"

    xbb_show_env_develop

    echo
    echo "Checking the ${triplet}-gcc shared libraries..."

    show_host_libs "${CC}"
    show_host_libs "${CXX}"
    if [ -f "${F90}" ]
    then
      show_host_libs "${F90}"
    fi

    show_host_libs "${AR}"
    show_host_libs "${NM}"
    show_host_libs "${RANLIB}"
    show_host_libs "${GCOV}"

    (
      set +e
      show_host_libs "$(run_target_app ${CC} --print-prog-name=cc1 | sed -e 's|^z:||' -e 's|\r$||')"
      show_host_libs "$(run_target_app ${CC} --print-prog-name=cc1plus | sed -e 's|^z:||' -e 's|\r$||')"
      show_host_libs "$(run_target_app ${CC} --print-prog-name=collect2 | sed -e 's|^z:||' -e 's|\r$||')"
      show_host_libs "$(run_target_app ${CC} --print-prog-name=lto1 | sed -e 's|^z:||' -e 's|\r$||')"
      show_host_libs "$(run_target_app ${CC} --print-prog-name=lto-wrapper | sed -e 's|^z:||' -e 's|\r$||')"
    )

    echo
    echo "Testing if ${triplet}-gcc binaries start properly..."

    run_host_app_verbose "${CC}" --version
    run_host_app_verbose "${CXX}" --version
    if [ -f "${F90}" ]
    then
      run_host_app_verbose "${F90}" --version
    fi

    # x86_64-w64-mingw32-gcc-ar.exe: Cannot find binary 'ar'
    # x86_64-w64-mingw32-gcc-nm.exe: Cannot find binary 'nm'
    if [ "${XBB_HOST_PLATFORM}" != "win32" ]
    then
      run_host_app_verbose "${AR}" --version
      run_host_app_verbose "${NM}" --version
      run_host_app_verbose "${RANLIB}" --version
    fi

    run_host_app_verbose "${GCOV}" --version
    run_host_app_verbose "${GCOV_DUMP}" --version
    run_host_app_verbose "${GCOV_TOOL}" --version

    run_host_app_verbose "${GENDEF}" --help

    echo
    echo "Showing the ${triplet}-gcc configurations..."

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
    run_host_app_verbose "${CC}" -print-file-name=libgcc_s_seh-1.dll
    run_host_app_verbose "${CC}" -print-prog-name=cc1

    run_host_app_verbose "${CXX}" --help
    run_host_app_verbose "${CXX}" -v
    run_host_app_verbose "${CXX}" -dumpversion
    run_host_app_verbose "${CXX}" -dumpmachine

    run_host_app_verbose "${CXX}" -print-search-dirs
    run_host_app_verbose "${CXX}" -print-libgcc-file-name
    run_host_app_verbose "${CXX}" -print-multi-directory
    run_host_app_verbose "${CXX}" -print-multi-lib
    run_host_app_verbose "${CXX}" -print-multi-os-directory
    run_host_app_verbose "${CXX}" -print-sysroot
    run_host_app_verbose "${CXX}" -print-file-name=libstdc++-6.dll
    run_host_app_verbose "${CXX}" -print-file-name=libwinpthread-1.dll
    run_host_app_verbose "${CXX}" -print-prog-name=cc1plus

    echo
    echo "Testing if ${triplet}-gcc compiles simple programs..."

    rm -rf "${XBB_TESTS_FOLDER_PATH}/${triplet}-gcc"
    mkdir -pv "${XBB_TESTS_FOLDER_PATH}/${triplet}-gcc"
    cd "${XBB_TESTS_FOLDER_PATH}/${triplet}-gcc"

    echo
    echo "pwd: $(pwd)"

    # -------------------------------------------------------------------------

    # -------------------------------------------------------------------------

    run_verbose cp -rv "${helper_folder_path}/tests/c-cpp" .
    chmod -R a+w c-cpp
    run_verbose cp -rv "${helper_folder_path}/tests/wine"/* c-cpp
    chmod -R a+w c-cpp

    run_verbose cp -rv "${helper_folder_path}/tests/fortran" .
    chmod -R a+w fortran

    # -------------------------------------------------------------------------

    # From https://wiki.winehq.org/Wine_User%27s_Guide#DLL_Overrides
    # DLLs usually get loaded in the following order:
    # - The directory the program was started from.
    # - The current directory.
    # - The Windows system directory.
    # - The Windows directory.
    # - The PATH variable directories.

    # Run tests in all cases.

    (
      # For libstdc++-6.dll & co.
      # The DLLs are available in the /lib folder.
      export WINEPATH="${test_bin_path}/../${XBB_CURRENT_TRIPLET}/lib;${WINEPATH:-}"
      echo "WINEPATH=${WINEPATH}"
      test_compiler_single "${test_bin_path}"
      test_compiler_single "${test_bin_path}" --gc
      test_compiler_single "${test_bin_path}" --lto
      test_compiler_single "${test_bin_path}" --gc --lto
    )

    (
      # For libwinpthread-1.dll. (This is a big pain).
      # The DLLs are available in the /lib folder.
      export WINEPATH="${test_bin_path}/../${XBB_CURRENT_TRIPLET}/lib;${WINEPATH:-}"
      echo "WINEPATH=${WINEPATH}"
      test_compiler_single "${test_bin_path}" --static-lib
      test_compiler_single "${test_bin_path}" --static-lib --gc
      test_compiler_single "${test_bin_path}" --static-lib --lto
      test_compiler_single "${test_bin_path}" --static-lib --gc --lto
    )

    (
      test_compiler_single "${test_bin_path}" --static
      test_compiler_single "${test_bin_path}" --static --gc
      test_compiler_single "${test_bin_path}" --static --lto
      test_compiler_single "${test_bin_path}" --static --gc --lto
    )

    # -------------------------------------------------------------------------
  )
}

# -----------------------------------------------------------------------------
