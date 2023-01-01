# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.gnu.org/software/findutils/
# https://ftp.gnu.org/gnu/findutils/
# https://ftp.gnu.org/gnu/findutils/findutils-4.8.0.tar.xz

# 2021-01-09, "4.8.0"
# 2022-02-01, "4.9.0"

# TODO: check before use.

# -----------------------------------------------------------------------------

function findutils_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local findutils_version="$1"

  local findutils_src_folder_name="findutils-${findutils_version}"

  local findutils_archive="${findutils_src_folder_name}.tar.xz"
  local findutils_url="https://ftp.gnu.org/gnu/findutils/${findutils_archive}"

  local findutils_folder_name="${findutils_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${findutils_folder_name}"

  local findutils_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${findutils_folder_name}-installed"
  if [ ! -f "${findutils_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${findutils_url}" "${findutils_archive}" \
      "${findutils_src_folder_name}"

    (
      if [ ! -x "${XBB_SOURCES_FOLDER_PATH}/${findutils_src_folder_name}/configure" ]
      then

        cd "${XBB_SOURCES_FOLDER_PATH}/${findutils_src_folder_name}"

        xbb_activate_dependencies_dev

        run_verbose bash ${DEBUG} "bootstrap.sh"

      fi
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${findutils_folder_name}/autogen-output-$(ndate).txt"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${findutils_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${findutils_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP}"

      xbb_adjust_ldflags_rpath

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running findutils configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${findutils_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          # config_options+=("--host=${XBB_HOST_TRIPLET}")
          # config_options+=("--target=${XBB_TARGET_TRIPLET}")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${findutils_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${findutils_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${findutils_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running findutils make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/find"

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${findutils_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${findutils_src_folder_name}" \
        "${findutils_folder_name}"

    )

    (
      findutils_test
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${findutils_folder_name}/test-output-$(ndate).txt"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${findutils_stamp_file_path}"

  else
    echo "Component findutils already installed"
  fi
}

function findutils_test()
{
  (
    echo
    echo "Checking the findutils shared libraries..."

    show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/find"

    echo
    echo "Checking if findutils starts..."
    "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/find" || true
  )
}

# -----------------------------------------------------------------------------
