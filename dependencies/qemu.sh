# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# Stick to upstream as long as possible.
# https://github.com/qemu/qemu/tags

# The second choice is the xPack fork.
# https://github.com/xpack-dev-tools/qemu

# https://gitlab.archlinux.org/archlinux/packaging/packages/qemu/-/blob/main/PKGBUILD
# https://gitlab.archlinux.org/archlinux/packaging/packages/libvirt/-/blob/main/PKGBUILD

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/q/qemu.rb

# https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-qemu/PKGBUILD

# -----------------------------------------------------------------------------

# Environment variables:
# XBB_QEMU_GIT_URL
# XBB_QEMU_GIT_BRANCH
# XBB_QEMU_GIT_COMMIT

function qemu_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local qemu_version="$1"
  local qemu_target="$2" # arm, riscv, tools

  qemu_src_folder_name="${XBB_QEMU_SRC_FOLDER_NAME:-qemu-${qemu_version}.git}"

  local qemu_folder_name="qemu-${qemu_version}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${qemu_folder_name}/"

  local qemu_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${qemu_folder_name}-installed"
  if [ ! -f "${qemu_stamp_file_path}" ] || [ "${XBB_IS_DEBUG}" == "y" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    if [ ! -d "${XBB_SOURCES_FOLDER_PATH}/${qemu_src_folder_name}" ]
    then
      git_clone "${XBB_QEMU_GIT_URL}" "${XBB_QEMU_GIT_BRANCH}" \
          "${XBB_QEMU_GIT_COMMIT}" "${XBB_SOURCES_FOLDER_PATH}/${qemu_src_folder_name}"

      if false # Disabled, since the fork is needed anyway for the macOS patches.
      then
        # Simple way to customise the greeting message, instead of
        # managing a patch, or a fork.
        # On later versions, the file is `system/vl.c`.
        run_verbose sed -i.bak \
          -e 's|printf("QEMU emulator version "|printf("xPack QEMU emulator version "|' \
          "${XBB_SOURCES_FOLDER_PATH}/${qemu_src_folder_name}/softmmu/vl.c"

        run_verbose diff "${XBB_SOURCES_FOLDER_PATH}/${qemu_src_folder_name}/softmmu/vl.c.bak" "${XBB_SOURCES_FOLDER_PATH}/${qemu_src_folder_name}/softmmu/vl.c" || true
      fi
    fi
    # exit 1

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${qemu_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${qemu_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"

      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        LDFLAGS+=" -fstack-protector"
      # elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
      # then
      #   # The error messages are confusing, check the log for actual cause.
      #   # For example the missing -ldl resulted in:
      #   # sizeof(size_t) doesn't match GLIB_SIZEOF_SIZE_T
      #   LDFLAGS+=" -ldl -ludev -lpthread -lrt"
      elif [ "${XBB_HOST_PLATFORM}" == "linux" ] &&
           [ "${XBB_HOST_ARCH}" == "arm64" ] &&
           [ "${qemu_version}" == "8.1.0" ]
      then
        # ../../../sources/qemu-8.1.0.git/util/cpuinfo-aarch64.c: In function 'cpuinfo_init':
        # ../../../sources/qemu-8.1.0.git/util/cpuinfo-aarch64.c:58:22: error: 'HWCAP_USCAT' undeclared (first use in this function); did you mean 'HWCAP_JSCVT'?
        # 58 |     info |= (hwcap & HWCAP_USCAT ? CPUINFO_LSE2 : 0);

        CPPFLAGS+=" -DHWCAP_USCAT=(1<<25)"
      fi

      xbb_adjust_ldflags_rpath

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS

      export LDFLAGS

      (
        if [ ! -f "config.status" ]
        then

          xbb_show_env_develop

          echo
          echo "Running qemu ${qemu_target} configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            # Although it shouldn't, the script checks python before --help.
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${qemu_src_folder_name}/configure" \
              --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

          config_options+=("--bindir=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin")

          # This seems redundant, but without it the greeting
          # string is suffixed by -dirty.
          config_options+=("--with-pkgversion=${XBB_QEMU_GIT_COMMIT}")

          if [ "${XBB_HOST_PLATFORM}" == "win32" ]
          then
            config_options+=("--cross-prefix=${XBB_TARGET_TRIPLET}-")
          fi

          config_options+=("--cc=${CC}")
          config_options+=("--cxx=${CXX}")

          # CFLAGS, CXXFLAGS and LDFLAGS are used directly.
          config_options+=("--extra-cflags=${CPPFLAGS}")
          config_options+=("--extra-cxxflags=${CPPFLAGS}")

          config_options+=("--python=python3")

          if [ "${qemu_target}" == "arm" ]
          then
            config_options+=("--target-list=arm-softmmu,aarch64-softmmu")
            config_options+=("--disable-tools")
          elif [ "${qemu_target}" == "riscv" ]
          then
            config_options+=("--target-list=riscv32-softmmu,riscv64-softmmu")
            config_options+=("--disable-tools")
          elif [ "${qemu_target}" == "tools" ]
          then
            config_options+=("--target-list=") # None
            config_options+=("--enable-tools")
          else
            echo "Unsupported qemu_target ${qemu_target} in ${FUNCNAME[0]}()"
            exit 1
          fi

          if [ "${XBB_IS_DEBUG}" == "y" ]
          then
            config_options+=("--enable-debug")
          fi

          config_options+=("--enable-nettle")
          config_options+=("--enable-lzo")

          # Not toghether with nettle.
          # config_options+=("--enable-gcrypt")

          if [ "${XBB_HOST_PLATFORM}" != "win32" ]
          then
            config_options+=("--enable-libssh")
            config_options+=("--enable-curses")
            config_options+=("--enable-vde")
          fi

          if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then
            # For now, Cocoa builds fail on macOS 10.13.
            if [ "${XBB_ENABLE_QEMU_SDL:-"n"}" == "y" ]
            then
              # In the first Arm release.
              config_options+=("--disable-cocoa")
              config_options+=("--enable-sdl")
            else
              config_options+=("--enable-cocoa")
              config_options+=("--disable-sdl")
            fi
            # Prevent codesign issues caused by including the Hypervisor.
            config_options+=("--disable-hvf")
          else
            config_options+=("--enable-sdl")
          fi

          config_options+=("--disable-bsd-user")
          config_options+=("--disable-guest-agent")
          config_options+=("--disable-gtk")

          if [ "${XBB_WITH_STRIP}" != "y" ]
          then
            config_options+=("--disable-strip")
          fi

          config_options+=("--disable-werror")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${qemu_src_folder_name}/configure" \
            ${config_options[@]}

        fi
        cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${qemu_folder_name}/configure-log-$(ndate).txt"
      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${qemu_folder_name}/configure-output-$(ndate).txt"

      (
        echo
        echo "Running qemu ${qemu_target} make..."

        # Build.
        run_verbose make -j ${XBB_JOBS} # V=1

        run_verbose make install

        if [ "${qemu_target}" == "arm" ]
        then
          show_host_libs "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/qemu-system-aarch64"
        elif [ "${qemu_target}" == "riscv" ]
        then
          show_host_libs "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/qemu-system-riscv64"
        elif [ "${qemu_target}" == "tools" ]
        then
          show_host_libs "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/qemu-img"
        else
          echo "Unsupported qemu_target ${qemu_target} in ${FUNCNAME[0]}()"
          exit 1
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${qemu_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${qemu_src_folder_name}" \
        "qemu-${qemu_version}"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${qemu_stamp_file_path}"

  else
    echo "Component qemu ${qemu_target} already installed"
  fi

  # Define this function at package level.
  tests_add "qemu_${qemu_target}_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

# -----------------------------------------------------------------------------

