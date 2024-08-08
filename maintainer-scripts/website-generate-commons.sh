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

# which liquidjs
# liquidjs --help

cd "${root_folder_path}"

# Use liquidjs to extract properties from package.json.
export appName="$(liquidjs --context @package.json --template '{{ xpack.properties.appName }}')"
export appLcName="$(liquidjs --context @package.json --template '{{ xpack.properties.appLcName }}')"
export platforms="$(liquidjs --context @package.json --template '{{ xpack.properties.platforms }}')"
export showDeprecatedGnuMcuAnalytics="$(liquidjs --context @package.json --template '{{ xpack.properties.showDeprecatedGnuMcuAnalytics }}')"
export showDeprecatedRiscvGccAnalytics="$(liquidjs --context @package.json --template '{{ xpack.properties.showDeprecatedRiscvGccAnalytics }}')"
export showTestsResults="$(liquidjs --context @package.json --template '{{ xpack.properties.showTestsResults }}')"

export context="{ \"appName\": \"${appName}\", \"appLcName\": \"${appLcName}\", \"platforms\": \"${platforms}\", \"branch\": \"${branch}\", \"showDeprecatedGnuMcuAnalytics\": \"${showDeprecatedGnuMcuAnalytics}\", \"showDeprecatedRiscvGccAnalytics\": \"${showDeprecatedRiscvGccAnalytics}\", \"showTestsResults\": \"${showTestsResults}\" }"

# tmp_context_file="$(mktemp) -t context"
# echo "{ \"appName\": \"${appName}\", \"appLcName\": \"${appLcName}\", \"platforms\": \"${platforms}\" }" > "${tmp_context_file}"

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
  liquidjs --context "${context}" --template "@$from" --output "$2/$to" --strict-variables --strict-filters

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
echo "Common files, overriden..."

find . -type f -print0 | sort -zn | \
  xargs -0 -I '{}' bash "${tmp_script_file}" --force '{}' "${project_folder_path}/website"

cd "${helper_folder_path}/templates/docusaurus/first-time"
# pwd

echo
echo "First time versions..."

find . -type f -print0 | sort -zn | \
  xargs -0 -I '{}' bash "${tmp_script_file}" '{}' "${project_folder_path}/website"

rm -f "${tmp_script_file}"

cd "${helper_folder_path}/templates/docusaurus/other"

# Regenerate top README.md.
if [ $(cat "${project_folder_path}/README.md" | wc -l | tr -d '[:blank:]') -lt 42 ]
then
  echo
  echo liquidjs --context "${context}" --template "@README-TOP-liquid.md" --output "${project_folder_path}/README.md"
  liquidjs --context "${context}" --template "@README-TOP-liquid.md" --output "${project_folder_path}/README.md" --strict-variables --strict-filters
else
  echo
  echo "Top README preserved."
fi

echo
echo "Done"

# -----------------------------------------------------------------------------
