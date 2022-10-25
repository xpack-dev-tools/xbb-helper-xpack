# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# TODO: add support for dylib
function build_bzip2()
{
  # https://sourceware.org/bzip2/
  # https://sourceware.org/pub/bzip2/
  # https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz

  # https://github.com/archlinux/svntogit-packages/blob/packages/bzip2/trunk/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/bzip2/files/PKGBUILD

  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-bzip2/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/bzip2.rb

  # 2019-07-13 "1.0.8"

  local bzip2_version="$1"

  local bzip2_src_folder_name="bzip2-${bzip2_version}"

  local bzip2_archive="${bzip2_src_folder_name}.tar.gz"
  local bzip2_url="https://sourceware.org/pub/bzip2/${bzip2_archive}"

  local bzip2_folder_name="${bzip2_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${bzip2_folder_name}"

  local bzip2_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${bzip2_folder_name}-installed"
  if [ ! -f "${bzip2_stamp_file_path}" ]
  then

    echo
    echo "bzip2 in-source building..."

    mkdir -pv "${XBB_BUILD_FOLDER_PATH}"
    cd "${XBB_BUILD_FOLDER_PATH}"

    if [ ! -d "${XBB_BUILD_FOLDER_PATH}/${bzip2_folder_name}" ]
    then
      download_and_extract "${bzip2_url}" "${bzip2_archive}" \
        "${bzip2_src_folder_name}"

      if [ "${bzip2_src_folder_name}" != "${bzip2_folder_name}" ]
      then
        mv -v "${bzip2_src_folder_name}" "${bzip2_folder_name}"
      fi
    fi

    (
      cd "${XBB_BUILD_FOLDER_PATH}/${bzip2_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      # libbz2.a(bzlib.o): relocation R_X86_64_PC32 against symbol `BZ2_crc32Table' can not be used when making a shared object; recompile with -fPIC
      CFLAGS="${XBB_CFLAGS_NO_W} -fPIC --param max-inline-insns-single=500"
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

      (
        if [ "${XBB_IS_DEVELOP}" == "y" ]
        then
          env | sort
        fi

        echo
        echo "Running bzip2 make..."

        if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
        then
          # Build.
          run_verbose make all -j ${XBB_JOBS} \
            PREFIX=${XBB_LIBRARIES_INSTALL_FOLDER_PATH} \
            CC="${CC} ${CPPFLAGS} ${CFLAGS} ${LDFLAGS}" \
            AR=${AR} \
            RANLIB=${RANLIB} \
            LDFLAGS=${LDFLAGS} \

          run_verbose make install PREFIX="${XBB_LIBRARIES_INSTALL_FOLDER_PATH}"

          if [ "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}" != "${XBB_BINARIES_INSTALL_FOLDER_PATH}" ]
          then
            run_verbose make install PREFIX="${XBB_BINARIES_INSTALL_FOLDER_PATH}"
            rm -rfv "${XBB_BINARIES_INSTALL_FOLDER_PATH}/lib/libbz2.a"
            rm -rfv "${XBB_BINARIES_INSTALL_FOLDER_PATH}/include/bzlib.h"
          fi

          if [ "${XBB_WITH_TESTS}" == "y" ]
          then
            run_verbose make test
          fi

          # Once again for the shared library.
          run_verbose make clean

          # Build the shared library.
          run_verbose make all -f Makefile-libbz2_so -j ${XBB_JOBS} \
            PREFIX=${XBB_LIBRARIES_INSTALL_FOLDER_PATH} \
            CC="${CC} ${CPPFLAGS} ${CFLAGS} ${LDFLAGS}" \
            AR=${AR} \
            RANLIB=${RANLIB} \
            LDFLAGS=${LDFLAGS} \

          mkdir -pv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/"
          install -v -c -m 644 "libbz2.so.${bzip2_version}" "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/"

          (
            cd "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/"

            rm -rfv libbz2.so*
            ln -sv "libbz2.so.${bzip2_version}" libbz2.so.1.0
            ln -sv "libbz2.so.${bzip2_version}" libbz2.so.1
            ln -sv "libbz2.so.${bzip2_version}" libbz2.so
          )

          create_bzip2_pc

        elif [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
        then

          # Build.
          run_verbose make all -j ${XBB_JOBS} \
            PREFIX=${XBB_LIBRARIES_INSTALL_FOLDER_PATH} \
            CC="${CC} ${CPPFLAGS} ${CFLAGS} ${LDFLAGS}" \
            AR=${AR} \
            RANLIB=${RANLIB} \
            LDFLAGS=${LDFLAGS} \

          run_verbose make install PREFIX="${XBB_LIBRARIES_INSTALL_FOLDER_PATH}"

          if [ "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}" != "${XBB_BINARIES_INSTALL_FOLDER_PATH}" ]
          then
            run_verbose make install PREFIX="${XBB_BINARIES_INSTALL_FOLDER_PATH}"
            rm -rfv "${XBB_BINARIES_INSTALL_FOLDER_PATH}/lib/libbz2.a"
            rm -rfv "${XBB_BINARIES_INSTALL_FOLDER_PATH}/include/bzlib.h"
          fi

          if [ "${XBB_WITH_TESTS}" == "y" ]
          then
            run_verbose make test
          fi

          # Once again for the shared library.
          run_verbose make clean

          # Build the shared library.
          cp "${helper_folder_path}/extras/Makefile-libbz2_dylib" .
          run_verbose make all -f Makefile-libbz2_dylib -j ${XBB_JOBS} \
            PREFIX=${XBB_LIBRARIES_INSTALL_FOLDER_PATH} \
            CC="${CC} ${CPPFLAGS} ${CFLAGS} ${LDFLAGS}" \
            AR=${AR} \
            RANLIB=${RANLIB} \
            LDFLAGS=${LDFLAGS} \

          mkdir -pv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/"
          install -v -c -m 644 "libbz2.${bzip2_version}.dylib" "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/"

          (
            cd "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/"

            rm -rfv libbz2.dylib libbz2.1.dylib libbz2.1.0.dylib
            ln -sv "libbz2.${bzip2_version}.dylib" libbz2.1.0.dylib
            ln -sv "libbz2.${bzip2_version}.dylib" libbz2.1.dylib
            ln -sv "libbz2.${bzip2_version}.dylib" libbz2.dylib
          )

          create_bzip2_pc

        elif [ "${XBB_TARGET_PLATFORM}" == "win32" ]
        then

          run_verbose make libbz2.a bzip2 bzip2recover -j ${XBB_JOBS} \
            PREFIX=${XBB_LIBRARIES_INSTALL_FOLDER_PATH} \
            CC="${CC} ${CPPFLAGS} ${CFLAGS} ${LDFLAGS}" \
            AR=${AR} \
            RANLIB=${RANLIB} \
            LDFLAGS=${LDFLAGS} \

          mkdir -p "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include"
          run_verbose cp bzlib.h "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include"
          mkdir -p "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib"
          run_verbose cp libbz2.a "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib"
          mkdir -p "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin"
          run_verbose cp bzip2.exe "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin"
          run_verbose cp bzip2recover.exe "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin"

        fi

        if [ "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}" != "${XBB_BINARIES_INSTALL_FOLDER_PATH}" ]
        then
          (
            cd "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"

            # For unknown reasons, the original links are absolute.
            # Make them relative to the current folder.
            if [ -L "bzcmp "]
            then
              rm bzcmp
              ln -s bzdiff bzcmp
            fi

            if [ -L "bzegrep" ]
            then
              rm bzegrep
              ln -s bzgrep bzegrep
            fi

            if [ -L "bzfgrep" ]
            then
              rm bzfgrep
              ln -s bzgrep bzfgrep
            fi

            if [ -L "bzless" ]
            then
              rm bzless
              ln -s bzmore bzless
            fi
          )
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${bzip2_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_BUILD_FOLDER_PATH}/${bzip2_folder_name}" \
        "${bzip2_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${bzip2_stamp_file_path}"

  else
    echo "Library bzip2 already installed."
  fi
}

function create_bzip2_pc()
{
  mkdir -p "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/pkgconfig"
  # Note: __EOF__ is NOT quoted to allow substitutions.
  cat <<__EOF__ >"${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/pkgconfig/bzip2.pc"
prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}
exec_prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}
bindir=\${exec_prefix}/bin
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: bzip2
Description: A file compression library
Version: ${bzip2_version}
Libs: -L\${libdir} -lbz2
Cflags: -I\${includedir}
__EOF__

  run_verbose cat "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/pkgconfig/bzip2.pc"
}

# -----------------------------------------------------------------------------
