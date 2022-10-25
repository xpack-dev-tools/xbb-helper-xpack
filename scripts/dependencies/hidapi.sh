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

    if false
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
    else
      mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
      cd "${XBB_SOURCES_FOLDER_PATH}"

      download_and_extract "${hidapi_url}" "${hidapi_archive}" \
        "${hidapi_src_folder_name}" "${hidapi_patch_file_name}"
    fi

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${hidapi_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${hidapi_folder_name}"

      xbb_activate_installed_dev

      if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
      then

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
          CC=${XBB_CROSS_COMPILE_PREFIX}-gcc \
          "${hidapi_OBJECT}"

        # Make just compiles the file. Create the archive and convert it to library.
        # No dynamic/shared libs involved.
        ar -r  "${hidapi_A}" "${hidapi_OBJECT}"
        ${XBB_CROSS_COMPILE_PREFIX}-ranlib "${hidapi_A}"

        mkdir -pv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib"
        cp -v "${hidapi_A}" \
          "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib"

        mkdir -pv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/pkgconfig"
        sed -e "s|XXX|${XBB_LIBRARIES_INSTALL_FOLDER_PATH}|" \
          "${XBB_BUILD_GIT_PATH}/pkgconfig/hidapi-${hidapi_version}-windows.pc" \
          > "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/pkgconfig/hidapi.pc"

        mkdir -pv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/hidapi"
        cp -v "${XBB_SOURCES_FOLDER_PATH}/${hidapi_folder_name}/hidapi/hidapi.h" \
          "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/hidapi"

      elif [ "${XBB_TARGET_PLATFORM}" == "linux" -o "${XBB_TARGET_PLATFORM}" == "darwin" ]
      then

        if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
        then
          copy_libudev

          export LIBS="-liconv"
        elif [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
        then
          : # With GCC: error: unknown type name ‘dispatch_block_t’
        fi

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

        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running hidapi cmake..."

          config_options=()

          config_options+=("-G" "Ninja")

          config_options+=("-DCMAKE_INSTALL_PREFIX=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

          config_options+=("-DCMAKE_VERBOSE_MAKEFILE=ON")
          config_options+=("-DCMAKE_BUILD_TYPE=${build_type}")

          if [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
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

      fi

      rm -f "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}"/lib*/libhidapi-hidraw.la

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${hidapi_src_folder_name}" \
        "${hidapi_folder_name}"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${hidapi_stamp_file_path}"

  else
    echo "Library hidapi already installed."
  fi
}

function copy_libudev()
{
  (
    if [ -f "/usr/include/libudev.h" ]
    then
      cp -v "/usr/include/libudev.h" "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include"
    else
      echo "No libudev.h"
      exit 1
    fi

    local find_path="$(find /lib* -name 'libudev.so.?' | sort -u | sed -n 1p)"
    if [ ! -z "${find_path}" ]
    then
      copy_libudev_with_links "${find_path}" "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib"
    fi

    find_path="$(find /usr/lib* -name 'libudev.so' | sort -u | sed -n 1p)"
    if [ ! -z "${find_path}" ]
    then
      copy_libudev_with_links "${find_path}" "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib"
    fi

    local find_pc_path="$(find /usr/lib* -name 'libudev.pc')"
    if [ ! -z "${find_pc_path}" ]
    then
      cp -v "${find_pc_path}" "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/pkgconfig"
    else
      echo "No libudev.pc"
      exit 1
    fi
  )
}

function copy_libudev_with_links()
{
  local from_file_path="$1"
  local dest_folder_path="$2"

  if [ -L "${from_file_path}" ]
  then
    local link_file_path="$(readlink "${from_file_path}")"
    if [ "${link_file_path}" == "$(basename "${link_file_path}")" ]
    then
      copy_libudev_with_links "$(dirname "${from_file_path}")/${link_file_path}" "${dest_folder_path}"
    else
      copy_libudev_with_links "${link_file_path}" "${dest_folder_path}"
    fi
    (
      cd "${dest_folder_path}"
      if [ ! -L "$(basename "${from_file_path}")" ]
      then
        ln -sv "$(basename "${link_file_path}")" "$(basename "${from_file_path}")"
      fi
    )
  else
    local dest_file_path="${dest_folder_path}/$(basename "${from_file_path}")"
    if [ ! -f "${dest_file_path}" ]
    then
      cp -v "${from_file_path}" "${dest_folder_path}"
    fi

    # Hack to get libudev.so in line with the 'all rpath' policy,
    # since on arm 32-bit it is checked.
    # Manually add $ORIGIN to libudev.so (fingers crossed!).
    run_verbose ${PATCHELF:-$(which patchelf || echo patchelf)} --force-rpath --set-rpath "\$ORIGIN" "${dest_file_path}"
  fi
}

# -----------------------------------------------------------------------------
