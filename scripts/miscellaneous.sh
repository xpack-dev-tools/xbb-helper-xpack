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

    if [ "${XBB_HOST_PLATFORM}" == "win32" ]
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

function copy_libudev()
{
  (
    if [ -f "/usr/include/libudev.h" ]
    then
      cp -v "/usr/include/libudev.h" "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include"
    else
      echo "No libudev.h"
      exit 1
    fi

    local find_path="$(find /lib* -name 'libudev.so.?' | sort -u | sed -n 1p)"
    if [ ! -z "${find_path}" ]
    then
      copy_libudev_with_links "${find_path}" "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib"
    fi

    find_path="$(find /usr/lib* -name 'libudev.so' | sort -u | sed -n 1p)"
    if [ ! -z "${find_path}" ]
    then
      copy_libudev_with_links "${find_path}" "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib"
    fi

    local find_pc_path="$(find /usr/lib* -name 'libudev.pc')"
    if [ ! -z "${find_pc_path}" ]
    then
      cp -v "${find_pc_path}" "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/pkgconfig"
    else
      echo "No libudev.pc"
      exit 1
    fi
  )
}

function copy_libudev_with_links()
{
  local from_file_path="$1"
  local dest_folder_path="$2"

  if [ -L "${from_file_path}" ]
  then
    local link_file_path="$(readlink "${from_file_path}")"
    if [ "${link_file_path}" == "$(basename "${link_file_path}")" ]
    then
      copy_libudev_with_links "$(dirname "${from_file_path}")/${link_file_path}" "${dest_folder_path}"
    else
      copy_libudev_with_links "${link_file_path}" "${dest_folder_path}"
    fi
    (
      cd "${dest_folder_path}"
      if [ ! -L "$(basename "${from_file_path}")" ]
      then
        ln -sv "$(basename "${link_file_path}")" "$(basename "${from_file_path}")"
      fi
    )
  else
    local dest_file_path="${dest_folder_path}/$(basename "${from_file_path}")"
    if [ ! -f "${dest_file_path}" ]
    then
      cp -v "${from_file_path}" "${dest_folder_path}"
    fi

    # Hack to get libudev.so in line with the 'all rpath' policy,
    # since on arm 32-bit it is checked.
    # Manually add $ORIGIN to libudev.so (fingers crossed!).
    run_verbose ${PATCHELF:-$(which patchelf || echo patchelf)} --force-rpath --set-rpath "\$ORIGIN" "${dest_file_path}"
  fi
}

# -----------------------------------------------------------------------------
