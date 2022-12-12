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

# Copy one folder to another.
function copy_dir()
{
  local from_path="$1"
  local to_path="$2"

  echo
  echo "# Copying ${from_path}..."

  set +u
  # rm -rf "${to_path}"
  mkdir -pv "${to_path}"

  (
    cd "${from_path}"
    if [ "${XBB_BUILD_PLATFORM}" == "darwin" ]
    then
      find . -xdev -print0 | cpio -oa0 | (cd "${to_path}" && cpio -im)
    else
      find . -xdev -print0 | cpio -oa0V | (cd "${to_path}" && cpio -imuV)
    fi
  )

  set -u
}

# -----------------------------------------------------------------------------

# Output the result of a filtered otool.
function get_darwin_lc_rpaths()
{
  local file_path="$1"

  otool -l "${file_path}" | grep LC_RPATH -A2 | grep '(offset ' | sed -e 's|.*path \(.*\) (offset.*)|\1|'
}

function get_darwin_dylibs()
{
  local file_path="$1"

  if is_darwin_dylib "${file_path}"
  then
    # Skip the extra line with the library name.
    otool -L "${file_path}" \
          | sed '1d' \
          | sed '1d' \
          | sed -e 's|[[:space:]]*\(.*\) (.*)|\1|' \

  else
    otool -L "${file_path}" \
          | sed '1d' \
          | sed -e 's|[[:space:]]*\(.*\) (.*)|\1|' \

  fi
}

function get_linux_rpaths_line()
{
  local file_path="$1"

  readelf -d "${file_path}" \
    | egrep '(RUNPATH|RPATH)' \
    | sed -e 's|.*\[\(.*\)\]|\1|'

}

# -----------------------------------------------------------------------------
