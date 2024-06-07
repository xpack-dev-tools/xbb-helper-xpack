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

  export XBB_TEST_RESULTS_FOLDER_PATH="${XBB_TARGET_WORK_FOLDER_PATH}/tests/results"
  rm -rf "${XBB_TEST_RESULTS_FOLDER_PATH}"
  mkdir -pv "${XBB_TEST_RESULTS_FOLDER_PATH}"

  export XBB_TEST_RESULTS_SUMMARY_FILE_PATH="${XBB_TEST_RESULTS_FOLDER_PATH}/summary"
  touch "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}"

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
}

function tests_report_results()
{
  local passed=$(grep "pass:" "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}" | wc -l | tr -d '[:blank:]')
  local failed=$(grep -i "fail:" "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}" | wc -l | tr -d '[:blank:]')
  echo
  echo "-------------------------------------------------------------------------------"
  echo

  mkdir -pv "${XBB_ARTEFACTS_FOLDER_NAME}"
  (
    echo "# ${XBB_APPLICATION_NAME} $(echo "${XBB_RELEASE_VERSION}" | sed -e 's|[-].*||') test results"
    echo
    echo "## ${XBB_BUILD_DISTRO_NAME} ${XBB_BUILD_KERNEL_NAME} ${XBB_BUILD_MACHINE}"
    echo
    if [ ${failed} -gt 0 ]
    then
      echo "\`\`\`console"
      echo "Tests summary for ${XBB_APPLICATION_LOWER_CASE_NAME} ${XBB_RELEASE_VERSION} on ${XBB_REQUESTED_TARGET_PLATFORM}-${XBB_REQUESTED_TARGET_ARCH} (${XBB_BUILD_DISTRO_NAME} ${XBB_BUILD_DISTRO_VERSION})"
      echo
      echo "${passed} test(s) passed, ${failed} failed:"
      echo
      grep -i "FAIL:" "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}" | sed -e 's|^|- |'

      local catastrophic=$(grep "FAIL:" "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}" | wc -l | tr -d '[:blank:]')
      if [ ${catastrophic} -gt 0 ]
      then
        echo
        echo "${catastrophic} failed unexpectedly"
        echo "Verdict: tests cannot be accepted"

        echo
        echo "Possibly ignore some tests:"

        IFS=$'\n\t'
        for f in $(grep 'FAIL:' "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}" | sed -e 's|^.*: ||' -e 's| [(].*$||' -e 's|gc-||' -e 's|lto-||' -e 's|crt-||' -e 's|lld-||' -e 's|static-lib-||' -e 's|static-||'  -e 's|libcxx-||' 2>&1 | sort -u)
        do
          echo
          echo "# ${f}."
          grep "${f}" "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}" | grep 'FAIL:' | sed -e 's|^.*FAIL.*[(]|export |' -e 's|[)]|="y"|'
        done

        exit 1
      fi
      echo
      echo "Verdict: tests reluctantly accepted"
      echo "\`\`\`"

      echo
      echo "The failing tests are:"

      IFS=$'\n\t'
      for test_name in $(grep -i 'fail:' "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}" | sed -e 's|^.*: ||' -e 's| [(].*$||' -e 's|gc-||' -e 's|lto-||' -e 's|crt-||' -e 's|lld-||' -e 's|static-lib-||' -e 's|static-||'  -e 's|libcxx-||' 2>&1 | sort -u)
      do
        echo
        echo "### Test ${test_name}"
        echo
        for test_case_name in $(grep -i 'fail:' "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}" | grep "${test_name}" | sed -e 's|^.*: ||' -e 's| [(].*$||'  2>&1)
        do
          echo "#### Test case ${test_case_name}"
          echo
          echo "\`\`\`console"
          tail -n +2 "${XBB_TEST_RESULTS_FOLDER_PATH}/${test_case_name}.txt" | grep -v "is_variable_set XBB_IGNORE_TEST" | grep -v "test_case_trap_handler"
          echo "\`\`\`"
          echo
        done
      done
    else
      echo
      if [ ${passed} -gt 0 ]
      then
        echo "${passed} test(s) passed"
      fi
      echo "All ${XBB_APPLICATION_LOWER_CASE_NAME} ${XBB_RELEASE_VERSION} ${XBB_REQUESTED_TARGET_PLATFORM}-${XBB_REQUESTED_TARGET_ARCH} (${XBB_BUILD_DISTRO_NAME} ${XBB_BUILD_DISTRO_VERSION}) tests completed successfully"
    fi
  ) 2>&1 | tee "${XBB_ARTEFACTS_FOLDER_NAME}/tests-summary.md"

  echo "-------------------------------------------------------------------------------"
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
  local exit_code="$1"
  shift
  local line_number="$1"
  shift

  local filtered_suffix="$(echo "${SUFFIX}" | sed -e 's|-bootstrap$||')"
  if [ ! -z "${filtered_suffix}" ]
  then
    if is_variable_set "XBB_IGNORE_TEST_ALL_${test_case_name}${filtered_suffix}" \
                       "XBB_IGNORE_TEST_ALL_${test_case_name}" \
                       "XBB_IGNORE_TEST_${PREFIX}${test_case_name}${filtered_suffix}" \
                       "XBB_IGNORE_TEST_${PREFIX}${test_case_name}"
    then
      # Lower case means the failure is expected.
      echo
      echo "xfail: ${PREFIX}${test_case_name}${SUFFIX}"
      echo "xfail: ${PREFIX}${test_case_name}${SUFFIX}" >> "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}"
    else
      # Upper case means the failure is unexpected.
      echo
      echo "FAIL: ${PREFIX}${test_case_name}${SUFFIX}"
      local recommend="$(echo XBB_IGNORE_TEST_${PREFIX}${test_case_name}${filtered_suffix} | tr "[:lower:]" "[:upper:]" | tr '-' '_')"
      echo "FAIL: ${PREFIX}${test_case_name}${SUFFIX} ${exit_code} ${line_number} (${recommend})" >> "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}"
    fi
  else
    if is_variable_set "XBB_IGNORE_TEST_ALL_${test_case_name}" \
                       "XBB_IGNORE_TEST_${PREFIX}${test_case_name}"
    then
      # Lower case means the failure is expected.
      echo
      echo "xfail: ${PREFIX}${test_case_name}${SUFFIX}"
      echo "xfail: ${PREFIX}${test_case_name}" >> "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}"
    else
      echo
      echo "FAIL: ${PREFIX}${test_case_name}${SUFFIX}"
      local recommend="$(echo XBB_IGNORE_TEST_${PREFIX}${test_case_name} | tr "[:lower:]" "[:upper:]" | tr '-' '_')"
      # Upper case means the failure is unexpected.
      echo "FAIL: ${PREFIX}${test_case_name} (${recommend})" >> "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}"
    fi
  fi

  return 0 # "${exit_code}"
}

function test_case_pass()
{
  local test_case_name="$1"

  echo
  echo "pass: ${PREFIX}${test_case_name}${SUFFIX}"

  echo "pass: ${PREFIX}${test_case_name}${SUFFIX}" >> "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}"
}

# -----------------------------------------------------------------------------
