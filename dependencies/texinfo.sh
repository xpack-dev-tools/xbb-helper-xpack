# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.gnu.org/software/texinfo/
# https://ftp.gnu.org/gnu/texinfo/

# https://gitlab.archlinux.org/archlinux/packaging/packages/texinfo/-/blob/main/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/texinfo/files/PKGBUILD
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=texinfo-svn

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/t/texinfo.rb

# 2017-09-12, "6.5"
# 2019-02-16, "6.6"
# 2019-09-23, "6.7"
# 2021-07-03, "6.8"

# -----------------------------------------------------------------------------

function texinfo_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local texinfo_version="$1"

  local texinfo_src_folder_name="texinfo-${texinfo_version}"

  local texinfo_archive="${texinfo_src_folder_name}.tar.gz"
  local texinfo_url="https://ftp.gnu.org/gnu/texinfo/${texinfo_archive}"

  local texinfo_folder_name="${texinfo_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${texinfo_folder_name}"

  local texinfo_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${texinfo_folder_name}-installed"
  if [ ! -f "${texinfo_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${texinfo_url}" "${texinfo_archive}" \
      "${texinfo_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${texinfo_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${texinfo_folder_name}"

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
          echo "Running texinfo configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${texinfo_src_folder_name}/configure" --help
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

          # config_options+=("--disable-debug") # HB but not recognised
          config_options+=("--disable-dependency-tracking") # HB
          if is_development
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--disable-install-warnings") # HB

          config_options+=("--disable-nls")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${texinfo_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${texinfo_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${texinfo_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running texinfo make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if with_strip
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        run_verbose rm -rf "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/info" "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man"

        # Darwin: FAIL: t/94htmlxref.t 11 - htmlxref errors file_html
        # Darwin: ERROR: t/94htmlxref.t - exited with status 2

        # Too many.
        if false # [ "${XBB_WITH_TESTS}" == "y" ]
        then
          if is_darwin
          then
            if is_development
            then
              run_verbose make -j1 check || true
            fi
          else
            run_verbose make -j1 check
          fi
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${texinfo_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${texinfo_src_folder_name}" \
        "${texinfo_folder_name}"
    )

    (
      texinfo_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${texinfo_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${texinfo_stamp_file_path}"

  else
    echo "Component texinfo already installed"
  fi

  tests_add "texinfo_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function texinfo_test()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Testing if texinfo scripts start properly..."

    run_host_app_verbose "${test_bin_folder_path}/texi2pdf" --version

    # No ELFs, it is a script.
  )
}

# -----------------------------------------------------------------------------
