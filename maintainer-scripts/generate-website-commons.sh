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
helper_folder="$(dirname "${script_folder_path}")"

project_folder="$(dirname $(dirname $(dirname $(dirname "${script_folder_path}"))))"

# which liquidjs
# liquidjs --help

cd "${project_folder}"

# Use liquidjs to extract properties from package.json.
appName="$(liquidjs --context @package.json --template '{{ xpack.properties.appName }}')"
appLcName="$(liquidjs --context @package.json --template '{{ xpack.properties.appLcName }}')"
platforms="$(liquidjs --context @package.json --template '{{ xpack.properties.platforms }}')"

# tmp_context_file="$(mktemp) -t context"
# echo "{ \"appName\": \"${appName}\", \"appLcName\": \"${appLcName}\", \"platforms\": \"${platforms}\" }" > "${tmp_context_file}"

tmp_script_file="$(mktemp) -t script"
# Note: __EOF__ is quoted to prevent substitutions.
cat <<'__EOF__' >"${tmp_script_file}"

# echo $@

# set -x
from=$(echo "$1" | sed -e 's|^\.\/||')
to=$(echo "$from" | sed -e 's|-liquid||')
# echo $from

if [ "$(basename "$from")" == ".DS_Store" ]
then
  : # echo "ignored"
elif [[ "$(basename "$from")" =~ .*-liquid.* ]]
then
  mkdir -p "$(dirname $2/$to)"
__EOF__

# Note: __EOF__ is NOT quoted to allow substitutions.
cat <<__EOF__ >>"${tmp_script_file}"
  echo liquidjs "@\$from" -> "\$2/\$to"
   liquidjs --context '{ "appName": "${appName}", "appLcName": "${appLcName}", "platforms": "${platforms}" }' --template "@\$from" --output "\$2/\$to" --strict-variables --strict-filters
__EOF__

# Note: __EOF__ is quoted to prevent substitutions.
cat <<'__EOF__' >>"${tmp_script_file}"

else
  mkdir -p "$(dirname $2/$to)"
  cp -v "$from" "$2/$to"
fi

__EOF__

# cat ${tmp_script_file}
# exit 1
cd "${helper_folder}/templates/docusaurus/common"
# pwd

find . -type f -print0 | sort -zn | \
   xargs -0 -I '{}' bash "${tmp_script_file}" '{}' "${project_folder}/website"

rm -f "${tmp_script_file}"

echo

# -----------------------------------------------------------------------------
