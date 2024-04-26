# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# test_bin_path
# [--32|--64]
function test_compiler_fortran()
{
  echo_develop
  echo_develop "[test_compiler_fortran $@]"

  local test_bin_path="$1"
  shift

  (
    unset IFS

    local prefix=""
    local suffix=""
    local bits_flags=""

    while [ $# -gt 0 ]
    do
      case "$1" in

        --64 )
          bits_flags=" -m64"
          suffix="-64"
          shift
          ;;

        --32 )
          bits_flags=" -m32"
          suffix="-32"
          shift
          ;;

        * )
          echo "Unsupported option $1 in ${FUNCNAME[0]}()"
          exit 1
          ;;

      esac
    done

    LDFLAGS=""

    if is_variable_set "F90"
    then
      (
        run_verbose_develop cd fortran

        if is_gcc && [ "${XBB_BUILD_PLATFORM}" == "win32" ]
        then
          # error while loading shared libraries: api-ms-win-crt-time-l1-1-0.dll: cannot open shared object file: No such file or directory
          # The api-ms-win-crt-runtime-l1-1-0.dll file is included in Microsoft Visual C++ Redistributable for Visual Studio 2015
          echo
          echo "Skipping Fortran tests on Windows..."
        else
          # Test a very simple Fortran (a print).
          run_host_app_verbose "${F90}" hello.f90 -o "${prefix}hello-f${suffix}${XBB_TARGET_DOT_EXE}" ${bits_flags} ${LDFLAGS}
          # The space is expected.
          expect_target_output " Hello" "${prefix}hello-f${suffix}${XBB_TARGET_DOT_EXE}"

          # Test a concurrent computation.
          run_host_app_verbose "${F90}" concurrent.f90 -o "${prefix}concurrent-f${suffix}${XBB_TARGET_DOT_EXE}" ${bits_flags} ${LDFLAGS}

          show_target_libs_develop "${prefix}concurrent-f${suffix}${XBB_TARGET_DOT_EXE}"
          run_target_app_verbose "./${prefix}concurrent-f${suffix}"
        fi
      )
    else
      echo
      echo "Skipping Fortran tests, compiler not available..."
    fi
  )
}

# -----------------------------------------------------------------------------
