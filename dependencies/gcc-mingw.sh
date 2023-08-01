# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# The configurations generally follow the Linux Arch configurations, but
# also MSYS2 and HomeBrew were considered.

# The difference is the install location, which no longer uses `/usr`.

# https://gcc.gnu.org
# https://gcc.gnu.org/wiki/InstallingGCC

# The DLLs are moved to bin
# mv "$pkgdir"/usr/${_arch}/lib/*.dll "$pkgdir"/usr/${_arch}/bin/
# https://github.com/archlinux/svntogit-community/blob/packages/mingw-w64-gcc/trunk/PKGBUILD

# MSYS2 uses a lot of patches.
# https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-gcc/PKGBUILD

# arch_dir = "#{prefix}/toolchain-#{arch}"
# target = "#{arch}-w64-mingw32"
#
# binutils & gcc --prefix=#{arch_dir} --with-sysroot=#{arch_dir}
# mingw-headers --prefix=#{arch_dir}/#{target}
# mingw-libs --prefix=#{arch_dir}/#{target} --with-sysroot=#{arch_dir}/## https://github.com/Homebrew/homebrew-core/blob/master/Formula/mingw-w64.rb

# https://ftp.gnu.org/gnu/gcc/
# 2019-02-22, "8.3.0"
# 2019-05-03, "9.1.0"
# 2019-08-12, "9.2.0"
# 2019-11-14, "7.5.0" *
# 2020-03-04, "8.4.0"
# 2020-03-12, "9.3.0"
# 2021-04-08, "10.3.0"
# 2021-04-27, "11.1.0"
# 2021-05-14, "8.5.0" *
# 2021-07-28, "11.2.0"
# 2022-04-21, "11.3.0"
# 2022-05-06, "12.1.0"
# 2022-08-19, "12.2.0"
# 2023-05-08, "12.3.0"
# 2023-05-29, "11.4.0"
# 2023-04-26, "13.1.0"
# 2023-07-27, "13.2.0"

# -----------------------------------------------------------------------------

function gcc_mingw_build_dependencies()
{
  libiconv_build "${XBB_LIBICONV_VERSION}"

  # New zlib, used in most of the tools.
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
  # Still problematic, temporarily disabled.
  zstd_build "${XBB_ZSTD_VERSION}"
}

function gcc_mingw_build_all_triplets()
{
  for triplet in "${XBB_MINGW_TRIPLETS[@]}"
  do

    # Set XBB_TARGET_STRIP, _RANLIB & _OBJDUMP
    xbb_set_extra_target_env "${triplet}"

    binutils_build "${XBB_BINUTILS_VERSION}" --triplet="${triplet}" --program-prefix="${triplet}-"

    # Deploy the headers, they are needed by the compiler.
    mingw_build_headers --triplet="${triplet}"

    # Build only the compiler, without libraries.
    gcc_mingw_build_first "${XBB_GCC_VERSION}" --triplet="${triplet}"

    # Refers to mingw headers.
    mingw_build_widl --triplet="${triplet}"

    # Build some native tools.
    mingw_build_libmangle --triplet="${triplet}"
    mingw_build_gendef --triplet="${triplet}"

    (
      xbb_activate_installed_bin
      (
        # Fails if CC is defined to a native compiler.
        xbb_prepare_gcc_env "${triplet}-"

        mingw_build_crt --triplet="${triplet}"
        mingw_build_winpthreads --triplet="${triplet}"
      )

      # With the run-time available, build the C/C++ libraries and the rest.
      gcc_mingw_build_final --triplet="${triplet}"
    )

  done
}

# -----------------------------------------------------------------------------

