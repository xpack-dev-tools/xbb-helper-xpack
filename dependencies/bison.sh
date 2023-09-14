# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.gnu.org/software/bison/
# https://ftp.gnu.org/gnu/bison/

# https://gitlab.archlinux.org/archlinux/packaging/packages/bison/-/blob/main/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/bison/files/PKGBUILD
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=bison-git

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/b/bison.rb

# 2015-01-23, "3.0.4"
# 2019-02-03, "3.3.2", Crashes with Abort trap 6.
# 2019-09-12, "3.4.2"
# 2019-12-11, "3.5"
# 2020-07-23, "3.7"
# 2021-09-25, "3.8.2"

# -----------------------------------------------------------------------------

function bison_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local bison_version="$1"

  local bison_src_folder_name="bison-${bison_version}"

  local bison_archive="${bison_src_folder_name}.tar.xz"
  local bison_url="https://ftp.gnu.org/gnu/bison/${bison_archive}"

  local bison_folder_name="${bison_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${bison_folder_name}"

  local bison_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${bison_folder_name}-installed"
  if [ ! -f "${bison_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${bison_url}" "${bison_archive}" \
      "${bison_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${bison_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${bison_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP}"

      xbb_adjust_ldflags_rpath

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      export M4=gm4

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running bison configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${bison_src_folder_name}/configure" --help
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

          config_options+=("--disable-dependency-tracking") # HB
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--disable-nls")

          # Usually not recommended, but here it is needed to generate
          # a relocatable yacc script.
          config_options+=("--enable-relocatable") # HB

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${bison_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${bison_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${bison_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running bison make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        # Remove documentation
        run_verbose rm -rfv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/share/doc" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/share/info"

        # Takes too long.
        if false # [ "${RUN_LONG_TESTS}" == "y" ]
        then
          # 596, 7 failed
          make -j1 check
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${bison_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${bison_src_folder_name}" \
        "${bison_folder_name}"
    )

    (
      bison_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${bison_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${bison_stamp_file_path}"

  else
    echo "Component bison already installed"
  fi

  tests_add "bison_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function bison_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the bison binaries shared libraries..."

    show_host_libs "${test_bin_folder_path}/bison"
    # yacc is a script.

    echo
    echo "Testing if bison binaries start properly..."

    run_host_app_verbose "${test_bin_folder_path}/bison" --version
    run_host_app_verbose "${test_bin_folder_path}/yacc" --version

    rm -rf "${XBB_TESTS_FOLDER_PATH}/bison"
    mkdir -pv "${XBB_TESTS_FOLDER_PATH}/bison"; cd "${XBB_TESTS_FOLDER_PATH}/bison"

      # Note: __EOF__ is quoted to prevent substitutions here.
      cat <<'__EOF__' > test.y
%{ #include <iostream>
    using namespace std;
    extern void yyerror (char *s);
    extern int yylex ();
%}
%start prog
%%
prog:  //  empty
    |  prog expr '\n' { cout << "pass"; exit(0); }
    ;
expr: '(' ')'
    | '(' expr ')'
    |  expr expr
    ;
%%
char c;
void yyerror (char *s) { cout << "fail"; exit(0); }
int yylex () { cin.get(c); return c; }
int main() { yyparse(); }
__EOF__

    run_host_app_verbose "${test_bin_folder_path}/bison" test.y -Wno-conflicts-sr

    (
      export LD_LIBRARY_PATH="$(xbb_get_libs_path "${CXX}")"

      run_verbose ${CXX} test.tab.c -o test -w

      expect_host_output "pass" "$(which bash)" "-c" "(echo '((()(())))()' | ./test)"
      expect_host_output "fail" "$(which bash)" "-c" "(echo '())' | ./test)"
    )

  )
}
