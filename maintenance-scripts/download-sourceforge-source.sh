# -----------------------------------------------------------------------------
#
# This file is part of the xPack project (http://xpack.github.io).
# Copyright (c) 2024 Liviu Ionescu.  All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
#
# If a copy of the license was not distributed with this file, it can
# be obtained from https://opensource.org/licenses/MIT.
#
# -----------------------------------------------------------------------------

function run_verbose()
{
  # Does not include the .exe extension.
  local app_path="$1"
  shift

  echo
  echo "[${app_path} $@]"
  "${app_path}" "$@" 2>&1
}

function download_sourceforge_one()
{
  local name="$1"
  local version="$2"
  local platform="$3"
  local threshold=$4

  local archive_name
  if [ "${platform}" == "win32-x64" ] || [ "${platform}" == "win32-x32" ] || [ "${platform}" == "win32-ia32" ]
  then
    archive_name="xpack-${name}-${version}-${platform}.zip"
  else
    archive_name="xpack-${name}-${version}-${platform}.tar.gz"
  fi

  archive_url="https://sourceforge.net/projects/${name}-xpack/files/v${version}/${archive_name}/download"

  mkdir -pv "${HOME}/tmp/sourceforge"

  # 0-32767
  if [ ${RANDOM} -ge ${threshold} ]
  then
    echo
    echo "Downloading ${archive_name}..."

    curl --location --insecure --fail --location --silent \
          --output "${HOME}/tmp/sourceforge/${archive_name}" \
          "${archive_url}"

    # 2/3 (>1/3)
    if [ ${RANDOM} -ge 10922 ]
    then
      archive_name+=".sha"
      archive_url="https://sourceforge.net/projects/${name}-xpack/files/v${version}/${archive_name}/download"

      echo "Downloading ${archive_name}..."

      curl --location --insecure --fail --location --silent \
            --output "${HOME}/tmp/sourceforge/${archive_name}" \
            "${archive_url}"
    fi

    # Give it some time to rest.
    sleep 5
  else
    echo
    echo "Skipping ${archive_name}..."
  fi
}

function download_sourceforge()
{
  local name="$1"
  local version="$2"
  local threshold=$3
  local platforms="$4"

  IVS=','
  for platform in ${platforms}
  do
    download_sourceforge_one "${name}" "${version}" "${platform}" ${threshold}
  done
}

# -----------------------------------------------------------------------------

# 2019
# platforms="win32-x64,win32-x32,linux-x64,linux-x32,darwin-x64"
# 2020, 2021
# platforms="win32-x64,win32-ia32,linux-x64,linux-ia32,linux-arm64,linux-arm,darwin-x64"
# 2022, 2023, 2024
# platforms="win32-x64,linux-x64,linux-arm64,linux-arm,darwin-x64,darwin-arm64"
# 2025
# platforms="win32-x64,linux-x64,linux-arm64,darwin-x64,darwin-arm64"
# 2025-no-darwin
# platforms="win32-x64,linux-x64,linux-arm64"

# -----------------------------------------------------------------------------

# Node code to compute the cron minute & hour as a hash of the name.

# name='xxx'
# sum=0; for(i = 0; i < name.length; ++i) { sum+=name.charCodeAt(i) }; console.log(sum%60, sum%24)

# -----------------------------------------------------------------------------
