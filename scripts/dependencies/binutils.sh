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

# https://github.com/archlinux/svntogit-packages/blob/packages/binutils/trunk/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/binutils/files/PKGBUILD
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gdb-git

# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-binutils
# https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-binutils/PKGBUILD

# mingw-w64
# https://github.com/archlinux/svntogit-community/blob/packages/mingw-w64-binutils/trunk/PKGBUILD

# https://github.com/msys2/MSYS2-packages/blob/master/binutils/PKGBUILD

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/binutils.rb


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
# 2022-02-09, "2.38"
# 2022-08-05, "2.39"

# -----------------------------------------------------------------------------

# triplet
# program_prefix
function prepare_binutils_common_options()
{
  config_options=()

  config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

  config_options+=("--infodir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/info")
  config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")
  config_options+=("--htmldir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/html")
  config_options+=("--pdfdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/pdf")

  config_options+=("--build=${XBB_BUILD_TRIPLET}")
  config_options+=("--host=${XBB_HOST_TRIPLET}")
  config_options+=("--target=${triplet}") # Arch, HB

  config_options+=("--program-prefix=${program_prefix}")
  config_options+=("--program-suffix=")

  config_options+=("--with-pkgversion=${XBB_BINUTILS_BRANDING}")

  # config_options+=("--with-lib-path=/usr/lib:/usr/local/lib")
  config_options+=("--with-sysroot=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

  if [ "${XBB_HOST_PLATFORM}" != "linux" ]
  then
    config_options+=("--with-libiconv-prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
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
    # config_options+=("--enable-pgo-build=lto")
    :

  else
    echo "Unsupported XBB_HOST_PLATFORM=${XBB_HOST_PLATFORM} in ${FUNCNAME[0]}()"
    exit 1
  fi

  config_options+=("--enable-64-bit-bfd") # HB
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
    config_options+=("--disable-multilib") # Arch, HB
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
  config_options+=("--enable-shared") # Arch
  config_options+=("--enable-static")

  if [ ! -z "${triplet}" ]
  then
    config_options+=("--enable-targets=${triplet}") # HB
  else
    config_options+=("--enable-targets=all") # HB
  fi

  config_options+=("--enable-threads") # Arch

  config_options+=("--disable-debug") # HB
  config_options+=("--disable-dependency-tracking") # HB
  if [ "${XBB_IS_DEVELOP}" == "y" ]
  then
    config_options+=("--disable-silent-rules")
  fi

  config_options+=("--disable-gdb") # Arch
  config_options+=("--disable-gdbserver") # Arch
  config_options+=("--disable-libdecnumber") # Arch

  config_options+=("--disable-new-dtags")
  config_options+=("--disable-nls") # HB

  config_options+=("--disable-readline") # Arch
  config_options+=("--disable-sim") # Arch
  config_options+=("--disable-werror") # Arch, HB
}

# binutils should not be used on Darwin, the build is ok, but
# there are functional issues, due to the different ld/as/etc.

function build_binutils()
{
  local binutils_version="$1"
  shift

  local triplet="${XBB_TARGET_TRIPLET}" # "x86_64-w64-mingw32"
  local name_prefix=""
  local program_prefix=""
  local has_program_prefix="n"

  while [ $# -gt 0 ]
  do
    case "$1" in
      --triplet=* )
        triplet=$(xbb_parse_option "$1")
        name_prefix="${triplet}-"
        ;;

      --program-prefix=* )
        program_prefix=$(xbb_parse_option "$1")
        has_program_prefix="y"
        ;;

      * )
        echo "Unsupported argument $1 in ${FUNCNAME[0]}()"
        exit 1
        ;;
    esac
    shift
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
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${binutils_url}" "${binutils_archive}" \
      "${binutils_src_folder_name}" "${binutils_patch_file_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${binutils_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${binutils_folder_name}"

      # To access the newly compiled libraries.
      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      # LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC}"
      LDFLAGS="${XBB_LDFLAGS_APP}"
      xbb_adjust_ldflags_rpath

      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        # Used to enable wildcard; inspired from arm-none-eabi-gcc.
        LDFLAGS+=" -Wl,${XBB_NATIVE_DEPENDENCIES_INSTALL_FOLDER_PATH}/${XBB_TARGET_TRIPLET}/lib/CRT_glob.o"
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
          echo "Running ${name_prefix}binutils configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/configure" --help

            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/binutils/configure" --help
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/bfd/configure" --help
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/gas/configure" --help
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/ld/configure" --help
          fi

          prepare_binutils_common_options

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
          : # run_verbose make check
        fi

        # Avoid strip here, it may interfere with patchelf.
        # make install-strip
        run_verbose make install

        if [ -f "libiberty/pic/libiberty.a" ]
        then
          # install PIC version of libiberty
          libiberty_file_path="$(find "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}" -name libiberty.a)"
          if [ -n "${libiberty_file_path}" ]
          then
            run_verbose ${INSTALL} -v -c -m 644 libiberty/pic/libiberty.a \
              "$(dirname ${libiberty_file_path})"
          fi
        fi

        run_verbose rm -rf "${XBB_BUILD_FOLDER_PATH}/${binutils_folder_name}/doc"

        test_binutils_libs

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

  tests_add "test_binutils" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin" "${name_prefix}"
}

function test_binutils_libs()
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
}

