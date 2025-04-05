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

function download_sourceforge_2019()
{
  local name="$1"
  local version="$2"
  local threshold=$3

  download_sourceforge_one "${name}" "${version}" "win32-x64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "win32-x32" ${threshold}
  download_sourceforge_one "${name}" "${version}" "linux-x64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "linux-x32" ${threshold}
  download_sourceforge_one "${name}" "${version}" "darwin-x64" ${threshold}
}

function download_sourceforge_2020()
{
  local name="$1"
  local version="$2"
  local threshold=$3

  download_sourceforge_one "${name}" "${version}" "win32-x64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "win32-ia32" ${threshold}
  download_sourceforge_one "${name}" "${version}" "linux-x64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "linux-ia32" ${threshold}
  download_sourceforge_one "${name}" "${version}" "linux-arm64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "linux-arm" ${threshold}
  download_sourceforge_one "${name}" "${version}" "darwin-x64" ${threshold}
}

function download_sourceforge_2022()
{
  local name="$1"
  local version="$2"
  local threshold=$3

  download_sourceforge_one "${name}" "${version}" "win32-x64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "linux-x64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "linux-arm64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "linux-arm" ${threshold}
  download_sourceforge_one "${name}" "${version}" "darwin-x64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "darwin-arm64" ${threshold}
}

function download_sourceforge_2023()
{
  local name="$1"
  local version="$2"
  local threshold=$3

  download_sourceforge_one "${name}" "${version}" "win32-x64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "linux-x64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "linux-arm64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "linux-arm" ${threshold}
  download_sourceforge_one "${name}" "${version}" "darwin-x64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "darwin-arm64" ${threshold}
}

function download_sourceforge_2024()
{
  local name="$1"
  local version="$2"
  local threshold=$3

  download_sourceforge_one "${name}" "${version}" "win32-x64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "linux-x64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "linux-arm64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "linux-arm" ${threshold}
  download_sourceforge_one "${name}" "${version}" "darwin-x64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "darwin-arm64" ${threshold}
}

function download_sourceforge_2025()
{
  local name="$1"
  local version="$2"
  local threshold=$3

  download_sourceforge_one "${name}" "${version}" "win32-x64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "linux-x64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "linux-arm64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "darwin-x64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "darwin-arm64" ${threshold}
}

function download_sourceforge_2025_no_darwin()
{
  local name="$1"
  local version="$2"
  local threshold=$3

  download_sourceforge_one "${name}" "${version}" "win32-x64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "linux-x64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "linux-arm64" ${threshold}
}

# -----------------------------------------------------------------------------

# name='xxx'
# sum=0; for(i = 0; i < name.length; ++i) { sum+=name.charCodeAt(i) }; console.log(sum%60, sum%24)
