# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# https://www.gnu.org/software/flex/
# https://github.com/westes/flex/releases
# https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz

# https://archlinuxarm.org/packages/aarch64/flex/files/PKGBUILD
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=flex-git

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/f/flex.rb

# Apple uses 2.5.3
# Ubuntu 12 uses 2.5.35
#
# May 6, 2017, "2.6.4"

# -----------------------------------------------------------------------------

function flex_build()
{
  # 30 Dec 2016, "2.6.3"
  # On Ubuntu 18, it fails while building wine with
  # /opt/xbb/lib/gcc/x86_64-w64-mingw32/9.2.0/../../../../x86_64-w64-mingw32/bin/ld: macro.lex.yy.cross.o: in function `yylex':
  # /root/Work/xbb-3.1-ubuntu-18.04-x86_64/build/wine-5.1/programs/winhlp32/macro.lex.yy.c:1031: undefined reference to `yywrap'
  # collect2: error: ld returned 1 exit status

  # May 6, 2017, "2.6.4" (latest)
  # On Ubuntu 18 it crashes (due to an autotool issue) with
  # ./stage1flex   -o stage1scan.c /home/ilg/Work/xbb-bootstrap/sources/flex-2.6.4/src/scan.l
  # make[2]: *** [Makefile:1696: stage1scan.c] Segmentation fault (core dumped)
  # The patch from Arch should fix it.
  # https://archlinuxarm.org/packages/aarch64/flex/files/flex-pie.patch

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local flex_version="$1"

  local flex_src_folder_name="flex-${flex_version}"

  local flex_archive="${flex_src_folder_name}.tar.gz"
  local flex_url="https://github.com/westes/flex/releases/download/v${flex_version}/${flex_archive}"

  local flex_folder_name="${flex_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${flex_folder_name}"

  local flex_patch_file_name="${flex_folder_name}.git.patch"
  local flex_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${flex_folder_name}-installed"
  if [ ! -f "${flex_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${flex_url}" "${flex_archive}" \
      "${flex_src_folder_name}" \
      "${flex_patch_file_name}"

    (
      run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}/${flex_src_folder_name}"
      if [ ! -f "stamp-autogen" ]
      then

        xbb_activate_installed_bin
        xbb_activate_dependencies_dev

        run_verbose bash ${DEBUG} "autogen.sh"

        # No longer needed, done in libtool.
        # patch -p0 <"${helper_folder_path}/patches/flex-2.4.6-libtool.patch"

        touch "stamp-autogen"

      fi
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${flex_folder_name}/autogen-output-$(ndate).txt"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${flex_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${flex_folder_name}"

      xbb_activate_dependencies_dev

      # make[2]: *** [Makefile:1834: stage1scan.c] Segmentation fault (core dumped)
      CPPFLAGS="${XBB_CPPFLAGS} -D_GNU_SOURCE"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

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
          echo "Running flex configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${flex_src_folder_name}/configure" --help
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

          config_options+=("--enable-shared") # HB

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--disable-nls")

          config_options+=("--disable-warnings")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${flex_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${flex_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${flex_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running flex make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        # Keep only the static library, it is small.
        find "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib" -type f -not -name '*.a' -exec rm -rf '{}' ';'
        find "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib" -type l -exec rm -rf '{}' ';'

        # Remove documentation
        run_verbose rm -rfv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/share"

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          # cxx_restart fails - https://github.com/westes/flex/issues/98
          # make -k check || true
          if [ "${XBB_HOST_PLATFORM}" == "darwin" ] && [ "${XBB_HOST_ARCH}" == "arm64" ]
          then
            : # Fails with internal error, caused by gm4
          else
            run_verbose make -k check
          fi
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${flex_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${flex_src_folder_name}" \
        "${flex_folder_name}"
    )

    (
      flex_test_libs
      flex_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${flex_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${flex_stamp_file_path}"

  else
    echo "Component flex already installed"
  fi

  tests_add "flex_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function flex_test_libs()
{
  echo
  echo "Checking the flex shared libraries..."

  show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libfl.${XBB_HOST_SHLIB_EXT}"
}

function flex_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the flex shared libraries..."

    show_host_libs "${test_bin_folder_path}/flex"

    echo
    echo "Testing if flex binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/flex" --version

    rm -rf "${XBB_TESTS_FOLDER_PATH}/flex"
    mkdir -pv "${XBB_TESTS_FOLDER_PATH}/flex"; cd "${XBB_TESTS_FOLDER_PATH}/flex"

    # Note: __EOF__ is quoted to prevent substitutions here.
    cat <<'__EOF__' >test.flex
CHAR   [a-z][A-Z]
%%
{CHAR}+      printf("%s", yytext);
[ \t\n]+   printf("\n");
%%
int main()
{
  yyin = stdin;
  yylex();
}
__EOF__

      run_host_app_verbose "${test_bin_folder_path}/flex" test.flex

      (
        export LD_LIBRARY_PATH="$(xbb_get_libs_path)"

        if is_variable_set "XBB_LIBRARIES_INSTALL_FOLDER_PATH"
        then
          run_host_app_verbose "${CC}" lex.yy.c -L"${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib" -lfl -o test -v
        else
          local flex_realpath="$(${REALPATH} "${test_bin_folder_path}/flex")"
          local libraries_folder_path="$(dirname $(dirname "${flex_realpath}"))/lib"

          ls -l "${libraries_folder_path}"
          run_host_app_verbose "${CC}" lex.yy.c -L"${libraries_folder_path}" -lfl -o test -v
        fi

        show_host_libs ./test

        echo "Hello World" | ./test
      )
  )
}

# -----------------------------------------------------------------------------
