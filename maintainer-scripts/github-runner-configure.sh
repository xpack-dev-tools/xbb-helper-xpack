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

organization="xpack-dev-tools"

cache_folder_path="${HOME}/cache"
mkdir -pv "${cache_folder_path}"

tmp_script_file="$(mktemp -t script)"

if [ "$(uname -s)" == "Darwin" ]
then
  platform="osx"
elif [ "$(uname -s)" == "Linux" ]
then
  platform="linux"
else
  echo "Unexpected platform..."
  exit 1
fi

if [ "$(uname -m)" == "x86_64" ]
then
  arch="x64"
elif [ "$(uname -m)" == "aarch64" ]
then
  arch="arm64"
elif [ "$(uname -m)" == "armv7l" ]
then
  arch="arm"
else
  echo "Unexpected arch..."
  exit 1
fi

# -----------------------------------------------------------------------------

# https://docs.github.com/en/rest/releases/releases?apiVersion=2022-11-28
echo
echo "Getting latest runner release..."
curl -L -s -S \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GITHUB_API_XPACK_DEV_TOOLS_RUNNERS_TOKEN}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/actions/runner/releases/latest \
  --output "${tmp_script_file}"

# cat "${tmp_script_file}"

# Like v2.321.0
release_name="$(json -f "${tmp_script_file}" name)"
# Long text. The SHA sums are marked with BEGIN ... END comments.
release_body="$(json -f "${tmp_script_file}" body)"

# Without v, like 2.321.0
version="$(echo "${release_name}" | sed -e 's|v||')"

sha="$(echo "${release_body}" | grep "BEGIN SHA" | grep "actions-runner-${platform}-${arch}-${version}" | sed -e 's|<!-- END SHA.*||' -e 's|.* -->||' )"

if [ "${hostname}" == "xbbmi.local" ]
then
  # Lock xbbmi to this old version until an update to macOS 11.
  version="2.320.0"
  sha="11e610adc1c3721a806d2a439d03d143cceeda7a63e794bfe75b45da55e308df"
fi

if [ ! -f "${cache_folder_path}/actions-runner-${platform}-${arch}-${version}.tar.gz" ]
then
  (
    cd "${cache_folder_path}"

    echo
    echo "Downloading actions-runner-${platform}-${arch}-${version}.tar.gz..."
    curl -L \
      "https://github.com/actions/runner/releases/download/v${version}/actions-runner-${platform}-${arch}-${version}.tar.gz" \
      --output "actions-runner-${platform}-${arch}-${version}.tar.gz"

    # Validate SHA.
    echo "${sha}  actions-runner-${platform}-${arch}-${version}.tar.gz" | shasum -a 256 -c
  )
fi

function get_token()
{
  curl -L -s -S \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GITHUB_API_XPACK_DEV_TOOLS_RUNNERS_TOKEN}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/orgs/${organization}/actions/runners/registration-token" \
    --output "${tmp_script_file}"

  json -f "${tmp_script_file}" "token"
}

hostname="$(hostname)"

if [ "${hostname}" == "wksi.local" ]
then
  sudo rm -rf "${HOME}/actions-runners/${organization}"

  mkdir -p "${HOME}/actions-runners/${organization}"
  cd "${HOME}/actions-runners/${organization}"
  (
    echo
    echo "Unpacking archive..."
    tar xzf "${cache_folder_path}/actions-runner-${platform}-${arch}-${version}.tar.gz"

    token="$(get_token)"

    echo
    echo "Configuring..."
    ./config.sh --url "https://github.com/${organization}" --token "${token}" --name 'wksi' --labels 'intel,14.6,wksi' --unattended --replace

    echo "To remove the runner, use:"
    echo "(cd "${HOME}/actions-runners/${organization}"; ./config.sh remove --token "${token}")"
  )
elif [ "${hostname}" == "xbbmi.local" ]
then
  sudo rm -rf "${HOME}/actions-runners/${organization}"

  mkdir -p "${HOME}/actions-runners/${organization}"
  cd "${HOME}/actions-runners/${organization}"
  (
    echo
    echo "Unpacking archive..."
    tar xzf "${cache_folder_path}/actions-runner-${platform}-${arch}-${version}.tar.gz"

    token="$(get_token)"

    echo
    echo "Configuring..."
    ./config.sh --url "https://github.com/${organization}" --token "${token}" --name 'xbbmi' --labels 'intel,10.14,xbbmi' --unattended --replace --disableupdate

    echo "To remove the runner, use:"
    echo "(cd "${HOME}/actions-runners/${organization}"; ./config.sh remove --token "${token}")"
  )
