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

# set -x
helper_folder_path="$(dirname "${script_folder_path}")"

# This is the folder where the build is started (build-assets).
root_folder_path="$(dirname $(dirname $(dirname $(dirname "${script_folder_path}"))))"
if [ "$(basename "${root_folder_path}")" == "build-assets" ]
then
  project_folder_path="$(dirname "${root_folder_path}")"
  branch="xpack-development"
else
  project_folder_path="${root_folder_path}"
  branch="xpack-develop"
fi
scripts_folder_path="${root_folder_path}/scripts"

# -----------------------------------------------------------------------------

if [ -f "${scripts_folder_path}/application.sh" ]
then
  source "${scripts_folder_path}/application.sh"
fi

# Helper functions
source "${helper_folder_path}/github-actions/common.sh"
source "${helper_folder_path}/build-scripts/xbb.sh"
source "${helper_folder_path}/build-scripts/wrappers.sh"

# -----------------------------------------------------------------------------

# which liquidjs
# liquidjs --help

cd "${root_folder_path}"

# Use liquidjs to extract properties from package.json.
export app_name="$(liquidjs --context @package.json --template '{{xpack.properties.appName}}')"
export app_lc_name="$(liquidjs --context @package.json --template '{{xpack.properties.appLcName}}')"
platforms="$(liquidjs --context @package.json --template '{{xpack.properties.platforms}}')"

if [ -z "${platforms}" ]
then
  platforms="all"
fi

if [ "${platforms}" == "all" ]
then
  platforms="win32-x64,darwin-x64,darwin-arm64,linux-x64,linux-arm64,linux-arm"
fi

export platforms

custom_fields="$(liquidjs --context @package.json --template '{{xpack.properties.customFields | json}}')"

if [ -z "${custom_fields}" ]
then
  custom_fields='{}'
fi

export custom_fields

has_two_numbers_version="$(liquidjs --context "${custom_fields}" --template '{{hasTwoNumbersVersion}}')"
is_organization_web="$(liquidjs --context "${custom_fields}" --template '{{isOrganizationWeb}}')"

if [ "${is_organization_web}" == "true" ]
then
  xpack_version="0.0.0-0"
else
  xpack_version=${XBB_RELEASE_VERSION:-"$(xbb_get_current_version)"}
fi

# Remove pre-release.
semver_version="$(echo ${xpack_version} | sed -e 's|-.*||')"

if [ "${has_two_numbers_version}" == "true" ] && [[ "${semver_version}" =~ .*[.]0*$ ]]
then
  # Remove the patch number, if zero.
  upstream_version="$(echo ${semver_version} | sed -e 's|[.]0*$||')"
else
  upstream_version="${semver_version}"
fi

github_project_name="$(liquidjs --context @package.json --template '{{xpack.properties.customFields.gitHubProjectName}}')"

if [ -z "${github_project_name}" ]
then
  github_project_name="${app_lc_name}-xpack"
fi

export context="{ \"appName\": \"${app_name}\", \"appLcName\": \"${app_lc_name}\", \"platforms\": \"${platforms}\", \"branch\": \"${branch}\", \"upstreamVersion\": \"${upstream_version}\", \"gitHubProjectName\": \"${github_project_name}\", \"customFields\": ${custom_fields} }"

# tmp_context_file="$(mktemp) -t context"
# echo "{ \"appName\": \"${app_name}\", \"appLcName\": \"${app_lc_name}\", \"platforms\": \"${platforms}\" }" > "${tmp_context_file}"

tmp_script_file="$(mktemp) -t script"
# Note: __EOF__ is quoted to prevent substitutions.
cat <<'__EOF__' >"${tmp_script_file}"

# xargs stops only for exit code 255.
function trap_handler()
{
  local from_file="$1"
  shift
  local line_number="$1"
  shift
  local exit_code="$1"
  shift

  echo "FAIL ${from_file} line: ${line_number} exit: ${exit_code}"
  exit 255
}

# echo $@

do_force="n"
if [ "$1" == "--force" ]
then
  do_force="y"
  shift
fi

from=$(echo "$1" | sed -e 's|^\.\/||')
to=$(echo "$from" | sed -e 's|-liquid||')
# echo $from

trap 'trap_handler ${from} $LINENO $?; return 255' ERR

if [ -d "${from}" ] && [ "$(basename "${from}")" == "_common" ]
then
  if [ -d "$2/$to" ]
  then
    chmod -R +w "$2/$to"
    rm -rf "$2/$to"
    echo "rm $2/$to"
  fi
  exit 0
fi

if [ "${do_force}" != "y" ]
then
  if [ -f "$2/$to" ]
  then
    echo "$2/$to already present"
    exit 0
  fi

  if [ -d "$2/$to" ]
  then
    echo "$2/$to is a folder!"
    exit 1
  fi
  # set -x
fi

if [ -f "$2/$to" ]
then
  chmod +w "$2/$to"
fi

if [ "$(basename "$from")" == ".DS_Store" ]
then
  : # echo "ignored"
elif [[ "$(basename "$from")" =~ .*-liquid.* ]]
then
  mkdir -p "$(dirname $2/$to)"

  echo liquidjs "@$from" '->' "$2/$to"
  # --strict-variables
  liquidjs --context "${context}" --template "@$from" --output "$2/$to"  --strict-filters

  if [ "${do_force}" == "y" ]
  then
    chmod -w "$2/$to"
  fi
else
  mkdir -p "$(dirname $2/$to)"

  cp -v "$from" "$2/$to"

  if [ "${do_force}" == "y" ]
  then
    chmod -w "$2/$to"
  fi
fi

__EOF__

# cat ${tmp_script_file}
# exit 1

cd "${helper_folder_path}/templates/docusaurus/common"
# pwd

echo
echo "Common files, cleanups..."

# Preliminary pass to remove _common folders.
find . -type d -name '_common' -print0 | sort -zn | \
  xargs -0 -I '{}' bash "${tmp_script_file}" --force '{}' "${project_folder_path}/website"

echo
echo "context=${context}"

echo
echo "Common files, overriden..."

# Main pass to copy/generate common
find . -type f -print0 | sort -zn | \
  xargs -0 -I '{}' bash "${tmp_script_file}" --force '{}' "${project_folder_path}/website"

cd "${helper_folder_path}/templates/docusaurus/first-time"
# pwd

echo
echo "First time proposals..."

find . -type f -print0 | sort -zn | \
  xargs -0 -I '{}' bash "${tmp_script_file}" '{}' "${project_folder_path}/website"

rm -f "${tmp_script_file}"

cd "${helper_folder_path}/templates/docusaurus/other"

if [ ${is_organization_web} == "true" ]
then
  echo
  echo "Remove unused files..."

  (
    cd "${project_folder_path}/website"

    rm -rf "docs/developer"
    rm -rf "docs/faq"
    rm -rf "docs/install"
    rm -rf "docs/maintainer"
    rm -rf "docs/releases"
    rm -rf "docs/support"
    rm -rf "docs/test"
    rm -rf "docs/user"
  )
else
  # Regenerate top README.md.
  if [ $(cat "${project_folder_path}/README.md" | wc -l | tr -d '[:blank:]') -ge 42 ]
  then
    mv "${project_folder_path}/README.md" "${root_folder_path}/README-long.md"
  fi
  echo
  echo liquidjs "@README-TOP-liquid.md" '->' "${project_folder_path}/README.md"
  liquidjs --context "${context}" --template "@README-TOP-liquid.md" --output "${project_folder_path}/README.md" --strict-variables --strict-filters
fi

echo
echo "Done"

# -----------------------------------------------------------------------------
