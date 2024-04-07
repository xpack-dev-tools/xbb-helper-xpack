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

tmp_file="$(mktemp)"
cat <<'__EOF__' >"${tmp_file}"
cd "$1/.."
pwd
# b="$(git name-rev --name-only HEAD)"
d="$(git status)"
if [[ "${d}" == *nothing\ to\ commit,\ working\ tree\ clean ]]
then
  p="$(git log @{push}..)"
  if [ "${p}" != "" ]
  then
    echo
    pwd
    echo "${p}"
    git status -v
  fi
else
  echo
  pwd
  git status -v
fi

__EOF__

cd "$(dirname $(dirname "${script_folder_path}"))"

find . -type d -name '.git' -exec bash  "${tmp_file}" {} \;
