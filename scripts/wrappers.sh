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

function ndate()
{
  date -u +%Y%m%d-%H%M%S
}

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
  local app_path="$1"
  shift

  echo
  echo "[${app_path} $@]"
  "${app_path}" "$@" 2>&1
}

function run_verbose_develop()
{
  # Does not include the .exe extension.
  local app_path="$1"
  shift

  if [ "${XBB_IS_DEVELOP}" == "y" ]
  then
    echo
    echo "[${app_path} $@]"
  fi
  "${app_path}" "$@" 2>&1
}

function run_verbose_timed()
{
  # Does not include the .exe extension.
  local app_path="$1"
  shift

  echo
  echo "[${app_path} $@]"
  time "${app_path}" "$@" 2>&1
}

# -----------------------------------------------------------------------------

# Run elf binaries via the verbose wrapper and complain about other binaries.
function run_app_verbose()
{
  local app_path="$1"
  shift

  if [ "${XBB_BUILD_PLATFORM}" == "linux" ] || [ "${XBB_BUILD_PLATFORM}" == "darwin" ]
  then
    if is_elf "$(${REALPATH} ${app_path})"
    then
      run_verbose "${app_path}" "$@"
    elif is_executable_script "$(${REALPATH} ${app_path})"
    then
      run_verbose "${app_path}" "$@"
    else
      run_verbose file "$(${REALPATH} ${app_path})"
      echo
      echo "Unsupported \"${app_path} $@\" in ${FUNCNAME[0]}()"
      exit 1
    fi
  elif [ "${XBB_BUILD_PLATFORM}" == "win32" ]
  then
    run_verbose "${app_path}" "$@"
  else
    echo
    echo "Unsupported XBB_BUILD_PLATFORM=${XBB_BUILD_PLATFORM} in ${FUNCNAME[0]}()"
    exit 1
  fi
}

function run_target_app_verbose()
{
  # Does not need to include the .exe extension.
  local app_path="$1"
  shift

  if [ "${XBB_BUILD_PLATFORM}" == "linux" -o "${XBB_BUILD_PLATFORM}" == "darwin" ]
  then
    if is_elf "$(${REALPATH} ${app_path})"
    then
      run_verbose "${app_path}" "$@"
    elif is_executable_script "$(${REALPATH} ${app_path})"
    then
      run_verbose "${app_path}" "$@"
    elif is_pe64 "$(${REALPATH} ${app_path})"
    then
      local wine_path=$(which wine64 2>/dev/null)
      if [ ! -z "${wine_path}" ]
      then
        (
          unset DISPLAY
          export WINEDEBUG=-all
          run_verbose wine64 "${app_path}" "$@"
        )
      else
        echo
        echo "wine64 ${app_path} $@ - not available in ${FUNCNAME[0]}()"
      fi
    elif is_pe64 "$(${REALPATH} ${app_path}.exe)"
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
        echo
        echo "wine64 ${app_path} $@ - not available in ${FUNCNAME[0]}()"
      fi
    elif is_pe32 "$(${REALPATH} ${app_path})"
    then
      local wine_path=$(which wine 2>/dev/null)
      if [ ! -z "${wine_path}" ]
      then
        (
          unset DISPLAY
          export WINEDEBUG=-all
          run_verbose wine "${app_path}" "$@"
        )
      else
        echo
        echo "wine ${app_path} $@ - not available in ${FUNCNAME[0]}()"
      fi
    elif is_pe32 "$(${REALPATH} ${app_path}.exe)"
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
        echo
        echo "wine ${app_path} $@ - not available in ${FUNCNAME[0]}()"
      fi
    else
      echo
      echo "Unsupported \"${app_path} $@\" in ${FUNCNAME[0]}()"
      exit 1
    fi
  elif [ "${XBB_BUILD_PLATFORM}" == "win32" ]
  then
    run_verbose "${app_path}" "$@"
  else
    echo
    echo "Unsupported XBB_HOST_PLATFORM=${XBB_HOST_PLATFORM} in ${FUNCNAME[0]}()"
    exit 1
  fi
}

function run_host_app_verbose()
{
  # Use the same strategy as for target apps.
  run_target_app_verbose "$@"
}

function run_host_app()
{
  # Use the same strategy as for target apps.
  run_target_app "$@"
}

