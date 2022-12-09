#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2022 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# Environment variables:
#
# - XBB_DOWNLOAD_FOLDER_PATH
# - XBB_WITH_UPDATE_CONFIG_SUB
# - XBB_BUILD_GIT_PATH
# - DEBUG

# -----------------------------------------------------------------------------

function git_clone()
{
  local url="$1"
  local branch="$2"
  local commit="$3"
  local folder_name="$4"

  (
    echo
    echo "Cloning \"${folder_name}\" from \"${url}\"..."
    run_verbose git clone --branch="${branch}" "${url}" "${folder_name}"
    if [ -n "${commit}" ]
    then
      cd "${folder_name}"
      run_verbose git checkout -qf "${commit}"
    fi
  )
}

# $4 is the patch file name only, not the full path
function download_and_extract()
{
  local url="$1"
  local archive_name="$2"
  local folder_name="$3"

  download "${url}" "${archive_name}"
  if [ $# -ge 4 ]
  then
    extract "${XBB_DOWNLOAD_FOLDER_PATH}/${archive_name}" "${folder_name}" "$4"
  else
    extract "${XBB_DOWNLOAD_FOLDER_PATH}/${archive_name}" "${folder_name}"
  fi

  chmod -R +w "${folder_name}" || true

  local with_update_config_sub=${XBB_WITH_UPDATE_CONFIG_SUB:-""}
  if [ "${with_update_config_sub}" == "y" ]
  then
    update_config_sub "${folder_name}"
  fi
}

function download()
{
  local url="$1"
  local archive_name="$2"

  if [ ! -f "${XBB_DOWNLOAD_FOLDER_PATH}/${archive_name}" ]
  then
    (
      echo
      echo "Downloading \"${archive_name}\" from \"${url}\"..."
      rm -f "${XBB_DOWNLOAD_FOLDER_PATH}/${archive_name}.download"
      mkdir -pv "${XBB_DOWNLOAD_FOLDER_PATH}"
      run_verbose curl --insecure --fail --location --output "${XBB_DOWNLOAD_FOLDER_PATH}/${archive_name}.download" "${url}"
      mv "${XBB_DOWNLOAD_FOLDER_PATH}/${archive_name}.download" "${XBB_DOWNLOAD_FOLDER_PATH}/${archive_name}"
    )
  else
    echo
    echo "File \"${XBB_DOWNLOAD_FOLDER_PATH}/${archive_name}\" already downloaded"
  fi
}

function extract()
{
  local archive_file_path="$1"
  local folder_name="$2"
  # local patch_file_name="$3"
  local pwd="$(pwd)"

  if [ ! -d "${folder_name}" ]
  then
    (
      echo
      echo "Extracting \"${archive_file_path}\" -> \"${pwd}/${folder_name}\"..."
      if [[ "${archive_file_path}" == *zip ]]
      then
        run_verbose_develop unzip "${archive_file_path}"
      else
        # On macOS Docker seems to have a problem and extracting symlinks
        # fails, but a second atempt is successful.
        if [ ! -z "${DEBUG}" ]
        then
          run_verbose_develop tar -x -v -f "${archive_file_path}" --no-same-owner || tar -x -v -f "${archive_file_path}" --no-same-owner
        else
          run_verbose_develop tar -x -f "${archive_file_path}" --no-same-owner || tar -x -f "${archive_file_path}" --no-same-owner
        fi
      fi

      if [ $# -ge 3 ]
      then
        cd "${folder_name}"
        _do_patch "$3"
      fi
    )
  else
    echo
    echo "Folder \"${pwd}/${folder_name}\" already present"
  fi
}

function _do_patch()
{
  if [ ! -z "$1" ]
  then
    local patch_file_name="$1"
    local patch_path="${XBB_BUILD_GIT_PATH}/patches/${patch_file_name}"
    if [ ! -f "${patch_path}" ]
    then
      # If not local in the project, try in the common helper.
      patch_path="${helper_folder_path}/patches/${patch_file_name}"
    fi

    if [ -f "${patch_path}" ]
    then
      echo "Applying \"${patch_path}\"..."
      if [[ ${patch_path} == *.patch.diff ]] || [[ ${patch_path} == *.git.patch ]]
      then
        # Fork & Sourcetree creates patch.diff files, which require -p1.
        run_verbose_develop patch -p1 < "${patch_path}"
      else
        # Manually created patches.
        run_verbose_develop patch -p0 < "${patch_path}"
      fi
    fi
  fi
}

function update_config_sub()
{
  local folder_path="$1"

  (
    cd "${folder_path}"

    find . -name 'config.sub' \
      -exec cp -v "${helper_folder_path}/config/config.sub" "{}" \;
  )
}

# -----------------------------------------------------------------------------
