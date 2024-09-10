# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://tiswww.case.edu/php/chet/readline/rltop.html
# https://ftp.gnu.org/gnu/readline/
# https://ftp.gnu.org/gnu/readline/readline-8.0.tar.gz

# https://gitlab.archlinux.org/archlinux/packaging/packages/readline/-/blob/main/PKGBUILD

# depends=(glibc gcc-libs)
# https://archlinuxarm.org/packages/aarch64/readline/files/PKGBUILD

# https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-readline/PKGBUILD

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/r/readline.rb

# 2019-01-07, "8.0"
# 2020-12-06, "8.1"
# 2022-01-05, "8.1.2"
# 2022-09-26, "8.2" - fails on mingw

# -----------------------------------------------------------------------------

function readline_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local readline_version="$1"
  local readline_version_major=$(xbb_get_version_major "${readline_version}")
  local readline_version_minor=$(xbb_get_version_minor "${readline_version}")

  # The folder name as resulted after being extracted from the archive.
  local readline_src_folder_name="readline-${readline_version}"

  local readline_archive="${readline_src_folder_name}.tar.gz"
  local readline_url="https://ftp.gnu.org/gnu/readline/${readline_archive}"

  # The folder name  for build, licenses, etc.
  local readline_folder_name="${readline_src_folder_name}"

  local readline_patch_file_path="${readline_folder_name}.patch"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${readline_folder_name}"

  local readline_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${readline_folder_name}-installed"
  if [ ! -f "${readline_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${readline_url}" "${readline_archive}" \
      "${readline_src_folder_name}" "${readline_patch_file_path}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${readline_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${readline_folder_name}"

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
          echo "Running readline configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${readline_src_folder_name}/configure" --help
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

          if [ "${XBB_HOST_PLATFORM}" == "win32" ]
          then
            config_options+=("--without-curses")
          else
            config_options+=("--with-curses")
          fi

          # Add a reference to the TERMCAP libtinfo.so, otherwise
          # python 3.12 fails to load the module.
          config_options+=("--with-shared-termcap-library")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${readline_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${readline_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${readline_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running readline make..."

        # Build.
        run_verbose make -j 1 # ${XBB_JOBS}

        # Has no install-strip
        run_verbose make install

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${readline_folder_name}/make-output-$(ndate).txt"
    )

    (
      readline_test
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${readline_folder_name}/test-output-$(ndate).txt"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${readline_stamp_file_path}"

  else
    echo "Library readline already installed"
  fi
}

function readline_test()
{
  (
    echo
    echo "Checking the readline shared libraries..."

    show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libreadline.${XBB_HOST_SHLIB_EXT}"
    show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libhistory.${XBB_HOST_SHLIB_EXT}"
  )
}

# -----------------------------------------------------------------------------
