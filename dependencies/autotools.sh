# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
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
  # https://ftp.gnu.org/pub/gnu/libiconv/
  libiconv_build "1.17" # "1.16"

  # https://ftp.gnu.org/gnu/autoconf/
  # depends on m4.
  autoconf_build "2.71"

  # https://ftp.gnu.org/gnu/automake/
  # depends on autoconf.
  automake_build "1.16.5"

  # http://ftpmirror.gnu.org/libtool/
  libtool_build "2.4.7"

  # configure.ac:34: error: Macro PKG_PROG_PKG_CONFIG is not available. It is usually defined in file pkg.m4 provided by package pkg-config.
  # https://pkgconfig.freedesktop.org/releases/
  # depends on libiconv
  pkg_config_build "0.29.2"
}

# -----------------------------------------------------------------------------
