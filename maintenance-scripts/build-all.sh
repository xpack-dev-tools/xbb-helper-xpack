#!/usr/bin/env bash
# -----------------------------------------------------------------------------
#
# This file is part of the xPack project (http://xpack.github.io).
# Copyright (c) 2022 Liviu Ionescu. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
#
# If a copy of the license was not distributed with this file, it can
# be obtained from https://opensource.org/licenses/MIT.
#
# -----------------------------------------------------------------------------

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

export script_path
export script_name="$(basename "${script_path}")"

export script_folder_path="$(dirname "${script_path}")"
export script_folder_name="$(basename "${script_folder_path}")"

# =============================================================================

# Maintenance script used to build all packages available on a given platform.
# To run it, clone the helper project and then run:
#
# bash ${WORK}/xbb-helper-xpack.git/maintainer/build-all.sh
# bash ${WORK}/xbb-helper-xpack.git/maintainer/build-all.sh --windows

# -----------------------------------------------------------------------------

argv="$@"

stamps_folder_name="$(echo "${script_name}" | sed -e 's|\.sh$||')"
stamps_folder_path="$(dirname $(dirname "${script_folder_path}"))/stamps/${stamps_folder_name}"

WORK="${HOME}/Work/xpack-dev-tools"

do_windows=""
do_clone=""
do_dry_run=""
do_repos_status=""
do_deep_clean=""
do_purge=""
do_update_top=""
do_restart=""
do_check_space=""

do_patch_debian=""

# https://www.gnu.org/software/bash/manual/html_node/Arrays.html
declare -a excluded=( )

while [ $# -gt 0 ]
do
  case "$1" in
    --windows )
      do_windows="y"
      stamps_folder_path+="-windows"
      shift
      ;;

    --clone )
      if [ $(hostname -s) == "wksi" ]
      then
        echo "Cloning on wksi is not a good idea"
        exit 1
      fi
      do_clone="y"
      shift
      ;;

    --purge )
      do_purge="y"
      shift
      ;;

    --restart )
      do_restart="y"
      shift
      ;;

    --dry-run )
      do_dry_run="y"
      shift
      ;;

    --status|--repos-status )
      do_repos_status="y"
      shift
      ;;

    --deep-clean )
      do_deep_clean="y"
      shift
      ;;

    --update-top )
      do_update_top="y"
      shift
      ;;

    --exclude )
      excluded+=( "$2" )
      shift 2
      ;;

    --patch-debian )
      do_patch_debian="y"
      shift
      ;;

    --check-space )
      do_check_space="y"
      shift
      ;;

    * )
      echo "Unsupported argument $1 in $(basename "$0")"
      exit 1
      ;;
  esac
done

# -----------------------------------------------------------------------------

function run_verbose()
{
  local app_path="$1"
  shift

  echo
  echo "[${app_path} $@]"
  "${app_path}" "$@" 2>&1
}

# -----------------------------------------------------------------------------

if [ "$(uname)" == "Darwin" ]
then
  if [ "$(uname -m)" == "x86_64" ]
  then
    config=darwin-x64
  elif [ "$(uname -m)" == "arm64" ]
  then
    config=darwin-arm64
  else
    echo "Unsupported architecture $(uname -m)"
    exit 1
  fi
elif [ "$(uname)" == "Linux" ]
then
  if [ "$(uname -m)" == "x86_64" ]
  then
    if [ "${do_windows}" == "y" ]
    then
      config=win32-x64
    else
      config=linux-x64
    fi
  elif [ "$(uname -m)" == "aarch64" ]
  then
    config=linux-arm64
  # elif [ "$(uname -m)" == "armv7l" -o "$(uname -m)" == "armv8l" ]
  # then
  #   config=linux-arm
  else
    echo "Unsupported architecture $(uname -m)"
    exit 1
  fi
else
  echo "Unsupported machine $(uname)"
  exit 1
fi

# -----------------------------------------------------------------------------

names=()

# All-platform packages.

# Start with the light ones.
names+=( ninja-build )
names+=( cmake )
names+=( meson-build )

names+=( openocd )

names+=( qemu-arm )
names+=( qemu-riscv )

if [ "${do_windows}" == "y" ]
then
  # Windows only packages.
  names+=( windows-build-tools )