function test_binutils()
{
  local test_bin_path="$1"
  local name_prefix="${2:-""}"

  (
    echo
    echo "Checking the ${name_prefix}binutils shared libraries..."

    show_host_libs "${test_bin_path}/${name_prefix}ar"
    show_host_libs "${test_bin_path}/${name_prefix}as"
    show_host_libs "${test_bin_path}/${name_prefix}elfedit"
    show_host_libs "${test_bin_path}/${name_prefix}gprof"
    show_host_libs "${test_bin_path}/${name_prefix}ld"
    if [ -f  "${test_bin_path}/${name_prefix}ld.gold${XBB_HOST_DOT_EXE}" ]
    then
      # No ld.gold on Windows.
      show_host_libs "${test_bin_path}/${name_prefix}ld.gold"
    fi
    show_host_libs "${test_bin_path}/${name_prefix}nm"
    show_host_libs "${test_bin_path}/${name_prefix}objcopy"
    show_host_libs "${test_bin_path}/${name_prefix}objdump"
    show_host_libs "${test_bin_path}/${name_prefix}ranlib"
    show_host_libs "${test_bin_path}/${name_prefix}readelf"
    show_host_libs "${test_bin_path}/${name_prefix}size"
    show_host_libs "${test_bin_path}/${name_prefix}strings"
    show_host_libs "${test_bin_path}/${name_prefix}strip"

    echo
    echo "Testing if ${name_prefix}binutils start properly..."

    run_host_app_verbose "${test_bin_path}/${name_prefix}ar" --version
    run_host_app_verbose "${test_bin_path}/${name_prefix}as" --version
    run_host_app_verbose "${test_bin_path}/${name_prefix}elfedit" --version
    run_host_app_verbose "${test_bin_path}/${name_prefix}gprof" --version
    run_host_app_verbose "${test_bin_path}/${name_prefix}ld" --version
    if [ -f  "${test_bin_path}/${name_prefix}ld.gold${XBB_HOST_DOT_EXE}" ]
    then
      # No ld.gold on Windows.
      run_host_app_verbose "${test_bin_path}/${name_prefix}ld.gold" --version
    fi
    run_host_app_verbose "${test_bin_path}/${name_prefix}nm" --version
    run_host_app_verbose "${test_bin_path}/${name_prefix}objcopy" --version
    run_host_app_verbose "${test_bin_path}/${name_prefix}objdump" --version
    run_host_app_verbose "${test_bin_path}/${name_prefix}ranlib" --version
    run_host_app_verbose "${test_bin_path}/${name_prefix}readelf" --version
    run_host_app_verbose "${test_bin_path}/${name_prefix}size" --version
    run_host_app_verbose "${test_bin_path}/${name_prefix}strings" --version
    run_host_app_verbose "${test_bin_path}/${name_prefix}strip" --version

    echo
    echo "Testing if ${name_prefix}binutils binaries display help..."

    run_host_app_verbose "${test_bin_path}/${name_prefix}ar" --help
    run_host_app_verbose "${test_bin_path}/${name_prefix}as" --help
    run_host_app_verbose "${test_bin_path}/${name_prefix}elfedit" --help
    run_host_app_verbose "${test_bin_path}/${name_prefix}gprof" --help
    run_host_app_verbose "${test_bin_path}/${name_prefix}ld" --help
    if [ -f  "${test_bin_path}/${name_prefix}ld.gold${XBB_HOST_DOT_EXE}" ]
    then
      # No ld.gold on Windows.
      run_host_app_verbose "${test_bin_path}/${name_prefix}ld.gold" --help
    fi
    run_host_app_verbose "${test_bin_path}/${name_prefix}nm" --help
    run_host_app_verbose "${test_bin_path}/${name_prefix}objcopy" --help
    run_host_app_verbose "${test_bin_path}/${name_prefix}objdump" --help
    run_host_app_verbose "${test_bin_path}/${name_prefix}ranlib" --help
    run_host_app_verbose "${test_bin_path}/${name_prefix}readelf" --help
    run_host_app_verbose "${test_bin_path}/${name_prefix}size" --help
    run_host_app_verbose "${test_bin_path}/${name_prefix}strings" --help
    run_host_app_verbose "${test_bin_path}/${name_prefix}strip" --help || true
  )
}

# -----------------------------------------------------------------------------

function build_binutils_ld_gold()
{
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
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${binutils_url}" "${binutils_archive}" \
      "${binutils_src_folder_name}" "${binutils_patch_file_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${binutils_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${binutils_folder_name}"

      # To access the newly compiled libraries.
      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      # LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC}"
      LDFLAGS="${XBB_LDFLAGS_APP}"
      xbb_adjust_ldflags_rpath

      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        if [ "${XBB_TARGET_ARCH}" == "x32" -o "${XBB_TARGET_ARCH}" == "ia32" ]
        then
          # From MSYS2 MINGW
          LDFLAGS+=" -Wl,--large-address-aware"
        fi

        # Used to enable wildcard; inspired from arm-none-eabi-gcc.
        LDFLAGS+=" -Wl,${XBB_NATIVE_DEPENDENCIES_INSTALL_FOLDER_PATH}/${XBB_TARGET_TRIPLET}/lib/CRT_glob.o"
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
          echo "Running binutils-ld.gold configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
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

          prepare_binutils_common_options

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

  tests_add "test_binutils_ld_gold" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function test_binutils_ld_gold()
{
  local test_bin_path="$1"

  show_host_libs "${test_bin_path}/ld.gold"

  echo
  echo "Testing if binutils ld.gold starts properly..."

  run_host_app_verbose "${test_bin_path}/ld.gold" --version
}

# -----------------------------------------------------------------------------
