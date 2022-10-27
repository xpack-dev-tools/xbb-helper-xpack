# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# Required by Windows.
function build_libusb_w32()
{
  # https://sourceforge.net/projects/libusb-win32/files/libusb-win32-releases/
  # 2012-01-17, 1.2.6.0
  # libusb_w32_version="1.2.6.0" # +PATCH!

  local libusb_w32_version="$1"

  local libusb_w32_prefix="libusb-win32"
  local libusb_w32_prefix_version="${libusb_w32_prefix}-${libusb_w32_version}"

  local libusb_w32_src_folder_name="${libusb_w32_prefix}-src-${libusb_w32_version}"

  local libusb_w32_archive="${libusb_w32_src_folder_name}.zip"
  local libusb_w32_url="http://sourceforge.net/projects/libusb-win32/files/libusb-win32-releases/${libusb_w32_version}/${libusb_w32_archive}"

  local libusb_w32_folder_name="${libusb_w32_prefix}-${libusb_w32_version}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libusb_w32_folder_name}"

  local libusb_w32_patch="libusb-win32-${libusb_w32_version}-mingw-w64.patch"

  local libusb_w32_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${libusb_w32_folder_name}-installed"
  if [ ! -f "${libusb_w32_stamp_file_path}" ]
  then

    echo
    echo "libusb-w32 in-source building..."

    mkdir -pv "${XBB_BUILD_FOLDER_PATH}"
    cd "${XBB_BUILD_FOLDER_PATH}"

    if [ ! -d "${XBB_BUILD_FOLDER_PATH}/${libusb_w32_folder_name}" ]
    then
      cd "${XBB_BUILD_FOLDER_PATH}"

      # Do not add the patch here, it must be done after dos2unix.
      download_and_extract "${libusb_w32_url}" "${libusb_w32_archive}" \
        "${libusb_w32_src_folder_name}"

      if [ "${libusb_w32_src_folder_name}" != "${libusb_w32_folder_name}" ]
      then
        mv -v "${libusb_w32_src_folder_name}" "${libusb_w32_folder_name}"
      fi

      cd "${XBB_BUILD_FOLDER_PATH}/${libusb_w32_folder_name}"

      # Patch from:
      # https://gitorious.org/jtag-tools/openocd-mingw-build-scripts

      # The conversions are needed to avoid errors like:
      # 'Hunk #1 FAILED at 31 (different line endings).'
      run_verbose dos2unix src/install.c
      run_verbose dos2unix src/install_filter_win.c
      run_verbose dos2unix src/registry.c

      if [ -f "${helper_folder_path}/patches/${libusb_w32_patch}" ]
      then
        run_verbose patch -p0 < "${helper_folder_path}/patches/${libusb_w32_patch}"
      fi
    fi

    (
      echo
      echo "Running libusb-win32 make..."

      cd "${XBB_BUILD_FOLDER_PATH}/${libusb_w32_folder_name}"

      xbb_activate_installed_dev

      # Build.
      (
        CPPFLAGS="${XBB_CPPFLAGS}"
        CFLAGS="${XBB_CFLAGS_NO_W}"
        CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

        LDFLAGS="${XBB_LDFLAGS_LIB}"

        export CPPFLAGS
        export CFLAGS
        export CXXFLAGS
        export LDFLAGS

        xbb_show_env_develop

        run_verbose make \
          host_prefix=${XBB_CROSS_COMPILE_PREFIX} \
          host_prefix_x86=i686-w64-mingw32 \
          dll

        # Manually install, could not find a make target.
        mkdir -pv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin"

        # Skipping it does not remove the reference from openocd, so for the
        # moment it is preserved.
        cp -v "${XBB_BUILD_FOLDER_PATH}/${libusb_w32_folder_name}/libusb0.dll" \
          "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin"

        mkdir -pv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib"
        cp -v "${XBB_BUILD_FOLDER_PATH}/${libusb_w32_folder_name}/libusb.a" \
          "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib"

        mkdir -pv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/pkgconfig"
        sed -e "s|XXX|${XBB_LIBRARIES_INSTALL_FOLDER_PATH}|" \
          "${helper_folder_path}/pkgconfig/${libusb_w32_prefix_version}.pc" \
          > "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib/pkgconfig/libusb.pc"

        mkdir -pv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/libusb"
        cp -v "${XBB_BUILD_FOLDER_PATH}/${libusb_w32_folder_name}/src/lusb0_usb.h" \
          "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/libusb/usb.h"

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libusb_w32_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_BUILD_FOLDER_PATH}/${libusb_w32_folder_name}" \
        "${libusb_w32_folder_name}"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libusb_w32_stamp_file_path}"

  else
    echo "Library libusb-w32 already installed."
  fi
}

# -----------------------------------------------------------------------------
