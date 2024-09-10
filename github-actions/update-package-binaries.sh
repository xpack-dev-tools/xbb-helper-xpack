#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu. All rights reserved.
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

build_script_path="$0"
if [[ "${build_script_path}" != /* ]]
then
  # Make relative path absolute.
  build_script_path="$(pwd)/$0"
fi

script_folder_path="$(dirname "${build_script_path}")"
script_folder_name="$(basename "${script_folder_path}")"

# =============================================================================

helper_folder_path="$(dirname ${script_folder_path})"
root_folder_path="$(dirname $(dirname $(dirname "${helper_folder_path}")))"
if [ "$(basename "${root_folder_path}")" == "build-assets" ]
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
source "${helper_folder_path}/build-scripts/wrappers.sh"

# -----------------------------------------------------------------------------

# Script to generate the Jekyll post markdown page.

# -----------------------------------------------------------------------------

echo
echo "Update the ${XBB_APPLICATION_DESCRIPTION} package.json binaries..."

# -----------------------------------------------------------------------------

version=${XBB_RELEASE_VERSION:-"$(xbb_get_current_version)"}

run_verbose xpm-dev binaries-update \
  -C "${HOME}/Work/xpack-dev-tools/${XBB_APPLICATION_LOWER_CASE_NAME}-xpack.git" \
  "${version}" \
  "${HOME}/Downloads/xpack-binaries/${XBB_APPLICATION_LOWER_CASE_NAME}"

echo
echo "Done"

# Completed successfully.
exit 0

# -----------------------------------------------------------------------------
