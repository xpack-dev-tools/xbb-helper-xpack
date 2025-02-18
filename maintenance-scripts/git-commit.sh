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

tmp_file_template_github="$(mktemp)"
cat <<'__EOF__' >"${tmp_file_template_github}"
cd "$1"

if [ ! -d build-assets ]
then
  exit 0
fi

cd build-assets

echo
echo $1
git add templates/body-github*.md*
git commit -m "templates/body-github: update" || true

__EOF__

# -----------------------------------------------------------------------------

tmp_file_blog="$(mktemp)"
cat <<'__EOF__' >"${tmp_file_blog}"
cd "$1"

echo
echo $1
git add website/blog/*.md*
# git add templates

git commit -m "website/blog updates" || true

__EOF__

# -----------------------------------------------------------------------------

tmp_file_website_xpack="$(mktemp)"
cat <<'__EOF__' >"${tmp_file_website_xpack}"
cd "$1"

echo
echo $1
git add website/_xpack.github.io

git commit -m "website: add _xpack.github.io" || true

__EOF__


# -----------------------------------------------------------------------------

tmp_file_template_blog="$(mktemp)"
cat <<'__EOF__' >"${tmp_file_template_blog}"
cd "$1"

if [ ! -d website/blog/_templates ]
then
  exit 0
fi

# cd website/blog/_templates

echo
echo $1
git add website/blog/_templates/blog-post-release-part-*-liquid.mdx
# git add templates

git commit -m "website/blog/_templates/blog-post-release*" || true

__EOF__

# -----------------------------------------------------------------------------

tmp_file_versioning="$(mktemp)"
cat <<'__EOF__' >"${tmp_file_versioning}"
cd "$1"

echo
echo $1
git add scripts/versioning.sh
git commit -m "versioning.sh: update for https" || true

__EOF__

# -----------------------------------------------------------------------------

tmp_file_application="$(mktemp)"
cat <<'__EOF__' >"${tmp_file_application}"
cd "$1"

echo
echo $1
git add scripts/application.sh
git commit -m "application.sh: update" || true

__EOF__

# -----------------------------------------------------------------------------

tmp_file_commit_all="$(mktemp)"
cat <<'__EOF__' >"${tmp_file_commit_all}"
cd "$1"

echo
echo $1
git add -A
git commit -m "Update min CMake 3.19" || true

__EOF__

# -----------------------------------------------------------------------------

tmp_file_workflows="$(mktemp)"
cat <<'__EOF__' >"${tmp_file_workflows}"
cd "$1"

echo
echo $1
git add .github/workflows
git commit -m "re-generate workflows" || true

__EOF__

# -----------------------------------------------------------------------------

tmp_file_scripts="$(mktemp)"
cat <<'__EOF__' >"${tmp_file_scripts}"
cd "$1"

cd build-assets

echo
echo $1
git add scripts
# git commit -m "scripts cosmetics" || true
# git commit -m "re-generate scripts" || true
git commit -m "update scripts copyright notices" || true

__EOF__

# -----------------------------------------------------------------------------

tmp_file_vscode="$(mktemp)"
cat <<'__EOF__' >"${tmp_file_vscode}"
cd "$1"

echo
echo $1
git add .vscode/settings.json
git commit -m ".vscode/settings.json ignoreWords" || true

__EOF__

# -----------------------------------------------------------------------------

tmp_file_npmignore="$(mktemp)"
cat <<'__EOF__' >"${tmp_file_npmignore}"
cd "$1"

echo
echo $1
git add .npmignore
git commit -m ".npmignore update" || true

__EOF__

# -----------------------------------------------------------------------------

tmp_file_website="$(mktemp)"
cat <<'__EOF__' >"${tmp_file_website}"
cd "$1"

if [ ! -d website ]
then
  exit 0
fi

echo
echo $1
git add website
# git add build-assets
git commit -m "website update" || true
# git commit -m "website remove preliminary" || true
# git commit -m "website move blog post templates" || true

__EOF__

# -----------------------------------------------------------------------------

tmp_file_commit_readmes="$(mktemp)"
cat <<'__EOF__' >"${tmp_file_commit_readmes}"
cd "$1"

echo
echo $1
# git add README-RELEASE.md
# git add README-MAINTAINER.md
# git add README*.md scripts/README*.md
git add README*.md build-assets/README*.md

git commit -m "READMEs update" || true
# git commit -m "READMEs update prerequisites" || true
# git commit -m "READMEs update xpack-dev-tools path" || true
# git commit -m "README-MAINTAINER rename xbbla" || true

__EOF__

# -----------------------------------------------------------------------------

tmp_file_commit_package="$(mktemp)"
cat <<'__EOF__' >"${tmp_file_commit_package}"
cd "$1"

echo
echo $1

# git add package.json
git add package.json
if [ -f package-lock.json ]
then
  git add package-lock.json
fi

# git commit -m "package.json: add scripts" || true
# git commit -m "package.json: update Work/xpacks" || true
# git commit -m "package.json: bump deps & reorder git-log" || true
# git commit -m "package.json: mkdir -pv cache" || true
# git commit -m "package.json: clang 17.0.6-1.1" || true
# git commit -m "package.json: xpm-version 0.18.0" || true
# git commit -m "package.json: update xpack-dev-tools path" || true
# git commit -m "package.json: move scripts to actions" || true
# git commit -m "package.json: minXpm 0.16.3 & @xpack-dev-tools/xbb-helper" || true
# git commit -m "package.json: liquidjs --context --template" || true
# git commit -m "package.json: reorder build actions" || true
# git commit -m "package.json: add build-development-debug" || true
# git commit -m "package.json: rename xbbla" || true
# git commit -m "package.json: rm xpack-dev-tools-build/*" || true
# git commit -m "package.json: add linux32" || true
# git commit -m "package.json: rework generate workflows" || true
# git commit -m "package.json: loglevel info" || true
# git commit -m "package.json: add actions, bump deps" || true
# git commit -m "package.json: update generate-workflows" || true
# git commit -m "package.json: git+https" || true
# git commit -m "package.json: cosmetics" || true
git commit -m "package.json: bump deps" || true

__EOF__

tmp_file_commit_build_assets_package="$(mktemp)"
cat <<'__EOF__' >"${tmp_file_commit_build_assets_package}"
cd "$1"

if [ ! -d build-assets ]
then
  exit 0
fi

cd build-assets

echo
echo $1

git add package.json
if [ -f package-lock.json ]
then
  git add package-lock.json
fi

# git add ../package.json

# git commit -m "build-assets/package.json: build-development & docker 5.2.2" || true
# git commit -m "build-assets/package.json: updates" || true
git commit -m "build-assets/package.json: bump deps" || true
# git commit -m "package.json: bump minimumXpmRequired 0.20.5" || true


__EOF__

# -----------------------------------------------------------------------------

tmp_file_commit_copyrights="$(mktemp)"
cat <<'__EOF__' >"${tmp_file_commit_copyrights}"
cd "$1"

echo
echo $1
git add -A

git commit -m "copyright updates" || true

__EOF__

# -----------------------------------------------------------------------------

# set -x

# UPDATE ME!
# commands_file="${tmp_file_template_github}"
# commands_file="${tmp_file_template_blog}"
# commands_file="${tmp_file_blog}"
# commands_file="${tmp_file_workflows}"
# commands_file="${tmp_file_application}"

# commands_file="${tmp_file_scripts}"
# commands_file="${tmp_file_npmignore}"

# commands_file="${tmp_file_website}"
# commands_file="${tmp_file_website_xpack}"

# commands_file="${tmp_file_commit_readmes}"

# commands_file="${tmp_file_commit_package}"
commands_file="${tmp_file_commit_build_assets_package}"
# commands_file="${tmp_file_commit_copyrights}"

repos_folder="$(dirname $(dirname "${script_folder_path}"))"

cd "${repos_folder}"

for f in "${repos_folder}"/*/.git
do
  (
    cd "$(dirname "${f}")"

    if [ ! -d build-assets ]
    then
      continue
    fi

    echo
    pwd

    bash -x "${commands_file}" "$(dirname "${f}")"
  )
done

echo
echo "${script_name} done"


# -----------------------------------------------------------------------------
