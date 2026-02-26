# -----------------------------------------------------------------------------
#
# This file is part of the xPack project (http://xpack.github.io).
# Copyright (c) 2024-2026 Liviu Ionescu. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
#
# If a copy of the license was not distributed with this file, it can
# be obtained from https://opensource.org/licenses/mit.
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
  local threshold=$((32767 * (100-$4)/100))
  local threshold_sha=0

  if [ ${threshold} -ne 0 ]
  then
    # Half the archive threshold.
    threshold_sha=$((32767 * (100-($4/2))/100))
  fi

  local archive_name
  if [ "${platform}" == "win32-x64" ] || [ "${platform}" == "win32-x32" ] || [ "${platform}" == "win32-ia32" ]
  then
    archive_name="xpack-${name}-${version}-${platform}.zip"
  else
    archive_name="xpack-${name}-${version}-${platform}.tar.gz"
  fi

  archive_url="https://sourceforge.net/projects/${name}-xpack/files/v${version}/${archive_name}/download"

  mkdir -p "${HOME}/tmp/sourceforge"

  echo
  # 0-32767
  if [ ${RANDOM} -gt ${threshold} ]
  then
    echo "Downloading ${archive_name}..."

    # Try download up to 3 times
    local success="false"
    for attempt in 1 2 3; do
      if curl --location --insecure --fail --location --silent \
            --output "${HOME}/tmp/sourceforge/${archive_name}" \
            "${archive_url}"
      then
        success="true"
        break
      else
        echo "Download attempt ${attempt} failed"
        if [ ${attempt} -lt 3 ]; then
          local delay=$((5 * attempt))
          echo "Retrying in ${delay} seconds..."
          sleep ${delay}
        fi
      fi
    done

    if [ "${success}" == "false" ]; then
      echo "All download attempts failed for ${archive_name}"
      return 1
    fi

    if [ ${RANDOM} -gt ${threshold_sha} ]
    then
      archive_name+=".sha"
      archive_url="https://sourceforge.net/projects/${name}-xpack/files/v${version}/${archive_name}/download"

      echo "Downloading ${archive_name}..."

      # Try download up to 3 times
      local success_sha="false"
      for attempt in 1 2 3; do
        if curl --location --insecure --fail --location --silent \
              --output "${HOME}/tmp/sourceforge/${archive_name}" \
              "${archive_url}"
        then
          success_sha="true"
          break
        else
          echo "SHA download attempt ${attempt} failed"
          if [ ${attempt} -lt 3 ]; then
            local delay=$((5 * attempt))
            echo "Retrying in ${delay} seconds..."
            sleep ${delay}
          fi
        fi
      done

      if [ "${success_sha}" == "false" ]; then
        echo "All SHA download attempts failed for ${archive_name}"
        return 1
      fi
    fi

    # Give it some time to rest.
    sleep 5
  else
    echo "Skipping ${archive_name}..."
  fi
  return 0
}

function download_sourceforge()
{
  local name="$1"
  local version="$2"
  local threshold=$3
  local platforms="$4"

  IFS=','
  for platform in ${platforms}
  do
    download_sourceforge_one "${name}" "${version}" "${platform}" ${threshold}
    rm -rf "${HOME}/tmp/sourceforge"
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
