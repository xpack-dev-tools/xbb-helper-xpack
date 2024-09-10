# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# https://gcc.gnu.org
# Releases https://ftp.gnu.org/gnu/gcc/

# https://gcc.gnu.org/wiki/InstallingGCC
# https://gcc.gnu.org/install
# https://gcc.gnu.org/install/configure.html

# https://gitlab.archlinux.org/archlinux/packaging/packages/gcc/-/blob/main/PKGBUILD
# https://gitlab.archlinux.org/archlinux/packaging/packages/gcc10/-/blob/main/PKGBUILD
# https://gitlab.archlinux.org/archlinux/packaging/packages/mingw-w64-gcc/-/blob/main/PKGBUILD

# https://archlinuxarm.org/packages/aarch64/gcc/files/PKGBUILD
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gcc-git

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/g/gcc.rb
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/g/gcc@8.rb

# Mingw on Arch
# https://gitlab.archlinux.org/archlinux/packaging/packages/mingw-w64-gcc/-/blob/main/PKGBUILD
# https://gitlab.archlinux.org/archlinux/packaging/packages/mingw-w64-headers/-/blob/main/PKGBUILD
# https://gitlab.archlinux.org/archlinux/packaging/packages/mingw-w64-crt/-/blob/main/PKGBUILD
#
# Mingw on Msys2
# https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-gcc/PKGBUILD
# https://github.com/msys2/MSYS2-packages/blob/master/gcc/PKGBUILD

# -----------------------------------------------------------------------------

