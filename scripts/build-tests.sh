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
  export TEST_COMMANDS_FILE_PATH="${INSTALL_FOLDER_PATH}/test-commands"
  rm -rf "${TEST_COMMANDS_FILE_PATH}"
  touch "${TEST_COMMANDS_FILE_PATH}"
}

function tests_add()
{
  echo "$@" >> "${TEST_COMMANDS_FILE_PATH}"
}

function tests_run_final()
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
  )
}

function tests_prime_wine()
{
  if [  "${TARGET_PLATFORM}" == "win32" ]
  then
    (
      echo

      # When running in Docker with the home mounted, wine throws:
      # wine: '/github/home' is not owned by you, refusing to create a configuration directory there
      # To avoid it, create the .wine folder beforehand.
      mkdir -p "${HOME}/.wine"
      winecfg

      echo "wine primed, testing..."
    )
  fi
}

# -----------------------------------------------------------------------------
