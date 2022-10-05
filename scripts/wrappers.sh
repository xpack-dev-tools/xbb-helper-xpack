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

function echo_develop()
{
  if [ "${IS_DEVELOP}" == "y" ]
  then
    echo "$@"
  fi
}

function run_verbose()
{
  # Does not include the .exe extension.
  local app_path=$1
  shift

  echo
  echo "[${app_path} $@]"
  "${app_path}" "$@" 2>&1
}

function run_verbose_timed()
{
  # Does not include the .exe extension.
  local app_path=$1
  shift

  echo
  echo "[${app_path} $@]"
  time "${app_path}" "$@" 2>&1
}

function run_app()
{
  # Does not include the .exe extension.
  local app_path=$1
  shift

  if [ "${TARGET_PLATFORM}" == "linux" ]
  then
    run_verbose "${app_path}" "$@"
  elif [ "${TARGET_PLATFORM}" == "darwin" ]
  then
    run_verbose "${app_path}" "$@"
  elif [ "${TARGET_PLATFORM}" == "win32" ]
  then
    if [ -x "${app_path}" ]
    then
      # When testing native variants, like llvm.
      run_verbose "${app_path}" "$@"
      return
    fi

    if [ "$(uname -o)" == "Msys" ]
    then
      run_verbose "${app_path}.exe" "$@"
      return
    fi

    local wsl_path=$(which wsl.exe 2>/dev/null)
    if [ ! -z "${wsl_path}" ]
    then
      run_verbose "${app_path}.exe" "$@"
      return
    fi

    (
      local wine_path=$(which wine64 2>/dev/null)
      if [ ! -z "${wine_path}" ]
      then
        if [ -f "${app_path}.exe" ]
        then
          run_verbose wine64 "${app_path}.exe" "$@"
        else
          echo "${app_path}.exe not found"
          exit 1
        fi
      else
        echo "Install wine64 if you want to run the .exe binaries on Linux."
      fi
    )

  else
    echo "Oops! Unsupported TARGET_PLATFORM=${TARGET_PLATFORM}."
    exit 1
  fi
}

function run_verbose_develop()
{
  # Does not include the .exe extension.
  local app_path=$1
  shift

  if [ "${IS_DEVELOP}" == "y" ]
  then
    echo
    echo "[${app_path} $@]"
  fi
  "${app_path}" "$@" 2>&1
}

# run_app_silent
# run_app_exit
# test_expect

# -----------------------------------------------------------------------------
