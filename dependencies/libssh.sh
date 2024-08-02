# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# C library SSHv1/SSHv2 client and server protocols
# https://www.libssh.org/
# https://www.libssh.org/files/
# https://www.libssh.org/files/0.9/libssh-0.9.6.tar.xz

# https://gitlab.archlinux.org/archlinux/packaging/packages/libssh/-/blob/main/PKGBUILD
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-libssh

# https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-libssh/PKGBUILD

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/l/libssh.rb

# 2021-08-26 "0.9.6"
# 2022-08-30, "0.10.1"

# -----------------------------------------------------------------------------

function libssh_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local libssh_version="$1"
  local libssh_major_version=$(xbb_get_version_major "${libssh_version}")
  local libssh_minor_version=$(xbb_get_version_minor "${libssh_version}")
  local libssh_major_minor_version="${libssh_major_version}.${libssh_minor_version}"

  local libssh_src_folder_name="libssh-${libssh_version}"

  local libssh_archive="${libssh_src_folder_name}.tar.xz"
  local libssh_url="https://www.libssh.org/files/${libssh_major_minor_version}/${libssh_archive}"

  local libssh_folder_name="${libssh_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libssh_folder_name}"

  local libssh_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${libssh_folder_name}-installed"
  if [ ! -f "${libssh_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libssh_url}" "${libssh_archive}" \
      "${libssh_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libssh_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${libssh_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"

      CMAKE=$(which cmake)

      xbb_adjust_ldflags_rpath

      # if [ "${XBB_HOST_PLATFORM}" == "linux" ]
      # then
      #   # export LIBS=" -lpthread -ldl -lrt"
      #   LDFLAGS+=" -lpthread -ldl -lrt"
      # fi

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

          if is_development
          then
            config_options+=("-LAH") # display help for each variable
          fi
          config_options+=("-G" "Ninja")

          # TODO: add separate BINS/LIBS.
          config_options+=("-DCMAKE_INSTALL_PREFIX=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          config_options+=("-DBUILD_STATIC_LIB=ON")
          config_options+=("-DWITH_SYMBOL_VERSIONING=OFF")

          # From Arch.
          config_options+=("-DWITH_GSSAPI=OFF")

          # Since CMake insists on picking the system one.
          config_options+=("-DWITH_ZLIB=OFF")

          if [ "${XBB_HOST_PLATFORM}" == "linux" ]
          then
            # On Linux
            # undefined reference to `__stack_chk_guard'
            config_options+=("-DWITH_STACK_PROTECTOR=OFF")
            config_options+=("-DWITH_STACK_PROTECTOR_STRONG=OFF")
            # config_options+=("-DWITH_STACK_CLASH_PROTECTION=OFF")
          elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then
            if [ ! -z "${MACOSX_DEPLOYMENT_TARGET:-""}" ]
            then
              config_options+=("-DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET}")
            fi
          fi

          run_verbose "${CMAKE}" \
            "${config_options[@]}" \
            \
            "${XBB_SOURCES_FOLDER_PATH}/${libssh_src_folder_name}"

        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libssh_folder_name}/cmake-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running libssh make..."

        if is_development
        then
          run_verbose "${CMAKE}" \
            --build . \
            --parallel ${XBB_JOBS} \
            --verbose \
            --config "${build_type}"
        else
          run_verbose "${CMAKE}" \
            --build . \
            --parallel ${XBB_JOBS} \
            --config "${build_type}"
        fi

        run_verbose "${CMAKE}" \
          --build . \
          --config "${build_type}" \
          -- \
          install

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libssh_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libssh_src_folder_name}" \
        "${libssh_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libssh_stamp_file_path}"

  else
    echo "Library libssh already installed"
  fi
}

# -----------------------------------------------------------------------------
