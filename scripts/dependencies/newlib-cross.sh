# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# Environment variables:
# XBB_NEWLIB_SRC_FOLDER_NAME
# XBB_NEWLIB_ARCHIVE_URL
# XBB_NEWLIB_ARCHIVE_NAME

# https://github.com/archlinux/svntogit-community/blob/packages/arm-none-eabi-newlib/trunk/PKGBUILD
# https://github.com/archlinux/svntogit-community/blob/packages/riscv32-elf-newlib/trunk/PKGBUILD

# For the nano build, call it with "-nano".
# $1="" or $1="-nano"
function build_cross_newlib()
{
  local newlib_version="$1"
  shift

  local triplet="$1"
  shift

  local name_prefix="${triplet}-"

  local name_suffix=""
  local is_nano="n"
  local nano_option=""

  while [ $# -gt 0 ]
  do
    case "$1" in
      --nano )
        is_nano="y"
        nano_option="--nano"
        name_suffix="-nano"
        ;;

      * )
        echo "Unsupported argument $1 in ${FUNCNAME[0]}()"
        exit 1
        ;;
    esac
    shift
  done

  local newlib_folder_name="${name_prefix}newlib-${newlib_version}${name_suffix}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${newlib_folder_name}"

  local newlib_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${newlib_folder_name}-installed"
  if [ ! -f "${newlib_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    if [ ! -d "${XBB_NEWLIB_SRC_FOLDER_NAME}" ]
    then
      download_and_extract "${XBB_NEWLIB_ARCHIVE_URL}" "${XBB_NEWLIB_ARCHIVE_NAME}" \
      "${XBB_NEWLIB_SRC_FOLDER_NAME}"

      # No longer needed, sed 4.9 is now a dependency.
      # if [ "${XBB_BUILD_PLATFORM}" == "darwin" ]
      # then
      #   # macOS 10.13 sed is very old and does not understand 'r'; use 'E'.
      #   run_verbose sed -i.bak -e 's|sed -re "|sed -E -e "|' \
      #     "${XBB_SOURCES_FOLDER_PATH}/${XBB_NEWLIB_SRC_FOLDER_NAME}/libgloss/multi-build.in"
      # fi

      if [ "${XBB_ENABLE_NEWLIB_RISCV_NANO_CXX_PATCH:-""}" == "y" ]
      then
        echo
        echo "Patching nano.specs..."

        local nano_specs_file_path="${XBB_NEWLIB_SRC_FOLDER_NAME}/libgloss/riscv/nano.specs"
        if grep "%(nano_link)" "${nano_specs_file_path}" | grep -q "%:replace-outfile(-lstdc++ -lstdc++_nano)"
        then
          echo "-lstdc++_nano already in"
        else
          run_verbose sed -i.bak \
            -e 's|^\(%(nano_link) .*\)$|\1 %:replace-outfile(-lstdc++ -lstdc++_nano)|' \
            "${nano_specs_file_path}"
        fi
        if grep "%(nano_link)" "${nano_specs_file_path}" | grep -q "%:replace-outfile(-lsupc++ -lsupc++_nano)"
        then
          echo "-lsupc++_nano already in"
        else
          run_verbose sed -i.bak \
            -e 's|^\(%(nano_link) .*\)$|\1 %:replace-outfile(-lsupc++ -lsupc++_nano)|' \
            "${nano_specs_file_path}"
        fi
      fi
      # exit 1
    fi

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${newlib_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${newlib_folder_name}"

      xbb_activate_dependencies_dev
      # xbb_activate_*_bin moved outside.

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      cross_gcc_define_flags_for_target "${nano_option}"

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS

      export CFLAGS_FOR_TARGET
      export CXXFLAGS_FOR_TARGET
      export LDFLAGS_FOR_TARGET

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          # --disable-nls do not use Native Language Support
          # --enable-newlib-io-long-double   enable long double type support in IO functions printf/scanf
          # --enable-newlib-io-long-long   enable long long type support in IO functions like printf/scanf
          # --enable-newlib-io-c99-formats   enable C99 support in IO functions like printf/scanf
          # --enable-newlib-register-fini   enable finalization function registration using atexit
          # --disable-newlib-supplied-syscalls disable newlib from supplying syscalls (__NO_SYSCALLS__)

          # --disable-newlib-fvwrite-in-streamio    disable iov in streamio
          # --disable-newlib-fseek-optimization    disable fseek optimization
          # --disable-newlib-wide-orient    Turn off wide orientation in streamio
          # --disable-newlib-unbuf-stream-opt    disable unbuffered stream optimization in streamio
          # --enable-newlib-nano-malloc    use small-footprint nano-malloc implementation
          # --enable-lite-exit	enable light weight exit
          # --enable-newlib-global-atexit	enable atexit data structure as global
          # --enable-newlib-nano-formatted-io    Use nano version formatted IO
          # --enable-newlib-reent-small

          # --enable-newlib-retargetable-locking ???

          echo
          echo "Running cross ${name_prefix}newlib${name_suffix} configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${XBB_NEWLIB_SRC_FOLDER_NAME}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

          config_options+=("--infodir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/info")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")
          config_options+=("--htmldir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/html")
          config_options+=("--pdfdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/pdf")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${triplet}")

          if [ "${is_nano}" != "y" ]
          then

            # 11.2-2022.02-darwin-x86_64-arm-none-eabi-manifest.txt:
            # newlib_configure=' --disable-newlib-supplied-syscalls
            # --enable-newlib-io-long-long --enable-newlib-io-c99-formats
            # --enable-newlib-mb --enable-newlib-reent-check-verify
            # --target=arm-none-eabi --prefix=/'

            # 11.2-2022.02-darwin-x86_64-aarch64-none-elf-manifest.txt
            # newlib_configure=' --disable-newlib-supplied-syscalls
            # --enable-newlib-io-long-long --enable-newlib-io-c99-formats
            # --enable-newlib-mb --enable-newlib-reent-check-verify
            # --target=aarch64-none-elf --prefix=/'

            config_options+=("--disable-newlib-supplied-syscalls") # Arm, AArch64

            config_options+=("--enable-newlib-io-c99-formats") # Arm, AArch64

            config_options+=("--enable-newlib-io-long-long") # Arm, AArch64
            config_options+=("--enable-newlib-mb") # Arm, AArch64
            config_options+=("--enable-newlib-reent-check-verify") # Arm, AArch64

            config_options+=("--enable-newlib-register-fini") # Arm

            config_options+=("--enable-newlib-retargetable-locking") # Arm

          else

            # 11.2-2022.02-darwin-x86_64-arm-none-eabi-manifest.txt:
            # newlib_nano_configure=' --disable-newlib-supplied-syscalls
            # --enable-newlib-nano-malloc --disable-newlib-unbuf-stream-opt
            # --enable-newlib-reent-small --disable-newlib-fseek-optimization
            # --enable-newlib-nano-formatted-io
            # --disable-newlib-fvwrite-in-streamio --disable-newlib-wide-orient
            # --enable-lite-exit --enable-newlib-global-atexit
            # --enable-newlib-reent-check-verify
            # --target=arm-none-eabi --prefix=/'

            # --enable-newlib-io-long-long and --enable-newlib-io-c99-formats
            # are currently ignored if --enable-newlib-nano-formatted-io.
            # --enable-newlib-register-fini is debatable, was removed.

            config_options+=("--disable-newlib-fseek-optimization") # Arm
            config_options+=("--disable-newlib-fvwrite-in-streamio") # Arm

            config_options+=("--disable-newlib-supplied-syscalls") # Arm
            config_options+=("--disable-newlib-unbuf-stream-opt") # Arm
            config_options+=("--disable-newlib-wide-orient") # Arm

            config_options+=("--enable-lite-exit") # Arm
            config_options+=("--enable-newlib-global-atexit") # Arm
            config_options+=("--enable-newlib-nano-formatted-io") # Arm
            config_options+=("--enable-newlib-nano-malloc") # Arm
            config_options+=("--enable-newlib-reent-check-verify") # Arm
            config_options+=("--enable-newlib-reent-small") # Arm

            config_options+=("--enable-newlib-retargetable-locking") # Arm

          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${XBB_NEWLIB_SRC_FOLDER_NAME}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${newlib_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${newlib_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        # Partial build, without documentation.
        echo
        echo "Running cross ${name_prefix}newlib${name_suffix} make..."

        # Parallel builds may fail.
        run_verbose make -j ${XBB_JOBS}
        # make

        # Top make fails with install-strip due to libgloss make.
        run_verbose make install

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${newlib_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${XBB_NEWLIB_SRC_FOLDER_NAME}" \
        "newlib-${newlib_version}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${newlib_stamp_file_path}"

  else
    echo "Component cross ${name_prefix}newlib${name_suffix} already installed"
  fi
}

# -----------------------------------------------------------------------------

function cross_newlib_copy_nano_libs()
{
  local src_folder="$1"
  local dst_folder="$2"

  # Copy the nano variants with a distinct name, as used in nano.specs.
  cp -v -f "${src_folder}/libc.a" "${dst_folder}/libc_nano.a"
  cp -v -f "${src_folder}/libg.a" "${dst_folder}/libg_nano.a"
  cp -v -f "${src_folder}/libm.a" "${dst_folder}/libm_nano.a"


  cp -v -f "${src_folder}/libstdc++.a" "${dst_folder}/libstdc++_nano.a"
  cp -v -f "${src_folder}/libsupc++.a" "${dst_folder}/libsupc++_nano.a"

  if [ -f "${src_folder}/libgloss.a" ]
  then
    cp -v -f "${src_folder}/libgloss.a" "${dst_folder}/libgloss_nano.a"
  fi

  if [ -f "${src_folder}/librdimon.a" ]
  then
    cp -v -f "${src_folder}/librdimon.a" "${dst_folder}/librdimon_nano.a"
  fi

  if [ -f "${src_folder}/librdimon-v2m.a" ]
  then
    cp -v -f "${src_folder}/librdimon-v2m.a" "${dst_folder}/lrdimon-v2m_nano.a"
  fi
}

# -----------------------------------------------------------------------------
