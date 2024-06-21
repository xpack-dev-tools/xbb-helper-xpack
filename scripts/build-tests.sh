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
  echo
  echo "# Initialising tests..."

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
  echo
  echo "# Reporting tests results..."

  local passed=$(grep "pass:" "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}" | wc -l | tr -d '[:blank:]')
  local skipped=$(grep "skip:" "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}" | wc -l | tr -d '[:blank:]')
  local failed=$(grep -i "fail:" "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}" | wc -l | tr -d '[:blank:]')
  echo
  echo "-------------------------------------------------------------------------------"
  echo

  mkdir -pv "${XBB_ARTEFACTS_FOLDER_PATH}"
  (
    # echo "# ${XBB_APPLICATION_NAME} $(echo "${XBB_RELEASE_VERSION}" | sed -e 's|[-].*||') test results"
    # echo
    echo "## ${XBB_BUILD_DISTRO_NAME} ${XBB_BUILD_KERNEL_NAME} ${XBB_BUILD_MACHINE}"
    echo
    if [ ${failed} -gt 0 ]
    then
      echo "\`\`\`txt"
      if [ "${XBB_TEST_SYSTEM_TOOLS:-""}" == "y" ]
      then
        echo "Tests summary for ${XBB_APPLICATION_LOWER_CASE_NAME} on ${XBB_REQUESTED_TARGET_PLATFORM}-${XBB_REQUESTED_TARGET_ARCH} (${XBB_BUILD_DISTRO_NAME} ${XBB_BUILD_DISTRO_VERSION})"
      else
        echo "Tests summary for ${XBB_APPLICATION_LOWER_CASE_NAME} ${XBB_RELEASE_VERSION} on ${XBB_REQUESTED_TARGET_PLATFORM}-${XBB_REQUESTED_TARGET_ARCH} (${XBB_BUILD_DISTRO_NAME} ${XBB_BUILD_DISTRO_VERSION})"
      fi
      echo
      echo "${passed} test cases passed, ${skipped} skipped, ${failed} failed:"
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
        for f in $(grep 'FAIL:' "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}" | sed -e 's|^.*: ||' -e 's| .*[(].*$||' -e 's|gc-||' -e 's|lto-||' -e 's|crt-||' -e 's|lld-||' -e 's|static-lib-||' -e 's|static-||' -e 's|libcxx-||' -e 's|-32||' -e 's|-64||' 2>&1 | sort -u)
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

      tests_list_succesful
      tests_list_skipped

      # Show the detailed list of failed test cases only when
      # explicitly running tests.
      if [ "${XBB_WHILE_RUNNING_SEPARATE_TESTS:-""}" == "y" ]
      then
        tests_list_failed
      fi
    else
      if [ ${passed} -gt 0 -o ${skipped} -gt 0 ]
      then
        echo "\`\`\`txt"
        if [ "${XBB_TEST_SYSTEM_TOOLS:-""}" == "y" ]
        then
          echo "Tests summary for ${XBB_APPLICATION_LOWER_CASE_NAME} on ${XBB_REQUESTED_TARGET_PLATFORM}-${XBB_REQUESTED_TARGET_ARCH} (${XBB_BUILD_DISTRO_NAME} ${XBB_BUILD_DISTRO_VERSION})"
        else
          echo "Tests summary for ${XBB_APPLICATION_LOWER_CASE_NAME} ${XBB_RELEASE_VERSION} on ${XBB_REQUESTED_TARGET_PLATFORM}-${XBB_REQUESTED_TARGET_ARCH} (${XBB_BUILD_DISTRO_NAME} ${XBB_BUILD_DISTRO_VERSION})"
        fi
        echo
        echo "${passed} test cases passed, ${skipped} skipped"
        echo "Verdict: tests accepted"
        echo "\`\`\`"

        tests_list_succesful
        tests_list_skipped
      else
        echo "All ${XBB_APPLICATION_LOWER_CASE_NAME} ${XBB_RELEASE_VERSION} ${XBB_REQUESTED_TARGET_PLATFORM}-${XBB_REQUESTED_TARGET_ARCH} (${XBB_BUILD_DISTRO_NAME} ${XBB_BUILD_DISTRO_VERSION}) tests completed successfully."
        echo
      fi
    fi
  ) 2>&1 | tee "${XBB_ARTEFACTS_FOLDER_PATH}/tests-report-${XBB_BUILD_PLATFORM}-${XBB_BUILD_ARCH}.md"

  echo
  # echo "-------------------------------------------------------------------------------"
}

