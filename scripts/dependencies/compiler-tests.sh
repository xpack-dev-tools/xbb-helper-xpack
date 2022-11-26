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
# [--static | --static-lib]
# [--crt]

function test_compiler_single()
{
  echo_develop
  echo_develop "[test_compiler_single $@]"

  local test_bin_path="$1"
  shift
  # shift

  (
    unset IFS

    local is_gc="n"
    local is_lto="n"
    local is_crt="n"
    local is_static="n"
    local is_static_lib="n"

    local prefix=""
    local suffix=""


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

    if [ "${is_lto}" == "y" ]
    then
      CFLAGS+=" -flto"
      CXXFLAGS+=" -flto"
      LDFLAGS+=" -flto"
      LDXXFLAGS+=" -flto"
      if false # [ "${XBB_HOST_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -fuse-ld=lld"
        LDXXFLAGS+=" -fuse-ld=lld"
      fi
      prefix="lto-${prefix}"
    fi

    if [ "${is_gc}" == "y" ]
    then
      CFLAGS+=" -ffunction-sections -fdata-sections"
      CXXFLAGS+=" -ffunction-sections -fdata-sections"
      LDFLAGS+=" -ffunction-sections -fdata-sections"
      LDXXFLAGS+=" -ffunction-sections -fdata-sections"
      if true # [ "${XBB_HOST_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,--gc-sections"
        LDXXFLAGS+=" -Wl,--gc-sections"
      elif [ "${XBB_HOST_PLATFORM}" == "darwin" ]
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
      run_target_app_verbose "${CC}" "simple-hello.c" -o "${prefix}simple-hello-c-one${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}
      test_mingw_expect "Hello" "${prefix}simple-hello-c-one${suffix}${XBB_TARGET_DOT_EXE}"

      # Test C compile and link in separate steps.
      run_target_app_verbose "${CC}" -c "simple-hello.c" -o "simple-hello.c.o" ${CFLAGS}
      run_target_app_verbose "${CC}" "simple-hello.c.o" -o "${prefix}simple-hello-c-two${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}
      test_mingw_expect "Hello" "${prefix}simple-hello-c-two${suffix}${XBB_TARGET_DOT_EXE}"

      # -------------------------------------------------------------------------

      # Test C++ compile and link in a single step.
      run_target_app_verbose "${CXX}" "simple-hello.cpp" -o "${prefix}simple-hello-cpp-one${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
      test_mingw_expect "Hello" "${prefix}simple-hello-cpp-one${suffix}${XBB_TARGET_DOT_EXE}"

      # Test C++ compile and link in separate steps.
      run_target_app_verbose "${CXX}" -c "simple-hello.cpp" -o "${prefix}simple-hello${suffix}.cpp.o" ${CXXFLAGS}
      run_target_app_verbose "${CXX}" "${prefix}simple-hello${suffix}.cpp.o" -o "${prefix}simple-hello-cpp-two${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
      test_mingw_expect "Hello" "${prefix}simple-hello-cpp-two${suffix}${XBB_TARGET_DOT_EXE}"

      # -------------------------------------------------------------------------

      if [ "${is_static}" != "y" ]
      then
        (
          if true # [ "${XBB_HOST_PLATFORM}" == "win32" ]
          then
            run_target_app_verbose "${CC}" -c "add.c" -o "${prefix}add${suffix}.c.o" ${CFLAGS}
          else
            run_target_app_verbose "${CC}" -c "add.c" -o "${prefix}add${suffix}.c.o" -fpic ${CFLAGS}
          fi

          rm -rf libadd-static.a
          run_target_app_verbose "${AR}" -r "lib${prefix}add-static${suffix}.a" "${prefix}add${suffix}.c.o"
          run_target_app_verbose "${RANLIB}" "lib${prefix}add-static${suffix}.a"

          if true # [ "${XBB_HOST_PLATFORM}" == "win32" ]
          then
            # The `--out-implib` creates an import library, which can be
            # directly used with -l.
            run_target_app_verbose "${CC}" "${prefix}add${suffix}.c.o" -shared -o "lib${prefix}add-shared${suffix}.dll" -Wl,--out-implib,"lib${prefix}add-shared${suffix}.dll.a" -Wl,--subsystem,windows
          else
            run_target_app_verbose "${CC}" "${prefix}add${suffix}.c.o" -shared -o "lib${prefix}add-shared${suffix}.${XBB_HOST_SHLIB_EXT}"
          fi

          run_target_app_verbose "${CC}" "adder.c" -o "${prefix}adder-static${suffix}${XBB_TARGET_DOT_EXE}" -l"${prefix}add-static${suffix}" -L . ${LDFLAGS}

          test_mingw_expect "42" "${prefix}adder-static${suffix}${XBB_TARGET_DOT_EXE}" 40 2

          if true # [ "${XBB_HOST_PLATFORM}" == "win32" ]
          then
            # -ladd-shared is in fact libadd-shared.dll.a
            # The library does not show as DLL, it is loaded dynamically.
            run_target_app_verbose "${CC}" "adder.c" -o "${prefix}adder-shared${suffix}${XBB_TARGET_DOT_EXE}" -l"${prefix}add-shared${suffix}" -L . ${LDFLAGS}
          else
            run_target_app_verbose "${CC}" "adder.c" -o "${prefix}adder-shared${suffix}" -l"${prefix}add-shared${suffix}" -L . ${LDFLAGS}
          fi

          test_mingw_expect "42" "${prefix}adder-shared${suffix}${XBB_TARGET_DOT_EXE}" 40 2
        )
      fi

      # -------------------------------------------------------------------------

      run_target_app_verbose "${CXX}" "simple-exception.cpp" -o "${prefix}simple-exception${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
      test_mingw_expect "MyException" "${prefix}simple-exception${suffix}${XBB_TARGET_DOT_EXE}"

      run_target_app_verbose "${CXX}" "simple-str-exception.cpp" -o "${prefix}simple-str-exception${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
      test_mingw_expect "MyStringException" "${prefix}simple-str-exception${suffix}${XBB_TARGET_DOT_EXE}"

      run_target_app_verbose "${CXX}" "simple-int-exception.cpp" -o "${prefix}simple-int-exception${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
      test_mingw_expect "42" "${prefix}simple-int-exception${suffix}${XBB_TARGET_DOT_EXE}"

      # -----------------------------------------------------------------------
      # Tests borrowed from the llvm-mingw project.

      run_target_app_verbose "${CC}" "hello.c" -o "${prefix}hello${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} -lm
      show_target_libs_develop "${prefix}hello${suffix}${XBB_TARGET_DOT_EXE}"
      run_target_app_verbose "./${prefix}hello${suffix}"

      run_target_app_verbose "${CC}" "setjmp-patched.c" -o "${prefix}setjmp${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} -lm
      show_target_libs_develop "${prefix}setjmp${suffix}${XBB_TARGET_DOT_EXE}"
      run_target_app_verbose "./${prefix}setjmp${suffix}"

      run_target_app_verbose "${CXX}" "hello-cpp.cpp" -o "${prefix}hello-cpp${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
      show_target_libs_develop "${prefix}hello-cpp${suffix}${XBB_TARGET_DOT_EXE}"
      run_target_app_verbose "./${prefix}hello-cpp${suffix}"

      run_target_app_verbose "${CXX}" "global-terminate.cpp" -o "${prefix}global-terminate${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
      show_target_libs_develop "${prefix}global-terminate${suffix}${XBB_TARGET_DOT_EXE}"
      run_target_app_verbose "./${prefix}global-terminate${suffix}"

      run_target_app_verbose "${CXX}" "longjmp-cleanup.cpp" -o "${prefix}longjmp-cleanup${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
      show_target_libs_develop "${prefix}longjmp-cleanup${suffix}${XBB_TARGET_DOT_EXE}"
      run_target_app_verbose "./${prefix}longjmp-cleanup${suffix}"

      run_target_app_verbose "${CXX}" "hello-exception.cpp" -o "${prefix}hello-exception${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
      show_target_libs_develop "${prefix}hello-exception${suffix}${XBB_TARGET_DOT_EXE}"
      run_target_app_verbose "./${prefix}hello-exception${suffix}"

      run_target_app_verbose "${CXX}" "exception-locale.cpp" -o "${prefix}exception-locale${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
      show_target_libs_develop "${prefix}exception-locale${suffix}${XBB_TARGET_DOT_EXE}"
      run_target_app_verbose "./${prefix}exception-locale${suffix}"

      run_target_app_verbose "${CXX}" "exception-reduced.cpp" -o "${prefix}exception-reduced${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
      show_target_libs_develop "${prefix}exception-reduced${suffix}${XBB_TARGET_DOT_EXE}"
      run_target_app_verbose "./${prefix}exception-reduced${suffix}"

      run_target_app_verbose "${CC}" hello-tls.c -o "${prefix}hello-tls${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}
      show_target_libs_develop "${prefix}hello-tls${suffix}${XBB_TARGET_DOT_EXE}"
      run_target_app_verbose "./${prefix}hello-tls${suffix}"

      run_target_app_verbose "${CC}" crt-test.c -o "${prefix}crt-test${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}
      show_target_libs_develop "${prefix}crt-test${suffix}${XBB_TARGET_DOT_EXE}"
      run_target_app_verbose "./${prefix}crt-test${suffix}"

      if [ "${is_lto}" != "y" ] && is_non_native && is_mingw_gcc
      then
        # With mingw-gcc bootstrap
        # hello-weak-cpp:(.text+0x25): undefined reference to `hello()'
        echo
        echo "Skip hello-weak-c* without -flto with Windows binaries"
      elif is_non_native && is_mingw_clang
      then
        # lld-link: error: duplicate symbol: world()
        # >>> defined at hello-weak-cpp.cpp
        # >>>            lto-hello-weak-cpp.cpp.o
        # >>> defined at hello-f-weak-cpp.cpp
        # >>>            lto-hello-f-weak-cpp.cpp.o
        # clang-12: error: linker command failed with exit code 1 (use -v to see invocation)
        # -Wl,--allow-multiple-definition fixes this, but then
        # Test "./lto-hello-weak-cpp.exe " failed :-(
        # expected 12: "Hello World!"
        # got 11: "Hello there"
        echo
        echo "Skip hello-weak-c* without -flto with Windows binaries"
      else
        run_target_app_verbose "${CC}" -c "hello-weak.c" -o "${prefix}hello-weak${suffix}.c.o" ${CFLAGS}
        run_target_app_verbose "${CC}" -c "hello-f-weak.c" -o "${prefix}hello-f-weak${suffix}.c.o" ${CFLAGS}
        run_target_app_verbose "${CC}" "${prefix}hello-weak${suffix}.c.o" "${prefix}hello-f-weak${suffix}.c.o" -o "${prefix}hello-weak${suffix}${XBB_TARGET_DOT_EXE}" -lm ${LDFLAGS}
        test_mingw_expect "Hello World!" "./${prefix}hello-weak${suffix}${XBB_TARGET_DOT_EXE}"

        run_target_app_verbose "${CXX}" -c "hello-weak-cpp.cpp" -o "${prefix}hello-weak-cpp${suffix}.cpp.o" ${CXXFLAGS}
        run_target_app_verbose "${CXX}" -c "hello-f-weak-cpp.cpp" -o "${prefix}hello-f-weak-cpp${suffix}.cpp.o"  ${CXXFLAGS}
        run_target_app_verbose "${CXX}" "${prefix}hello-weak-cpp${suffix}.cpp.o" "${prefix}hello-f-weak-cpp${suffix}.cpp.o" -o "${prefix}hello-weak-cpp${suffix}${XBB_TARGET_DOT_EXE}" -lm ${LDXXFLAGS}
        test_mingw_expect "Hello World!" "./${prefix}hello-weak-cpp${suffix}${XBB_TARGET_DOT_EXE}"
      fi

      # Test weak override.
      (
        cd weak-override

        run_target_app_verbose "${CC}" -c "main-weak.c" -o "${prefix}main-weak${suffix}.c.o" ${CFLAGS}
        run_target_app_verbose "${CC}" -c "add2.c" -o "${prefix}add2${suffix}.c.o" ${CFLAGS}
        run_target_app_verbose "${CC}" -c "dummy.c" -o "${prefix}dummy${suffix}.c.o" ${CFLAGS}
        run_target_app_verbose "${CC}" -c "expected3.c" -o "${prefix}expected3${suffix}.c.o" ${CFLAGS}

        run_target_app_verbose "${CC}" "${prefix}main-weak${suffix}.c.o" "${prefix}add2${suffix}.c.o" "${prefix}dummy${suffix}.c.o" "${prefix}expected3${suffix}.c.o" -o "${prefix}weak-override${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}

        show_target_libs_develop "${prefix}weak-override${suffix}${XBB_TARGET_DOT_EXE}"
        # The test returns success if the weak override is effective, 1 otherwise.
        run_target_app_verbose "./${prefix}weak-override${suffix}"
      )

      # Test if exceptions thrown from shared libraries are catched.
      if [ "${is_static}" != "y" ]
      then
        (
          if true # [ "${XBB_HOST_PLATFORM}" == "win32" ]
          then
            run_target_app_verbose "${CXX}" "throwcatch-lib.cpp" -shared -o "throwcatch-lib.dll" -Wl,--out-implib,libthrowcatch-lib.dll.a ${CXXFLAGS}
          else
            run_target_app_verbose "${CXX}" "throwcatch-lib.cpp" -shared -fpic -o "libthrowcatch-lib.${XBB_HOST_SHLIB_EXT}" ${CXXFLAGS}
          fi

          run_target_app_verbose "${CXX}" "throwcatch-main.cpp" -o "${prefix}throwcatch-main${suffix}${XBB_TARGET_DOT_EXE}" -L. -lthrowcatch-lib ${LDXXFLAGS}

          (
            # LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-""}
            # export LD_LIBRARY_PATH=$(pwd):${LD_LIBRARY_PATH}

            # C:\Users\ilg>"C:\Users\ilg\Desktop\New folder\lto-throwcatch-main.exe"
            # Mingw-w64 runtime failure:
            # 32 bit pseudo relocation at 00007FF74BF01697 out of range, targeting 00007FFBB05A168C, yielding the value 000000046469FFF1.

            # TODO allow it on clang
            # It happens with both bootstrap & cross.
            if [ "${is_lto}" == "y" ] && is_non_native && is_mingw_gcc
            then
              show_target_libs "${prefix}throwcatch-main${suffix}${XBB_TARGET_DOT_EXE}"
              echo
              echo "Skip ./${prefix}throwcatch-main${suffix} with gcc -flto"
            else
              show_target_libs_develop "${prefix}throwcatch-main${suffix}${XBB_TARGET_DOT_EXE}"
              run_target_app_verbose "./${prefix}throwcatch-main${suffix}"
            fi
          )
        )
      fi

      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        # tlstest-lib.dll is dynamically loaded by tltest-main.cpp.
        run_target_app_verbose "${CXX}" tlstest-lib.cpp -o tlstest-lib.dll -shared -Wl,--out-implib,libtlstest-lib.dll.a ${LDXXFLAGS}
        show_target_libs_develop "tlstest-lib.dll"

        run_target_app_verbose "${CXX}" tlstest-main.cpp -o "${prefix}tlstest-main${suffix}${XBB_TARGET_DOT_EXE}"${LDXXFLAGS}
        show_target_libs_develop ${prefix}tlstest-main${suffix}
        run_target_app_verbose "./${prefix}tlstest-main${suffix}"

        if [ "${is_static}" != "y" ]
        then
          run_target_app_verbose "${CC}" autoimport-lib.c -o autoimport-lib.dll -shared  -Wl,--out-implib,libautoimport-lib.dll.a ${LDFLAGS}
          show_target_libs_develop autoimport-lib.dll

          run_target_app_verbose "${CC}" autoimport-main.c -o "${prefix}autoimport-main${suffix}${XBB_TARGET_DOT_EXE}" -L. -lautoimport-lib ${LDFLAGS}

          # TODO allow it on clang
          # TODO allow it on bootstrap
          if [ "${is_lto}" == "y" ] && is_cross && is_mingw_gcc
          then
            show_target_libs "${prefix}autoimport-main${suffix}${XBB_TARGET_DOT_EXE}"
            echo
            echo "Skip ./${prefix}autoimport-main${suffix} with gcc -flto"
          else
            show_target_libs_develop "${prefix}autoimport-main${suffix}${XBB_TARGET_DOT_EXE}"
            run_target_app_verbose "./${prefix}autoimport-main${suffix}"
          fi
        fi

        # The IDL output isn't arch specific, but test each arch frontend
        run_target_app_verbose "${WIDL}" idltest.idl -o idltest.h -h
        run_target_app_verbose "${CC}" idltest.c -o "${prefix}idltest${suffix}${XBB_TARGET_DOT_EXE}" -I. -lole32 ${LDFLAGS}
        show_target_libs_develop "${prefix}idltest${suffix}${XBB_TARGET_DOT_EXE}"
        run_target_app_verbose "./${prefix}idltest${suffix}"
      fi

      # -----------------------------------------------------------------------

      # Test a very simple Objective-C (a printf).
      run_target_app_verbose "${CC}" simple-objc.m -o "${prefix}simple-objc${suffix}${XBB_TARGET_DOT_EXE}" ${CFLAGS}
      test_mingw_expect "Hello World" "${prefix}simple-objc${suffix}${XBB_TARGET_DOT_EXE}"

    )

    # -------------------------------------------------------------------------

    if [ ! -z ${F90+x} ]
    then
      (
        cd fortran

        # Test a very simple Fortran (a print).
        run_target_app_verbose "${F90}" hello.f90 -o "${prefix}hello-f${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}
        # The space is expected.
        test_mingw_expect " Hello" "${prefix}hello-f${suffix}${XBB_TARGET_DOT_EXE}"

        # Test a concurrent computation.
        run_target_app_verbose "${F90}" concurrent.f90 -o "${prefix}concurrent-f${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}

        show_target_libs_develop "${prefix}concurrent-f${suffix}${XBB_TARGET_DOT_EXE}"
        run_target_app_verbose "./${prefix}concurrent-f${suffix}"
      )
    else
      echo
      echo "Fortran tests skipped, compiler not available"
    fi

  )
}

# -----------------------------------------------------------------------------
