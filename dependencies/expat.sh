# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://libexpat.github.io
# https://github.com/libexpat/libexpat/releases

# https://gitlab.archlinux.org/archlinux/packaging/packages/expat/-/blob/main/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/expat/files/PKGBUILD
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=expat-git

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/e/expat.rb

# Oct 21, 2017 "2.1.1"
# Nov 1, 2017 "2.2.5"
# 26 Sep 2019 "2.2.9"
# 3 Oct 2020, "2.2.10"
# 25 Mar 2021 "2.3.0"
# 23 May 2021, "2.4.1"
# 29 Mar 2022, "2.4.8"

# -----------------------------------------------------------------------------

function expat_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local expat_version="$1"

  local expat_src_folder_name="expat-${expat_version}"
  local expat_archive="${expat_src_folder_name}.tar.bz2"
  if [[ ${expat_version} =~ 2[.]0[.].* ]]
  then
    expat_archive="${expat_src_folder_name}.tar.gz"
  fi

  local expat_release="R_$(echo ${expat_version} | sed -e 's|[.]|_|g')"
  local expat_url="https://github.com/libexpat/libexpat/releases/download/${expat_release}/${expat_archive}"

  local expat_folder_name="${expat_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${expat_folder_name}"

  local expat_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${expat_folder_name}-installed"
  if [ ! -f "${expat_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${expat_url}" "${expat_archive}" \
      "${expat_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${expat_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${expat_folder_name}"

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
          echo "Running expat configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${expat_src_folder_name}/configure" --help
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

          config_options+=("--without-docbook")
          config_options+=("--without-xmlwf")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${expat_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${expat_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${expat_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running expat make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

        # Has no install-strip
        run_verbose make install

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${expat_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${expat_src_folder_name}" \
        "${expat_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${expat_stamp_file_path}"

  else
    echo "Library expat already installed"
  fi
}

# -----------------------------------------------------------------------------
