# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://github.com/PCRE2Project/pcre2
# https://github.com/PCRE2Project/pcre2/releases
# https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.40/pcre2-10.40.tar.bz2

# https://gitlab.archlinux.org/archlinux/packaging/packages/pcre2/-/blob/main/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/pcre2/files/PKGBUILD
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/p/pcre2.rb

# 15 Apr 2022, "10.40"

# -----------------------------------------------------------------------------

function pcre2_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local pcre2_version="$1"

  local pcre2_src_folder_name="pcre2-${pcre2_version}"

  local pcre2_archive="${pcre2_src_folder_name}.tar.bz2"
  local pcre2_url="https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${pcre2_version}/${pcre2_archive}"

  local pcre2_folder_name="${pcre2_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${pcre2_folder_name}"

  local pcre2_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${pcre2_folder_name}-installed"
  if [ ! -f "${pcre2_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${pcre2_url}" "${pcre2_archive}" \
      "${pcre2_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${pcre2_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${pcre2_folder_name}"

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
          echo "Running pcre2 configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${pcre2_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          config_options+=("--enable-pcre2-16")
          config_options+=("--enable-pcre2-32")
          config_options+=("--enable-jit")
          config_options+=("--enable-pcre2grep-libz")
          config_options+=("--enable-pcre2grep-libbz2")
          # config_options+=("--enable-pcre2test-libreadline")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${pcre2_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${pcre2_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${pcre2_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running pcre2 make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          # On macOS RunGrepTest fails.
          run_verbose make -j1 check || true
        fi

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${pcre2_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${pcre2_src_folder_name}" \
        "${pcre2_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${pcre2_stamp_file_path}"

  else
    echo "Library pcre2 already installed"
  fi
}

# -----------------------------------------------------------------------------

