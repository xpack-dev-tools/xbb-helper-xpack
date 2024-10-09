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

function move_template_blog()
{
  (
    if [ ! -d "$(dirname "$1")/build-assets/templates" ]
    then
      return
    fi

    if [ ! -f "$1/blog/_templates/blog-post-release-part-1-liquid.mdx" ] &&
       [ -f "$(dirname "$1")/build-assets/templates/body-blog-release-post-part-1-liquid.mdx" ]
    then
      mkdir -pv "$1/blog/_templates"
      mv -v "$(dirname "$1")/build-assets/templates/body-blog-release-post-part-1-liquid.mdx" \
        "$1/blog/_templates/blog-post-release-part-1-liquid.mdx"
    fi

    if [ ! -f "$1/blog/_templates/blog-post-release-part-2-liquid.mdx" ] &&
       [ "$(dirname "$1")/build-assets/templates/body-blog-release-post-part-2-liquid.mdx" ]
    then
      mkdir -pv "$1/blog/_templates"
      mv -v "$(dirname "$1")/build-assets/templates/body-blog-release-post-part-2-liquid.mdx" \
        "$1/blog/_templates/blog-post-release-part-2-liquid.mdx"
    fi
  )
}

# =============================================================================

# set -x

repos_folder="$(dirname $(dirname "${script_folder_path}"))"

cd "${repos_folder}"

for f in "${repos_folder}"/*/website
do
  echo
  echo ${f}

  move_template_blog ${f}

done

echo "${script_name} done"

# -----------------------------------------------------------------------------
