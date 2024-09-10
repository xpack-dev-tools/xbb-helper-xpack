# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# This is a shortcut to build the latest versions of all autotools.

for dependency in libiconv autoconf automake libtool pkg-config
do
  echo "Including ${helper_folder_path}/dependencies/${dependency}.sh..."
  source "${helper_folder_path}/dependencies/${dependency}.sh"
done

function autotools_build()
{
  # For tools to access their dependencies.
  xbb_activate_installed_bin

  # Moved out, must be explicitly called by the application before this!
  # https://ftp.gnu.org/pub/gnu/libiconv/
  # libiconv_build "1.17" # "1.16"

  # https://ftp.gnu.org/gnu/autoconf/
  # depends on m4.
  autoconf_build "2.72" # "2.71"

  # https://ftp.gnu.org/gnu/automake/
  # depends on autoconf.
  automake_build "1.16.5"

  # https://ftpmirror.gnu.org/libtool/
  libtool_build "2.4.7"

  # configure.ac:34: error: Macro PKG_PROG_PKG_CONFIG is not available. It is usually defined in file pkg.m4 provided by package pkg-config.
  # https://pkgconfig.freedesktop.org/releases/
  # depends on libiconv
  # Must be local, cannot use the xPack version.
  pkg_config_build "0.29.2"
}

# -----------------------------------------------------------------------------