function tests_list_succesful()
{
  echo
  echo "### Successful tests"
  echo

  IFS=$'\n\t'
  local test_names="$(grep -i -E 'fail:|pass:' "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}" | sed -e 's|^.*: ||' -e 's| .*[(].*$||' -e 's|gc-||' -e 's|lto-||' -e 's|crt-||' -e 's|lld-||' -e 's|static-lib-||' -e 's|static-||' -e 's|libcxx-||' -e 's|-32||' -e 's|-64||' 2>&1 | sort -u)"
  local successful_count=0
  for test_name in ${test_names}
  do
    local failed_this=$(grep -i "fail:" "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}" | grep "${test_name}" | wc -l | tr -d '[:blank:]')
    if [ ${failed_this} -eq 0 ]
    then
      echo "- ${test_name} ✓"
      successful_count=$((successful_count + 1))
    fi
  done

  if [ ${successful_count} -eq 0 ]
  then
    echo "- none"
  fi
}

function tests_list_skipped()
{
  if [ ${skipped} -gt 0 ]
  then
    echo
    echo "### Skipped tests"
    echo

    local skipped_tests="$(grep 'skip:' "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}" | sed -e 's|^.*: ||' -e 's|gc-||' -e 's|lto-||' -e 's|crt-||' -e 's|lld-||' -e 's|static-lib-||' -e 's|static-||' -e 's|libcxx-||' -e 's|-32||' -e 's|-64||' 2>&1 | sort -u)"
    for test_line in ${skipped_tests}
    do
      echo "- ${test_line}"
    done
    echo
  fi
}

function tests_list_failed()
{
  local failed_test_names="$(grep -i 'fail:' "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}" | sed -e 's|^.*: ||' -e 's| .*[(].*$||' -e 's|gc-||' -e 's|lto-||' -e 's|crt-||' -e 's|lld-||' -e 's|static-lib-||' -e 's|static-||' -e 's|libcxx-||' -e 's|-32||' -e 's|-64||' 2>&1 | sort -u)"
  for test_name in ${failed_test_names}
  do
    echo
    echo "### Failed test ${test_name}"
    echo
    for test_case_name in $(grep "${test_name}" "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}" |  sed -e 's|^.*: ||' -e 's| .*[(].*$||'  2>&1)
    do
      local is_failed=$(grep -i 'fail:' "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}" |  sed -e 's|^.*: ||' -e 's| .*[(].*$||' | grep "^${test_case_name}$" | wc -l | tr -d '[:blank:]')
      if [ ${is_failed} -gt 0 ]
      then
        echo "- ${test_case_name} ✗"
        # echo
        echo "  \`\`\`txt"
        tail -n +2 "${XBB_TEST_RESULTS_FOLDER_PATH}/${test_case_name}.txt" | grep -v "is_variable_set XBB_IGNORE_TEST" | grep -v "test_case_trap_handler" | cat -s | sed -E 's|^|  |'
        echo "  \`\`\`"
        # echo
      else
        echo "- ${test_case_name} ✓"
      fi
    done
  done
  echo
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

  local prefix=${PREFIX:-""}
  local suffix=${SUFFIX:-""}

  local filtered_suffix="$(echo "${suffix}" | sed -e 's|-bootstrap$||')"
  if [ ! -z "${filtered_suffix}" ]
  then
    if is_variable_set "XBB_IGNORE_TEST_ALL_${test_case_name}${filtered_suffix}" \
                       "XBB_IGNORE_TEST_ALL_${test_case_name}" \
                       "XBB_IGNORE_TEST_${prefix}${test_case_name}${filtered_suffix}" \
                       "XBB_IGNORE_TEST_${prefix}${test_case_name}"
    then
      # Lower case means the failure is expected.
      echo
      echo "xfail: ${prefix}${test_case_name}${suffix}"
      echo "xfail: ${prefix}${test_case_name}${suffix}" >> "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}"
    else
      # Upper case means the failure is unexpected.
      echo
      echo "FAIL: ${prefix}${test_case_name}${suffix}"
      local recommend="$(echo XBB_IGNORE_TEST_${prefix}${test_case_name}${filtered_suffix} | tr "[:lower:]" "[:upper:]" | tr '-' '_')"
      echo "FAIL: ${prefix}${test_case_name}${suffix} ${exit_code} ${line_number} (${recommend})" >> "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}"
    fi
  else
    if is_variable_set "XBB_IGNORE_TEST_ALL_${test_case_name}" \
                       "XBB_IGNORE_TEST_${prefix}${test_case_name}"
    then
      # Lower case means the failure is expected.
      echo
      echo "xfail: ${prefix}${test_case_name}${suffix}"
      echo "xfail: ${prefix}${test_case_name}" >> "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}"
    else
      echo
      echo "FAIL: ${prefix}${test_case_name}${suffix}"
      local recommend="$(echo XBB_IGNORE_TEST_${prefix}${test_case_name} | tr "[:lower:]" "[:upper:]" | tr '-' '_')"
      # Upper case means the failure is unexpected.
      echo "FAIL: ${prefix}${test_case_name} (${recommend})" >> "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}"
    fi
  fi

  return 0 # "${exit_code}"
}

