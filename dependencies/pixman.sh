# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.pixman.org
# https://cairographics.org/releases/

# https://gitlab.archlinux.org/archlinux/packaging/packages/pixman/-/blob/main/PKGBUILD?ref_type=heads
# https://archlinuxarm.org/packages/aarch64/pixman/files/PKGBUILD
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=pixman-git
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-pixman

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/p/pixman.rb

# pixman_version="0.32.6"
# pixman_version="0.34.0" # 2016-01-31
# pixman_version="0.38.0" # 2019-02-11
# 2019-04-10, "0.38.4"
# 2020-04-19, "0.40.0"

# -----------------------------------------------------------------------------

function pixman_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local pixman_version="$1"

  local pixman_src_folder_name="pixman-${pixman_version}"

  local pixman_archive="${pixman_src_folder_name}.tar.gz"
  local pixman_url="https://cairographics.org/releases/${pixman_archive}"

  local pixman_folder_name="${pixman_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${pixman_folder_name}"

  local pixman_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-pixman-${pixman_version}-installed"
  if [ ! -f "${pixman_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${pixman_url}" "${pixman_archive}" \
      "${pixman_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${pixman_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${pixman_folder_name}"

      # Windows libtool chaks for it.
      mkdir -pv test/lib

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

      if [ -f "${XBB_SOURCES_FOLDER_PATH}/${pixman_src_folder_name}/meson.build" ]
      then
        if [ ! -f "build.ninja" ]
        then
          (
            xbb_show_env_develop

            echo
            echo "Running pixman meson setup..."

            # https://mesonbuild.com/Commands.html#setup
            config_options=()

            config_options+=("--prefix" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")
            config_options+=("--includedir" "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
            config_options+=("--libdir" "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
            config_options+=("--backend" "ninja")

            if [ "${XBB_HOST_PLATFORM}" == "win32" ]
            then
              config_options+=("--cross" "${helper_folder_path}/extras/meson/mingw-w64-gcc.ini")
            fi

            config_options+=("-D" "tests=disabled")
            config_options+=("-D" "loongson-mmi=disabled")
            config_options+=("-D" "vmx=disabled") # Arch
            config_options+=("-D" "arm-simd=disabled") # Arch
            config_options+=("-D" "neon=disabled") # Arch
            config_options+=("-D" "a64-neon=disabled") # Arch
            config_options+=("-D" "iwmmxt=disabled") # Arch
            config_options+=("-D" "mmx=disabled")
            config_options+=("-D" "sse2=disabled")
            config_options+=("-D" "ssse3=disabled")
            config_options+=("-D" "mips-dspr2=disabled") # Arch
            config_options+=("-D" "gtk=disabled") # Arch

            # meson setup <options> builddir sourcedir
            run_verbose meson setup \
              "${config_options[@]}" \
              "${XBB_BUILD_FOLDER_PATH}/${pixman_folder_name}" \
              "${XBB_SOURCES_FOLDER_PATH}/${pixman_src_folder_name}"

          ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${pixman_folder_name}/meson-setup-output-$(ndate).txt"
        fi

        (
          echo
          echo "Running pixman meson compile..."

          # Build.
          run_verbose meson compile -C "${XBB_BUILD_FOLDER_PATH}/${pixman_folder_name}"

          run_verbose meson install -C "${XBB_BUILD_FOLDER_PATH}/${pixman_folder_name}"

        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${pixman_folder_name}/meson-compile-output-$(ndate).txt"

      elif [ -f "${XBB_SOURCES_FOLDER_PATH}/${pixman_src_folder_name}/configure" ]
      then
        if [ ! -f "config.status" ]
        then
          (
            xbb_show_env_develop

            echo
            echo "Running pixman configure..."

            if is_development
            then
              run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${pixman_src_folder_name}/configure" --help
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

            # config_options+=("--with-gnu-ld")

            # The numerous disables were inspired by Arch, after the initial
            # failed on armhf.
            config_options+=("--disable-static-testprogs")
            config_options+=("--disable-loongson-mmi")
            config_options+=("--disable-vmx")
            config_options+=("--disable-arm-simd")
            config_options+=("--disable-arm-a64-neon")
            config_options+=("--disable-arm-neon")
            config_options+=("--disable-arm-iwmmxt")
            config_options+=("--disable-mmx")
            config_options+=("--disable-sse2")
            config_options+=("--disable-ssse3")
            config_options+=("--disable-mips-dspr2")
            config_options+=("--disable-gtk")

            run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${pixman_src_folder_name}/configure" \
              "${config_options[@]}"

            cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${pixman_folder_name}/config-log-$(ndate).txt"
          ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${pixman_folder_name}/configure-output-$(ndate).txt"
        fi

        (
          echo
          echo "Running pixman make..."

          # Build.
          run_verbose make -j ${XBB_JOBS}

          if with_strip
          then
            run_verbose make install-strip
          else
            run_verbose make install
          fi

        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${pixman_folder_name}/make-output-$(ndate).txt"
      else
        echo "Unsupported pixman build method"
        exit 1
      fi

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${pixman_src_folder_name}" \
        "${pixman_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${pixman_stamp_file_path}"

  else
    echo "Library pixman already installed"
  fi
}

# -----------------------------------------------------------------------------