else
  # Linux & macOS only packages (no Windows).
  names+=( patchelf pkg-config realpath m4 sed bison flex texinfo )

  if [ "${config}" == "linux-x64" ]
  then
    # Linux only packages.
    names+=( wine )
  fi
fi

# The heavy ones.
if [ "$(uname)" != "Darwin" ]
then
  # No more gcc on macOS!
  names+=( gcc )
fi

names+=( mingw-w64-gcc )

names+=( aarch64-none-elf-gcc )
names+=( arm-none-eabi-gcc )
names+=( riscv-none-elf-gcc )

# At the end, as the longest.
names+=( clang )

# -----------------------------------------------------------------------------

if [ "${do_repos_status}" == "y" ]
then
  names+=( xbb-helper )
  for name in ${names[@]}
  do
    run_verbose git -C ${WORK}/${name}-xpack.git status
  done

  echo "'${script_name} ${argv}' done"

  exit 0
elif [ "${do_clone}" == "y" ]
then

  rm -rf ~/Work/xpack-dev-tools/xbb-helper-xpack.git && \
  mkdir -p ~/Work/xpack-dev-tools && \
  run_verbose git clone \
    --branch xpack-development \
    https://github.com/xpack-dev-tools/xbb-helper-xpack.git \
    ~/Work/xpack-dev-tools/xbb-helper-xpack.git
  run_verbose xpm link -C ~/Work/xpack-dev-tools/xbb-helper-xpack.git

  rm -rf ~/Work/xpack/npm-packages-helper.git && \
  mkdir -p ~/Work/xpack && \
  run_verbose git clone \
  https://github.com/xpack/npm-packages-helper.git \
  ~/Work/xpack/npm-packages-helper.git

  run_verbose npm --prefix ~/Work/xpack/npm-packages-helper.git link --verbose

  rm -rf ~/Work/xpack/docusaurus-template-liquid.git && \
  mkdir -p ~/Work/xpack && \
  run_verbose git clone \
  https://github.com/xpack/docusaurus-template-liquid.git \
  ~/Work/xpack/docusaurus-template-liquid.git

  run_verbose npm --prefix ~/Work/xpack/docusaurus-template-liquid.git link --verbose

  # Preload clean repos.
  for name in ${names[@]}
  do

    run_verbose rm -rf ${WORK}/${name}-xpack.git && \
    run_verbose mkdir -p ${WORK} && \
    run_verbose git clone \
      --branch xpack-development \
      https://github.com/xpack-dev-tools/${name}-xpack.git \
      ${WORK}/${name}-xpack.git

  done

  echo "'${script_name} ${argv}' done"

  exit 0
elif [ "${do_update_top}" == "y" ]
then
  for name in ${names[@]}
  do
    (
      cd ${WORK}/${name}-xpack.git
      run_verbose npm run npm-link-helpers
      run_verbose npm run generate-top-commons
    )
  done

  echo "'${script_name} ${argv}' done"

  exit 0
elif [ "${do_check_space}" == "y" ]
then
  if [ "$(uname)" == "Darwin" ]
  then
    run_verbose df -gH /
  elif [ "$(uname)" == "Linux" ]
  then
    run_verbose df -BG -H /
  fi

  echo "'${script_name} ${argv}' done"

  exit 0
elif [ "${do_restart}" == "y" ]
then
  run_verbose rm -rf "${stamps_folder_path}"

  echo "'${script_name} ${argv}' done"

  exit 0
fi

# -----------------------------------------------------------------------------

run_verbose git -C ~/Work/xpack-dev-tools/xbb-helper-xpack.git pull
run_verbose git -C ~/Work/xpack/npm-packages-helper.git pull
run_verbose git -C ~/Work/xpack/docusaurus-template-liquid.git pull

