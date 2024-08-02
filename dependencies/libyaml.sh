function libyaml_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local libyaml_version="$1"

  local libyaml_src_folder_name="yaml-${libyaml_version}"

  local libyaml_archive="${libyaml_src_folder_name}.tar.gz"

  libyaml_url="https://pyyaml.org/download/libyaml/yaml-"${libyaml_version}".tar.gz"
  local libyaml_folder_name="${libyaml_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libyaml_folder_name}"

  local libyaml_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-libyaml-${libyaml_version}-installed"
  if [ ! -f "${libyaml_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libyaml_url}" "${libyaml_archive}" \
      "${libyaml_src_folder_name}"

    (
      if [ ! -x "${XBB_SOURCES_FOLDER_PATH}/${libyaml_src_folder_name}/configure" ]
      then

        run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}/${libyaml_src_folder_name}"

        xbb_activate_dependencies_dev

        run_verbose bash ${DEBUG} "bootstrap"

      fi
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libyaml_folder_name}/bootstrap-output-$(ndate).txt"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libyaml_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${libyaml_folder_name}"

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
          echo "Running libyaml configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libyaml_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${libyaml_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libyaml_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libyaml_folder_name}/configure-output-$(ndate).txt"

      fi

      (
        echo
        echo "Running libyaml make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if with_strip
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libyaml_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libyaml_src_folder_name}" \
        "${libyaml_folder_name}"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libyaml_stamp_file_path}"

  else
    echo "Library libyaml already installed"
  fi
}
