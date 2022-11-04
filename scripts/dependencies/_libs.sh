# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

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
          xbb_activate_cxx_rpath
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
          xbb_show_env_develop

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
          xbb_activate_cxx_rpath
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
          xbb_show_env_develop

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
          xbb_activate_cxx_rpath
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
          xbb_show_env_develop

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
        xbb_activate_cxx_rpath
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
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
        xbb_activate_cxx_rpath
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
          xbb_show_env_develop

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

      # LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC}"
      LDFLAGS="${XBB_LDFLAGS_APP}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        xbb_activate_cxx_rpath
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
          xbb_show_env_develop

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
        xbb_activate_cxx_rpath
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
          xbb_show_env_develop

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
        xbb_activate_cxx_rpath
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
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
        xbb_activate_cxx_rpath
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
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
        xbb_activate_cxx_rpath
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
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
        xbb_activate_cxx_rpath
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
          xbb_show_env_develop

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

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        xbb_activate_cxx_rpath
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
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

# used by qemu, in fact it should have been libusb1.
function _build_libusb()
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

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        xbb_activate_cxx_rpath
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
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
