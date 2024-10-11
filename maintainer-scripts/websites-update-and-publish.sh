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

repos_folder="$(dirname $(dirname "${script_folder_path}"))"

cd "${repos_folder}"

# find . -type d -name '.git' -print0 | sort -zn | \
#   xargs -0 -I '{}' bash "${commands_file}" '{}'

for f in "${repos_folder}"/*/.git
do
  (
    cd "${f}/.."

    if [ ! -d website ]
    then
      continue
    fi

    echo
    pwd

    set -x

    if grep '"xpack":' package.json
    then
      branch="xpack-development"
    else
      # xpack-dev-tools.github.io is not an xpack and has no xpack-development.
      gbranch="master"
    fi

    git checkout "${branch}"
    git add website
    git commit -m "website: updates" || true
    git push

    git checkout website
    git merge "${branch}"
    git push

    git checkout "${branch}"
  )
done

echo "${script_name} done"

# -----------------------------------------------------------------------------
