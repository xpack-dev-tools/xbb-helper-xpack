#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2022 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Functions used after the build, to prepare the distribution archive.

# Process all elf files in a folder (executables and shared libraries).

# $1 = folder path (default ${XBB_APPLICATION_INSTALL_FOLDER_PATH})
function make_standalone()
{
  local folder_path="${XBB_APPLICATION_INSTALL_FOLDER_PATH}"
  if [ $# -ge 1 ]
  then
    folder_path="$1"
  fi

  (
    echo
    echo "# Preparing ${folder_path} libraries..."

    # Otherwise `find` may fail.
    cd "${XBB_TARGET_WORK_FOLDER_PATH}"

    local binaries
    if [ "${XBB_HOST_PLATFORM}" == "win32" ]
    then

      binaries=$(find_binaries "${folder_path}")
      for bin in ${binaries}
      do
        echo
        echo "## Preparing $(basename "${bin}") ${bin} libraries..."
        # On Windows the DLLs are copied in the same folder.
        copy_dependencies_recursive "${bin}" "$(dirname "${bin}")"
      done

    elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
    then

      binaries=$(find_binaries "${folder_path}")
      for bin in ${binaries}
      do
        if is_elf "${bin}"
        then
          echo
          echo "## Preparing $(basename "${bin}") ${bin} libraries..."
          copy_dependencies_recursive "${bin}" "$(dirname "${bin}")"
        fi
      done

      # rpaths are not cleaned on the spot, to allow hard links to be
      # processed later, and add new $ORIGINs for the new locations.
      # Find again, to get the libraries copied to libexec.
      binaries=$(find_binaries "${folder_path}")
      for bin_path in ${binaries}
      do
        if is_elf "${bin_path}"
        then
          echo
          echo "## Cleaning ${bin_path} rpath..."
          clean_rpaths "${bin_path}"
        fi
      done

    elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
    then

      binaries=$(find_binaries "${folder_path}")
      for bin_path in ${binaries}
      do
        if is_elf_dynamic "${bin_path}"
        then
          echo
          echo "## Preparing $(basename "${bin_path}") (${bin_path}) libraries..."
          copy_dependencies_recursive "${bin_path}" \
            "$(dirname "${bin_path}")"

          # echo $(basename "${bin_path}") $(readelf -d "${bin_path}" | egrep '(RUNPATH|RPATH)')
        fi
      done

      # rpaths are not cleaned on the spot, to allow hard links to be
      # processed later, and add new $ORIGINs for the new locations.
      # Find again, to get the libraries copied to libexec.
      binaries=$(find_binaries "${folder_path}")
      for bin_path in ${binaries}
      do
        if is_elf_dynamic "${bin_path}"
        then
          echo
          echo "## Cleaning ${bin_path} rpath..."
          clean_rpaths "${bin_path}"
        fi
      done

    else
      echo "Unsupported XBB_HOST_PLATFORM=${XBB_HOST_PLATFORM} in make standalone."
      exit 1
    fi
  )
}

# -----------------------------------------------------------------------------

# Output the result of an elaborate find.
function find_binaries()
{
  local folder_path
  if [ $# -ge 1 ]
  then
    folder_path="$1"
  else
    folder_path="${XBB_APPLICATION_INSTALL_FOLDER_PATH}"
  fi

  if [ "${XBB_HOST_PLATFORM}" == "win32" ]
  then
    find "${folder_path}" \( -name \*.exe -o -name \*.dll -o -name \*.pyd \) | sort
  elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
  then
    find "${folder_path}" -name \* -type f ! -iname "*.cmake" ! -iname "*.txt" ! -iname "*.rst" ! -iname "*.html" ! -iname "*.json" ! -iname "*.py" ! -iname "*.pyc" ! -iname "*.h" ! -iname "*.xml" ! -iname "*.a" ! -iname "*.la" ! -iname "*.spec" ! -iname "*.specs" ! -iname "*.decTest" ! -iname "*.exe" ! -iname "*.c" ! -iname "*.cxx" ! -iname "*.cpp" ! -iname "*.f" ! -iname "*.f90" ! -iname "*.png" ! -iname "*.sh" ! -iname "*.bat" ! -iname "*.tcl" ! -iname "*.cfg" ! -iname "*.md" ! -iname "*.in" ! -iname "*.pl" ! -iname "*.pm" ! -iname "*.pod" ! -iname "*.enc" ! -iname "*.msg" ! -iname "*.def" ! -iname "*.dll" ! -iname "*.m4" ! -iname "*.am" ! -iname "*.awk" ! -iname "*.scm" ! -iname "*.nls" ! -iname "*.info" ! -iname "*.ld" ! -iname "*.gif" ! -iname "*.pem" ! -iname "*.zip" ! -iname "*.tpl" ! -iname "*.tlib" | grep -v "/ldscripts/" | grep -v "/doc/" | grep -v "/locale/" | grep -v "/include/" | grep -v 'MacOSX.*\.sdk' | grep -v 'macOS.*\.sdk' | grep -v "/distro-info/" | sort
  elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
  then
    find "${folder_path}" -name \* -type f ! -iname "*.cmake" ! -iname "*.txt" ! -iname "*.rst" ! -iname "*.html" ! -iname "*.json" ! -iname "*.py" ! -iname "*.pyc" ! -iname "*.h" ! -iname "*.xml" ! -iname "*.a" ! -iname "*.la" ! -iname "*.spec" ! -iname "*.specs" ! -iname "*.decTest" ! -iname "*.exe" ! -iname "*.c" ! -iname "*.cxx" ! -iname "*.cpp" ! -iname "*.f" ! -iname "*.f90" ! -iname "*.png" ! -iname "*.sh" ! -iname "*.bat" ! -iname "*.tcl" ! -iname "*.cfg" ! -iname "*.md" ! -iname "*.in" ! -iname "*.pl" ! -iname "*.pm" ! -iname "*.pod" ! -iname "*.enc" ! -iname "*.msg" ! -iname "*.def" ! -iname "*.dll" ! -iname "*.m4" ! -iname "*.am" ! -iname "*.awk" ! -iname "*.scm" ! -iname "*.nls" ! -iname "*.info" ! -iname "*.ld" ! -iname "*.gif" ! -iname "*.pem" ! -iname "*.zip" ! -iname "*.tpl" ! -iname "*.tlib" | grep -v "/ldscripts/" | grep -v "/doc/" | grep -v "/locale/" | grep -v "/include/" | grep -v "/distro-info/" | sort
  else
    echo "Unsupported XBB_HOST_PLATFORM=${XBB_HOST_PLATFORM} in find binaries."
    exit 1
  fi
}

# The initial call uses the binary path (app or library, no links)
# and its folder path,
# so there is nothing to copy, only to process the dependencies.
#
# Subsequent calls may copy dependencies from other folders
# (like the installed/libs, or the compiler folders).
#
# On macOS, the destination may also be changed by existing LC_RPATH.
#
# Another complication is that the sources may be links, which must
# be preserved, but also the destinations must be copied.
#
# If needed, set PATCHELF to a newer version.

# $1 = source file path
# $2 = destination folder path
function copy_dependencies_recursive()
{
  if [ $# -lt 2 ]
  then
    echo "copy_dependencies_recursive requires at least 2 arg."
    exit 1
  fi

  (
    # set -x
    local realpath=$(which grealpath || which realpath || echo realpath)
    local readlink=$(which greadlink || which readlink || echo readlink)

    local source_file_path="$1"
    local destination_folder_path="$2"

    XBB_DO_COPY_XBB_LIBS=${XBB_DO_COPY_XBB_LIBS:-'n'}
    XBB_DO_COPY_GCC_LIBS=${XBB_DO_COPY_GCC_LIBS:-'n'}

    local source_file_name="$(basename "${source_file_path}")"
    local source_folder_path="$(dirname "${source_file_path}")"

    local destination_file_path="${destination_folder_path}/${source_file_name}"

    echo_develop "copy_dependencies_recursive $@"

    # The first step is to copy the file to the destination,
    # if not already there.

    # Assume a regular file. Later changed if link.
    local actual_source_file_path="${source_file_path}"
    local actual_destination_file_path="$(${realpath} ${destination_folder_path})/${source_file_name}"

    # echo "I. Processing ${source_file_path} itself..."

    if [ ! -f "${destination_file_path}" ]
    then

      if [ -L "${source_file_path}" ]
      then

        # Compute the final absolute path of the link, regardless
        # how many links there are on the way.
        echo "process link ${source_file_path}"

        actual_source_file_path="$(${readlink} -f "${source_file_path}")"
        actual_source_file_name="$(basename "${actual_source_file_path}")"

        actual_destination_file_path="${destination_folder_path}/${actual_source_file_name}"
        if [ -f "${actual_destination_file_path}" ]
        then
          actual_destination_file_path="$(${realpath} "${actual_destination_file_path}")"
        fi

        install_elf "${actual_source_file_path}" "${actual_destination_file_path}"

        (
          cd "${destination_folder_path}"
          run_verbose ln -s "${actual_source_file_name}" "${source_file_name}"
        )

      elif is_elf "${source_file_path}" || is_pe "${source_file_path}"
      then

        # The file is definitelly an elf, not a link.
        echo_develop "is_elf ${source_file_name}"

        install_elf "${source_file_path}" "${destination_file_path}"

      else

        file "${source_file_path}"
        echo "${source_file_path} not a symlink and not an elf"
        exit 1

      fi

    else
      echo_develop "already there ${destination_file_path}"
    fi

    # replace_loader_path "${actual_source_file_path}" "${actual_destination_file_path}"

    if [ "${XBB_WITH_STRIP}" == "y" -a ! -L "${actual_destination_file_path}" ]
    then
      strip_binary "${actual_destination_file_path}"
    fi

    local actual_destination_folder_path="$(dirname "${actual_destination_file_path}")"

    if [ "${XBB_HOST_PLATFORM}" == "linux" ]
    then

      echo
      echo "${actual_destination_file_path}:"
      readelf_shared_libs "${actual_destination_file_path}"

      # patch_linux_elf_origin "${actual_destination_file_path}"

      # echo "II. Processing ${source_file_path} dependencies..."

      # The file must be an elf. Get its shared libraries.
      local lib_names=$(readelf -d "${actual_destination_file_path}" \
            | grep -i 'Shared library' \
            | sed -e 's/.*Shared library: \[\(.*\)\]/\1/')
      local lib_name

      local linux_rpaths_line=$(get_linux_rpaths_line "${actual_destination_file_path}")

      # On Linux the references are library names.
      for lib_name in ${lib_names}
      do
        echo_develop
        echo_develop "processing ${lib_name} of ${actual_destination_file_path}"

        if is_linux_allowed_sys_so "${lib_name}"
        then
          echo_develop "${lib_name} is allowed sys so"
          continue # System library, no need to copy it.
        fi

        local origin_prefix="\$ORIGIN"
        local must_add_origin=""
        local was_processed=""

        if [ -z "${linux_rpaths_line}" ]
        then
          echo ">>> \"${actual_destination_file_path}\" has no rpath, patchelf may damage it!"
          linux_rpaths_line="${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/lib"
        fi

        for rpath in $(echo "${linux_rpaths_line}" | tr ":" "\n")
        do
          echo_develop "rpath ${rpath}"

          if [ "${rpath:0:1}" == "/" ]
          then
            # Absolute path.
            if [ -f "${rpath}/${lib_name}" ]
            then
              echo_develop "${lib_name} found in ${rpath}"
              # Library present in the absolute path

              # If outside XBB_APPLICATION_INSTALL_FOLDER_PATH, copy it to libexec,
              # otherwise leave it in place and add a new $ORIGIN.
              local rpath_relative_to_app_prefix="$(${realpath} --relative-to="${XBB_APPLICATION_INSTALL_FOLDER_PATH}" "${rpath}")"
              echo_develop "relative to XBB_APPLICATION_INSTALL_FOLDER_PATH ${rpath_relative_to_app_prefix}"
              # If the relative path starts with `..`, it is outside.
              if [ "${rpath_relative_to_app_prefix:0:2}" == ".." ]
              then
                copy_dependencies_recursive \
                  "${rpath}/${lib_name}" \
                  "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/libexec"

                must_add_origin="$(compute_origin_relative_to_libexec "${actual_destination_folder_path}")"
              else
                echo_develop "no need to copy to libexec"
                must_add_origin="$(compute_origin_relative_to_path ${rpath} "${actual_destination_folder_path}")"
              fi
              was_processed="y"
              break
            fi

          elif [ "${rpath:0:${#origin_prefix}}" == "${origin_prefix}" ]
          then
            # Looks like "", "/../lib"
            local file_relative_path="${rpath:${#origin_prefix}}"
            if [ -f "${actual_destination_folder_path}/${file_relative_path}/${lib_name}" ]
            then
              # Library present in the $ORIGIN path
              echo_develop "${lib_name} found in ${rpath}"
              was_processed="y"
              break
            fi
          else
            echo ">>> \"${rpath}\" with unsupported syntax"
            exit 1
          fi
        done

        if [ "${was_processed}" != "y" ]
        then
          # Perhas a compiler dependency.
          local full_path=$(${CC} -print-file-name=${lib_name})
          # -print-file-name outputs back the requested name if not found.

          if [ -f "$(dirname "${actual_source_file_path}")/${lib_name}"  ]
          then
            must_add_origin="\$ORIGIN"
          elif [ "${full_path}" != "${lib_name}" ]
          then
            echo_develop "${lib_name} found as ${CC} compiler file \"${full_path}\""
            copy_dependencies_recursive \
              "${full_path}" \
              "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/libexec"

            must_add_origin="$(compute_origin_relative_to_libexec "${actual_destination_folder_path}")"
          else
            echo ">>> \"${lib_name}\" of \"${actual_destination_file_path}\" not yet processed"
            exit 1
          fi
        fi

        if [ ! -z "${must_add_origin}" ]
        then
          patch_linux_elf_add_rpath \
            "${actual_destination_file_path}" \
            "${must_add_origin}"
        fi
      done

      echo
      echo "Processed ${actual_destination_file_path}:"
      readelf_shared_libs "${actual_destination_file_path}"

      # echo "iterate ${destination_folder_path}/${source_file_name} done"
    elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
    then

      # echo "II. Processing ${source_file_path} dependencies..."

      local lc_rpaths=$(get_darwin_lc_rpaths "${actual_destination_file_path}")
      local lc_rpaths_line=$(echo "${lc_rpaths}" | tr '\n' ':' | sed -e 's|:$||')

      echo
      if [ ! -z "${lc_rpaths_line}" ]
      then
        otool -L "${actual_destination_file_path}" | sed -e "1s|:|: (LC_RPATH=${lc_rpaths_line})|"
      else
        otool -L "${actual_destination_file_path}"
      fi

      local lib_paths=$(get_darwin_dylibs "${actual_destination_file_path}")

      local executable_prefix="@executable_path/"
      local loader_prefix="@loader_path/"
      local rpath_prefix="@rpath/"

      # On macOS 10.13 the references to dynamic libraries use full paths;
      # on 11.6 the paths are relative to @rpath.
      for lib_path in ${lib_paths}
      do
        # The path may be regular (absolute or relative), but may also be
        # relative to a special prefix (executable, loader, rpath).
        # The name usually is a link to more strictly versioned file.

        echo_develop
        echo_develop "processing ${lib_path} of ${actual_destination_file_path}"

        local from_path="${lib_path}"

        if [ "${lib_path:0:1}" == "@" ]
        then
          if [ "${lib_path:0:${#executable_prefix}}" == "${executable_prefix}" ]
          then
            echo ">>> \"${lib_path}\" is relative to unknown executable"
            exit 1
          elif [ "${lib_path:0:${#loader_prefix}}" == "${loader_prefix}" ]
          then
            # Adjust to original location.
            if [ -f "$(dirname "${actual_source_file_path}")/${lib_path:${#loader_prefix}}" ]
            then
              from_path="$(dirname "${actual_source_file_path}")/${lib_path:${#loader_prefix}}"
            else
              echo ">>> \"${lib_path}\" is not found in original folder"
              exit 1
            fi
          elif [ "${lib_path:0:${#rpath_prefix}}" == "${rpath_prefix}" ]
          then
            # Cases like @rpath/libstdc++.6.dylib; compute the absolute path.
            local found_absolute_lib_path=""
            local file_relative_path="${lib_path:${#rpath_prefix}}"
            for lc_rpath in ${lc_rpaths}
            do
              if [ "${lc_rpath:0:${#loader_prefix}}" == "${loader_prefix}" -o "${lc_rpath}/" == "${loader_prefix}" ]
              then
                # Use the original location.
                local maybe_file_path="$(dirname "${actual_source_file_path}")/${lc_rpath:${#loader_prefix}}/${file_relative_path}"
                echo_develop "maybe ${maybe_file_path}"
                if [ -f "${maybe_file_path}" ]
                then
                  found_absolute_lib_path="$(${realpath} ${maybe_file_path})"
                  break
                fi
                maybe_file_path="${actual_destination_folder_path}/${lc_rpath:${#loader_prefix}}/${file_relative_path}"
                echo_develop "maybe ${maybe_file_path}"
                if [ -f "${maybe_file_path}" ]
                then
                  found_absolute_lib_path="$(${realpath} ${maybe_file_path})"
                  break
                fi
                continue
              fi
              if [ "${lc_rpath:0:1}" != "/" ]
              then
                echo ">>> \"${lc_rpath}\" is not expected as LC_RPATH"
                exit 1
              fi
              if [ -f "${lc_rpath}/${file_relative_path}" ]
              then
                found_absolute_lib_path="$(${realpath} ${lc_rpath}/${file_relative_path})"
                break
              fi
            done
            if [ -z "${found_absolute_lib_path}" ]
            then
              # Not found in LC_RPATH, but is may be in LIBS_INSTALL.
              if [ -f "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/lib/${file_relative_path}" ]
              then
                found_absolute_lib_path="${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/lib/${file_relative_path}"
              fi
            fi
            if [ ! -z "${found_absolute_lib_path}" ]
            then
              from_path="${found_absolute_lib_path}"
              echo_develop "found ${from_path}"
            else
              echo ">>> \"${lib_path}\" not found in LC_RPATH"
              exit 1
            fi
          fi
        fi

        if [ "${from_path:0:1}" == "@" ]
        then
          echo_develop "already processed ${from_path}"
        elif [ "${from_path:0:1}" == "/" ]
        then
          # Regular absolute path, possibly a link.
          if is_darwin_sys_dylib "${from_path}"
          then
            if is_darwin_allowed_sys_dylib "${from_path}"
            then
              # Allowed system library, no need to copy it.
              echo_develop "${from_path} is allowed sys dylib"
              continue # Avoid recursive copy.
            elif [ "${lib_path:0:1}" == "/" ]
            then
              echo ">>> absolute \"${lib_path}\" not one of the allowed libs"
              exit 1
            fi
            # from_path already an actual absolute path.
          fi
        else
          ## Relative path.
          echo_develop "${lib_path} is a relative path"
          if [ -f "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/lib/${lib_path}" ]
          then
            # Make the from_path absolute.
            from_path="${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/lib/${lib_path}"
            echo_develop "using XBB_DEPENDENCIES_INSTALL_FOLDER_PATH ${from_path}"
          else
            echo ">>> Relative path ${lib_path} not found in libs/lib"
            exit 1
          fi
        fi

        # If outside XBB_APPLICATION_INSTALL_FOLDER_PATH, copy it to libexec,
        # otherwise leave it in place and add a new $ORIGIN.
        local rpath_relative_to_app_prefix="$(${realpath} --relative-to="${XBB_APPLICATION_INSTALL_FOLDER_PATH}" "${from_path}")"
        echo_develop "relative to XBB_APPLICATION_INSTALL_FOLDER_PATH ${rpath_relative_to_app_prefix}"
        # If the relative path starts with `..`, it is outside.
        if [ "${rpath_relative_to_app_prefix:0:2}" == ".." ]
        then

          # For consistency reasons, update rpath first, before dependencies.
          local relative_folder_path="$(${realpath} --relative-to="${actual_destination_folder_path}" "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/libexec")"
          patch_macos_elf_add_rpath \
            "${actual_destination_file_path}" \
            "${loader_prefix}${relative_folder_path}"

          if [ "${lib_path}" != "@rpath/$(basename "${from_path}")" ]
          then
            chmod +w "${actual_destination_file_path}"
            run_verbose install_name_tool \
              -change "${lib_path}" \
              "@rpath/$(basename "${from_path}")" \
              "${actual_destination_file_path}"
          fi

          copy_dependencies_recursive \
            "${from_path}" \
            "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/libexec"

        else

          echo_develop "no need to copy to libexec"
          local relative_lc_rpath="$(${realpath} --relative-to="${actual_destination_folder_path}" "$(dirname ${from_path})")"

          chmod +w "${actual_destination_file_path}"

          patch_macos_elf_add_rpath "${actual_destination_file_path}" "@loader_path/${relative_lc_rpath}"

          run_verbose install_name_tool \
            -change "${lib_path}" \
            "@rpath/$(basename "${from_path}")" \
            "${actual_destination_file_path}"

          show_libs "${actual_destination_file_path}"

        fi

      done

      (
        set +e

        lc_rpaths=$(get_darwin_lc_rpaths "${actual_destination_file_path}")
        lc_rpaths_line=$(echo "${lc_rpaths}" | tr '\n' ':' | sed -e 's|:$||')

        echo
        if [ ! -z "${lc_rpaths_line}" ]
        then
          otool -L "${actual_destination_file_path}" | sed -e "1s|^|Processed |" -e "1s|:|: (LC_RPATH=${lc_rpaths_line})|"
        else
          otool -L "${actual_destination_file_path}" | sed -e "1s|^|Processed |"
        fi
      )

    elif [ "${XBB_HOST_PLATFORM}" == "win32" ]
    then

      echo
      echo "${actual_destination_file_path}:"
      ${XBB_TARGET_TRIPLET}-objdump -x "${source_file_path}" \
            | grep -i 'DLL Name' || true

      local source_file_name="$(basename "${source_file_path}")"
      local source_folder_path="$(dirname "${source_file_path}")"

      # The first step is to copy the file to the destination.

      local actual_source_file_path=""
      local copied_file_path="${destination_folder_path}/${source_file_name}"

      # echo "I. Processing ${source_file_path} itself..."

      if [ ! -f "${destination_folder_path}/${source_file_name}" ]
      then

        # On Windows don't bother with sym links, simply copy the file
        # to the destination.

        actual_source_file_path="$(${readlink} -f "${source_file_path}")"
        copied_file_path="${destination_folder_path}/${source_file_name}"

      else
        echo_develop "${destination_folder_path}/${source_file_name} already there"
      fi

      if [ ! -z "${actual_source_file_path}" ]
      then
        if [ ! -f "${copied_file_path}" ]
        then
          if [ ! -d "$(dirname "${copied_file_path}")" ]
          then
            run_verbose install -d -m 755 "$(dirname "${copied_file_path}")"
          fi
          run_verbose install -c -m 755 "${actual_source_file_path}" "${copied_file_path}"
        fi
      else
        actual_source_file_path="${source_file_path}"
      fi

      if [ "${XBB_WITH_STRIP}" == "y" -a ! -L "${copied_file_path}" ]
      then
        strip_binary "${copied_file_path}"
      fi

      # If libexec is the destination, there is no need to link.
      if [ ! -f "${destination_folder_path}/${source_file_name}" ]
      then
        (
          cd "${destination_folder_path}"

          local link_relative_path="$(${realpath} --relative-to="${destination_folder_path}" "${copied_file_path}")"
          run_verbose ln -s "${link_relative_path}" "${source_file_name}"
        )
      fi

      local actual_destination_file_path="$(${realpath} "${destination_folder_path}/${source_file_name}")"
      local actual_destination_folder_path="$(dirname "${actual_destination_file_path}")"

      # echo "II. Processing ${source_file_path} dependencies..."

      local libs=$(${XBB_TARGET_TRIPLET}-objdump -x "${destination_folder_path}/${source_file_name}" \
            | grep -i 'DLL Name' \
            | sed -e 's/.*DLL Name: \(.*\)/\1/' \
          )
      local lib_name
      for lib_name in ${libs}
      do
        if [ -f "${destination_folder_path}/${lib_name}" ]
        then
          : # Already present in the same folder as the source.
        elif is_win_sys_dll "${lib_name}"
        then
          : # System DLL, no need to copy it.
        else
          local full_path=$(${XBB_TARGET_TRIPLET}-gcc -print-file-name=${lib_name})

          if [ -f "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/bin/${lib_name}" ]
          then
            # GCC leaves some .DLLs in bin.
            copy_dependencies_recursive \
              "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/bin/${lib_name}" \
              "${destination_folder_path}"
          elif [ -f "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/${XBB_TARGET_TRIPLET}/bin/${lib_name}" ]
          then
            # ... or in x86_64-w64-mingw32/bin
            copy_dependencies_recursive \
              "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/${XBB_TARGET_TRIPLET}/bin/${lib_name}" \
              "${destination_folder_path}"
          elif [ -f "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/bin/${lib_name}" ]
          then
            # These scripts leave libraries in install/libs/bin.
            copy_dependencies_recursive \
              "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}/bin/${lib_name}" \
              "${destination_folder_path}"
          elif [ "${XBB_DO_COPY_GCC_LIBS}" == "y" -a "${full_path}" != "${lib_name}" ]
          then
            # -print-file-name outputs back the requested name if not found.
            copy_dependencies_recursive \
              "${full_path}" \
              "${destination_folder_path}"
          elif false # [ "${XBB_DO_COPY_GCC_LIBS}" == "y" -a "${lib_name}" == "libwinpthread-1.dll" -a -f "${XBB_FOLDER_PATH}/usr/${XBB_TARGET_TRIPLET}/bin/libwinpthread-1.dll" ]
          then
            copy_dependencies_recursive \
              "${XBB_FOLDER_PATH}/usr/${XBB_TARGET_TRIPLET}/bin/libwinpthread-1.dll" \
              "${destination_folder_path}"
          else
            echo "${lib_name} required by ${source_file_name}, not found"
            exit 1
          fi
        fi
      done
    else
      echo "Unsupported XBB_HOST_PLATFORM=${XBB_HOST_PLATFORM} in copy dependencies."
      exit 1
    fi

    echo_develop "done with ${source_file_path}"
  )
}

function install_elf()
{
  local source_file_path="$1"
  local destination_file_path="$2"

  if [ ! -f "${destination_file_path}" ]
  then
    if [ ! -d "$(dirname "${destination_file_path}")" ]
    then
      run_verbose install -d -m 755 "$(dirname "${destination_file_path}")"
    fi
    run_verbose install -c -m 755 "${source_file_path}" "${destination_file_path}"
  fi
}

# Output the result of a filtered otool.
function get_darwin_lc_rpaths()
{
  local file_path="$1"

  otool -l "${file_path}" | grep LC_RPATH -A2 | grep '(offset ' | sed -e 's|.*path \(.*\) (offset.*)|\1|'
}

function get_darwin_dylibs()
{
  local file_path="$1"

  if is_darwin_dylib "${file_path}"
  then
    # Skip the extra line with the library name.
    otool -L "${file_path}" \
          | sed '1d' \
          | sed '1d' \
          | sed -e 's|[[:space:]]*\(.*\) (.*)|\1|' \

  else
    otool -L "${file_path}" \
          | sed '1d' \
          | sed -e 's|[[:space:]]*\(.*\) (.*)|\1|' \

  fi
}

function get_linux_rpaths_line()
{
  local file_path="$1"

  readelf -d "${file_path}" \
    | egrep '(RUNPATH|RPATH)' \
    | sed -e 's|.*\[\(.*\)\]|\1|'

}

function is_target()
{
  if [ $# -lt 1 ]
  then
    warning "is_target: Missing arguments"
    exit 1
  fi

  local bin_path="$1"

  # Symlinks do not match.
  if [ -L "${bin_path}" ]
  then
    return 1
  fi

  if [ -f "${bin_path}" ]
  then
    # Return 0 (true) if found.
    if [ "${XBB_HOST_PLATFORM}" == "linux" -a "${XBB_HOST_ARCH}" == "x64" ]
    then
      file ${bin_path} | egrep -q ", x86-64, "
    elif [ "${XBB_HOST_PLATFORM}" == "linux" -a \( "${XBB_HOST_ARCH}" == "x32" -o "${XBB_HOST_ARCH}" == "ia32" \) ]
    then
      file ${bin_path} | egrep -q ", Intel 80386, "
    elif [ "${XBB_HOST_PLATFORM}" == "linux" -a "${XBB_HOST_ARCH}" == "arm64" ]
    then
      file ${bin_path} | egrep -q ", ARM aarch64, "
    elif [ "${XBB_HOST_PLATFORM}" == "linux" -a "${XBB_HOST_ARCH}" == "arm" ]
    then
      file ${bin_path} | egrep -q ", ARM, "
    elif [ "${XBB_HOST_PLATFORM}" == "darwin" -a "${XBB_HOST_ARCH}" == "x64" ]
    then
      file ${bin_path} | egrep -q "x86_64"
    elif [ "${XBB_HOST_PLATFORM}" == "darwin" -a "${XBB_HOST_ARCH}" == "arm64" ]
    then
      file ${bin_path} | egrep -q "arm64"
    elif [ "${XBB_HOST_PLATFORM}" == "win32" -a "${XBB_HOST_ARCH}" == "x64" ]
    then
      file ${bin_path} | egrep -q " x86-64 "
    elif [ "${XBB_HOST_PLATFORM}" == "win32" -a \( "${XBB_HOST_ARCH}" == "x32" -o "${XBB_HOST_ARCH}" == "ia32" \) ]
    then
      file ${bin_path} | egrep -q " Intel 80386"
    else
      return 1
    fi
  else
    return 1
  fi
}

function is_darwin_dylib()
{
  if [ $# -lt 1 ]
  then
    warning "is_darwin_dylib: Missing arguments"
    exit 1
  fi

  local bin_path="$1"
  local real_path

  local realpath=$(which grealpath || which realpath || echo realpath)

  # Follow symlinks.
  if [ -L "${bin_path}" ]
  then
    real_path="$(${realpath} "${bin_path}")"
  else
    real_path="${bin_path}"
  fi

  if [ -f "${real_path}" ]
  then
    # Return 0 (true) if found.
    file ${real_path} | egrep -q "dynamically linked shared library"
  else
    return 1
  fi
}

# Links are automatically followed.
function is_darwin_sys_dylib()
{
  local lib_name="$1"

  if [[ ${lib_name} == /usr/lib* ]]
  then
    return 0 # True
  fi
  if [[ ${lib_name} == /System/Library/Frameworks/* ]]
  then
    return 0 # True
  fi
  if [[ ${lib_name} == /Library/Frameworks/* ]]
  then
    return 0 # True
  fi

  return 1 # False
}

function is_darwin_allowed_sys_dylib()
{
  local lib_name="$1"

  # Since there is no -static-libc++, the first attempt was to not
  # define these here and have the 10.x ones copied to the application.
  # Building CMake proved that this is ok with 10.11 and 10.12, but
  # fails on 10.13 and 10.14 with:
  # dyld: Symbol not found: __ZNSt3__118shared_timed_mutex13unlock_sharedEv
  # Referenced from: /System/Library/Frameworks/CoreDisplay.framework/Versions/A/CoreDisplay
  # Expected in: /Users/travis/test-cmake/xpack-cmake-3.17.1-1/bin/libc++.1.dylib
  # in /System/Library/Frameworks/CoreDisplay.framework/Versions/A/CoreDisplay
  #
  # /usr/lib/libc++.dylib \
  # /usr/lib/libc++.1.dylib \
  # /usr/lib/libc++abi.dylib \

  # Same for -static-libgcc; there were no cases which failed on later releases,
  # but for consistency, they are also included here.
  #
  # /usr/lib/libgcc_s.1.dylib \

  # /usr/lib/libz.1.dylib \
  # /usr/lib/libedit.3.dylib \

  local sys_libs=(\
    /usr/lib/libgcc_s.1.dylib \
    \
    /usr/lib/libc++.dylib \
    /usr/lib/libc++.1.dylib \
    /usr/lib/libc++abi.dylib \
    \
    /usr/lib/libSystem.B.dylib \
    /usr/lib/libobjc.A.dylib \
    /usr/lib/libicucore.A.dylib \
    \
    /usr/lib/libutil.dylib \
    /usr/lib/libcompression.dylib \
    /usr/lib/libpam.1.dylib \
    /usr/lib/libpam.2.dylib \
    /usr/lib/libsasl2.2.dylib \
    /usr/lib/libresolv.9.dylib \
    \
  )

  if [[ ${lib_name} == /System/Library/Frameworks/* ]]
  then
    # Allow all system frameworks.
    return 0 # True
  fi

  local lib
  for lib in "${sys_libs[@]}"
  do
    if [ "${lib}" == "${lib_name}" ]
    then
      return 0 # True
    fi
  done
  return 1 # False
}

function is_linux_allowed_sys_so()
{
  local lib_name="$1"

  # Do not add these two, they are present if the toolchain is installed,
  # but this is not guaranteed, so better copy them from the xbb toolchain.
  # libstdc++.so.6
  # libgcc_s.so.1

  # Shared libraries that are expected to be present on any Linux.
  # Note the X11 libraries.
  # libnsl.so.1 - not available on RedHat
  local sys_lib_names=(\
    librt.so.1 \
    libm.so.6 \
    libc.so.6 \
    libutil.so.1 \
    libpthread.so.0 \
    libdl.so.2 \
    ld-linux.so.2 \
    ld-linux.so.3 \
    ld-linux-x86-64.so.2 \
    ld-linux-armhf.so.3 \
    ld-linux-arm64.so.1 \
    ld-linux-aarch64.so.1 \
    libX11.so.6 \
    libXau.so.6 \
    libxcb.so.1 \
  )

  local sys_lib_name
  for sys_lib_name in "${sys_lib_names[@]}"
  do
    if [ "${lib_name}" == "${sys_lib_name}" ]
    then
      return 0 # True
    fi
  done
  return 1 # False
}

function is_win_sys_dll()
{
  local dll_name="$(echo "$1" | tr "[:upper:]" "[:lower:]")"

  # DLLs that are expected to be present on any Windows.
  # Be sure all names are lower case!
  local sys_dlls=( \
    advapi32.dll \
    bcrypt.dll \
    cabinet.dll \
    cfgmgr32.dll \
    comctl32.dll
    crypt32.dll \
    dbghelp.dll \
    dnsapi.dll \
    gdi32.dll \
    imm32.dll \
    imm32.dll \
    iphlpapi.dll \
    iphlpapi.dll \
    kernel32.dll \
    msi.dll \
    msvcr71.dll \
    msvcr80.dll \
    msvcr90.dll \
    msvcrt.dll \
    ole32.dll \
    oleaut32.dll \
    psapi.dll \
    rpcrt4.dll \
    setupapi.dll \
    shell32.dll \
    shlwapi.dll \
    user32.dll \
    userenv.dll \
    vcruntime140.dll \
    version.dll \
    winmm.dll \
    winmm.dll \
    ws2_32.dll \
    \
    api-ms-win-core-path-l1-1-0.dll \
    api-ms-win-crt-conio-l1-1-0.dll \
    api-ms-win-crt-convert-l1-1-0.dll \
    api-ms-win-crt-environment-l1-1-0.dll \
    api-ms-win-crt-filesystem-l1-1-0.dll \
    api-ms-win-crt-heap-l1-1-0.dll \
    api-ms-win-crt-locale-l1-1-0.dll \
    api-ms-win-crt-math-l1-1-0.dll \
    api-ms-win-crt-multibyte-l1-1-0.dll \
    api-ms-win-crt-private-l1-1-0.dll \
    api-ms-win-crt-process-l1-1-0.dll \
    api-ms-win-crt-runtime-l1-1-0.dll \
    api-ms-win-crt-string-l1-1-0.dll \
    api-ms-win-crt-stdio-l1-1-0.dll \
    api-ms-win-crt-time-l1-1-0.dll \
    api-ms-win-crt-utility-l1-1-0.dll \
  )

  # The Python DLL were a permanent source of trouble.
  # python27.dll \
  # The latest Python 2.7.18 has no DLL at all, so it cannot be skipped.
  # python37.dll \
  # The Python 3 seems better, allow to copy it in the archive,
  # to be sure it matches the version used during build.

  local dll
  for dll in "${sys_dlls[@]}"
  do
    if [ "${dll}" == "${dll_name}" ]
    then
      return 0 # True
    fi
  done
  return 1 # False
}

function is_ar()
{
  if [ $# -lt 1 ]
  then
    warning "is_ar: Missing arguments"
    exit 1
  fi

  local bin_path="$1"

  # Symlinks do not match.
  if [ -L "${bin_path}" ]
  then
    return 1
  fi

  if [ -f "${bin_path}" ]
  then
    # Return 0 (true) if found.
    file ${bin_path} | egrep -q "ar archive"
  else
    return 1
  fi
}

function has_origin()
{
  if [ $# -lt 1 ]
  then
    warning "has_origin: Missing file argument"
    exit 1
  fi

  local elf="$1"
  if [ "${XBB_HOST_PLATFORM}" == "linux" ]
  then
    local origin=$(readelf -d ${elf} | egrep '(RUNPATH|RPATH)' | egrep '\$ORIGIN')
    if [ ! -z "${origin}" ]
    then
      return 0 # true
    fi
  fi
  return 1 # false
}

function has_rpath_origin()
{
  if [ $# -lt 1 ]
  then
    warning "has_rpath_origin: Missing file argument"
    exit 1
  fi

  local elf="$1"
  if [ "${XBB_HOST_PLATFORM}" == "linux" ]
  then
    local origin=$(readelf -d ${elf} | grep 'Library rpath: \[' | grep '\$ORIGIN')
    if [ ! -z "${origin}" ]
    then
      return 0 # true
    fi
  fi
  return 1 # false
}

# DT_RPATH is searchd before LD_LIBRARY_PATH and DT_RUNPATH.
function has_rpath()
{
  if [ $# -lt 1 ]
  then
    warning "has_rpath: Missing file argument"
    exit 1
  fi

  local elf="$1"
  if [ "${XBB_HOST_PLATFORM}" == "linux" ]
  then

    local rpath=$(readelf -d ${elf} | egrep '(RUNPATH|RPATH)')
    if [ ! -z "${rpath}" ]
    then
      return 0 # true
    fi

  fi
  return 1 # false
}

# -----------------------------------------------------------------------------

# https://wincent.com/wiki/%40executable_path%2C_%40load_path_and_%40rpath
# @loader_path = the path of the elf refering it (like $ORIGIN) (since 10.4)
# @rpath = one of the LC_RPATH array stored in the elf (since 10.5)
# @executable_path = the path of the application loading the shared library

function patch_macos_elf_add_rpath()
{
  if [ $# -lt 2 ]
  then
    echo "patch_macos_elf_add_rpath requires 2 args."
    exit 1
  fi

  local file_path="$1"
  local new_rpath="$2"

  if [ "${new_rpath:(-2)}" == "/." ]
  then
    let remaining=${#new_rpath}-2
    new_rpath=${new_rpath:0:${remaining}}
  fi

  # On macOS there are no fully statical executables, so all must be processed.

  if [ -z "${new_rpath}" ]
  then
    echo "patch_macos_elf_add_rpath new path cannot be empty."
    exit 1
  fi

  local lc_rpaths=$(get_darwin_lc_rpaths "${file_path}")
  for lc_rpath in ${lc_rpaths}
  do
    if [ "${new_rpath}" == "${lc_rpath}" ]
    then
      # Already there.
      return
    fi
  done

  chmod +w "${file_path}"
  run_verbose install_name_tool \
    -add_rpath "${new_rpath}" \
    "${file_path}"

}

# Remove non relative LC_RPATH entries.
# $1 = file path
function clean_rpaths()
{
  local file_path="$1"

  if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
  then
    (
      local lc_rpaths=$(get_darwin_lc_rpaths "${file_path}")
      if [ -z "${lc_rpaths}" ]
      then
        return
      fi

      local loader_prefix="@loader_path/"
      local rpath_prefix="@rpath/"

      for lc_rpath in ${lc_rpaths}
      do
        local is_found=""
        if [ "${lc_rpath}/" == "${loader_prefix}" -o \
          "${lc_rpath:0:${#loader_prefix}}" == "${loader_prefix}" ]
        then
          # May be empty.
          local rpath_relative_path="${lc_rpath:${#loader_prefix}}"

          local lib_paths=$(get_darwin_dylibs "${file_path}")
          for lib_path in ${lib_paths}
          do
            if [ "${lib_path:0:${#rpath_prefix}}" == "${rpath_prefix}" ]
            then
              local file_name="${lib_path:${#rpath_prefix}}"

              local maybe_file_path="$(dirname "${file_path}")/${rpath_relative_path}/${file_name}"
              if [ -f "${maybe_file_path}" ]
              then
                is_found="y"
                echo_develop "${maybe_file_path}, ${lc_rpath} retained"
                break
              fi
            fi
          done
        fi

        if [ "${is_found}" != "y" ]
        then
          # Not recognized, deleted.
          run_verbose install_name_tool \
            -delete_rpath "${lc_rpath}" \
            "${file_path}"
        fi
      done
    )
  elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
  then

      local origin_prefix="\$ORIGIN"
      local new_rpath=""

      local linux_rpaths_line=$(get_linux_rpaths_line "${file_path}")

      if [ -z "${linux_rpaths_line}" ]
      then
        return
      fi

      for rpath in $(echo "${linux_rpaths_line}" | tr ":" "\n")
      do
        if [ "${rpath:0:${#origin_prefix}}" == "${origin_prefix}" ]
        then
          if [ ! -z "${new_rpath}" ]
          then
            new_rpath+=":"
          fi
          new_rpath+="${rpath}"
        fi
      done

      if [ -z "${new_rpath}" ]
      then
        new_rpath="${origin_prefix}"
      fi

      patch_linux_elf_set_rpath \
        "${file_path}" \
        "${new_rpath}"

  else
    echo "Unsupported XBB_HOST_PLATFORM=${XBB_HOST_PLATFORM} in clean rpaths."
    exit 1
  fi
}

# Workaround to Docker error on 32-bit image:
# stat: Value too large for defined data type (requires -D_FILE_OFFSET_BITS=64)
function patch_linux_elf_origin()
{
  if [ $# -lt 1 ]
  then
    echo "patch_linux_elf_origin requires 1 args."
    exit 1
  fi

  local file_path="$1"
  local libexec_path
  if [ $# -ge 2 ]
  then
    libexec_path="$2"
  else
    libexec_path="$(dirname "${file_path}")"
  fi

  local do_require_rpath="${XBB_DO_REQUIRE_RPATH:-"y"}"

  local patchelf=${PATCHELF:-$(which patchelf || echo patchelf)}
  # run_verbose "${patchelf}" --version
  # run_verbose "${patchelf}" --help

  local patchelf_has_output=""
  local use_copy_hack="${XBB_USE_COPY_HACK:-"n"}"
  if [ "${use_copy_hack}" == "y" ]
  then
    local tmp_path=$(mktemp)
    rm -rf "${tmp_path}"
    cp "${file_path}" "${tmp_path}"
    if "${patchelf}" --help 2>&1 | egrep -q -e '--output'
    then
      patchelf_has_output="y"
    fi
  else
    local tmp_path="${file_path}"
  fi

  if file "${tmp_path}" | grep statically
  then
    file "${file_path}"
  else
    if ! has_rpath "${file_path}"
    then
      echo "patch_linux_elf_origin: ${file_path} has no rpath!"
      if [ "${do_require_rpath}" == "y" ]
      then
        exit 1
      fi
    fi

    if [ "${patchelf_has_output}" == "y" ]
    then
      echo "[${patchelf} --force-rpath --set-rpath \"\$ORIGIN\" --output \"${file_path}\" \"${tmp_path}\"]"
      ${patchelf} --force-rpath --set-rpath "\$ORIGIN" --output "${file_path}" "${tmp_path}"
    else
      echo "[${patchelf} --force-rpath --set-rpath \"\$ORIGIN\" \"${file_path}\"]"
      ${patchelf} --force-rpath --set-rpath "\$ORIGIN" "${tmp_path}"
      if [ "${use_copy_hack}" == "y" ]
      then
        cp "${tmp_path}" "${file_path}"
      fi
    fi

    if [ "${XBB_IS_DEVELOP}" == "y" ]
    then
      readelf -d "${tmp_path}" | egrep '(RUNPATH|RPATH)'
      ldd "${tmp_path}"
    fi

  fi
  if [ "${use_copy_hack}" == "y" ]
  then
    rm -rf "${tmp_path}"
  fi
}

function patch_linux_elf_set_rpath()
{
  if [ $# -lt 2 ]
  then
    echo "patch_linux_elf_set_rpath requires 2 args."
    exit 1
  fi

  local file_path="$1"
  local new_rpath="$2"

  if [ "${new_rpath:(-2)}" == "/." ]
  then
    let remaining=${#new_rpath}-2
    new_rpath=${new_rpath:0:${remaining}}
  fi

  local do_require_rpath="${XBB_DO_REQUIRE_RPATH:-"y"}"

  if file "${file_path}" | grep statically
  then
    file "${file_path}"
  else
    local patchelf=${PATCHELF:-$(which patchelf || echo patchelf)}
    # run_verbose "${patchelf}" --version
    # run_verbose "${patchelf}" --help

    local patchelf_has_output=""
    local use_copy_hack="${XBB_USE_COPY_HACK:-"n"}"
    if [ "${use_copy_hack}" == "y" ]
    then
      local tmp_path=$(mktemp)
      rm -rf "${tmp_path}"
      cp "${file_path}" "${tmp_path}"
      if "${patchelf}" --help 2>&1 | egrep -q -e '--output'
      then
        patchelf_has_output="y"
      fi
    else
      local tmp_path="${file_path}"
    fi

    if ! has_rpath "${file_path}"
    then
      echo "patch_linux_elf_set_rpath: ${file_path} has no rpath!"
      if [ "${do_require_rpath}" == "y" ]
      then
        exit 1
      fi
    fi

    if [ "${patchelf_has_output}" == "y" ]
    then
      echo "[${patchelf} --force-rpath --set-rpath \"${new_rpath}\" --output \"${file_path}\" \"${tmp_path}\"]"
      ${patchelf} --force-rpath --set-rpath "${new_rpath}" --output "${file_path}" "${tmp_path}"
    else
      echo "[${patchelf} --force-rpath --set-rpath \"${new_rpath}\" \"${file_path}\"]"
      ${patchelf} --force-rpath --set-rpath "${new_rpath}" "${tmp_path}"
      if [ "${use_copy_hack}" == "y" ]
      then
        cp "${tmp_path}" "${file_path}"
      fi
    fi

    if [ "${XBB_IS_DEVELOP}" == "y" ]
    then
      readelf -d "${tmp_path}" | egrep '(RUNPATH|RPATH)'
      ldd "${tmp_path}"
    fi

    if [ "${use_copy_hack}" == "y" ]
    then
      rm -rf "${tmp_path}"
    fi
  fi
}

function patch_linux_elf_add_rpath()
{
  if [ $# -lt 2 ]
  then
    echo "patch_linux_elf_add_rpath requires 2 args."
    exit 1
  fi

  local file_path="$1"
  local new_rpath="$2"

  if [ "${new_rpath:(-2)}" == "/." ]
  then
    let remaining=${#new_rpath}-2
    new_rpath=${new_rpath:0:${remaining}}
  fi

  local do_require_rpath="${XBB_DO_REQUIRE_RPATH:-"y"}"

  if file "${file_path}" | grep statically
  then
    file "${file_path}"
  else
    if [ -z "${new_rpath}" ]
    then
      echo "patch_linux_elf_add_rpath new path cannot be empty."
      exit 1
    fi

    local linux_rpaths_line=$(get_linux_rpaths_line "${file_path}")

    if [ -z "${linux_rpaths_line}" ]
    then
      echo "patch_linux_elf_add_rpath: ${file_path} has no rpath!"
      if [ "${do_require_rpath}" == "y" ]
      then
        exit 1
      fi
    else
      for rpath in $(echo "${linux_rpaths_line}" | tr ":" "\n")
      do
        if [ "${rpath}" == "${new_rpath}" ]
        then
          # Already there.
          return
        fi
      done

      new_rpath="${linux_rpaths_line}:${new_rpath}"
    fi

    local patchelf=${PATCHELF:-$(which patchelf || echo patchelf)}
    # run_verbose "${patchelf}" --version
    # run_verbose "${patchelf}" --help

    local patchelf_has_output=""
    local use_copy_hack="${XBB_USE_COPY_HACK:-"n"}"
    if [ "${use_copy_hack}" == "y" ]
    then
      local tmp_path=$(mktemp)
      rm -rf "${tmp_path}"
      cp "${file_path}" "${tmp_path}"
      if "${patchelf}" --help 2>&1 | egrep -q -e '--output'
      then
        patchelf_has_output="y"
      fi
    else
      local tmp_path="${file_path}"
    fi

    if [ "${patchelf_has_output}" == "y" ]
    then
      echo "[${patchelf} --force-rpath --set-rpath \"${new_rpath}\" --output \"${file_path}\" \"${tmp_path}\"]"
      ${patchelf} --force-rpath --set-rpath "${new_rpath}" --output "${file_path}" "${tmp_path}"
    else
      echo "[${patchelf} --force-rpath --set-rpath \"${new_rpath}\" \"${file_path}\"]"
      ${patchelf} --force-rpath --set-rpath "${new_rpath}" "${tmp_path}"
      if [ "${use_copy_hack}" == "y" ]
      then
        cp "${tmp_path}" "${file_path}"
      fi
    fi

    if [ "${XBB_IS_DEVELOP}" == "y" ]
    then
      readelf -d "${tmp_path}" | egrep '(RUNPATH|RPATH)'
      ldd "${tmp_path}"
    fi

    if [ "${use_copy_hack}" == "y" ]
    then
      rm -rf "${tmp_path}"
    fi
  fi
}

# Compute the $ORIGIN from the given folder path to libexec.
function compute_origin_relative_to_libexec()
{
  if [ $# -lt 1 ]
  then
    echo "compute_origin_relative_to_libexec requires 1 arg."
    exit 1
  fi

  local folder_path="$1"

  local realpath=$(which grealpath || which realpath || echo realpath)

  local relative_folder_path="$(${realpath} --relative-to="${folder_path}" "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/libexec")"

  echo "\$ORIGIN/${relative_folder_path}"
}

# Compute the $ORIGIN from the given folder path to the reference.
function compute_origin_relative_to_path()
{
  if [ $# -lt 2 ]
  then
    echo "compute_origin_relative_to_path requires 2 args."
    exit 1
  fi

  local reference_folder_path="$1"
  local folder_path="$2"

  local realpath=$(which grealpath || which realpath || echo realpath)

  local relative_folder_path="$(${realpath} --relative-to="${folder_path}" "${reference_folder_path}")"

  echo "\$ORIGIN/${relative_folder_path}"
}

# -----------------------------------------------------------------------------

function strip_binaries()
{
  local folder_path="${XBB_APPLICATION_INSTALL_FOLDER_PATH}"
  if [ $# -ge 1 ]
  then
    folder_path="$1"
  fi

  if [ "${XBB_WITH_STRIP}" == "y" ]
  then
    (
      echo
      echo "# Stripping binaries..."

      # Otherwise `find` may fail.
      cd "${XBB_TARGET_WORK_FOLDER_PATH}"

      local binaries
      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then

        binaries=$(find "${folder_path}" \( -name \*.exe -o -name \*.dll -o -name \*.pyd \))
        for bin in ${binaries}
        do
          strip_binary "${bin}"
        done

      elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
      then

        binaries=$(find "${folder_path}" -name \* -perm +111 -type f ! -type l | grep -v 'MacOSX.*\.sdk' | grep -v 'macOS.*\.sdk' )
        for bin in ${binaries}
        do
          if is_elf "${bin}"
          then
            if is_target "${bin}"
            then
              strip_binary "${bin}"
            else
              echo_develop "$(file "${bin}") (not for target architecture)"
            fi
          fi
        done

      elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
      then

        binaries=$(find "${folder_path}" -name \* -type f ! -type l)
        for bin in ${binaries}
        do
          if is_elf "${bin}"
          then
            if is_target "${bin}"
            then
              strip_binary "${bin}"
            else
              echo_develop "$(file "${bin}") (not for target architecture)"
            fi
          fi
        done

      fi
    )
  fi
}

function strip_binary()
{
  if [ $# -lt 1 ]
  then
    warning "strip_binary: Missing file argument"
    exit 1
  fi

  local file_path="$1"

  local strip
  set +u
  strip="${STRIP}"
  if [ "${XBB_HOST_PLATFORM}" == "win32" ]
  then
    if [ -z "${strip}" ]
    then
      strip="${XBB_TARGET_TRIPLET}-strip"
    fi
    if [[ "${file_path}" != *.exe ]] && [[ "${file_path}" != *.dll ]] && [[ "${file_path}" != *.pyd ]]
    then
      file_path="${file_path}.exe"
    fi
  else
    if [ -L "${file_path}" ]
    then
      echo "??? '${file_path}' should not strip links"
      exit 1
    fi
    if [ -z "${strip}" ]
    then
      strip="strip"
    fi
  fi
  set -u

  if is_elf "${file_path}" || is_pe "${file_path}"
  then
    :
  else
    echo $(file "${file_path}")
    return
  fi

  # Deprecated? Not yet, gcc still sigfaults.
  if has_origin "${file_path}"
  then
    # If the file was patched, skip strip, otherwise
    # we may damage the binary due to a bug in strip.
    echo "${strip} ${file_path} skipped (patched)"
    return
  fi

  echo "[${strip} ${file_path}]"
  if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
  then
    # Remove the debugging symbol table entries; there is no --strip-unneeded.
    "${strip}" -S "${file_path}" || true
  else
    "${strip}" --strip-unneeded "${file_path}" || true
  fi
}

# -----------------------------------------------------------------------------

function copy_distro_files()
{
  (
    echo
    mkdir -pv "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/${XBB_DISTRO_INFO_NAME}"

    echo
    echo "# Copying xPack files..."

    cd "${XBB_BUILD_GIT_PATH}"
    local readme_out_file_name="${readme_out_file_name:-README-OUT.md}"
    install -v -c -m 644 "scripts/${readme_out_file_name}" \
      "${XBB_APPLICATION_INSTALL_FOLDER_PATH}/README.md"
  )
}

# Override it in the project, if needed.
function copy_custom_files()
{
  :
}

# -----------------------------------------------------------------------------

# Copy one folder to another
function copy_dir()
{
  local from_path="$1"
  local to_path="$2"

  set +u
  # rm -rf "${to_path}"
  mkdir -pv "${to_path}"

  (
    cd "${from_path}"
    if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
    then
      find . -xdev -print0 | cpio -oa0 | (cd "${to_path}" && cpio -im)
    else
      find . -xdev -print0 | cpio -oa0V | (cd "${to_path}" && cpio -imuV)
    fi
  )

  set -u
}

# -----------------------------------------------------------------------------

# Check all executables and shared libraries in the given folder.

# $1 = folder path (default ${XBB_APPLICATION_INSTALL_FOLDER_PATH})
function check_binaries()
{
  local folder_path="${XBB_APPLICATION_INSTALL_FOLDER_PATH}"
  if [ $# -ge 1 ]
  then
    folder_path="$1"
  fi

  (
    echo
    echo "# Checking binaries for unwanted libraries..."

    # Otherwise `find` may fail.
    cd "${XBB_TARGET_WORK_FOLDER_PATH}"

    local binaries
    if [ "${XBB_HOST_PLATFORM}" == "win32" ]
    then

      binaries=$(find_binaries "${folder_path}")
      for bin in ${binaries}
      do
        check_binary "${bin}"
      done

    elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
    then

      binaries=$(find_binaries "${folder_path}")
      for bin in ${binaries}
      do
        if is_elf "${bin}"
        then
          check_binary "${bin}"
        else
          echo_develop "$(file "${bin}") (not elf)"
        fi
      done

    elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
    then

      binaries=$(find_binaries "${folder_path}")
      for bin in ${binaries}
      do
        if is_elf_dynamic "${bin}"
        then
          check_binary "${bin}"
        else
          echo_develop "$(file "${bin}") (not dynamic elf)"
        fi
      done

    else
      echo "Unsupported XBB_HOST_PLATFORM=${XBB_HOST_PLATFORM} in check binaries."
      exit 1
    fi
  ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/check-binaries-output-$(ndate).txt"
}

function check_binary()
{
  local file_path="$1"

  if file --mime "${file_path}" | grep -q text
  then
    echo "${file_path} has no text"
    return 0
  fi

  check_binary_for_libraries "$1"
}

function check_binary_for_libraries()
{
  local file_path="$1"
  local file_name="$(basename ${file_path})"
  local folder_path="$(dirname ${file_path})"

  (
    if [ "${XBB_HOST_PLATFORM}" == "win32" ]
    then
      echo
      echo "${file_name}: (${file_path})"
      set +e
      ${XBB_TARGET_TRIPLET}-objdump -x "${file_path}" | grep -i 'DLL Name'

      local dll_names=$(${XBB_TARGET_TRIPLET}-objdump -x "${file_path}" \
        | grep -i 'DLL Name' \
        | sed -e 's/.*DLL Name: \(.*\)/\1/' \
      )

      local n
      for n in ${dll_names}
      do
        if [ ! -f "${folder_path}/${n}" ]
        then
          if is_win_sys_dll "${n}"
          then
            :
          elif [ "${n}${XBB_HAS_WINPTHREAD}" == "libwinpthread-1.dlly" ]
          then
            :
          else
            echo "Unexpected |${n}|"
            exit 1
          fi
        fi
      done
      set -e
    elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
    then
      local lc_rpaths=$(get_darwin_lc_rpaths "${file_path}")

      echo
      (
        set +e
        cd ${folder_path}
        local lc_rpaths_line=$(echo "${lc_rpaths}" | tr '\n' ':' | sed -e 's|:$||')
        if [ ! -z "${lc_rpaths_line}" ]
        then
          echo "${file_name}: (${file_path}, LC_RPATH=${lc_rpaths_line})"
        else
          echo "${file_name}: (${file_path})"
        fi

        otool -L "${file_name}" | tail -n +2
        set -e
      )

      # Skip the first line which is the binary itself.
      local libs
      if is_darwin_dylib "${file_path}"
      then
        # Skip the second line too, which is the library again.
        lib_paths=$(otool -L "${file_path}" \
              | sed '1d' \
              | sed '1d' \
              | sed -e 's|[[:space:]]*\(.*\) (.*)|\1|' \
            )
      else
        lib_paths=$(otool -L "${file_path}" \
              | sed '1d' \
              | sed -e 's|[[:space:]]*\(.*\) (.*)|\1|' \
            )
      fi

      # For debug, use DYLD_PRINT_LIBRARIES=1
      # https://medium.com/@donblas/fun-with-rpath-otool-and-install-name-tool-e3e41ae86172

      for lib_path in ${lib_paths}
      do
        if [ "${lib_path:0:1}" == "/" ]
        then
          # If an absolute path, it must be in the system.
          if is_darwin_allowed_sys_dylib "${lib_path}"
          then
            :
          else
            echo ">>> absolute \"${lib_path}\" not one of the allowed libs"
            exit 1
          fi

        elif [ "${lib_path:0:1}" == "@" ]
        then

          local executable_prefix="@executable_path/"
          local loader_prefix="@loader_path/"
          local rpath_prefix="@rpath/"

          if [ "${lib_path:0:${#executable_prefix}}" == "${executable_prefix}" ]
          then
            echo ">>> \"${lib_path}\" is relative to unknown executable"
            exit 1
          elif [ "${lib_path:0:${#loader_prefix}}" == "${loader_prefix}" ]
          then
            echo ">>> \"${lib_path}\" was not processed, bust be @rpath/xx"
            exit 1
          elif [ "${lib_path:0:${#rpath_prefix}}" == "${rpath_prefix}" ]
          then
            # The normal case, the LC_RPATH must be set properly.
            local file_relative_path="${lib_path:${#rpath_prefix}}"
            local is_found=""
            for lc_rpath in ${lc_rpaths}
            do
              if [ "${lc_rpath:0:${#loader_prefix}}/" == "${loader_prefix}" ]
              then
                if [ "${folder_path}/${file_relative_path}" ]
                then
                  is_found="y"
                  break
                fi
              elif [ "${lc_rpath:0:${#loader_prefix}}" == "${loader_prefix}" ]
              then
                local actual_folder_path=${folder_path}/${lc_rpath:${#loader_prefix}}
                if [ -f "${actual_folder_path}/${lib_path:${#rpath_prefix}}" ]
                then
                  is_found="y"
                  break
                fi
              else
                echo ">>> LC_RPATH=${lc_rpath} syntax not supported"
                exit 1
              fi
            done
            if [ "${is_found}" != "y" ]
            then
              echo ">>> ${file_relative_path} not found in LC_RPATH"
              exit 1
            fi
          else
            echo ">>> special relative \"${lib_path}\" not supported"
            exit 1
          fi

        else
          echo ">>> \"${lib_path}\" with unsupported syntax"
          exit 1
        fi
      done

      (
        # More or less deprecated by the above, but kept for just in case.
        set +e
        local unxp
        if [[ "${file_name}" == *\.dylib ]]
        then
          unxp=$(otool -L "${file_path}" | sed '1d' | sed '1d' | grep -v "${file_name}" | egrep -e "(macports|homebrew|opt|install)/")
        else
          unxp=$(otool -L "${file_path}" | sed '1d' | grep -v "${file_name}" | egrep -e "(macports|homebrew|opt|install)/")
        fi

        # echo "|${unxp}|"
        if [ ! -z "$unxp" ]
        then
          echo "Unexpected |${unxp}|"
          exit 1
        fi
        set -e
      )
    elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
    then
      echo
      echo "${file_name}: (${file_path})"
      set +e
      readelf_shared_libs "${file_path}"

      local so_names=$(readelf -d "${file_path}" \
        | grep -i 'Shared library' \
        | sed -e 's/.*Shared library: \[\(.*\)\]/\1/' \
      )

      # local relative_path=$(readelf -d "${file_path}" | egrep '(RUNPATH|RPATH)' | sed -e 's/.*\[\$ORIGIN//' | sed -e 's/\].*//')
      # echo $relative_path
      local linux_rpaths_line=$(get_linux_rpaths_line "${file_path}")
      local origin_prefix="\$ORIGIN"

      for so_name in ${so_names}
      do
        if is_linux_allowed_sys_so "${so_name}"
        then
          continue
        elif [[ ${so_name} == libpython* ]] && [[ ${file_name} == *-gdb-py ]]
        then
          continue
        else
          local found=""
          for rpath in $(echo "${linux_rpaths_line}" | tr ":" "\n")
          do
            if  [ "${rpath:0:${#origin_prefix}}" == "${origin_prefix}" ]
            then
              # Looks like "", "/../lib"
              local folder_relative_path="${rpath:${#origin_prefix}}"

              if [ -f "${folder_path}${folder_relative_path}/${so_name}" ]
              then
                found="y"
                break
              fi
            else
              echo ">>> DT_RPATH \"${rpath}\" not supported"
            fi
          done

          if [ "${found}" != "y" ]
          then
            echo ">>> Library \"${so_name}\" not found in DT_RPATH"
            exit 1
          fi
        fi
      done
      set -e
    else
      echo "Unsupported XBB_HOST_PLATFORM=${XBB_HOST_PLATFORM} in check binary for libraries."
      exit 1
    fi
  )
}

# -----------------------------------------------------------------------------

function create_archive()
{
  (
    local distribution_file_version="${XBB_RELEASE_VERSION}"

    local target_folder_name=${XBB_TARGET_FOLDER_NAME}

    local distribution_file="${XBB_DEPLOY_FOLDER_PATH}/${XBB_APPLICATION_DISTRO_LOWER_CASE_NAME}-${XBB_APPLICATION_LOWER_CASE_NAME}-${distribution_file_version}-${target_folder_name}"

    local archive_version_path
    archive_version_path="${XBB_ARCHIVE_FOLDER_PATH}/${XBB_APPLICATION_DISTRO_LOWER_CASE_NAME}-${XBB_APPLICATION_LOWER_CASE_NAME}-${distribution_file_version}"

    cd "${XBB_APPLICATION_INSTALL_FOLDER_PATH}"
    find . -name '.DS_Store' -exec rm '{}' ';'

    echo
    echo "# Creating distribution..."

    mkdir -pv "${XBB_DEPLOY_FOLDER_PATH}"

    # The folder is temprarily moved into a versioned folder like
    # xpack-<app-name>-<version>, or, in previous versions,
    # in a more elaborate hierarchy like
    # xPacks/<app-name>/<version>.
    # After the archive is created, the folders are moved back.
    # The atempt to transform the tar path fails, since symlinks were
    # also transformed, which is bad.
    if [ "${XBB_HOST_PLATFORM}" == "win32" ]
    then

      local distribution_file="${distribution_file}.zip"

      echo
      echo "ZIP file: \"${distribution_file}\"."

      rm -rf "${XBB_ARCHIVE_FOLDER_PATH}"
      mkdir -pv "${archive_version_path}"
      mv "${XBB_APPLICATION_INSTALL_FOLDER_PATH}"/* "${archive_version_path}"

      cd "${XBB_ARCHIVE_FOLDER_PATH}"
      zip -r9 -q "${distribution_file}" *

      # Put everything back.
      mv "${archive_version_path}"/* "${XBB_APPLICATION_INSTALL_FOLDER_PATH}"

    else

      # Unfortunately on node.js, xz & bz2 require native modules, which
      # proved unsafe, some xz versions failed to compile on node.js v9.x,
      # so use the good old .tar.gz.
      local distribution_file
      # Some platforms (like Arduino) accept only this explicit path.
      distribution_file="${distribution_file}.tar.gz"

      echo "Compressed tarball: \"${distribution_file}\"."

      rm -rf "${XBB_ARCHIVE_FOLDER_PATH}"
      mkdir -pv "${archive_version_path}"
      mv -v "${XBB_APPLICATION_INSTALL_FOLDER_PATH}"/* "${archive_version_path}"

      # Without --hard-dereference the hard links may be turned into
      # broken soft links on macOS.
      cd "${XBB_ARCHIVE_FOLDER_PATH}"
      # -J uses xz for compression; best compression ratio.
      # -j uses bz2 for compression; good compression ratio.
      # -z uses gzip for compression; fair compression ratio.
      if [ "${XBB_BUILD_UNAME}" == "Darwin" ]
      then
        tar -c -z -f "${distribution_file}" *
      else
        tar -c -z -f "${distribution_file}" \
          --owner=0 \
          --group=0 \
          --format=posix \
          --hard-dereference \
          *
      fi

      # Put folders back.
      mv -v "${archive_version_path}"/* "${XBB_APPLICATION_INSTALL_FOLDER_PATH}"

    fi

    cd "${XBB_DEPLOY_FOLDER_PATH}"
    if [ "${XBB_BUILD_UNAME}" == "Darwin" ]
    then
      # Isn't it binary?
      shasum -a 256 "$(basename ${distribution_file})" >"$(basename ${distribution_file}).sha"
    else
      sha256sum "$(basename ${distribution_file})" >"$(basename ${distribution_file}).sha"
    fi
  )
}

# -----------------------------------------------------------------------------

function compute_sha()
{
  # $1 shasum program
  # $2.. options
  # ${!#} file

  file=${!#}
  sha_file="${file}.sha"
  "$@" >"${sha_file}"
  echo "SHA: $(cat ${sha_file})"
}

# -----------------------------------------------------------------------------
