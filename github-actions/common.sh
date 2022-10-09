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

function trigger_github_workflow()
{
  local github_org="$1"
  local github_repo="$2"
  local workflow_id="$3"
  local data_file_path="$4"
  local token="$5"

  echo
  echo "Request body:"
  cat "${data_file_path}"

  # This script requires an authentication token in the environment.
  # https://docs.github.com/en/rest/reference/actions#create-a-workflow-dispatch-event

  echo
  echo "Response:"

  curl \
    --request POST \
    --include \
    --header "Authorization: token ${token}" \
    --header "Content-Type: application/json" \
    --header "Accept: application/vnd.github.v3+json" \
    --data-binary @"${data_file_path}" \
    https://api.github.com/repos/${github_org}/${github_repo}/actions/workflows/${workflow_id}/dispatches

  rm -rf "${data_file_path}"
}

# -----------------------------------------------------------------------------
