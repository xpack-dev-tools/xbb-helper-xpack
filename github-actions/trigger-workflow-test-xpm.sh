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
root_folder_path="$(dirname $(dirname $(dirname "${helper_folder_path}")))"
if [ "$(basename "${root_folder}")" == "build-assets" ]
then
  project_folder_path="$(dirname "${root_folder_path}")"
else
  project_folder_path="${root_folder_path}"
fi
scripts_folder_path="${root_folder_path}/scripts"

# -----------------------------------------------------------------------------

source "${scripts_folder_path}/application.sh"

# Helper functions
source "${helper_folder_path}/github-actions/common.sh"
source "${helper_folder_path}/build-scripts/xbb.sh"

# -----------------------------------------------------------------------------

# Script to trigger a set of native tests via GitHub Actions.
# The binaries are downloaded from the `--base-url` parameter.

# GITHUB_API_DISPATCH_TOKEN must be present in the environment.

message="Test ${XBB_APPLICATION_DESCRIPTION} with xpm install"

branch="xpack-development"
package_version="$(xbb_get_current_package_version)"
version="$(echo "${package_version}" | sed -e 's|[.][0-9][0-9]*$||')"
workflow_id="test-xpm.yml"
helper_git_ref="v$(xbb_get_current_helper_version)"

while [ $# -gt 0 ]
do
  case "$1" in

    --branch )
      branch="$2"
      shift 2
      ;;

    --package-version )
      # tags like "next" and "latest" also accepted.
      package_version="$2"
      if [[ "${package_version}" =~ .*[.][0-9][0-9]* ]]
      then
        version="$(echo "${package_version}" | sed -e 's|[.][0-9][0-9]*$||')"
      fi
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
      echo "Unsupported option $1 in ${FUNCNAME[0]}()"
      exit 1
      ;;

  esac
done

# -----------------------------------------------------------------------------

data_file_path=$(mktemp)
rm -rf "${data_file_path}"

# Note: __EOF__ is NOT quoted to allow substitutions.
cat <<__EOF__ > "${data_file_path}"
{
  "ref": "${branch}",
  "inputs": {
    "package-version": "${package_version}",
    "version": "${version}"
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
echo "Done"

# -----------------------------------------------------------------------------