function test_case_pass()
{
  local test_case_name="$1"

  local prefix=${PREFIX:-""}
  local suffix=${SUFFIX:-""}

  echo
  echo "pass: ${prefix}${test_case_name}${suffix}"

  echo "pass: ${prefix}${test_case_name}${suffix}" >> "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}"
}

function test_case_skip()
{
  local test_case_name="$1"
  shift

  local prefix=${PREFIX:-""}
  local suffix=${SUFFIX:-""}

  local filtered_suffix="$(echo "${suffix}" | sed -e 's|-bootstrap$||')"
  if [ ! -z "${filtered_suffix}" ]
  then
    if is_variable_set "XBB_SKIP_TEST_ALL_${test_case_name}${filtered_suffix}" \
                       "XBB_SKIP_TEST_ALL_${test_case_name}" \
                       "XBB_SKIP_TEST_${prefix}${test_case_name}${filtered_suffix}" \
                       "XBB_SKIP_TEST_${prefix}${test_case_name}"
    then
      echo
      echo "skip: ${prefix}${test_case_name}${suffix} $@"

      echo "skip: ${prefix}${test_case_name}${suffix} $@" >> "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}"
      return 0 # True
    else
      return 1
    fi
  else
    if is_variable_set "XBB_SKIP_TEST_ALL_${test_case_name}" \
                       "XBB_SKIP_TEST_${prefix}${test_case_name}"
    then
      echo
      echo "skip: ${prefix}${test_case_name}${suffix} $@"

      echo "skip: ${prefix}${test_case_name}${suffix} $@" >> "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}"
      return 0 # True
    else
      return 1
    fi
  fi
}

function test_case_skip_all_static()
{
  local test_case_name="$1"
  shift

  local prefix=${PREFIX:-""}
  local suffix=${SUFFIX:-""}

  local filtered_suffix="$(echo "${suffix}" | sed -e 's|-bootstrap$||')"
  if [ ! -z "${filtered_suffix}" ]
  then
    if is_variable_set "XBB_SKIP_TEST_ALL_STATIC_${test_case_name}${filtered_suffix}" \
                       "XBB_SKIP_TEST_ALL_STATIC_${test_case_name}"
    then
      echo
      echo "skip: ${prefix}${test_case_name}${suffix} $@"

      echo "skip: ${prefix}${test_case_name}${suffix} $@" >> "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}"
      return 0 # True
    else
      return 1
    fi
  else
    if is_variable_set "XBB_SKIP_TEST_ALL_STATIC_${test_case_name}"
    then
      echo
      echo "skip: ${prefix}${test_case_name}${suffix} $@"

      echo "skip: ${prefix}${test_case_name}${suffix} $@" >> "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}"
      return 0 # True
    else
      return 1
    fi
  fi
}

# -----------------------------------------------------------------------------
