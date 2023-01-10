# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# https://gcc.gnu.org
# https://ftp.gnu.org/gnu/gcc/
# https://gcc.gnu.org/wiki/InstallingGCC
# https://gcc.gnu.org/install
# https://gcc.gnu.org/install/configure.html

# https://github.com/archlinux/svntogit-packages/blob/packages/gcc/trunk/PKGBUILD
# https://github.com/archlinux/svntogit-community/blob/packages/gcc10/trunk/PKGBUILD
# https://github.com/archlinux/svntogit-community/blob/packages/mingw-w64-gcc/trunk/PKGBUILD

# https://archlinuxarm.org/packages/aarch64/gcc/files/PKGBUILD
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gcc-git
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/gcc.rb
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/gcc@8.rb

# Mingw on Arch
# https://github.com/archlinux/svntogit-community/blob/packages/mingw-w64-gcc/trunk/PKGBUILD
# https://github.com/archlinux/svntogit-community/blob/packages/mingw-w64-headers/trunk/PKGBUILD
# https://github.com/archlinux/svntogit-community/blob/packages/mingw-w64-crt/trunk/PKGBUILD
#
# Mingw on Msys2
# https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-gcc/PKGBUILD
# https://github.com/msys2/MSYS2-packages/blob/master/gcc/PKGBUILD


# 2018-05-02, "8.1.0"
# 2018-07-26, "8.2.0"
# 2018-10-30, "6.5.0" *
# 2018-12-06, "7.4.0"
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

# Returns GCC_SRC_FOLDER_NAME.
function gcc_download()
{
  local gcc_version="$1"

  # Branch from the Darwin maintainer of GCC with Apple Silicon support,
  # located at https://github.com/iains/gcc-darwin-arm64 and
  # backported with his help to gcc-11 branch.

  # The repo used by the HomeBrew:
  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/gcc.rb
  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/gcc@12.rb
  # https://github.com/fxcoudert/gcc/tags

  export GCC_SRC_FOLDER_NAME="gcc-${gcc_version}"

  local gcc_archive="${GCC_SRC_FOLDER_NAME}.tar.xz"
  local gcc_url="https://ftp.gnu.org/gnu/gcc/gcc-${gcc_version}/${gcc_archive}"
  local gcc_patch_file_name="gcc-${gcc_version}.git.patch"


  if [ "${XBB_HOST_PLATFORM}" == "darwin" -a "${gcc_version}" == "12.2.0" ]
  then
    # https://raw.githubusercontent.com/Homebrew/formula-patches/1d184289/gcc/gcc-12.2.0-arm.diff
    local gcc_patch_file_name="gcc-${gcc_version}-darwin.git.patch"
  elif [ "${XBB_HOST_PLATFORM}" == "darwin" -a "${XBB_HOST_ARCH}" == "arm64" -a "${gcc_version}" == "12.1.0" ]
  then
    # https://raw.githubusercontent.com/Homebrew/formula-patches/d61235ed/gcc/gcc-12.1.0-arm.diff
    local gcc_patch_file_name="gcc-${gcc_version}-darwin-arm.git.patch"
  elif [ "${XBB_HOST_PLATFORM}" == "darwin" -a "${XBB_HOST_ARCH}" == "arm64" -a "${gcc_version}" == "11.3.0" ]
  then
    # https://raw.githubusercontent.com/Homebrew/formula-patches/22dec3fc/gcc/gcc-11.3.0-arm.diff
    local gcc_patch_file_name="gcc-${gcc_version}-darwin-arm.git.patch"
  elif [ "${XBB_HOST_PLATFORM}" == "darwin" -a "${XBB_HOST_ARCH}" == "arm64" -a "${gcc_version}" == "11.2.0" ]
  then
    # https://github.com/fxcoudert/gcc/archive/refs/tags/gcc-11.2.0-arm-20211201.tar.gz
    export GCC_SRC_FOLDER_NAME="gcc-gcc-11.2.0-arm-20211201"
    local gcc_archive="gcc-11.2.0-arm-20211201.tar.gz"
    local gcc_url="https://github.com/fxcoudert/gcc/archive/refs/tags/${gcc_archive}"
    local gcc_patch_file_name=""
  elif [ "${XBB_HOST_PLATFORM}" == "darwin" -a "${XBB_HOST_ARCH}" == "arm64" -a "${gcc_version}" == "11.1.0" ]
  then
    # https://github.com/fxcoudert/gcc/archive/refs/tags/gcc-11.1.0-arm-20210504.tar.gz
    export GCC_SRC_FOLDER_NAME="gcc-gcc-11.1.0-arm-20210504"
    local gcc_archive="gcc-11.1.0-arm-20210504.tar.gz"
    local gcc_url="https://github.com/fxcoudert/gcc/archive/refs/tags/${gcc_archive}"
    local gcc_patch_file_name=""
  fi

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}"

  local gcc_download_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${GCC_SRC_FOLDER_NAME}-downloaded"
  if [ ! -f "${gcc_download_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${gcc_url}" "${gcc_archive}" \
      "${GCC_SRC_FOLDER_NAME}" "${gcc_patch_file_name}"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${gcc_download_stamp_file_path}"
  fi
}

