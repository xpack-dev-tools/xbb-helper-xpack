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
      echo "## Running \"${cmd_array[@]}\" completed."
    fi
  done

  echo
  echo "Final tests completed successfuly."
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
      mkdir -pv "${HOME}/.wine"
      winecfg

      echo "Wine primed..."
    )
  fi
}

# -----------------------------------------------------------------------------
