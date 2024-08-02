# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# https://www.gnu.org/software/libunistring/
# https://ftp.gnu.org/gnu/libunistring/
# https://ftp.gnu.org/gnu/libunistring/libunistring-0.9.10.tar.xz

# https://gitlab.archlinux.org/archlinux/packaging/packages/libunistring/-/blob/main/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/libunistring/files/PKGBUILD

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/l/libunistring.rb

# 2018-05-25 "0.9.10"
# 2022-10-16 "1.1"

# -----------------------------------------------------------------------------

function libunistring_build()
{

  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local libunistring_version="$1"

  local libunistring_src_folder_name="libunistring-${libunistring_version}"

  local libunistring_archive="${libunistring_src_folder_name}.tar.xz"
  local libunistring_url="https://ftp.gnu.org/gnu/libunistring/${libunistring_archive}"

  local libunistring_folder_name="${libunistring_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libunistring_folder_name}"

  local libunistring_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${libunistring_folder_name}-installed"
  if [ ! -f "${libunistring_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libunistring_url}" "${libunistring_archive}" \
      "${libunistring_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libunistring_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${libunistring_folder_name}"

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
          echo "Running libunistring configure..."

          if is_development
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libunistring_src_folder_name}/configure" --help
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
          if is_development
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          # DO NOT USE, on macOS the LC_RPATH looses GCC references.
          # config_options+=("--enable-relocatable")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${libunistring_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libunistring_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libunistring_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running libunistring make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if with_strip
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        # It takes too long.
        if false # [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libunistring_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libunistring_src_folder_name}" \
        "${libunistring_folder_name}"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libunistring_stamp_file_path}"

  else
    echo "Library libunistring already installed"
  fi
}

# -----------------------------------------------------------------------------
