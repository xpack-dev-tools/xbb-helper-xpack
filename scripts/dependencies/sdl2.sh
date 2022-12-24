# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function sdl2_build()
{
  # https://www.libsdl.org/
  # https://www.libsdl.org/release

  # https://archlinuxarm.org/packages/aarch64/sdl2/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=sdl2-hg
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-sdl2

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/sdl2.rb

  # sdl2_version="2.0.3" # 2014-03-16
  # sdl2_version="2.0.5" # 2016-10-20
  # sdl2_version="2.0.9" # 2018-10-31
  # 2021-11-30, "2.0.18"
  # 2022-04-25, "2.0.22"
  # 2022-08-19, "2.24.0" # Fails on arm linux with xbb v5.0.0
  # 2022-11-01, "2.24.2"

  local sdl2_version="$1"

  local sdl2_src_folder_name="SDL2-${sdl2_version}"

  local sdl2_archive="${sdl2_src_folder_name}.tar.gz"
  local sdl2_url="https://www.libsdl.org/release/${sdl2_archive}"

  local sdl2_folder_name="${sdl2_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${sdl2_folder_name}"

  local sdl2_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-sdl2-${sdl2_version}-installed"
  if [ ! -f "${sdl2_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${sdl2_url}" "${sdl2_archive}" \
      "${sdl2_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${sdl2_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${sdl2_folder_name}"

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
          echo "Running sdl2 configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${sdl2_src_folder_name}/configure" --help
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

          config_options+=("--enable-video")
          config_options+=("--disable-audio")
          config_options+=("--disable-joystick")
          config_options+=("--disable-haptic")

          if [ "${XBB_HOST_PLATFORM}" == "win32" ]
          then
            :
          elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
          then
            config_options+=("--enable-video-opengl")
            config_options+=("--enable-video-x11")

            config_options+=("--enable-libudev")
          elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then
            config_options+=("--without-x")
          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${sdl2_src_folder_name}/configure" \
            ${config_options[@]}

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${sdl2_folder_name}/config-log.txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${sdl2_folder_name}/configure-output.txt"

      fi

      (
        echo
        echo "Running sdl2 make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        run_verbose make install

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${sdl2_folder_name}/make-output.txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${sdl2_src_folder_name}" \
        "${sdl2_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${sdl2_stamp_file_path}"

  else
    echo "Library sdl2 already installed"
  fi
}

function sdl2_image_build()
{
  # https://www.libsdl.org/projects/SDL_image/
  # https://www.libsdl.org/projects/SDL_image/release

  # https://archlinuxarm.org/packages/aarch64/sdl2_image/files
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-sdl2_image

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/sdl2_image.rb

  # sdl2_image_version="1.1"
  # sdl2_image_version="2.0.1" # 2016-01-03
  # sdl2_image_version="2.0.3" # 2018-03-01
  # sdl2_image_version="2.0.4" # 2018-10-31
  # 2019-07-01, "2.0.5"
  # 2022-08-19, "2.6.2"

  local sdl2_image_version="$1"

  local sdl2_image_src_folder_name="SDL2_image-${sdl2_image_version}"

  local sdl2_image_archive="${sdl2_image_src_folder_name}.tar.gz"
  local sdl2_image_url="https://www.libsdl.org/projects/SDL_image/release/${sdl2_image_archive}"

  local sdl2_image_folder_name="${sdl2_image_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${sdl2_image_folder_name}"

  local sdl2_image_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-sdl2-image-${sdl2_image_version}-installed"
  if [ ! -f "${sdl2_image_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${sdl2_image_url}" "${sdl2_image_archive}" \
      "${sdl2_image_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${sdl2_image_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${sdl2_image_folder_name}"

      # The windows build checks this.
      mkdir -pv lib

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      OBJCFLAGS="${XBB_CFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      xbb_adjust_ldflags_rpath

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export OBJCFLAGS
      export LDFLAGS

      if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
      then
        export OBJC=clang
      fi

      # export LIBS="-lpng16 -ljpeg"

      if [ ! -f "config.status" ]
      then

        (
          xbb_show_env_develop

          echo
          echo "Running sdl2-image configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${sdl2_image_src_folder_name}/configure" --help
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

          config_options+=("--enable-jpg")
          config_options+=("--enable-png")

          config_options+=("--disable-sdltest")
          config_options+=("--disable-jpg-shared")
          config_options+=("--disable-png-shared")
          config_options+=("--disable-bmp")
          config_options+=("--disable-gif")
          config_options+=("--disable-lbm")
          config_options+=("--disable-pcx")
          config_options+=("--disable-pnm")
          config_options+=("--disable-tga")
          config_options+=("--disable-tif")
          config_options+=("--disable-tif-shared")
          config_options+=("--disable-xcf")
          config_options+=("--disable-xpm")
          config_options+=("--disable-xv")
          config_options+=("--disable-webp")
          config_options+=("--disable-webp-shared")

          if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
          then
            config_options+=("--enable-imageio")
          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${sdl2_image_src_folder_name}/configure" \
            ${config_options[@]}

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${sdl2_image_folder_name}/config-log.txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${sdl2_image_folder_name}/configure-output.txt"

      fi

      (
        echo
        echo "Running sdl2-image make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${sdl2_image_folder_name}/make-output.txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${sdl2_image_src_folder_name}" \
        "${sdl2_image_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${sdl2_image_stamp_file_path}"

  else
    echo "Library sdl2-image already installed"
  fi
}

# -----------------------------------------------------------------------------
