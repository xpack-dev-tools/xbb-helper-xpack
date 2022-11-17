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

function show_libs()
{
  # Does not include the .exe extension.
  local app_path=$1
  shift

  (
    if [ "${XBB_HOST_PLATFORM}" == "linux" ]
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
    elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
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
    elif [ "${XBB_HOST_PLATFORM}" == "win32" ]
    then
      if is_elf "${app_path}"
      then
        run_verbose ls -l "${app_path}"
        if [ "${XBB_IS_DEVELOP}" == "y" ]
        then
          run_verbose file "${app_path}"
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
      else
        if false # [ -f "${app_path}" ]
        then
          run_verbose ls -l "${app_path}"
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose file "${app_path}"
          fi
          echo
          echo "[${XBB_TARGET_TRIPLET}-objdump -x ${app_path}]"
          ${XBB_TARGET_TRIPLET}-objdump -x ${app_path} | grep -i 'DLL Name' || true
        elif [ -f "${app_path}.exe" ]
        then
          run_verbose ls -l "${app_path}.exe"
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose file "${app_path}.exe"
          fi
          echo
          echo "[${XBB_TARGET_TRIPLET}-objdump -x ${app_path}.exe]"
          ${XBB_TARGET_TRIPLET}-objdump -x ${app_path}.exe | grep -i 'DLL Name' || true
        else
          run_verbose file "${app_path}"
        fi
      fi
    else
      echo "Unsupported XBB_HOST_PLATFORM=${XBB_HOST_PLATFORM} in ${FUNCNAME[0]}()"
      exit 1
    fi
  )
}

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

function show_native_libs()
{
  # Does not include the .exe extension.
  local app_path=$1
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

function show_dlls()
{
  # Does not include the .exe extension.
  local objdump_path="$1"
  local exe_path="$2"

  (
    if [ -f "${exe_path}" ]
    then
      run_verbose ls -l "${exe_path}"
      if [ "${XBB_IS_DEVELOP}" == "y" ]
      then
        run_verbose file "${exe_path}"
      fi
      echo
      echo "[${objdump_path} -x ${exe_path}]"
      "${objdump_path}" -x "${exe_path}" | grep -i 'DLL Name' || true
    else
      echo
      file "${exe_path}"
    fi
  )
}

# -----------------------------------------------------------------------------
