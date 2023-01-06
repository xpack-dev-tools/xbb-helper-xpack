# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# http://www.intra2net.com/en/developer/libftdi/download.php
# https://www.intra2net.com/en/developer/libftdi/download/libftdi1-1.4.tar.bz2

# 1.2 (no date)
# libftdi_version="1.2" # +PATCH!
# 1.4 +PATCH
# 1.5 +PATCH

# -----------------------------------------------------------------------------

function libftdi_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local libftdi_version="$1"

  local libftdi_src_folder_name="libftdi1-${libftdi_version}"

  local libftdi_archive="${libftdi_src_folder_name}.tar.bz2"

  libftdi_url="http://www.intra2net.com/en/developer/libftdi/download/${libftdi_archive}"

  local libftdi_folder_name="${libftdi_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libftdi_folder_name}"

  local libftdi_patch="libftdi1-${libftdi_version}.patch"
  local libftdi_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-libftdi-${libftdi_version}-installed"
  if [ ! -f "${libftdi_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libftdi_url}" "${libftdi_archive}" \
      "${libftdi_src_folder_name}" \
      "${libftdi_patch}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libftdi_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${libftdi_folder_name}"

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

      (
        xbb_show_env_develop

        echo
        echo "Running libftdi configure..."

        config_options=()

        if [ "${XBB_IS_DEVELOP}" == "y" ]
        then
          config_options+=("-LH") # display help for each variable
        fi
        config_options+=("-G" "Ninja")

        config_options+=("-DCMAKE_INSTALL_PREFIX=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")

        config_options+=("-DPKG_CONFIG_EXECUTABLE=${PKG_CONFIG}")
        config_options+=("-DBUILD_TESTS:BOOL=off")
        config_options+=("-DEXAMPLES:BOOL=off")
        config_options+=("-DDOCUMENTATION:BOOL=off")
        config_options+=("-DFTDI_EEPROM:BOOL=off")
        config_options+=("-DPYTHON_BINDINGS:BOOL=off")

        if [ "${XBB_HOST_PLATFORM}" == "win32" ]
        then
          config_options+=("-DCMAKE_TOOLCHAIN_FILE=${XBB_SOURCES_FOLDER_PATH}/${libftdi_src_folder_name}/cmake/Toolchain-${XBB_TARGET_TRIPLET}.cmake")
          config_options+=("-DLIBUSB_INCLUDE_DIR=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/libusb-1.0")
          config_options+=("-DLIBUSB_LIBRARIES=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/libusb-1.0.a")
          config_options+=("-DFTDIPP:BOOL=off")
        elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
        then
          config_options+=("-DCMAKE_OSX_DEPLOYMENT_TARGET=${XBB_MACOSX_DEPLOYMENT_TARGET}")
        fi

        run_verbose cmake \
          "${config_options[@]}" \
          "${XBB_SOURCES_FOLDER_PATH}/${libftdi_src_folder_name}"

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libftdi_folder_name}/configure-output-$(ndate).txt"

      (
        echo
        echo "Running libftdi make..."

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

        run_verbose cmake \
          --build . \
          --config "${build_type}" \
          -- \
          install

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libftdi_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${libftdi_src_folder_name}" \
        "${libftdi_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libftdi_stamp_file_path}"

  else
    echo "Library libftdi already installed"
  fi
}

# -----------------------------------------------------------------------------
