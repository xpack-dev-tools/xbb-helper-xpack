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
helper_folder_path="$(dirname "${script_folder_path}")"

# This is the folder where the build is started (build-assets).
root_folder_path="$(dirname $(dirname $(dirname $(dirname "${script_folder_path}"))))"
if [ "$(basename "${root_folder_path}")" == "build-assets" ]
then
  project_folder_path="$(dirname "${root_folder_path}")"
  prefix="build-assets"
  branch="xpack-development"
else
  project_folder_path="${root_folder_path}"
  prefix="."
  branch="xpack-develop"
fi

# which liquidjs
# liquidjs --help

cd "${root_folder_path}"

# Use liquidjs to extract properties from package.json.
export appName="$(liquidjs --context @package.json --template '{{ xpack.properties.appName }}')"
export appLcName="$(liquidjs --context @package.json --template '{{ xpack.properties.appLcName }}')"

# "all" is equivalent with "linux-x64,linux-arm64,linux-arm,darwin-x64,darwin-arm64,win32-x64"
export platforms="$(liquidjs --context @package.json --template '{{ xpack.properties.platforms }}')"

platforms_with_commas=",${platforms},"
if [ "${platforms_with_commas}" == ",all," ]
then
  platforms_with_commas=",linux-x64,linux-arm64,linux-arm,darwin-x64,darwin-arm64,win32-x64,"
fi

export context="{ \"XBB_APPLICATION_NAME\": \"${appName}\", \"XBB_APPLICATION_LOWER_CASE_NAME\": \"${appLcName}\", \"platforms\": \"${platforms}\", \"prefix\": \"${prefix}\", \"branch\": \"${branch}\" }"

# The template files include
# "xpacks/@xpack-dev-tools/xbb-helper/templates/workflows/copyright-liquid.yml"

cd "${root_folder_path}"

mkdir -pv ${project_folder_path}/.github/workflows/

echo
echo "Workflows..."
cp -v ${helper_folder_path}/templates/body-github-pre-releases-test.md ${project_folder_path}/.github/workflows/

if [[ "${platforms_with_commas}" =~ ,darwin-x64, ]]
then
  run_verbose liquidjs --context "${context}" --template @${helper_folder_path}/templates/workflows/build-darwin-x64-liquid.yml --output ${project_folder_path}/.github/workflows/build-darwin-x64.yml
fi

if [[ "${platforms_with_commas}" =~ ,darwin-arm64, ]]
then
  run_verbose liquidjs --context "${context}" --template @${helper_folder_path}/templates/workflows/build-darwin-arm64-liquid.yml --output ${project_folder_path}/.github/workflows/build-darwin-arm64.yml
fi

if [[ "${platforms_with_commas}" =~ ,linux-x64, ]]
then
  run_verbose liquidjs --context "${context}" --template @${helper_folder_path}/templates/workflows/build-linux-x64-liquid.yml --output ${project_folder_path}/.github/workflows/build-linux-x64.yml
fi

if [[ "${platforms_with_commas}" =~ ,win32-x64, ]]
then
  run_verbose liquidjs --context "${context}" --template @${helper_folder_path}/templates/workflows/build-win32-x64-liquid.yml --output ${project_folder_path}/.github/workflows/build-win32-x64.yml
fi

if [[ "${platforms_with_commas}" =~ ,linux-arm, ]]
then
  run_verbose liquidjs --context "${context}" --template @${helper_folder_path}/templates/workflows/build-linux-arm-liquid.yml --output ${project_folder_path}/.github/workflows/build-linux-arm.yml
fi

if [[ "${platforms_with_commas}" =~ ,linux-arm64, ]]
then
  run_verbose liquidjs --context "${context}" --template @${helper_folder_path}/templates/workflows/build-linux-arm64-liquid.yml --output ${project_folder_path}/.github/workflows/build-linux-arm64.yml
fi

run_verbose liquidjs --context "${context}" --template @${helper_folder_path}/templates/workflows/test-prime-liquid.yml --output ${project_folder_path}/.github/workflows/test-prime.yml

if [[ "${platforms_with_commas}" =~ ,linux-x64, ]]
then
  run_verbose liquidjs --context "${context}" --template @${helper_folder_path}/templates/workflows/test-docker-linux-intel-liquid.yml --output ${project_folder_path}/.github/workflows/test-docker-linux-intel.yml
fi

if [[ "${platforms_with_commas}" =~ ,linux-arm64, ]] || [[ "${platforms_with_commas}" =~ ,linux-arm, ]]
then
 run_verbose liquidjs --context "${context}" --template @${helper_folder_path}/templates/workflows/test-docker-linux-arm-liquid.yml --output ${project_folder_path}/.github/workflows/test-docker-linux-arm.yml
fi

run_verbose liquidjs --context "${context}" --template @${helper_folder_path}/templates/workflows/publish-release-liquid.yml --output ${project_folder_path}/.github/workflows/publish-release.yml
run_verbose liquidjs --context "${context}" --template @${helper_folder_path}/templates/workflows/test-xpm-liquid.yml --output ${project_folder_path}/.github/workflows/test-xpm.yml
run_verbose liquidjs --context "${context}" --template @${helper_folder_path}/templates/workflows/deep-clean-liquid.yml --output ${project_folder_path}/.github/workflows/deep-clean.yml

echo
cp -v ${helper_folder_path}/templates/workflows/publish-github-pages.yml ${project_folder_path}/.github/workflows/publish-github-pages.yml

echo
echo "dot files..."
cp -v ${helper_folder_path}/templates/dot.gitignore ${project_folder_path}/.gitignore
cp -v ${helper_folder_path}/templates/dot.npmignore ${project_folder_path}/.npmignore

echo
echo "Scripts..."
cp -v ${helper_folder_path}/templates/build.sh ${root_folder_path}/scripts/
cp -v ${helper_folder_path}/templates/test.sh ${root_folder_path}/scripts/

echo
echo "Done"

# -----------------------------------------------------------------------------
