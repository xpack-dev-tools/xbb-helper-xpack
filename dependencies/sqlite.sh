# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.sqlite.org/
# https://sqlite.org/chronology.html
# https://www.sqlite.org/download.html
# https://www.sqlite.org/2020/sqlite-src-3330000.zip
# https://www.sqlite.org/2021/sqlite-src-3360000.zip
# https://www.sqlite.org/2022/sqlite-src-3380200.zip
# https://www.sqlite.org/src/tarball/7ebdfa80/SQLite-7ebdfa80.tar.gz

# https://github.com/archlinux/svntogit-packages/blob/packages/sqlite/trunk/PKGBUILD

# https://archlinuxarm.org/packages/aarch64/sqlite/files/PKGBUILD

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/sqlite.rb

# 2020-06-18 "3.32.3" 7ebdfa80
# 2021-06-18 "3360000"
# 2022 "3380200"
# "3390200"

# -----------------------------------------------------------------------------

function sqlite_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local sqlite_version="$1"

  local sqlite_src_folder_name="sqlite-src-${sqlite_version}"
  local sqlite_archive="${sqlite_src_folder_name}.zip"
  local sqlite_url

  if [ "${sqlite_version}" == "3390200" ]
  then
    # 2022
    sqlite_url="https://www.sqlite.org/2022/${sqlite_archive}"
  elif [ "${sqlite_version}" == "3380200" ]
  then
    # 2022
    sqlite_url="https://www.sqlite.org/2022/${sqlite_archive}"
  elif [ "${sqlite_version}" == "3360000" ]
  then
    # 2021
    sqlite_url="https://www.sqlite.org/2021/${sqlite_archive}"
  elif [ "${sqlite_version}" == "3.32.3" ]
  then
    sqlite_commit="7ebdfa80"
    sqlite_src_folder_name="SQLite-${sqlite_commit}"
    sqlite_archive="${sqlite_src_folder_name}.tar.gz"
    sqlite_url="https://www.sqlite.org/src/tarball/${sqlite_commit}/${sqlite_archive}"
  else
    echo "Unsupported sqlite version ${sqlite_version} in ${FUNCNAME[0]}()"
    exit 1
  fi

  local sqlite_folder_name="sqlite-${sqlite_version}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${sqlite_folder_name}"

  local sqlite_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${sqlite_folder_name}-installed"
  if [ ! -f "${sqlite_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${sqlite_url}" "${sqlite_archive}" \
      "${sqlite_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${sqlite_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${sqlite_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS} -I${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/readline"
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
          echo "Running sqlite configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${sqlite_src_folder_name}/configure" --help
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

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--disable-editline") # HB
          # config_options+=("--disable-static") # Arch

          config_options+=("--enable-tcl=no")

          config_options+=("--enable-dynamic-extensions") # HB
          # config_options+=("--enable-readline") # HB
          config_options+=("--enable-session") # HB

          config_options+=("--enable-fts3") # Arch
          config_options+=("--enable-fts4") # Arch
          config_options+=("--enable-fts5") # Arch
          config_options+=("--enable-rtree") # Arch

          # config_options+=("--with-readline-inc=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/readline")
          # config_options+=("--with-readline-lib=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--disable-readline")

          # For readline, see CPPFLAGS.

          # Fails on macOS & Linux.
          # config_options+=("--disable-tcl")
          # Fail on macOS.
          # config_options+=("--disable-readline")
          # config_options+=("--disable-amalgamation")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${sqlite_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${sqlite_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${sqlite_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running sqlite make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        # Fails on Linux. And takes way too long.
        # 2 errors out of 249249 tests on docker Linux 64-bit little-endian
        # !Failures on these tests: oserror-1.4.1 oserror-1.4.2
        if false # [ "${XBB_WITH_TESTS}" == "y" ]
        then
          (
            # To access the /opt/xbb/lib/libtcl8.6.so
            xbb_activate_libs

            run_verbose make -j1 quicktest
          )
        fi

        # Has no install-strip
        run_verbose make install

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${sqlite_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${sqlite_src_folder_name}" \
        "${sqlite_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${sqlite_stamp_file_path}"

  else
    echo "Library sqlite already installed"
  fi
}

# -----------------------------------------------------------------------------