IFS="|"
for name in ${names[@]}
do

  if [ -f "${stamps_folder_path}/${name}" ]
  then
      echo "${name} already built..."
      continue
  fi

  echo
  echo "----------------------------------------------------------------------------"
  echo "${name}"

  # if [ "${excluded["${name}"]}" == "y" ] # not functional
  # if [[ -v excluded[${name}] ]] # bash 4.x only
  if [ ${#excluded[@]} -gt 0 ] && [[ "${IFS}${excluded[*]}${IFS}" =~ "${IFS}${name}${IFS}" ]]
  then
    echo
    echo "Skipping ${name}..."
  else
    # Temporary?
    rm -rf "${WORK}/${name}-xpack.git/package-lock.json"

    if [ -d "${WORK}/${name}-xpack.git" ]
    then
      run_verbose rm -rf ${WORK}/${name}-xpack.git/package-lock.json
      run_verbose rm -rf ${WORK}/${name}-xpack.git/build-assets/package-lock.json
      run_verbose git -C ${WORK}/${name}-xpack.git pull
    else
      run_verbose git clone \
        --branch xpack-development \
        https://github.com/xpack-dev-tools/${name}-xpack.git \
        ${WORK}/${name}-xpack.git
    fi

    (
      run_verbose cd "${WORK}/${name}-xpack.git"

      if [ "${do_patch_debian}" == "y" ]
      then
        run_verbose sed -i.bak \
          -e 's|"dockerImage": "ilegeul/ubuntu:amd64-18.04-xbb-v5.[0-9].[0-9]"|"dockerImage": "ilegeul/debian:amd64-10-xbb-v5.1.1"|' \
          -e 's|"dockerImage": "ilegeul/ubuntu:arm64v8-18.04-xbb-v5.[0-9].[0-9]"|"dockerImage": "ilegeul/debian:arm64v8-10-xbb-v5.1.1"|' \
          -e 's|"dockerImage": "ilegeul/ubuntu:arm32v7-18.04-xbb-v5.[0-9].[0-9]"|"dockerImage": "ilegeul/debian:arm32v7-10-xbb-v5.1.1"|' \
          package.json

        run_verbose diff package.json.bak package.json || true
      fi

      if [ "${do_deep_clean}" == "y" ]
      then
        run_verbose xpm run install -C build-assets
        run_verbose xpm run deep-clean -C build-assets
      fi

      run_verbose npm install
      run_verbose xpm run install -C build-assets
      run_verbose xpm run link-deps -C build-assets

      export XBB_ENVIRONMENT_SKIP_CHECKS="y"

      if [ "$(uname)" == "Darwin" ]
      then
        if [ "${do_deep_clean}" == "y" ]
        then
          run_verbose xpm run deep-clean --config ${config}  -C build-assets
        fi
        run_verbose xpm install --config ${config} -C build-assets

        if [ "${do_dry_run}" == "y" ]
        then
          echo "Skipping real action for ${name}..."
        else
          run_verbose xpm run build-development --config ${config} -C build-assets
        fi
      elif [ "$(uname)" == "Linux" ]
      then
        if [ "${do_deep_clean}" == "y" ]
        then
          run_verbose xpm run deep-clean --config ${config} -C build-assets
        fi
        run_verbose xpm run docker-prepare --config ${config} -C build-assets
        run_verbose xpm run docker-link-deps --config ${config} -C build-assets

        if [ "${do_dry_run}" == "y" ]
        then
          echo "would run [xpm run docker-build-development --config ${config} -C ${WORK}/${name}-xpack.git/build-assets]"
        else
          run_verbose xpm run docker-build-development --config ${config} -C build-assets
        fi
        run_verbose xpm run docker-remove --config ${config} -C build-assets
      fi

      if [ "${do_purge}" == "y" ]
      then
        # Cannot do this if we want the final statistics.
        run_verbose xpm run deep-clean -C build-assets
      fi
    )

    run_verbose run_verbose mkdir -pv "${stamps_folder_path}"
    run_verbose run_verbose touch "${stamps_folder_path}/${name}"

  fi

done

# -----------------------------------------------------------------------------

work_build_folder="${WORK}"
if [ ! -z "${WORK_FOLDER_PATH:-""}" ]
then
  work_build_folder="${WORK_FOLDER_PATH}/xpack-dev-tools-build"
fi

if [ "${do_purge}" != "y" ]
then
  echo
  echo "# Durations summary:"

  run_verbose find ${work_build_folder} -name 'duration-*-*.txt' -exec echo '[cat {}]' ';' -exec cat '{}' ';' -exec echo ';'

  echo
  echo "# Copied files summary:"

  run_verbose find ${work_build_folder} -name 'copied-files-*-*.txt' -exec echo '[sort {}]' ';' -exec echo ';' -exec sort '{}' ';' -exec echo ';'
fi

echo "'${script_name} ${argv}' done"
exit 0

# -----------------------------------------------------------------------------