# XBB_MINGW_GCC_PATCH_FILE_NAME
function gcc_mingw_build_first()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  export mingw_gcc_version="$1"
  shift

  local triplet="${XBB_TARGET_TRIPLET}" # "x86_64-w64-mingw32"
  local name_prefix

  while [ $# -gt 0 ]
  do
    case "$1" in
      --triplet=* )
        triplet=$(xbb_parse_option "$1")
        shift
        ;;

      * )
        echo "Unsupported argument $1 in ${FUNCNAME[0]}()"
        exit 1
        ;;
    esac
  done

  name_prefix="${triplet}-"

  # Number
  local mingw_gcc_version_major=$(xbb_get_version_major "${mingw_gcc_version}")

  local mingw_gcc_src_folder_name="gcc-${mingw_gcc_version}"

  local mingw_gcc_archive="${mingw_gcc_src_folder_name}.tar.xz"
  local mingw_gcc_url="https://ftp.gnu.org/gnu/gcc/gcc-${mingw_gcc_version}/${mingw_gcc_archive}"

  export mingw_gcc_folder_name="${name_prefix}gcc-${mingw_gcc_version}"

  local mingw_gcc_step1_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${name_prefix}gcc-first-${mingw_gcc_version}-installed"
  if [ ! -f "${mingw_gcc_step1_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${mingw_gcc_url}" "${mingw_gcc_archive}" \
      "${mingw_gcc_src_folder_name}" \
      "${XBB_MINGW_GCC_PATCH_FILE_NAME:-none}"

    mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${mingw_gcc_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${mingw_gcc_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${mingw_gcc_folder_name}"

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

      LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ "${XBB_HOST_PLATFORM}" == "linux" ]
      then
        if is_native || is_bootstrap
        then
          # Hack to avoid missing ZSTD_* symbols
          # /home/ilg/.local/xPacks/@xpack-dev-tools/gcc/12.2.0-2.1/.content/bin/../lib/gcc/x86_64-pc-linux-gnu/12.2.0/../../../../x86_64-pc-linux-gnu/bin/ld: lto-compress.o: in function `lto_end_compression(lto_compression_stream*)':
          # lto-compress.cc:(.text._Z19lto_end_compressionP22lto_compression_stream+0x33): undefined reference to `ZSTD_compressBound'

          # Testing -lzstd alone fails since it depends on -lpthread.
          LDFLAGS+=" -lpthread"
          # export LIBS="-lzstd -lpthread"
        fi
      fi

      xbb_adjust_ldflags_rpath

      export CFLAGS_FOR_TARGET="-g -ffunction-sections -fdata-sections -pipe -O2 -D__USE_MINGW_ACCESS -w"
      export CXXFLAGS_FOR_TARGET="-g -ffunction-sections -fdata-sections -pipe -O2 -D__USE_MINGW_ACCESS -w"

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      # HB: Create a mingw symlink, expected by GCC
      # ln_s "#{arch_dir}/#{target}", "#{arch_dir}/mingw"
      # Otherwise:
      # The directory that should contain system headers does not exist:
      #   /home/ilg/Work/xpack-dev-tools/mingw-w64-gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install/mingw/include
      # Makefile:3271: recipe for target 'stmp-fixinc' failed

      rm -rf "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/mingw"
      (
        run_verbose_develop cd "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}"
        run_verbose ln -sv "${triplet}" "mingw"
      )

      # rm -rf "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/${triplet}/mingw"
      # (
      #   mkdir -pv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/${triplet}/mingw"
      #   run_verbose_develop cd "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/${triplet}/mingw"
      #   run_verbose ln -sv "../include" "include"
      # )

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
          config_options+=("--with-sysroot=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}") # HB

          config_options+=("--libexecdir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib") # Arch /usr/lib

          config_options+=("--infodir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/info")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")
          config_options+=("--htmldir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/html")
          config_options+=("--pdfdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/pdf")

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

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${mingw_gcc_src_folder_name}" \
        "gcc-${mingw_gcc_version}"

    )

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${mingw_gcc_step1_stamp_file_path}"

  else
    echo "Component ${name_prefix}gcc first already installed"
  fi
}

