# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.python.org
# https://www.python.org/downloads/source/
# https://www.python.org/ftp/python/
# https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tar.xz

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/p/python@3.10.rb

## https://gitlab.archlinux.org/archlinux/packaging/packages/python/-/blob/main/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/python/files/PKGBUILD
# https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/python
# https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/python-pip

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/p/python@3.9.rb

# 2018-12-24, "3.7.2"
# March 25, 2019, "3.7.3"
# Dec. 18, 2019, "3.8.1"
# 17-Aug-2020, "3.7.9"
# 23-Sep-2020, "3.8.6"
# May 3, 2021 "3.8.10"
# May 3, 2021 "3.9.5"
# Aug. 30, 2021, "3.8.12"
# Aug. 30, 2021, "3.9.7"
# Sept. 4, 2021, "3.7.12"
# 24-Mar-2022, "3.9.12"
# 23-Mar-2022, "3.10.4"


# TODO:
# Check why some modules (like openssl) are not built

# https://stackoverflow.com/questions/44150871/embeded-python3-6-with-mingw-in-c-fail-on-linking

# -----------------------------------------------------------------------------

function python3_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local python3_version="$1"

  local python3_version_major=$(xbb_get_version_major "${python3_version}")
  local python3_version_minor=$(xbb_get_version_minor "${python3_version}")

  local python3_src_folder_name="${XBB_PYTHON3_SRC_FOLDER_NAME:-Python-${python3_version}}"

  local python3_archive="${python3_src_folder_name}.tar.xz"
  local python3_url="https://www.python.org/ftp/python/${python3_version}/${python3_archive}"

  local python3_folder_name="python-${python3_version}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${python3_folder_name}"

  local python3_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${python3_folder_name}-installed"
  if [ ! -f "${python3_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${python3_url}" "${python3_archive}" \
      "${python3_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${python3_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${python3_folder_name}"

      # GCC chokes on dynamic sizes:
      # error: variably modified ‘bytes’ at file scope
      # char bytes[kAuthorizationExternalFormLength];
      # -DkAuthorizationExternalFormLength=32 not working

      # To pick the new libraries
      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS} -I${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/ncurses"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      if [[ $(basename "${CC}") =~ .*gcc.* ]]
      then
        # Inspired from Arch; not supported by clang.
        CFLAGS+=" -fno-semantic-interposition"
        CXXFLAGS+=" -fno-semantic-interposition"
        LDFLAGS+=" -fno-semantic-interposition"
      fi

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
          echo "Running python3 configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${python3_src_folder_name}/configure" --help
          fi

          # Fail on macOS:
          # --enable-universalsdk
          # --with-lto

          # "... you should not skip tests when using --enable-optimizations as
          # the data required for profiling is generated by running tests".

          # --enable-optimizations takes too long

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

          # Exception: use BINS_INSTALL_*.
          config_options+=("--libdir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib")

          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--infodir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/info")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")
          config_options+=("--htmldir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/html")
          config_options+=("--pdfdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/pdf")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          config_options+=("--without-ensurepip") # HB, Arch

          config_options+=("--with-universal-archs=${XBB_TARGET_BITS}-bit")
          config_options+=("--with-computed-gotos") # Arch
          config_options+=("--with-dbmliborder=gdbm:ndbm") # HB, Arch

          config_options+=("--with-lto") # HB, Arch

          config_options+=("--with-system-expat") # HB, Arch
          config_options+=("--with-system-ffi") # HB, Arch
          config_options+=("--with-system-libmpdec") # HB, Arch

          # config_options+=("--with-dtrace") # HB

          # config_options+=("--with-openssl=${XBB_INSTALL_FOLDER_PATH}")

          # Create the PythonX.Y.so.
          config_options+=("--enable-shared") # HB, Arch

          config_options+=("--enable-optimizations") # HB, Arch

          # config_options+=("--enable-ipv6") # HB, Arch

          # config_options+=("--enable-loadable-sqlite-extensions") # HB, Arch
          config_options+=("--disable-loadable-sqlite-extensions")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${python3_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${python3_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${python3_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running python3 make..."

        # export LD_RUN_PATH="${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib"

        # Build.
        run_verbose make -j ${XBB_JOBS} # build_all

        run_verbose make altinstall

        (
          run_verbose_develop cd "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
          run_verbose ln -svf "python${XBB_PYTHON3_VERSION_MAJOR}.${XBB_PYTHON3_VERSION_MINOR}" \
            "python${XBB_PYTHON3_VERSION_MAJOR}"
        )

        # Hundreds of tests, take a lot of time.
        # Many failures.
        if false # [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 quicktest
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${python3_folder_name}/make-output-$(ndate).txt"
    )

    (
      python3_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${python3_folder_name}/test-output-$(ndate).txt"

    copy_license \
      "${XBB_SOURCES_FOLDER_PATH}/${python3_src_folder_name}" \
      "${python3_folder_name}"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${python3_stamp_file_path}"

  else
    echo "Component python3 already installed"
  fi

  tests_add "python3_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function python3_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the python3 binary shared libraries..."

    show_host_libs "$(dirname $(${REALPATH} ${test_bin_folder_path}/python3))/../lib/libpython3"*."${XBB_HOST_SHLIB_EXT}"

    echo
    echo "Testing if the python3 binary starts properly..."

    # if [ "${XBB_HOST_PLATFORM}" == "linux" ]
    # then
    #   export LD_LIBRARY_PATH="${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib"
    # fi

    run_host_app_verbose "${test_bin_folder_path}/python3" --version

    run_host_app_verbose "${test_bin_folder_path}/python3" -c 'import sys; print(sys.path)'
    run_host_app_verbose "${test_bin_folder_path}/python3" -c 'import sys; print(sys.prefix)'
  )
}

# -----------------------------------------------------------------------------

# Download the Windows Python 3 libraries and headers.
function python3_download_win()
{
  # https://www.python.org/downloads/windows/
  # https://www.python.org/downloads/release/python-372/
  # https://www.python.org/ftp/python/3.7.2/python-3.7.2.post1-embed-win32.zip
  # https://www.python.org/ftp/python/3.7.2/python-3.7.2.post1-embed-amd64.zip
  # https://www.python.org/ftp/python/3.7.2/python-3.7.2.exe
  # https://www.python.org/ftp/python/3.7.2/python-3.7.2-amd64.exe
  # https://www.python.org/ftp/python/3.7.2/Python-3.7.2.tar.xz
  # https://www.python.org/ftp/python/3.7.6/
  # https://www.python.org/ftp/python/3.7.6/python-3.7.6-embed-amd64.zip
  # https://www.python.org/ftp/python/3.7.6/python-3.7.6-embed-win32.zip

  local python3_win_version="$1"

  # Version 3.7.2 uses a longer name, like python-3.7.2.post1-embed-amd64.zip.
  if [ "${XBB_HOST_BITS}" == "32" ]
  then
    XBB_PYTHON3_WIN_SRC_FOLDER_NAME="python-${python3_win_version}-embed-win32"
  else
    XBB_PYTHON3_WIN_SRC_FOLDER_NAME="python-${python3_win_version}-embed-amd64"
  fi

  # Used in python3-config.sh
  export XBB_PYTHON3_WIN_SRC_FOLDER_NAME

  local python3_win_embed_pack="${XBB_PYTHON3_WIN_SRC_FOLDER_NAME}.zip"
  local python3_win_embed_url="https://www.python.org/ftp/python/${python3_win_version}/${python3_win_embed_pack}"

  (
    if [ ! -d "${XBB_SOURCES_FOLDER_PATH}/${XBB_PYTHON3_WIN_SRC_FOLDER_NAME}" ]
    then
      download "${python3_win_embed_url}" "${python3_win_embed_pack}"

      # The archive has no folders, so extract it manually.
      mkdir -pv "${XBB_SOURCES_FOLDER_PATH}/${XBB_PYTHON3_WIN_SRC_FOLDER_NAME}"
      run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}/${XBB_PYTHON3_WIN_SRC_FOLDER_NAME}"
      run_verbose_develop unzip "${XBB_DOWNLOAD_FOLDER_PATH}/${python3_win_embed_pack}"
    else
      echo
      echo "Folder ${XBB_PYTHON3_WIN_SRC_FOLDER_NAME} already present"
    fi

    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}/${XBB_PYTHON3_WIN_SRC_FOLDER_NAME}"
    echo
    echo "# Copying python${XBB_PYTHON3_VERSION_MAJOR}${XBB_PYTHON3_VERSION_MINOR}.dll..."
    # From here it'll be copied as dependency.
    mkdir -pv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/"
    run_verbose ${INSTALL} -v -c -m 644 "python${XBB_PYTHON3_VERSION_MAJOR}.dll" \
      "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/"
    run_verbose ${INSTALL} -v -c -m 644 "python${XBB_PYTHON3_VERSION_MAJOR}${XBB_PYTHON3_VERSION_MINOR}.dll" \
      "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/"
  )

  (
    # export XBB_PYTHON3_SRC_FOLDER_NAME="Python-${python3_win_version}"

    local python3_archive="${XBB_PYTHON3_SRC_FOLDER_NAME}.tar.xz"
    local python3_url="https://www.python.org/ftp/python/${python3_win_version}/${python3_archive}"

    # The full source is needed for the headers.
    if [ ! -d "${XBB_SOURCES_FOLDER_PATH}/${XBB_PYTHON3_SRC_FOLDER_NAME}" ]
    then
      run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

      download_and_extract "${python3_url}" "${python3_archive}" \
        "${XBB_PYTHON3_SRC_FOLDER_NAME}"
    fi
  )
}

