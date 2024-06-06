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

function trigger_github_workflow()
{
  echo
  echo "[${FUNCNAME[0]} $@]"

  local github_org="$1"
  local github_repo="$2"
  local workflow_id="$3"
  local data_file_path="$4"
  local token="$5"

  echo
  echo "Request body:"
  cat "${data_file_path}"

  # This script requires an authentication token in the environment.
  # https://docs.github.com/en/rest/reference/actions#create-a-workflow-dispatch-event

  echo
  echo "Response:"

  curl \
    --request POST \
    --include \
    --header "Authorization: token ${token}" \
    --header "Content-Type: application/json" \
    --header "Accept: application/vnd.github.v3+json" \
    --data-binary @"${data_file_path}" \
    https://api.github.com/repos/${github_org}/${github_repo}/actions/workflows/${workflow_id}/dispatches

  rm -rf "${data_file_path}"
}

function download_binaries()
{
  local destination_folder_path="${1:-"${HOME}/Downloads/xpack-binaries/${XBB_APPLICATION_LOWER_CASE_NAME}"}"

  local version=${XBB_RELEASE_VERSION:-"$(xbb_get_current_version)"}

  (
    rm -rf "${destination_folder_path}-bak"
    if [ -d "${destination_folder_path}" ]
    then
      mv "${destination_folder_path}" "${destination_folder_path}-bak"
    fi

    mkdir -pv "${destination_folder_path}"
    cd "${destination_folder_path}"

    local package_file_path="${project_folder_path}/package.json"

    # Extract the xpack.properties platforms. There are also in xpack.binaries.
    local platforms=$(grep '"platforms": "' "${package_file_path}" | sed -e 's|.*: "||' | sed -e 's|".*||' | sed 's|,| |g')
    if [ "${platforms}" == "all" ]
    then
      platforms='linux-x64 linux-arm64 linux-arm darwin-x64 darwin-arm64 win32-x64'
    fi

    IFS=' '
    for platform in ${platforms}
    do

      # echo ${platform}
      # https://github.com/xpack-dev-tools/pre-releases/releases/download/test/xpack-ninja-build-1.11.1-2-win32-x64.zip
      local extension='tar.gz'
      if [ "${platform}" == "win32-x64" ]
      then
        extension='zip'
      fi

      archive_name="${XBB_APPLICATION_DISTRO_LOWER_CASE_NAME}-${XBB_APPLICATION_LOWER_CASE_NAME}-${version}-${platform}.${extension}"
      archive_url="https://github.com/xpack-dev-tools/pre-releases/releases/download/test/${archive_name}"

      run_verbose curl --location --insecure --fail --location --silent \
        --output "${archive_name}" \
        "${archive_url}"

      run_verbose curl --location --insecure --fail --location --silent \
        --output "${archive_name}.sha" \
        "${archive_url}.sha"

    done

    rm -rf "${destination_folder_path}-bak"
  )
}

# -----------------------------------------------------------------------------
