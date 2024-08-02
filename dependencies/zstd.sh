# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# Zstandard is a real-time compression algorithm
# https://facebook.github.io/zstd/
# https://github.com/facebook/zstd/releases
# https://github.com/facebook/zstd/archive/v1.4.4.tar.gz
# https://github.com/facebook/zstd/releases/download/v1.5.0/zstd-1.5.0.tar.gz

# https://gitlab.archlinux.org/archlinux/packaging/packages/zstd/-/blob/main/PKGBUILD
# https://archlinuxarm.org/packages/aarch64/zstd/files/PKGBUILD

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/z/zstd.rb

# 5 Nov 2019 "1.4.4"
# 3 Mar 2021 "1.4.9"
# 14 May 2021 "1.5.0"
# 20 Jan 2022 "1.5.2"

# -----------------------------------------------------------------------------

function zstd_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local zstd_version="$1"

  # The folder name as resulted after being extracted from the archive.
  local zstd_src_folder_name="zstd-${zstd_version}"

  local zstd_archive="${zstd_src_folder_name}.tar.gz"
  # GitHub release archive.
  local zstd_github_archive="v${zstd_version}.tar.gz"
  local zstd_github_url="https://github.com/facebook/zstd/archive/${zstd_github_archive}"

  # The folder name for build, licenses, etc.
  local zstd_folder_name="${zstd_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${zstd_folder_name}"

  local zstd_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${zstd_folder_name}-installed"
  if [ ! -f "${zstd_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${zstd_github_url}" "${zstd_archive}" \
      "${zstd_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${zstd_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${zstd_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      if [ "${XBB_HOST_PLATFORM}" == "linux" ]
      then
        CFLAGS+=' -ffat-lto-objects' # Arch
        CXXFLAGS+=' -ffat-lto-objects' # Arch
      fi

      LDFLAGS="${XBB_LDFLAGS_LIB}"

      CMAKE="$(which cmake)"

      xbb_adjust_ldflags_rpath

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
          echo "Running zstd cmake..."

          config_options=()

          if is_development
          then
            config_options+=("-LAH") # display help for each variable
          fi
          config_options+=("-G" "Ninja")

          config_options+=("-DCMAKE_INSTALL_PREFIX=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          # config_options+=("-DZSTD_BUILD_CONTRIB=ON") # Arch, MD
          config_options+=("-DZSTD_BUILD_CONTRIB=OFF")

          config_options+=("-DZSTD_BUILD_PROGRAMS=OFF")

          # config_options+=("-DZSTD_BUILD_STATIC=OFF") # Arch
          config_options+=("-DZSTD_BUILD_STATIC=ON")

          if [ "${XBB_WITH_TESTS}" == "y" ]
          then
            config_options+=("-DZSTD_BUILD_TESTS=ON")
          fi

          config_options+=("-DZSTD_LEGACY_SUPPORT=ON") # HB
          config_options+=("-DZSTD_ZLIB_SUPPORT=ON") # HB
          config_options+=("-DZSTD_LZMA_SUPPORT=ON") # HB
          # config_options+=("-DZSTD_LZ4_SUPPORT=ON") # HB

          config_options+=("-DZSTD_PROGRAMS_LINK_SHARED=ON") # Arch, HB

          if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then
            if [ ! -z "${MACOSX_DEPLOYMENT_TARGET:-""}" ]
            then
              config_options+=("-DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET}")
            fi

            # config_options+=("-DCMAKE_INSTALL_RPATH=${XBB_LIBRARY_PATH}")
          elif [ "${XBB_HOST_PLATFORM}" == "win32" ]
          then
            config_options+=("-DCMAKE_SYSTEM_NAME=Windows")
          fi

          config_options+=("-DCMAKE_SKIP_RPATH=ON")
          config_options+=("-DCMAKE_SKIP_INSTALL_RPATH=ON")

          run_verbose "${CMAKE}" \
            "${config_options[@]}" \
            \
            "${XBB_SOURCES_FOLDER_PATH}/${zstd_src_folder_name}/build/cmake"

          if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then
            # Replace the relative rpath name with the absolute path.
            run_verbose sed -i.bak \
              -e "s|INSTALLNAME_DIR = @rpath/|INSTALLNAME_DIR = ${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/|" \
              "${XBB_BUILD_FOLDER_PATH}/${zstd_folder_name}/build.ninja"
          elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
          then
            # Replace the relative rpath name with the absolute path.
            run_verbose sed -i.bak \
              -e "s|INSTALLNAME_DIR = @rpath/|INSTALLNAME_DIR = |" \
              "${XBB_BUILD_FOLDER_PATH}/${zstd_folder_name}/build.ninja"
          elif [ "${XBB_HOST_PLATFORM}" == "win32" ]
          then
            : # nothing to patch for Windows.
          else
            # Maybe add win32?
            echo "Unsupported XBB_HOST_PLATFORM=${XBB_HOST_PLATFORM} in ${FUNCNAME[0]}()"
            exit 1
          fi

          if [ -f "${XBB_BUILD_FOLDER_PATH}/${zstd_folder_name}/build.ninja.bak" ]
          then
            run_verbose diff \
              "${XBB_BUILD_FOLDER_PATH}/${zstd_folder_name}/build.ninja.bak" \
              "${XBB_BUILD_FOLDER_PATH}/${zstd_folder_name}/build.ninja" \
              || true
          fi

        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${zstd_folder_name}/cmake-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running zstd build..."

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

        # It takes too long, run only the first test (which also takes a few minutes)
        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose ctest \
            -V \
            --tests-regex 'fullbench'
        fi

        (
          # The install procedure runs some resulted executables, which require
          # the libssl and libcrypt libraries from XBB.
          # xbb_activate_libs

          echo
          echo "Running zstd install..."

          run_verbose "${CMAKE}" \
            --build . \
            --config "${build_type}" \
            -- \
            install

        )
      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${zstd_folder_name}/build-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${zstd_src_folder_name}" \
        "${zstd_folder_name}"

      (
        run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}"

        copy_cmake_files "${zstd_folder_name}"
      )

    )

    (
      zstd_test
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${zstd_folder_name}/test-output-$(ndate).txt"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${zstd_stamp_file_path}"

  else
    echo "Library zstd already installed"
  fi
}

function zstd_test()
{
  (
    echo
    echo "Checking the zstd shared library..."

    show_host_libs "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libzstd.${XBB_HOST_SHLIB_EXT}"
  )
}
# -----------------------------------------------------------------------------
