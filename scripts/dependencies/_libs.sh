# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# Helper script used in the xPack build scripts. As the name implies,
# it should contain only functions and should be included with 'source'
# by the build scripts (both native and container).


# -----------------------------------------------------------------------------

function build_gmp()
{
  # https://gmplib.org
  # https://gmplib.org/download/gmp/

  # https://github.com/archlinux/svntogit-packages/blob/packages/gmp/trunk/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/gmp/files/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/gmp.rb

  # 01-Nov-2015 "6.1.0"
  # 16-Dec-2016 "6.1.2"
  # 17-Jan-2020 "6.2.0"
  # 14-Nov-2020, "6.2.1"

  local gmp_version="$1"
  local name_suffix=${2-''}

  # The folder name as resulted after being extracted from the archive.
  local gmp_src_folder_name="gmp-${gmp_version}"

  local gmp_archive="${gmp_src_folder_name}.tar.xz"
  local gmp_url="https://gmplib.org/download/gmp/${gmp_archive}"

  # The folder name for build, licenses, etc.
  local gmp_folder_name="${gmp_src_folder_name}${name_suffix}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${gmp_folder_name}"

  local gmp_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${gmp_folder_name}-installed"
  if [ ! -f "${gmp_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${gmp_url}" "${gmp_archive}" \
      "${gmp_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${gmp_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${gmp_folder_name}"

      if [ "${name_suffix}" == "-bootstrap" ]
      then

        CPPFLAGS="${XBB_CPPFLAGS}"
        CFLAGS="${XBB_CFLAGS_NO_W}"
        CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

        LDFLAGS="${XBB_LDFLAGS_LIB}"

      else

        xbb_activate_installed_dev

        # Exceptions used by Arm GCC script and by mingw-w64.
        CPPFLAGS="${XBB_CPPFLAGS} -fexceptions"
        # Test fail with -Ofast, revert to -O2
        CFLAGS="${XBB_CFLAGS_NO_W}"
        CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

        LDFLAGS="${XBB_LDFLAGS_LIB}"
        if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
        then
          LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
        fi

        if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
        then
          export CC_FOR_BUILD="${XBB_NATIVE_CC}"
        fi

      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      # ABI is mandatory, otherwise configure fails on 32-bit.
      # (see https://gmplib.org/manual/ABI-and-ISA.html)
      if [ "${XBB_TARGET_ARCH}" == "x64" -o "${XBB_TARGET_ARCH}" == "x32" -o "${XBB_TARGET_ARCH}" == "ia32" ]
      then
        export ABI="${XBB_TARGET_BITS}"
      fi

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running gmp${name_suffix} configure..."

          # ABI is mandatory, otherwise configure fails on 32-bit.
          # (see https://gmplib.org/manual/ABI-and-ISA.html)

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${gmp_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/share/man")

          if [ "${name_suffix}" == "-bootstrap" ]
          then

            config_options+=("--build=${XBB_BUILD}")
            config_options+=("--host=${XBB_BUILD}")
            config_options+=("--target=${XBB_BUILD}")

          else

            config_options+=("--build=${XBB_BUILD}")
            config_options+=("--host=${XBB_HOST}")
            config_options+=("--target=${XBB_TARGET}")

            config_options+=("--enable-cxx")
            config_options+=("--enable-fat") # Arch

            # From Arm.
            config_options+=("--enable-fft")

            if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
            then
              # mpfr asks for this explicitly during configure.
              # (although the message is confusing)
              config_options+=("--enable-shared")
              config_options+=("--disable-static")
            elif [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
            then
              # Enable --with-pic to avoid linking issues with the static library
              config_options+=("--with-pic") # HB
            fi

            if [ "${XBB_TARGET_ARCH}" == "ia32" -o "${XBB_TARGET_ARCH}" == "arm" ]
            then
              config_options+=("ABI=32")
            fi

          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${gmp_src_folder_name}/configure" \
            "${config_options[@]}"

          if false # [ "${XBB_TARGET_PLATFORM}" == "darwin" ] # and clang
          then
            # Disable failing `t-sqrlo` test.
            run_verbose sed -i.bak \
              -e 's| t-sqrlo$(EXEEXT) | |' \
              "tests/mpn/Makefile"
          fi

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${gmp_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gmp_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running gmp${name_suffix} make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          if [ "${XBB_TARGET_PLATFORM}" == "darwin" -a "${XBB_TARGET_ARCH}" == "arm64" ]
          then
            # FAIL: t-rand
            :
          else
            run_verbose make -j1 check
          fi
        fi

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        if [ "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}" != "${XBB_BINARIES_INSTALL_FOLDER_PATH}" ]
        then
          if [ -f "${XBB_BINARIES_INSTALL_FOLDER_PATH}/include/gmp.h" ]
          then
            # For unknow reasons, this file is stored in the wrong location.
            mkdir -pv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include"
            mv -fv "${XBB_BINARIES_INSTALL_FOLDER_PATH}/include/gmp.h" \
              "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include"
          fi
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gmp_folder_name}/make-output-$(ndate).txt"

      if [ -z "${name_suffix}" ]
      then
        copy_license \
          "${XBB_SOURCES_FOLDER_PATH}/${gmp_src_folder_name}" \
          "${gmp_folder_name}"
      fi

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${gmp_stamp_file_path}"

  else
    echo "Library gmp${name_suffix} already installed."
  fi
}

# Depends on gmp.
function build_mpfr()
{
  # http://www.mpfr.org
  # http://www.mpfr.org/history.html

  # https://github.com/archlinux/svntogit-packages/blob/packages/mpfr/trunk/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/mpfr/files/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/mpfr.rb

  # 6 March 2016 "3.1.4"
  # 7 September 2017 "3.1.6"
  # 31 January 2019 "4.0.2"
  # 10 July 2020 "4.1.0"

  local mpfr_version="$1"
  local name_suffix=${2-''}

  # The folder name as resulted after being extracted from the archive.
  local mpfr_src_folder_name="mpfr-${mpfr_version}"

  local mpfr_archive="${mpfr_src_folder_name}.tar.xz"
  local mpfr_url="http://www.mpfr.org/${mpfr_src_folder_name}/${mpfr_archive}"

  # The folder name for build, licenses, etc.
  local mpfr_folder_name="${mpfr_src_folder_name}${name_suffix}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${mpfr_folder_name}"

  local mpfr_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${mpfr_folder_name}-installed"
  if [ ! -f "${mpfr_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${mpfr_url}" "${mpfr_archive}" \
      "${mpfr_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${mpfr_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${mpfr_folder_name}"

      if [ "${name_suffix}" == "-bootstrap" ]
      then

        CPPFLAGS="${XBB_CPPFLAGS}"
        CFLAGS="${XBB_CFLAGS_NO_W}"
        CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

        LDFLAGS="${XBB_LDFLAGS_LIB}"

      else

        xbb_activate_installed_dev

        CPPFLAGS="${XBB_CPPFLAGS}"
        CFLAGS="${XBB_CFLAGS_NO_W}"
        CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

        LDFLAGS="${XBB_LDFLAGS_LIB}"
        if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
        then
          LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
        fi

      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running mpfr${name_suffix} configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${mpfr_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/share/man")

          if [ "${name_suffix}" == "-bootstrap" ]
          then

            config_options+=("--build=${XBB_BUILD}")
            config_options+=("--host=${XBB_BUILD}")
            config_options+=("--target=${XBB_BUILD}")

          else

            config_options+=("--build=${XBB_BUILD}")
            config_options+=("--host=${XBB_HOST}")
            config_options+=("--target=${XBB_TARGET}")

          fi

          config_options+=("--with-gmp=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}")

          config_options+=("--enable-shared") # Arch
          config_options+=("--enable-thread-safe") # Arch

          config_options+=("--disable-maintainer-mode")
          config_options+=("--disable-warnings")

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${mpfr_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${mpfr_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${mpfr_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running mpfr${name_suffix} make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
          run_verbose make -j1 check-exported-symbols
        fi

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${mpfr_folder_name}/make-output-$(ndate).txt"

      if [ -z "${name_suffix}" ]
      then
        copy_license \
          "${XBB_SOURCES_FOLDER_PATH}/${mpfr_src_folder_name}" \
          "${mpfr_folder_name}"
      fi

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${mpfr_stamp_file_path}"

  else
    echo "Library mpfr${name_suffix} already installed."
  fi
}

# Depends on gmp, mpfr.
function build_mpc()
{
  # http://www.multiprecision.org/
  # ftp://ftp.gnu.org/gnu/mpc

  # https://github.com/archlinux/svntogit-packages/blob/packages/mpc/trunk/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/mpc/files/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/mpc.rb

  # 20 Feb 2015 "1.0.3"
  # 2018-01-11 "1.1.0"
  # 2020-08 "1.2.0"
  # 2020-10 "1.2.1"

  local mpc_version="$1"
  local name_suffix=${2-''}

  # The folder name as resulted after being extracted from the archive.
  local mpc_src_folder_name="mpc-${mpc_version}"

  local mpc_archive="${mpc_src_folder_name}.tar.gz"
  local mpc_url="ftp://ftp.gnu.org/gnu/mpc/${mpc_archive}"
  if [[ ${mpc_version} =~ 0\.* ]]
  then
    mpc_url="http://www.multiprecision.org/downloads/${mpc_archive}"
  fi

  # The folder name for build, licenses, etc.
  local mpc_folder_name="${mpc_src_folder_name}${name_suffix}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${mpc_folder_name}"

  local mpc_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${mpc_folder_name}-installed"
  if [ ! -f "${mpc_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${mpc_url}" "${mpc_archive}" \
      "${mpc_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${mpc_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${mpc_folder_name}"

      if [ "${name_suffix}" == "-bootstrap" ]
      then

        CPPFLAGS="${XBB_CPPFLAGS}"
        CFLAGS="${XBB_CFLAGS_NO_W}"
        CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

        LDFLAGS="${XBB_LDFLAGS_LIB}"

      else

        xbb_activate_installed_dev

        CPPFLAGS="${XBB_CPPFLAGS}"
        CFLAGS="${XBB_CFLAGS_NO_W}"
        CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

        LDFLAGS="${XBB_LDFLAGS_LIB}"
        if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
        then
          LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
        fi

      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running mpc${name_suffix} configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${mpc_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/share/man")

          if [ "${name_suffix}" == "-bootstrap" ]
          then

            config_options+=("--build=${XBB_BUILD}")
            config_options+=("--host=${XBB_BUILD}")
            config_options+=("--target=${XBB_BUILD}")

          else

            config_options+=("--build=${XBB_BUILD}")
            config_options+=("--host=${XBB_HOST}")
            config_options+=("--target=${XBB_TARGET}")

          fi

          config_options+=("--disable-maintainer-mode")

          config_options+=("--with-gmp=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}")
          config_options+=("--with-mpfr=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${mpc_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${mpc_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${mpc_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running mpc${name_suffix} make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${mpc_folder_name}/make-output-$(ndate).txt"

      if [ -z "${name_suffix}" ]
      then
        copy_license \
          "${XBB_SOURCES_FOLDER_PATH}/${mpc_src_folder_name}" \
          "${mpc_folder_name}"
      fi

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${mpc_stamp_file_path}"

  else
    echo "Library mpc${name_suffix} already installed."
  fi
}

# Depends on gmp.
function build_isl()
{
  # http://isl.gforge.inria.fr - deprecated
  # https://sourceforge.net/projects/libisl/files/

  # https://github.com/archlinux/svntogit-packages/blob/packages/libisl/trunk/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/isl.rb

  # 2015-06-12 "0.15"
  # 2016-01-15 "0.16.1"
  # 2016-12-20 "0.18"
  # 2019-03-26 "0.21"
  # 2020-01-16 "0.22"
  # 2020-11-11 "0.23"
  # 2021-05-01 "0.24"
  # 2022-07-02 "0.25"

  local isl_version="$1"
  local name_suffix=${2-''}

  # The folder name as resulted after being extracted from the archive.
  local isl_src_folder_name="isl-${isl_version}"

  local isl_archive="${isl_src_folder_name}.tar.xz"
  if [[ ${isl_version} =~ 0\.1[24]\.* ]]
  then
    isl_archive="${isl_src_folder_name}.tar.gz"
  fi

  local isl_url="https://sourceforge.net/projects/libisl/files/${isl_archive}"

  # The folder name for build, licenses, etc.
  local isl_folder_name="${isl_src_folder_name}${name_suffix}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${isl_folder_name}"

  local isl_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${isl_folder_name}-installed"
  if [ ! -f "${isl_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${isl_url}" "${isl_archive}" \
      "${isl_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${isl_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${isl_folder_name}"

      if [ "${name_suffix}" == "-bootstrap" ]
      then

        # Otherwise `configure: error: gmp.h header not found`.`
        CPPFLAGS="${XBB_CPPFLAGS} -I${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/include"
        CFLAGS="${XBB_CFLAGS_NO_W}"
        CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

        LDFLAGS="${XBB_LDFLAGS_LIB}"

      else

        xbb_activate_installed_dev

        CPPFLAGS="${XBB_CPPFLAGS}"
        CFLAGS="${XBB_CFLAGS_NO_W}"
        CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

        LDFLAGS="${XBB_LDFLAGS_LIB}"
        if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
        then
          LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
        fi

      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running isl${name_suffix} configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${isl_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/share/man")

          if [ "${name_suffix}" == "-bootstrap" ]
          then

            config_options+=("--build=${XBB_BUILD}")
            config_options+=("--host=${XBB_BUILD}")
            config_options+=("--target=${XBB_BUILD}")

          else

            config_options+=("--build=${XBB_BUILD}")
            config_options+=("--host=${XBB_HOST}")
            config_options+=("--target=${XBB_TARGET}")

          fi

          config_options+=("--with-gmp=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}")

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${isl_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${isl_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${isl_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running isl${name_suffix} make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
          then
            # /Host/Users/ilg/Work/gcc-8.4.0-1/linux-x64/build/libs/isl-0.22/.libs/lt-isl_test_cpp: relocation error: /Host/Users/ilg/Work/gcc-8.4.0-1/linux-x64/build/libs/isl-0.22/.libs/lt-isl_test_cpp: symbol _ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm, version GLIBCXX_3.4.21 not defined in file libstdc++.so.6 with link time reference
            # FAIL isl_test_cpp (exit status: 127)
            # /Host/Users/ilg/Work/gcc-8.4.0-1/linux-x32/build/libs/isl-0.22/.libs/lt-isl_test_cpp: relocation error: /Host/Users/ilg/Work/gcc-8.4.0-1/linux-x32/build/libs/isl-0.22/.libs/lt-isl_test_cpp: symbol _ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERjj, version GLIBCXX_3.4.21 not defined in file libstdc++.so.6 with link time reference
            # FAIL isl_test_cpp (exit status: 127)
            # Similar for aarch64
            # FAIL: isl_test_cpp

            run_verbose make -j1 check || true
          else
            run_verbose make -j1 check
          fi
        fi

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${isl_folder_name}/make-output-$(ndate).txt"

      if [ -z "${name_suffix}" ]
      then
        copy_license \
          "${XBB_SOURCES_FOLDER_PATH}/${isl_src_folder_name}" \
          "${isl_folder_name}"
      fi

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${isl_stamp_file_path}"

  else
    echo "Library isl${name_suffix} already installed."
  fi
}

function build_zstd()
{
  # Zstandard is a real-time compression algorithm
  # https://facebook.github.io/zstd/
  # https://github.com/facebook/zstd/releases
  # https://github.com/facebook/zstd/archive/v1.4.4.tar.gz
  # https://github.com/facebook/zstd/releases/download/v1.5.0/zstd-1.5.0.tar.gz

  # https://github.com/archlinux/svntogit-packages/blob/packages/zstd/trunk/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/zstd/files/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/zstd.rb

  # 5 Nov 2019 "1.4.4"
  # 3 Mar 2021 "1.4.9"
  # 14 May 2021 "1.5.0"
  # 20 Jan 2022 "1.5.2"

  local zstd_version="$1"

  # The folder name as resulted after being extracted from the archive.
  local zstd_src_folder_name="zstd-${zstd_version}"

  local zstd_archive="${zstd_src_folder_name}.tar.gz"
  # GitHub release archive.
  local zstd_github_archive="v${zstd_version}.tar.gz"
  local zstd_github_url="https://github.com/facebook/zstd/archive/${zstd_github_archive}"

  # The folder name for build, licenses, etc.
  local zstd_folder_name="${zstd_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${zstd_folder_name}"

  local zstd_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${zstd_folder_name}-installed"
  if [ ! -f "${zstd_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${zstd_github_url}" "${zstd_archive}" \
      "${zstd_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${zstd_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${zstd_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      local build_type
      if [ "${XBB_IS_DEBUG}" == "y" ]
      then
        build_type=Debug
      else
        build_type=Release
      fi

      if [ ! -f "CMakeCache.txt" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running zstd cmake..."

          config_options=()

          config_options+=("-LH")
          config_options+=("-G" "Ninja")

          config_options+=("-DCMAKE_INSTALL_PREFIX=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
          config_options+=("-DZSTD_BUILD_PROGRAMS=OFF")

          if [ "${XBB_WITH_TESTS}" == "y" ]
          then
            config_options+=("-DZSTD_BUILD_TESTS=ON")
          fi

          if [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
          then
            # Otherwise it'll generate two -mmacosx-version-min
            config_options+=("-DCMAKE_OSX_DEPLOYMENT_TARGET=${XBB_MACOSX_DEPLOYMENT_TARGET}")
          fi

          run_verbose cmake \
            "${config_options[@]}" \
            \
            "${XBB_SOURCES_FOLDER_PATH}/${zstd_src_folder_name}/build/cmake"

        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${zstd_folder_name}/cmake-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running zstd build..."

        run_verbose cmake \
          --build . \
          --parallel ${XBB_JOBS} \
          --config "${build_type}" \

        # It takes too long.
        if false # [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose ctest \
            -V \

        fi

        (
          # The install procedure runs some resulted executables, which require
          # the libssl and libcrypt libraries from XBB.
          # xbb_activate_libs

          echo
          echo "Running zstd install..."

          run_verbose cmake \
            --build . \
            --config "${build_type}" \
            -- \
            install

        )
      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${zstd_folder_name}/build-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${zstd_src_folder_name}" \
        "${zstd_folder_name}"

      (
        cd "${XBB_BUILD_FOLDER_PATH}"

        copy_cmake_logs "${zstd_folder_name}"
      )

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${zstd_stamp_file_path}"

  else
    echo "Library zstd already installed."
  fi
}



# -----------------------------------------------------------------------------

function build_gettext()
{
  # https://www.gnu.org/software/gettext/
  # http://ftp.gnu.org/pub/gnu/gettext/

  # https://archlinuxarm.org/packages/aarch64/gettext/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gettext-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-gettext

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/gettext.rb

  # 2015-07-14 "0.19.5.1"
  # 2016-06-11 "0.19.8.1"
  # 2020-04-14 "0.20.2"
  # 2020-07-26 "0.21"

  local gettext_version="$1"

  local gettext_src_folder_name="gettext-${gettext_version}"

  local gettext_archive="${gettext_src_folder_name}.tar.gz"
  local gettext_url="http://ftp.gnu.org/pub/gnu/gettext/${gettext_archive}"

  local gettext_folder_name="${gettext_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${gettext_folder_name}"

  local gettext_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${gettext_folder_name}-installed"
  if [ ! -f "${gettext_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${gettext_url}" "${gettext_archive}" \
      "${gettext_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${gettext_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${gettext_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running gettext configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${gettext_src_folder_name}/gettext-runtime/configure" --help
          fi

          # Build only the /gettext-runtime folder, attempts to build
          # the full package fail with a CXX='no' problem.
          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
          then
            config_options+=("--enable-threads=windows")
            config_options+=("--with-gnu-ld")
          elif [ "${XBB_TARGET_PLATFORM}" == "linux" ]
          then
            config_options+=("--enable-threads=posix")
            config_options+=("--with-gnu-ld")
          elif [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
          then
            config_options+=("--enable-threads=posix")
          fi

          config_options+=("--without-git") # HB
          config_options+=("--without-cvs") # HB
          config_options+=("--without-xz") # HB
          config_options+=("--without-included-gettext") # Arch

          config_options+=("--with-included-glib") # HB
          config_options+=("--with-included-libcroco") # HB
          config_options+=("--with-included-libunistring") # HB
          config_options+=("--with-included-libxml") # HB
          config_options+=("--with-included-gettext") # HB

          # config_options+=("--with-emacs") # HB

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--disable-installed-tests")
          config_options+=("--disable-always-build-tests")

          # config_options+=("--enable-nls")
          config_options+=("--disable-nls")

          config_options+=("--disable-java") # HB
          config_options+=("--disable-native-java")

          config_options+=("--disable-csharp") # HB
          # config_options+=("--enable-csharp") # Arch

          # config_options+=("--disable-c++")
          config_options+=("--disable-libasprintf")

          # DO NOT USE, on macOS the LC_RPATH looses GCC references.
          # config_options+=("--enable-relocatable")

          #  --enable-nls needed to include libintl
          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${gettext_src_folder_name}/gettext-runtime/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${gettext_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gettext_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running gettext make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          make -j1 check # || true
        fi

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gettext_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${gettext_src_folder_name}" \
        "${gettext_folder_name}"

    )

    (
      test_gettext "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gettext_folder_name}/test-output-$(ndate).txt"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${gettext_stamp_file_path}"

  else
    echo "Library gettext already installed."
  fi

  tests_add "test_gettext" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
}

function test_gettext()
{
  local test_bin_folder_path="$1"

  echo
  echo "Checking the gettext shared libraries..."

  show_libs "${test_bin_folder_path}/gettext"
  show_libs "${test_bin_folder_path}/ngettext"
  show_libs "${test_bin_folder_path}/envsubst"

  run_app "${test_bin_folder_path}/gettext" --version
  test_expect "test" "${test_bin_folder_path}/gettext" test
}

# -----------------------------------------------------------------------------

function build_libelf()
{
  # https://sourceware.org/elfutils/
  # ftp://sourceware.org/pub/elfutils/
  # ftp://sourceware.org/pub/elfutils//0.178/elfutils-0.178.tar.bz2

  # https://archlinuxarm.org/packages/aarch64/libelf/files/PKGBUILD

  # libelf_version="0.8.13" (deprecated)
  # 26 Nov 2019, 0.178
  # 2020-03-30, 0.179
  # 2020-06-11, 0.180
  # 2020-09-08, 0.181
  # 2020-10-31, 0.182
  # 2021-02-07, "0.183"
  # 2021-05-10, "0.184"

  local libelf_version="$1"

  local libelf_src_folder_name="libelf-${libelf_version}"
  local libelf_archive="${libelf_src_folder_name}.tar.gz"

  # local libelf_url="http://www.mr511.de/software/${libelf_archive}"
  # The original site seems unavailable, use a mirror.
  local libelf_url="https://fossies.org/linux/misc/old/${libelf_archive}"

  local libelf_folder_name="${libelf_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libelf_folder_name}"

  local libelf_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${libelf_folder_name}-installed"
  if [ ! -f "${libelf_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libelf_url}" "${libelf_archive}" \
      "${libelf_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libelf_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${libelf_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running libelf configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libelf_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          # config_options+=("--disable-nls")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${libelf_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libelf_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libelf_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running libelf make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libelf_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libelf_src_folder_name}" \
        "${libelf_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libelf_stamp_file_path}"

  else
    echo "Library libelf already installed."
  fi
}

# -----------------------------------------------------------------------------

function build_gpm()
{
  # General purpose mouse. Used by ncurses.
  # https://www.nico.schottelius.org/software/gpm/
  # https://github.com/telmich/gpm
  # https://github.com/telmich/gpm/tags
  # https://github.com/telmich/gpm/releases/tag/1.20.7
  # https://github.com/telmich/gpm/archive/1.20.7.tar.gz
  # https://github.com/xpack-dev-tools/gpm/archive/refs/tags/v1.20.7-1.tar.gz

  # https://archlinuxarm.org/packages/aarch64/gpm/files/PKGBUILD

  # 27 Oct 2012 "1.20.7"
  # 25 Apr 2022 "1.20.7-1" xPack

  local gpm_version="$1"

  local gpm_src_folder_name="gpm-${gpm_version}"

  local gpm_archive="${gpm_src_folder_name}.tar.gz"
  # GitHub release archive.
  local gpm_github_archive="${gpm_version}.tar.gz"
  # local gpm_github_url="https://github.com/telmich/gpm/archive/${gpm_github_archive}"
  local gpm_github_url="https://github.com/xpack-dev-tools/gpm/archive/refs/tags/v${gpm_github_archive}"

  local gpm_folder_name="${gpm_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${gpm_folder_name}"

  local gpm_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${gpm_folder_name}-installed"
  if [ ! -f "${gpm_stamp_file_path}" ]
  then

    echo
    echo "gmp in-source building..."

    mkdir -pv "${XBB_BUILD_FOLDER_PATH}"
    cd "${XBB_BUILD_FOLDER_PATH}"

    if [ ! -d "${XBB_BUILD_FOLDER_PATH}/${gpm_folder_name}" ]
    then
      download_and_extract "${gpm_github_url}" "${gpm_archive}" \
        "${gpm_src_folder_name}"

      if [ "${gpm_src_folder_name}" != "${gpm_folder_name}" ]
      then
        mv -v "${gpm_src_folder_name}" "${gpm_folder_name}"
      fi
    fi

    (
      cd "${XBB_BUILD_FOLDER_PATH}/${gpm_folder_name}"
      if [ ! -f "stamp-autogen" ]
      then

        run_verbose bash ${DEBUG} "autogen.sh"

        touch "stamp-autogen"
      fi
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gpm_folder_name}/autogen-output-$(ndate).txt"

    (
      cd "${XBB_BUILD_FOLDER_PATH}/${gpm_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS} -I${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/${gpm_folder_name}/src/headers"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
        LDFLAGS+=" -Wl,--allow-multiple-definition"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running gpm configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          # config_options+=("--with-pic")

          run_verbose bash ${DEBUG} "configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${gpm_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gpm_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running gpm make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
        then
          (
            mkdir -pv "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
            cd "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"

            # Manual copy, since it is not refered in the elf.
            cp -v "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libgpm.so.2.1.0" .
            rm -f "libgpm.so.2"
            ln -s -v "libgpm.so.2.1.0" "libgpm.so.2"
          )
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gpm_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_BUILD_FOLDER_PATH}/${gpm_folder_name}" \
        "${gpm_folder_name}"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${gpm_stamp_file_path}"

  else
    echo "Library gpm already installed."
  fi
}






# -----------------------------------------------------------------------------

function build_lzo()
{
  # Real-time data compression library
  # https://www.oberhumer.com/opensource/lzo/
  # https://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz

  # https://github.com/archlinux/svntogit-packages/blob/packages/lzo/trunk/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/lzo.rb

  # 01 Mar 2017 "2.10"

  local lzo_version="$1"

  local lzo_src_folder_name="lzo-${lzo_version}"

  local lzo_archive="${lzo_src_folder_name}.tar.gz"
  local lzo_url="https://www.oberhumer.com/opensource/lzo/download/${lzo_archive}"

  local lzo_folder_name="${lzo_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${lzo_folder_name}"

  local lzo_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${lzo_folder_name}-installed"
  if [ ! -f "${lzo_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${lzo_url}" "${lzo_archive}" \
      "${lzo_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${lzo_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${lzo_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running lzo configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${lzo_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          config_options+=("--disable-dependency-tracking")
          config_options+=("--enable-shared")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${lzo_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${lzo_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${lzo_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running lzo make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${lzo_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${lzo_src_folder_name}" \
        "${lzo_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${lzo_stamp_file_path}"

  else
    echo "Library lzo already installed."
  fi
}

# -----------------------------------------------------------------------------

function build_python2()
{
  # https://www.python.org
  # https://www.python.org/downloads/source/
  # https://www.python.org/ftp/python/
  # https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tar.xz

  # https://archlinuxarm.org/packages/aarch64/python/files/PKGBUILD
  # https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/python
  # https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/python-pip

  # 19-Apr-2020, "2.7.18"

  local python2_version="$1"

  export XBB_PYTHON2_VERSION_MAJOR=$(echo ${python2_version} | sed -e 's|\([0-9]\)\..*|\1|')
  export XBB_PYTHON2_VERSION_MINOR=$(echo ${python2_version} | sed -e 's|\([0-9]\)\.\([0-9][0-9]*\)\..*|\2|')
  export XBB_PYTHON2_VERSION_MAJOR_MINOR=${XBB_PYTHON2_VERSION_MAJOR}${XBB_PYTHON2_VERSION_MINOR}

  # Used in python27-config.sh.
  export XBB_PYTHON2_SRC_FOLDER_NAME="Python-${python2_version}"

  local python2_archive="${XBB_PYTHON2_SRC_FOLDER_NAME}.tar.xz"
  local python2_url="https://www.python.org/ftp/python/${python2_version}/${python2_archive}"

  local python2_folder_name="python-${python2_version}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${python2_folder_name}"

  local python2_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${python2_folder_name}-installed"
  if [ ! -f "${python2_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${python2_url}" "${python2_archive}" \
      "${XBB_PYTHON2_SRC_FOLDER_NAME}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${python2_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${python2_folder_name}"

      # To pick the new libraries
      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS} -I${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/ncurses"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      if [[ ${CC} =~ .*gcc.* ]]
      then
        # Inspired from Arch; not supported by clang.
        CFLAGS+=" -fno-semantic-interposition"
        CXXFLAGS+=" -fno-semantic-interposition"
        LDFLAGS+=" -fno-semantic-interposition"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running python2 configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${XBB_PYTHON2_SRC_FOLDER_NAME}/configure" --help
          fi

          # Fail on macOS:
          # --enable-universalsdk
          # --with-lto

          # "... you should not skip tests when using --enable-optimizations as
          # the data required for profiling is generated by running tests".

          # --enable-optimizations takes too long

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--with-dbmliborder=gdbm:ndbm")

          config_options+=("--without-ensurepip")
          config_options+=("--without-lto")

          # Create the PythonX.Y.so.
          config_options+=("--enable-shared")

          if [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
          then
            config_options+=("--enable-unicode=ucs2")
          else
            config_options+=("--enable-unicode=ucs4")
          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${XBB_PYTHON2_SRC_FOLDER_NAME}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${python2_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${python2_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running python2 make..."

        # export LD_RUN_PATH="${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib"

        # Build.
        run_verbose make -j ${XBB_JOBS} # build_all

        run_verbose make altinstall

        # Hundreds of tests, take a lot of time.
        # Many failures.
        if false # [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 quicktest
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${python2_folder_name}/make-output-$(ndate).txt"
    )

    (
      test_python2
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${python2_folder_name}/test-output-$(ndate).txt"

    copy_license \
      "${XBB_SOURCES_FOLDER_PATH}/${XBB_PYTHON2_SRC_FOLDER_NAME}" \
      "${python2_folder_name}"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${python2_stamp_file_path}"

  else
    echo "Component python2 already installed."
  fi
}


function test_python2()
{
  (
    echo
    echo "Checking the python2 binary shared libraries..."

    show_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/python2.${XBB_PYTHON2_VERSION_MINOR}"
    show_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libpython${XBB_PYTHON2_VERSION_MAJOR}.${XBB_PYTHON2_VERSION_MINOR}.${XBB_SHLIB_EXT}"

    echo
    echo "Testing if the python2 binary starts properly..."

    export LD_LIBRARY_PATH="${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib"
    run_app "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/python2.${XBB_PYTHON2_VERSION_MINOR}" --version

    run_app "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/python2.${XBB_PYTHON2_VERSION_MINOR}" -c 'import sys; print(sys.path)'
    run_app "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/python2.${XBB_PYTHON2_VERSION_MINOR}" -c 'import sys; print(sys.prefix)'
  )
}


# -----------------------------------------------------------------------------

# Download the Windows Python 2 libraries and headers.
function download_python2_win()
{
  # https://www.python.org/downloads/release/python-2714/
  # https://www.python.org/ftp/python/2.7.14/python-2.7.14.msi
  # https://www.python.org/ftp/python/2.7.14/python-2.7.14.amd64.msi

  local python2_win_version="$1"

  export XBB_PYTHON2_VERSION_MAJOR=$(echo ${python2_win_version} | sed -e 's|\([0-9]\)\..*|\1|')
  export XBB_PYTHON2_VERSION_MINOR=$(echo ${python2_win_version} | sed -e 's|\([0-9]\)\.\([0-9][0-9]*\)\..*|\2|')
  export XBB_PYTHON2_VERSION_MAJOR_MINOR=${XBB_PYTHON2_VERSION_MAJOR}${XBB_PYTHON2_VERSION_MINOR}

  local python2_win_pack

  if [ "${XBB_TARGET_BITS}" == "32" ]
  then
    XBB_PYTHON2_WIN_SRC_FOLDER_NAME="python-${python2_win_version}-embed-win32"
    python2_win_pack="python-${python2_win_version}.msi"
  else
    XBB_PYTHON2_WIN_SRC_FOLDER_NAME="python-${python2_win_version}-embed-amd64"
    python2_win_pack="python-${python2_win_version}.amd64.msi"
  fi

  # Used in python27-config.sh.
  export XBB_PYTHON2_WIN_SRC_FOLDER_NAME

  local python2_win_url="https://www.python.org/ftp/python/${python2_win_version}/${python2_win_pack}"

  cd "${XBB_SOURCES_FOLDER_PATH}"

  download "${python2_win_url}" "${python2_win_pack}"

  (
    if [ ! -d "${XBB_PYTHON2_WIN_SRC_FOLDER_NAME}" ]
    then
      mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

      # Include only the headers and the python library and executable.
      local tmp_path="/tmp/included$$"
      echo '*.h' >"${tmp_path}"
      echo 'python*.dll' >>"${tmp_path}"
      echo 'python*.lib' >>"${tmp_path}"
      7za x -o"${XBB_PYTHON2_WIN_SRC_FOLDER_NAME}" "${XBB_DOWNLOAD_FOLDER_PATH}/${python2_win_pack}" -i@"${tmp_path}"

      # Patch to disable the macro that renames hypot.
      local patch_path="${XBB_PYTHON2_WIN_SRC_FOLDER_NAME}.patch"
      if [ -f "${patch_path}" ]
      then
        (
          cd "${XBB_PYTHON2_WIN_SRC_FOLDER_NAME}"
          patch -p0 <"${patch_path}"
        )
      fi
    else
      echo "Folder ${XBB_PYTHON2_WIN_SRC_FOLDER_NAME} already present."
    fi

    echo "Copying python${XBB_PYTHON2_VERSION_MAJOR_MINOR}.dll..."
    # From here it'll be copied as dependency.
    mkdir -pv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/"
    install -v -c -m 644 "${XBB_PYTHON2_WIN_SRC_FOLDER_NAME}/python${XBB_PYTHON2_VERSION_MAJOR_MINOR}.dll" \
      "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/"

    mkdir -pv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/"
    install -v -c -m 644 "${XBB_PYTHON2_WIN_SRC_FOLDER_NAME}/python${XBB_PYTHON2_VERSION_MAJOR_MINOR}.lib" \
      "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/"
  )
}


# -----------------------------------------------------------------------------

function build_libpng()
{
  # To ensure builds stability, use slightly older releases.
  # https://sourceforge.net/projects/libpng/files/libpng16/
  # https://sourceforge.net/projects/libpng/files/libpng16/older-releases/

  # https://github.com/archlinux/svntogit-packages/blob/packages/libpng/trunk/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/libpng/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libpng-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-libpng

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/libpng.rb

  # libpng_version="1.2.53"
  # libpng_version="1.6.17"
  # libpng_version="1.6.23" # 2016-06-09
  # libpng_version="1.6.36" # 2018-12-01
  # 2019-04-15, "1.6.37"
  # libpng_SFOLDER="libpng12"
  # libpng_SFOLDER="libpng16"

  local libpng_version="$1"
  local libpng_major_minor_version="$(echo ${libpng_version} | sed -e 's|\([0-9][0-9]*\)\.\([0-9][0-9]*\)\.[0-9].*|\1\2|')"

  local libpng_src_folder_name="libpng-${libpng_version}"

  local libpng_archive="${libpng_src_folder_name}.tar.xz"
  # local libpng_url="https://sourceforge.net/projects/libpng/files/${libpng_SFOLDER}/older-releases/${libpng_version}/${libpng_archive}"
  local libpng_url="https://sourceforge.net/projects/libpng/files/libpng${libpng_major_minor_version}/${libpng_version}/${libpng_archive}"

  local libpng_folder_name="${libpng_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libpng_folder_name}"

  local libpng_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-libpng-${libpng_version}-installed"
  if [ ! -f "${libpng_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libpng_url}" "${libpng_archive}" \
      "${libpng_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libpng_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${libpng_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running libpng configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libpng_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          # config_options+=("--disable-static")
          # From Arm Arch.
          config_options+=("--enable-arm-neon=no")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${libpng_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libpng_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libpng_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running libpng make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libpng_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libpng_src_folder_name}" \
        "${libpng_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libpng_stamp_file_path}"

  else
    echo "Library libpng already installed."
  fi
}

# See also
# https://archlinuxarm.org/packages/aarch64/libjpeg-turbo/files/PKGBUILD

function build_jpeg()
{
  # http://www.ijg.org
  # http://www.ijg.org/files/

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libjpeg9

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/jpeg.rb

  # Jan 19 10:26 2014 "9a"
  # Jan 17 10:46 2016 "9b"
  # Jan 14 10:10 2018 "9c"
  # Jan 12 10:07 2020 "9d"
  # Jan 16 10:12 2022 "9e"

  local jpeg_version="$1"

  local jpeg_src_folder_name="jpeg-${jpeg_version}"

  local jpeg_archive="jpegsrc.v${jpeg_version}.tar.gz"
  local jpeg_url="http://www.ijg.org/files/${jpeg_archive}"

  local jpeg_folder_name="${jpeg_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${jpeg_folder_name}"

  local jpeg_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-jpeg-${jpeg_version}-installed"
  if [ ! -f "${jpeg_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${jpeg_url}" "${jpeg_archive}" \
        "${jpeg_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${jpeg_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${jpeg_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running jpeg configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${jpeg_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          # --enable-shared needed by sdl2_image on CentOS 64-bit and Ubuntu.
          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${jpeg_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${jpeg_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${jpeg_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running jpeg make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${jpeg_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${jpeg_src_folder_name}" \
        "${jpeg_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${jpeg_stamp_file_path}"

  else
    echo "Library jpeg already installed."
  fi
}

function build_pixman()
{
  # http://www.pixman.org
  # http://cairographics.org/releases/

  # https://archlinuxarm.org/packages/aarch64/pixman/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=pixman-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-pixman

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/pixman.rb

  # pixman_version="0.32.6"
  # pixman_version="0.34.0" # 2016-01-31
  # pixman_version="0.38.0" # 2019-02-11
  # 2019-04-10, "0.38.4"
  # 2020-04-19, "0.40.0"

  local pixman_version="$1"

  local pixman_src_folder_name="pixman-${pixman_version}"

  local pixman_archive="${pixman_src_folder_name}.tar.gz"
  local pixman_url="http://cairographics.org/releases/${pixman_archive}"

  local pixman_folder_name="${pixman_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${pixman_folder_name}"

  local pixman_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-pixman-${pixman_version}-installed"
  if [ ! -f "${pixman_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${pixman_url}" "${pixman_archive}" \
      "${pixman_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${pixman_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${pixman_folder_name}"

      # Windows libtool chaks for it.
      mkdir -pv test/lib

      if [ "${XBB_TARGET_PLATFORM}" == "darwin" ] && [[ ${CC} =~ .*gcc.* ]]
      then
        # TODO: check again on Apple Silicon.
        prepare_clang_env ""
      fi

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running pixman configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${pixman_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          # config_options+=("--with-gnu-ld")

          # The numerous disables were inspired from Arch, after the initial
          # failed on armhf.
          config_options+=("--disable-static-testprogs")
          config_options+=("--disable-loongson-mmi")
          config_options+=("--disable-vmx")
          config_options+=("--disable-arm-simd")
          config_options+=("--disable-arm-neon")
          config_options+=("--disable-arm-iwmmxt")
          config_options+=("--disable-mmx")
          config_options+=("--disable-sse2")
          config_options+=("--disable-ssse3")
          config_options+=("--disable-mips-dspr2")
          config_options+=("--disable-gtk")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${pixman_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${pixman_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${pixman_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running pixman make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${pixman_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${pixman_src_folder_name}" \
        "${pixman_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${pixman_stamp_file_path}"

  else
    echo "Library pixman already installed."
  fi
}

# -----------------------------------------------------------------------------


function build_glib2()
{
  # http://ftp.gnome.org/pub/GNOME/sources/glib

  # https://github.com/archlinux/svntogit-packages/blob/packages/glib2/trunk/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=glib2-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-glib2

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/glib.rb

  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-glib2/PKGBUILD

  # 2015-May-13, "2.44.1"
  # 2017-Mar-13, "2.51.5"
  # 2018-Sep-21, "2.56.3"
  # 2018-Dec-18, "2.56.4"
  # --- Starting with 2.57, the build was migrated to meson (TODO) ---
  # 2018-Aug-23, "2.57.3"
  # 2019-Sep-02, "2.60.7"
  # 2021-May-11, "2.68.4"
  # 2021-Sep-17, "2.70.0"
  # 2021-Dec-03, "2.70.2"
  # 2022-Apr-14, "2.72.1"
  # 2022-Aug-05, "2.73.3"

  local glib_version="$1"
  local glib_major_version=$(echo ${glib_version} | sed -e 's|\([0-9][0-9]*\)\.\([0-9][0-9]*\)\.[0-9].*|\1|')
  local glib_minor_version=$(echo ${glib_version} | sed -e 's|\([0-9][0-9]*\)\.\([0-9][0-9]*\)\.[0-9].*|\2|')
  local glib_major_minor_version="$(echo ${glib_version} | sed -e 's|\([0-9][0-9]*\)\.\([0-9][0-9]*\)\.[0-9].*|\1.\2|')"

  local glib_src_folder_name="glib-${glib_version}"

  local glib_archive="${glib_src_folder_name}.tar.xz"

  local glib_url="http://ftp.gnome.org/pub/GNOME/sources/glib/${glib_major_minor_version}/${glib_archive}"

  local glib_folder_name="${glib_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${glib_folder_name}"

  local glib_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-glib-${glib_version}-installed"
  if [ ! -f "${glib_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${glib_url}" "${glib_archive}" \
      "${glib_src_folder_name}"

    (
      # Hack, /gio/lib added because libtool needs it on Win32.
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${glib_folder_name}"/gio/lib
      cd "${XBB_BUILD_FOLDER_PATH}/${glib_folder_name}"

      if [ "${XBB_TARGET_PLATFORM}" == "darwin" ] && [[ ${CC} =~ .*gcc.* ]]
      then
        # GCC fails with
        # error: unknown type name ‘dispatch_block_t
        prepare_clang_env ""
      fi

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      LIBS=""

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH} -liconv"
        # LIBS="-liconv"
      elif [ "${XBB_TARGET_PLATFORM}" == "win32" ]
      then
        LDFLAGS+=" -Wl,--allow-multiple-definition"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS
      export LIBS

      if [ ${glib_major_version} -eq 2 -a ${glib_minor_version} -le 56 ]
      then
        # Up to 2.56 use the old configure.
        if [ ! -f "config.status" ]
        then
          (
            if [ "${XBB_IS_DEVELOP}" == "y" ]
            then
              env | sort
            fi

            echo
            echo "Running glib configure..."

            if [ "${XBB_IS_DEVELOP}" == "y" ]
            then
              run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${glib_src_folder_name}/configure" --help
            fi

            config_options=()

            config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
            config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
            config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
            # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
            config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

            config_options+=("--build=${XBB_BUILD}")
            config_options+=("--host=${XBB_HOST}")
            config_options+=("--target=${XBB_TARGET}")

            # --with-libiconv=gnu required on Linux
            config_options+=("--with-libiconv=gnu")
            config_options+=("--without-pcre")

            config_options+=("--disable-selinux")
            config_options+=("--disable-fam")
            config_options+=("--disable-xattr")
            config_options+=("--disable-libelf")
            config_options+=("--disable-libmount")
            config_options+=("--disable-dtrace")
            config_options+=("--disable-systemtap")
            config_options+=("--disable-coverage")
            config_options+=("--disable-Bsymbolic")
            config_options+=("--disable-znodelete")
            config_options+=("--disable-compile-warnings")
            config_options+=("--disable-installed-tests")
            config_options+=("--disable-always-build-tests")

            run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${glib_src_folder_name}/configure" \
              "${config_options[@]}"

            # Disable SPLICE, it fails on CentOS.
            local gsed_path=$(which gsed)
            if [ ! -z "${gsed_path}" ]
            then
              run_verbose gsed -i -e '/#define HAVE_SPLICE 1/d' config.h
            else
              run_verbose sed -i -e '/#define HAVE_SPLICE 1/d' config.h
            fi

            cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${glib_folder_name}/config-log-$(ndate).txt"
          ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${glib_folder_name}/configure-output-$(ndate).txt"
        fi

        (
          echo
          echo "Running glib make..."

          # Build.
          run_verbose make -j ${XBB_JOBS}

          if [ "${XBB_WITH_STRIP}" == "y" ]
          then
            run_verbose make install-strip
          else
            run_verbose make install
          fi

        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${glib_folder_name}/make-output-$(ndate).txt"
      else
        if [ ! -f "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/${glib_folder_name}/build.ninja" ]
        then
          (
            if [ "${XBB_IS_DEVELOP}" == "y" ]
            then
              env | sort
            fi

            echo
            echo "Running glib meson setup..."

            cd "${XBB_SOURCES_FOLDER_PATH}/${glib_src_folder_name}"

            # https://mesonbuild.com/Commands.html#setup
            config_options=()

            config_options+=("--prefix" "${XBB_BINARIES_INSTALL_FOLDER_PATH}")
            config_options+=("--includedir" "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
            config_options+=("--libdir" "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
            config_options+=("--backend" "ninja")

            if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
            then
              config_options+=("--cross" "${helper_folder_path}/extras/meson/mingw-w64-gcc.ini")
            fi

            run_verbose meson setup \
              "${config_options[@]}" \
              "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/${glib_folder_name}"

          ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${glib_folder_name}/meson-setup-output-$(ndate).txt"
        fi

        (
          echo
          echo "Running glib meson compile..."

          # Build.
          run_verbose meson compile -C "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/${glib_folder_name}"

          run_verbose meson install -C "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/${glib_folder_name}"

        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${glib_folder_name}/meson-compile-output-$(ndate).txt"

        # exit 1
      fi

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${glib_src_folder_name}" \
        "${glib_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${glib_stamp_file_path}"

  else
    echo "Library glib already installed."
  fi
}

# -----------------------------------------------------------------------------

function build_libxml2()
{
  # http://www.xmlsoft.org
  # ftp://xmlsoft.org/libxml2/
  # https://download.gnome.org/sources/libxml2
  # https://download.gnome.org/sources/libxml2/2.9/libxml2-2.9.14.tar.xz

  # https://gitlab.gnome.org/GNOME/libxml2/-/releases
  # https://gitlab.gnome.org/GNOME/libxml2/-/archive/v2.9.14/libxml2-v2.9.14.tar.bz2

  # https://github.com/archlinux/svntogit-packages/blob/packages/libxml2/trunk/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/libxml2/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libxml2-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-libxml2

  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-libxml2/PKGBUILD
  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-readline/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/libxml2.rb

  # Mar 05 2018, "2.9.8"
  # Jan 03 2019, "2.9.9"
  # Oct 30 2019, "2.9.10"
  # May 13 2021, "2.9.11"
  # May 2, 2022, "2.9.14"
  # Aug 29, 2022, "2.10.2"

  local libxml2_version="$1"
  local libxml2_version_major_minor="$(echo ${libxml2_version} | sed -e 's|\([0-9][0-9]*\)\.\([0-9][0-9]*\)\.[0-9].*|\1.\2|')"


  local libxml2_src_folder_name="libxml2-${libxml2_version}"

  local libxml2_archive="${libxml2_src_folder_name}.tar.xz"
  # local libxml2_url="ftp://xmlsoft.org/libxml2/${libxml2_archive}"
  local libxml2_url="https://download.gnome.org/sources/libxml2/${libxml2_version_major_minor}/${libxml2_archive}"

  local libxml2_folder_name="${libxml2_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libxml2_folder_name}"

  local libxml2_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-libxml2-${libxml2_version}-installed"
  if [ ! -f "${libxml2_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libxml2_url}" "${libxml2_archive}" \
      "${libxml2_src_folder_name}"

    # Fails if not built in place.
    if [ ! -d "${XBB_BUILD_FOLDER_PATH}/${libxml2_folder_name}" ]
    then
      (
        cp -r "${libxml2_src_folder_name}" \
          "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/${libxml2_folder_name}"

        cd "${XBB_BUILD_FOLDER_PATH}/${libxml2_folder_name}"

        xbb_activate_installed_dev

        autoreconf -vfi
      )
    fi

    (
      # /lib added due to wrong -Llib used during make.
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libxml2_folder_name}/lib"
      cd "${XBB_BUILD_FOLDER_PATH}/${libxml2_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running libxml2 configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          config_options+=("--without-python") # HB
          # config_options+=("--with-python=/usr/bin/python") # Arch

          # config_options+=("--without-lzma") # HB

          # config_options+=("--with-history") # Arch
          config_options+=("--with-icu") # Arch

          # config_options+=("--disable-static") # Arch

          if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
          then
            config_options+=("--with-threads=win32")
            config_options+=("--without-catalog")
            config_options+=("--disable-shared")
          fi

          run_verbose bash ${DEBUG} "configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libxml2_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libxml2_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running libxml2 make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libxml2_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libxml2_src_folder_name}" \
        "${libxml2_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libxml2_stamp_file_path}"

  else
    echo "Library libxml2 already installed."
  fi
}

# -----------------------------------------------------------------------------

function build_libedit()
{
  # https://www.thrysoee.dk/editline/
  # https://www.thrysoee.dk/editline/libedit-20210522-3.1.tar.gz
  # https://www.thrysoee.dk/editline/libedit-20210910-3.1.tar.gz

  # https://archlinuxarm.org/packages/aarch64/libedit/files/PKGBUILD

  # 2021-05-22, "20210522-3.1"
  # 2021-09-1-, "20210910-3.1"

  local libedit_version="$1"
  local libedit_version_short="$(echo ${libedit_version} | sed -e 's|[0-9]*-||')"

  local libedit_src_folder_name="libedit-${libedit_version}"
  local libedit_archive="${libedit_src_folder_name}.tar.gz"

  local libedit_url="https://www.thrysoee.dk/editline/${libedit_archive}"

  local libedit_folder_name="libedit-${libedit_version_short}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libedit_folder_name}"

  local libedit_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${libedit_folder_name}-installed"
  if [ ! -f "${libedit_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libedit_url}" "${libedit_archive}" \
      "${libedit_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libedit_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${libedit_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        if [ -d "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/ncursesw" ]
        then
          CPPFLAGS+=" -I${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/ncursesw"
        elif [ -d "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/ncurses" ]
        then
          CPPFLAGS+=" -I${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/ncurses"
        else
          echo "No include/ncurses folder."
          exit 1
        fi
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running libedit configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libedit_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          # config_options+=("--disable-nls")
          # config_options+=("--disable-shared")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${libedit_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libedit_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libedit_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running libedit make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libedit_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libedit_src_folder_name}" \
        "${libedit_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libedit_stamp_file_path}"

  else
    echo "Library libedit already installed."
  fi
}

# -----------------------------------------------------------------------------

# Not yet functional.
function build_xar()
{
  # https://github.com/mackyle/xar
  # https://github.com/mackyle/xar/archive/refs/tags/xar-1.6.1.tar.gz

  # 18 Sep 2012, "1.6.1"

  local xar_version="$1"

  local xar_src_folder_name="xar-xar-${xar_version}"

  local xar_archive="xar-${xar_version}.tar.gz"
  # GitHub release archive.
  local xar_github_archive="xar-${xar_version}.tar.gz"
  local xar_github_url="https://github.com/mackyle/xar/archive/refs/tags/${xar_github_archive}"

  local xar_folder_name="xar-${xar_version}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${xar_folder_name}"

  local xar_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${xar_folder_name}-installed"
  if [ ! -f "${xar_stamp_file_path}" ]
  then

    echo
    echo "xar in-source building..."

    mkdir -pv "${XBB_BUILD_FOLDER_PATH}"
    cd "${XBB_BUILD_FOLDER_PATH}"

    if [ ! -d "${XBB_BUILD_FOLDER_PATH}/${xar_folder_name}" ]
    then
      download_and_extract "${xar_github_url}" "${xar_archive}" \
        "${xar_src_folder_name}"

      if [ "${xar_src_folder_name}" != "${xar_folder_name}" ]
      then
        mv -v "${xar_src_folder_name}" "${xar_folder_name}"
      fi
    fi

    (
      cd "${XBB_BUILD_FOLDER_PATH}/${xar_folder_name}/xar/"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -x "configure" ]
      then

        echo
        echo "Running xar autogen..."
        run_verbose bash ${DEBUG} "autogen.sh"

      fi

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running xar configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "./configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          run_verbose bash ${DEBUG} "./configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${xar_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${xar_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running xar make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${xar_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${xar_src_folder_name}" \
        "${xar_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${xar_stamp_file_path}"

  else
    echo "Library xar already installed."
  fi
}

# -----------------------------------------------------------------------------

function build_libgpg_error()
{
  # https://gnupg.org/ftp/gcrypt/libgpg-error

  # https://github.com/archlinux/svntogit-packages/blob/packages/libgpg-error/trunk/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/libgpg-error/files/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/libgpg-error.rb

  # 2020-02-07, "1.37"
  # 2021-03-22, "1.42"
  # 2021-11-03, "1.43"

  local libgpg_error_version="$1"

  local libgpg_error_src_folder_name="libgpg-error-${libgpg_error_version}"

  local libgpg_error_archive="${libgpg_error_src_folder_name}.tar.bz2"
  local libgpg_error_url="https://gnupg.org/ftp/gcrypt/libgpg-error/${libgpg_error_archive}"

  local libgpg_error_folder_name="${libgpg_error_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libgpg_error_folder_name}"

  local libgpg_error_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${libgpg_error_folder_name}-installed"
  if [ ! -f "${libgpg_error_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libgpg_error_url}" "${libgpg_error_archive}" \
      "${libgpg_error_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libgpg_error_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${libgpg_error_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running libgpg-error configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libgpg_error_src_folder_name}/configure" --help
          fi

          config_options=()

          # Exception: use LIBS_INSTALL_*.
          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--disable-nls")

          config_options+=("--enable-static") # HB

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${libgpg_error_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libgpg_error_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libgpg_error_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running libgpg-error make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          # WARN-TEST
          run_verbose make -j1 check
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libgpg_error_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libgpg_error_src_folder_name}" \
        "${libgpg_error_folder_name}"
    )

    (
      test_libgpg_error_libs
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libgpg_error_folder_name}/test-output-$(ndate).txt"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libgpg_error_stamp_file_path}"

  else
    echo "Library libgpg-error already installed."
  fi
}

function test_libgpg_error_libs()
{
  echo
  echo "Checking the libpng_error shared libraries..."

  show_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libgpg-error.${XBB_SHLIB_EXT}"
}

# -----------------------------------------------------------------------------

function build_libgcrypt()
{
  # https://gnupg.org/ftp/gcrypt/libgcrypt
  # https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.8.5.tar.bz2

  # https://github.com/archlinux/svntogit-packages/blob/packages/libgcrypt/trunk/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/libgcrypt/files/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/libgcrypt.rb

  # 2019-08-29, "1.8.5"
  # 2021-06-02, "1.8.8"
  # 2021-04-19, "1.9.3" Fails many tests on macOS 10.13
  # 2021-08-22, "1.9.4"

  local libgcrypt_version="$1"

  local libgcrypt_src_folder_name="libgcrypt-${libgcrypt_version}"

  local libgcrypt_archive="${libgcrypt_src_folder_name}.tar.bz2"
  local libgcrypt_url="https://gnupg.org/ftp/gcrypt/libgcrypt/${libgcrypt_archive}"

  local libgcrypt_folder_name="${libgcrypt_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libgcrypt_folder_name}"

  local libgcrypt_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${libgcrypt_folder_name}-installed"
  if [ ! -f "${libgcrypt_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libgcrypt_url}" "${libgcrypt_archive}" \
      "${libgcrypt_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libgcrypt_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${libgcrypt_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running libgcrypt configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libgcrypt_src_folder_name}/configure" --help
          fi

          config_options=()

          # Exception: use LIBS_INSTALL_*.
          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          config_options+=("--with-libgpg-error-prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          config_options+=("--disable-doc")
          config_options+=("--disable-large-data-tests")

          # For Darwin, there are problems with the assembly code.
          config_options+=("--disable-asm") # HB
          config_options+=("--disable-amd64-as-feature-detection")

          config_options+=("--disable-padlock-support") # Arch

          if [ "${XBB_HOST_MACHINE}" != "aarch64" ]
          then
            config_options+=("--disable-neon-support")
            config_options+=("--disable-arm-crypto-support")
          fi

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--enable-static") # HB

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${libgcrypt_src_folder_name}/configure" \
            "${config_options[@]}"

          if false # [ "${XBB_HOST_MACHINE}" != "aarch64" ]
          then
            # fix screwed up capability detection
            sed -i.bak -e '/HAVE_GCC_INLINE_ASM_AARCH32_CRYPTO 1/d' "config.h"
            sed -i.bak -e '/HAVE_GCC_INLINE_ASM_NEON 1/d' "config.h"
          fi

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libgcrypt_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libgcrypt_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running libgcrypt make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        # Check after install, otherwise mac test fails:
        # dyld: Library not loaded: /Users/ilg/opt/xbb/lib/libgcrypt.20.dylib
        # Referenced from: /Users/ilg/Work/xbb-3.1-macosx-10.15.3-x86_64/build/libs/libgcrypt-1.8.5/tests/.libs/random

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libgcrypt_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libgcrypt_src_folder_name}" \
        "${libgcrypt_folder_name}"
    )

    (
      test_libgcrypt_libs
      test_libgcrypt "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libgcrypt_folder_name}/test-output-$(ndate).txt"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libgcrypt_stamp_file_path}"

  else
    echo "Library libgcrypt already installed."
  fi

  tests_add "test_libgcrypt" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
}

function test_libgcrypt_libs()
{
  echo
  echo "Checking the libgcrypt shared libraries..."

  # show_libs "${XBB_INSTALL_FOLDER_PATH}/bin/libgcrypt-config"
  show_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/dumpsexp"
  show_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/hmac256"
  show_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/mpicalc"

  show_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libgcrypt.${XBB_SHLIB_EXT}"
}

function test_libgcrypt()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the libgcrypt shared libraries..."

    # show_libs "${XBB_INSTALL_FOLDER_PATH}/bin/libgcrypt-config"
    show_libs "${test_bin_folder_path}/dumpsexp"
    show_libs "${test_bin_folder_path}/hmac256"
    show_libs "${test_bin_folder_path}/mpicalc"

    echo
    echo "Testing if libgcrypt binaries start properly..."

    run_app "${test_bin_folder_path}/libgcrypt-config" --version
    run_app "${test_bin_folder_path}/dumpsexp" --version
    run_app "${test_bin_folder_path}/hmac256" --version
    run_app "${test_bin_folder_path}/mpicalc" --version

    # --help not available
    # run_app "${test_bin_folder_path}/hmac256" --help

    rm -rf "${XBB_TESTS_FOLDER_PATH}/libgcrypt"
    mkdir -pv "${XBB_TESTS_FOLDER_PATH}/libgcrypt"; cd "${XBB_TESTS_FOLDER_PATH}/libgcrypt"

    touch test.in
    test_expect "0e824ce7c056c82ba63cc40cffa60d3195b5bb5feccc999a47724cc19211aef6  test.in"  "${test_bin_folder_path}/hmac256" "testing" test.in

  )
}

# -----------------------------------------------------------------------------

function build_libassuan()
{
  # https://gnupg.org/ftp/gcrypt/libassuan
  # https://gnupg.org/ftp/gcrypt/libassuan/libassuan-2.5.3.tar.bz2

  # https://github.com/archlinux/svntogit-packages/blob/packages/libassuan/trunk/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/libassuan/files/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/libassuan.rb

  # 2019-02-11, "2.5.3"
  # 2021-03-22, "2.5.5"

  local libassuan_version="$1"

  local libassuan_src_folder_name="libassuan-${libassuan_version}"

  local libassuan_archive="${libassuan_src_folder_name}.tar.bz2"
  local libassuan_url="https://gnupg.org/ftp/gcrypt/libassuan/${libassuan_archive}"

  local libassuan_folder_name="${libassuan_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libassuan_folder_name}"

  local libassuan_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${libassuan_folder_name}-installed"
  if [ ! -f "${libassuan_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libassuan_url}" "${libassuan_archive}" \
      "${libassuan_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libassuan_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${libassuan_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running libassuan configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libassuan_src_folder_name}/configure" --help
          fi

          config_options=()

          # Exception: use LIBS_INSTALL_*.
          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          config_options+=("--with-libgpg-error-prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--enable-static") # HB

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${libassuan_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libassuan_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libassuan_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running libassuan make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libassuan_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libassuan_src_folder_name}" \
        "${libassuan_folder_name}"
    )

    (
      test_libassuan_libs
      test_libassuan "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"

    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libassuan_folder_name}/test-output-$(ndate).txt"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libassuan_stamp_file_path}"

  else
    echo "Library libassuan already installed."
  fi

  tests_add "test_libassuan" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
}

function test_libassuan_libs()
{
  echo
  echo "Checking the libassuan shared libraries..."

  # show_libs "${XBB_INSTALL_FOLDER_PATH}/bin/libassuan-config"
  show_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libassuan.${XBB_SHLIB_EXT}"
}

function test_libassuan()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Testing if libassuan binaries start properly..."

    run_app "${test_bin_folder_path}/libassuan-config" --version
  )
}

# -----------------------------------------------------------------------------

function build_libksba()
{
  # https://gnupg.org/ftp/gcrypt/libksba
  # https://gnupg.org/ftp/gcrypt/libksba/libksba-1.3.5.tar.bz2

  # https://github.com/archlinux/svntogit-packages/blob/packages/libksba/trunk/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/libksba/files/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/libksba.rb

  # 2016-08-22, "1.3.5"
  # 2021-06-10, "1.6.0"

  local libksba_version="$1"

  local libksba_src_folder_name="libksba-${libksba_version}"

  local libksba_archive="${libksba_src_folder_name}.tar.bz2"
  local libksba_url="https://gnupg.org/ftp/gcrypt/libksba/${libksba_archive}"

  local libksba_folder_name="${libksba_src_folder_name}"

  local libksba_patch_file_name="${libksba_folder_name}.patch"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libksba_folder_name}"

  local libksba_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${libksba_folder_name}-installed"
  if [ ! -f "${libksba_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libksba_url}" "${libksba_archive}" \
      "${libksba_src_folder_name}" "${libksba_patch_file_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libksba_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${libksba_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CC_FOR_BUILD="${CC}"

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running libksba configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libksba_src_folder_name}/configure" --help
          fi

          config_options=()

          # Exception: use LIBS_INSTALL_*.
          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          config_options+=("--with-libgpg-error-prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${libksba_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libksba_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libksba_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running libksba make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libksba_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libksba_src_folder_name}" \
        "${libksba_folder_name}"
    )

    (
      test_libksba_libs
      test_libksba "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libksba_folder_name}/test-output-$(ndate).txt"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libksba_stamp_file_path}"

  else
    echo "Library libksba already installed."
  fi

  tests_add "test_libksba" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
}

function test_libksba_libs()
{
  echo
  echo "Checking the libksba shared libraries..."

  # show_libs "${XBB_INSTALL_FOLDER_PATH}/bin/ksba-config"
  show_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libksba.${XBB_SHLIB_EXT}"
}

function test_libksba()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Testing if libksba binaries start properly..."

    run_app "${test_bin_folder_path}/ksba-config" --version
  )
}

# -----------------------------------------------------------------------------

function build_npth()
{
  # https://gnupg.org/ftp/gcrypt/npth
  # https://gnupg.org/ftp/gcrypt/npth/npth-1.6.tar.bz2

  # https://archlinuxarm.org/packages/aarch64/npth/files/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/npth.rb

  # 2018-07-16, "1.6"

  local npth_version="$1"

  local npth_src_folder_name="npth-${npth_version}"

  local npth_archive="${npth_src_folder_name}.tar.bz2"
  local npth_url="https://gnupg.org/ftp/gcrypt/npth/${npth_archive}"

  local npth_folder_name="${npth_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${npth_folder_name}"

  local npth_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${npth_folder_name}-installed"
  if [ ! -f "${npth_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${npth_url}" "${npth_archive}" \
      "${npth_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${npth_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${npth_folder_name}"

      if [ "${XBB_TARGET_PLATFORM}" == "darwin" ] && [[ ${CC} =~ .*gcc.* ]]
      then
        # /usr/include/os/base.h:113:20: error: missing binary operator before token "("
        # #if __has_extension(attribute_overloadable)
        prepare_clang_env ""
      fi

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running npth configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${npth_src_folder_name}/configure" --help
          fi

          config_options=()

          # Exception: use LIBS_INSTALL_*.
          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${npth_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${npth_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${npth_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running npth make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${npth_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${npth_src_folder_name}" \
        "${npth_folder_name}"
    )

    (
      test_npth_libs
      test_npth "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${npth_folder_name}/test-output-$(ndate).txt"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${npth_stamp_file_path}"

  else
    echo "Library npth already installed."
  fi

  tests_add "test_npth" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
}

function test_npth_libs()
{
  echo
  echo "Checking the npth shared libraries..."

  show_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libnpth.${XBB_SHLIB_EXT}"
}

function test_npth()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the npth shared libraries..."

    run_app "${test_bin_folder_path}/npth-config" --version
  )
}

# -----------------------------------------------------------------------------

function build_nettle()
{
  # https://www.lysator.liu.se/~nisse/nettle/
  # https://ftp.gnu.org/gnu/nettle/

  # https://github.com/archlinux/svntogit-packages/blob/packages/nettle/trunk/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/nettle/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=nettle-git

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/nettle.rb

  # 2017-11-19, "3.4"
  # 2018-12-04, "3.4.1"
  # 2019-06-27, "3.5.1"
  # 2021-06-07, "3.7.3"
  # 2022-07-27, "3.8.1"

  local nettle_version="$1"

  local nettle_src_folder_name="nettle-${nettle_version}"

  local nettle_archive="${nettle_src_folder_name}.tar.gz"
  local nettle_url="ftp://ftp.gnu.org/gnu/nettle/${nettle_archive}"

  local nettle_folder_name="${nettle_src_folder_name}"

  local nettle_patch_file_path="${nettle_folder_name}.patch"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${nettle_folder_name}"

  local nettle_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${nettle_folder_name}-installed"
  if [ ! -f "${nettle_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${nettle_url}" "${nettle_archive}" \
      "${nettle_src_folder_name}" "${nettle_patch_file_path}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${nettle_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${nettle_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running nettle configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${nettle_src_folder_name}/configure" --help
          fi

          # -disable-static

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          # config_options+=("--enable-mini-gmp")
          config_options+=("--enable-shared") # HB

          # config_options+=("--disable-shared") # Arch

          config_options+=("--disable-documentation")
          config_options+=("--disable-arm-neon")
          config_options+=("--disable-assembler")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${nettle_src_folder_name}/configure" \
            "${config_options[@]}"

          if false # is_darwin # && [ "${XBB_LAYER}" == "xbb-bootstrap" ]
          then
            # dlopen failed: dlopen(../libnettle.so, 2): image not found
            # /Users/ilg/Work/xbb-3.1-macosx-x86_64/sources/nettle-3.5.1/run-tests: line 57: 46731 Abort trap: 6           "$1" $testflags
            # darwin: FAIL: dlopen
            run_verbose sed -i.bak \
              -e 's| dlopen-test$(EXEEXT)||' \
              "testsuite/Makefile"
          fi

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${nettle_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${nettle_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running nettle make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        # make install-strip
        # For unknown reasons, on 32-bits make install-info fails
        # (`install-info --info-dir="/opt/xbb/share/info" nettle.info` returns 1)
        # Make the other install targets.
        run_verbose make install-headers install-static install-pkgconfig install-shared-nettle install-shared-hogweed

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          if false # is_darwin
          then
            # dlopen failed: dlopen(../libnettle.so, 2): image not found
            # /Users/ilg/Work/xbb-3.1-macosx-x86_64/sources/nettle-3.5.1/run-tests: line 57: 46731 Abort trap: 6           "$1" $testflags
            # darwin: FAIL: dlopen
            # WARN-TEST
            run_verbose make -j1 -k check
          else
            # Takes very long on armhf.
            run_verbose make -j1 -k check
          fi
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${nettle_folder_name}/make-output-$(ndate).txt"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${nettle_stamp_file_path}"

  else
    echo "Library nettle already installed."
  fi
}

# -----------------------------------------------------------------------------

function build_libusb()
{
  # https://libusb.info/
  # https://github.com/libusb/libusb/releases/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-libusb
  # https://github.com/libusb/libusb/releases/download/v1.0.24/libusb-1.0.24.tar.bz2

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/libusb.rb

  # 2015-09-14, 1.0.20
  # 2018-03-25, 1.0.22
  # 2020-12-11, 1.0.24
  # 2022-04-10, "1.0.26"

  local libusb_version="$1"

  local libusb_src_folder_name="libusb-${libusb_version}"

  local libusb_archive="${libusb_src_folder_name}.tar.bz2"
  local libusb_url="https://github.com/libusb/libusb/releases/download/v${libusb_version}/${libusb_archive}"

  local libusb_folder_name="${libusb_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libusb_folder_name}"

  local libusb_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-libusb-${libusb_version}-installed"
  if [ ! -f "${libusb_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libusb_url}" "${libusb_archive}" \
      "${libusb_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libusb_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${libusb_folder_name}"

      if [ "${XBB_TARGET_PLATFORM}" == "darwin" ] && [[ ${CC} =~ .*gcc.* ]]
      then
        # /Users/ilg/Work/qemu-arm-6.2.0-1/darwin-x64/sources/libusb-1.0.24/libusb/os/darwin_usb.c: In function 'darwin_handle_transfer_completion':
        # /Users/ilg/Work/qemu-arm-6.2.0-1/darwin-x64/sources/libusb-1.0.24/libusb/os/darwin_usb.c:2151:3: error: variable-sized object may not be initialized
        # 2151 |   const char *transfer_types[max_transfer_type + 1] = {"control", "isoc", "bulk", "interrupt", "bulk-stream"};
        prepare_clang_env ""
      fi

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then

        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running libusb configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libusb_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          config_options+=("--disable-dependency-tracking")
          if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
          then
            # On 32-bit Arm `/lib/arm-linux-gnueabihf/libudev.so.1` has
            # a dependency on the system `libgcc_s.so.1` and makes
            # life very difficult.
            config_options+=("--disable-udev")
          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${libusb_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libusb_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libusb_folder_name}/configure-output-$(ndate).txt"

      fi

      (
        echo
        echo "Running libusb make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libusb_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libusb_src_folder_name}" \
        "${libusb_folder_name}"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libusb_stamp_file_path}"

  else
    echo "Library libusb already installed."
  fi
}


# -----------------------------------------------------------------------------

function build_vde()
{
  # Ethernet compliant virtual network
  # https://github.com/virtualsquare/vde-2
  # https://vde.sourceforge.io/
  # https://sourceforge.net/projects/vde/files/vde2/
  # https://downloads.sourceforge.net/project/vde/vde2/2.3.2/vde2-2.3.2.tar.gz

  # https://github.com/archlinux/svntogit-packages/blob/packages/vde2/trunk/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/vde.rb

  # 2011-11-23 "2.3.2"

  local vde_version="$1"

  local vde_src_folder_name="vde2-${vde_version}"

  local vde_archive="${vde_src_folder_name}.tar.gz"
  local vde_url="https://downloads.sourceforge.net/project/vde/vde2/${vde_version}/${vde_archive}"

  local vde_folder_name="${vde_src_folder_name}"
  local vde_patch_file_patch="${vde_folder_name}.patch.diff"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${vde_folder_name}"

  local vde_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${vde_folder_name}-installed"
  if [ ! -f "${vde_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${vde_url}" "${vde_archive}" \
      "${vde_src_folder_name}" "${vde_patch_file_patch}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${vde_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${vde_folder_name}"

      xbb_activate_installed_dev

      # On debug, -O[01] fail with:
      # Undefined symbols for architecture x86_64:
      #   "_ltonstring", referenced from:
      #       _fst_in_bpdu in fstp.o
      #   "_nstringtol", referenced from:
      #       _fst_in_bpdu in fstp.o
      #       _fstprintactive in fstp.o

      CPPFLAGS="$(echo "${XBB_CPPFLAGS}" | sed -e 's|-O0|-O2|')"
      CFLAGS="$(echo "${XBB_CFLAGS_NO_W}" | sed -e 's|-O0|-O2|')"
      CXXFLAGS="$(echo "${XBB_CXXFLAGS_NO_W}" | sed -e 's|-O0|-O2|')"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running vde configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${vde_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          config_options+=("--disable-python")
          # src/vde_cryptcab/cryptcab.c:25:23: error: tentative definition has type 'EVP_CIPHER_CTX' (aka 'struct evp_cipher_ctx_st') that is never completed
          config_options+=("--disable-cryptcab")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${vde_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${vde_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${vde_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running vde make..."

        # Build.
        # *** No rule to make target '../../src/lib/libvdemgmt.la', needed by 'libvdesnmp.la'.  Stop.
        run_verbose make # -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${vde_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${vde_src_folder_name}" \
        "${vde_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${vde_stamp_file_path}"

  else
    echo "Library vde already installed."
  fi
}

# -----------------------------------------------------------------------------

function build_libpcap()
{
  # Portable library for network traffic capture
  # https://www.tcpdump.org/
  # https://www.tcpdump.org/release/
  # https://www.tcpdump.org/release/libpcap-1.10.1.tar.gz

  # https://github.com/archlinux/svntogit-packages/blob/packages/libpcap/trunk/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/libpcap.rb

  # June 9, 2021 "1.10.1"

  local libpcap_version="$1"

  local libpcap_src_folder_name="libpcap-${libpcap_version}"

  local libpcap_archive="${libpcap_src_folder_name}.tar.gz"
  local libpcap_url="https://www.tcpdump.org/release/${libpcap_archive}"

  local libpcap_folder_name="${libpcap_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libpcap_folder_name}"

  local libpcap_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${libpcap_folder_name}-installed"
  if [ ! -f "${libpcap_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libpcap_url}" "${libpcap_archive}" \
      "${libpcap_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libpcap_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${libpcap_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running libpcap configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libpcap_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          # HomeBrew
          config_options+=("--disable-universal")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${libpcap_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libpcap_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libpcap_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running libpcap make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        run_verbose make install

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libpcap_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libpcap_src_folder_name}" \
        "${libpcap_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libpcap_stamp_file_path}"

  else
    echo "Library libpcap already installed."
  fi
}

# -----------------------------------------------------------------------------

function build_libssh()
{
  # C library SSHv1/SSHv2 client and server protocols
  # https://www.libssh.org/
  # https://www.libssh.org/files/
  # https://www.libssh.org/files/0.9/libssh-0.9.6.tar.xz

  # https://github.com/archlinux/svntogit-packages/blob/packages/libssh/trunk/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-libssh

  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-libssh/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/libssh.rb

  # 2021-08-26 "0.9.6"
  # 2022-08-30, "0.10.1"

  local libssh_version="$1"
  local libssh_major_minor_version="$(echo ${libssh_version} | sed -e 's|\([0-9][0-9]*\)\.\([0-9][0-9]*\)\.[0-9].*|\1.\2|')"

  local libssh_src_folder_name="libssh-${libssh_version}"

  local libssh_archive="${libssh_src_folder_name}.tar.xz"
  local libssh_url="https://www.libssh.org/files/${libssh_major_minor_version}/${libssh_archive}"

  local libssh_folder_name="${libssh_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libssh_folder_name}"

  local libssh_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${libssh_folder_name}-installed"
  if [ ! -f "${libssh_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libssh_url}" "${libssh_archive}" \
      "${libssh_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libssh_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${libssh_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      local build_type
      if [ "${XBB_IS_DEBUG}" == "y" ]
      then
        build_type=Debug
      else
        build_type=Release
      fi

      if [ ! -f "CMakeCache.txt" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running libssh cmake..."

          config_options=()

          # TODO: add separate BINS/LIBS.
          config_options+=("-DCMAKE_INSTALL_PREFIX=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          config_options+=("-DBUILD_STATIC_LIB=ON")
          config_options+=("-DWITH_SYMBOL_VERSIONING=OFF")

          # From Arch.
          config_options+=("-DWITH_GSSAPI=OFF")

          # Since CMake insists on picking the system one.
          config_options+=("-DWITH_ZLIB=OFF")

          if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
          then
            # On Linux
            # undefined reference to `__stack_chk_guard'
            config_options+=("-DWITH_STACK_PROTECTOR=OFF")
            config_options+=("-DWITH_STACK_PROTECTOR_STRONG=OFF")
            # config_options+=("-DWITH_STACK_CLASH_PROTECTION=OFF")
          elif [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
          then
            # Otherwise it'll generate two -mmacosx-version-min
            config_options+=("-DCMAKE_OSX_DEPLOYMENT_TARGET=${XBB_MACOSX_DEPLOYMENT_TARGET}")
          fi

          run_verbose cmake \
            "${config_options[@]}" \
            \
            "${XBB_SOURCES_FOLDER_PATH}/${libssh_src_folder_name}"

        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libssh_folder_name}/cmake-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running libssh make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        run_verbose make install

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libssh_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libssh_src_folder_name}" \
        "${libssh_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libssh_stamp_file_path}"

  else
    echo "Library libssh already installed."
  fi
}

# -----------------------------------------------------------------------------

function build_sdl2()
{
  # https://www.libsdl.org/
  # https://www.libsdl.org/release

  # https://archlinuxarm.org/packages/aarch64/sdl2/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=sdl2-hg
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-sdl2

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/sdl2.rb

  # sdl2_version="2.0.3" # 2014-03-16
  # sdl2_version="2.0.5" # 2016-10-20
  # sdl2_version="2.0.9" # 2018-10-31
  # 2021-11-30, "2.0.18"
  # 2022-04-25, "2.0.22"
  # 2022-08-19, "2.24.0"

  local sdl2_version="$1"

  local sdl2_src_folder_name="SDL2-${sdl2_version}"

  local sdl2_archive="${sdl2_src_folder_name}.tar.gz"
  local sdl2_url="https://www.libsdl.org/release/${sdl2_archive}"

  local sdl2_folder_name="${sdl2_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${sdl2_folder_name}"

  local sdl2_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-sdl2-${sdl2_version}-installed"
  if [ ! -f "${sdl2_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${sdl2_url}" "${sdl2_archive}" \
      "${sdl2_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${sdl2_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${sdl2_folder_name}"

      if [ "${XBB_TARGET_PLATFORM}" == "darwin" ] && [[ ${CC} =~ .*gcc.* ]]
      then
        # GNU GCC fails with
        #  CC     build/SDL_syspower.lo
        # In file included from //System/Library/Frameworks/CoreFoundation.framework/Headers/CFPropertyList.h:13,
        #                 from //System/Library/Frameworks/CoreFoundation.framework/Headers/CoreFoundation.h:55,
        #                 from /Users/ilg/Work/qemu-riscv-2.8.0-9/sources/SDL2-2.0.9/src/power/macosx/SDL_syspower.c:26:
        # //System/Library/Frameworks/CoreFoundation.framework/Headers/CFStream.h:249:59: error: unknown type name ‘dispatch_queue_t’
        prepare_clang_env ""
      fi

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then

        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running sdl2 configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${sdl2_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          config_options+=("--enable-video")
          config_options+=("--disable-audio")
          config_options+=("--disable-joystick")
          config_options+=("--disable-haptic")

          if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
          then
            :
          elif [ "${XBB_TARGET_PLATFORM}" == "linux" ]
          then
            config_options+=("--enable-video-opengl")
            config_options+=("--enable-video-x11")
          elif [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
          then
            config_options+=("--without-x")
          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${sdl2_src_folder_name}/configure" \
            ${config_options[@]}

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${sdl2_folder_name}/config-log.txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${sdl2_folder_name}/configure-output.txt"

      fi

      (
        echo
        echo "Running sdl2 make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        run_verbose make install

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${sdl2_folder_name}/make-output.txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${sdl2_src_folder_name}" \
        "${sdl2_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${sdl2_stamp_file_path}"

  else
    echo "Library sdl2 already installed."
  fi
}

function build_sdl2_image()
{
  # https://www.libsdl.org/projects/SDL_image/
  # https://www.libsdl.org/projects/SDL_image/release

  # https://archlinuxarm.org/packages/aarch64/sdl2_image/files
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-sdl2_image

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/sdl2_image.rb

  # sdl2_image_version="1.1"
  # sdl2_image_version="2.0.1" # 2016-01-03
  # sdl2_image_version="2.0.3" # 2018-03-01
  # sdl2_image_version="2.0.4" # 2018-10-31
  # 2019-07-01, "2.0.5"
  # 2022-08-19, "2.6.2"

  local sdl2_image_version="$1"

  local sdl2_image_src_folder_name="SDL2_image-${sdl2_image_version}"

  local sdl2_image_archive="${sdl2_image_src_folder_name}.tar.gz"
  local sdl2_image_url="https://www.libsdl.org/projects/SDL_image/release/${sdl2_image_archive}"

  local sdl2_image_folder_name="${sdl2_image_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${sdl2_image_folder_name}"

  local sdl2_image_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-sdl2-image-${sdl2_image_version}-installed"
  if [ ! -f "${sdl2_image_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${sdl2_image_url}" "${sdl2_image_archive}" \
      "${sdl2_image_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${sdl2_image_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${sdl2_image_folder_name}"

      # The windows build checks this.
      mkdir -pv lib

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      OBJCFLAGS="${XBB_CFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi
      if [ "${XBB_IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export OBJCFLAGS
      export LDFLAGS

      if [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
      then
        export OBJC=clang
      fi

      # export LIBS="-lpng16 -ljpeg"

      env | sort

      if [ ! -f "config.status" ]
      then

        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running sdl2-image configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${sdl2_image_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          config_options+=("--enable-jpg")
          config_options+=("--enable-png")

          config_options+=("--disable-sdltest")
          config_options+=("--disable-jpg-shared")
          config_options+=("--disable-png-shared")
          config_options+=("--disable-bmp")
          config_options+=("--disable-gif")
          config_options+=("--disable-lbm")
          config_options+=("--disable-pcx")
          config_options+=("--disable-pnm")
          config_options+=("--disable-tga")
          config_options+=("--disable-tif")
          config_options+=("--disable-tif-shared")
          config_options+=("--disable-xcf")
          config_options+=("--disable-xpm")
          config_options+=("--disable-xv")
          config_options+=("--disable-webp")
          config_options+=("--disable-webp-shared")

          if [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
          then
            config_options+=("--enable-imageio")
          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${sdl2_image_src_folder_name}/configure" \
            ${config_options[@]}

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${sdl2_image_folder_name}/config-log.txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${sdl2_image_folder_name}/configure-output.txt"

      fi

      (
        echo
        echo "Running sdl2-image make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${sdl2_image_folder_name}/make-output.txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${sdl2_image_src_folder_name}" \
        "${sdl2_image_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${sdl2_image_stamp_file_path}"

  else
    echo "Library sdl2-image already installed."
  fi
}

# -----------------------------------------------------------------------------

function build_pcre2()
{
  # https://github.com/PCRE2Project/pcre2
  # https://github.com/PCRE2Project/pcre2/releases
  # https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.40/pcre2-10.40.tar.bz2

  # https://github.com/archlinux/svntogit-packages/blob/packages/pcre2/trunk/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/pcre2/files/PKGBUILD
  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/pcre2.rb

  # 15 Apr 2022, "10.40"

  local pcre2_version="$1"

  local pcre2_src_folder_name="pcre2-${pcre2_version}"

  local pcre2_archive="${pcre2_src_folder_name}.tar.bz2"
  local pcre2_url="https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${pcre2_version}/${pcre2_archive}"

  local pcre2_folder_name="${pcre2_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${pcre2_folder_name}"

  local pcre2_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${pcre2_folder_name}-installed"
  if [ ! -f "${pcre2_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${pcre2_url}" "${pcre2_archive}" \
      "${pcre2_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${pcre2_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${pcre2_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running pcre2 configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${pcre2_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          config_options+=("--enable-pcre2-16")
          config_options+=("--enable-pcre2-32")
          config_options+=("--enable-jit")
          config_options+=("--enable-pcre2grep-libz")
          config_options+=("--enable-pcre2grep-libbz2")
          # config_options+=("--enable-pcre2test-libreadline")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${pcre2_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${pcre2_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${pcre2_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running pcre2 make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${pcre2_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${pcre2_src_folder_name}" \
        "${pcre2_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${pcre2_stamp_file_path}"

  else
    echo "Library pcre2 already installed."
  fi
}

# -----------------------------------------------------------------------------


function build_termcap()
{
  # https://www.gnu.org/software/termutils/
  # https://ftp.gnu.org/gnu/termcap/
  # https://ftp.gnu.org/gnu/termcap/termcap-1.3.1.tar.gz

  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-termcap/PKGBUILD

  # 2002-03-13, "1.3.1"

  local termcap_version="$1"

  local termcap_src_folder_name="termcap-${termcap_version}"

  local termcap_archive="${termcap_src_folder_name}.tar.gz"
  local termcap_url="https://ftp.gnu.org/gnu/termcap/${termcap_archive}"

  local termcap_folder_name="${termcap_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${termcap_folder_name}"

  local termcap_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${termcap_folder_name}-installed"
  if [ ! -f "${termcap_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    if [ ! -d "${termcap_src_folder_name}" ]
    then
      download_and_extract "${termcap_url}" "${termcap_archive}" \
        "${termcap_src_folder_name}"

      run_verbose sed -i -e 's|char PC;|static char PC;|' \
        "${termcap_src_folder_name}/termcap.c"
    fi

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${termcap_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${termcap_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running termcap configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${termcap_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${termcap_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${termcap_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${termcap_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running termcap make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

        run_verbose make install


      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${termcap_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${termcap_src_folder_name}" \
        "${termcap_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${termcap_stamp_file_path}"

  else
    echo "Library termcap already installed."
  fi
}

# -----------------------------------------------------------------------------
