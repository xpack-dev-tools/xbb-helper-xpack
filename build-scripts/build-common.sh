#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2022 Liviu Ionescu. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Included by the application `scripts/build.sh`.

source "${helper_folder_path}/build-scripts/timer.sh"
source "${helper_folder_path}/build-scripts/machine.sh"
source "${helper_folder_path}/build-scripts/is-something.sh"
source "${helper_folder_path}/build-scripts/wrappers.sh"
source "${helper_folder_path}/build-scripts/xbb.sh"
source "${helper_folder_path}/build-scripts/build-tests.sh"
source "${helper_folder_path}/build-scripts/download.sh"
source "${helper_folder_path}/build-scripts/post-processing.sh"
source "${helper_folder_path}/build-scripts/show-libs.sh"
source "${helper_folder_path}/build-scripts/miscellaneous.sh"

# -----------------------------------------------------------------------------

function build_common_parse_options()
{
  local help_message="$1"
  shift

  XBB_REQUEST_TARGET_BE_WINDOWS="n"

  XBB_IS_DEBUG="n"
  XBB_IS_DEVELOPMENT="n"
  XBB_WITH_STRIP="y"
  XBB_WITH_PDF="n"
  XBB_WITH_HTML="n"

  if [ "${XBB_ENVIRONMENT_SKIP_CHECKS:-""}" == "y" ]
  then
    XBB_WITH_TESTS="n"
  else
    XBB_WITH_TESTS="y"
  fi

  XBB_WITHOUT_MULTILIB="${XBB_APPLICATION_WITHOUT_MULTILIB:-"n"}"
  XBB_TEST_ONLY="n"

  XBB_REQUESTED_TARGET=""
  XBB_REQUESTED_BUILD_RELATIVE_FOLDER=""

  local uname="$(uname)"
  if [ "${uname}" == "Linux" ]
  then
    XBB_JOBS="$(nproc)"
  elif [ "${uname}" == "Darwin" ]
  then
    XBB_JOBS="$(sysctl hw.ncpu | sed 's/hw.ncpu: //')"
  else
    XBB_JOBS="1"
  fi

  echo
  echo "The ${XBB_APPLICATION_DISTRO_NAME} ${XBB_APPLICATION_NAME} distribution build script"

  while [ $# -gt 0 ]
  do
    case "$1" in

      --win | --windows )
        XBB_REQUEST_TARGET_BE_WINDOWS="y"
        shift
        ;;

      --debug )
        XBB_IS_DEBUG="y"
        shift
        ;;

      --develop | --development )
        XBB_IS_DEVELOPMENT="y"
        shift
        ;;

      --jobs )
        shift
        XBB_JOBS=$1
        shift
        ;;

      --disable-strip )
        XBB_WITH_STRIP="n"
        shift
        ;;

      --disable-tests )
        XBB_WITH_TESTS="n"
        shift
        ;;

      --test-only | --tests-only )
        XBB_TEST_ONLY="y"
        shift
        ;;

      --disable-multilib )
        XBB_WITHOUT_MULTILIB="y"
        shift
        ;;

      --target )
        shift
        XBB_REQUESTED_TARGET="$1"
        shift
        ;;

      --build-folder )
        shift
        if [ "${1:0:1}" == "/" ]
        then
          echo "Only relative paths are accepted for --build-folder"
          exit 1
        fi
        XBB_REQUESTED_BUILD_RELATIVE_FOLDER="$1"
        shift
        ;;

      --help )
        echo "Usage:"
        echo "${help_message}"
        echo
        exit 0
        ;;

      * )
        echo "Unsupported option $1 in ${FUNCNAME[0]}()"
        exit 1
        ;;

    esac

  done

  # Debug automatically disables strip.
  if [ "${XBB_IS_DEBUG}" == "y" ]
  then
    XBB_WITH_STRIP="n"
  fi

  export XBB_IS_DEBUG
  export XBB_IS_DEVELOPMENT

  # DEPRECATED!
  export XBB_IS_DEVELOP="${XBB_IS_DEVELOPMENT}"

  export XBB_WITH_STRIP
  export XBB_WITH_PDF
  export XBB_WITH_HTML
  export XBB_WITH_TESTS
  export XBB_WITHOUT_MULTILIB
  export XBB_TEST_ONLY

  export XBB_REQUEST_TARGET_BE_WINDOWS
  export XBB_REQUESTED_BUILD_RELATIVE_FOLDER
}

# =============================================================================

