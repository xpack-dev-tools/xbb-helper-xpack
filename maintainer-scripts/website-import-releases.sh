#!/usr/bin/env bash

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

doForce="n"
doForce="y"
export doForce

# set -x
helper_folder_path="$(dirname "${script_folder_path}")"

# This is the folder where the build is started (build-assets).
root_folder_path="$(dirname $(dirname $(dirname $(dirname "${script_folder_path}"))))"
if [ "$(basename "${root_folder_path}")" == "build-assets" ]
then
  project_folder_path="$(dirname "${root_folder_path}")"
else
  project_folder_path="${root_folder_path}"
fi

xpack_www_releases="$(dirname $(dirname $(dirname "${project_folder_path}")))/xpack.github/www/web-jekyll-xpack.git/_posts/releases"

# which liquidjs
# liquidjs --help

cd "${root_folder_path}"

# Use liquidjs to extract properties from package.json.
export app_name="$(liquidjs --context @package.json --template '{{xpack.properties.appName}}')"
export app_lc_name="$(liquidjs --context @package.json --template '{{xpack.properties.appLcName}}')"
export platforms="$(liquidjs --context @package.json --template '{{xpack.properties.platforms}}')"

if [ ! -d "${xpack_www_releases}/${app_lc_name}" ]
then
  echo "No ${xpack_www_releases}/${app_lc_name}, quiting..."
  exit 0
fi

cd "${xpack_www_releases}/${app_lc_name}"
# pwd

# echo
# echo "platforms=${platforms}"

echo
echo "Release posts..."

find . -type f -print0 | \
   xargs -0 -I '{}' bash "${script_folder_path}/website-convert-release-post.sh" '{}' "${project_folder_path}/website/blog"

echo
echo "Validating..."

if grep -r -e '{{' "${project_folder_path}/website/blog"/* | grep -v '/website/blog/_' || \
   grep -r -e '{%' "${project_folder_path}/website/blog"/* | grep -v '/website/blog/_'
then
  exit 1
fi

echo
echo "${script_name} done"

# -----------------------------------------------------------------------------
