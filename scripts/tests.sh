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

function tests_initialize()
{
  export TEST_COMMANDS_FILE_PATH="${INSTALL_FOLDER_PATH}/test-commands"
  rm -rf "${TEST_COMMANDS_FILE_PATH}"
  touch "${TEST_COMMANDS_FILE_PATH}"
}

function tests_add()
{
  echo "$@" >> "${TEST_COMMANDS_FILE_PATH}"
}

function tests_run()
{
  (
    echo
    echo "# Running final tests..."

    for line in $(cat ${TEST_COMMANDS_FILE_PATH})
    do
      if [ "${line}" != "" ]
      then
        # local func=$(echo ${line} | sed -e s'| .*||' | sed -e 's|-|_|g')

        IFS=' '
        read -a cmd_array <<< "${line}"
        echo
        echo "## Running ${cmd_array[@]}..."
        "${cmd_array[@]}"
      fi
    done

    echo
    echo "Final tests completed successfuly."
  ) 2>&1 | tee "${LOGS_FOLDER_PATH}/tests-output-$(date -u +%Y%m%d-%H%M).txt"
}

function tests_prime_wine()
{
  if [  "${TARGET_PLATFORM}" == "win32" ]
  then
    (
      xbb_activate

      echo
      winecfg &>/dev/null
      echo "wine primed, testing..."
    )
  fi
}

# -----------------------------------------------------------------------------
