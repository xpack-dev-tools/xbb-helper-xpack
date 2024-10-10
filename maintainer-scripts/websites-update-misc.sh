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

function rename_folders_hierarchies()
{
  (
    if [ -f "$1/docs/install/_folder-hierarchies.mdx" ]
    then
      mv -v "$1/docs/install/_folder-hierarchies.mdx" "$1/docs/install/_folders-hierarchies.mdx"
    fi
  )
}

function split_folders_hierarchies()
{
  (
    if [ -f "$1/docs/install/_folders-hierarchies.mdx" ] &&
       [ ! -f "$1/docs/install/_folders-hierarchies-linux.mdx" ]
    then
      cp -v "$1/docs/install/_folders-hierarchies.mdx" "$1/docs/install/_folders-hierarchies-linux.mdx"
    fi

    if [ -f "$1/docs/install/_folders-hierarchies.mdx" ] &&
       [ ! -f "$1/docs/install/_folders-hierarchies-macos.mdx" ]
    then
      cp -v "$1/docs/install/_folders-hierarchies.mdx" "$1/docs/install/_folders-hierarchies-macos.mdx"
    fi

    if [ -f "$1/docs/install/_folders-hierarchies.mdx" ] &&
       [ ! -f "$1/docs/install/_folders-hierarchies-windows.mdx" ]
    then
      mv -v "$1/docs/install/_folders-hierarchies.mdx" "$1/docs/install/_folders-hierarchies-windows.mdx"
    fi

    set -x
    if [ -f "$1/docs/install/_folders-hierarchies-linux.mdx" ]
    then
      sed -i.bak -e '/^## Folders hierarchy$/,/^\<TabItem value="linux" label="GNU\/Linux"\>$/d' "$1/docs/install/_folders-hierarchies-linux.mdx"
      sed -i.bak -e '/^\<\/TabItem\>$/,$d' "$1/docs/install/_folders-hierarchies-linux.mdx"
    fi

    if [ -f "$1/docs/install/_folders-hierarchies-macos.mdx" ]
    then
      sed -i.bak -e '/^## Folders hierarchy$/,/^\<TabItem value="macos" label="macOS"\>$/d' "$1/docs/install/_folders-hierarchies-macos.mdx"
      sed -i.bak -e '/^\<\/TabItem\>$/,$d' "$1/docs/install/_folders-hierarchies-macos.mdx"
    fi

    if [ -f "$1/docs/install/_folders-hierarchies-windows.mdx" ]
    then
      sed -i.bak -e '/^## Folders hierarchy$/,/^\<TabItem value="windows" label="Windows" default\>$/d' "$1/docs/install/_folders-hierarchies-windows.mdx"
      sed -i.bak -e '/^\<\/TabItem\>$/,$d' "$1/docs/install/_folders-hierarchies-windows.mdx"
    fi

    rm -f "$1/docs/install/_folders-hierarchies"-*.mdx.bak
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

  # move_template_blog ${f}
  # rename_folders_hierarchies ${f}
  split_folders_hierarchies ${f}

done

echo "${script_name} done"

# -----------------------------------------------------------------------------
