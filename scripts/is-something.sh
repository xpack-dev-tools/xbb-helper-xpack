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

function is_variable_set()
{
  # For convenience, turn dashes into underscores
  # and convert all letters to upper case.
  local variable_name=$(echo "$1" | tr '-' '_' | tr "[:lower:]" "[:upper:]")

  # https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#Shell-Parameter-Expansion
  # ! is the bash indirection operator
  # ${var+x} evaluates to null if x is not set
  # https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02
  if [ ! -z ${!variable_name+x} ]
  then
    return 0
  else
    return 1
  fi
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
    file ${bin_path} | egrep -q "( PE )|( PE32 )|( PE32\+ )"
  else
    return 1
  fi
}

# x.exe: PE32+ executable (console) x86-64 (stripped to external PDB), for MS Windows
# x.exe: PE32 executable (console) Intel 80386 (stripped to external PDB), for MS Windows

function is_pe64()
{
  if [ $# -lt 1 ]
  then
    warning "is_pe64: Missing arguments"
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
    # file ${bin_path} | egrep -q "( PE )|( PE32 )|( PE32\+ )" | egrep -q "x86-64"
    file ${bin_path} | grep -q "PE32+ executable (console) x86-64"
  else
    return 1
  fi
}

function is_pe32()
{
  if [ $# -lt 1 ]
  then
    warning "is_pe32: Missing arguments"
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
    file ${bin_path} | grep -q "PE32 executable (console) Intel 80386"
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

function is_executable_script()
{
  if [ $# -lt 1 ]
  then
    warning "is_executable_script: Missing arguments"
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
    if [ "${XBB_BUILD_PLATFORM}" == "linux" ] || [ "${XBB_BUILD_PLATFORM}" == "darwin" ]
    then
      file ${bin_path} | grep -q "text executable"
    else
      return 1
    fi
  else
    return 1
  fi
}

# -----------------------------------------------------------------------------

function is_native()
{
  if [ "${XBB_BUILD_PLATFORM}" == "${XBB_HOST_PLATFORM}" ] &&
     [ "${XBB_HOST_PLATFORM}" == "${XBB_TARGET_PLATFORM}" ]
  then
    return 0
  else
    return 1
  fi
}

function is_non_native()
{
  if [ "${XBB_BUILD_PLATFORM}" == "${XBB_HOST_PLATFORM}" ] &&
     [ "${XBB_HOST_PLATFORM}" == "${XBB_TARGET_PLATFORM}" ]
  then
    return 1
  else
    return 0
  fi
}

function is_bootstrap()
{
  if [ "${XBB_BUILD_PLATFORM}" == "${XBB_HOST_PLATFORM}" ] &&
     [ "${XBB_HOST_PLATFORM}" != "${XBB_TARGET_PLATFORM}" ]
  then
    return 0
  else
    return 1
  fi
}

function is_cross()
{
  if [ "${XBB_BUILD_PLATFORM}" != "${XBB_HOST_PLATFORM}" ] &&
     [ "${XBB_HOST_PLATFORM}" == "${XBB_TARGET_PLATFORM}" ]
  then
    return 0
  else
    return 1
  fi
}

function is_gcc()
{
  if [[ "$(basename "${CC}")" =~ .*gcc.* ]]
  then
    return 0
  else
    return 1
  fi
}

function is_mingw_gcc()
{
  if [[ "$(basename "${CC}")" =~ .*mingw32-gcc.* ]]
  then
    return 0
  else
    return 1
  fi
}

function is_clang()
{
  if [[ "$(basename "${CC}")" =~ .*clang.* ]]
  then
    return 0
  else
    return 1
  fi
}

function is_mingw_clang()
{
  if [[ "$(basename "${CC}")" =~ .*mingw32-clang.* ]]
  then
    return 0
  else
    return 1
  fi
}

# -----------------------------------------------------------------------------
