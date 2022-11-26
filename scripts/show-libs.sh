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

function show_host_libs()
{
  local app_path="$1"
  shift

  (
    if [ ! -f "${app_path}" ] && [ ! -f "${app_path}.exe" ]
    then
      run_verbose file -L "${app_path}"
      return
    fi

    local realpath=$(which grealpath || which realpath || echo realpath)

    if [ "${XBB_BUILD_PLATFORM}" == "linux" ]
    then
      if is_elf "$(${realpath} ${app_path})"
      then
        run_verbose ls -l "${app_path}"
        if [ "${XBB_IS_DEVELOP}" == "y" ]
        then
          run_verbose file -L "${app_path}"
        fi
        echo
        echo "[readelf -d ${app_path} | egrep ...]"
        # Ignore errors in case it is not using shared libraries.
        set +e
        readelf_shared_libs "${app_path}"
        echo
        echo "[ldd -v ${app_path}]"
        ldd -v "${app_path}" || true
        set -e
      elif is_pe "${app_path}"
      then
        run_verbose ls -l "${app_path}"
        if [ "${XBB_IS_DEVELOP}" == "y" ]
        then
          run_verbose file "${app_path}"
        fi
        echo
        echo "[${XBB_HOST_OBJDUMP} -x ${app_path}]"
        "${XBB_HOST_OBJDUMP}" -x "${app_path}" | grep -i 'DLL Name' || true
      elif is_pe "${app_path}.exe"
      then
        run_verbose ls -l "${app_path}.exe"
        if [ "${XBB_IS_DEVELOP}" == "y" ]
        then
          run_verbose file "${app_path}.exe"
        fi
        echo
        echo "[${XBB_HOST_OBJDUMP} -x ${app_path}.exe]"
        "${XBB_HOST_OBJDUMP}" -x "${app_path}.exe" | grep -i 'DLL Name' || true
      else
        run_verbose file -L "${app_path}"
        echo
        echo "Unsupported \"${app_path}\" in ${FUNCNAME[0]}()"
        exit 1
      fi
    elif [ "${XBB_BUILD_PLATFORM}" == "darwin" ]
    then
      if is_elf "$(${realpath} ${app_path})"
      then
        run_verbose ls -l "${app_path}"
        if [ "${XBB_IS_DEVELOP}" == "y" ]
        then
          run_verbose file -L "${app_path}"
        fi
        echo
        echo "[otool -L ${app_path}]"
        set +e
        local lc_rpaths=$(get_darwin_lc_rpaths "${app_path}")
        local lc_rpaths_line=$(echo "${lc_rpaths}" | tr '\n' ':' | sed -e 's|:$||')
        if [ ! -z "${lc_rpaths_line}" ]
        then
          echo "${app_path}: (LC_RPATH=${lc_rpaths_line})"
        else
          echo "${app_path}:"
        fi
        otool -L "${app_path}" | tail -n +2
      else
        run_verbose file -L "${app_path}"
        echo
        echo "Unsupported \"${app_path}\" in ${FUNCNAME[0]}()"
        exit 1
      fi
    else
      echo
      echo "Unsupported XBB_BUILD_PLATFORM=${XBB_BUILD_PLATFORM} in ${FUNCNAME[0]}()"
      exit 1
    fi
  )
}

