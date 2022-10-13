#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
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
project_folder_path="$(dirname $(dirname "${helper_folder_path}"))"
scripts_folder_path="${project_folder_path}/scripts"

# -----------------------------------------------------------------------------

source "${scripts_folder_path}/definitions.sh"

# Helper functions
source "${helper_folder_path}/github-actions/common.sh"
source "${helper_folder_path}/scripts/xbb.sh"
source "${helper_folder_path}/scripts/wrappers.sh"

# -----------------------------------------------------------------------------

# Script to generate the Jekyll post markdown page.

# -----------------------------------------------------------------------------

echo
echo "Download the ${APP_DESCRIPTION} binaries..."

# -----------------------------------------------------------------------------

version=${RELEASE_VERSION:-"$(xbb_get_current_version)"}

rm -rf ~/Downloads/xpack-binaries/${APP_LC_NAME}-bak
mv ~/Downloads/xpack-binaries/${APP_LC_NAME} ~/Downloads/xpack-binaries/${APP_LC_NAME}-bak

mkdir -p ~/Downloads/xpack-binaries/${APP_LC_NAME}
cd ~/Downloads/xpack-binaries/${APP_LC_NAME}

package_file_path="${1:-"${project_folder_path}/package.json"}"

# Extract the xpack.properties platforms. There are also in xpack.binaries.
platforms=$(grep '"platforms": "' "${package_file_path}" | sed -e 's|.*: \"\([a-z0-9]*\)\",.*|\1|' | sed 's|,| |g')
if [ "${platforms}" == "all" ]
then
  platforms='linux-x64 linux-arm64 linux-arm darwin-x64 darwin-arm64 win32-x64'
fi

IFS=' '
for platform in ${platforms}
do
  echo ${platform}
  # https://github.com/xpack-dev-tools/pre-releases/releases/download/test/xpack-ninja-build-1.11.1-2-win32-x64.zip
  extension='tar.gz'
  if [ "${platform}" == "win32-x64" ]
  then
    extension='zip'
  fi

  archive_name="${APP_DISTRO_LC_NAME}-${APP_LC_NAME}-${version}-${platform}.${extension}"
  run_verbose curl --location --insecure --fail --location \
    --output "${archive_name}" \
   "https://github.com/xpack-dev-tools/pre-releases/releases/download/test/${archive_name}"
  run_verbose curl --location --insecure --fail --location \
    --output "${archive_name}.sha" \
   "https://github.com/xpack-dev-tools/pre-releases/releases/download/test/${archive_name}.sha"

done

echo
ls -lL

rm -rf ~/Downloads/xpack-binaries/${APP_LC_NAME}-bak

echo
echo "Done."

# Completed successfully.
exit 0

# -----------------------------------------------------------------------------
