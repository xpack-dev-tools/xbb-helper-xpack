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

function common_build()
{
  # Must be after host_parse_options, for a simple --help.
  timer_start

  host_detect

  xbb_set_env

  tests_initialize

  copy_build_files

  # ---------------------------------------------------------------------------

  (
    echo
    xbb_set_compiler_env

    echo
    echo "Here we go..."
    echo

    build_versioned_components

    if [ ! "${TEST_ONLY}" == "y" ]
    then
      (
        if [ "${TARGET_PLATFORM}" == "win32" ]
        then
          # The Windows still has a reference to libgcc_s and libwinpthread
          export DO_COPY_GCC_LIBS="y"
        fi

        # Post processing.
        make_standalone

        # strip_libs
        strip_binaries

        copy_distro_files
        copy_custom_files

        check_binaries

        create_archive
      )
    fi
  )

  # ---------------------------------------------------------------------------

  # Final checks.
  # To keep everything as pristine as possible, run tests
  # only after the archive is packed.

  tests_prime_wine

  tests_run

  # -----------------------------------------------------------------------------

  if [ "${TEST_ONLY}" != "y" ]
  then
    (
      echo
      echo "# Build results..."

      run_verbose ls -l "${DEPLOY_FOLDER_PATH}"

      run_verbose ls -l "${APPLICATION_INSTALL_FOLDER_PATH}"
      run_verbose ls -l "${APPLICATION_INSTALL_FOLDER_PATH}/bin"

      (
        cd "${APPLICATION_INSTALL_FOLDER_PATH}/bin"

        echo
        echo "package.json xpack.bin definitions:"
        ls -1 | sed -e 's|\.exe$||' | sed -e '/\.dll$/d' | sort | sed -e 's|\(.*\)|      "\1": "./.content/bin/\1",|'
      )
    ) 2>&1 | tee "${LOGS_FOLDER_PATH}/post-lists-output-$(ndate).txt"
  fi

  # ---------------------------------------------------------------------------

  timer_stop
}

# -----------------------------------------------------------------------------
