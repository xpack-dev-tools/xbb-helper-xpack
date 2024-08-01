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
helper_folder="$(dirname "${script_folder_path}")"

# This is the folder where the build is started (build-assets).
root_folder="$(dirname $(dirname $(dirname $(dirname "${script_folder_path}"))))"
if [ "$(basename "${root_folder}")" == "build-assets" ]
then
  project_folder="$(dirname "${root_folder}")"
else
  project_folder="${root_folder}"
fi

xpack_www_releases="$(dirname $(dirname $(dirname "${project_folder}")))/xpack.github/www/web-jekyll-xpack.git/_posts/releases"

# which liquidjs
# liquidjs --help

cd "${root_folder}"

# Use liquidjs to extract properties from package.json.
export appName="$(liquidjs --context @package.json --template '{{ xpack.properties.appName }}')"
export appLcName="$(liquidjs --context @package.json --template '{{ xpack.properties.appLcName }}')"
export platforms="$(liquidjs --context @package.json --template '{{ xpack.properties.platforms }}')"

cd "${xpack_www_releases}/${appLcName}"
# pwd

echo
echo "Release posts..."

find . -type f -print0 | \
   xargs -0 -I '{}' bash "${script_folder_path}/website-convert-release-post.sh" '{}' "${project_folder}/website/blog"

echo
echo "Validating..."

if grep -r -e '{{' "${project_folder}/website/blog"/* || grep -r -e '{%' "${project_folder}/website/blog"/*
then
  exit 1
fi

echo
echo "Done"

# -----------------------------------------------------------------------------
