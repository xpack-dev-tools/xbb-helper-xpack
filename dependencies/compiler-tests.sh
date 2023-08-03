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
    local is_static="n"
    local is_static_lib="n"
    local use_crt="n"
    local use_libcxx="n"
    local use_libunwind="n"
    local use_lld="n"
    local use_libpthread="n"
    local use_libdl="n"

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
          use_crt="y"
          shift
          ;;

        --libc++ )
          use_libcxx="y"
          shift
          ;;

        --libunwind )
          use_libunwind="y"
          shift
          ;;

        --libpthread )
          use_libpthread="y"
          shift
          ;;

        --libdl )
          use_libdl="y"
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

    if [ "${use_crt}" == "y" ]
    then
      LDFLAGS+=" -rtlib=compiler-rt"
      LDXXFLAGS+=" -rtlib=compiler-rt"
      prefix="crt-${prefix}"
    fi

    if [ "${use_libcxx}" == "y" ]
    then
      CXXFLAGS+=" -stdlib=libc++"
      LDXXFLAGS+=" -stdlib=libc++"
      prefix="libcxx-${prefix}"
    fi

    if [ "${use_libunwind}" == "y" ]
    then
      LDFLAGS+=" -lunwind"
      LDXXFLAGS+=" -lunwind"
    fi

    if [ "${use_libpthread}" == "y" ]
    then
      LDFLAGS+=" -lpthread"
      LDXXFLAGS+=" -lpthread"
    fi

    if [ "${use_libdl}" == "y" ]
    then
      LDFLAGS+=" -ldl"
      LDXXFLAGS+=" -ldl"
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
      run_verbose_develop cd c-cpp

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

      # Test borrowed from https://gist.github.com/floooh/10160514
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        run_host_app_verbose "${CXX}" "atomic.cpp" -o "${prefix}atomic${suffix}${XBB_TARGET_DOT_EXE}" -Wno-format -latomic ${LDXXFLAGS}
      else
        run_host_app_verbose "${CXX}" "atomic.cpp" -o "${prefix}atomic${suffix}${XBB_TARGET_DOT_EXE}" -Wno-format ${LDXXFLAGS}
      fi
      show_target_libs_develop "${prefix}atomic${suffix}${XBB_TARGET_DOT_EXE}"
      run_target_app_verbose "./${prefix}atomic${suffix}"

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

      if is_variable_set "XBB_SKIP_RUN_TEST_${prefix}global-terminate${suffix}" \
                         "XBB_SKIP_RUN_TEST_${prefix}global-terminate"
      then
        echo
        echo "Skipping running ${prefix}global-terminate${suffix}..."
      else
        run_target_app_verbose "./${prefix}global-terminate${suffix}"
      fi

      run_host_app_verbose "${CXX}" "longjmp-cleanup.cpp" -o "${prefix}longjmp-cleanup${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
      show_target_libs_develop "${prefix}longjmp-cleanup${suffix}${XBB_TARGET_DOT_EXE}"
      run_target_app_verbose "./${prefix}longjmp-cleanup${suffix}"

      if is_variable_set "XBB_SKIP_TEST_${prefix}hello-exception${suffix}" \
                         "XBB_SKIP_TEST_${prefix}hello-exception"
      then
        echo
        echo "Skipping ${prefix}hello-exception${suffix}..."
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

      if is_variable_set "XBB_SKIP_TEST_${prefix}crt-test${suffix}" \
                         "XBB_SKIP_TEST_${prefix}crt-test"
      then
        echo
        echo "Skipping ${prefix}crt-test${suffix}..."
      else
        # This test uses math functions. On Windows -lm is not mandatory.
        run_host_app_verbose "${CC}" crt-test.c -o "${prefix}crt-test${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} -lm
        show_target_libs_develop "${prefix}crt-test${suffix}${XBB_TARGET_DOT_EXE}"
        run_target_app_verbose "./${prefix}crt-test${suffix}"
      fi

      if is_variable_set "XBB_SKIP_TEST_${prefix}hello-weak-c${suffix}" \
                         "XBB_SKIP_TEST_${prefix}hello-weak-c"
      then
        echo
        echo "Skipping ${prefix}hello-weak-c${suffix}..."
      else
        run_host_app_verbose "${CC}" -c "hello-weak.c" -o "${prefix}hello-weak${suffix}.c.o" ${CFLAGS}
        run_host_app_verbose "${CC}" -c "hello-f-weak.c" -o "${prefix}hello-f-weak${suffix}.c.o" ${CFLAGS}
        run_host_app_verbose "${CC}" "${prefix}hello-weak${suffix}.c.o" "${prefix}hello-f-weak${suffix}.c.o" -o "${prefix}hello-weak-c${suffix}${XBB_TARGET_DOT_EXE}" -lm ${LDFLAGS}
        expect_target_output "Hello World!" "./${prefix}hello-weak-c${suffix}${XBB_TARGET_DOT_EXE}"
      fi

      if is_variable_set "XBB_SKIP_TEST_${prefix}hello-weak-cpp${suffix}" \
                         "XBB_SKIP_TEST_${prefix}hello-weak-cpp"
      then
        echo
        echo "Skipping ${prefix}hello-weak-cpp${suffix}..."
      else
        run_host_app_verbose "${CXX}" -c "hello-weak-cpp.cpp" -o "${prefix}hello-weak-cpp${suffix}.cpp.o" ${CXXFLAGS}
        run_host_app_verbose "${CXX}" -c "hello-f-weak-cpp.cpp" -o "${prefix}hello-f-weak-cpp${suffix}.cpp.o" ${CXXFLAGS}
        run_host_app_verbose "${CXX}" "${prefix}hello-weak-cpp${suffix}.cpp.o" "${prefix}hello-f-weak-cpp${suffix}.cpp.o" -o "${prefix}hello-weak-cpp${suffix}${XBB_TARGET_DOT_EXE}" -lm ${LDXXFLAGS}
        expect_target_output "Hello World!" "./${prefix}hello-weak-cpp${suffix}${XBB_TARGET_DOT_EXE}"
      fi

      # Test weak override.
      (
        run_verbose_develop cd weak-override

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

          show_target_libs_develop "${prefix}throwcatch-main${suffix}${XBB_TARGET_DOT_EXE}"

          if is_variable_set "XBB_SKIP_RUN_TEST_${prefix}throwcatch-main${suffix}" \
                             "XBB_SKIP_RUN_TEST_${prefix}throwcatch-main"
          then
            echo
            echo "Skipping running ${prefix}throwcatch-main${suffix}..."
          else
            run_target_app_verbose "./${prefix}throwcatch-main${suffix}"
          fi
        )
      fi

      if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
      then

        if is_variable_set "XBB_SKIP_TEST_${prefix}tlstest-main${suffix}" \
                           "XBB_SKIP_TEST_${prefix}tlstest-main"
        then
          echo
          echo "Skipping ${prefix}tlstest-main${suffix}..."
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

          show_target_libs_develop "${prefix}autoimport-main${suffix}${XBB_TARGET_DOT_EXE}"

          if is_variable_set "XBB_SKIP_RUN_TEST_${prefix}autoimport-main${suffix}" \
                             "XBB_SKIP_RUN_TEST_${prefix}autoimport-main"
          then
            echo
            echo "Skipping running ${prefix}autoimport-main${suffix}..."
          else
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

    if is_variable_set "F90"
    then
      (
        run_verbose_develop cd fortran

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
