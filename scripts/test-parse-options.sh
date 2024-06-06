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
# Included by the application `scripts/test.sh`.

function tests_parse_options()
{
  echo
  echo "[${FUNCNAME[0]} $@]"

  XBB_IS_DEBUG="n"
  XBB_IS_DEVELOP="n"

  XBB_FORCE_32_BIT="n"
  XBB_IMAGE_NAME=""
  XBB_RELEASE_VERSION="${XBB_RELEASE_VERSION:-$(xbb_get_current_version)}"
  XBB_BASE_URL="${XBB_BASE_URL:-}"
  XBB_DO_TEST_VIA_XPM="n"
  XBB_OUTPUT_FILE_NAME="tests"
  XBB_USE_CACHED_ARCHIVE="n"
  XBB_NPM_PACKAGE_VERSION="next"

  while [ $# -gt 0 ]
  do
    case "$1" in

      --help )
        echo "usage: $(basename $0) [--32] [--version X.Y.Z] [--base-url URL]"
        exit 0
        ;;

      --develop )
        XBB_IS_DEVELOP="y"
        XBB_OUTPUT_FILE_NAME+="-develop"
        shift
        ;;

      --32 )
        XBB_FORCE_32_BIT="y"
        XBB_OUTPUT_FILE_NAME+="-32"
        shift
        ;;

      --image )
        XBB_IMAGE_NAME="$2"
        shift 2
        ;;

      --version )
        if [ "$2" != "current" ]
        then
          XBB_RELEASE_VERSION="$2"
        fi
        shift 2
        ;;

      --package-version )
        # tags like "next" and "latest" also accepted.
        XBB_NPM_PACKAGE_VERSION="$2"
        shift 2
        ;;

      --base-url )
        XBB_BASE_URL="$2"
        XBB_OUTPUT_FILE_NAME+="-base-url"
        shift 2
        ;;

      --xpm )
        XBB_DO_TEST_VIA_XPM="y"
        XBB_OUTPUT_FILE_NAME+="-xpm"
        shift
        ;;

      --cache )
        XBB_USE_CACHED_ARCHIVE="y"
        shift
        ;;

      --* )
        echo "Unsupported option $1 in ${FUNCNAME[0]}()"
        exit 1
        ;;

      * )
        echo "Unsupported arg $1 in ${FUNCNAME[0]}()"
        exit 1
        ;;

    esac
  done

  export XBB_IS_DEBUG
  export XBB_IS_DEVELOP

  export XBB_RELEASE_VERSION
  export XBB_BASE_URL
  export XBB_IMAGE_NAME
  export XBB_FORCE_32_BIT
  export XBB_DO_TEST_VIA_XPM
  export XBB_OUTPUT_FILE_NAME
  export XBB_USE_CACHED_ARCHIVE
  export XBB_NPM_PACKAGE_VERSION

  if is_develop
  then
    echo
    echo "XBB_RELEASE_VERSION=${XBB_RELEASE_VERSION}"
    echo "XBB_BASE_URL=${XBB_BASE_URL}"
    echo "XBB_FORCE_32_BIT=${XBB_FORCE_32_BIT}"
    echo "XBB_IMAGE_NAME=${XBB_IMAGE_NAME}"
    echo "XBB_DO_TEST_VIA_XPM=${XBB_DO_TEST_VIA_XPM}"
    echo "XBB_OUTPUT_FILE_NAME=${XBB_OUTPUT_FILE_NAME}"
    echo "XBB_NPM_PACKAGE_VERSION=${XBB_NPM_PACKAGE_VERSION}"
  fi
}

# -----------------------------------------------------------------------------
