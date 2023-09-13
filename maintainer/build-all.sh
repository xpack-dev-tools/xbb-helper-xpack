#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2022 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
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

build_script_path="$0"
if [[ "${build_script_path}" != /* ]]
then
  # Make relative path absolute.
  build_script_path="$(pwd)/$0"
fi

script_folder_path="$(dirname "${build_script_path}")"
script_folder_name="$(basename "${script_folder_path}")"

# =============================================================================

# Maintenance script used to build all packages available on a given platform.
# To run it, clone the helper project and then run:
#
# bash ${WORK}/xbb-helper-xpack.git/maintainer/build-all.sh
# bash ${WORK}/xbb-helper-xpack.git/maintainer/build-all.sh --windows

# -----------------------------------------------------------------------------

WORK="${HOME}/Work/xpack-dev-tools"

do_windows=""
do_clone=""
do_dry_run=""
do_status=""
do_deep_clean=""

do_patch_debian=""

# https://www.gnu.org/software/bash/manual/html_node/Arrays.html
declare -a excluded=( )

while [ $# -gt 0 ]
do
  case "$1" in
    --windows )
      do_windows="y"
      shift
      ;;

    --clone )
      do_clone="y"
      shift
      ;;

    --dry-run )
      do_dry_run="y"
      shift
      ;;

    --status )
      do_status="y"
      shift
      ;;

    --deep-clean )
      do_deep_clean="y"
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

    * )
      echo "Unsupported argument $1 in ${FUNCNAME[0]}()"
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
  elif [ "$(uname -m)" == "armv7l" -o "$(uname -m)" == "armv8l" ]
  then
    config=linux-arm
  else
    echo "Unsupported architecture $(uname -m)"
    exit 1
  fi
else
  echo "Unsupported machine $(uname)"
  exit 1
fi

names=()

# All-platform packages.
names+=( gcc )
names+=( mingw-w64-gcc )

names+=( cmake )
names+=( meson-build )
names+=( ninja-build )

names+=( openocd )

names+=( qemu-arm )
names+=( qemu-riscv )

names+=( arm-none-eabi-gcc )
names+=( aarch64-none-elf-gcc )
names+=( riscv-none-elf-gcc )

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

# At the end, as the longest.
names+=( clang )

if [ "${do_status}" == "y" ]
then
  names+=( xbb-helper )
  for name in ${names[@]}
  do
    run_verbose git -C ${WORK}/${name}-xpack.git status
  done

  exit 0
fi

if [ "${do_clone}" == "y" ]
then

  # Preload clean repos.
  for name in ${names[@]}
  do

    run_verbose rm -rf ${WORK}/${name}-xpack.git && \
    run_verbose mkdir -p ${WORK} && \
    run_verbose git clone \
      --branch xpack-develop \
      https://github.com/xpack-dev-tools/${name}-xpack.git \
      ${WORK}/${name}-xpack.git

  done

  exit 0
fi

# git -C ${WORK}/xbb-helper-xpack.git pull
# xpm link -C ${WORK}/xbb-helper-xpack.git

IFS="|"
for name in ${names[@]}
do

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
      run_verbose git -C ${WORK}/${name}-xpack.git pull
    else
      run_verbose git clone \
        --branch xpack-develop \
        https://github.com/xpack-dev-tools/${name}-xpack.git \
        ${WORK}/${name}-xpack.git
    fi

    if [ "${do_patch_debian}" == "y" ]
    then
      (
        cd "${WORK}/${name}-xpack.git"
        run_verbose sed -i.bak \
          -e 's|"dockerImage": "ilegeul/ubuntu:amd64-18.04-xbb-v5.1.1"|"dockerImage": "ilegeul/debian:amd64-10-xbb-v5.1.1"|' \
          -e 's|"dockerImage": "ilegeul/ubuntu:arm64v8-18.04-xbb-v5.1.1"|"dockerImage": "ilegeul/debian:arm64v8-10-xbb-v5.1.1"|' \
          -e 's|"dockerImage": "ilegeul/ubuntu:arm32v7-18.04-xbb-v5.1.1"|"dockerImage": "ilegeul/debian:arm32v7-10-xbb-v5.1.1"|' \
          package.json

        run_verbose diff package.json.bak package.json || true
      )
    fi

    if [ "${do_deep_clean}" == "y" ]
    then
      xpm run deep-clean -C ${WORK}/${name}-xpack.git
    fi

    xpm run install -C ${WORK}/${name}-xpack.git
    xpm run link-deps -C ${WORK}/${name}-xpack.git

    if [ "$(uname)" == "Darwin" ]
    then
      xpm run deep-clean --config ${config}  -C ${WORK}/${name}-xpack.git
      xpm install --config ${config} -C ${WORK}/${name}-xpack.git

      if [ "${do_dry_run}" == "y" ]
      then
        echo "Skipping real action for ${name}..."
      else
        xpm run build-develop --config ${config} -C ${WORK}/${name}-xpack.git
      fi
    elif [ "$(uname)" == "Linux" ]
    then
      xpm run deep-clean --config ${config} -C ${WORK}/${name}-xpack.git
      xpm run docker-prepare --config ${config} -C ${WORK}/${name}-xpack.git
      xpm run docker-link-deps --config ${config} -C ${WORK}/${name}-xpack.git

      if [ "${do_dry_run}" == "y" ]
      then
        echo "would run [xpm run docker-build-develop --config ${config} -C ${WORK}/${name}-xpack.git]"
      else
        xpm run docker-build-develop --config ${config} -C ${WORK}/${name}-xpack.git
      fi
      xpm run docker-remove --config ${config} -C ${WORK}/${name}-xpack.git
    fi

    # Cannot do this if we want the final statistics.
    # xpm run deep-clean --config ${config} -C ${WORK}/${name}-xpack.git
  fi

done

echo
echo "# Durations summary:"

run_verbose find ${WORK} -name 'duration-*-*.txt' -exec echo '[cat {}]' ';' -exec cat '{}' ';' -exec echo ';'

echo
echo "# Copied files summary:"

run_verbose find ${WORK} -name 'copied-files-*-*.txt' -exec echo '[sort {}]' ';' -exec echo ';' -exec sort '{}' ';' -exec echo ';'

echo "Done"
exit 0

# -----------------------------------------------------------------------------
