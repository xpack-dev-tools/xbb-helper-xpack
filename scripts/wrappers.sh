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
  if [ "${XBB_IS_DEVELOP}" == "y" ]
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
  local app_path="$1"
  shift

  if [ "${XBB_BUILD_PLATFORM}" == "linux" ]
  then
    # Possibly Windows executables, run them via wine.
    if is_pe64 "$(realpath ${app_path}.exe)"
    then
      local wine_path=$(which wine64 2>/dev/null)
      if [ ! -z "${wine_path}" ]
      then
        (
          unset DISPLAY
          export WINEDEBUG=-all
          run_verbose wine64 "${app_path}.exe" "$@"
        )
      else
        echo "wine64" "${app_name}" "$@" "- not available in ${FUNCNAME[0]}()"
      fi
    elif is_pe32 "$(realpath ${app_path}.exe)"
    then
      local wine_path=$(which wine 2>/dev/null)
      if [ ! -z "${wine_path}" ]
      then
        (
          unset DISPLAY
          export WINEDEBUG=-all
          run_verbose wine "${app_path}.exe" "$@"
        )
      else
        echo "wine" "${app_path}" "$@" "- not available in ${FUNCNAME[0]}()"
      fi
    else
      # Assume it is a Linux executable.
      run_verbose "${app_path}" "$@"
    fi
  elif [ "${XBB_BUILD_PLATFORM}" == "darwin" ]
  then
    run_verbose "${app_path}" "$@"
  elif [ "${XBB_BUILD_PLATFORM}" == "win32" ]
  then
    if is_elf "${app_path}"
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
          unset DISPLAY
          export WINEDEBUG=-all
          run_verbose wine64 "${app_path}.exe" "$@"
        else
          echo "${app_path}.exe not found"
          exit 1
        fi
      else
        echo "wine64" "${app_name}" "$@" "- not available in ${FUNCNAME[0]}()"
      fi
    )

  else
    echo "Unsupported XBB_HOST_PLATFORM=${XBB_HOST_PLATFORM} in ${FUNCNAME[0]}()"
    exit 1
  fi
}

function run_verbose_develop()
{
  # Does not include the .exe extension.
  local app_path=$1
  shift

  if [ "${XBB_IS_DEVELOP}" == "y" ]
  then
    echo
    echo "[${app_path} $@]"
  fi
  "${app_path}" "$@" 2>&1
}

# -----------------------------------------------------------------------------

function run_app_silent()
{
  # Does not include the .exe extension.
  local app_path=$1
  shift

  if [ "${XBB_HOST_PLATFORM}" == "linux" ]
  then
    "${app_path}" "$@" 2>&1
  elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
  then
    "${app_path}" "$@" 2>&1
  elif [ "${XBB_HOST_PLATFORM}" == "win32" ]
  then
    if [ "$(uname -o)" == "Msys" ]
    then
      "${app_path}.exe" "$@"
      return
    fi

    local wsl_path=$(which wsl.exe 2>/dev/null)
    if [ ! -z "${wsl_path}" ]
    then
      "${app_path}.exe" "$@" 2>&1
      return
    fi
    (
      unset DISPLAY
      export WINEDEBUG=-all

      local wine_path=$(which wine64 2>/dev/null)
      if [ ! -z "${wine_path}" ]
      then
        if [ -f "${app_path}.exe" ]
        then
          wine64 "${app_path}.exe" "$@" 2>&1
        else
          echo "${app_path}.exe not found"
          exit 1
        fi
      else
        echo "Install wine64 if you want to run the .exe binaries on Linux."
      fi
    )

  else
    echo "Oops! Unsupported XBB_HOST_PLATFORM=${XBB_HOST_PLATFORM} in ${FUNCNAME[0]}()"
    exit 1
  fi
}