function run_target_app()
{
  # Does not need to include the .exe extension.
  local app_path="$1"
  shift

  if [ "${XBB_BUILD_PLATFORM}" == "linux" ]
  then
    if is_elf "$(${REALPATH} ${app_path})"
    then
      "${app_path}" "$@"
    elif is_executable_script "$(${REALPATH} ${app_path})"
    then
      "${app_path}" "$@"
    elif is_pe64 "$(${REALPATH} ${app_path})"
    then
      local wine_path=$(which wine64 2>/dev/null)
      if [ ! -z "${wine_path}" ]
      then
        (
          unset DISPLAY
          export WINEDEBUG=-all
          wine64 "${app_path}" "$@"
        )
      else
        echo
        echo "wine64 ${app_path} $@ - not available in ${FUNCNAME[0]}()"
      fi
    elif is_pe64 "$(${REALPATH} ${app_path}.exe)"
    then
      local wine_path=$(which wine64 2>/dev/null)
      if [ ! -z "${wine_path}" ]
      then
        (
          unset DISPLAY
          export WINEDEBUG=-all
          wine64 "${app_path}.exe" "$@"
        )
      else
        echo
        echo "wine64 ${app_path} $@ - not available in ${FUNCNAME[0]}()"
      fi
    elif is_pe32 "$(${REALPATH} ${app_path})"
    then
      local wine_path=$(which wine 2>/dev/null)
      if [ ! -z "${wine_path}" ]
      then
        (
          unset DISPLAY
          export WINEDEBUG=-all
          wine "${app_path}" "$@"
        )
      else
        echo
        echo "wine ${app_path} $@ - not available in ${FUNCNAME[0]}()"
      fi
    elif is_pe32 "$(${REALPATH} ${app_path}.exe)"
    then
      local wine_path=$(which wine 2>/dev/null)
      if [ ! -z "${wine_path}" ]
      then
        (
          unset DISPLAY
          export WINEDEBUG=-all
          wine "${app_path}.exe" "$@"
        )
      else
        echo
        echo "wine ${app_path} $@ - not available in ${FUNCNAME[0]}()"
      fi
    else
      echo
      echo "Unsupported \"${app_path} $@\" in ${FUNCNAME[0]}()"
      exit 1
    fi
  elif [ "${XBB_BUILD_PLATFORM}" == "darwin" ]
  then
    if is_elf "$(${REALPATH} ${app_path})"
    then
      "${app_path}" "$@"
    elif is_executable_script "$(${REALPATH} ${app_path})"
    then
      "${app_path}" "$@"
    else
      echo
      echo "Unsupported \"${app_path} $@\" in ${FUNCNAME[0]}()"
      exit 1
    fi
  elif [ "${XBB_BUILD_PLATFORM}" == "win32" ]
  then
    "${app_path}" "$@"
  else
    echo
    echo "Unsupported XBB_HOST_PLATFORM=${XBB_HOST_PLATFORM} in ${FUNCNAME[0]}()"
    exit 1
  fi
}