# -----------------------------------------------------------------------------

# Used by gdb-py3 on Windows. The default paths on Windows are different
# from POSIX.
function python3_copy_win_syslibs()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  if [ "${XBB_HOST_PLATFORM}" == "win32" ]
  then
    echo
    echo "Copying .pyd & .dll files from the embedded Python distribution..."
    mkdir -pv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    cp -v "${XBB_SOURCES_FOLDER_PATH}/${XBB_PYTHON3_WIN_SRC_FOLDER_NAME}/python${XBB_PYTHON3_VERSION_MAJOR}${XBB_PYTHON3_VERSION_MINOR}.zip"\
      "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"

    mkdir -pv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/DLLs"
    cp -v "${XBB_SOURCES_FOLDER_PATH}/${XBB_PYTHON3_WIN_SRC_FOLDER_NAME}"/*.pyd \
      "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/DLLs"
    cp -v "${XBB_SOURCES_FOLDER_PATH}/${XBB_PYTHON3_WIN_SRC_FOLDER_NAME}"/*.dll \
      "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/DLLs"
  fi
}

# Used by gdb-py3 on POSIX and by packages with full
# control over path (like meson) on all platforms.
function python3_copy_syslibs()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local python_with_version="python${XBB_PYTHON3_VERSION_MAJOR}.${XBB_PYTHON3_VERSION_MINOR}"
  if [ ! -d "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib/${python_with_version}/" ]
  then
    (
      mkdir -pv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib/${python_with_version}/"

      (
        echo
        echo "Copying .py files from the standard Python library..."

        # Copy all .py from the original source package.
        cp -r "${XBB_SOURCES_FOLDER_PATH}/${XBB_PYTHON3_SRC_FOLDER_NAME}"/Lib/* \
          "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib/${python_with_version}/"

        echo "Compiling all python sources..."
        if [ "${XBB_HOST_PLATFORM}" == "win32" ]
        then
          run_verbose "${XBB_TARGET_WORK_FOLDER_PATH}/${LINUX_INSTALL_RELATIVE_PATH}/libs/bin/python3.${XBB_PYTHON3_VERSION_MINOR}" \
            -m compileall \
            -j "${XBB_JOBS}" \
            -f "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib/${python_with_version}/" \
            || true
        else
          # Compiling tests fails, ignore the errors.
          run_verbose "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/python3.${XBB_PYTHON3_VERSION_MINOR}" \
            -m compileall \
            -j "${XBB_JOBS}" \
            -f "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib/${python_with_version}/" \
            || true
        fi

        # For just in case.
        find "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib/${python_with_version}/" \
          \( -name '*.opt-1.pyc' -o -name '*.opt-2.pyc' \) \
          -exec rm -v '{}' ';'
      )

      echo "Replacing .py files with .pyc files..."
      python3_move_pyc "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib/${python_with_version}"

      mkdir -pv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib/${python_with_version}/lib-dynload/"

      echo
      echo "Copying Python shared libraries..."

      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        # Copy the Windows specific DLLs (.pyd) to the separate folder;
        # they are dynamically loaded by Python.
        cp -v "${XBB_SOURCES_FOLDER_PATH}/${XBB_PYTHON3_WIN_SRC_FOLDER_NAME}"/*.pyd \
          "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib/${python_with_version}/lib-dynload/"
        # Copy the usual DLLs too; the python*.dll are used, do not remove them.
        cp -v "${XBB_SOURCES_FOLDER_PATH}/${XBB_PYTHON3_WIN_SRC_FOLDER_NAME}"/*.dll \
          "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib/${python_with_version}/lib-dynload/"
      else
        # Copy dynamically loaded modules and rename folder.
        cp -rv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/python${XBB_PYTHON3_VERSION_MAJOR}.${XBB_PYTHON3_VERSION_MINOR}"/lib-dynload/* \
          "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/lib/${python_with_version}/lib-dynload/"
      fi
    )
  fi
}

function python3_process_pyc()
{
  local file_path="$1"

  # echo bbb "${file_path}"

  local file_full_name="$(basename "${file_path}")"
  local file_name="$(echo "${file_full_name}" | sed -e 's|[.]cpython-[0-9]*[.]pyc||')"
  local folder_path="$(dirname $(dirname "${file_path}"))"

  # echo "${folder_path}" "${file_name}"

  if [ -f "${folder_path}/${file_name}.py" ]
  then
    mv "${file_path}" "${folder_path}/${file_name}.pyc"
    rm "${folder_path}/${file_name}.py"
  fi
}

export -f python3_process_pyc

function python3_process_pycache()
{
  local folder_path="$1"

  find ${folder_path} -name '*.pyc' -type f -print0 | xargs -0 -L 1 -I {} bash -c 'python3_process_pyc "{}"'

  if [ $(ls -1 "${folder_path}" | wc -l) -eq 0 ]
  then
    rm -rf "${folder_path}"
  fi
}

export -f python3_process_pycache

function python3_move_pyc()
{
  local folder_path="$1"

  find ${folder_path} -name '__pycache__' -type d -print0 | xargs -0 -L 1 -I {} bash -c 'python3_process_pycache "{}"'
}

# -----------------------------------------------------------------------------
