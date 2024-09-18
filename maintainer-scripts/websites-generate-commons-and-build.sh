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

tmp_file_commit_website="$(mktemp)"
cat <<'__EOF__' >"${tmp_file_commit_website}"
cd "$1/.."

if [ ! -d website ]
then
  exit 0
fi

echo
echo $1

set -x

git checkout xpack-development

xpm run website-generate-commons -C build-assets
xpm run website-import-releases -C build-assets

(cd website && npm install && npm run build)

__EOF__

# -----------------------------------------------------------------------------

# set -x

commands_file="${tmp_file_commit_website}"

repos_folder="$(dirname $(dirname "${script_folder_path}"))"

cd "${repos_folder}"

find . -type d -name '.git' -print0 | sort -zn | \
  xargs -0 -I '{}' bash "${commands_file}" '{}'

echo

# -----------------------------------------------------------------------------