function build_common_run()
{
  # Avoid leaving files that cannot be removed by users.
  trap xbb_make_writable EXIT

  # Must be after host_parse_options, for a simple --help.
  timer_start

  machine_detect

  xbb_save_env
  xbb_set_requested
  xbb_reset_env
  xbb_prepare_pkg_config

  # Deprecated in Sep 2023.
  # copy_build_files

  tests_initialize

  xbb_set_target "native"

  # Leave a trace of copied files for later inspection.
  # (XBB_LOGS_FOLDER_PATH is set in xbb_set_target).
  export XBB_LOGS_COPIED_FILES_FILE_PATH="${XBB_LOGS_FOLDER_PATH}/copied-files-$(ndate).txt"
  mkdir -pv "${XBB_LOGS_FOLDER_PATH}"
  touch "${XBB_LOGS_COPIED_FILES_FILE_PATH}"

  xbb_show_tools_versions

  # Prime it early
  tests_prime_wine

  if [ -f "/.dockerenv" ]
  then
    (
      cd "${HOME}"
      if [ ! -d "work" ]
      then
        # This is a hack, required by GCC 12, which returns lower case paths
        # to `-print-file-name`.
        ln -s Work work
      fi
    )
  fi

  (
    # Isolate the build in a sub-shell, to run the tests in a clean environment.

    echo
    echo "Here we go..."
    echo

    # -------------------------------------------------------------------------
    # The actual build.

    # It sets variables in the environment, required for post-processing,
    # run it in the same sub-shell.
    application_build_versioned_components

    # -------------------------------------------------------------------------
    # Post-processing.

    if [ ! "${XBB_TEST_ONLY}" == "y" ]
    then
      # Run the final steps in the requested environment.
      xbb_reset_env

      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        # Add the native XBB bin to the PATH to get the bootstrap compiler.
        if is_variable_set "XBB_NATIVE_DEPENDENCIES_INSTALL_FOLDER_PATH" &&
          [ -d "${XBB_NATIVE_DEPENDENCIES_INSTALL_FOLDER_PATH}/bin" ]
        then
          PATH="${XBB_NATIVE_DEPENDENCIES_INSTALL_FOLDER_PATH}/bin:$PATH"
          echo_develop "PATH=${PATH}"
        fi
      fi

      xbb_set_target "requested"

      mkdir -pv "${XBB_LOGS_FOLDER_PATH}"
      (
        if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "win32" ]
        then
          # The Windows still has a reference to libgcc_s and libwinpthread
          export XBB_DO_COPY_GCC_LIBS="y"
        fi

        xbb_show_env_develop

        # Post processing.
        make_standalone

        # strip_libs
        strip_binaries

        copy_distro_files
        application_copy_files

        check_binaries

        application_check_binaries

        create_archive
      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/post-process-output-$(ndate).txt"
    else
      echo
      echo "Tests only, skipping post processing..."
    fi
  )

  # ---------------------------------------------------------------------------
  # Final checks.

  # Guarantee a known environment.
  xbb_reset_env
  xbb_set_target "requested"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}"
  (
    # Isolate the tests in a sub-shell to easily capture the output.
    xbb_show_env_develop

    tests_run_final

    tests_report_results
  ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/tests-output-$(ndate).txt"

  # ---------------------------------------------------------------------------

  # We're basically done, from now on, errors should not break the build.
  set +o errexit # Do not exit if command fails

  if [ "${XBB_TEST_ONLY}" != "y" ]
  then
    mkdir -pv "${XBB_LOGS_FOLDER_PATH}"
    (
      echo
      echo "# Build results..."

      # When testing the bootstrap, the application folder is not there.
      mkdir -pv "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/bin"

      run_verbose ls -l "${XBB_APPLICATION_INSTALL_FOLDER_PATH}"
      run_verbose ls -l "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/bin"
      if [ -d "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/libexec" ]
      then
        run_verbose ls -l "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/libexec"
      fi
      if [ -d "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/lib" ]
      then
        run_verbose ls -l "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/lib"
      fi
      if [ -d "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/include" ]
      then
        run_verbose ls -l "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/include"
      fi
      if [ -d "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/shared" ]
      then
        run_verbose ls -l "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/shared"
      fi

      echo
      echo "# Copied files..."
      cat  "${XBB_LOGS_COPIED_FILES_FILE_PATH}" | sort

      if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "win32" ] || is_variable_set "XBB_APPLICATION_SHOW_DLLS"
      then
        (
          cd "${XBB_APPLICATION_INSTALL_FOLDER_PATH}"
          run_verbose find . -name '*.dll'
        )
      fi

      (
        cd "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/bin"

        echo
        echo "package.json xpack.bin definitions:"
        ls -1 -p | grep -v '/' | sed -e 's|[.]exe$||' | sed -e '/[.]dll$/d' | sed -e '/[.]zip$/d' | sed -e '/DLLs$/d' | sort | sed -e 's|\(.*\)|      "\1": "./.content/bin/\1",|'
      )

      run_verbose ls -l "${XBB_DEPLOY_FOLDER_PATH}"

      run_verbose tree -L 2 -A "${XBB_APPLICATION_INSTALL_FOLDER_PATH}" || true

    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/post-lists-output-$(ndate).txt"
  fi

  # ---------------------------------------------------------------------------

  (
    timer_stop
  ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/duration-$(ndate).txt"
}

# -----------------------------------------------------------------------------
