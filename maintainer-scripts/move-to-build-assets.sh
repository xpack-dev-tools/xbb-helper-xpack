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

echo
echo $1


if false
then

  # Skip if already processed.
  if [ -d build-assets ]
  then
    exit 0
  fi

  # Skip if not a binary xPack.
  if [ ! -d scripts ]
  then
    exit 0
  fi

  git checkout -b xpack-development

  mkdir build-assets
  mv build extras node_modules patches scripts wrappers xpacks README-*.md build-assets

  mv README.md README-LONG.md
  touch README.md

  cp package.json build-assets
  rm package-lock.json

  xpm run generate-workflows -C build-assets

  xpm run website-generate-commons -C build-assets
  xpm run website-import-releases -C build-assets

elif false
then

  # Skip if build-assets not created.
  if [ ! -d build-assets ]
  then
    exit 0
  fi

  cd build-assets

  # bring templates up one level
  mv scripts/templates .

  cd templates
  mv body-jekyll-release-post-part-1-liquid.md body-blog-release-post-part-1-liquid.md
  mv body-jekyll-release-post-part-2-liquid.md body-blog-release-post-part-2-liquid.md

elif false
then

  # Skip if build-assets not created.
  if [ ! -d build-assets ]
  then
    exit 0
  fi

  git add build-assets scripts README-*.md package*.json
  if [ -d extras ]
  then
    git add extras
  fi
  if [ -d patches ]
  then
  git add patches
  fi
  if [ -d wrappers ]
  then
  git add wrappers
  fi

elif false
then

  # Skip if build-assets not created.
  if [ ! -d build-assets ]
  then
    exit 0
  fi

  git add .github .gitignore .npmignore
  git commit -m "re-generate workflows"

elif false
then

  # Skip if build-assets not created.
  if [ ! -d build-assets ]
  then
    exit 0
  fi

  git add website
  git commit -m "website: preliminary content"

elif true
then

  # Skip if build-assets not created.
  if [ ! -d build-assets ]
  then
    exit 0
  fi

  git checkout xpack
  git merge xpack-development
  git push
  git checkout xpack-development

fi

__EOF__

# -----------------------------------------------------------------------------

set -x

commands_file="${tmp_file}"

repos_folder="$(dirname $(dirname "${script_folder_path}"))"

cd "${repos_folder}"

find . -type d -name '.git' -print0 | sort -zn | \
  xargs -0 -I '{}' bash "${commands_file}" '{}'

echo

# -----------------------------------------------------------------------------