function show_target_libs()
{
  local app_path="$1"
  shift

  (
    if [ ! -f "${app_path}" ] && [ ! -f "${app_path}.exe" ]
    then
      run_verbose file -L "${app_path}"
      return
    fi

    local realpath=$(which grealpath || which realpath || echo realpath)

    if [ "${XBB_BUILD_PLATFORM}" == "linux" ]
    then
      if is_elf "$(${realpath} ${app_path})"
      then
        run_verbose ls -l "${app_path}"
        if [ "${XBB_IS_DEVELOP}" == "y" ]
        then
          run_verbose file -L "${app_path}"
        fi
        echo
        echo "[readelf -d ${app_path} | egrep ...]"
        # Ignore errors in case it is not using shared libraries.
        set +e
        readelf_shared_libs "${app_path}"
        echo
        echo "[ldd -v ${app_path}]"
        ldd -v "${app_path}" || true
        set -e
      elif is_pe "${app_path}"
      then
        run_verbose ls -l "${app_path}"
        if [ "${XBB_IS_DEVELOP}" == "y" ]
        then
          run_verbose file "${app_path}"
        fi
        echo
        echo "[${XBB_TARGET_OBJDUMP} -x ${app_path}]"
        "${XBB_TARGET_OBJDUMP}" -x "${app_path}" | grep -i 'DLL Name' || true
      elif is_pe "${app_path}.exe"
      then
        run_verbose ls -l "${app_path}.exe"
        if [ "${XBB_IS_DEVELOP}" == "y" ]
        then
          run_verbose file "${app_path}.exe"
        fi
        echo
        echo "[${XBB_TARGET_OBJDUMP} -x ${app_path}.exe]"
        "${XBB_TARGET_OBJDUMP}" -x "${app_path}.exe" | grep -i 'DLL Name' || true
      else
        run_verbose file -L "${app_path}"
        echo
        echo "Unsupported \"${app_path}\" in ${FUNCNAME[0]}()"
        exit 1
      fi
    elif [ "${XBB_BUILD_PLATFORM}" == "darwin" ]
    then
      if is_elf "$(${realpath} ${app_path})"
      then
        run_verbose ls -l "${app_path}"
        if [ "${XBB_IS_DEVELOP}" == "y" ]
        then
          run_verbose file -L "${app_path}"
        fi
        echo
        echo "[otool -L ${app_path}]"
        set +e
        local lc_rpaths=$(get_darwin_lc_rpaths "${app_path}")
        local lc_rpaths_line=$(echo "${lc_rpaths}" | tr '\n' ':' | sed -e 's|:$||')
        if [ ! -z "${lc_rpaths_line}" ]
        then
          echo "${app_path}: (LC_RPATH=${lc_rpaths_line})"
        else
          echo "${app_path}:"
        fi
        otool -L "${app_path}" | tail -n +2
      else
        run_verbose file -L "${app_path}"
        echo
        echo "Unsupported \"${app_path}\" in ${FUNCNAME[0]}()"
        exit 1
      fi
    else
      echo
      echo "Unsupported XBB_BUILD_PLATFORM=${XBB_BUILD_PLATFORM} in ${FUNCNAME[0]}()"
      exit 1
    fi
  )
}

function show_target_libs_develop()
{
  if [ "${XBB_IS_DEVELOP}" == "y" ]
  then
    show_target_libs "$@"
  fi
}

# -----------------------------------------------------------------------------

function readelf_shared_libs()
{
  local file_path="$1"
  shift

  (
    set +e

    readelf -d "${file_path}" | egrep '(SONAME)' || true
    readelf -d "${file_path}" | egrep '(RUNPATH|RPATH)' || true
    readelf -d "${file_path}" | egrep '(NEEDED)' || true
  )
}

function _show_native_libs()
{
  # Does not include the .exe extension.
  local app_path="$1"
  shift

  (
    echo
    echo "[readelf -d ${app_path} | egrep ...]"
    # Ignore errors in case it is not using shared libraries.
    set +e
    readelf_shared_libs "${app_path}"
    echo
    echo "[ldd -v ${app_path}]"
    ldd -v "${app_path}" || true
    set -e
  )
}

function _show_dlls()
{
  # Does include the .exe extension.
  local exe_path="$1"
  shift

  (
    if is_pe "${exe_path}"
    then
      run_verbose ls -l "${exe_path}"
      if [ "${XBB_IS_DEVELOP}" == "y" ]
      then
        run_verbose file "${exe_path}"
      fi
      echo
      echo "[${XBB_TARGET_OBJDUMP} -x ${exe_path}]"
      "${XBB_TARGET_OBJDUMP}" -x "${exe_path}" | grep -i 'DLL Name' || true
    else
      echo
      file "${exe_path}"
    fi
  )
}

# -----------------------------------------------------------------------------
