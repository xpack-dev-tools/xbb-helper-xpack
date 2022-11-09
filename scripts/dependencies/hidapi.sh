# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function build_hidapi()
{
  # Oct 26, 2011, "0.7.0"

  # https://github.com/signal11/hidapi/archive/hidapi-0.8.0-rc1.zip
  # Oct 7, 2013, "0.8.0-rc1", latest on signal11's repository

  # https://github.com/libusb/hidapi/releases
  # https://github.com/libusb/hidapi/archive/hidapi-0.9.0.zip
  # Jun 19 2019 "hidapi-0.9.0", maintained releases by libusb

  # https://github.com/archlinux/svntogit-community/blob/packages/hidapi/trunk/PKGBUILD
  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/hidapi.rb

  # Nov 24, 2020, 0.10.1
  # 27 Sep 2021, "0.11.0"
  # 23 Dec 2021, "0.11.1"
  # 3 Jan, 2022, "0.11.2"
  # 25 May 2022, "0.12.0"

  local hidapi_version="$1"

  local hidapi_src_folder_name="hidapi-hidapi-${hidapi_version}"

  local hidapi_archive="hidapi-${hidapi_version}.zip"
  local hidapi_url="https://github.com/libusb/hidapi/archive/${hidapi_archive}"

  local hidapi_folder_name="${hidapi_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${hidapi_folder_name}"

  local hidapi_patch_file_name="hidapi-${hidapi_version}.patch"
  local hidapi_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-hidapi-${hidapi_version}-installed"
  if [ ! -f "${hidapi_stamp_file_path}" ]
  then

    (
      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then

        echo
        echo "hidapi in-source building..."

        mkdir -pv "${XBB_BUILD_FOLDER_PATH}"
        cd "${XBB_BUILD_FOLDER_PATH}"

        if [ ! -d "${XBB_BUILD_FOLDER_PATH}/${hidapi_folder_name}" ]
        then
          download_and_extract "${hidapi_url}" "${hidapi_archive}" \
            "${hidapi_src_folder_name}" "${hidapi_patch_file_name}"

          if [ "${hidapi_src_folder_name}" != "${hidapi_folder_name}" ]
          then
            mv -v "${hidapi_src_folder_name}" "${hidapi_folder_name}"
          fi
        fi

        hidapi_OBJECT="hid.o"
        hidapi_A="libhid.a"

        cd "${XBB_BUILD_FOLDER_PATH}/${hidapi_folder_name}/windows"

        CPPFLAGS="${XBB_CPPFLAGS}"
        CFLAGS="${XBB_CFLAGS_NO_W}"
        CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

        LDFLAGS="${XBB_LDFLAGS_LIB}"

        export CPPFLAGS
        export CFLAGS
        export CXXFLAGS
        export LDFLAGS

        run_verbose make -f Makefile.mingw \
          CC=${XBB_TARGET_TRIPLET}-gcc \
          "${hidapi_OBJECT}"

        # Make just compiles the file. Create the archive and convert it to library.
        # No dynamic/shared libs involved.
        cd "${XBB_BUILD_FOLDER_PATH}/${hidapi_folder_name}/windows"
        run_verbose ar -r  "${hidapi_A}" "${hidapi_OBJECT}"
        run_verbose ${XBB_TARGET_TRIPLET}-ranlib "${hidapi_A}"

        mkdir -pv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib"
        run_verbose cp -v "${hidapi_A}" \
          "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib"

        mkdir -pv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/pkgconfig"
        sed -e "s|XXX|${XBB_LIBRARIES_INSTALL_FOLDER_PATH}|" \
          "${helper_folder_path}/pkgconfig/hidapi-${hidapi_version}-windows.pc" \
          > "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/pkgconfig/hidapi.pc"

        cd "${XBB_BUILD_FOLDER_PATH}/${hidapi_folder_name}"
        mkdir -pv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/hidapi"
        run_verbose cp -v "hidapi/hidapi.h" \
          "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/hidapi"

        find "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}" \
          -name 'libhidapi-hidraw.la' \
          -exec rm -v '{}' ';'
        # rm -f "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}"/lib*/libhidapi-hidraw.la

        copy_license \
          "${XBB_BUILD_FOLDER_PATH}/${hidapi_folder_name}" \
          "${hidapi_folder_name}"

      elif [ "${XBB_HOST_PLATFORM}" == "linux" -o "${XBB_HOST_PLATFORM}" == "darwin" ]
      then

        mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
        cd "${XBB_SOURCES_FOLDER_PATH}"

        download_and_extract "${hidapi_url}" "${hidapi_archive}" \
          "${hidapi_src_folder_name}" "${hidapi_patch_file_name}"

        mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${hidapi_folder_name}"
        cd "${XBB_BUILD_FOLDER_PATH}/${hidapi_folder_name}"

        xbb_activate_installed_dev

        if [ "${XBB_HOST_PLATFORM}" == "linux" ]
        then
          copy_libudev

          export LIBS="-liconv"
        elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
        then
          : # With GCC: error: unknown type name ‘dispatch_block_t’
        fi

        CPPFLAGS="${XBB_CPPFLAGS}"
        CFLAGS="${XBB_CFLAGS_NO_W}"
        CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

        LDFLAGS="${XBB_LDFLAGS_LIB}"
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

        (
          xbb_show_env_develop

          echo
          echo "Running hidapi cmake..."

          config_options=()

          config_options+=("-G" "Ninja")

          config_options+=("-DCMAKE_INSTALL_PREFIX=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          config_options+=("-DCMAKE_VERBOSE_MAKEFILE=ON")
          config_options+=("-DCMAKE_BUILD_TYPE=${build_type}")

          if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then
            # Otherwise it'll generate two -mmacosx-version-min
            config_options+=("-DCMAKE_OSX_DEPLOYMENT_TARGET=${XBB_MACOSX_DEPLOYMENT_TARGET}")
          fi

          # The mingw build also requires RC pointing to windres.
          run_verbose cmake \
            "${config_options[@]}" \
            \
            "${XBB_SOURCES_FOLDER_PATH}/${hidapi_src_folder_name}"

        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${hidapi_folder_name}/cmake-output-$(ndate).txt"

        (
          echo
          echo "Running cmake build..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose cmake \
              --build . \
              --parallel ${XBB_JOBS} \
              --verbose \
              --config "${build_type}"
          else
            run_verbose cmake \
              --build . \
              --parallel ${XBB_JOBS} \
              --config "${build_type}"
          fi

          echo
          echo "Running cmake install..."

          run_verbose cmake \
            --build . \
            --config "${build_type}" \
            -- \
            install

        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${hidapi_folder_name}/build-output.txt"

        (
          cd "${XBB_BUILD_FOLDER_PATH}"

          copy_cmake_logs "${hidapi_folder_name}"
        )

        find "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}" \
          -name 'libhidapi-hidraw.la' \
          -exec rm -v '{}' ';'
        # rm -f "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}"/lib*/libhidapi-hidraw.la

        copy_license \
          "${XBB_SOURCES_FOLDER_PATH}/${hidapi_src_folder_name}" \
          "${hidapi_folder_name}"

      fi
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${hidapi_stamp_file_path}"

  else
    echo "Library hidapi already installed."
  fi
}

# -----------------------------------------------------------------------------
