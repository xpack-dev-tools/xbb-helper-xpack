#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.gnu.org/software/binutils/
# https://ftp.gnu.org/gnu/binutils/

# https://gitlab.archlinux.org/archlinux/packaging/packages/binutils/-/blob/main/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/binutils/files/PKGBUILD
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gdb-git

# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-binutils
# https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-binutils/PKGBUILD

# mingw-w64
# https://gitlab.archlinux.org/archlinux/packaging/packages/mingw-w64-binutils/-/blob/main/PKGBUILD

# MSYS2
# https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-binutils/PKGBUILD
# https://github.com/msys2/MSYS2-packages/blob/master/binutils/PKGBUILD

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/b/binutils.rb
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/m/mingw-w64.rb


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
# 2022-02-09, "2.38" - ! dlltool bug, fixed in 2.39
# 2022-08-05, "2.39"

# -----------------------------------------------------------------------------

# triplet
# program_prefix
function binutils_prepare_common_options()
{
  local triplet="$1"
  local has_triplet="${2:-""}"

  config_options=()

  config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

  if [ "${has_triplet}" == "y" ]
  then
    config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/${triplet}/lib")
    config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/${triplet}/include")
  else
    config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
    config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
  fi
  # Remove ansidecl.h!

  # config_options+=("--with-lib-path=/usr/lib:/usr/local/lib")

  config_options+=("--infodir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/info")
  config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")
  config_options+=("--htmldir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/html")
  config_options+=("--pdfdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/pdf")

  config_options+=("--build=${XBB_BUILD_TRIPLET}")
  config_options+=("--host=${XBB_HOST_TRIPLET}")
  config_options+=("--target=${triplet}") # Arch, HB, HB mingw

  config_options+=("--program-prefix=${program_prefix}")
  config_options+=("--program-suffix=")

  config_options+=("--with-pkgversion=${XBB_BINUTILS_BRANDING}")

  if [ "${XBB_HOST_PLATFORM}" != "linux" ]
  then
    config_options+=("--with-libiconv-prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
    config_options+=("--with-sysroot=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}") # HB mingw
  fi

  # Use the zlib compiled from sources.
  config_options+=("--with-system-zlib") # Arch, HB

  config_options+=("--with-pic") # Arch

  # error: debuginfod is missing or unusable
  # config_options+=("--with-debuginfod") # Arch
  config_options+=("--without-debuginfod")

  if [ "${XBB_HOST_PLATFORM}" == "win32" ]
  then

    config_options+=("--enable-ld")

  elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
  then

    if [ -z "${triplet}" ]
    then
      config_options+=("--enable-pgo-build=lto") # Arch
    fi

    config_options+=("--enable-ld=default") # Arch

    # config_options+=("--enable-targets=x86_64-pep,bpf-unknown-none")

  elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
  then

    # Not supported by clang.
    :

  else
    echo "Unsupported XBB_HOST_PLATFORM=${XBB_HOST_PLATFORM} in ${FUNCNAME[0]}()"
    exit 1
  fi

  if [ "${triplet}" != "i686-w64-mingw32" ]
  then
    config_options+=("--enable-64-bit-bfd") # HB, mingw
  fi
  config_options+=("--enable-build-warnings=no")
  config_options+=("--enable-cet") # Arch
  config_options+=("--enable-default-execstack=no") # Arch
  config_options+=("--enable-deterministic-archives") # Arch, HB
  config_options+=("--enable-gold") # Arch, HB
  config_options+=("--enable-install-libiberty") # Arch
  config_options+=("--enable-interwork") # HB
  # config_options+=("--enable-jansson") # Arch
  config_options+=("--enable-libssp")
  config_options+=("--enable-lto")

  if [ ! -z "${triplet}" ]
  then
    # The mingw binaries have architecture specific names,
    # so multilib makes no sense.
    config_options+=("--disable-multilib") # Arch, HB, HB mingw
  else
    if [ "${XBB_HOST_PLATFORM}" == "linux" -a "${XBB_HOST_ARCH}" == "x64" ]
    then
      # Only Intel Linux supports multilib.
      config_options+=("--enable-multilib") # HB
    else
      # All other platforms do not.
      config_options+=("--disable-multilib")
    fi
  fi

  config_options+=("--enable-plugins") # Arch, HB
  config_options+=("--enable-relro") # Arch

  if [ "${has_triplet}" == "y" ]
  then
    # To avoid the libexec dilema for mingw which has two variants.
    config_options+=("--disable-shared")
  elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
  then
    :
  else
    config_options+=("--enable-shared") # Arch
  fi
  config_options+=("--enable-static")

  if [ ! -z "${triplet}" ]
  then
    config_options+=("--enable-targets=${triplet}") # HB, HB mingw
  else
    config_options+=("--enable-targets=all") # HB
  fi

  config_options+=("--enable-threads") # Arch

  config_options+=("--disable-debug") # HB
  config_options+=("--disable-dependency-tracking") # HB
  if is_develop
  then
    config_options+=("--disable-silent-rules")
  fi

  config_options+=("--disable-gdb") # Arch
  config_options+=("--disable-gdbserver") # Arch
  config_options+=("--disable-libdecnumber") # Arch

  config_options+=("--disable-new-dtags")
  config_options+=("--disable-nls") # HB, HB mingw

  config_options+=("--disable-readline") # Arch
  config_options+=("--disable-sim") # Arch
  config_options+=("--disable-werror") # Arch, HB
}

# binutils should not be used on Darwin, the build is ok, but
# there are functional issues, due to the different ld/as/etc.

function binutils_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local binutils_version="$1"
  shift

  local triplet="${XBB_TARGET_TRIPLET}" # "x86_64-w64-mingw32"
  local name_prefix=""
  local program_prefix=""

  # triplet and prefix are passed only from gcc-mingw.sh.
  local has_triplet="n"
  local has_program_prefix="n"

  while [ $# -gt 0 ]
  do
    case "$1" in
      --triplet=* )
        triplet=$(xbb_parse_option "$1")
        name_prefix="${triplet}-"
        has_triplet="y"
        shift
        ;;

      --program-prefix=* )
        program_prefix=$(xbb_parse_option "$1")
        has_program_prefix="y"
        shift
        ;;

      * )
        echo "Unsupported argument $1 in ${FUNCNAME[0]}()"
        exit 1
        ;;
    esac
  done

  if [ "${has_program_prefix}" == "y" ]
  then
    # The explicit program prefix takes precendence on the triplet.
    name_prefix="${program_prefix}"
  fi

  local binutils_src_folder_name="binutils-${binutils_version}"
  local binutils_folder_name="${name_prefix}binutils-${binutils_version}"

  local binutils_archive="${binutils_src_folder_name}.tar.xz"
  local binutils_url="https://ftp.gnu.org/gnu/binutils/${binutils_archive}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${binutils_folder_name}"

  local binutils_patch_file_name="binutils-${binutils_version}.patch"
  local binutils_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${binutils_folder_name}-installed"
  if [ ! -f "${binutils_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${binutils_url}" "${binutils_archive}" \
      "${binutils_src_folder_name}" "${binutils_patch_file_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${binutils_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${binutils_folder_name}"

      local libraries_path="${XBB_LIBRARIES_INSTALL_FOLDER_PATH}"

      if [ "${XBB_HOST_PLATFORM}" == "linux" ]
      then
        # Trick!
        # Be sure that the local libraries are prefered to compiler libraries.
        # The build script adds the local folder at the end of the rpath,
        # which is too late.
        if [ "${has_triplet}" == "y" ]
        then
          libraries_path="${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/${triplet}"
        fi
      fi

      # To access the newly compiled libraries.
      xbb_activate_dependencies_dev "${libraries_path}"

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        # Reduce the risk of messing bootstrap libraries.
        # LDFLAGS+=" ${XBB_LDFLAGS_STATIC_LIBS}"

        # Used to enable wildcard; inspired by arm-none-eabi-gcc.
        local crt_clob_file_path="$(${CC} --print-file-name=CRT_glob.o)"
        LDFLAGS+=" -Wl,${crt_clob_file_path}"
      fi

      xbb_adjust_ldflags_rpath "${libraries_path}/lib"

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running ${name_prefix}binutils configure..."

          if is_develop
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/configure" --help

            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/binutils/configure" --help
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/bfd/configure" --help
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/gas/configure" --help
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/ld/configure" --help
          fi

          binutils_prepare_common_options "${triplet}" "${has_triplet}"

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/configure" \
            ${config_options[@]}

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${binutils_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${binutils_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running ${name_prefix}binutils make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          (
            export LD_LIBRARY_PATH="$(xbb_get_toolchain_library_path "${CXX}")"
            echo
            echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"

            if [ "${XBB_HOST_ARCH}" == "x64" ]
            then
              run_verbose make CFLAGS_FOR_TARGET="-O2 -g" \
              CXXFLAGS="-O2 -no-pie -fno-PIC" \
              CFLAGS="-O2 -no-pie" \
              LDFLAGS="" \
              check
            else
              if is_develop
              then
                # TODO: investigate why tests on Arm fail.
                run_verbose make CFLAGS_FOR_TARGET="-O2 -g" \
                CXXFLAGS="-O2 -no-pie -fno-PIC" \
                CFLAGS="-O2 -no-pie" \
                LDFLAGS="" \
                check || true
              fi
            fi
          )
        fi

        # Avoid strip here, it may interfere with patchelf.
        # make install-strip
        run_verbose make install

        run_verbose rm -rf "${XBB_BUILD_FOLDER_PATH}/${binutils_folder_name}/doc"

        if [ "${has_triplet}" != "y" ]
        then
          # /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-12.3.0/libiberty/objalloc.c:95:18: error: 'PTR' undeclared (first use in this function)
          #    95 |   ret->chunks = (PTR) malloc (CHUNK_SIZE);
          # or
          # /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/install/include/ansidecl.h:282:56: note: in expansion of macro 'warn_unused_result'
          #   282 | #  define ATTRIBUTE_WARN_UNUSED_RESULT __attribute__ ((warn_unused_result))

          run_verbose rm -rf "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/ansidecl.h"
        fi

        binutils_test_libs

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${binutils_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}" \
        "binutils-${binutils_version}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${binutils_stamp_file_path}"

  else
    echo "Component ${name_prefix}binutils already installed"
  fi

  tests_add "binutils_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin" "${name_prefix}"
}

function binutils_test_libs()
{
  show_host_libs "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${name_prefix}ar"
  show_host_libs "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${name_prefix}as"
  show_host_libs "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${name_prefix}ld"
  show_host_libs "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${name_prefix}nm"
  show_host_libs "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${name_prefix}objcopy"
  show_host_libs "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${name_prefix}objdump"
  show_host_libs "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${name_prefix}ranlib"
  show_host_libs "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${name_prefix}size"
  show_host_libs "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${name_prefix}strings"
  show_host_libs "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${name_prefix}strip"

  # On wine if fails; not so important, test only on Linux & macOS.
  if [ "${XBB_HOST_PLATFORM}" != "win32" ]
  then
    # Run test added because on arm 32-bit it happened to fail with:
    # /home/ilg/Work/xpack-dev-tools/mingw-w64-gcc-xpack.git/build/linux-arm/application/lib/gcc/x86_64-w64-mingw32/12.3.0/../../../../x86_64-w64-mingw32/bin/as: error while loading shared libraries: /home/ilg/Work/xpack-dev-tools/mingw-w64-gcc-xpack.git/build/linux-arm/application/armv7l-unknown-linux-gnueabihf/x86_64-w64-mingw32/lib/libbfd-2.41.so: unexpected reloc type 0x03

    echo
    echo "Testing if ${name_prefix}binutils start properly..."

    run_host_app_verbose "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${name_prefix}ar" --version
    run_host_app_verbose "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${name_prefix}as" --version
    run_host_app_verbose "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${name_prefix}ld" --version
    run_host_app_verbose "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${name_prefix}nm" --version
    run_host_app_verbose "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${name_prefix}objcopy" --version
    run_host_app_verbose "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${name_prefix}objdump" --version
    run_host_app_verbose "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${name_prefix}ranlib" --version
    run_host_app_verbose "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${name_prefix}size" --version
    run_host_app_verbose "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${name_prefix}strings" --version
    run_host_app_verbose "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/${name_prefix}strip" --version
  fi
}

function binutils_test()
{
  local test_bin_path="$1"
  local name_prefix="${2:-""}"

  (
    if [ "${XBB_TEST_SYSTEM_TOOLS:-""}" == "y" ]
    then
      export AR="$(which ${name_prefix}ar)"
      export AS="$(which ${name_prefix}as)"
      export ELFEDIT="$(which ${name_prefix}elfedit)"
      export GPROF="$(which ${name_prefix}gprof)"
      export LD="$(which ${name_prefix}ld)"
      export LD_GOLD="$(which ${name_prefix}ld.gold)"
      export NM="$(which ${name_prefix}nm)"
      export OBJCOPY="$(which ${name_prefix}objcopy)"
      export OBJDUMP="$(which ${name_prefix}objdump)"
      export RANLIB="$(which ${name_prefix}ranlib)"
      export READELF="$(which ${name_prefix}readelf)"
      export SIZE="$(which ${name_prefix}size)"
      export STRINGS="$(which ${name_prefix}strings)"
      export STRIP="$(which ${name_prefix}strip)"
    else
      export AR="${test_bin_path}/${name_prefix}ar"
      export AS="${test_bin_path}/${name_prefix}as"
      export ELFEDIT="${test_bin_path}/${name_prefix}elfedit"
      export GPROF="${test_bin_path}/${name_prefix}gprof"
      export LD="${test_bin_path}/${name_prefix}ld"
      export LD_GOLD="${test_bin_path}/${name_prefix}ld.gold"
      export NM="${test_bin_path}/${name_prefix}nm"
      export OBJCOPY="${test_bin_path}/${name_prefix}objcopy"
      export OBJDUMP="${test_bin_path}/${name_prefix}objdump"
      export RANLIB="${test_bin_path}/${name_prefix}ranlib"
      export READELF="${test_bin_path}/${name_prefix}readelf"
      export SIZE="${test_bin_path}/${name_prefix}size"
      export STRINGS="${test_bin_path}/${name_prefix}strings"
      export STRIP="${test_bin_path}/${name_prefix}strip"
    fi

    if [ "${XBB_BUILD_PLATFORM}" != "win32" ]
    then
      echo
      echo "Checking the ${name_prefix}binutils shared libraries..."

      show_host_libs "${AR}"
      show_host_libs "${AS}"
      show_host_libs "${ELFEDIT}"
      show_host_libs "${GPROF}"
      show_host_libs "${LD}"
      if [ -f  "${LD_GOLD}${XBB_HOST_DOT_EXE}" ]
      then
        # No ld.gold on Windows.
        show_host_libs "${LD_GOLD}"
      fi
      show_host_libs "${NM}"
      show_host_libs "${OBJCOPY}"
      show_host_libs "${OBJDUMP}"
      show_host_libs "${RANLIB}"
      show_host_libs "${READELF}"
      show_host_libs "${SIZE}"
      show_host_libs "${STRINGS}"
      show_host_libs "${STRIP}"
    fi

    echo
    echo "Testing if ${name_prefix}binutils start properly..."

    run_host_app_verbose "${AR}" --version
    run_host_app_verbose "${AS}" --version
    run_host_app_verbose "${ELFEDIT}" --version
    run_host_app_verbose "${GPROF}" --version
    run_host_app_verbose "${LD}" --version
    if [ -f  "${LD_GOLD}${XBB_HOST_DOT_EXE}" ]
    then
      # No ld.gold on Windows.
      run_host_app_verbose "${LD_GOLD}" --version
    fi
    run_host_app_verbose "${NM}" --version
    run_host_app_verbose "${OBJCOPY}" --version
    run_host_app_verbose "${OBJDUMP}" --version
    run_host_app_verbose "${RANLIB}" --version
    run_host_app_verbose "${READELF}" --version
    run_host_app_verbose "${SIZE}" --version
    run_host_app_verbose "${STRINGS}" --version
    run_host_app_verbose "${STRIP}" --version

    echo
    echo "Testing if ${name_prefix}binutils binaries display help..."

    run_host_app_verbose "${AR}" --help
    run_host_app_verbose "${AS}" --help
    run_host_app_verbose "${ELFEDIT}" --help
    run_host_app_verbose "${GPROF}" --help
    run_host_app_verbose "${LD}" --help
    if [ "${LD_GOLD}${XBB_HOST_DOT_EXE}" ]
    then
      # No ld.gold on Windows.
      run_host_app_verbose "${LD_GOLD}" --help
    fi
    run_host_app_verbose "${NM}" --help
    run_host_app_verbose "${OBJCOPY}" --help
    run_host_app_verbose "${OBJDUMP}" --help
    run_host_app_verbose "${RANLIB}" --help
    run_host_app_verbose "${READELF}" --help
    run_host_app_verbose "${SIZE}" --help
    run_host_app_verbose "${STRINGS}" --help
    run_host_app_verbose "${STRIP}" --help || true
  )
}

# -----------------------------------------------------------------------------

function binutils_build_ld_gold()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local binutils_version="$1"

  local binutils_src_folder_name="binutils-${binutils_version}"

  local binutils_archive="${binutils_src_folder_name}.tar.xz"
  local binutils_url="https://ftp.gnu.org/gnu/binutils/${binutils_archive}"

  local binutils_folder_name="binutils-ld.gold-${binutils_version}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${binutils_folder_name}"

  local binutils_patch_file_name="binutils-${binutils_version}.patch"
  local binutils_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${binutils_folder_name}-installed"
  if [ ! -f "${binutils_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${binutils_url}" "${binutils_archive}" \
      "${binutils_src_folder_name}" "${binutils_patch_file_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${binutils_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${binutils_folder_name}"

      # To access the newly compiled libraries.
      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      if [ "${XBB_HOST_PLATFORM}" == "linux" ]
      then
        # Trick!
        # Be sure that the local libraries are prefered to compiler libraries.
        # The build script adds the local folder at the end of the rpath,
        # which is too late.
        if is_native
        then
          # mkdir -pv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib"
          XBB_LIBRARY_PATH="${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib:${XBB_LIBRARY_PATH}"
        elif [ "${has_program_prefix}" == "y" ]
        then
          # The `application/lib` must be also added before the toolchain path,
          # since the libctf*.so is located here, and there might be another one
          # in the toolchain path.
          # mkdir -pv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/${XBB_HOST_TRIPLET}/${triplet}/lib"
          # mkdir -pv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib"
          XBB_LIBRARY_PATH="${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/${XBB_HOST_TRIPLET}/${triplet}/lib:${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib:${XBB_LIBRARY_PATH}"
        elif is_cross
        then
          :
        else
          echo "TODO in ${FUNCNAME[0]} $@"
          exit 1
        fi
        echo_develop "XBB_LIBRARY_PATH=${XBB_LIBRARY_PATH}"
      fi

      LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        if [ "${XBB_TARGET_ARCH}" == "x32" -o "${XBB_TARGET_ARCH}" == "ia32" ]
        then
          # From MSYS2 MINGW
          LDFLAGS+=" -Wl,--large-address-aware"
        fi

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
          echo "Running binutils-ld.gold configure..."

          if is_develop
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/configure" --help
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/ld/configure" --help
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/bfd/configure" --help
          fi

          local triplet="${XBB_TARGET_TRIPLET}"
          local program_prefix=""

          # Linux
          #  config_options+=("--disable-shared")
          #  config_options+=("--disable-shared-libgcc")

          binutils_prepare_common_options "${triplet}"

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${binutils_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${binutils_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running binutils-ld.gold make..."

        # Build.
        run_verbose make -j ${XBB_JOBS} all-gold

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          # gcctestdir/collect-ld: relocation error: gcctestdir/collect-ld: symbol _ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm, version GLIBCXX_3.4.21 not defined in file libstdc++.so.6 with link time reference
          : # make maybe-check-gold
        fi

        # Avoid strip here, it may interfere with patchelf.
        # make install-strip
        run_verbose make maybe-install-gold

        # Remove the separate folder, the xPack distribution is single target.
        rm -rf "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/${XBB_BUILD_TRIPLET}"

        if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
        then
          : # rm -rv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/strip"
        fi

        show_host_libs "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/ld.gold"

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${binutils_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}" \
        "${binutils_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${binutils_stamp_file_path}"

  else
    echo "Component binutils ld.gold already installed"
  fi

  tests_add "binutils_test_ld_gold" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function binutils_test_ld_gold()
{
  local test_bin_path="$1"

  show_host_libs "${test_bin_path}/ld.gold"

  echo
  echo "Testing if binutils ld.gold starts properly..."

  run_host_app_verbose "${test_bin_path}/ld.gold" --version
}

# -----------------------------------------------------------------------------
