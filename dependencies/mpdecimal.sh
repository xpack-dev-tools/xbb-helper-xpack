# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.bytereef.org/mpdecimal/index.html
# https://www.bytereef.org/mpdecimal/download.html
# https://www.bytereef.org/software/mpdecimal/releases/mpdecimal-2.4.2.tar.gz

# https://github.com/archlinux/svntogit-packages/blob/packages/mpdecimal/trunk/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/mpdecimal/files/PKGBUILD

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/mpdecimal.rb

# 2016-02-28, "2.4.2"
# 2020-06-28, "2.5.0"
# 2021-01-28, "2.5.1"

# -----------------------------------------------------------------------------

function mpdecimal_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local mpdecimal_version="$1"

  local mpdecimal_src_folder_name="mpdecimal-${mpdecimal_version}"

  local mpdecimal_archive="${mpdecimal_src_folder_name}.tar.gz"
  local mpdecimal_url="https://www.bytereef.org/software/mpdecimal/releases/${mpdecimal_archive}"

  local mpdecimal_folder_name="${mpdecimal_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${mpdecimal_folder_name}"

  local mpdecimal_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${mpdecimal_folder_name}-installed"
  if [ ! -f "${mpdecimal_stamp_file_path}" ]
  then

    echo
    echo "mpdecimal in-source building..."

    mkdir -pv "${XBB_BUILD_FOLDER_PATH}"
    cd "${XBB_BUILD_FOLDER_PATH}"

    if [ ! -d "${XBB_BUILD_FOLDER_PATH}/${mpdecimal_folder_name}" ]
    then
      download_and_extract "${mpdecimal_url}" "${mpdecimal_archive}" \
        "${mpdecimal_src_folder_name}"

      if [ "${mpdecimal_src_folder_name}" != "${mpdecimal_folder_name}" ]
      then
        mv -v "${mpdecimal_src_folder_name}" "${mpdecimal_folder_name}"
      fi
    fi

    (
      cd "${XBB_BUILD_FOLDER_PATH}/${mpdecimal_src_folder_name}"

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
      export LD=${CC} # Does not like the default ld

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running mpdecimal configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "configure" --help
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

          # C++ tests fail on Linux.
          # config_options+=("--enable-cxx")
          config_options+=("--disable-cxx")

          run_verbose bash ${DEBUG} "configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${mpdecimal_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${mpdecimal_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running mpdecimal make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        # Has no install-strip
        run_verbose make install

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          if [ "${XBB_HOST_PLATFORM}" == "linux" ]
          then
            # TODO
            # Fails shared on darwin
            run_verbose make -j1 check
          fi
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${mpdecimal_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_BUILD_FOLDER_PATH}/${mpdecimal_folder_name}" \
        "${mpdecimal_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${mpdecimal_stamp_file_path}"

  else
    echo "Library mpdecimal already installed"
  fi
}

# -----------------------------------------------------------------------------
