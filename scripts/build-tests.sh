#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2022 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Test functions used during the build.

function tests_initialize()
{
  export XBB_TEST_COMMANDS_FILE_PATH="${XBB_TARGET_WORK_FOLDER_PATH}/tests/commands"
  rm -rf "${XBB_TEST_COMMANDS_FILE_PATH}"
  mkdir -pv "$(dirname ${XBB_TEST_COMMANDS_FILE_PATH})"
  touch "${XBB_TEST_COMMANDS_FILE_PATH}"

  export XBB_TEST_RESULTS_FILE_PATH="${XBB_TARGET_WORK_FOLDER_PATH}/tests/results"
  rm -rf "${XBB_TEST_RESULTS_FILE_PATH}"
  mkdir -pv "$(dirname ${XBB_TEST_RESULTS_FILE_PATH})"
  touch "${XBB_TEST_RESULTS_FILE_PATH}"

  XBB_WHILE_RUNNING_TESTS="n"
  export XBB_WHILE_RUNNING_TESTS
}

function tests_add()
{
  if [ "${XBB_WHILE_RUNNING_TESTS}" != "y" ]
  then
    echo "$@" >> "${XBB_TEST_COMMANDS_FILE_PATH}"
  fi
}

function tests_run_final()
{
  echo
  echo "# Running final tests..."

  XBB_WHILE_RUNNING_TESTS="y"
  export XBB_WHILE_RUNNING_TESTS

  for line in $(cat ${XBB_TEST_COMMANDS_FILE_PATH})
  do
    if [ "${line}" != "" ]
    then
      # local func=$(echo ${line} | sed -e s'| .*||' | sed -e 's|-|_|g')

      IFS=' '
      read -a cmd_array <<< "${line}"
      echo
      echo "## Running \"${cmd_array[@]}\"..."
      "${cmd_array[@]}"
      echo "## Running \"${cmd_array[@]}\" completed"
    fi
  done

  local failed=$(grep -i "FAIL:" "${XBB_TEST_RESULTS_FILE_PATH}" | wc -l | sed -e 's|\s*||')
  if [ ${failed} -ge 0 ]
  then
    echo
    echo "${failed} test(s) failed:"
    echo
    grep -i "FAIL:" "${XBB_TEST_RESULTS_FILE_PATH}"

    local catastrophic=$(grep "FAIL:" "${XBB_TEST_RESULTS_FILE_PATH}" | wc -l | sed -e 's|\s*||')
    if [ ${catastrophic} -gt 0 ]
    then
      echo
      echo "${catastrophic} failed unexpectedly."
      echo "Final tests results cannot be accepted"
      exit 1
    else
      echo
      echo "Final tests results accepted"
    fi
  else
    echo
    echo "Final tests completed successfuly"
  fi
}

function tests_prime_wine()
{
  if [ "${XBB_REQUESTED_TARGET_PLATFORM}" == "win32" ]
  then
    (
      echo
      echo "Priming wine..."

      # When running in Docker with the home mounted, wine throws:
      # wine: '/github/home' is not owned by you, refusing to create a configuration directory there
      # To avoid it, create the .wine folder beforehand.
      run_verbose mkdir -pv "${HOME}/.wine"
      run_verbose winecfg
      sleep 1 # Give it time to complete.
      echo "Wine primed..."
    )
  fi
}

function test_case_get_name()
{
  echo "$(echo ${FUNCNAME[1]} | sed -e 's|test_case_||'  | tr '_' '-')"
}

function test_case_trap_handler()
{
  echo_develop "[${FUNCNAME[0]} $@ $#]"

  local test_case_name="$1"
  shift

  echo_develop "FAIL: ${PREFIX}${test_case_name}${SUFFIX}"

  local recommend="$(echo XBB_SKIP_TEST_${PREFIX}${test_case_name}${SUFFIX} | tr "[:lower:]" "[:upper:]" | tr '-' '_')"

  if [ ! -z "${SUFFIX}" ] && \
     is_variable_set "XBB_SKIP_TEST_ALL_${test_case_name}${SUFFIX}" \
                     "XBB_SKIP_TEST_ALL_${test_case_name}" \
                     "XBB_SKIP_TEST_${PREFIX}${test_case_name}${SUFFIX}" \
                     "XBB_SKIP_TEST_${PREFIX}${test_case_name}" \
                     "$@" || \
     is_variable_set "XBB_SKIP_TEST_ALL_${test_case_name}" \
                     "XBB_SKIP_TEST_${PREFIX}${test_case_name}" \
                     "$@"
  then
    # Lower case means the failure is expected.
    echo "fail: ${PREFIX}${test_case_name}${SUFFIX}" >> "${XBB_TEST_RESULTS_FILE_PATH}"
  else
    # Upper case means the failure is unexpected.
    echo "FAIL: ${PREFIX}${test_case_name}${SUFFIX} (${recommend})" >> "${XBB_TEST_RESULTS_FILE_PATH}"
  fi
}

function test_case_pass()
{
  local test_case_name="$1"

  echo_develop "pass: ${PREFIX}${test_case_name}${SUFFIX}"
  echo "pass: ${PREFIX}${test_case_name}${SUFFIX}" >> "${XBB_TEST_RESULTS_FILE_PATH}"
}

# -----------------------------------------------------------------------------