elif [ "${hostname}" == "xbbli" ]
then
  sudo rm -rf "${HOME}/actions-runners/${organization}"

  mkdir -p "${HOME}/actions-runners/${organization}/1"
  (
    cd "${HOME}/actions-runners/${organization}/1"
    echo
    echo "Unpacking archive..."
    tar xzf "${cache_folder_path}/actions-runner-${platform}-${arch}-${version}.tar.gz"

    token="$(get_token)"

    echo
    echo "Configuring 1..."
    ./config.sh --url "https://github.com/${organization}" --token "${token}" --name 'xbbli-1' --labels 'xbbli,xbblix,intel' --unattended --replace

    echo "To remove the runner 1, use:"
    echo "(cd "${HOME}/actions-runners/${organization}"; ./config.sh remove --token "${token}")"
  )
  mkdir -p "${HOME}/actions-runners/${organization}/2"
  (
    cd "${HOME}/actions-runners/${organization}/2"
    echo
    echo "Unpacking archive..."
    tar xzf "${cache_folder_path}/actions-runner-${platform}-${arch}-${version}.tar.gz"

    token="$(get_token)"

    echo
    echo "Configuring 2..."
    ./config.sh --url "https://github.com/${organization}" --token "${token}" --name 'xbbli-2' --labels 'xbbli,xbbliw,intel' --unattended --replace

    echo "To remove the runner 2, use:"
    echo "(cd "${HOME}/actions-runners/${organization}"; ./config.sh remove --token "${token}")"
  )
elif [ "${hostname}" == "xbbla" ]
then
  sudo rm -rf "${HOME}/actions-runners/${organization}"

  mkdir -p "${HOME}/actions-runners/${organization}/1"
  (
    cd "${HOME}/actions-runners/${organization}/1"
    echo
    echo "Unpacking archive..."
    tar xzf "${cache_folder_path}/actions-runner-${platform}-${arch}-${version}.tar.gz"

    token="$(get_token)"

    echo
    echo "Configuring 1..."
    ./config.sh --url "https://github.com/${organization}" --token "${token}" --name 'xbbla-1' --labels 'xbbla,xbblax' --unattended --replace

    echo "To remove the runner 1, use:"
    echo "(cd "${HOME}/actions-runners/${organization}"; ./config.sh remove --token "${token}")"
  )
  mkdir -p "${HOME}/actions-runners/${organization}/2"
  (
    cd "${HOME}/actions-runners/${organization}/2"
    echo
    echo "Unpacking archive..."
    tar xzf "${cache_folder_path}/actions-runner-${platform}-${arch}-${version}.tar.gz"

    token="$(get_token)"

    echo
    echo "Configuring 2..."
    ./config.sh --url "https://github.com/${organization}" --token "${token}" --name 'xbbla-2' --labels 'xbbla,xbblay' --unattended --replace

    echo "To remove the runner 2, use:"
    echo "(cd "${HOME}/actions-runners/${organization}"; ./config.sh remove --token "${token}")"
  )
elif [ "${hostname}" == "xbbla32" ]
then
  sudo rm -rf "${HOME}/actions-runners/${organization}"

  mkdir -p "${HOME}/actions-runners/${organization}"
  (
    cd "${HOME}/actions-runners/${organization}"
    echo
    echo "Unpacking archive..."
    tar xzf "${cache_folder_path}/actions-runner-${platform}-${arch}-${version}.tar.gz"

    token="$(get_token)"

    echo
    echo "Configuring..."
    ./config.sh --url "https://github.com/${organization}" --token "${token}" --name 'xbbla32' --labels 'xbbla32' --unattended --replace

    echo "To remove the runner, use:"
    echo "(cd "${HOME}/actions-runners/${organization}"; ./config.sh remove --token "${token}")"
  )
else
  echo "Unrecognized host ${hostname}..."
  exit 1
fi

echo
echo "To check organization runners:"
echo "https://github.com/organizations/${organization}/settings/actions/runners"

# -----------------------------------------------------------------------------

rm -rf "${tmp_script_file}"

echo
echo "${script_name} done"

# Completed successfully.
exit 0

# -----------------------------------------------------------------------------