# -----------------------------------------------------------------------------

# Return GCC_FOLDER_NAME
function gcc_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local gcc_version="$1"
  shift

  local disable_shared="n"

  while [ $# -gt 0 ]
  do
    case "$1" in
      --disable-shared )
        disable_shared="y"
        shift
        ;;

      * )
        echo "Unsupported argument $1 in ${FUNCNAME[0]}()"
        exit 1
        ;;
    esac
  done

  local gcc_version_major=$(echo ${gcc_version} | sed -e 's|\([0-9][0-9]*\)[.].*|\1|')

  export GCC_FOLDER_NAME="${GCC_SRC_FOLDER_NAME}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}"

  local gcc_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${GCC_FOLDER_NAME}-installed"
  if [ ! -f "${gcc_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    (
      mkdir -p "${XBB_BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"
      cd "${XBB_BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"

      # To access the newly compiled libraries.
      # On Arm it still needs --with-gmp
      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        # --enable-mingw-wildcard already does this, enabling it results in:
        # multiple definition of `_dowildcard'
        # Used to enable wildcard; inspired by arm-none-eabi-gcc.
        # local crt_clob_file_path="$(${CC} --print-file-name=CRT_glob.o)"
        # LDFLAGS+=" -Wl,${crt_clob_file_path}"

        # Hack to prevent "too many sections", "File too big" etc in insn-emit.c
        CXXFLAGS=$(echo ${CXXFLAGS} | sed -e 's|-ffunction-sections -fdata-sections||')
        CXXFLAGS+=" -D__USE_MINGW_ACCESS"
      elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
      then
        # HomeBrew mentiones this:
        # GCC will suffer build errors if forced to use a particular linker.
        unset LD

        export LDFLAGS_FOR_TARGET="${LDFLAGS}"
        export LDFLAGS_FOR_BUILD="${LDFLAGS}"
        export BOOT_LDFLAGS="${LDFLAGS}"
      elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
      then
        # if is_native || is_bootstrap
        # then
        #   # Hack to avoid missing ZSTD_* symbols
        #   # /home/ilg/.local/xPacks/@xpack-dev-tools/gcc/12.2.0-2.1/.content/bin/../lib/gcc/x86_64-pc-linux-gnu/12.2.0/../../../../x86_64-pc-linux-gnu/bin/ld: lto-compress.o: in function `lto_end_compression(lto_compression_stream*)':
        #   # lto-compress.cc:(.text._Z19lto_end_compressionP22lto_compression_stream+0x33): undefined reference to `ZSTD_compressBound'

        #   # Testing -lzstd alone fails since it depends on -lpthread.
        #   LDFLAGS+=" -lpthread"
        # fi

        LDFLAGS_FOR_TARGET="${LDFLAGS}"
        LDFLAGS_FOR_BUILD="${LDFLAGS}"
        BOOT_LDFLAGS="${LDFLAGS}"

        export LDFLAGS_FOR_TARGET
        export LDFLAGS_FOR_BUILD
        export BOOT_LDFLAGS
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
          echo "Running gcc configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}/configure" --help
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}/gcc/configure" --help

            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}/libgcc/configure" --help
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}/libstdc++-v3/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")
          config_options+=("--program-suffix=")

          config_options+=("--infodir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/info")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")
          config_options+=("--htmldir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/html")
          config_options+=("--pdfdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/pdf")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          config_options+=("--with-pkgversion=${XBB_GCC_BRANDING}")

          #  build crashes LTO on Apple Silicon.
          # config_options+=("--with-build-config=-lto") # Arch

          # config_options+=("--with-gcc-major-version-only") # HB

          config_options+=("--with-dwarf2")
          config_options+=("--with-diagnostics-color=auto")

          config_options+=("--with-gmp=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--with-isl=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--with-libiconv-prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--with-mpc=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--with-mpfr=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          config_options+=("--with-zstd=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          # Use the zlib compiled from sources.
          config_options+=("--with-system-zlib") # HB, Arch
          config_options+=("--without-cuda-driver")

          config_options+=("--enable-languages=c,c++,objc,obj-c++,lto,fortran") # HB
          config_options+=("--enable-objc-gc=auto")

          # Intel specific.
          # config_options+=("--enable-cet=auto")
          config_options+=("--enable-checking=release") # HB, Arch

          config_options+=("--enable-lto") # Arch
          config_options+=("--enable-plugin") # Arch

          config_options+=("--enable-__cxa_atexit") # Arch
          config_options+=("--enable-cet=auto") # Arch

          config_options+=("--enable-threads=posix")

          # It fails on macOS master with:
          # libstdc++-v3/include/bits/cow_string.h:630:9: error: no matching function for call to 'std::basic_string<wchar_t>::_Alloc_hider::_Alloc_hider(std::basic_string<wchar_t>::_Rep*)'
          # config_options+=("--enable-fully-dynamic-string")
          config_options+=("--enable-cloog-backend=isl")

          config_options+=("--enable-default-pie") # Arch

          # The GNU Offloading and Multi Processing Runtime Library
          config_options+=("--enable-libgomp")

          # config_options+=("--disable-libssp") # Arch
          config_options+=("--enable-libssp")

          config_options+=("--enable-default-ssp") # Arch
          config_options+=("--enable-libatomic")
          config_options+=("--enable-graphite")
          config_options+=("--enable-libquadmath")
          config_options+=("--enable-libquadmath-support")

          config_options+=("--enable-libstdcxx")
          config_options+=("--enable-libstdcxx-backtrace") # Arch
          config_options+=("--enable-libstdcxx-time=yes")
          config_options+=("--enable-libstdcxx-visibility")
          config_options+=("--enable-libstdcxx-threads")

          config_options+=("--enable-static")

          config_options+=("--with-default-libstdcxx-abi=new")

          config_options+=("--enable-pie-tools")

          config_options+=("--enable-gold")

          # config_options+=("--enable-version-specific-runtime-libs")

          # TODO?
          # config_options+=("--enable-nls")
          config_options+=("--disable-nls") # HB

          config_options+=("--disable-libstdcxx-debug")
          config_options+=("--disable-libstdcxx-pch") # Arch

          config_options+=("--disable-install-libiberty")

          # It is not yet clear why, but Arch, RH use it.
          # config_options+=("--disable-libunwind-exceptions")

          config_options+=("--disable-werror") # Arch

          if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then

            # DO NOT DISABLE, otherwise 'ld: library not found for -lgcc_ext.10.5'.
            # make[2]: *** No rule to make target `emutls_s.o', needed by `libemutls_w.a'.  Stop.
            config_options+=("--enable-shared")
            # config_options+=("--disable-shared")

            # This distribution expects the SDK to be installed
            # with the Command Line Tools, which have a fixed location,
            # while Xcode may vary from version to version.
            config_options+=("--with-sysroot=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk") # HB

            # From HomeBrew, but not present on 11.x
            # config_options+=("--with-native-system-header-dir=/usr/include")

            #  fails with Undefined symbols: "_libiconv_open", etc
            if true # [ "${XBB_IS_DEVELOP}" == "y" ]
            then
              # To speed things up during development.
              config_options+=("--disable-bootstrap")
            else
              config_options+=("--enable-bootstrap")
            fi

            config_options+=("--disable-multilib")

          elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
          then

            # Shared libraries remain problematic when refered from generated
            # programs, and require setting the executable rpath to work.
            config_options+=("--enable-shared")

            #  fails on aarch64 with
            # gcc/lto-compress.cc:135: undefined reference to `ZSTD_compressBound'
            if [ "${XBB_IS_DEVELOP}" == "y" ]
            then
              config_options+=("--disable-bootstrap")
            else
              config_options+=("--enable-bootstrap")
            fi

            # The Linux build also uses:
            # --with-linker-hash-style=gnu
            # --enable-libmpx (fails on arm)
            # --enable-clocale=gnu
            # --enable-install-libiberty

            # Ubuntu also used:
            # --enable-libstdcxx-debug
            # --enable-libstdcxx-time=yes (links librt)
            # --with-default-libstdcxx-abi=new (default)

            if [ "${XBB_HOST_ARCH}" == "x64" ]
            then
              config_options+=("--enable-multilib") # Arch

              # From Ubuntu 18.04.
              config_options+=("--enable-multiarch")
              config_options+=("--with-arch-32=i686")
              config_options+=("--with-abi=m64")
              # patchelf gets confused by x32 shared libraries.
              # config_options+=("--with-multilib-list=m32,m64,mx32")
              config_options+=("--with-multilib-list=m32,m64")

              config_options+=("--with-arch=x86-64")
              config_options+=("--with-tune=generic")
              # Support for Intel Memory Protection Extensions (MPX).
              config_options+=("--enable-libmpx")
            elif [ "${XBB_HOST_ARCH}" == "x32" -o "${XBB_HOST_ARCH}" == "ia32" ]
            then
              config_options+=("--disable-multilib")

              config_options+=("--with-arch=i686")
              config_options+=("--with-arch-32=i686")
              config_options+=("--with-tune=generic")
              config_options+=("--enable-libmpx")
            elif [ "${XBB_HOST_ARCH}" == "arm64" ]
            then
              config_options+=("--disable-multilib")

              config_options+=("--with-arch=armv8-a")
              config_options+=("--enable-fix-cortex-a53-835769")
              config_options+=("--enable-fix-cortex-a53-843419")
            elif [ "${XBB_HOST_ARCH}" == "arm" ]
            then
              config_options+=("--disable-multilib")

              config_options+=("--with-arch=armv7-a")
              config_options+=("--with-float=hard")
              config_options+=("--with-fpu=vfpv3-d16")
            else
              echo "Unsupported ${XBB_HOST_ARCH} in ${FUNCNAME[0]}()"
              exit 1
            fi

            config_options+=("--with-pic")

            config_options+=("--with-stabs")
            config_options+=("--with-gnu-as")
            config_options+=("--with-gnu-ld")

            # Used by Arch
            # config_options+=("--disable-libunwind-exceptions")
            # config_options+=("--disable-libssp")
            config_options+=("--with-linker-hash-style=gnu") # Arch
            config_options+=("--enable-clocale=gnu") # Arch

            # Tells GCC to use the gnu_unique_object relocation for C++
            # template static data members and inline function local statics.
            config_options+=("--enable-gnu-unique-object") # Arch
            config_options+=("--enable-gnu-indirect-function") # Arch
            config_options+=("--enable-linker-build-id") # Arch

            # Not needed.
            # config_options+=("--with-sysroot=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")
            # config_options+=("--with-native-system-header-dir=/usr/include")

          elif [ "${XBB_HOST_PLATFORM}" == "win32" ]
          then

            # With shared 32-bit, the simple-exception and other
            # tests with exceptions, fail.
            # Static libwinpthread also requires to disable this.
            # undefined reference to `__imp_pthread_mutex_lock'
            if [ "${disable_shared}" == "y" ]
            then
              config_options+=("--disable-shared")
            else
              config_options+=("--enable-shared") # Arch
            fi

            if [ "${XBB_HOST_ARCH}" == "x64" ]
            then
              config_options+=("--with-arch=x86-64")
            elif [ "${XBB_HOST_ARCH}" == "x32" -o "${XBB_HOST_ARCH}" == "ia32" ]
            then
              config_options+=("--with-arch=i686")

              # https://stackoverflow.com/questions/15670169/what-is-difference-between-sjlj-vs-dwarf-vs-seh
              # The defaults are sjlj for 32-bit and seh for 64-bit,
              # So better disable SJLJ explicitly.
              config_options+=("--disable-sjlj-exceptions")
            else
              echo "Unsupported XBB_HOST_ARCH=${XBB_HOST_ARCH} in ${FUNCNAME[0]}()"
              exit 1
            fi

            # Cross builds have their own explicit .
            config_options+=("--disable-bootstrap")

            config_options+=("--enable-mingw-wildcard")

            # Tells GCC to use the gnu_unique_object relocation for C++
            # template static data members and inline function local statics.
            config_options+=("--enable-gnu-unique-object")
            config_options+=("--enable-gnu-indirect-function")
            config_options+=("--enable-linker-build-id")

            config_options+=("--disable-multilib")

            # Inspired from mingw-w64; apart from --with-sysroot.
            config_options+=("--with-native-system-header-dir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/include")

            # Arch also uses --disable-dw2-exceptions
            # config_options+=("--disable-dw2-exceptions")

            if [ ${XBB_MINGW_VERSION_MAJOR} -ge 7 -a ${gcc_version_major} -ge 9 ]
            then
              # Requires at least GCC 9 & mingw 7.
              config_options+=("--enable-libstdcxx-filesystem-ts=yes")
            fi

            # Fails!
            # config_options+=("--enable-default-pie")

            # Disable look up installations paths in the registry.
            config_options+=("--disable-win32-registry")
            # Turn off symbol versioning in the shared library
            config_options+=("--disable-symvers")

            config_options+=("--disable-libitm")
            config_options+=("--with-tune=generic")

            config_options+=("--with-stabs")
            config_options+=("--with-gnu-as")
            config_options+=("--with-gnu-ld")

            # config_options+=("--disable-libssp")
            # msys2: --disable-libssp should suffice in GCC 8
            # export gcc_cv_libc_provides_ssp=yes
            # libssp: conflicts with builtin SSP

            # so libgomp DLL gets built despide static libdl
            # export lt_cv_deplibs_check_method='pass_all'

          else
            echo "Unsupported XBB_HOST_PLATFORM=${XBB_HOST_PLATFORM} in ${FUNCNAME[0]}()"
            exit 1
          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}/configure" \
            ${config_options[@]}

          if [ "${XBB_HOST_PLATFORM}" == "linux" ]
          then
            run_verbose sed -i.bak \
              -e "s|^\(POSTSTAGE1_LDFLAGS = .*\)$|\1 -Wl,-rpath,${LD_LIBRARY_PATH}|" \
              "Makefile"
          fi

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/config-log-$(ndate).txt"

        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running gcc make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        run_verbose make install-strip

        if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
        then
          echo
          echo "Removing unnecessary files..."

          rm -rfv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/gcc-ar"
          rm -rfv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/gcc-nm"
          rm -rfv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/gcc-ranlib"

          run_verbose rm -rfv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${XBB_TARGET_TRIPLET}"-*

        elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
        then
          echo
          echo "Removing unnecessary files..."

          run_verbose rm -rfv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${XBB_TARGET_TRIPLET}"-*
        elif [ "${XBB_HOST_PLATFORM}" == "win32" ]
        then
          echo
          echo "Removing unnecessary files..."

          run_verbose rm -rfv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${XBB_TARGET_TRIPLET}"-*.exe

          # These files are necessary:
          # gcc.exe: fatal error: cannot execute 'as': CreateProcess: No such file or directory
          # run_verbose rm -rfv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/${XBB_TARGET_TRIPLET}/bin"
        fi

        show_host_libs "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/gcc"
        show_host_libs "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/g++"

        if [ "${XBB_HOST_PLATFORM}" != "win32" ]
        then
          show_host_libs "$(${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/gcc --print-prog-name=cc1)"
          show_host_libs "$(${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/gcc --print-prog-name=cc1plus)"
          show_host_libs "$(${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/gcc --print-prog-name=collect2)"
          show_host_libs "$(${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/gcc --print-prog-name=lto1)"
          show_host_libs "$(${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/gcc --print-prog-name=lto-wrapper)"
        fi

        if [ "${XBB_HOST_PLATFORM}" == "linux" ]
        then
          show_host_libs "$(${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/gcc --print-file-name=libstdc++.so)"
        elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
        then
          show_host_libs "$(${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/gcc --print-file-name=libstdc++.dylib)"
        elif [ "${XBB_HOST_PLATFORM}" == "win32" ]
        then
          (
            cd "${XBB_BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"
            run_verbose find "${XBB_TARGET_TRIPLET}" -name '*.dll' ! -iname 'liblto*' \
              -exec cp -v '{}' "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib" ';'

            cd "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}"
            run_verbose find . -name '*.dll'
          )
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/make-output-$(ndate).txt"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${gcc_stamp_file_path}"

  else
    echo "Component gcc already installed"
  fi

  tests_add "gcc_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

