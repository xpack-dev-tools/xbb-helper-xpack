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

# Pass the results file name as first argument.
results_file_name="${1:-results}"

# grep "${test_case_name}" results | sed -e 's|^.*FAIL.*[(]|export |' -e 's|[)]|="y"|'

for f in $(grep 'FAIL:' "${results_file_name}" | sed -e 's|^.*: ||' -e 's| [(].*$||' -e 's|gc-||' -e 's|lto-||' -e 's|crt-||' -e 's|lld-||' -e 's|static-lib-||' -e 's|static-||'  -e 's|libcxx-||' 2>&1 | sort -u)
do
  echo
  echo "# ${f}."
  grep "${f}" "${results_file_name}" | grep 'FAIL:' | sed -e 's|^.*FAIL.*[(]|export |' -e 's|[)]|="y"|'
done