function gcc_mingw_build_final()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local triplet="${XBB_TARGET_TRIPLET}" # "x86_64-w64-mingw32"
  local name_prefix

  while [ $# -gt 0 ]
  do
    case "$1" in
      --triplet=* )
        triplet=$(xbb_parse_option "$1")
        shift
        ;;

      * )
        echo "Unsupported argument $1 in ${FUNCNAME[0]}()"
        exit 1
        ;;
    esac
  done

  name_prefix="${triplet}-"

  local mingw_gcc_final_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${name_prefix}gcc-final-${mingw_gcc_version}-installed"
  if [ ! -f "${mingw_gcc_final_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${mingw_gcc_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${mingw_gcc_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${mingw_gcc_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

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
      if [ "${XBB_WITH_STRIP}" == "y" ]
      then
        run_verbose make install-strip
      else
        run_verbose make install
      fi

      (
        # The DLLs are expected to be in the /${triplet}/lib folder.
        # When building for Windows, the `x86_64-w64-mingw32/lib` folder
        # is not properly populated; manually copy the DLLs.
        if [ "${XBB_HOST_PLATFORM}" == "win32" ]
        then
          run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${mingw_gcc_folder_name}"
          run_verbose find "${triplet}" -name '*.dll' ! -iname 'liblto*' \
            -exec cp -v '{}' "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/${triplet}/lib" ';'
        fi

        run_verbose_develop cd "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}"
        run_verbose find . -name '*.dll'
      )

      # Remove weird files like x86_64-w64-mingw32-x86_64-w64-mingw32-c++.exe
      run_verbose rm -rf "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${triplet}-${triplet}-"*

    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${mingw_gcc_folder_name}/make-final-output-$(ndate).txt"

    (
      if [ "${XBB_WITH_STRIP}" == "y" ]
      then

        # Exception to the rule, it would be too complicated to express
        # as absolute paths.
        # For *-w64-mingw32-strip
        xbb_activate_installed_bin

        echo
        echo "Stripping ${name_prefix}gcc libraries..."

        run_verbose_develop cd "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}" # ! usr

        strip="$(which ${triplet}-strip)"
        ranlib="$(which ${triplet}-ranlib)"

        set +e
        find ${triplet} \
          -name '*.so' -type f \
          -print \
          -exec "${strip}" --strip-debug '{}' ';'
        find ${triplet} \
          -name '*.so.*'  \
          -type f \
          -print \
          -exec "${strip}" --strip-debug '{}' ';'
        # Note: without ranlib, windows builds failed.
        find ${triplet} lib/gcc/${triplet} \
          -name '*.a'  \
          -type f  \
          -print \
          -exec "${strip}" --strip-debug '{}' ';' \
          -exec "${ranlib}" '{}' ';'
        set -e

      else
        echo "Stripping ${name_prefix}gcc libraries skipped..."
      fi

      # The mingw link was created in gcc_first; no longer needed.
      rm -rf "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/mingw"

    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${mingw_gcc_folder_name}/strip-final-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${mingw_gcc_final_stamp_file_path}"

  else
    echo "Component ${name_prefix}gcc final already installed"
  fi

  tests_add "gcc_mingw_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin" "${triplet}"
}

function gcc_mingw_test()
{
  local test_bin_path="$1"
  local triplet="$2"

  xbb_set_extra_target_env "${triplet}"

  (
    CC="${test_bin_path}/${triplet}-gcc"
    CXX="${test_bin_path}/${triplet}-g++"
    F90="${test_bin_path}/${triplet}-gfortran"

    AR="${test_bin_path}/${triplet}-gcc-ar"
    NM="${test_bin_path}/${triplet}-gcc-nm"
    RANLIB="${test_bin_path}/${triplet}-gcc-ranlib"

    OBJDUMP="${test_bin_path}/${triplet}-objdump"

    GCOV="${test_bin_path}/${triplet}-gcov"
    GCOV_DUMP="${test_bin_path}/${triplet}-gcov-dump"
    GCOV_TOOL="${test_bin_path}/${triplet}-gcov-tool"

    DLLTOOL="${test_bin_path}/${triplet}-dlltool"
    GENDEF="${test_bin_path}/${triplet}-gendef"
    WIDL="${test_bin_path}/${triplet}-widl"

    xbb_show_env_develop

    if [ "${XBB_BUILD_PLATFORM}" != "win32" ]
    then
      echo
      echo "Checking the ${triplet}-gcc shared libraries..."

      # When running on Windows, the executable may not be directly available,
      # it is behind a script or a .cmd shim.
      show_host_libs "${CC}"
      show_host_libs "${CXX}"
      if [ -f "${F90}" -o -f "${F90}${XBB_HOST_DOT_EXE}" ]
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
    fi

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
    run_verbose_develop cd "${XBB_TESTS_FOLDER_PATH}/${triplet}-gcc"

    echo
    echo "pwd: $(pwd)"

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

    local bits
    if [ "${triplet}" == "x86_64-w64-mingw32" ]
    then
      bits="--64"
    elif [ "${triplet}" == "i686-w64-mingw32" ]
    then
      bits="--32"
    else
      echo "Unsupported triplet ${triplet}"
      exit 1
    fi

    local gcc_version=$(run_host_app "${CC}" -dumpversion)
    echo "GCC: ${gcc_version}"

    # Skip tests known to fail.

    if [[ "${gcc_version}" =~ 12[.]3[.]0 ]]
    then

      # /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install/lib/gcc/x86_64-w64-mingw32/12.3.0/../../../../x86_64-w64-mingw32/bin/ld: hello-weak.c.o:hello-weak.c:(.text+0x15): undefined reference to `world'
      # collect2: error: ld returned 1 exit status

      export XBB_SKIP_TEST_HELLO_WEAK_C="y"
      export XBB_SKIP_TEST_HELLO_WEAK_CPP="y"

      # [wine64 ./lto-throwcatch-main.exe]
      # wine: Unhandled page fault on execute access to 0000000122B1157C at address 0000000122B1157C (thread 0394), starting debugger...
      # Unhandled exception: page fault on execute access to 0x0000000122b1157c in 64-bit code (0x00000122b1157c).

      export XBB_SKIP_RUN_TEST_LTO_THROWCATCH_MAIN_64="y"
      export XBB_SKIP_RUN_TEST_GC_LTO_THROWCATCH_MAIN_64="y"
      export XBB_SKIP_RUN_TEST_STATIC_LIB_LTO_THROWCATCH_MAIN_64="y"
      export XBB_SKIP_RUN_TEST_STATIC_LIB_GC_LTO_THROWCATCH_MAIN_64="y"

      # [wine ./static-lib-throwcatch-main.exe]
      # not throwing
      # throwing FirstException
      # terminate called after throwing an instance of 'FirstException'
      #   what():  first

      export XBB_SKIP_RUN_TEST_STATIC_LIB_THROWCATCH_MAIN_32="y"
      export XBB_SKIP_RUN_TEST_STATIC_LIB_GC_THROWCATCH_MAIN_32="y"
      export XBB_SKIP_RUN_TEST_STATIC_LIB_LTO_THROWCATCH_MAIN_32="y"
      export XBB_SKIP_RUN_TEST_STATIC_LIB_GC_LTO_THROWCATCH_MAIN_32="y"

      # [wine64 ./lto-autoimport-main.exe]
      # Mingw-w64 runtime failure:
      # 32 bit pseudo relocation at 000000014000152A out of range, targeting 000000028846135C, yielding the value 000000014845FE2E.

      export XBB_SKIP_RUN_TEST_LTO_AUTOIMPORT_MAIN_64="y"
      export XBB_SKIP_RUN_TEST_GC_LTO_AUTOIMPORT_MAIN_64="y"
      export XBB_SKIP_RUN_TEST_STATIC_LIB_LTO_AUTOIMPORT_MAIN_64="y"
      export XBB_SKIP_RUN_TEST_STATIC_LIB_GC_LTO_AUTOIMPORT_MAIN_64="y"

    fi

    # Run tests in all cases.
    (
      # For libstdc++-6.dll & co.
      # The DLLs are available in the /lib folder.
      if [ "${XBB_BUILD_PLATFORM}" == "win32" ]
      then
        cxx_lib_path=$(dirname $(${CXX} -print-file-name=libstdc++-6.dll | sed -e 's|:||' | sed -e 's|^|/|'))
        export PATH="${cxx_lib_path}:${PATH:-}"
        echo "PATH=${PATH}"
      else
        export WINEPATH="${test_bin_path}/../${XBB_CURRENT_TRIPLET}/lib;${WINEPATH:-}"
        echo "WINEPATH=${WINEPATH}"
      fi

      compiler-tests-single "${test_bin_path}" ${bits}
      compiler-tests-single "${test_bin_path}" --gc ${bits}
      compiler-tests-single "${test_bin_path}" --lto ${bits}
      compiler-tests-single "${test_bin_path}" --gc --lto ${bits}
    )

    (
      # For libwinpthread-1.dll. (This is a big pain).
      # The DLLs are available in the /lib folder.
      if [ "${XBB_BUILD_PLATFORM}" == "win32" ]
      then
        cxx_lib_path=$(dirname $(${CXX} -print-file-name=libstdc++-6.dll | sed -e 's|:||' | sed -e 's|^|/|'))
        export PATH="${cxx_lib_path}:${PATH:-}"
        echo "PATH=${PATH}"
      else
        export WINEPATH="${test_bin_path}/../${XBB_CURRENT_TRIPLET}/lib;${WINEPATH:-}"
        echo "WINEPATH=${WINEPATH}"
      fi

      compiler-tests-single "${test_bin_path}" --static-lib ${bits}
      compiler-tests-single "${test_bin_path}" --static-lib --gc ${bits}
      compiler-tests-single "${test_bin_path}" --static-lib --lto ${bits}
      compiler-tests-single "${test_bin_path}" --static-lib --gc --lto ${bits}
    )

    (
      compiler-tests-single "${test_bin_path}" --static ${bits}
      compiler-tests-single "${test_bin_path}" --static --gc ${bits}
      compiler-tests-single "${test_bin_path}" --static --lto ${bits}
      compiler-tests-single "${test_bin_path}" --static --gc --lto ${bits}
    )

    # -------------------------------------------------------------------------
  )
}

# -----------------------------------------------------------------------------
