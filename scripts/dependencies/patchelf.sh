# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function build_patchelf()
{
  # https://nixos.org/patchelf.html
  # https://github.com/NixOS/patchelf
  # https://github.com/NixOS/patchelf/releases/
  # https://github.com/NixOS/patchelf/releases/download/0.12/patchelf-0.12.tar.bz2
  # https://github.com/NixOS/patchelf/archive/0.12.tar.gz
  # https://github.com/NixOS/patchelf/releases/download/0.14.5/patchelf-0.14.5.tar.bz2

  # https://github.com/archlinux/svntogit-community/blob/packages/patchelf/trunk/PKGBUILD
  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/patchelf.rb


  # 2016-02-29, "0.9"
  # 2019-03-28, "0.10"
  # 2020-06-09, "0.11"
  # 2020-08-27, "0.12"
  # 05 Aug 2021, "0.13"
  # 05 Dec 2021, "0.14.3"
  # 16 Jul 2022, "0.14.4"
  # 21 Feb 2022, "0.14.5"
  # 16 Jul 2022, "0.15.0"

  local patchelf_version="$1"

  local patchelf_src_folder_name="patchelf-${patchelf_version}"

  local patchelf_archive="${patchelf_src_folder_name}.tar.bz2"
  local patchelf_url="https://github.com/NixOS/patchelf/releases/download/${patchelf_version}/${patchelf_archive}"

  local patchelf_folder_name="${patchelf_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${patchelf_folder_name}"

  local patchelf_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${patchelf_folder_name}-installed"
  if [ ! -f "${patchelf_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${patchelf_url}" "${patchelf_archive}" \
      "${patchelf_src_folder_name}"

    (
      if [ ! -x "${XBB_SOURCES_FOLDER_PATH}/${patchelf_src_folder_name}/configure" ]
      then

        cd "${XBB_SOURCES_FOLDER_PATH}/${patchelf_src_folder_name}"

        xbb_activate_installed_dev

        run_verbose bash ${DEBUG} "bootstrap.sh"

      fi
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${patchelf_folder_name}/autogen-output-$(ndate).txt"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${patchelf_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${patchelf_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      # Wihtout -static-libstdc++, it fails with
      # /usr/lib/x86_64-linux-gnu/libstdc++.so.6: version `GLIBCXX_3.4.29' not found
      # LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC}"
      LDFLAGS="${XBB_LDFLAGS_APP}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" -o "${XBB_TARGET_PLATFORM}" == "darwin" ]
      then
        xbb_activate_cxx_rpath
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running patchelf configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${patchelf_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${patchelf_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${patchelf_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${patchelf_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running patchelf make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

        # Fails.
        # x86_64: FAIL: set-rpath-library.sh (Segmentation fault (core dumped))
        # x86_64: FAIL: set-interpreter-long.sh (Segmentation fault (core dumped))
        # make -C tests -j1 check

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${patchelf_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${patchelf_src_folder_name}" \
        "${patchelf_folder_name}"
    )

    (
      test_patchelf "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${patchelf_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${patchelf_stamp_file_path}"

  else
    echo "Component patchelf already installed."
  fi

  tests_add "test_patchelf" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
}

function test_patchelf()
{
  local test_bin_folder_path="$1"

  (
    echo
    echo "Checking the patchelf binaries shared libraries..."

    show_libs "${test_bin_folder_path}/patchelf"

    echo
    echo "Testing if patchelf binaries start properly..."

    run_app "${test_bin_folder_path}/patchelf" --version
    run_app "${test_bin_folder_path}/patchelf" --help
  )
}

# -----------------------------------------------------------------------------
