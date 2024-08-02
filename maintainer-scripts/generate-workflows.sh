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

function run_verbose()
{
  local app_path="$1"
  shift

  echo
  echo "[${app_path} $@]"
  "${app_path}" "$@" 2>&1
}

# -----------------------------------------------------------------------------

# set -x
helper_folder="$(dirname "${script_folder_path}")"

# This is the folder where the build is started (build-assets).
root_folder="$(dirname $(dirname $(dirname $(dirname "${script_folder_path}"))))"
if [ "$(basename "${root_folder}")" == "build-assets" ]
then
  project_folder="$(dirname "${root_folder}")"
  prefix="build-assets"
  branch="xpack-development"
else
  project_folder="${root_folder}"
  prefix="."
  branch="xpack-develop"
fi

# which liquidjs
# liquidjs --help

cd "${root_folder}"

# Use liquidjs to extract properties from package.json.
export appName="$(liquidjs --context @package.json --template '{{ xpack.properties.appName }}')"
export appLcName="$(liquidjs --context @package.json --template '{{ xpack.properties.appLcName }}')"
export platforms="$(liquidjs --context @package.json --template '{{ xpack.properties.platforms }}')"

export context="{ \"XBB_APPLICATION_NAME\": \"${appName}\", \"XBB_APPLICATION_LOWER_CASE_NAME\": \"${appLcName}\", \"platforms\": \"${platforms}\", \"prefix\": \"${prefix}\", \"branch\": \"${branch}\" }"

# The template files include
# "xpacks/@xpack-dev-tools/xbb-helper/templates/workflows/copyright-liquid.yml"

cd "${root_folder}"

mkdir -pv ${project_folder}/.github/workflows/

echo
echo "Workflows..."
cp -v ${helper_folder}/templates/body-github-pre-releases-test.md ${project_folder}/.github/workflows/

run_verbose liquidjs --context "${context}" --template @${helper_folder}/templates/workflows/build-darwin-x64-liquid.yml --output ${project_folder}/.github/workflows/build-darwin-x64.yml
run_verbose liquidjs --context "${context}" --template @${helper_folder}/templates/workflows/build-darwin-arm64-liquid.yml --output ${project_folder}/.github/workflows/build-darwin-arm64.yml
run_verbose liquidjs --context "${context}" --template @${helper_folder}/templates/workflows/build-linux-x64-liquid.yml --output ${project_folder}/.github/workflows/build-linux-x64.yml
run_verbose liquidjs --context "${context}" --template @${helper_folder}/templates/workflows/build-win32-x64-liquid.yml --output ${project_folder}/.github/workflows/build-win32-x64.yml
run_verbose liquidjs --context "${context}" --template @${helper_folder}/templates/workflows/build-linux-arm-liquid.yml --output ${project_folder}/.github/workflows/build-linux-arm.yml
run_verbose liquidjs --context "${context}" --template @${helper_folder}/templates/workflows/build-linux-arm64-liquid.yml --output ${project_folder}/.github/workflows/build-linux-arm64.yml
run_verbose liquidjs --context "${context}" --template @${helper_folder}/templates/workflows/test-prime-liquid.yml --output ${project_folder}/.github/workflows/test-prime.yml
run_verbose liquidjs --context "${context}" --template @${helper_folder}/templates/workflows/test-docker-linux-intel-liquid.yml --output ${project_folder}/.github/workflows/test-docker-linux-intel.yml
run_verbose liquidjs --context "${context}" --template @${helper_folder}/templates/workflows/test-docker-linux-arm-liquid.yml --output ${project_folder}/.github/workflows/test-docker-linux-arm.yml
run_verbose liquidjs --context "${context}" --template @${helper_folder}/templates/workflows/publish-release-liquid.yml --output ${project_folder}/.github/workflows/publish-release.yml
run_verbose liquidjs --context "${context}" --template @${helper_folder}/templates/workflows/test-xpm-liquid.yml --output ${project_folder}/.github/workflows/test-xpm.yml
run_verbose liquidjs --context "${context}" --template @${helper_folder}/templates/workflows/deep-clean-liquid.yml --output ${project_folder}/.github/workflows/deep-clean.yml

echo
cp -v ${helper_folder}/templates/workflows/publish-github-pages.yml ${project_folder}/.github/workflows/publish-github-pages.yml

echo
echo "dot files..."
cp -v ${helper_folder}/templates/dot.gitignore ${project_folder}/.gitignore
cp -v ${helper_folder}/templates/dot.npmignore ${project_folder}/.npmignore

echo
echo "Scripts..."
cp -v ${helper_folder}/templates/build.sh ${root_folder}/scripts/
cp -v ${helper_folder}/templates/test.sh ${root_folder}/scripts/

echo
echo "Done"

# -----------------------------------------------------------------------------
