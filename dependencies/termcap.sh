# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.gnu.org/software/termutils/
# https://ftp.gnu.org/gnu/termcap/
# https://ftp.gnu.org/gnu/termcap/termcap-1.3.1.tar.gz

# https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-termcap/PKGBUILD

# 2002-03-13, "1.3.1"

# -----------------------------------------------------------------------------

function termcap_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local termcap_version="$1"

  local termcap_src_folder_name="termcap-${termcap_version}"

  local termcap_archive="${termcap_src_folder_name}.tar.gz"
  local termcap_url="https://ftp.gnu.org/gnu/termcap/${termcap_archive}"

  local termcap_folder_name="${termcap_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${termcap_folder_name}"

  local termcap_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${termcap_folder_name}-installed"
  if [ ! -f "${termcap_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    if [ ! -d "${termcap_src_folder_name}" ]
    then
      download_and_extract "${termcap_url}" "${termcap_archive}" \
        "${termcap_src_folder_name}"

      run_verbose sed -i -e 's|char PC;|static char PC;|' \
        "${termcap_src_folder_name}/termcap.c"
    fi

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${termcap_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${termcap_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"

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
          echo "Running termcap configure..."

          if is_develop
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${termcap_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

          # No --libdir, --includedir, --datarootdir, --mandir

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${termcap_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${termcap_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${termcap_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running termcap make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

        run_verbose make install


      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${termcap_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${termcap_src_folder_name}" \
        "${termcap_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${termcap_stamp_file_path}"

  else
    echo "Library termcap already installed"
  fi
}

# -----------------------------------------------------------------------------
