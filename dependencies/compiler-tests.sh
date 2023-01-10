# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# test_bin_path
# [--suffix=("" | "-bootstrap")]
# [--lto]
# [--gc]
# [--32|--64]
# [--static | --static-lib]
# [--crt]
# [--libunwind]
# [--lld]

function compiler-tests-single()
{
  echo_develop
  echo_develop "[compiler-tests-single $@]"

  local test_bin_path="$1"
  shift

  (
    unset IFS

    local is_gc="n"
    local is_lto="n"
    local is_crt="n"
    local is_static="n"
    local is_static_lib="n"
    local use_libunwind="n"
    local use_lld="n"

    local prefix=""
    local suffix=""
    local bits=""

    while [ $# -gt 0 ]
    do
      case "$1" in

        --suffix=* )
          suffix=$(xbb_parse_option "$1")
          shift
          ;;

        --gc )
          is_gc="y"
          shift
          ;;

        --lto )
          is_lto="y"
          shift
          ;;

        --64 )
          bits="64"
          suffix="-64"
          shift
          ;;

        --32 )
          bits="32"
          suffix="-32"
          shift
          ;;

        --static )
          is_static="y"
          is_static_lib="n"
          shift
          ;;

        --static-lib )
          is_static_lib="y"
          shift
          ;;

        # clang -rtlib=compiler-rt
        --crt )
          is_crt="y"
          shift
          ;;

        --libunwind )
          use_libunwind="y"
          shift
          ;;

        --lld )
          use_lld="y"
          shift
          ;;

        * )
          echo "Unsupported option $1 in ${FUNCNAME[0]}()"
          exit 1
          ;;

      esac
    done

    CFLAGS=""
    CXXFLAGS=""
    LDFLAGS=""
    LDXXFLAGS=""

    if [ "${is_crt}" == "y" ]
    then
      LDFLAGS+=" -rtlib=compiler-rt"
      LDXXFLAGS+=" -rtlib=compiler-rt"
      prefix="crt-${prefix}"
    fi

    if [ "${use_libunwind}" == "y" ]
    then
      LDFLAGS+=" -lunwind"
      LDXXFLAGS+=" -lunwind"
    fi

    if [ "${use_lld}" == "y" ]
    then
      LDFLAGS+=" -fuse-ld=lld"
      LDXXFLAGS+=" -fuse-ld=lld"
    fi

    if [ "${is_lto}" == "y" ]
    then
      CFLAGS+=" -flto"
      CXXFLAGS+=" -flto"
      LDFLAGS+=" -flto"
      LDXXFLAGS+=" -flto"
      prefix="lto-${prefix}"
    fi

    if [ "${is_gc}" == "y" ]
    then
      CFLAGS+=" -ffunction-sections -fdata-sections"
      CXXFLAGS+=" -ffunction-sections -fdata-sections"
      LDFLAGS+=" -ffunction-sections -fdata-sections"
      LDXXFLAGS+=" -ffunction-sections -fdata-sections"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,--gc-sections"
        LDXXFLAGS+=" -Wl,--gc-sections"
      elif [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
      then
        LDFLAGS+=" -Wl,-dead_strip"
        LDXXFLAGS+=" -Wl,-dead_strip"
      fi
      prefix="gc-${prefix}"
    fi

    # --static takes precedence over --static-lib.
    if [ "${is_static}" == "y" ]
    then
      LDFLAGS+=" -static"
      LDXXFLAGS+=" -static"
      prefix="static-${prefix}"
    elif [ "${is_static_lib}" == "y" ]
    then
      LDFLAGS+=" -static-libgcc"
      LDXXFLAGS+=" -static-libgcc -static-libstdc++"
      prefix="static-lib-${prefix}"
    fi

    if [ "${bits}" != "" ]
    then
      CFLAGS+=" -m${bits}"
      CXXFLAGS+=" -m${bits}"
      LDFLAGS+=" -m${bits}"
      LDXXFLAGS+=" -m${bits}"
    fi

    if [ "${XBB_IS_DEVELOP}" == "y" ]
    then
      CFLAGS+=" -v"
      CXXFLAGS+=" -v"
      LDFLAGS+=" -v"
      LDXXFLAGS+=" -v"
    fi

    (
      cd c-cpp

      # Test C compile and link in a single step.
      run_host_app_verbose "${CC}" "simple-hello.c" -o "${prefix}simple-hello-c-one${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}
      expect_target_output "Hello" "${prefix}simple-hello-c-one${suffix}${XBB_TARGET_DOT_EXE}"

      # Test C compile and link in separate steps.
      run_host_app_verbose "${CC}" -c "simple-hello.c" -o "simple-hello.c.o" ${CFLAGS}
      run_host_app_verbose "${CC}" "simple-hello.c.o" -o "${prefix}simple-hello-c-two${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}
      expect_target_output "Hello" "${prefix}simple-hello-c-two${suffix}${XBB_TARGET_DOT_EXE}"

      # -----------------------------------------------------------------------

      # Test C++ compile and link in a single step.
      run_host_app_verbose "${CXX}" "simple-hello.cpp" -o "${prefix}simple-hello-cpp-one${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
      expect_target_output "Hello" "${prefix}simple-hello-cpp-one${suffix}${XBB_TARGET_DOT_EXE}"

      # Test C++ compile and link in separate steps.
      run_host_app_verbose "${CXX}" -c "simple-hello.cpp" -o "${prefix}simple-hello${suffix}.cpp.o" ${CXXFLAGS}
      run_host_app_verbose "${CXX}" "${prefix}simple-hello${suffix}.cpp.o" -o "${prefix}simple-hello-cpp-two${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
      expect_target_output "Hello" "${prefix}simple-hello-cpp-two${suffix}${XBB_TARGET_DOT_EXE}"

      # -----------------------------------------------------------------------

      if [ "${is_static}" != "y" ]
      then
        (
          if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
          then
            run_host_app_verbose "${CC}" -c "add.c" -o "${prefix}add${suffix}.c.o" ${CFLAGS}
          else
            run_host_app_verbose "${CC}" -c "add.c" -o "${prefix}add${suffix}.c.o" -fpic ${CFLAGS}
          fi

          rm -rf libadd-static.a
          run_host_app_verbose "${AR}" -r "lib${prefix}add-static${suffix}.a" "${prefix}add${suffix}.c.o"
          run_host_app_verbose "${RANLIB}" "lib${prefix}add-static${suffix}.a"

          run_host_app_verbose "${CC}" "adder.c" -o "${prefix}adder-static${suffix}${XBB_TARGET_DOT_EXE}" -l"${prefix}add-static${suffix}" -L . ${LDFLAGS}

          expect_target_output "42" "${prefix}adder-static${suffix}${XBB_TARGET_DOT_EXE}" 40 2

          if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
          then
            # The `--out-implib` creates an import library, which can be
            # directly used with -l.
            run_host_app_verbose "${CC}" "${prefix}add${suffix}.c.o" -shared -o "lib${prefix}add-shared${suffix}.dll" -Wl,--out-implib,"lib${prefix}add-shared${suffix}.dll.a" -Wl,--subsystem,windows ${LDFLAGS}

            # -ladd-shared is in fact libadd-shared.dll.a
            # The library does not show as DLL, it is loaded dynamically.
            run_host_app_verbose "${CC}" "adder.c" -o "${prefix}adder-shared${suffix}${XBB_TARGET_DOT_EXE}" -l"${prefix}add-shared${suffix}" -L . ${LDFLAGS}
          else
            run_host_app_verbose "${CC}" "${prefix}add${suffix}.c.o" -shared -o "lib${prefix}add-shared${suffix}.${XBB_TARGET_SHLIB_EXT}" ${LDFLAGS}

            # show_target_libs "lib${prefix}add-shared${suffix}.${XBB_TARGET_SHLIB_EXT}"

            run_host_app_verbose "${CC}" "adder.c" -o "${prefix}adder-shared${suffix}" -l"${prefix}add-shared${suffix}" -L . ${LDFLAGS}

            if [ "${XBB_HOST_PLATFORM}" == "linux" ]
            then
              export LD_LIBRARY_PATH=$(pwd):${LD_LIBRARY_PATH:-}
              echo
              echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"
            fi
          fi

          expect_target_output "42" "${prefix}adder-shared${suffix}${XBB_TARGET_DOT_EXE}" 40 2
        )
      fi

      # -----------------------------------------------------------------------

      run_host_app_verbose "${CXX}" "simple-exception.cpp" -o "${prefix}simple-exception${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
      expect_target_output "MyException" "${prefix}simple-exception${suffix}${XBB_TARGET_DOT_EXE}"

      run_host_app_verbose "${CXX}" "simple-str-exception.cpp" -o "${prefix}simple-str-exception${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
      expect_target_output "MyStringException" "${prefix}simple-str-exception${suffix}${XBB_TARGET_DOT_EXE}"

      run_host_app_verbose "${CXX}" "simple-int-exception.cpp" -o "${prefix}simple-int-exception${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
      expect_target_output "42" "${prefix}simple-int-exception${suffix}${XBB_TARGET_DOT_EXE}"

      # -----------------------------------------------------------------------
      # Tests borrowed from the llvm-mingw project.

      run_host_app_verbose "${CC}" "hello.c" -o "${prefix}hello${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} -lm
      show_target_libs_develop "${prefix}hello${suffix}${XBB_TARGET_DOT_EXE}"
      run_target_app_verbose "./${prefix}hello${suffix}"

      # run_host_app_verbose "${CC}" "setjmp-patched.c" -o "${prefix}setjmp${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} -lm
      run_host_app_verbose "${CC}" "setjmp.c" -o "${prefix}setjmp${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} -lm
      show_target_libs_develop "${prefix}setjmp${suffix}${XBB_TARGET_DOT_EXE}"
      run_target_app_verbose "./${prefix}setjmp${suffix}"

      run_host_app_verbose "${CXX}" "hello-cpp.cpp" -o "${prefix}hello-cpp${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
      show_target_libs_develop "${prefix}hello-cpp${suffix}${XBB_TARGET_DOT_EXE}"
      run_target_app_verbose "./${prefix}hello-cpp${suffix}"

      run_host_app_verbose "${CXX}" "global-terminate.cpp" -o "${prefix}global-terminate${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
      show_target_libs_develop "${prefix}global-terminate${suffix}${XBB_TARGET_DOT_EXE}"
      run_target_app_verbose "./${prefix}global-terminate${suffix}"

      run_host_app_verbose "${CXX}" "longjmp-cleanup.cpp" -o "${prefix}longjmp-cleanup${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
      show_target_libs_develop "${prefix}longjmp-cleanup${suffix}${XBB_TARGET_DOT_EXE}"
      run_target_app_verbose "./${prefix}longjmp-cleanup${suffix}"

      if false # [ "${XBB_TARGET_PLATFORM}" == "darwin" ] && [ "${XBB_TARGET_ARCH}" == "x64" ] && is_gcc
      then

        # /Users/runner/work/gcc-xpack/gcc-xpack/build/darwin-x64/x86_64-apple-darwin21.6.0/tests/xpack-gcc-12.2.0-2/bin/../libexec/gcc/x86_64-apple-darwin17.7.0/12.2.0/collect2 -syslibroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/ -dynamic -arch x86_64 -macosx_version_min 12.0.0 -o hello-exception -L/Users/runner/work/gcc-xpack/gcc-xpack/build/darwin-x64/x86_64-apple-darwin21.6.0/tests/xpack-gcc-12.2.0-2/bin/../lib/gcc/x86_64-apple-darwin17.7.0/12.2.0 -L/Users/runner/work/gcc-xpack/gcc-xpack/build/darwin-x64/x86_64-apple-darwin21.6.0/tests/xpack-gcc-12.2.0-2/bin/../lib/gcc -L/Users/runner/work/gcc-xpack/gcc-xpack/build/darwin-x64/x86_64-apple-darwin21.6.0/tests/xpack-gcc-12.2.0-2/bin/../lib/gcc/x86_64-apple-darwin17.7.0/12.2.0/../../.. /var/folders/24/8k48jl6d249_n_qfxwsl6xvm0000gn/T//cc9bpKXa.o -lstdc++ -lemutls_w -lgcc -lSystem -no_compact_unwind
        # 0  0x10b5f0ffa  __assert_rtn + 139
        # 1  0x10b42428d  mach_o::relocatable::Parser<x86_64>::parse(mach_o::relocatable::ParserOptions const&) + 4989
        # 2  0x10b414f8f  mach_o::relocatable::Parser<x86_64>::parse(unsigned char const*, unsigned long long, char const*, long, ld::File::Ordinal, mach_o::relocatable::ParserOptions const&) + 207
        # 3  0x10b48b9d4  ld::tool::InputFiles::makeFile(Options::FileInfo const&, bool) + 2036
        # 4  0x10b48efa0  ___ZN2ld4tool10InputFilesC2ER7Options_block_invoke + 48
        # 5  0x7ff81d0b634a  _dispatch_client_callout2 + 8
        # 6  0x7ff81d0c8c45  _dispatch_apply_invoke_and_wait + 213
        # 7  0x7ff81d0c8161  _dispatch_apply_with_attr_f + 1178
        # 8  0x7ff81d0c8327  dispatch_apply + 45
        # 9  0x10b48ee2d  ld::tool::InputFiles::InputFiles(Options&) + 669
        # 10  0x10b3ffd48  main + 840
        # A linker snapshot was created at:
        # 	/tmp/hello-exception-2022-12-14-082452.ld-snapshot
        # ld: Assertion failed: (_file->_atomsArrayCount == computedAtomCount && "more atoms allocated than expected"), function parse, file macho_relocatable_file.cpp, line 2061.
        # collect2: error: ld returned 1 exit status

        echo
        echo "Skipping hello-exception.cpp for macOS gcc..."
      else
        run_host_app_verbose "${CXX}" "hello-exception.cpp" -o "${prefix}hello-exception${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
        show_target_libs_develop "${prefix}hello-exception${suffix}${XBB_TARGET_DOT_EXE}"
        run_target_app_verbose "./${prefix}hello-exception${suffix}"
      fi

      run_host_app_verbose "${CXX}" "exception-locale.cpp" -o "${prefix}exception-locale${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
      show_target_libs_develop "${prefix}exception-locale${suffix}${XBB_TARGET_DOT_EXE}"
      run_target_app_verbose "./${prefix}exception-locale${suffix}"

      run_host_app_verbose "${CXX}" "exception-reduced.cpp" -o "${prefix}exception-reduced${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
      show_target_libs_develop "${prefix}exception-reduced${suffix}${XBB_TARGET_DOT_EXE}"
      run_target_app_verbose "./${prefix}exception-reduced${suffix}"

      if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
      then
        run_host_app_verbose "${CC}" "hello-tls.c" -o "${prefix}hello-tls${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}
        show_target_libs_develop "${prefix}hello-tls${suffix}${XBB_TARGET_DOT_EXE}"
        run_target_app_verbose "./${prefix}hello-tls${suffix}"

        if false
        then
          # -lssp not available.
          run_host_app_verbose "${CC}" "bufferoverflow.c" -o "${prefix}bufferoverflow${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} -D_FORTIFY_SOURCE=2 -lssp
          show_target_libs_develop "${prefix}bufferoverflow${suffix}${XBB_TARGET_DOT_EXE}"
          run_target_app_verbose "./${prefix}bufferoverflow${suffix}"
          run_target_app_verbose "./${prefix}bufferoverflow${suffix}" 1
          run_target_app_verbose "./${prefix}bufferoverflow${suffix}" 2
          run_target_app_verbose "./${prefix}bufferoverflow${suffix}" 3
          run_target_app_verbose "./${prefix}bufferoverflow${suffix}" 4
          run_target_app_verbose "./${prefix}bufferoverflow${suffix}" 5
          run_target_app_verbose "./${prefix}bufferoverflow${suffix}" 6
          run_target_app_verbose "./${prefix}bufferoverflow${suffix}" 7
          run_target_app_verbose "./${prefix}bufferoverflow${suffix}" 8
          run_target_app_verbose "./${prefix}bufferoverflow${suffix}" 9
          run_target_app_verbose "./${prefix}bufferoverflow${suffix}" 10

          # Control Flow Guard is _not_ enabled!
          run_host_app_verbose "${CC}" "cfguard-test.c" -o "${prefix}cfguard-test${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} -mguard=cf
          show_target_libs_develop "${prefix}cfguard-test${suffix}${XBB_TARGET_DOT_EXE}"
          run_target_app_verbose "./${prefix}cfguard-test${suffix}"
          run_target_app_verbose "./${prefix}cfguard-test${suffix}" check_enabled
          run_target_app_verbose "./${prefix}cfguard-test${suffix}" normal_icall
          run_target_app_verbose "./${prefix}cfguard-test${suffix}" invalid_icall
          run_target_app_verbose "./${prefix}cfguard-test${suffix}" invalid_icall_nocf
        fi
      fi

      if [ "${XBB_TARGET_PLATFORM}" == "darwin" ] && [ "${XBB_TARGET_ARCH}" == "x64" ]
      then
        # On macOS 10.13
        # crt-test.c:1531: lgamma(F(-0.0)) failed, expected inf, got -inf
        # crt-test.c:1532: lgammaf(F(-0.0)) failed, expected inf, got -inf
        # 2592 tests, 2 failures
        echo
        echo "Skipping crt-test on macOS..."
      else
        # This test uses math functions. On Windows -lm is not mandatory.
        run_host_app_verbose "${CC}" crt-test.c -o "${prefix}crt-test${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} -lm
        show_target_libs_develop "${prefix}crt-test${suffix}${XBB_TARGET_DOT_EXE}"
        run_target_app_verbose "./${prefix}crt-test${suffix}"
      fi

      if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
      then
        echo
        echo "Skipping hello-weak-c with Windows binaries..."
      # elif [ "${is_lto}" != "y" ] && is_non_native && is_mingw_gcc
      # then
      #   # With mingw-gcc bootstrap
      #   # hello-weak-cpp:(.text+0x25): undefined reference to `hello()'
      #   echo
      #   echo "Skipping hello-weak-c without -flto with Windows binaries..."
      # elif is_non_native && is_mingw_clang
      # then
      #   # lld-link: error: duplicate symbol: world()
      #   # >>> defined at hello-weak-cpp.cpp
      #   # >>>            lto-hello-weak-cpp.cpp.o
      #   # >>> defined at hello-f-weak-cpp.cpp
      #   # >>>            lto-hello-f-weak-cpp.cpp.o
      #   # clang-12: error: linker command failed with exit code 1 (use -v to see invocation)
      #   # -Wl,--allow-multiple-definition fixes this, but then
      #   # Test "./lto-hello-weak-cpp.exe " failed :-(
      #   # expected 12: "Hello World!"
      #   # got 11: "Hello there"
      #   echo
      #   echo "Skipping hello-weak-c without -flto with Windows binaries..."
      # elif is_cross && is_gcc
      # then
      #   echo
      #   echo "Skipping hello-weak-c without -flto with Windows binaries..."
      # elif [ "${is_lto}" != "y" ] && is_gcc && [ "${XBB_BUILD_PLATFORM}" == "win32" ]
      # then
      #   echo
      #   echo "Skipping hello-weak-c without -flto on Windows..."
      # elif [ "${is_lto}" == "y" ] && is_clang && [ "${XBB_BUILD_PLATFORM}" == "win32" ]
      # then
      #   echo
      #   echo "Skipping hello-weak-c with clang -flto on Windows..."
      else
        run_host_app_verbose "${CC}" -c "hello-weak.c" -o "${prefix}hello-weak${suffix}.c.o" ${CFLAGS}
        run_host_app_verbose "${CC}" -c "hello-f-weak.c" -o "${prefix}hello-f-weak${suffix}.c.o" ${CFLAGS}
        run_host_app_verbose "${CC}" "${prefix}hello-weak${suffix}.c.o" "${prefix}hello-f-weak${suffix}.c.o" -o "${prefix}hello-weak${suffix}${XBB_TARGET_DOT_EXE}" -lm ${LDFLAGS}
        expect_target_output "Hello World!" "./${prefix}hello-weak${suffix}${XBB_TARGET_DOT_EXE}"
      fi

      if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
      then
        echo
        echo "Skipping hello-weak-cpp with Windows binaries..."
      # elif [ "${is_lto}" != "y" ] && is_non_native && is_mingw_gcc
      # then
      #   # With mingw-gcc bootstrap
      #   # hello-weak-cpp:(.text+0x25): undefined reference to `hello()'
      #   echo
      #   echo "Skipping hello-weak-cpp without -flto with Windows binaries..."
      # elif is_non_native && is_clang
      # then
      #   # lld-link: error: duplicate symbol: world()
      #   # >>> defined at hello-weak-cpp.cpp
      #   # >>>            lto-hello-weak-cpp.cpp.o
      #   # >>> defined at hello-f-weak-cpp.cpp
      #   # >>>            lto-hello-f-weak-cpp.cpp.o
      #   # clang-12: error: linker command failed with exit code 1 (use -v to see invocation)
      #   # -Wl,--allow-multiple-definition fixes this, but then
      #   # Test "./lto-hello-weak-cpp.exe " failed :-(
      #   # expected 12: "Hello World!"
      #   # got 11: "Hello there"
      #   echo
      #   echo "Skipping hello-weak-cpp without -flto with Windows binaries..."
      # elif is_cross && is_gcc
      # then
      #   echo
      #   echo "Skipping hello-weak-cpp without -flto with Windows binaries..."
      # elif [ "${is_lto}" != "y" ] && is_gcc && [ "${XBB_BUILD_PLATFORM}" == "win32" ]
      # then
      #   echo
      #   echo "Skipping hello-weak-cpp without -flto on Windows..."
      # elif [ "${is_lto}" == "y" ] && is_clang && [ "${XBB_BUILD_PLATFORM}" == "win32" ]
      # then
      #   echo
      #   echo "Skipping hello-weak-cpp with clang -flto on Windows..."
      else
        run_host_app_verbose "${CXX}" -c "hello-weak-cpp.cpp" -o "${prefix}hello-weak-cpp${suffix}.cpp.o" ${CXXFLAGS}
        run_host_app_verbose "${CXX}" -c "hello-f-weak-cpp.cpp" -o "${prefix}hello-f-weak-cpp${suffix}.cpp.o" ${CXXFLAGS}
        run_host_app_verbose "${CXX}" "${prefix}hello-weak-cpp${suffix}.cpp.o" "${prefix}hello-f-weak-cpp${suffix}.cpp.o" -o "${prefix}hello-weak-cpp${suffix}${XBB_TARGET_DOT_EXE}" -lm ${LDXXFLAGS}
        expect_target_output "Hello World!" "./${prefix}hello-weak-cpp${suffix}${XBB_TARGET_DOT_EXE}"
      fi

      # Test weak override.
      (
        cd weak-override

        run_host_app_verbose "${CC}" -c "main-weak.c" -o "${prefix}main-weak${suffix}.c.o" ${CFLAGS}
        run_host_app_verbose "${CC}" -c "add2.c" -o "${prefix}add2${suffix}.c.o" ${CFLAGS}
        run_host_app_verbose "${CC}" -c "dummy.c" -o "${prefix}dummy${suffix}.c.o" ${CFLAGS}
        run_host_app_verbose "${CC}" -c "expected3.c" -o "${prefix}expected3${suffix}.c.o" ${CFLAGS}

        run_host_app_verbose "${CC}" "${prefix}main-weak${suffix}.c.o" "${prefix}add2${suffix}.c.o" "${prefix}dummy${suffix}.c.o" "${prefix}expected3${suffix}.c.o" -o "${prefix}weak-override${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}

        show_target_libs_develop "${prefix}weak-override${suffix}${XBB_TARGET_DOT_EXE}"
        # The test returns success if the weak override is effective, 1 otherwise.
        run_target_app_verbose "./${prefix}weak-override${suffix}"
      )

      # Test if exceptions thrown from shared libraries are caught.
      if [ "${is_static}" != "y" ]
      then
        (
          if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
          then
            run_host_app_verbose "${CXX}" "throwcatch-lib.cpp" -shared -o "throwcatch-lib.dll" -Wl,--out-implib,libthrowcatch-lib.dll.a ${LDXXFLAGS}
          else
            run_host_app_verbose "${CXX}" "throwcatch-lib.cpp" -shared -fpic -o "libthrowcatch-lib.${XBB_TARGET_SHLIB_EXT}" ${LDXXFLAGS}

            if [ "${XBB_HOST_PLATFORM}" == "linux" ]
            then
              export LD_LIBRARY_PATH=$(pwd):${LD_LIBRARY_PATH:-}
              echo
              echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"
            fi
          fi

          # mingw-gcc on macOS throws
          # multiple definition of `_Unwind_Resume'
          if [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
          then
            run_host_app_verbose "${CXX}" "throwcatch-main.cpp" -o "${prefix}throwcatch-main${suffix}${XBB_TARGET_DOT_EXE}" -L. -lthrowcatch-lib ${LDXXFLAGS}
          else
            run_host_app_verbose "${CXX}" "throwcatch-main.cpp" -o "${prefix}throwcatch-main${suffix}${XBB_TARGET_DOT_EXE}" -L. -lthrowcatch-lib ${LDXXFLAGS} -Wl,--allow-multiple-definition
          fi

          (
            # LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-""}
            # export LD_LIBRARY_PATH=$(pwd):${LD_LIBRARY_PATH}
            # echo
            # echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"

            # C:\Users\ilg>"C:\Users\ilg\Desktop\New folder\lto-throwcatch-main.exe"
            # Mingw-w64 runtime failure:
            # 32 bit pseudo relocation at 00007FF74BF01697 out of range, targeting 00007FFBB05A168C, yielding the value 000000046469FFF1.

            # TODO allow it on clang
            # It happens with both bootstrap & cross.
            if [ "${is_lto}" == "y" ] && is_non_native && is_mingw_gcc
            then
              show_target_libs "${prefix}throwcatch-main${suffix}${XBB_TARGET_DOT_EXE}"
              echo
              echo "Skipping ${prefix}throwcatch-main${suffix} with gcc -flto..."
            elif [ "${is_lto}" == "y" ] && is_cross && is_gcc
            then
              # wine: Unhandled page fault on execute access to 0000000122B1157C at address 0000000122B1157C (thread 0138), starting debugger...
              # Unhandled exception: page fault on execute access to 0x122b1157c in 64-bit code (0x0000000122b1157c).
              show_target_libs "${prefix}throwcatch-main${suffix}${XBB_TARGET_DOT_EXE}"
              echo
              echo "Skipping ${prefix}throwcatch-main${suffix} with gcc -flto..."
            elif [ "${XBB_TARGET_PLATFORM}" == "darwin" -a "${is_lto}" == "y" ] && is_native && is_clang
            then

              # Expected behaviour:
              # [./throwcatch-main ]
              # not throwing
              # throwing FirstException
              # caught FirstException
              # throwing SecondException
              # caught SecondException
              # throwing std::exception
              # caught std::exception
              # all ok

              # Does not identify the custom exceptions:
              # [./lto-throwcatch-main ]
              # not throwing
              # throwing FirstException
              # caught std::exception <--
              # caught unexpected exception 3!
              # throwing SecondException
              # caught std::exception <--
              # caught unexpected exception 3!
              # throwing std::exception
              # caught std::exception
              # got errors

              show_target_libs "${prefix}throwcatch-main${suffix}${XBB_TARGET_DOT_EXE}"
              echo
              echo "Skipping ${prefix}throwcatch-main${suffix} with clang -flto on macOS..."
            elif [ "${is_lto}" == "y" ] && is_gcc && [ "${XBB_BUILD_PLATFORM}" == "win32" ]
            then
              # Mingw-w64 runtime failure:
              # 32 bit pseudo relocation at 00007FF67D9F1587 out of range, targeting 00007FFF403E157C, yielding the value 00000008C29EFFF1.
              echo
              echo "Skipping ${prefix}throwcatch-main${suffix} -flto on Windows..."
            elif [ "${is_static_lib}" == "y" ] && [[ "$(basename "${CC}")" =~ .*i686-w64-mingw32-gcc.* ]]
            then
              # terminate called after throwing an instance of 'FirstException'
              #   what():  first
              echo
              echo "Skipping ${prefix}throwcatch-main${suffix} --static-lib i686 on Windows..."
            else
              show_target_libs_develop "${prefix}throwcatch-main${suffix}${XBB_TARGET_DOT_EXE}"
              run_target_app_verbose "./${prefix}throwcatch-main${suffix}"
            fi
          )
        )
      fi

      if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
      then
        if is_gcc && [ "${XBB_BUILD_PLATFORM}" == "win32" ]
        then
          echo
          echo "Skipping tlstest-main.cpp on Windows..."
        else
          # tlstest-lib.dll is dynamically loaded by tltest-main.cpp.
          run_host_app_verbose "${CXX}" tlstest-lib.cpp -o tlstest-lib.dll -shared -Wl,--out-implib,libtlstest-lib.dll.a ${LDXXFLAGS}
          show_target_libs_develop "tlstest-lib.dll"

          run_host_app_verbose "${CXX}" tlstest-main.cpp -o "${prefix}tlstest-main${suffix}${XBB_TARGET_DOT_EXE}"${LDXXFLAGS}
          show_target_libs_develop ${prefix}tlstest-main${suffix}
          run_target_app_verbose "./${prefix}tlstest-main${suffix}"
        fi

        if [ "${is_static}" != "y" ]
        then
          run_host_app_verbose "${CC}" autoimport-lib.c -o autoimport-lib.dll -shared  -Wl,--out-implib,libautoimport-lib.dll.a ${LDFLAGS}
          show_target_libs_develop autoimport-lib.dll

          run_host_app_verbose "${CC}" autoimport-main.c -o "${prefix}autoimport-main${suffix}${XBB_TARGET_DOT_EXE}" -L. -lautoimport-lib ${LDFLAGS}

          # TODO allow it on clang
          # TODO allow it on bootstrap
          if [ "${is_lto}" == "y" ] && is_cross && is_mingw_gcc
          then
            show_target_libs "${prefix}autoimport-main${suffix}${XBB_TARGET_DOT_EXE}"
            echo
            echo "Skipping ${prefix}autoimport-main${suffix} with gcc -flto..."
          elif [ "${is_lto}" == "y" ] && is_bootstrap && is_mingw_gcc
          then
            # [wine64 ./lto-autoimport-main.exe]
            # Mingw-w64 runtime failure:
            # 32 bit pseudo relocation at 000000014000163A out of range, targeting 000000028846146C, yielding the value 000000014845FE2E.
            # 0080:err:rpc:RpcAssoc_BindConnection receive failed with error 1726

            show_target_libs "${prefix}autoimport-main${suffix}${XBB_TARGET_DOT_EXE}"
            echo
            echo "Skipping ${prefix}autoimport-main${suffix} with gcc -flto..."
          elif [ "${is_lto}" == "y" ] && is_cross && is_gcc
          then
            # Mingw-w64 runtime failure:
            # 32 bit pseudo relocation at 000000014000152A out of range, targeting 000000028846135C, yielding the value 000000014845FE2E.
            show_target_libs "${prefix}autoimport-main${suffix}${XBB_TARGET_DOT_EXE}"
            echo
            echo "Skipping ${prefix}autoimport-main${suffix} with gcc -flto..."
          elif [ "${is_lto}" == "y" ] && is_gcc && [ "${XBB_BUILD_PLATFORM}" == "win32" ]
          then
            # Mingw-w64 runtime failure:
            # 32 bit pseudo relocation at 00007FF62E64152A out of range, targeting 00007FFF4040135C, yielding the value 0000000911DBFE2E.
            echo
            echo "Skipping ${prefix}autoimport-main${suffix} with gcc -flto on Windows..."
          else
            show_target_libs_develop "${prefix}autoimport-main${suffix}${XBB_TARGET_DOT_EXE}"
            run_target_app_verbose "./${prefix}autoimport-main${suffix}"
          fi
        fi

        # The IDL output isn't arch specific, but test each arch frontend
        run_host_app_verbose "${WIDL}" idltest.idl -o idltest.h -h
        run_host_app_verbose "${CC}" idltest.c -o "${prefix}idltest${suffix}${XBB_TARGET_DOT_EXE}" -I. -lole32 ${LDFLAGS}
        show_target_libs_develop "${prefix}idltest${suffix}${XBB_TARGET_DOT_EXE}"
        run_target_app_verbose "./${prefix}idltest${suffix}"
      fi

      # -----------------------------------------------------------------------

      # Test a very simple Objective-C (a printf).
      run_host_app_verbose "${CC}" simple-objc.m -o "${prefix}simple-objc${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}
      expect_target_output "Hello World" "${prefix}simple-objc${suffix}${XBB_TARGET_DOT_EXE}"

    )

    # -------------------------------------------------------------------------

    if [ ! -z ${F90+x} ]
    then
      (
        cd fortran

        if is_gcc && [ "${XBB_BUILD_PLATFORM}" == "win32" ]
        then
          # error while loading shared libraries: api-ms-win-crt-time-l1-1-0.dll: cannot open shared object file: No such file or directory
          # The api-ms-win-crt-runtime-l1-1-0.dll file is included in Microsoft Visual C++ Redistributable for Visual Studio 2015
          echo
          echo "Skipping Fortran tests on Windows..."
        else
          # Test a very simple Fortran (a print).
          run_host_app_verbose "${F90}" hello.f90 -o "${prefix}hello-f${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}
          # The space is expected.
          expect_target_output " Hello" "${prefix}hello-f${suffix}${XBB_TARGET_DOT_EXE}"

          # Test a concurrent computation.
          run_host_app_verbose "${F90}" concurrent.f90 -o "${prefix}concurrent-f${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}

          show_target_libs_develop "${prefix}concurrent-f${suffix}${XBB_TARGET_DOT_EXE}"
          run_target_app_verbose "./${prefix}concurrent-f${suffix}"
        fi
      )
    else
      echo
      echo "Skipping Fortran tests, compiler not available..."
    fi

  )
}

# -----------------------------------------------------------------------------
