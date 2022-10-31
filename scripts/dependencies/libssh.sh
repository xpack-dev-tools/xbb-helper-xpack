# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function build_libssh()
{
  # C library SSHv1/SSHv2 client and server protocols
  # https://www.libssh.org/
  # https://www.libssh.org/files/
  # https://www.libssh.org/files/0.9/libssh-0.9.6.tar.xz

  # https://github.com/archlinux/svntogit-packages/blob/packages/libssh/trunk/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-libssh

  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-libssh/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/libssh.rb

  # 2021-08-26 "0.9.6"
  # 2022-08-30, "0.10.1"

  local libssh_version="$1"
  local libssh_major_minor_version="$(echo ${libssh_version} | sed -e 's|\([0-9][0-9]*\)\.\([0-9][0-9]*\)\.[0-9].*|\1.\2|')"

  local libssh_src_folder_name="libssh-${libssh_version}"

  local libssh_archive="${libssh_src_folder_name}.tar.xz"
  local libssh_url="https://www.libssh.org/files/${libssh_major_minor_version}/${libssh_archive}"

  local libssh_folder_name="${libssh_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libssh_folder_name}"

  local libssh_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${libssh_folder_name}-installed"
  if [ ! -f "${libssh_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libssh_url}" "${libssh_archive}" \
      "${libssh_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libssh_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${libssh_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        xbb_activate_cxx_rpath
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      local build_type
      if [ "${XBB_IS_DEBUG}" == "y" ]
      then
        build_type=Debug
      else
        build_type=Release
      fi

      if [ ! -f "CMakeCache.txt" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running libssh cmake..."

          config_options=()

          # TODO: add separate BINS/LIBS.
          config_options+=("-DCMAKE_INSTALL_PREFIX=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          config_options+=("-DBUILD_STATIC_LIB=ON")
          config_options+=("-DWITH_SYMBOL_VERSIONING=OFF")

          # From Arch.
          config_options+=("-DWITH_GSSAPI=OFF")

          # Since CMake insists on picking the system one.
          config_options+=("-DWITH_ZLIB=OFF")

          if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
          then
            # On Linux
            # undefined reference to `__stack_chk_guard'
            config_options+=("-DWITH_STACK_PROTECTOR=OFF")
            config_options+=("-DWITH_STACK_PROTECTOR_STRONG=OFF")
            # config_options+=("-DWITH_STACK_CLASH_PROTECTION=OFF")
          elif [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
          then
            # Otherwise it'll generate two -mmacosx-version-min
            config_options+=("-DCMAKE_OSX_DEPLOYMENT_TARGET=${XBB_MACOSX_DEPLOYMENT_TARGET}")
          fi

          run_verbose cmake \
            "${config_options[@]}" \
            \
            "${XBB_SOURCES_FOLDER_PATH}/${libssh_src_folder_name}"

        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libssh_folder_name}/cmake-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running libssh make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        run_verbose make install

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libssh_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libssh_src_folder_name}" \
        "${libssh_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libssh_stamp_file_path}"

  else
    echo "Library libssh already installed."
  fi
}

# -----------------------------------------------------------------------------