# Deprecated.
# Currently not used, work done by gcc_build().
function _gcc_build_libs()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local gcc_libs_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${GCC_FOLDER_NAME}-libs-installed"
  if [ ! -f "${gcc_libs_stamp_file_path}" ]
  then
  (
    mkdir -p "${XBB_BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"
    cd "${XBB_BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"

    CPPFLAGS="${XBB_CPPFLAGS}"
    CFLAGS="${XBB_CFLAGS_NO_W}"
    CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

    LDFLAGS="${XBB_LDFLAGS_APP} -Wl,-rpath,${XBB_FOLDER_PATH}/lib"

    export CPPFLAGS
    export CFLAGS
    export CXXFLAGS
    export LDFLAGS

    (
      xbb_show_env_develop

      echo
      echo "Running gcc-libs make..."

      run_verbose make -j ${XBB_JOBS} all-target-libgcc
      run_verbose make install-strip-target-libgcc

    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/make-libs-output-$(ndate).txt"
  )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${gcc_libs_stamp_file_path}"
  else
    echo "Component gcc-libs already installed"
  fi
}

# Deprecated.
# Currently not used, work done by gcc_build().
function _gcc_build_final()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local gcc_final_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${GCC_FOLDER_NAME}-final-installed"
  if [ ! -f "${gcc_final_stamp_file_path}" ]
  then
    (
      mkdir -p "${XBB_BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"
      cd "${XBB_BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP} -Wl,-rpath,${XBB_FOLDER_PATH}/lib"

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      (
        xbb_show_env_develop

        echo
        echo "Running gcc-final make..."

        run_verbose make -j ${XBB_JOBS}
        run_verbose make install-strip

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/make-final-output-$(ndate).txt"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${gcc_final_stamp_file_path}"
  else
    echo "Component gcc-final already installed"
  fi

  tests_add "gcc_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}


function gcc_test()
{
  local test_bin_path="$1"

  (
    run_verbose ls -l "${test_bin_path}"

    CC="${test_bin_path}/gcc"
    CXX="${test_bin_path}/g++"
    F90="${test_bin_path}/gfortran"

    if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
    then
      AR="$(which ar)"
      NM="$(which nm)"
      RANLIB="$(which ranlib)"
    else
      AR="${test_bin_path}/gcc-ar"
      NM="${test_bin_path}/gcc-nm"
      RANLIB="${test_bin_path}/gcc-ranlib"

      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        WIDL="${test_bin_path}/widl"
      fi
    fi

    echo
    echo "Checking the gcc shared libraries..."

    show_host_libs "${CC}"
    show_host_libs "${CXX}"
    if [ -f "${F90}" ]
    then
      show_host_libs "${F90}"
    fi

    if [ "${XBB_HOST_PLATFORM}" != "win32" ]
    then
      show_host_libs "$(${CC} --print-prog-name=cc1)"
      show_host_libs "$(${CC} --print-prog-name=cc1plus)"
      show_host_libs "$(${CC} --print-prog-name=collect2)"
      show_host_libs "$(${CC} --print-prog-name=lto1)"
      show_host_libs "$(${CC} --print-prog-name=lto-wrapper)"
    fi

    if [ "${XBB_HOST_PLATFORM}" == "linux" ]
    then
      show_host_libs "$(${CC} --print-file-name=libgcc_s.so.1)"
      show_host_libs "$(${CC} --print-file-name=libstdc++.so.6)"
    elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
    then
      local libgcc_path="$(${CC} --print-file-name=libgcc_s.1.dylib)"
      if [ "${libgcc_path}" != "libgcc_s.1.dylib" ]
      then
        show_host_libs "$(${CC} --print-file-name=libgcc_s.1.dylib)"
      fi
      show_host_libs "$(${CC} --print-file-name=libstdc++.dylib)"
    fi

    echo
    echo "Testing if the gcc binaries start properly..."

    run_host_app_verbose "${CC}" --version
    run_host_app_verbose "${CXX}" --version
    if [ -f "${F90}" ]
    then
      run_host_app_verbose "${F90}" --version
    fi

    if [ "${XBB_HOST_PLATFORM}" == "linux" ]
    then
      # On Darwin they refer to existing Darwin tools
      # which do not support --version
      # TODO: On Windows: gcc-ar.exe: Cannot find binary 'ar'
      run_host_app_verbose "${AR}" --version
      run_host_app_verbose "${NM}" --version
      run_host_app_verbose "${RANLIB}" --version
    fi

    run_host_app_verbose "${test_bin_path}/gcov" --version
    run_host_app_verbose "${test_bin_path}/gcov-dump" --version
    run_host_app_verbose "${test_bin_path}/gcov-tool" --version

    echo
    echo "Showing the gcc configurations..."

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
    run_host_app_verbose "${CXX}" -print-prog-name=cc1plus

    echo
    echo "Testing if gcc compiles simple programs..."

    rm -rf "${XBB_TESTS_FOLDER_PATH}/gcc"
    mkdir -pv "${XBB_TESTS_FOLDER_PATH}/gcc"
    cd "${XBB_TESTS_FOLDER_PATH}/gcc"

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

    xbb_show_env_develop

    run_verbose uname
    if [ "${XBB_HOST_PLATFORM}" != "darwin" ]
    then
      run_verbose uname -o
    fi

    # -------------------------------------------------------------------------

    if [ "${XBB_HOST_PLATFORM}" == "win32" ]
    then
      (
        if [ "${XBB_BUILD_PLATFORM}" == "win32" ]
        then
          cxx_lib_path=$(dirname $(${CXX} -print-file-name=libstdc++-6.dll | sed -e 's|:||' | sed -e 's|^|/|'))
          export PATH="${cxx_lib_path}:${PATH:-}"
          echo "PATH=${PATH}"
        else
          export WINEPATH="${test_bin_path}/../lib;${WINEPATH:-}"
          echo "WINEPATH=${WINEPATH}"
        fi

        compiler-tests-single "${test_bin_path}"
        compiler-tests-single "${test_bin_path}" --gc
        compiler-tests-single "${test_bin_path}" --lto
        compiler-tests-single "${test_bin_path}" --gc --lto
      )
      (
        if [ "${XBB_BUILD_PLATFORM}" == "win32" ]
        then
          cxx_lib_path=$(dirname $(${CXX} -print-file-name=libstdc++-6.dll | sed -e 's|:||' | sed -e 's|^|/|'))
          export PATH="${cxx_lib_path}:${PATH:-}"
          echo "PATH=${PATH}"
        else
          export WINEPATH="${test_bin_path}/../lib;${WINEPATH:-}"
          echo "WINEPATH=${WINEPATH}"
        fi

        compiler-tests-single "${test_bin_path}" --static-lib
        compiler-tests-single "${test_bin_path}" --static-lib --gc
        compiler-tests-single "${test_bin_path}" --static-lib --lto
        compiler-tests-single "${test_bin_path}" --static-lib --gc --lto
      )
      (
        compiler-tests-single "${test_bin_path}" --static
        compiler-tests-single "${test_bin_path}" --static --gc
        compiler-tests-single "${test_bin_path}" --static --lto
        compiler-tests-single "${test_bin_path}" --static --gc --lto
      )
    elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
    then
      if [ "${XBB_HOST_ARCH}" == "x64" ]
      then
        (
          export LD_LIBRARY_PATH="$(xbb_get_libs_path -m64)"
          echo
          echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"

          compiler-tests-single "${test_bin_path}" --64
          compiler-tests-single "${test_bin_path}" --64 --gc
          compiler-tests-single "${test_bin_path}" --64 --lto
          compiler-tests-single "${test_bin_path}" --64 --gc --lto
        )
        if [ "${XBB_SKIP_32_BIT_TESTS:-""}" == "y" ]
        then
          echo
          echo "Skipping -m32 tests..."
        else
          (
            export LD_LIBRARY_PATH="$(xbb_get_libs_path -m32)"
            echo
            echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"

            compiler-tests-single "${test_bin_path}" --32
            compiler-tests-single "${test_bin_path}" --32 --gc
            compiler-tests-single "${test_bin_path}" --32 --lto
            compiler-tests-single "${test_bin_path}" --32 --gc --lto
          )
        fi
      else
        (
          export LD_LIBRARY_PATH="$(xbb_get_libs_path)"
          echo
          echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"

          compiler-tests-single "${test_bin_path}"
          compiler-tests-single "${test_bin_path}" --gc
          compiler-tests-single "${test_bin_path}" --lto
          compiler-tests-single "${test_bin_path}" --gc --lto
        )
      fi

      local distro=$(lsb_release -is)
      if [[ ${distro} == CentOS ]] || [[ ${distro} == RedHat* ]] || [[ ${distro} == Fedora ]]
      then
        # RedHat has no static libstdc++.
        echo
        echo "Skipping all --static-lib on ${distro}..."
      else
        if [ "${XBB_HOST_ARCH}" == "x64" ]
        then
          (
            # Mainly for libgfortran.so.
            export LD_LIBRARY_PATH="$(xbb_get_libs_path -m64)"
            echo
            echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"

            compiler-tests-single "${test_bin_path}" --64 --static-lib
            compiler-tests-single "${test_bin_path}" --64 --static-lib --gc
            compiler-tests-single "${test_bin_path}" --64 --static-lib --lto
            compiler-tests-single "${test_bin_path}" --64 --static-lib --gc --lto
          )
          if [ "${XBB_SKIP_32_BIT_TESTS:-""}" == "y" ]
          then
            echo
            echo "Skipping -m32 --static-lib tests..."
          else
            (
              export LD_LIBRARY_PATH="$(xbb_get_libs_path -m32)"
              echo
              echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"

              compiler-tests-single "${test_bin_path}" --32 --static-lib
              compiler-tests-single "${test_bin_path}" --32 --static-lib --gc
              compiler-tests-single "${test_bin_path}" --32 --static-lib --lto
              compiler-tests-single "${test_bin_path}" --32 --static-lib --gc --lto
            )
          fi
        else
          (
            # Mainly for libgfortran.so.
            export LD_LIBRARY_PATH="$(xbb_get_libs_path)"
            echo
            echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"

            compiler-tests-single "${test_bin_path}" --static-lib
            compiler-tests-single "${test_bin_path}" --static-lib --gc
            compiler-tests-single "${test_bin_path}" --static-lib --lto
            compiler-tests-single "${test_bin_path}" --static-lib --gc --lto
          )
        fi
      fi

      # On Linux static linking is highly discouraged.
      # On RedHat and derived, the static libraries must be installed explicitly.

      if [[ ${distro} == CentOS ]] || [[ ${distro} == RedHat* ]] || [[ ${distro} == Fedora ]] || [[ ${distro} == openSUSE ]]
      then
        echo
        echo "Skipping all --static on ${distro}..."
      else
        if [ "${XBB_HOST_ARCH}" == "x64" ]
        then
          (
            compiler-tests-single "${test_bin_path}" --64 --static
            compiler-tests-single "${test_bin_path}" --64 --static --gc
            compiler-tests-single "${test_bin_path}" --64 --static --lto
            compiler-tests-single "${test_bin_path}" --64 --static --gc --lto

            if [ "${XBB_SKIP_32_BIT_TESTS:-""}" == "y" ]
            then
              echo
              echo "Skipping -m32 --static tests..."
            else
              compiler-tests-single "${test_bin_path}" --32 --static
              compiler-tests-single "${test_bin_path}" --32 --static --gc
              compiler-tests-single "${test_bin_path}" --32 --static --lto
              compiler-tests-single "${test_bin_path}" --32 --static --gc --lto
            fi
          )
        else
          (
            compiler-tests-single "${test_bin_path}" --static
            compiler-tests-single "${test_bin_path}" --static --gc
            compiler-tests-single "${test_bin_path}" --static --lto
            compiler-tests-single "${test_bin_path}" --static --gc --lto
          )
        fi

      fi
    elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
    then
      (
        # # https://stackoverflow.com/questions/3146274/is-it-ok-to-use-dyld-library-path-on-mac-os-x-and-whats-the-dynamic-library-s
        # Note: do not simply override DYLD_FALLBACK_LIBRARY_PATH,
        # it must include the system lcoations.
        # export DYLD_LIBRARY_PATH="$(${CC} -print-search-dirs | grep 'libraries: =' | sed -e 's|libraries: =||')"
        # echo
        # echo "DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}"

        # Normally this is not needed, the resulting binaries use rpath:
        # [objdump --macho --dylibs-used /Users/ilg/Work/gcc-12.2.0-2/darwin-x64/x86_64-apple-darwin21.6.0/tests/gcc/c-cpp/throwcatch-main]
        # /Users/ilg/Work/gcc-12.2.0-2/darwin-x64/x86_64-apple-darwin21.6.0/tests/gcc/c-cpp/throwcatch-main: (LC_RPATH=@loader_path:/Users/ilg/Work/gcc-12.2.0-2/darwin-x64/application/lib/gcc/x86_64-apple-darwin21.6.0/12.2.0:/Users/ilg/Work/gcc-12.2.0-2/darwin-x64/application/lib)
        # 	@rpath/libstdc++.6.dylib (compatibility version 7.0.0, current version 7.30.0)
        # 	@rpath/libgcc_s.1.1.dylib (compatibility version 1.0.0, current version 1.1.0)
        # 	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1319.0.0)

        # Old macOS linkers do not support LTO, thus use lld.
        compiler-tests-single "${test_bin_path}"
        compiler-tests-single "${test_bin_path}" --gc
        compiler-tests-single "${test_bin_path}" --lto --lld
        compiler-tests-single "${test_bin_path}" --gc --lto --lld

        echo
        echo "Skipping all --static-lib on macOS..."
        echo
        echo "Skipping all --static on macOS..."
      )
    fi
  )
}

# -----------------------------------------------------------------------------
