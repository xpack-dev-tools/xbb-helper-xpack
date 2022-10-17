#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Safety settings (see https://gist.github.com/ilg-ul/383869cbb01f61a51c4d).

if [[ ! -z ${DEBUG} ]]
then
  set ${DEBUG} # Activate the expand mode if DEBUG is anything but empty.
else
  DEBUG=""
fi

set -o errexit # Exit if command failed.
set -o pipefail # Exit if pipe failed.
set -o nounset # Exit if variable not set.

# Remove the initial space and instead use '\n'.
IFS=$'\n\t'

# -----------------------------------------------------------------------------
# Identify the script location, to reach, for example, the helper scripts.

script_path="$0"
if [[ "${script_path}" != /* ]]
then
  # Make relative path absolute.
  script_path="$(pwd)/$0"
fi

script_name="$(basename "${script_path}")"

script_folder_path="$(dirname "${script_path}")"
script_folder_name="$(basename "${script_folder_path}")"

# =============================================================================

helper_folder_path="$(dirname ${script_folder_path})"
project_folder_path="$(dirname $(dirname "${helper_folder_path}"))"
scripts_folder_path="${project_folder_path}/scripts"

# -----------------------------------------------------------------------------

source "${scripts_folder_path}/definitions.sh"

# Helper functions
source "${helper_folder_path}/github-actions/common.sh"
source "${helper_folder_path}/scripts/xbb.sh"

# -----------------------------------------------------------------------------

# Script to trigger a release publishing via GitHub Actions.

# GITHUB_API_DISPATCH_TOKEN must be present in the environment.

message="Build ${XBB_APPLICATION_NAME}"

branch="xpack-develop"
version=${XBB_RELEASE_VERSION:-"$(xbb_get_current_version)"}
workflow_id="publish-release.yml"
helper_git_ref="v$(xbb_get_current_helper_version)"

while [ $# -gt 0 ]
do
  case "$1" in

    --branch )
      branch="$2"
      shift 2
      ;;

    --version )
      version="$2"
      shift 2
      ;;

    --helper-git-ref )
      helper_git_ref="$2"
      shift 2
      ;;

    --* )
      echo "Unsupported option $1."
      exit 1
      ;;

  esac
done

data_file_path=$(mktemp)
rm -rf "${data_file_path}"

# Note: __EOF__ is NOT quoted to allow substitutions.
cat <<__EOF__ > "${data_file_path}"
{
  "ref": "${branch}",
  "inputs": {
    "version": "${version}",
    "helper-git-ref": "${helper_git_ref}"
  }
}
__EOF__

trigger_github_workflow \
  "${XBB_GITHUB_ORG}" \
  "${XBB_GITHUB_REPO}" \
  "${workflow_id}" \
  "${data_file_path}" \
  "${GITHUB_API_DISPATCH_TOKEN}"

echo
echo "Done."

# -----------------------------------------------------------------------------