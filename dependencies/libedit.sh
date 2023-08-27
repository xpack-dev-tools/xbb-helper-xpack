# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.thrysoee.dk/editline/
# https://www.thrysoee.dk/editline/libedit-20221030-3.1.tar.gz

# https://github.com/archlinux/svntogit-packages/blob/packages/libedit/trunk/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/libedit/files/PKGBUILD

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/l/libedit.rb

# 2021-05-22, "20210522-3.1"
# 2021-09-10, "20210910-3.1"
# 2022-10-30, "20211030-3.1"

# depends=('glibc' 'ncurses' 'libncursesw.so')

# -----------------------------------------------------------------------------

function libedit_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local libedit_version="$1"
  local libedit_version_short="$(echo ${libedit_version} | sed -e 's|[0-9]*-||')"

  local libedit_src_folder_name="libedit-${libedit_version}"
  local libedit_archive="${libedit_src_folder_name}.tar.gz"

  local libedit_url="https://www.thrysoee.dk/editline/${libedit_archive}"

  local libedit_folder_name="libedit-${libedit_version_short}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libedit_folder_name}"

  local libedit_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${libedit_folder_name}-installed"
  if [ ! -f "${libedit_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libedit_url}" "${libedit_archive}" \
      "${libedit_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libedit_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${libedit_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      if [ "${XBB_HOST_PLATFORM}" == "linux" ]
      then
        if [ -d "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/ncursesw" ]
        then
          CPPFLAGS+=" -I${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/ncursesw"
        elif [ -d "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/ncurses" ]
        then
          CPPFLAGS+=" -I${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/ncurses"
        else
          echo "No include/ncurses folder"
          exit 1
        fi
      fi

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
          echo "Running libedit configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libedit_src_folder_name}/configure" --help
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

          config_options+=("--disable-nls")

          # config_options+=("--disable-shared")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${libedit_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libedit_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libedit_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running libedit make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libedit_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libedit_src_folder_name}" \
        "${libedit_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libedit_stamp_file_path}"

  else
    echo "Library libedit already installed"
  fi
}

# -----------------------------------------------------------------------------
