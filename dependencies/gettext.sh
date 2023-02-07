# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.gnu.org/software/gettext/
# https://ftp.gnu.org/pub/gnu/gettext/

# https://archlinuxarm.org/packages/aarch64/gettext/files/PKGBUILD
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gettext-git
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-gettext

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/gettext.rb

# 2015-07-14 "0.19.5.1"
# 2016-06-11 "0.19.8.1"
# 2020-04-14 "0.20.2"
# 2020-07-26 "0.21"
# 2022-10-09, "0.21.1"

# -----------------------------------------------------------------------------

function gettext_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local gettext_version="$1"

  local gettext_src_folder_name="gettext-${gettext_version}"

  local gettext_archive="${gettext_src_folder_name}.tar.gz"
  local gettext_url="https://ftp.gnu.org/pub/gnu/gettext/${gettext_archive}"

  local gettext_folder_name="${gettext_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${gettext_folder_name}"

  local gettext_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${gettext_folder_name}-installed"
  if [ ! -f "${gettext_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${gettext_url}" "${gettext_archive}" \
      "${gettext_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${gettext_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${gettext_folder_name}"

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

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running gettext configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${gettext_src_folder_name}/gettext-runtime/configure" --help
          fi

          # Build only the /gettext-runtime folder, attempts to build
          # the full package fail with a CXX='no' problem.
          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          if [ "${XBB_HOST_PLATFORM}" == "win32" ]
          then
            config_options+=("--enable-threads=windows")
            config_options+=("--with-gnu-ld")
          elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
          then
            config_options+=("--enable-threads=posix")
            config_options+=("--with-gnu-ld")
          elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then
            config_options+=("--enable-threads=posix")
          fi

          config_options+=("--without-git") # HB
          config_options+=("--without-cvs") # HB
          config_options+=("--without-xz") # HB
          config_options+=("--without-included-gettext") # Arch

          config_options+=("--with-included-glib") # HB
          config_options+=("--with-included-libcroco") # HB
          config_options+=("--with-included-libunistring") # HB
          config_options+=("--with-included-libxml") # HB
          config_options+=("--with-included-gettext") # HB

          # config_options+=("--with-emacs") # HB

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--disable-installed-tests")
          config_options+=("--disable-always-build-tests")

          # config_options+=("--enable-nls")
          config_options+=("--disable-nls")

          config_options+=("--disable-java") # HB
          config_options+=("--disable-native-java")

          config_options+=("--disable-csharp") # HB
          # config_options+=("--enable-csharp") # Arch

          # config_options+=("--disable-c++")
          config_options+=("--disable-libasprintf")

          # DO NOT USE, on macOS the LC_RPATH looses GCC references.
          # config_options+=("--enable-relocatable")

          #  --enable-nls needed to include libintl
          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${gettext_src_folder_name}/gettext-runtime/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${gettext_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gettext_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running gettext make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          make -j1 check # || true
        fi

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gettext_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${gettext_src_folder_name}" \
        "${gettext_folder_name}"

    )

    (
      gettext_test "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gettext_folder_name}/test-output-$(ndate).txt"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${gettext_stamp_file_path}"

  else
    echo "Library gettext already installed"
  fi

  tests_add "gettext_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function gettext_test()
{
  local test_bin_folder_path="$1"

  echo
  echo "Checking the gettext shared libraries..."

  show_host_libs "${test_bin_folder_path}/gettext"
  show_host_libs "${test_bin_folder_path}/ngettext"
  show_host_libs "${test_bin_folder_path}/envsubst"

  run_host_app_verbose "${test_bin_folder_path}/gettext" --version
  expect_host_output "test" "${test_bin_folder_path}/gettext" test
}

# -----------------------------------------------------------------------------
