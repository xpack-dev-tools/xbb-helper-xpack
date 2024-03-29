# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.gnu.org/software/gdb/
# https://ftp.gnu.org/gnu/gdb/
# https://ftp.gnu.org/gnu/gdb/gdb-10.2.tar.xz

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/g/gdb.rb

# GDB Text User Interface
# https://ftp.gnu.org/old-gnu/Manuals/gdb/html_chapter/gdb_19.html#SEC197

# 2019-05-11, "8.3"
# 2020-02-08, "9.1"
# 2020-05-23, "9.2"
# 2020-10-24, "10.1"
# 2021-04-25, "10.2"
# 2022-01-16, "11.2"
# 2022-05-01, "12.1"

# -----------------------------------------------------------------------------

# Called multile times, with and without python support.
# $1="" or $1="-py3"
function gdb_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local gdb_version="$1"

  local gdb_src_folder_name="gdb-${gdb_version}"

  local gdb_archive="${gdb_src_folder_name}.tar.xz"
  local gdb_url="https://ftp.gnu.org/gnu/gdb/${gdb_archive}"

  local gdb_folder_name="${gdb_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${gdb_folder_name}"

  local gdb_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${gdb_folder_name}-installed"

  if [ ! -f "${gdb_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    # Download gdb
    if [ ! -d "${XBB_SOURCES_FOLDER_PATH}/${gdb_src_folder_name}" ]
    then
      download_and_extract "${gdb_url}" "${gdb_archive}" \
        "${gdb_src_folder_name}"
    fi

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${gdb_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${gdb_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        # Used to enable wildcard; inspired by arm-none-eabi-gcc.
        local crt_clob_file_path="$(${CC} --print-file-name=CRT_glob.o)"
        LDFLAGS+=" -Wl,${crt_clob_file_path}"

        # Hack to place the bcrypt library at the end of the list of libraries,
        # to avoid 'undefined reference to BCryptGenRandom'.
        # Using LIBS does not work, the order is important.
        export DEBUGINFOD_LIBS="-lbcrypt"
      fi

      xbb_adjust_ldflags_rpath

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS

      export LDFLAGS
      export LIBS

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running gdb configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${gdb_src_folder_name}/gdb/configure" --help
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

          config_options+=("--with-pkgversion=${XBB_GDB_BRANDING}")

          config_options+=("--with-expat")
          config_options+=("--with-lzma=yes")

          config_options+=("--with-python=no")

          config_options+=("--without-guile")
          config_options+=("--without-babeltrace")
          config_options+=("--without-libunwind-ia64")

          config_options+=("--disable-nls")
          config_options+=("--disable-sim")
          config_options+=("--disable-gas")
          config_options+=("--disable-binutils")
          config_options+=("--disable-ld")
          config_options+=("--disable-gprof")
          config_options+=("--disable-source-highlight")

          if [ "${XBB_HOST_PLATFORM}" == "win32" ]
          then
            config_options+=("--disable-tui")
          else
            config_options+=("--enable-tui")
          fi

          config_options+=("--disable-werror")
          config_options+=("--enable-build-warnings=no")

          # Note that all components are disabled, except GDB.
          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${gdb_src_folder_name}/configure" \
            ${config_options[@]}

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${gdb_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gdb_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running gdb make..."

        # Build.
        run_verbose make -j ${XBB_JOBS} all-gdb

        # install-strip fails, not only because of readline has no install-strip
        # but even after patching it tries to strip a non elf file
        # strip:.../install/riscv-none-gcc/bin/_inst.672_: file format not recognized
        run_verbose make install-gdb

        show_host_libs "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/gdb"

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gdb_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${gdb_src_folder_name}" \
        "${gdb_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${gdb_stamp_file_path}"

  else
    echo "Component gdb already installed"
  fi

  tests_add "gdb_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function gdb_test()
{
  local test_bin_path="$1"

  GDB="${test_bin_path}/gdb"

  show_host_libs "${GDB}"

  run_host_app_verbose "${GDB}" --version
  run_host_app_verbose "${GDB}" --help
  run_host_app_verbose "${GDB}" --config

  # This command is known to fail with 'Abort trap: 6' (SIGABRT)
  # in abnormal builds.
  run_host_app_verbose "${GDB}" \
    --nx \
    --nw \
    --batch \
    -ex 'show language' \
    -ex 'set language auto' \

  # ---------------------------------------------------------------------------
  # Test if GDB is built with correct ELF support.
  (
    # Assume that the compiler was built too.
    CXX="${test_bin_path}/g++"

    rm -rf "${XBB_TESTS_FOLDER_PATH}/gdb"
    mkdir -pv "${XBB_TESTS_FOLDER_PATH}/gdb"
    run_verbose_develop cd "${XBB_TESTS_FOLDER_PATH}/gdb"

    cat <<'__EOF__' > hello.cpp
#include <iostream>

int
main(int argc, char* argv[])
{
  std::cout << "Hello World" << std::endl;

  return 0;
}
__EOF__

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

        run_host_app_verbose "${CXX}" hello.cpp -o hello-cpp.exe -g -v

        run_host_app_verbose "${GDB}" \
          --nx \
          --nw \
          --batch \
          hello-cpp.exe \
          --return-child-result \
          -ex 'run' \

      )
    elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
    then
      (
        export LD_LIBRARY_PATH="$(xbb_get_libs_path "${CXX}" -m64)"
        echo
        echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"

        run_host_app_verbose "${CXX}" hello.cpp -o hello-cpp -g -v

        # Test if GDB is built with correct ELF support.
        run_host_app_verbose "${GDB}" \
          --nx \
          --nw \
          --batch \
          hello-cpp \
          --return-child-result \
          -ex 'run' \

      )
    elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
    then
      if [ "${XBB_HOST_ARCH}" == "x64" ]
      then
        # On macOS x64 10.13:
        # Unable to find Mach task port for process-id 96212: (os/kern) failure (0x5).
        #  (please check gdb is codesigned - see taskgated(8))
        echo "skip gdb check"
      else
        (
          export LD_LIBRARY_PATH="$(xbb_get_libs_path "${CXX}")"
          echo
          echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"

          run_host_app_verbose "${CXX}" hello.cpp -o hello-cpp -g -v

          # echo 'startup-with-shell off' >.gdbinit
          # Test if GDB is built with correct ELF support.
          run_host_app_verbose "${GDB}" \
            -ex 'set startup-with-shell off' \
            --nx \
            --nw \
            --batch \
            hello-cpp \
            --return-child-result \
            -ex 'run' \

        )
      fi
    else
      echo "Unsupported XBB_HOST_PLATFORM=${XBB_HOST_PLATFORM} in ${FUNCNAME[0]}()"
      exit 1
    fi
  )

}

# -----------------------------------------------------------------------------