function _run_app_exit()
{
  local expected_exit_code="$1"
  shift
  local app_path="$1"
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

# -----------------------------------------------------------------------------

function expect_host_output()
{
  local expected="$1"
  shift
  local app_path="$1"
  shift

  (
    set +e

    # Remove the trailing CR present on Windows.
    local output
    if [ "${app_path:0:1}" == "/" ]
    then
      show_host_libs "${app_path}"
      output="$(run_target_app "${app_path}" "$@" | sed -e 's|\r$||')"
    elif [ "${app_path:0:2}" == "./" ]
    then
      show_host_libs "${app_path}"
      output="$(run_target_app "${app_path}" "$@" | sed -e 's|\r$||')"
    elif [ -f "${app_path}.exe" ]
    then
      show_host_libs "${app_path}"
      output="$(run_target_app "${app_path}" "$@" | sed -e 's|\r$||')"
    else
      if [ -x "${app_path}" ]
      then
        show_host_libs "${app_path}"
        output="$(run_target_app "./${app_path}" "$@" | sed -e 's|\r$||')"
      else
        # bash case
        output="$(run_target_app "${app_path}" "$@" | sed -e 's|\r$||')"
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

function expect_target_output()
{
  local expected="$1"
  shift
  local app_name="$1"
  shift

  (
    local app_path="$(${REALPATH} "${app_name}")"

    show_target_libs_develop "${app_name}"

    local output=""

    if [ "${XBB_BUILD_PLATFORM}" == "linux" -o "${XBB_BUILD_PLATFORM}" == "darwin" ]
    then

      if is_elf "${app_path}"
      then
        echo
        echo "[${app_path} $@]"
        output="$("${app_path}" "$@" | sed -e 's|\r$||')"
      elif is_executable_script "${app_path}"
      then
        echo
        echo "[${app_path} $@]"
        output="$("${app_path}" "$@" | sed -e 's|\r$||')"
      elif is_pe64 "${app_path}"
      then
        local wine_path=$(which wine64 2>/dev/null)
        if [ ! -z "${wine_path}" ]
        then
          echo
          echo "[wine64 ${app_path} $@]"
          # Remove the trailing CR present on Windows.
          output="$(wine64 "${app_path}" "$@" | sed -e 's|\r$||')"
        else
          echo
          echo "wine64 ${app_name} $@ - not available in ${FUNCNAME[0]}()"
          return
        fi
      elif is_pe32 "${app_path}"
      then
        local wine_path=$(which wine 2>/dev/null)
        if [ ! -z "${wine_path}" ]
        then
          echo
          echo "[wine ${app_path} $@]"
          # Remove the trailing CR present on Windows.
          output="$(wine "${app_path}" "$@" | sed -e 's|\r$||')"
        else
          echo
          echo "wine ${app_name} $@ - not available in ${FUNCNAME[0]}()"
          return
        fi
      else
        echo
        echo "Unsupported \"${app_name} $@\" in ${FUNCNAME[0]}()"
        exit 1
      fi
    elif [ "${XBB_BUILD_PLATFORM}" == "win32" ]
    then
      output="$("${app_path}" "$@")"
    else
      echo
      echo "Unsupported XBB_HOST_PLATFORM=${XBB_HOST_PLATFORM} in ${FUNCNAME[0]}()"
      exit 1
    fi

    echo ${output}

    if [ "x${output}x" == "x${expected}x" ]
    then
      echo
      echo "Test \"${app_name} $@\" passed, got output \"${expected}\" :-)"
    else
      echo
      echo "Test \"${app_name} $@\" failed :-("
      echo "expected output ${#expected} chars: \"${expected}\""
      echo "got ${#output} chars: \"${output}\""
      echo
      exit 1
    fi
  )
}

function expect_target_succeed()
{
  expect_target_exit 0 "$@"
}

function expect_target_exit()
{
  local expected_exit_code="$1"
  shift

  local app_name="$1"
  shift

  (
    local app_path="$(${REALPATH} "${app_name}")"

    show_target_libs_develop "${app_name}"

    local succeed=""
    local exit_code=0

    if [ "${XBB_BUILD_PLATFORM}" == "linux" -o "${XBB_BUILD_PLATFORM}" == "darwin" ]
    then

      if is_elf "${app_path}"
      then
        echo
        echo "[${app_path} $@]"
        # This looks weird, but the purpose here is to run the command
        # within `if`, the result is the exit code in both cases.
        if "${app_path}" "$@"
        then
          : # Nothing special to do, get the exit code below.
        fi
        exit_code=$?

      elif is_executable_script "${app_path}"
      then
        echo
        echo "[${app_path} $@]"
        if "${app_path}" "$@"
        then
          :
        fi
        exit_code=$?
      elif is_pe64 "${app_path}"
      then
        local wine_path=$(which wine64 2>/dev/null)
        if [ ! -z "${wine_path}" ]
        then
          echo
          echo "[wine64 ${app_path} $@]"
          if wine64 "${app_path}" "$@"
          then
            :
          fi
          exit_code=$?
        else
          echo
          echo "wine64 ${app_name} $@ - not available in ${FUNCNAME[0]}()"
          return
        fi
      elif is_pe32 "${app_path}"
      then
        local wine_path=$(which wine 2>/dev/null)
        if [ ! -z "${wine_path}" ]
        then
          echo
          echo "[wine ${app_path} $@]"
          if wine "${app_path}" "$@"
          then
            :
          fi
          exit_code=$?
        else
          echo
          echo "wine ${app_name} $@ - not available in ${FUNCNAME[0]}()"
          return
        fi
      else
        echo
        echo "Unsupported \"${app_name} $@\" in ${FUNCNAME[0]}()"
        exit 1
      fi

    elif [ "${XBB_BUILD_PLATFORM}" == "win32" ]
    then
      echo
      echo "[${app_path} $@]"
      if "${app_path}" "$@"
      then
        :
      fi
      exit_code=$?
    else
      echo
      echo "Unsupported XBB_HOST_PLATFORM=${XBB_HOST_PLATFORM} in ${FUNCNAME[0]}()"
      exit 1
    fi

    if [ ${exit_code} -eq ${expected_exit_code} ]
    then
      echo
      echo "Test \"${app_name} $@\" passed, got exit code: ${exit_code} :-)"
    else
      echo
      echo "Test \"${app_name} $@\" failed, got exit code: ${exit_code}, expeted ${expected_exit_code} :-("
      echo
      exit 1
    fi
  )
}

function _run_mingw()
{
  local app_name="$1"
  shift

  local app_path="$(${REALPATH} "${app_name}")"

  show_target_libs_develop "${app_path}"

  if is_pe64 "${app_path}"
  then
    (
      local wine_path=$(which wine64 2>/dev/null)
      if [ ! -z "${wine_path}" ]
      then
        run_verbose wine64 "${app_name}" "$@"
      else
        echo
        echo "wine64" "${app_name}" "$@" "- not available in ${FUNCNAME[0]}()"
      fi
    )
  elif is_pe32 "${app_path}"
  then
    (
      local wine_path=$(which wine 2>/dev/null)
      if [ ! -z "${wine_path}" ]
      then
        run_verbose wine "${app_name}" "$@"
      else
        echo
        echo "wine" "${app_name}" "$@" "- not available in ${FUNCNAME[0]}()"
      fi
    )
  fi
}

# -----------------------------------------------------------------------------
