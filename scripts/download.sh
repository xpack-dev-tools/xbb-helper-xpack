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

# Runs in the XBB_SOURCES_FOLDER_PATH folder.
function git_clone()
{
  local url="$1"
  shift
  local folder_name="$1"
  shift

  local branch=""
  local commit=""
  local patch_file_name=""

  while [ $# -gt 0 ]
  do
    case "$1" in
      --branch=* )
        branch=$(xbb_parse_option "$1")
        shift
        ;;

      --commit=* )
        commit=$(xbb_parse_option "$1")
        shift
        ;;

      --patch=* )
        patch_file_name=$(xbb_parse_option "$1")
        shift
        ;;

      * )
        echo "Unsupported argument $1 in ${FUNCNAME[0]}()"
        exit 1
        ;;
    esac
  done

  (
    echo
    echo "Cloning \"${folder_name}\" from \"${url}\"..."

    run_verbose rm -rf "${folder_name}" "${folder_name}.download"
    if [ -z "${branch}" ]
    then
      run_verbose git clone --verbose "${url}" "${folder_name}.download"
    else
      run_verbose git clone --verbose --branch "${branch}" "${url}" "${folder_name}.download"
    fi

    if [ -n "${commit}" ]
    then
      run_verbose git -C "${folder_name}.download" checkout -qf "${commit}"
    else
      run_verbose git -C "${folder_name}.download" rev-parse HEAD
    fi
    run_verbose git -C "${folder_name}.download" log -1 --format=%cd

    if [ -n "${patch_file_name}" ]
    then
      (
        cd "${folder_name}.download"
        _do_patch "${patch_file_name}"
      )
    fi

    run_verbose mv "${folder_name}.download" "${folder_name}"
  )
}

# $4 is the patch file name only, not the full path
function download_and_extract()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local url="$1"
  local archive_name="$2"
  local folder_name="$3"

  download "${url}" "${archive_name}"
  if [ $# -ge 4 ] && [ -n "$4" ]
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
      # Not guaranteed to be unique between containers, but good enough.
      local rand=$(echo $((RANDOM)))
      rm -f "${XBB_DOWNLOAD_FOLDER_PATH}/${archive_name}.${rand}.download"
      mkdir -pv "${XBB_DOWNLOAD_FOLDER_PATH}"
      run_verbose curl --insecure --fail --location --output "${XBB_DOWNLOAD_FOLDER_PATH}/${archive_name}.${rand}.download" "${url}"
      if [ ! -f "${XBB_DOWNLOAD_FOLDER_PATH}/${archive_name}" ]
      then
        mv -fv "${XBB_DOWNLOAD_FOLDER_PATH}/${archive_name}.${rand}.download" "${XBB_DOWNLOAD_FOLDER_PATH}/${archive_name}"
      else
        rm -f "${XBB_DOWNLOAD_FOLDER_PATH}/${archive_name}.${rand}.download"
      fi
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
        run_verbose_develop unzip -q "${archive_file_path}"
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

      if [ $# -ge 3 ] && [ -n "$3" ]
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
      echo
      echo "Applying \"${patch_path}\"..."
      if [[ ${patch_path} == *.patch.diff ]] || [[ ${patch_path} == *.git.patch ]]
      then
        # Fork & Sourcetree creates patch.diff files, which require -p1.
        run_verbose_develop patch -p1 < "${patch_path}"
      else
        # Manually created patches.
        run_verbose_develop patch -p0 < "${patch_path}"
      fi
    else
      echo_develop
      echo_develop "Patch \"${patch_file_name}\" not found, skipping..."
    fi
  fi
}

function check_patch()
{
  local patch_file_name="$1"

  local patch_path="${XBB_BUILD_GIT_PATH}/patches/${patch_file_name}"
  if [ ! -f "${patch_path}" ]
  then
    # If not local in the project, try in the common helper.
    patch_path="${helper_folder_path}/patches/${patch_file_name}"
  fi

  if [ ! -f "${patch_path}" ]
  then
    echo
    echo "Patch \"${patch_file_name}\" not found"
    exit 1
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
