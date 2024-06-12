# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# [--32|--64]
# [--bootstrap]

function test_compiler_fortran()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  echo "[${FUNCNAME[0]} $@]" >> "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}"

  (
    unset IFS

    local is_bootstrap=""

    PREFIX=""
    SUFFIX=""
    BITS_FLAGS=""

    while [ $# -gt 0 ]
    do
      case "$1" in

        --64 )
          BITS_FLAGS=" -m64"
          SUFFIX+="-64"
          shift
          ;;

        --32 )
          BITS_FLAGS=" -m32"
          SUFFIX+="-32"
          shift
          ;;

        --bootstrap )
          is_bootstrap="y"
          shift
          ;;

        * )
          echo "Unsupported option $1 in ${FUNCNAME[0]}()"
          exit 1
          ;;

      esac
    done

    if [ "${is_bootstrap}" == "y" ]
    then
      SUFFIX+="-bootstrap"
    fi

    LDFLAGS=""

    export LDFLAGS

    export PREFIX
    export SUFFIX
    export bits

    if is_variable_set "F90"
    then
      (
        run_verbose_develop cd fortran

        set +o errexit  # Do not exit if commands fail, to allow continuation.

        # ---------------------------------------------------------------------

        if is_gcc && [ "${XBB_BUILD_PLATFORM}" == "win32" ]
        then
          # error while loading shared libraries: api-ms-win-crt-time-l1-1-0.dll: cannot open shared object file: No such file or directory
          # The api-ms-win-crt-runtime-l1-1-0.dll file is included in Microsoft Visual C++ Redistributable for Visual Studio 2015
          echo
          echo "Skipping Fortran tests on Windows..."
        else

          test_case_hello_f

          test_case_concurrent_f

        fi
      )
    else
      echo
      echo "Skipping Fortran tests, compiler not available..."
    fi
  )
}

# -----------------------------------------------------------------------------

function test_case_hello_f()
{
  local test_case_name="$(test_case_get_name)"

  local prefix=${PREFIX:-""}
  local suffix=${SUFFIX:-""}

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    # Test a very simple Fortran (a print).
    run_host_app_verbose "${F90}" hello.f90 -o "${prefix}hello-f${suffix}${XBB_TARGET_DOT_EXE}" ${BITS_FLAGS} ${LDFLAGS}

    # The space is expected.
    expect_target_output " Hello" "${prefix}hello-f${suffix}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${prefix}${test_case_name}${suffix}.txt"
}

function test_case_concurrent_f()
{
  local test_case_name="$(test_case_get_name)"

  local prefix=${PREFIX:-""}
  local suffix=${SUFFIX:-""}

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    # Test a concurrent computation.
    run_host_app_verbose "${F90}" concurrent.f90 -o "${prefix}concurrent-f${suffix}${XBB_TARGET_DOT_EXE}" ${BITS_FLAGS} ${LDFLAGS}

    expect_target_succeed "${prefix}concurrent-f${suffix}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${prefix}${test_case_name}${suffix}.txt"
}


# -----------------------------------------------------------------------------

# Template to acc new test cases.

# -----------------------------------------------------------------------------

function test_case_()
{
  local test_case_name="$(test_case_get_name)"

  local prefix=${PREFIX:-""}
  local suffix=${SUFFIX:-""}

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR


    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${prefix}${test_case_name}${suffix}.txt"
}
