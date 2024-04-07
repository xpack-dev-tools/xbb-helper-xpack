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

function timer_start()
{
  export XBB_SCRIPT_BEGIN_SECOND=$(date +%s)
  echo
  echo "Script \"$0\" started at $(date)"
}

function timer_stop()
{
  local script_end_second=$(date +%s)
  echo
  echo "The ${XBB_APPLICATION_DISTRO_NAME} ${XBB_APPLICATION_NAME} (${XBB_APPLICATION_LOWER_CASE_NAME}) project - ${XBB_REQUESTED_TARGET_PLATFORM}-${XBB_REQUESTED_TARGET_ARCH}"
  echo "Script \"$0\" completed at $(date)"
  local delta_seconds=$((script_end_second-XBB_SCRIPT_BEGIN_SECOND))
  if [ ${delta_seconds} -lt 2 ]
  then
    printf "Duration: %d second" ${delta_seconds}
  elif [ ${delta_seconds} -lt 100 ]
  then
    printf "Duration: %d seconds" ${delta_seconds}
  elif [ ${delta_seconds} -lt 3600 ]
  then
    local delta_minutes=$(((delta_seconds+30)/60))
    printf "Duration: %d minutes" ${delta_minutes}
  else
    local delta_minutes=$(((delta_seconds+30)/60))
    local delta_hours=$((delta_minutes/60))
    local delta_hour_minutes=$((delta_minutes-(delta_hours*60)))
    printf "Duration: %d minutes (%dh%02dm)\n" ${delta_minutes} ${delta_hours} ${delta_hour_minutes}
  fi
}

# -----------------------------------------------------------------------------
