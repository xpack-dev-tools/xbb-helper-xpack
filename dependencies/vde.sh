# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# Ethernet compliant virtual network
# https://github.com/virtualsquare/vde-2
# https://vde.sourceforge.io/
# https://sourceforge.net/projects/vde/files/vde2/
# https://downloads.sourceforge.net/project/vde/vde2/2.3.2/vde2-2.3.2.tar.gz

# https://github.com/archlinux/svntogit-packages/blob/packages/vde2/trunk/PKGBUILD

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/v/vde.rb

# 2011-11-23 "2.3.2"

# -----------------------------------------------------------------------------

function vde_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local vde_version="$1"

  local vde_src_folder_name="vde2-${vde_version}"

  local vde_archive="${vde_src_folder_name}.tar.gz"
  local vde_url="https://downloads.sourceforge.net/project/vde/vde2/${vde_version}/${vde_archive}"

  local vde_folder_name="${vde_src_folder_name}"
  local vde_patch_file_name="${vde_folder_name}.git.patch"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${vde_folder_name}"

  local vde_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${vde_folder_name}-installed"
  if [ ! -f "${vde_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    run_verbose_develop cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${vde_url}" "${vde_archive}" \
      "${vde_src_folder_name}" "${vde_patch_file_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${vde_folder_name}"
      run_verbose_develop cd "${XBB_BUILD_FOLDER_PATH}/${vde_folder_name}"

      xbb_activate_dependencies_dev

      # On debug, -O[01] fail with:
      # Undefined symbols for architecture x86_64:
      #   "_ltonstring", referenced from:
      #       _fst_in_bpdu in fstp.o
      #   "_nstringtol", referenced from:
      #       _fst_in_bpdu in fstp.o
      #       _fstprintactive in fstp.o

      CPPFLAGS="$(echo "${XBB_CPPFLAGS}" | sed -e 's|-O0|-O2|')"
      CFLAGS="$(echo "${XBB_CFLAGS_NO_W}" | sed -e 's|-O0|-O2|')"
      CXXFLAGS="$(echo "${XBB_CXXFLAGS_NO_W}" | sed -e 's|-O0|-O2|')"

      # 2.3.2
      # /Users/ilg/Work/xpack-dev-tools-build/qemu-arm-7.2.0-1/darwin-x64/sources/vde2-2.3.2/src/wirefilter.c:136:28: error: parameter 'i' was not declared, defaults to 'int'; ISO C99 and later do not support implicit int [-Wimplicit-int]
      CFLAGS+=" -Wno-implicit-int"

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
          echo "Running vde configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${vde_src_folder_name}/configure" --help
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

          config_options+=("--disable-python")
          # src/vde_cryptcab/cryptcab.c:25:23: error: tentative definition has type 'EVP_CIPHER_CTX' (aka 'struct evp_cipher_ctx_st') that is never completed
          config_options+=("--disable-cryptcab")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${vde_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${vde_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${vde_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running vde make..."

        # Build.
        # *** No rule to make target '../../src/lib/libvdemgmt.la', needed by 'libvdesnmp.la'.  Stop.
        run_verbose make # -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${vde_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${vde_src_folder_name}" \
        "${vde_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${vde_stamp_file_path}"

  else
    echo "Library vde already installed"
  fi
}

# -----------------------------------------------------------------------------
