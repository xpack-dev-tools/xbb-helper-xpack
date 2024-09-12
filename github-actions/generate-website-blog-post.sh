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
  website_blog_path="${project_folder_path}/website/blog"
else
  project_folder_path="${root_folder_path}"
  website_blog_path="${HOME}/Desktop"
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
echo "Generating the ${XBB_APPLICATION_DESCRIPTION} blog release page..."

# -----------------------------------------------------------------------------

# set -x
destination_folder_path="${HOME}/Downloads/xpack-binaries/${XBB_APPLICATION_LOWER_CASE_NAME}"

download_binaries "${destination_folder_path}"

echo
ls -lL "${destination_folder_path}"

echo
cat "${destination_folder_path}"/*.sha

release_version=${XBB_RELEASE_VERSION:-"$(xbb_get_current_version)"}
release_date="$(date '+%Y-%m-%d %H:%M:%S %z')"
post_file_path="${website_blog_path}/$(date -u '+%Y-%m-%d')-${XBB_APPLICATION_LOWER_CASE_NAME}-v$(echo ${release_version} | tr '.' '-')-released.mdx"
echo

rm -rf "${post_file_path}"
touch "${post_file_path}"

customFields="$(liquidjs --context "@${root_folder_path}/package.json" --template '{{xpack.properties.customFields | json}}')"
if [ -z "${customFields}" ]
then
  customFields='{}'
fi

upstreamVersion="$(echo ${release_version} | sed -e 's|-.*||')"

appLcName="$(liquidjs --context "@${root_folder_path}/package.json" --template '{{xpack.properties.appLcName}}')"

if [ "${appLcName}" == "wine" ]
then
  upstreamVersion="$(echo ${upstreamVersion} | sed -e 's|[.]0[.]0$]|.0|')"
fi

context="{ \"releaseVersion\": \"${release_version}\", \"releaseDate\": \"${release_date}\", \"upstreamVersion\": \"${upstreamVersion}\", \"customFields\": ${customFields} }"

liquidjs --context "${context}" --template "@${root_folder_path}/templates/body-blog-release-post-part-1-liquid.mdx" >> "${post_file_path}"

echo >> "${post_file_path}"
echo '```txt'  >> "${post_file_path}"
cat "${destination_folder_path}"/*.sha \
  | sed -e 's|$|\n|' \
  | sed -e 's|  |\n|' \
  >> "${post_file_path}"
echo '```'  >> "${post_file_path}"

liquidjs --context "${context}" --template "@${root_folder_path}/templates/body-blog-release-post-part-2-liquid.mdx" >> "${post_file_path}"

echo "Don't forget to manually solve the TODO action point!"

echo
echo "Done"

# Completed successfully.
exit 0

# -----------------------------------------------------------------------------
