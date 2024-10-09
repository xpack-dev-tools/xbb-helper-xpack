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

script_name="$(basename "${build_script_path}")"

script_folder_path="$(dirname "${build_script_path}")"
script_folder_name="$(basename "${script_folder_path}")"

# =============================================================================

# set -x
helper_folder_path="$(dirname "${script_folder_path}")"

# (build-assets/xpacks/@xpack-dev-tools/xbb-helper/maintainer-scripts/*.sh).

project_folder_path="$(dirname $(dirname $(dirname $(dirname $(dirname "${script_folder_path}")))))"

# This is the folder where the build is started
# (build-assets/xpacks/@xpack-dev-tools/xbb-helper/maintainer-scripts/*.sh).
build_assets_folder_path="${project_folder_path}/build-assets"

website_folder_path="${project_folder_path}/website"
website_blog_folder_path="${website_folder_path}/blog"

# -----------------------------------------------------------------------------

source "${build_assets_folder_path}/scripts/application.sh"

# Helper functions
source "${helper_folder_path}/github-actions/common.sh"
source "${helper_folder_path}/build-scripts/xbb.sh"
source "${helper_folder_path}/build-scripts/wrappers.sh"

# -----------------------------------------------------------------------------

echo
echo "Generating the ${XBB_APPLICATION_DESCRIPTION} blog release page..."

# -----------------------------------------------------------------------------

# set -x
xpack_binaries_folder_path="${HOME}/Downloads/xpack-binaries/${XBB_APPLICATION_LOWER_CASE_NAME}"

download_binaries "${xpack_binaries_folder_path}"

echo
ls -lL "${xpack_binaries_folder_path}"

echo
cat "${xpack_binaries_folder_path}"/*.sha

xpack_version=${XBB_RELEASE_VERSION:-"$(xbb_get_current_version)"}
release_date="$(date '+%Y-%m-%d %H:%M:%S %z')"
post_file_path="${website_blog_folder_path}/$(date -u '+%Y-%m-%d')-${XBB_APPLICATION_LOWER_CASE_NAME}-v$(echo ${xpack_version} | tr '.' '-')-released.mdx"
echo

rm -rf "${post_file_path}"
touch "${post_file_path}"

app_name="$(liquidjs --context @${build_assets_folder_path}/package.json --template '{{xpack.properties.appName}}')"
app_lc_name="$(liquidjs --context @${build_assets_folder_path}/package.json --template '{{xpack.properties.appLcName}}')"

platforms="$(liquidjs --context @${build_assets_folder_path}/package.json --template '{{xpack.properties.platforms}}')"

if [ "${platforms}" == "all" ]
then
  platforms="win32-x64,darwin-x64,darwin-arm64,linux-x64,linux-arm64,linux-arm"
fi

custom_fields="$(liquidjs --context "@${build_assets_folder_path}/package.json" --template '{{xpack.properties.customFields | json}}')"

if [ -z "${custom_fields}" ]
then
  custom_fields='{}'
fi

has_two_numbers_version="$(liquidjs --context "${custom_fields}" --template '{{hasTwoNumbersVersion}}')"

# Remove pre-release.
semver_version="$(echo ${xpack_version} | sed -e 's|-.*||')"

if [ "${has_two_numbers_version}" == "true" ] && [[ "${semver_version}" =~ .*[.]0*$ ]]
then
  # Remove the patch number, if zero.
  upstream_version="$(echo ${semver_version} | sed -e 's|[.]0*$||')"
else
  upstream_version="${semver_version}"
fi

context="{ \"appName\": \"${app_name}\", \"appLcName\": \"${app_lc_name}\", \"platforms\": \"${platforms}\", \"releaseVersion\": \"${xpack_version}\", \"releaseDate\": \"${release_date}\", \"upstreamVersion\": \"${upstream_version}\", \"customFields\": ${custom_fields} }"

liquidjs --context "${context}" --template "@${website_blog_folder_path}/templates/blog-post-release-part-1-liquid.mdx" >> "${post_file_path}"

echo >> "${post_file_path}"
echo '```txt'  >> "${post_file_path}"
cat "${xpack_binaries_folder_path}"/*.sha \
  | sed -e 's|$|\n|' \
  | sed -e 's|  |\n|' \
  >> "${post_file_path}"
echo '```'  >> "${post_file_path}"

liquidjs --context "${context}" --template "@${website_blog_folder_path}/templates/blog-post-release-part-2-liquid.mdx" >> "${post_file_path}"

echo "Don't forget to manually solve the TODO action point!"

echo
echo "${script_name} done"

# Completed successfully.
exit 0

# -----------------------------------------------------------------------------
