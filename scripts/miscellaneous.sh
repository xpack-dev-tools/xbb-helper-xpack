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

# $1 - absolute path to input folder
# $2 - name of output folder below INSTALL_FOLDER
function copy_license()
{
  # Iterate all files in a folder and install some of them in the
  # destination folder
  (
    if [ -z "$2" ]
    then
      return
    fi

    echo
    echo "Copying license files for $2..."

    cd "$1"
    local f
    for f in *
    do
      if [ -f "$f" ]
      then
        if [[ $f =~ AUTHORS.*|NEWS.*|COPYING.*|README.*|LICENSE.*|Copyright.*|COPYRIGHT.*|FAQ.*|DEPENDENCIES.*|THANKS.*|CHANGES.* ]]
        then
          install -d -m 0755 \
            "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/${XBB_DISTRO_INFO_NAME}/licenses/$2"
          install -v -c -m 644 "$f" \
            "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/${XBB_DISTRO_INFO_NAME}/licenses/$2"
        fi
      elif [ -d "$f" ] && [[ $f =~ [Ll][Ii][Cc][Ee][Nn][Ss][Ee]* ]]
      then
        (
          cd "$f"
          local files=$(find . -type f)
          for file in ${files}
          do
            install -d -m 0755 \
              "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/${XBB_DISTRO_INFO_NAME}/licenses/$2/$(dirname ${file})"
            install -v -c -m 644 "$file" \
              "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/${XBB_DISTRO_INFO_NAME}/licenses/$2/$(dirname ${file})"
          done
        )
      fi
    done
  )
  (
    if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
    then
      find "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/${XBB_DISTRO_INFO_NAME}/licenses" \
        -type f \
        -exec unix2dos '{}' ';'
    fi
  )
}

function copy_build_files()
{
  echo
  echo "Copying build files..."

  local verbose=""

  (
    rm -rf "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/${XBB_DISTRO_INFO_NAME}/scripts"
    rm -rf "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/${XBB_DISTRO_INFO_NAME}/patches"

    cd "${XBB_BUILD_GIT_PATH}"

    # Ignore hidden folders/files (like .DS_Store).
    find scripts -type d ! -iname '.*' \
      -exec install -d -m 0755 \
        "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/${XBB_DISTRO_INFO_NAME}"/'{}' ';'

    find scripts -type f ! -iname '.*' \
      -exec install -v -c -m 644 \
        '{}' "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/${XBB_DISTRO_INFO_NAME}"/'{}' ';'

    if [ -d patches ]
    then
      find patches -type d ! -iname '.*' \
        -exec install -d -m 0755 \
          "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/${XBB_DISTRO_INFO_NAME}"/'{}' ';'

      find patches -type f ! -iname '.*' \
        -exec install -v -c -m 644 \
          '{}' "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/${XBB_DISTRO_INFO_NAME}"/'{}' ';'
    fi

    if [ -f CHANGELOG.txt ]
    then
      install -v -c -m 644 \
          CHANGELOG.txt "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/${XBB_DISTRO_INFO_NAME}"
    fi
    if [ -f CHANGELOG.md ]
    then
      install -v -c -m 644 \
          CHANGELOG.md "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/${XBB_DISTRO_INFO_NAME}"
    fi
  )
}

# Must be called in the build folder, like
# cd "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}"
# cd "${XBB_BUILD_FOLDER_PATH}"

function copy_cmake_logs()
{
  local folder_name="$1"

  echo
  echo "Preserving CMake log files..."
  rm -rf "${XBB_LOGS_FOLDER_PATH}/${folder_name}"
  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${folder_name}/CMakeFiles"

  (
    cd "${folder_name}"
    cp -v "CMakeCache.txt" "${XBB_LOGS_FOLDER_PATH}/${folder_name}"

    cp -v "CMakeFiles"/*.log "${XBB_LOGS_FOLDER_PATH}/${folder_name}/CMakeFiles"
  )
}

# -----------------------------------------------------------------------------