# Returns XBB_GCC_SRC_FOLDER_NAME.
function gcc_download()
{
  local gcc_version="$1"

  # Branch from the Darwin maintainer of GCC with Apple Silicon support,
  # located at https://github.com/iains/gcc-darwin-arm64 and
  # backported with his help to gcc-1? branch.

  # The repo used by the HomeBrew:
  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/g/gcc.rb
  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/g/gcc@12.rb
  # https://github.com/Homebrew/formula-patches/tree/master/gcc
  # https://github.com/fxcoudert/gcc/tags

  export XBB_GCC_SRC_FOLDER_NAME="gcc-${gcc_version}"

  local gcc_archive="${XBB_APPLICATION_GCC_ARCHIVE_NAME:-${XBB_GCC_SRC_FOLDER_NAME}.tar.xz}"
  # https://gcc.gnu.org/ftp/gcc/releases/gcc-12.4.0/gcc-12.4.0.tar.xz <--
  # https://gcc.gnu.org/pub/gcc/releases/gcc-11.5.0/gcc-11.5.0.tar.xz
  local gcc_url="${XBB_APPLICATION_GCC_URL:-https://gcc.gnu.org/ftp/gcc/releases/gcc-${gcc_version}/${gcc_archive}}"

  local gcc_patch_file_name="${XBB_GCC_PATCH_FILE_NAME:-""}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${XBB_GCC_SRC_FOLDER_NAME}"

  if [ ! -d "${XBB_SOURCES_FOLDER_PATH}/${XBB_GCC_SRC_FOLDER_NAME}" ]
  then
    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    if [ "${XBB_APPLICATION_TEST_PRERELEASE:-""}" == "y" ]
    then
      run_verbose git_clone \
        "${XBB_GCC_GIT_URL}" \
        "${XBB_GCC_SRC_FOLDER_NAME}" \
        --branch="${XBB_GCC_GIT_BRANCH:-""}" \
        --commit="${XBB_GCC_GIT_COMMIT:-""}" \
        --patch="${gcc_patch_file_name}"
    else
      download_and_extract "${gcc_url}" "${gcc_archive}" \
        "${XBB_GCC_SRC_FOLDER_NAME}" "${gcc_patch_file_name}"
    fi
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

  local gcc_version_major=$(xbb_get_version_major "${gcc_version}")

  export GCC_FOLDER_NAME="${XBB_GCC_SRC_FOLDER_NAME}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}"

  local gcc_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${GCC_FOLDER_NAME}-installed"
  if [ ! -f "${gcc_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    (
      mkdir -p "${XBB_BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"

      # To access the newly compiled libraries.
      # On Arm it still needs --with-gmp
      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        # Reduce the risk of messing bootstrap libraries.
        # LDFLAGS="${XBB_LDFLAGS_APP} ${XBB_LDFLAGS_STATIC_LIBS}"

        # Mainly for the path to the libraries, rpath is not relevant.
        xbb_adjust_ldflags_rpath

        export CC_FOR_BUILD="${XBB_NATIVE_CC}"
        export CXX_FOR_BUILD="${XBB_NATIVE_CXX}"

        export AR_FOR_BUILD="${XBB_NATIVE_AR}"
        export AS_FOR_BUILD="${XBB_NATIVE_AS}"
        export DLLTOOL_FOR_BUILD="${XBB_NATIVE_DLLTOOL}"
        export LD_FOR_BUILD="${XBB_NATIVE_LD}"
        export NM_FOR_BUILD="${XBB_NATIVE_NM}"
        export RANLIB_FOR_BUILD="${XBB_NATIVE_RANLIB}"
        export WINDMC_FOR_BUILD="${XBB_NATIVE_WINDMC}"
        export WINDRES_FOR_BUILD="${XBB_NATIVE_WINDRES}"

        # local xbb_library_path_for_build=""
        local xbb_toolchain_rpath_for_build="$(xbb_get_toolchain_library_path "${CXX_FOR_BUILD}")"
        export LDFLAGS_FOR_BUILD="$(xbb_expand_linker_rpaths "${xbb_toolchain_rpath_for_build}")"

        # --enable-mingw-wildcard already does this, enabling it results in:
        # multiple definition of `_dowildcard'
        # Used to enable wildcard; inspired by arm-none-eabi-gcc.
        # local crt_clob_file_path="$(${CC} --print-file-name=CRT_glob.o)"
        # LDFLAGS+=" -Wl,${crt_clob_file_path}"

        # Hack to prevent "too many sections", "File too big" etc in insn-emit.c
        CXXFLAGS=$(echo ${CXXFLAGS} | sed -e 's|-ffunction-sections -fdata-sections||')
        CXXFLAGS+=" -D__USE_MINGW_ACCESS"

        # c++tools require a pic/libiberty.a, and --with-pic is ignored.
        CFLAGS+=" -fPIC"
        CXXFLAGS+=" -fPIC"
      elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
      then
        if is_development
        then
          LDFLAGS="-DXBB_MARKER_TOP"
        else
          LDFLAGS=""
        fi
        LDFLAGS+=" ${XBB_LDFLAGS_APP}"

        # Before LDFLAGS_FOR_TARGET & Co.
        xbb_adjust_ldflags_rpath

        # HomeBrew mentiones this:
        # GCC will suffer build errors if forced to use a particular linker.
        unset LD

        # The target may refer to the development libraries.
        # It does not need the bootstrap toolchain rpaths.
        if is_development
        then
          LDFLAGS_FOR_TARGET="-DXBB_MARKER_TARGET"
        else
          LDFLAGS_FOR_TARGET=""
        fi
        LDFLAGS_FOR_TARGET+=" ${XBB_LDFLAGS_APP}"
        LDFLAGS_FOR_TARGET+=" -v"
        if is_development
        then
          LDFLAGS_FOR_TARGET+=" -Wl,-v"
          if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then
            LDFLAGS_FOR_TARGET+=" -Wl,-t"
          elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
          then
            LDFLAGS_FOR_TARGET+=" -Wl,-t,-t"
          fi
        fi

        # The static libiconv is used to avoid a reference in libstdc++.dylib
        LDFLAGS_FOR_TARGET+=" -L${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/static/lib"

        LDFLAGS_FOR_TARGET+=" $(xbb_expand_linker_library_paths "${XBB_LIBRARY_PATH}")"
        LDFLAGS_FOR_TARGET+=" $(xbb_expand_linker_rpaths "${XBB_LIBRARY_PATH}")"

        export LDFLAGS_FOR_TARGET
      elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
      then
        if is_development
        then
          LDFLAGS="-DXBB_MARKER_TOP"
        else
          LDFLAGS=""
        fi
        LDFLAGS+=" ${XBB_LDFLAGS_APP}"

        # Before LDFLAGS_FOR_TARGET & Co.
        xbb_adjust_ldflags_rpath

        # The target may refer to the development libraries.
        # It does not need the bootstrap toolchain rpaths.
        if is_development
        then
          LDFLAGS_FOR_TARGET="-DXBB_MARKER_TARGET"
        else
          LDFLAGS_FOR_TARGET=""
        fi
        LDFLAGS_FOR_TARGET+=" ${XBB_LDFLAGS_APP}"
        LDFLAGS_FOR_TARGET+=" $(xbb_expand_linker_library_paths "${XBB_LIBRARY_PATH}")"
        LDFLAGS_FOR_TARGET+=" $(xbb_expand_linker_rpaths "${XBB_LIBRARY_PATH}")"

        export LDFLAGS_FOR_TARGET
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
          echo "Running gcc configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${XBB_GCC_SRC_FOLDER_NAME}/configure" --help
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${XBB_GCC_SRC_FOLDER_NAME}/gcc/configure" --help

            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${XBB_GCC_SRC_FOLDER_NAME}/libgcc/configure" --help
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${XBB_GCC_SRC_FOLDER_NAME}/libstdc++-v3/configure" --help
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

          # LTO build crashes on Apple Silicon.
          # config_options+=("--with-build-config=-lto") # Arch

          # config_options+=("--with-gcc-major-version-only") # HB

          config_options+=("--with-dwarf2")
          config_options+=("--with-diagnostics-color=auto")

          config_options+=("--with-libiconv-prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          config_options+=("--with-gmp=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--with-isl=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--with-mpc=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--with-mpfr=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
          # Note: the path is not propagated to sub-projects.
          config_options+=("--with-zstd=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          # Use the zlib compiled from sources.
          config_options+=("--with-system-zlib") # HB, Arch
          config_options+=("--without-cuda-driver")

          config_options+=("--enable-languages=c,c++,objc,obj-c++,lto,fortran") # HB
          config_options+=("--enable-objc-gc=auto")

          config_options+=("--enable-checking=release") # HB, Arch

          config_options+=("--enable-lto") # Arch
          config_options+=("--enable-plugin") # Arch

          config_options+=("--enable-__cxa_atexit") # Arch

          # Intel specific.
          config_options+=("--enable-cet=auto") # Arch

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

            config_options+=("--enable-threads=posix")

            # This distribution expects the SDK to be installed
            # with the Command Line Tools, which have a fixed location,
            # while Xcode may vary from version to version.
            config_options+=("--with-sysroot=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk") # HB

            # From HomeBrew, but the folder is not present in 11.x
            # config_options+=("--with-native-system-header-dir=/usr/include")

            # Be sure the multi-step build is performed; shortcuts
            # generally fail, since clang may have different libraries.
            config_options+=("--enable-bootstrap")

            # Build stage 1 with static system libraries.
            # The flags are added to the top LDFLAGS, so no need to repeat them.
            local ldflags_for_bootstrap
            if is_development
            then
              ldflags_for_bootstrap="-DXBB_MARKER_STAGE1"
            else
              ldflags_for_bootstrap=""
            fi
            if [[ $(basename "${CC}") =~ .*gcc.* ]]
            then
              # These are available only when bootstraping with gcc.
              ldflags_for_bootstrap+=" -static-libstdc++ -static-libgcc"
            # elif [[ $(basename "${CC}") =~ .*clang.* ]]
            # then
            #   ldflags_for_bootstrap+=" -fuse-ld=lld" # Experimental
            fi

            # Add -L for the toolchain libraries, otherwise the macOS linker will pick
            # the system libraries, like libc++ (on Linux, `-rpath-link` does the trick).
            ldflags_for_bootstrap+=" $(xbb_expand_linker_library_paths "${XBB_TOOLCHAIN_RPATH}")"

            config_options+=("--with-stage1-ldflags=${ldflags_for_bootstrap}") # -v -Wl,-v

            # Build the intermediate stages (2 & 3) with static system libraries,
            # to save some references to shared libraries.
            # The bootstrap toolchain rpaths are not needed.
            local ldflags_for_boot
            if is_development
            then
              ldflags_for_boot="-DXBB_MARKER_BOOT"
            else
              ldflags_for_boot=""
            fi
            ldflags_for_boot+=" -v"
            if is_development
            then
              ldflags_for_boot+=" -Wl,-v"
              if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
              then
                ldflags_for_boot+=" -Wl,-t"
              elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
              then
                ldflags_for_boot+=" -Wl,-t,-t"
              fi
            fi
            ldflags_for_boot+=" -static-libstdc++ -static-libgcc"
            ldflags_for_boot+=" ${XBB_LDFLAGS_APP}"

            ldflags_for_boot+=" $(xbb_expand_linker_library_paths "${XBB_LIBRARY_PATH}")"
            ldflags_for_boot+=" $(xbb_expand_linker_rpaths "${XBB_LIBRARY_PATH}")"

            config_options+=("--with-boot-ldflags=${ldflags_for_boot}") # -v -Wl,-v

            # Do not install libraries with @rpath/library-name. Not needed.
            # config_options+=("--enable-darwin-at-rpath=no")

            config_options+=("--disable-multilib")

          elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
          then

            # Shared libraries remain problematic when refered from generated
            # programs, and require setting the executable rpath to work.
            config_options+=("--enable-shared")

            config_options+=("--enable-threads=posix")

            config_options+=("--enable-bootstrap")

            # Stage 1 is the bootstrap, performed with on old compiler,
            # thus it needs the toolchain rpaths, but the resulting
            # compiler will be statically linked, to avoid computing
            # multiple rpaths in multilib cases.
            # The flags are added to the top LDFLAGS, so no need to repeat them.
            local ldflags_for_bootstrap
            if is_development
            then
              ldflags_for_bootstrap="-DXBB_MARKER_STAGE1"
            else
              ldflags_for_bootstrap=""
            fi
            ldflags_for_bootstrap+=" -static-libstdc++ -static-libgcc"
            config_options+=("--with-stage1-ldflags=${ldflags_for_bootstrap}") # -v -Wl,-v

            # Do not enable it, since it switches the compiler to CC, not CXX.
            # config_options+=("--with-boot-libs=-lpthread")

            # Build the intermediate stages (2 & 3) with static system libraries,
            # to save some references to shared libraries.
            # The bootstrap toolchain rpaths are not needed.
            local ldflags_for_boot
            if is_development
            then
              ldflags_for_boot="-DXBB_MARKER_BOOT"
            else
              ldflags_for_boot=""
            fi
            ldflags_for_boot+=" -v"
            if is_development
            then
              ldflags_for_boot+=" -Wl,-v"
              if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
              then
                ldflags_for_boot+=" -Wl,-t"
              elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
              then
                ldflags_for_boot+=" -Wl,-t,-t"
              fi
            fi
            ldflags_for_boot+=" -static-libstdc++ -static-libgcc ${XBB_LDFLAGS_APP}"
            ldflags_for_boot+=" $(xbb_expand_linker_library_paths "${XBB_LIBRARY_PATH}")"
            ldflags_for_boot+=" $(xbb_expand_linker_rpaths "${XBB_LIBRARY_PATH}")"

            config_options+=("--with-boot-ldflags=${ldflags_for_boot}") # -v -Wl,-v

            # Required on macOS, but here apparently not.
            # config_options+=("--disable-rpath")

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
              config_options+=("--with-arch=x86-64")
              config_options+=("--with-arch-32=i686")
              config_options+=("--with-abi=m64")
              # patchelf gets confused by x32 shared libraries.
              # config_options+=("--with-multilib-list=m32,m64,mx32")
              config_options+=("--with-multilib-list=m32,m64")

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

            # To keep -fPIC and generate  pic/libiberty.a
            config_options+=("--enable-host-shared")

            if [ ${gcc_version_major} -ge 13 ]
            then
              # https://github.com/gcc-mirror/gcc/commit/9149a5b7e0a66b7b94d5b7db3194a975d18dea2f
              config_options+=("--enable-threads=win32")
            else
              config_options+=("--enable-threads=posix")
            fi

            if [ "${XBB_HOST_ARCH}" == "x64" ]
            then
              config_options+=("--disable-multilib")
              config_options+=("--with-arch=x86-64")
            elif [ "${XBB_HOST_ARCH}" == "x32" -o "${XBB_HOST_ARCH}" == "ia32" ]
            then
              config_options+=("--disable-multilib")
              config_options+=("--with-arch=i686")

              # https://stackoverflow.com/questions/15670169/what-is-difference-between-sjlj-vs-dwarf-vs-seh
              # The defaults are sjlj for 32-bit and seh for 64-bit,
              # So better disable SJLJ explicitly.
              config_options+=("--disable-sjlj-exceptions")
            else
              echo "Unsupported XBB_HOST_ARCH=${XBB_HOST_ARCH} in ${FUNCNAME[0]}()"
              exit 1
            fi

            # Cross builds have their own explicit bootstrap.
            config_options+=("--disable-bootstrap")

            config_options+=("--enable-mingw-wildcard")

            # Tells GCC to use the gnu_unique_object relocation for C++
            # template static data members and inline function local statics.
            config_options+=("--enable-gnu-unique-object")
            config_options+=("--enable-gnu-indirect-function")
            config_options+=("--enable-linker-build-id")

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

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${XBB_GCC_SRC_FOLDER_NAME}/configure" \
            ${config_options[@]}

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/config-log-$(ndate).txt"

        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running gcc make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ] && [ "${XBB_APPLICATION_ENABLE_GCC_CHECK:-""}" == "y" ]
        then
          (
            echo
            echo "Running gcc make check..."

            xbb_activate_installed_bin

            export LD_LIBRARY_PATH="$(xbb_get_toolchain_library_path "${CXX}")"
            echo
            echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"

            if is_development
            then
              make -k check || true
            fi
          )
        fi

        echo
        echo "Running gcc make install..."

        if with_strip
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
        then
          # Hack to include the libiconv.a objects into libstdc++.a.
          local tmp_path=$(mktemp -d)

          echo
          echo "Including libiconv.a into libstdc++.a..."

          if [ "${XBB_TARGET_ARCH}" == "x64" ]
          then
            (
              rm -rf "${tmp_path}"
              mkdir "${tmp_path}"
              run_verbose_develop cd "${tmp_path}"

              run_verbose ${AR} xv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/static64/lib/libiconv.a"
              run_verbose ${AR} rsv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib64/libstdc++.a" *.o
            )
            (
              rm -rf "${tmp_path}"
              mkdir "${tmp_path}"
              run_verbose_develop cd "${tmp_path}"

              run_verbose ${AR} xv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/static32/lib/libiconv.a"
              run_verbose ${AR} rsv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib32/libstdc++.a" *.o
            )
          elif [ "${XBB_TARGET_ARCH}" == "arm64" ]
          then
            (
              rm -rf "${tmp_path}"
              mkdir "${tmp_path}"
              run_verbose_develop cd "${tmp_path}"

              run_verbose ${AR} xv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/static/lib/libiconv.a"
              run_verbose ${AR} rsv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib64/libstdc++.a" *.o
            )
          elif [ "${XBB_TARGET_ARCH}" == "arm" ]
          then
            (
              rm -rf "${tmp_path}"
              mkdir "${tmp_path}"
              run_verbose_develop cd "${tmp_path}"

              run_verbose ${AR} xv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/static/lib/libiconv.a"
              run_verbose ${AR} rsv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib/libstdc++.a" *.o
            )
          else
            echo "Unsupported XBB_TARGET_ARCH=${XBB_TARGET_ARCH} in ${FUNCNAME[0]}()"
            exit 1
          fi
        fi

        echo
        echo "Removing unnecessary files..."

        if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
        then
          rm -rfv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/gcc-ar"
          rm -rfv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/gcc-nm"
          rm -rfv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/gcc-ranlib"

          run_verbose rm -rfv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${XBB_TARGET_TRIPLET}"-*
        elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
        then
          run_verbose rm -rfv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${XBB_TARGET_TRIPLET}"-*
        elif [ "${XBB_HOST_PLATFORM}" == "win32" ]
        then
          run_verbose rm -rfv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${XBB_TARGET_TRIPLET}"-*.exe
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
            echo
            echo "Copying DLL files to lib..."

            run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"
            run_verbose find "${XBB_TARGET_TRIPLET}" -name '*.dll' ! -iname 'liblto*' \
              -exec cp -v '{}' "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib" ';'

            run_verbose_develop cd "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}"
            run_verbose find . -name '*.dll'
          )
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/make-output-$(ndate).txt"

      grep -i "FAIL:" "${XBB_LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}"/make-output-*.txt || true
      grep -i "error:" "${XBB_LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}"/make-output-*.txt || true
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${gcc_stamp_file_path}"

  else
    echo "Component gcc already installed"
  fi

  tests_add "gcc_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function gcc_test()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local test_bin_path="$1"
  shift

  local name_suffix=""
  local name_prefix=""

  (
    echo
    echo "Testing the ${name_prefix}gcc binaries..."

    if [ "${XBB_TEST_SYSTEM_TOOLS:-""}" == "y" ]
    then
      export CC="$(which gcc)"
      export CXX="$(which g++)"
      export F90="$(which gfortran)"

      if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
      then
        export AR="$(which ar)"
        export NM="$(which nm)"
        export RANLIB="$(which ranlib)"
      else
        export AR="$(which gcc-ar)"
        export NM="$(which gcc-nm)"
        export RANLIB="$(which gcc-ranlib)"

        if [ "${XBB_HOST_PLATFORM}" == "win32" ]
        then
          export WIDL="$(which widl)"
        fi
      fi

      export GCOV="$(which gcov)"
      export GCOV_DUMP="$(which gcov-dump)"
      export GCOV_TOOL="$(which gcov-tool)"
    else
      run_verbose ls -l "${test_bin_path}"

      export CC="${test_bin_path}/gcc"
      export CXX="${test_bin_path}/g++"
      export F90="${test_bin_path}/gfortran"

      if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
      then
        export AR="$(which ar)"
        export NM="$(which nm)"
        export RANLIB="$(which ranlib)"
      else
        export AR="${test_bin_path}/gcc-ar"
        export NM="${test_bin_path}/gcc-nm"
        export RANLIB="${test_bin_path}/gcc-ranlib"

        if [ "${XBB_HOST_PLATFORM}" == "win32" ]
        then
          export WIDL="${test_bin_path}/widl"
        fi
      fi

      export GCOV="${test_bin_path}/gcov"
      export GCOV_DUMP="${test_bin_path}/gcov-dump"
      export GCOV_TOOL="${test_bin_path}/gcov-tool"
    fi

    # -------------------------------------------------------------------------

    xbb_show_env_develop

    run_verbose uname
    if [ "${XBB_HOST_PLATFORM}" != "darwin" ]
    then
      run_verbose uname -o
    fi

    # -------------------------------------------------------------------------

    local gcc_version=$(run_host_app "${CC}" -dumpversion)
    echo
    echo "$(basename ${CC}${XBB_HOST_DOT_EXE}): ${gcc_version} (${CC}${XBB_HOST_DOT_EXE})"

    local gcc_version_major=$(xbb_get_version_major "${gcc_version}")

    # -------------------------------------------------------------------------

    echo
    echo "Checking the ${name_prefix}gcc shared libraries..."

    show_host_libs "${CC}"
    show_host_libs "${CXX}"

    if [ -f "${F90}${XBB_HOST_DOT_EXE}" ]
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
      show_host_libs "$(${CC} -m64 --print-file-name=libgcc_s.so.1)"
      show_host_libs "$(${CC} -m64 --print-file-name=libstdc++.so.6)"

      if [ "${XBB_SKIP_32_BIT_TESTS:-""}" != "y" ]
      then
        show_host_libs "$(${CC} -m32 --print-file-name=libgcc_s.so.1)"
        show_host_libs "$(${CC} -m32 --print-file-name=libstdc++.so.6)"
      fi
    elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
    then
      local libgcc_path="$(${CC} --print-file-name=libgcc_s.1.dylib)"
      if [ "${libgcc_path}" != "libgcc_s.1.dylib" ]
      then
        show_host_libs "$(${CC} --print-file-name=libgcc_s.1.dylib)"
      fi
      show_host_libs "$(${CC} --print-file-name=libstdc++.dylib)"
    fi

    # -------------------------------------------------------------------------

    test_case_gcc_binaries_start

    test_case_gcc_configuration

    # -------------------------------------------------------------------------

    echo
    echo "Testing if gcc compiles simple programs..."

    rm -rf "${XBB_TESTS_FOLDER_PATH}/gcc"
    mkdir -pv "${XBB_TESTS_FOLDER_PATH}/gcc"
    run_verbose_develop cd "${XBB_TESTS_FOLDER_PATH}/gcc"

    echo
    echo "pwd: $(pwd)"

    # -------------------------------------------------------------------------

    source "${helper_folder_path}/tests/c-cpp/test-compiler.sh"
    run_verbose cp -Rv "${helper_folder_path}/tests/c-cpp" .
    chmod -R a+w c-cpp

    run_verbose cp -Rv "${helper_folder_path}/tests/wine"/* c-cpp
    chmod -R a+w c-cpp

    source "${helper_folder_path}/tests/fortran/test-compiler.sh"
    run_verbose cp -Rv "${helper_folder_path}/tests/fortran" .
    chmod -R a+w fortran

    # -------------------------------------------------------------------------

    if [ "${XBB_HOST_PLATFORM}" == "win32" ]
    then
      test_win32
    elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
    then
      test_linux
    elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
    then
      test_darwin
    fi
  )
}

# -----------------------------------------------------------------------------

function test_case_gcc_binaries_start()
{
  local test_case_name="$(test_case_get_name)"

  local prefix=${PREFIX:-""}
  local suffix=${SUFFIX:-""}

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    echo
    echo "Testing if the ${prefix}gcc binaries start properly..."

    run_host_app_verbose "${CC}" --version
    run_host_app_verbose "${CXX}" --version

    if [ -f "${F90}${XBB_HOST_DOT_EXE}" ]
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

    run_host_app_verbose "${GCOV}" --version
    run_host_app_verbose "${GCOV_DUMP}" --version
    run_host_app_verbose "${GCOV_TOOL}" --version

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${prefix}${test_case_name}${suffix}.txt"
}

function test_case_gcc_configuration()
{
  local test_case_name="$(test_case_get_name)"

  local prefix=${PREFIX:-""}
  local suffix=${SUFFIX:-""}

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    echo
    echo "Testing the ${prefix}gcc configurations..."

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

    if [ "${XBB_HOST_PLATFORM}" == "linux" ] && [ "${XBB_SKIP_32_BIT_TESTS:-""}" != "y" ]
    then
      run_host_app_verbose "${CC}" -m32 -print-search-dirs
      run_host_app_verbose "${CC}" -m32 -print-multi-os-directory

      run_host_app_verbose "${CXX}" -m32 -print-search-dirs
      run_host_app_verbose "${CXX}" -m32 -print-multi-os-directory
    fi

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${prefix}${test_case_name}${suffix}.txt"
}

# -----------------------------------------------------------------------------

function test_win32()
{
  (
    if [ ${gcc_version_major} -eq 11 ] || \
       [ ${gcc_version_major} -eq 12 ] || \
       [ ${gcc_version_major} -eq 13 ] || \
       [ ${gcc_version_major} -eq 14 ]
    then

      # autoimport-main.
      # [wine64 ./lto-autoimport-main.exe]
      # Mingw-w64 runtime failure:
      # 32 bit pseudo relocation at 000000014000152A out of range, targeting 000000028846135C, yielding the value 000000014845FE2E.
      export XBB_IGNORE_TEST_LTO_AUTOIMPORT_MAIN="y"
      export XBB_IGNORE_TEST_GC_LTO_AUTOIMPORT_MAIN="y"
      export XBB_IGNORE_TEST_STATIC_LIB_LTO_AUTOIMPORT_MAIN="y"
      export XBB_IGNORE_TEST_STATIC_LIB_GC_LTO_AUTOIMPORT_MAIN="y"

      # hello-weak-c.
      # z:/home/ilg/work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/application/bin/../lib/gcc/x86_64-w64-mingw32/12.3.0/../../../../x86_64-w64-mingw32/bin/ld.exe: hello-weak.c.o:hello-weak.c:(.text+0x15): undefined reference to `world'
      # collect2.exe: error: ld returned 1 exit status
      # Interestingly, LTO tests pass.
      export XBB_IGNORE_TEST_HELLO_WEAK1_C="y"
      export XBB_IGNORE_TEST_GC_HELLO_WEAK1_C="y"
      export XBB_IGNORE_TEST_STATIC_LIB_HELLO_WEAK1_C="y"
      export XBB_IGNORE_TEST_STATIC_LIB_GC_HELLO_WEAK1_C="y"
      export XBB_IGNORE_TEST_STATIC_HELLO_WEAK1_C="y"
      export XBB_IGNORE_TEST_STATIC_GC_HELLO_WEAK1_C="y"

      # hello-weak-cpp.
      export XBB_IGNORE_TEST_HELLO_WEAK2_CPP="y"
      export XBB_IGNORE_TEST_GC_HELLO_WEAK2_CPP="y"
      export XBB_IGNORE_TEST_STATIC_LIB_HELLO_WEAK2_CPP="y"
      export XBB_IGNORE_TEST_STATIC_LIB_GC_HELLO_WEAK2_CPP="y"
      export XBB_IGNORE_TEST_STATIC_HELLO_WEAK2_CPP="y"
      export XBB_IGNORE_TEST_STATIC_GC_HELLO_WEAK2_CPP="y"

      # overload-new.
      # static lib and static are functional. (all on mingw!)
      # Does not return success.
      export XBB_IGNORE_TEST_OVERLOAD_NEW_CPP="y"
      export XBB_IGNORE_TEST_GC_OVERLOAD_NEW_CPP="y"
      export XBB_IGNORE_TEST_LTO_OVERLOAD_NEW_CPP="y"
      export XBB_IGNORE_TEST_GC_LTO_OVERLOAD_NEW_CPP="y"

      # throwcatch-main.
      # [wine64 ./lto-throwcatch-main.exe]
      # wine: Unhandled page fault on execute access to 0000000122B1157C at address 0000000122B1157C (thread 03d8), starting debugger...
      # Unhandled exception: page fault on execute access to 0x0000000122b1157c in 64-bit code (0x00000122b1157c).
      export XBB_IGNORE_TEST_LTO_THROWCATCH_MAIN="y"
      export XBB_IGNORE_TEST_GC_LTO_THROWCATCH_MAIN="y"
      export XBB_IGNORE_TEST_STATIC_LIB_LTO_THROWCATCH_MAIN="y"
      export XBB_IGNORE_TEST_STATIC_LIB_GC_LTO_THROWCATCH_MAIN="y"

      # unwind-weak.
      # LTO are functional.
      #  in function `main': undefined reference to `step1'
      export XBB_IGNORE_TEST_UNWIND_WEAK_CPP="y"
      export XBB_IGNORE_TEST_GC_UNWIND_WEAK_CPP="y"
      export XBB_IGNORE_TEST_STATIC_LIB_UNWIND_WEAK_CPP="y"
      export XBB_IGNORE_TEST_STATIC_LIB_GC_UNWIND_WEAK_CPP="y"
      export XBB_IGNORE_TEST_STATIC_UNWIND_WEAK_CPP="y"
      export XBB_IGNORE_TEST_STATIC_GC_UNWIND_WEAK_CPP="y"

      # weak-duplicate - LTO are functional.
      # in function `dummy': undefined reference to `func'
      export XBB_IGNORE_TEST_WEAK_DUPLICATE_C="y"
      export XBB_IGNORE_TEST_GC_WEAK_DUPLICATE_C="y"
      export XBB_IGNORE_TEST_STATIC_LIB_WEAK_DUPLICATE_C="y"
      export XBB_IGNORE_TEST_STATIC_LIB_GC_WEAK_DUPLICATE_C="y"
      export XBB_IGNORE_TEST_STATIC_WEAK_DUPLICATE_C="y"
      export XBB_IGNORE_TEST_STATIC_GC_WEAK_DUPLICATE_C="y"

      # weak-use - LTO variants are functional.
      # in function `dummy': undefined reference to `func'
      export XBB_IGNORE_TEST_WEAK_USE_C="y"
      export XBB_IGNORE_TEST_GC_WEAK_USE_C="y"
      export XBB_IGNORE_TEST_STATIC_LIB_WEAK_USE_C="y"
      export XBB_IGNORE_TEST_STATIC_LIB_GC_WEAK_USE_C="y"
      export XBB_IGNORE_TEST_STATIC_WEAK_USE_C="y"
      export XBB_IGNORE_TEST_STATIC_GC_WEAK_USE_C="y"
    fi

    (
      if [ "${XBB_BUILD_PLATFORM}" == "win32" ]
      then
        cxx_lib_path=$(dirname $(${CXX} -print-file-name=libstdc++-6.dll | sed -e 's|:||' | sed -e 's|^|/|'))
        export PATH="${cxx_lib_path}:${PATH:-}"
        echo "PATH=${PATH}"
      else
        # Cross-compiling, use WineHQ.
        export WINEPATH="${test_bin_path}/../lib;${WINEPATH:-}"
        echo "WINEPATH=${WINEPATH}"
      fi

      test_compiler_c_cpp
      test_compiler_c_cpp --gc
      test_compiler_c_cpp --lto
      test_compiler_c_cpp --gc --lto

      test_compiler_fortran
    )

    test_compiler_c_cpp --static-lib
    test_compiler_c_cpp --static-lib --gc
    test_compiler_c_cpp --static-lib --lto
    test_compiler_c_cpp --static-lib --gc --lto

    test_compiler_c_cpp --static
    test_compiler_c_cpp --static --gc
    test_compiler_c_cpp --static --lto
    test_compiler_c_cpp --static --gc --lto
  )
}

# -----------------------------------------------------------------------------

function test_linux()
{
  (
    local distro=$(lsb_release -is)

    if [ ${gcc_version_major} -eq 11 ] || \
       [ ${gcc_version_major} -eq 12 ] || \
       [ ${gcc_version_major} -eq 13 ] || \
       [ ${gcc_version_major} -eq 14 ]
    then
      # sleepy-threads-cv.
      # The static tests crash with 'Segmentation fault'.
      export XBB_IGNORE_TEST_STATIC_SLEEPY_THREADS_CV="y"
      export XBB_IGNORE_TEST_STATIC_GC_SLEEPY_THREADS_CV="y"
      export XBB_IGNORE_TEST_STATIC_LTO_SLEEPY_THREADS_CV="y"
      export XBB_IGNORE_TEST_STATIC_GC_LTO_SLEEPY_THREADS_CV="y"

      if [ "${distro}" == "Fedora" ]
      then
        # cnrt-test-32.
        # undefined reference to `fmod'
        export XBB_IGNORE_TEST_STATIC_CNRT_TEST_32="y"
        export XBB_IGNORE_TEST_STATIC_GC_CNRT_TEST_32="y"
        export XBB_IGNORE_TEST_STATIC_LTO_CNRT_TEST_32="y"
        export XBB_IGNORE_TEST_STATIC_GC_LTO_CNRT_TEST_32="y"
      fi
    fi

    # -------------------------------------------------------------------------

    # It is mandatory for the compiler to run properly without any
    # explicit libraries or other options, otherwise tools used
    # during configuration (like meson) might fail probing for
    # capabilities.
    test_compiler_c_cpp --probe

    # -------------------------------------------------------------------------

    if [ "${XBB_HOST_ARCH}" == "x64" ]
    then

      for bits in 32 64
      do
        if [ ${bits} -eq 32 ]
        then
          local skip_32_tests=""
          if is_variable_set "XBB_SKIP_32_BIT_TESTS"
          then
            skip_32_tests="${XBB_SKIP_32_BIT_TESTS}"
          else
            local libstdcpp_file_path="$(${CXX} -m32 -print-file-name=libstdc++.so)"
            if [ "${libstdcpp_file_path}" == "libstdc++.so" ]
            then
              # If the compiler does not find the full path of the
              # 32-bit c++ library, multilib support is not installed; skip.
              skip_32_tests="y"
            fi
          fi

          if [ "${skip_32_tests}" == "y" ]
          then
            echo
            echo "Skipping gcc -m32 tests..."
            continue
          fi
        fi

        (
          # The shared libraries are in a custom location and require setting
          # the libraries and rpath explicitly.

          local toolchain_library_path="$(xbb_get_toolchain_library_path "${CXX}" -m${bits})"

          # No -L required, -rpath-link does the trick.
          LDFLAGS+=" $(xbb_expand_linker_rpaths "${toolchain_library_path}")"
          LDXXFLAGS+=" $(xbb_expand_linker_rpaths "${toolchain_library_path}")"

          export LDFLAGS
          export LDXXFLAGS

          echo
          echo "LDFLAGS=${LDFLAGS}"

          test_compiler_c_cpp --${bits}
          test_compiler_c_cpp --${bits} --gc
          test_compiler_c_cpp --${bits} --lto
          test_compiler_c_cpp --${bits} --gc --lto
        )

        if is_variable_set "F90"
        then
          (
            # The shared libraries are in a custom location and require setting
            # the libraries and rpath explicitly.

            local toolchain_library_path="$(xbb_get_toolchain_library_path "${F90}" -m${bits})"

            # No -L required, -rpath-link does the trick.
            LDFLAGS+=" $(xbb_expand_linker_rpaths "${toolchain_library_path}")"

            export LDFLAGS

            echo
            echo "LDFLAGS=${LDFLAGS}"

            test_compiler_fortran --${bits}
          )
        fi

        test_compiler_c_cpp --${bits} --static-lib
        test_compiler_c_cpp --${bits} --static-lib --gc
        test_compiler_c_cpp --${bits} --static-lib --lto
        test_compiler_c_cpp --${bits} --static-lib --gc --lto

        # On Linux static linking is highly discouraged.
        # On RedHat and derived, the static libraries must be installed explicitly.

        test_compiler_c_cpp --${bits} --static
        test_compiler_c_cpp --${bits} --static --gc
        test_compiler_c_cpp --${bits} --static --lto
        test_compiler_c_cpp --${bits} --static --gc --lto
      done

    elif [ "${XBB_HOST_ARCH}" == "arm64" ] || [ "${XBB_HOST_ARCH}" == "arm" ]
    then

      # arm & aarch64 are non-multilib, no explicit -m32/-m64 needed.
      (
        # The shared libraries are in a custom location and require setting
        # the libraries and rpath explicitly.

        local toolchain_library_path="$(xbb_get_toolchain_library_path "${CXX}")"

        # No -L required, -rpath-link does the trick.
        LDFLAGS+=" $(xbb_expand_linker_rpaths "${toolchain_library_path}")"
        LDXXFLAGS+=" $(xbb_expand_linker_rpaths "${toolchain_library_path}")"

        export LDFLAGS
        export LDXXFLAGS

        echo
        echo "LDFLAGS=${LDFLAGS}"

        test_compiler_c_cpp
        test_compiler_c_cpp --gc
        test_compiler_c_cpp --lto
        test_compiler_c_cpp --gc --lto
      )

      if is_variable_set "F90"
      then
        (
          # The shared libraries are in a custom location and require setting
          # the libraries and rpath explicitly.

          local toolchain_library_path="$(xbb_get_toolchain_library_path "${F90}")"

          # No -L required, -rpath-link does the trick.
          LDFLAGS+=" $(xbb_expand_linker_rpaths "${toolchain_library_path}")"

          export LDFLAGS

          echo
          echo "LDFLAGS=${LDFLAGS}"

          test_compiler_fortran
        )
      fi

      test_compiler_c_cpp --static-lib
      test_compiler_c_cpp --static-lib --gc
      test_compiler_c_cpp --static-lib --lto
      test_compiler_c_cpp --static-lib --gc --lto

      # On Linux static linking is highly discouraged.
      # On RedHat and derived, the static libraries must be installed explicitly.

      test_compiler_c_cpp --static
      test_compiler_c_cpp --static --gc
      test_compiler_c_cpp --static --lto
      test_compiler_c_cpp --static --gc --lto

    else
      echo "Unsupported XBB_HOST_ARCH=${XBB_HOST_ARCH} in ${FUNCNAME[0]}()"
      exit 1
    fi
  )
}

# -----------------------------------------------------------------------------

function test_darwin()
{
  (
    # On older machines the references to libstdc++ are absolute and no rpath
    # is required, but on recent ones references are like @rpath/xxx.dylib.

    # Surprise! GCC 12 passes all tests.

    if [ ${gcc_version_major} -eq 13 ]
    then
      # weak-undef.
      # Most likely an Apple linker issue.
      export XBB_IGNORE_TEST_ALL_WEAK_UNDEF_C="y"

      # This one fails only with GC?!
      export XBB_IGNORE_TEST_GC_OVERLOAD_NEW_CPP="y"
      export XBB_IGNORE_TEST_GC_LTO_OVERLOAD_NEW_CPP="y"
    elif [ ${gcc_version_major} -eq 14 ] || \
         [ ${gcc_version_major} -eq 15 ]
    then
      # weak-undef.
      # Most likely an Apple linker issue.
      export XBB_IGNORE_TEST_ALL_WEAK_UNDEF_C="y"
      # export XBB_IGNORE_TEST_WEAK_UNDEF_C="y"
      # export XBB_IGNORE_TEST_GC_WEAK_UNDEF_C="y"
      # export XBB_IGNORE_TEST_LTO_WEAK_UNDEF_C="y"
      # export XBB_IGNORE_TEST_GC_LTO_WEAK_UNDEF_C="y"
      # export XBB_IGNORE_TEST_STATIC_LIB_WEAK_UNDEF_C="y"
      # export XBB_IGNORE_TEST_STATIC_LIB_GC_WEAK_UNDEF_C="y"
      # export XBB_IGNORE_TEST_STATIC_LIB_LTO_WEAK_UNDEF_C="y"
      # export XBB_IGNORE_TEST_STATIC_LIB_GC_LTO_WEAK_UNDEF_C="y"

      # This one fails only with GC?!
      export XBB_IGNORE_TEST_GC_OVERLOAD_NEW_CPP="y"
      export XBB_IGNORE_TEST_GC_LTO_OVERLOAD_NEW_CPP="y"
    fi

    # ---------------------------------------------------------------------

    # It is mandatory for the compiler to run properly without any
    # explicit libraries or other options, otherwise tools used
    # during configuration (like meson) might fail probing for
    # capabilities.
    test_compiler_c_cpp --probe

    # ---------------------------------------------------------------------

    (
      # The shared libraries are in a custom location and require setting
      # the libraries and rpath explicitly.

      local toolchain_library_path="$(xbb_get_toolchain_library_path "${CXX}")"

      # -L required, there is no -rpath-link like on Linux.
      LDFLAGS+=" $(xbb_expand_linker_library_paths "${toolchain_library_path}")"
      LDXXFLAGS+=" $(xbb_expand_linker_library_paths "${toolchain_library_path}")"

      LDFLAGS+=" $(xbb_expand_linker_rpaths "${toolchain_library_path}")"
      LDXXFLAGS+=" $(xbb_expand_linker_rpaths "${toolchain_library_path}")"

      export LDFLAGS
      export LDXXFLAGS

      echo
      echo "LDFLAGS=${LDFLAGS}"

      test_compiler_c_cpp
      test_compiler_c_cpp --gc
      test_compiler_c_cpp --lto
      test_compiler_c_cpp --gc --lto
    )

    if is_variable_set "F90"
    then
      (
        # The shared libraries are in a custom location and require setting
        # the libraries and rpath explicitly.

        local toolchain_library_path="$(xbb_get_toolchain_library_path "${F90}")"

        LDFLAGS+=" $(xbb_expand_linker_library_paths "${toolchain_library_path}")"
        LDFLAGS+=" $(xbb_expand_linker_rpaths "${toolchain_library_path}")"

        export LDFLAGS

        echo
        echo "LDFLAGS=${LDFLAGS}"

        test_compiler_fortran
      )
    else
      echo
      echo "Skipping Fortran tests, compiler not available..."
    fi

    # ---------------------------------------------------------------------

    # Again, with -static-libstdc++
    test_compiler_c_cpp --static-lib
    test_compiler_c_cpp --gc --static-lib
    test_compiler_c_cpp --lto --static-lib
    test_compiler_c_cpp --gc --lto --static-lib

    # ---------------------------------------------------------------------

    echo
    echo "Skipping all --static on macOS..."
  )
}

# -----------------------------------------------------------------------------
