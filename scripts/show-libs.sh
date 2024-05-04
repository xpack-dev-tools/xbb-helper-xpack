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

    local abs_path="$(${REALPATH} ${app_path})"
    local abs_exe_path="$(${REALPATH} ${app_path}.exe)"

    if [ "${XBB_BUILD_PLATFORM}" == "linux" ]
    then
      if is_elf "${abs_path}"
      then
        run_verbose ls -l "${abs_path}"
        if [ "${XBB_IS_DEVELOP}" == "y" ]
        then
          run_verbose file -L "${abs_path}"
        fi
        echo
        echo "[readelf -d ${abs_path} | egrep ...]"
        # Ignore errors in case it is not using shared libraries.
        set +e
        readelf_shared_libs "${abs_path}"
        echo
        echo "[ldd -v ${abs_path}]"
        ldd -v "${abs_path}" || true
        set -e
      elif is_pe "${abs_path}"
      then
        run_verbose ls -l "${abs_path}"
        if [ "${XBB_IS_DEVELOP}" == "y" ]
        then
          run_verbose file "${abs_path}"
        fi
        echo
        echo "[${XBB_HOST_OBJDUMP} -x ${abs_path}]"
        "${XBB_HOST_OBJDUMP}" -x "${abs_path}" | grep -i 'DLL Name' || true
      elif is_pe "${abs_exe_path}"
      then
        run_verbose ls -l "${abs_exe_path}"
        if [ "${XBB_IS_DEVELOP}" == "y" ]
        then
          run_verbose file "${abs_exe_path}"
        fi
        echo
        echo "[${XBB_HOST_OBJDUMP} -x ${abs_exe_path}]"
        "${XBB_HOST_OBJDUMP}" -x "${abs_exe_path}" | grep -i 'DLL Name' || true
      else
        run_verbose file -L "${abs_path}"
        echo
        echo "Unsupported \"${abs_path}\" in ${FUNCNAME[0]}()"
        exit 1
      fi
    elif [ "${XBB_BUILD_PLATFORM}" == "darwin" ]
    then
      if is_elf "${abs_path}"
      then
        run_verbose ls -l "${abs_path}"
        if [ "${XBB_IS_DEVELOP}" == "y" ]
        then
          run_verbose file -L "${abs_path}"
        fi
        echo
        # echo "[otool -L ${abs_path}]"
        echo "[${XBB_HOST_OBJDUMP} --macho --dylibs-used ${abs_path}]"
        set +e
        local lc_rpaths=$(darwin_get_lc_rpaths "${abs_path}")
        local lc_rpaths_line=$(echo "${lc_rpaths}" | tr '\n' ':' | sed -e 's|:$||')
        if [ ! -z "${lc_rpaths_line}" ]
        then
          echo "${abs_path}: (LC_RPATH=${lc_rpaths_line})"
        else
          echo "${abs_path}:"
        fi
        # otool -L "${abs_path}" | tail -n +2
        "${XBB_HOST_OBJDUMP}" --macho --dylibs-used "${abs_path}" | tail -n +2
      else
        run_verbose file -L "${abs_path}"
        echo
        echo "Unsupported \"${abs_path}\" in ${FUNCNAME[0]}()"
        exit 1
      fi
    elif [ "${XBB_BUILD_PLATFORM}" == "win32" ]
    then
      run_verbose ls -l "${abs_path}"
      if [ "${XBB_IS_DEVELOP}" == "y" ]
      then
        run_verbose file -L "${abs_path}"
      fi
      if [ -z "$(which ${XBB_HOST_OBJDUMP} 2>/dev/null)" ]
      then
        echo "${FUNCNAME[0]}() cannot show DLLs on Windows (no objdump)"
      else
        if [ -f "${abs_exe_path}" ]
        then
          echo "[${XBB_HOST_OBJDUMP} -x ${abs_exe_path}]"
          "${XBB_HOST_OBJDUMP}" -x "${abs_exe_path}" | grep -i 'DLL Name' || true
        elif [ -f "${abs_path}" ]
        then
          echo "[${XBB_HOST_OBJDUMP} -x ${abs_path}]"
          "${XBB_HOST_OBJDUMP}" -x "${abs_path}" | grep -i 'DLL Name' || true
        fi
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

    local abs_path="$(${REALPATH} ${app_path})"
    local abs_exe_path="$(${REALPATH} ${app_path}.exe)"

    if [ "${XBB_BUILD_PLATFORM}" == "linux" ]
    then
      if is_elf "${abs_path}"
      then
        run_verbose ls -l "${abs_path}"
        if [ "${XBB_IS_DEVELOP}" == "y" ]
        then
          run_verbose file -L "${abs_path}"
        fi
        echo
        echo "[readelf -d ${abs_path} | egrep ...]"
        # Ignore errors in case it is not using shared libraries.
        set +e
        readelf_shared_libs "${abs_path}"
        echo
        echo "[ldd -v ${abs_path}]"
        ldd -v "${abs_path}" || true
        set -e
      elif is_pe "${abs_path}"
      then
        run_verbose ls -l "${abs_path}"
        if [ "${XBB_IS_DEVELOP}" == "y" ]
        then
          run_verbose file "${abs_path}"
        fi
        echo
        echo "[${XBB_TARGET_OBJDUMP} -x ${abs_path}]"
        "${XBB_TARGET_OBJDUMP}" -x "${abs_path}" | grep -i 'DLL Name' || true
      elif is_pe "${abs_exe_path}"
      then
        run_verbose ls -l "${abs_exe_path}"
        if [ "${XBB_IS_DEVELOP}" == "y" ]
        then
          run_verbose file "${abs_exe_path}"
        fi
        echo
        echo "[${XBB_TARGET_OBJDUMP} -x ${abs_exe_path}]"
        "${XBB_TARGET_OBJDUMP}" -x "${abs_exe_path}" | grep -i 'DLL Name' || true
      else
        run_verbose file -L "${abs_path}"
        echo
        echo "Unsupported \"${abs_path}\" in ${FUNCNAME[0]}()"
        exit 1
      fi
    elif [ "${XBB_BUILD_PLATFORM}" == "darwin" ]
    then
      if is_elf "${abs_path}"
      then
        run_verbose ls -l "${abs_path}"
        if [ "${XBB_IS_DEVELOP}" == "y" ]
        then
          run_verbose file -L "${abs_path}"
        fi
        echo
        # echo "[otool -L ${abs_path}]"
        echo "[${XBB_TARGET_OBJDUMP} --macho --dylibs-used ${abs_path}]"
        set +e
        local lc_rpaths=$(darwin_get_lc_rpaths "${abs_path}")
        local lc_rpaths_line=$(echo "${lc_rpaths}" | tr '\n' ':' | sed -e 's|:$||')
        if [ ! -z "${lc_rpaths_line}" ]
        then
          echo "${abs_path}: (LC_RPATH=${lc_rpaths_line})"
        else
          echo "${abs_path}:"
        fi
        # otool -L "${abs_path}" | tail -n +2
        "${XBB_TARGET_OBJDUMP}" --macho --dylibs-used "${abs_path}" | tail -n +2
      elif is_pe "${abs_path}"
      then
        run_verbose ls -l "${abs_path}"
        if [ "${XBB_IS_DEVELOP}" == "y" ]
        then
          run_verbose file "${abs_path}"
        fi
        echo
        echo "[${XBB_TARGET_OBJDUMP} -x ${abs_path}]"
        "${XBB_TARGET_OBJDUMP}" -x "${abs_path}" | grep -i 'DLL Name' || true
      elif is_pe "${abs_exe_path}"
      then
        run_verbose ls -l "${abs_exe_path}"
        if [ "${XBB_IS_DEVELOP}" == "y" ]
        then
          run_verbose file "${abs_exe_path}"
        fi
        echo
        echo "[${XBB_TARGET_OBJDUMP} -x ${abs_exe_path}]"
        "${XBB_TARGET_OBJDUMP}" -x "${abs_exe_path}" | grep -i 'DLL Name' || true
      else
        run_verbose file -L "${abs_path}"
        echo
        echo "Unsupported \"${abs_path}\" in ${FUNCNAME[0]}()"
        exit 1
      fi
    elif [ "${XBB_BUILD_PLATFORM}" == "win32" ]
    then
      run_verbose ls -l "${abs_path}"
      if [ "${XBB_IS_DEVELOP}" == "y" ]
      then
        run_verbose file -L "${abs_path}"
      fi
      if [ -z "$(which ${XBB_TARGET_OBJDUMP} 2>/dev/null)" ]
      then
        echo "${FUNCNAME[0]}() cannot show DLLs on Windows (no objdump)"
      else
        if [ -f "${abs_exe_path}" ]
        then
          echo "[${XBB_TARGET_OBJDUMP} -x ${abs_exe_path}]"
          "${XBB_TARGET_OBJDUMP}" -x "${abs_exe_path}" | grep -i 'DLL Name' || true
        elif [ -f "${abs_path}" ]
        then
          echo "[${XBB_TARGET_OBJDUMP} -x ${abs_path}]"
          "${XBB_TARGET_OBJDUMP}" -x "${abs_path}" | grep -i 'DLL Name' || true
        fi
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
