# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

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

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
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
          echo "Running libelf configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libelf_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

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
      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS} -I${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/ncurses"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      # LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC}"
      LDFLAGS="${XBB_LDFLAGS_APP}"
      xbb_adjust_ldflags_rpath

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

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--with-dbmliborder=gdbm:ndbm")

          config_options+=("--without-ensurepip")
          config_options+=("--without-lto")

          # Create the PythonX.Y.so.
          config_options+=("--enable-shared")

          if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
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

    show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/python2.${XBB_PYTHON2_VERSION_MINOR}"
    show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libpython${XBB_PYTHON2_VERSION_MAJOR}.${XBB_PYTHON2_VERSION_MINOR}.${XBB_HOST_SHLIB_EXT}"

    echo
    echo "Testing if the python2 binary starts properly..."

    export LD_LIBRARY_PATH="${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib"
    run_app_verbose "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/python2.${XBB_PYTHON2_VERSION_MINOR}" --version

    run_app_verbose "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/python2.${XBB_PYTHON2_VERSION_MINOR}" -c 'import sys; print(sys.path)'
    run_app_verbose "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/python2.${XBB_PYTHON2_VERSION_MINOR}" -c 'import sys; print(sys.prefix)'
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

  if [ "${XBB_HOST_BITS}" == "32" ]
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

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      xbb_adjust_ldflags_rpath

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

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

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

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
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
          echo "Running libgpg-error configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libgpg_error_src_folder_name}/configure" --help
          fi

          config_options=()

          # Exception: use LIBS_INSTALL_*.
          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

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

  show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libgpg-error.${XBB_HOST_SHLIB_EXT}"
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

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
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
          echo "Running libgcrypt configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libgcrypt_src_folder_name}/configure" --help
          fi

          config_options=()

          # Exception: use LIBS_INSTALL_*.
          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          config_options+=("--with-libgpg-error-prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          config_options+=("--disable-doc")
          config_options+=("--disable-large-data-tests")

          # For Darwin, there are problems with the assembly code.
          config_options+=("--disable-asm") # HB
          config_options+=("--disable-amd64-as-feature-detection")

          config_options+=("--disable-padlock-support") # Arch

          if [ "${XBB_BUILD_MACHINE}" != "aarch64" ]
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

          if false # [ "${XBB_BUILD_MACHINE}" != "aarch64" ]
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
      test_libgcrypt "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libgcrypt_folder_name}/test-output-$(ndate).txt"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libgcrypt_stamp_file_path}"

  else
    echo "Library libgcrypt already installed."
  fi

  tests_add "test_libgcrypt" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function test_libgcrypt_libs()
{
  echo
  echo "Checking the libgcrypt shared libraries..."

  # show_host_libs "${XBB_INSTALL_FOLDER_PATH}/bin/libgcrypt-config"
  show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/dumpsexp"
  show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/hmac256"
  show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/mpicalc"

  show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libgcrypt.${XBB_HOST_SHLIB_EXT}"
}

function test_libgcrypt()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the libgcrypt shared libraries..."

    # show_host_libs "${XBB_INSTALL_FOLDER_PATH}/bin/libgcrypt-config"
    show_host_libs "${test_bin_folder_path}/dumpsexp"
    show_host_libs "${test_bin_folder_path}/hmac256"
    show_host_libs "${test_bin_folder_path}/mpicalc"

    echo
    echo "Testing if libgcrypt binaries start properly..."

    run_app_verbose "${test_bin_folder_path}/libgcrypt-config" --version
    run_app_verbose "${test_bin_folder_path}/dumpsexp" --version
    run_app_verbose "${test_bin_folder_path}/hmac256" --version
    run_app_verbose "${test_bin_folder_path}/mpicalc" --version

    # --help not available
    # run_app_verbose "${test_bin_folder_path}/hmac256" --help

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

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
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
          echo "Running libassuan configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libassuan_src_folder_name}/configure" --help
          fi

          config_options=()

          # Exception: use LIBS_INSTALL_*.
          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

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
      test_libassuan "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"

    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libassuan_folder_name}/test-output-$(ndate).txt"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libassuan_stamp_file_path}"

  else
    echo "Library libassuan already installed."
  fi

  tests_add "test_libassuan" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function test_libassuan_libs()
{
  echo
  echo "Checking the libassuan shared libraries..."

  # show_host_libs "${XBB_INSTALL_FOLDER_PATH}/bin/libassuan-config"
  show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libassuan.${XBB_HOST_SHLIB_EXT}"
}

function test_libassuan()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Testing if libassuan binaries start properly..."

    run_app_verbose "${test_bin_folder_path}/libassuan-config" --version
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

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      xbb_adjust_ldflags_rpath

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
          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

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
      test_libksba "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libksba_folder_name}/test-output-$(ndate).txt"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libksba_stamp_file_path}"

  else
    echo "Library libksba already installed."
  fi

  tests_add "test_libksba" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function test_libksba_libs()
{
  echo
  echo "Checking the libksba shared libraries..."

  # show_host_libs "${XBB_INSTALL_FOLDER_PATH}/bin/ksba-config"
  show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libksba.${XBB_HOST_SHLIB_EXT}"
}

function test_libksba()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Testing if libksba binaries start properly..."

    run_app_verbose "${test_bin_folder_path}/ksba-config" --version
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

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
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
          echo "Running npth configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${npth_src_folder_name}/configure" --help
          fi

          config_options=()

          # Exception: use LIBS_INSTALL_*.
          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

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
      test_npth "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${npth_folder_name}/test-output-$(ndate).txt"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${npth_stamp_file_path}"

  else
    echo "Library npth already installed."
  fi

  tests_add "test_npth" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function test_npth_libs()
{
  echo
  echo "Checking the npth shared libraries..."

  show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libnpth.${XBB_HOST_SHLIB_EXT}"
}

function test_npth()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the npth shared libraries..."

    run_app_verbose "${test_bin_folder_path}/npth-config" --version
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

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
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
          echo "Running libusb configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libusb_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          config_options+=("--disable-dependency-tracking")
          if [ "${XBB_HOST_PLATFORM}" == "linux" ]
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