function run_app_exit()
{
  local expected_exit_code=$1
  shift
  local app_path=$1
  shift
  if [ "${node_platform}" == "win32" ]
  then
    app_path+='.exe'
  fi

  (
    set +e
    echo
    echo "${app_path} $@"
    "${app_path}" "$@" 2>&1
    local actual_exit_code=$?
    echo "exit(${actual_exit_code})"
    set -e
    if [ ${actual_exit_code} -ne ${expected_exit_code} ]
    then
      exit ${actual_exit_code}
    fi
  )
}

function test_expect()
{
  local expected="$1"
  local app_path="$2"
  shift 2

  (
    set +e

    # Remove the trailing CR present on Windows.
    local output
    if [ "${app_path:0:1}" == "/" ]
    then
      show_libs "${app_path}"
      output="$(run_app_silent "${app_path}" "$@" | sed 's/\r$//')"
    elif [ "${app_path:0:2}" == "./" ]
    then
      show_libs "${app_path}"
      output="$(run_app_silent "${app_path}" "$@" | sed 's/\r$//')"
    elif [ -f "${app_path}.exe" ]
    then
      show_libs "${app_path}"
      output="$(run_app_silent "${app_path}" "$@" | sed 's/\r$//')"
    else
      if [ -x "${app_path}" ]
      then
        show_libs "${app_path}"
        output="$(run_app_silent "./${app_path}" "$@" | sed 's/\r$//')"
      else
        # bash case
        output="$(run_app_silent "${app_path}" "$@" | sed 's/\r$//')"
      fi
    fi

    if [ "x${output}x" == "x${expected}x" ]
    then
      echo
      echo "Test \"${app_path} $@\" passed, got \"${expected}\" :-)"
    else
      echo
      echo "Test \"${app_path} $@\" failed :-("
      echo "expected ${#expected}: \"${expected}\""
      echo "got ${#output}: \"${output}\""
      echo
      exit 1
    fi
  )
}

# -----------------------------------------------------------------------------

function is_pe()
{
  if [ $# -lt 1 ]
  then
    warning "is_pe: Missing arguments"
    exit 1
  fi

  local bin_path="$1"

  # Symlinks do not match.
  if [ -L "${bin_path}" ]
  then
    return 1
  fi

  if [ -f "${bin_path}" ]
  then
    if [ "${XBB_HOST_PLATFORM}" == "win32" ]
    then
      file ${bin_path} | egrep -q "( PE )|( PE32 )|( PE32\+ )"
    else
      return 1
    fi
  else
    return 1
  fi
}

function is_elf()
{
  if [ $# -lt 1 ]
  then
    warning "is_elf: Missing arguments"
    exit 1
  fi

  local bin_path="$1"

  # Symlinks do not match.
  if [ -L "${bin_path}" ]
  then
    return 1
  fi

  if [ -f "${bin_path}" ]
  then
    # Return 0 (true) if found.
    if [ "${XBB_BUILD_PLATFORM}" == "linux" ]
    then
      file ${bin_path} | egrep -q "( ELF )"
    elif [ "${XBB_BUILD_PLATFORM}" == "darwin" ]
    then
      # This proved to be very tricky.
      file ${bin_path} | egrep -q "x86_64:Mach-O|arm64e:Mach-O|Mach-O.*x86_64|Mach-O.*arm64"
    else
      return 1
    fi
  else
    return 1
  fi
}

function is_elf_dynamic()
{
  if [ $# -lt 1 ]
  then
    warning "is_elf_dynamic: Missing arguments"
    exit 1
  fi

  local bin_path="$1"

  if is_elf "${bin_path}"
  then
    # Return 0 (true) if found.
    file ${bin_path} | egrep -q "dynamically"
  else
    return 1
  fi

}

function is_dynamic()
{
  if [ $# -lt 1 ]
  then
    warning "is_dynamic: Missing arguments"
    exit 1
  fi

  local bin_path="$1"

  if [ -f "${bin_path}" ]
  then
    # Return 0 (true) if found.
    file ${bin_path} | egrep -q "dynamically"
  else
    return 1
  fi
}

# -----------------------------------------------------------------------------
