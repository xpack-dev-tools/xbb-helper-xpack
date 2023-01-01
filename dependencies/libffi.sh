# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# http://www.sourceware.org/libffi/
# ftp://sourceware.org/pub/libffi/
# https://github.com/libffi/libffi
# https://github.com/libffi/libffi/releases
# https://github.com/libffi/libffi/releases/download/v3.4.2/libffi-3.4.2.tar.gz
# https://github.com/libffi/libffi/archive/v3.2.1.tar.gz

# https://github.com/archlinux/svntogit-packages/blob/packages/libffi/trunk/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/libffi/files/PKGBUILD
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libffi-git
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-libffi

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/libffi.rb

# 12-Nov-2014, "3.2.1"
# 23 Nov 2019, "3.3"
# 29 Jun 2021, "3.4.2"
# 19 Sep 2022, "3.4.3"

# -----------------------------------------------------------------------------

function libffi_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local libffi_version="$1"

  local libffi_src_folder_name="libffi-${libffi_version}"

  local libffi_archive="${libffi_src_folder_name}.tar.gz"
  local libffi_url="https://github.com/libffi/libffi/releases/download/v${libffi_version}/${libffi_archive}"

  local libffi_folder_name="${libffi_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libffi_folder_name}"

  local libffi_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${libffi_folder_name}-installed"
  if [ ! -f "${libffi_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libffi_url}" "${libffi_archive}" \
      "${libffi_src_folder_name}"

    (
      if [ ! -x "${XBB_SOURCES_FOLDER_PATH}/${libffi_src_folder_name}/configure" ]
      then

        cd "${XBB_SOURCES_FOLDER_PATH}/${libffi_src_folder_name}"

        xbb_activate_dependencies_dev

        run_verbose bash ${DEBUG} "autogen.sh"

      fi
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libffi_folder_name}/autogen-output-$(ndate).txt"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libffi_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${libffi_folder_name}"

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
          echo "Running libffi configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libffi_src_folder_name}/configure" --help
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

          config_options+=("--enable-pax_emutramp") # Arch

          config_options+=("--disable-static") # Arch
          config_options+=("--disable-multi-os-directory") # Arch
          config_options+=("--disable-exec-static-tramp") # Arch

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${libffi_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libffi_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libffi_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running libffi make..."

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

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libffi_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libffi_src_folder_name}" \
        "${libffi_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libffi_stamp_file_path}"

  else
    echo "Library libffi already installed"
  fi
}

# -----------------------------------------------------------------------------
