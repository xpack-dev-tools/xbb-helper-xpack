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

# find . -type d -name '.git' -depth 2 -print0 | sort -zn | \
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
      git checkout xpack-development

      xpm run website-generate-commons -C build-assets
      xpm run website-import-releases -C build-assets
    else
      # xpack-dev-tools.github.io is not an xpack and has no xpack-development.
      git checkout master

      xpm run website-generate-commons -C build-assets
    fi

    (
      cd website

      echo
      pwd

      rm -f package-lock.json
      rm -rf .docusaurus build

      npm install
      npm run build
    )
  )
done

echo "${script_name} done"

# -----------------------------------------------------------------------------
