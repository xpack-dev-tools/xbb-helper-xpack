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

# data_file_path
# github_org
# github_repo
function trigger_travis()
{
  local github_org="$1"
  local github_repo="$2"
  local data_file_path="$3"
  local token="$4"

  curl \
    --request POST \
    --include \
    --header "Content-Type: application/json" \
    --header "Accept: application/json" \
    --header "Travis-API-Version: 3" \
    --header "Authorization: token ${token}" \
    --data-binary @"${data_file_path}" \
    https://api.travis-ci.com/repo/${github_org}%2F${github_repo}/requests
    # Warning: Do not add a trailing slash, it'll fail!

  rm -rf "${data_file_path}"
}

# Still in use, as the only available with old macOS versions.
# https://docs.travis-ci.com/user/reference/osx/
function create_macos_data_file()
{
  local message="$1"
  local branch="$2"
  local base_url="$3"
  local helper_git_ref="$4"
  local data_file_path="$5"

rm -rf "${data_file_path}"

# Versions before 10.13 may work for general packages, but fail on toolchains
# since they do not have the expected system headers in:
# /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk

# Note: __EOF__ is NOT quoted to allow substitutions.
cat <<__EOF__ > "${data_file_path}"
{
  "request": {
    "message": "${message}",
    "branch": "${branch}",
    "config": {
      "merge_mode": "replace",
      "jobs": [
        {
          "name": "x64 macOS 12.4",
          "os": "osx",
          "arch": "amd64",
          "osx_image": "xcode13.4.1",
          "language": "minimal",
          "script": [
            "sw_vers",
            "pwd",
            "ls -lLA",
            "env | sort",
            "mkdir -p xpacks",
            "git clone https://github.com/xpack-dev-tools/xbb-helper-xpack xpacks/xpack-dev-tools-xbb-helper",
            "git clone checkout ${helper_git_ref} -b xpack-develop"
            "DEBUG=${DEBUG} bash scripts/test.sh --base-url ${base_url}"
          ]
        }
      ],
      "notifications": {
        "email": {
          "on_success": "always",
          "on_failure": "always"
        }
      }
    }
  }
}
__EOF__

cat "${data_file_path}"
}

# -----------------------------------------------------------------------------

