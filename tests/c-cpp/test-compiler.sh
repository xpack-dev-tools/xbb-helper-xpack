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

function test_compiler_c_cpp()
{
  echo_develop
  echo_develop "[test_compiler_c_cpp $@]"

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
    local use_libcxx_abi="n"
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

        --libc++-abi )
          use_libcxx_abi="y"
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

    CFLAGS="${CFLAGS:-""}"
    CXXFLAGS="${CXXFLAGS:-""}"
    LDFLAGS="${LDFLAGS:-""}"
    LDXXFLAGS="${LDXXFLAGS:-""}"

    if [ "${use_lld}" == "y" ]
    then
      LDFLAGS+=" -fuse-ld=lld"
      LDXXFLAGS+=" -fuse-ld=lld"
      prefix="lld-${prefix}"
    fi

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

    if [ "${use_libcxx_abi}" == "y" ]
    then
      LDXXFLAGS+=" -lc++-abi"
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
      if [[ $(basename "${CC}") =~ .*clang.* ]] && [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
      then
        :
        # clang: error: unsupported option '-static-libgcc'
        # clang++: warning: argument unused during compilation: '-static-libstdc++' [-Wunused-command-line-argument]
      else
        LDFLAGS+=" -static-libgcc"
        LDXXFLAGS+=" -static-libgcc"
        LDXXFLAGS+=" -static-libstdc++"
      fi
      prefix="static-lib-${prefix}"
    fi

    if [ "${bits}" != "" ]
    then
      CFLAGS+=" -m${bits}"
      CXXFLAGS+=" -m${bits}"
      LDFLAGS+=" -m${bits}"
      LDXXFLAGS+=" -m${bits}"
    fi

    VERBOSE="-v"
    if is_develop
    then
      CFLAGS+=" -g -v"
      CXXFLAGS+=" -g -v"
      LDFLAGS+=" -g -v"
      LDXXFLAGS+=" -g -v"

      if [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
      then
        VERBOSE+=" -Wl,-t"
      elif [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        VERBOSE+=" -Wl,-t,-t"
      fi
    fi

    (
      run_verbose_develop cd c-cpp

      if is_variable_set "XBB_SKIP_TEST_${prefix}simple-hello-c-one${suffix}" \
                         "XBB_SKIP_TEST_${prefix}simple-hello-c-one"
      then
        echo
        echo "Skipping ${prefix}simple-hello-c-one${suffix}..."
      else
        # Test C compile and link in a single step.
        run_host_app_verbose "${CC}" "simple-hello.c" -o "${prefix}simple-hello-c-one${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} ${VERBOSE}
        expect_target_output "Hello" "${prefix}simple-hello-c-one${suffix}${XBB_TARGET_DOT_EXE}"
      fi

      if is_variable_set "XBB_SKIP_TEST_${prefix}simple-hello-c-two${suffix}" \
                         "XBB_SKIP_TEST_${prefix}simple-hello-c-two"
      then
        echo
        echo "Skipping ${prefix}simple-hello-c-two${suffix}..."
      else
        # Test C compile and link in separate steps.
        run_host_app_verbose "${CC}" -c "simple-hello.c" -o "simple-hello.c.o" ${CFLAGS}
        run_host_app_verbose "${CC}" "simple-hello.c.o" -o "${prefix}simple-hello-c-two${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}
        expect_target_output "Hello" "${prefix}simple-hello-c-two${suffix}${XBB_TARGET_DOT_EXE}"
      fi

      # -----------------------------------------------------------------------

      if is_variable_set "XBB_SKIP_TEST_${prefix}simple-hello-cpp-one${suffix}" \
                         "XBB_SKIP_TEST_${prefix}simple-hello-cpp-one"
      then
        echo
        echo "Skipping ${prefix}simple-hello-cpp-one${suffix}..."
      else
        # Test C++ compile and link in a single step.
        run_host_app_verbose "${CXX}" "simple-hello.cpp" -o "${prefix}simple-hello-cpp-one${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS} ${VERBOSE}
        expect_target_output "Hello" "${prefix}simple-hello-cpp-one${suffix}${XBB_TARGET_DOT_EXE}"
      fi

      if is_variable_set "XBB_SKIP_TEST_${prefix}simple-hello-cpp-two${suffix}" \
                         "XBB_SKIP_TEST_${prefix}simple-hello-cpp-two"
      then
        echo
        echo "Skipping ${prefix}simple-hello-cpp-two${suffix}..."
      else
        # Test C++ compile and link in separate steps.
        run_host_app_verbose "${CXX}" -c "simple-hello.cpp" -o "${prefix}simple-hello${suffix}.cpp.o" ${CXXFLAGS}
        run_host_app_verbose "${CXX}" "${prefix}simple-hello${suffix}.cpp.o" -o "${prefix}simple-hello-cpp-two${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
        expect_target_output "Hello" "${prefix}simple-hello-cpp-two${suffix}${XBB_TARGET_DOT_EXE}"
      fi

      # -----------------------------------------------------------------------

      if [ "${is_static}" != "y" ]
      then
        (
          if is_variable_set "XBB_SKIP_TEST_${prefix}adder-static${suffix}" \
                            "XBB_SKIP_TEST_${prefix}adder-static"
          then
            echo
            echo "Skipping ${prefix}adder-static${suffix}..."
          else
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
          fi

          if is_variable_set "XBB_SKIP_TEST_${prefix}adder-shared${suffix}" \
                            "XBB_SKIP_TEST_${prefix}adder-shared"
          then
            echo
            echo "Skipping ${prefix}adder-shared${suffix}..."
          else
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
          fi
        )
      fi

      # -----------------------------------------------------------------------

      if is_variable_set "XBB_SKIP_TEST_${prefix}simple-exception${suffix}" \
                         "XBB_SKIP_TEST_${prefix}simple-exception"
      then
        echo
        echo "Skipping ${prefix}simple-exception${suffix}..."
      else
        run_host_app_verbose "${CXX}" "simple-exception.cpp" -o "${prefix}simple-exception${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
        expect_target_output "MyException" "${prefix}simple-exception${suffix}${XBB_TARGET_DOT_EXE}"
      fi

      if is_variable_set "XBB_SKIP_TEST_${prefix}simple-str-exception${suffix}" \
                         "XBB_SKIP_TEST_${prefix}simple-str-exception"
      then
        echo
        echo "Skipping ${prefix}simple-str-exception${suffix}..."
      else
        run_host_app_verbose "${CXX}" "simple-str-exception.cpp" -o "${prefix}simple-str-exception${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
        expect_target_output "MyStringException" "${prefix}simple-str-exception${suffix}${XBB_TARGET_DOT_EXE}"
      fi

      if is_variable_set "XBB_SKIP_TEST_${prefix}simple-int-exception${suffix}" \
                         "XBB_SKIP_TEST_${prefix}simple-int-exception"
      then
        echo
        echo "Skipping ${prefix}simple-int-exception${suffix}..."
      else
        run_host_app_verbose "${CXX}" "simple-int-exception.cpp" -o "${prefix}simple-int-exception${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
        expect_target_output "42" "${prefix}simple-int-exception${suffix}${XBB_TARGET_DOT_EXE}"
      fi

      # -----------------------------------------------------------------------

      if is_variable_set "XBB_SKIP_TEST_${prefix}sleepy-threads${suffix}" \
                         "XBB_SKIP_TEST_${prefix}sleepy-threads"
      then
        echo
        echo "Skipping ${prefix}sleepy-threads${suffix}..."
      else
        if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
        then
          run_host_app_verbose "${CXX}" "sleepy-threads.cpp" -o "${prefix}sleepy-threads${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS} -lpthread
        else
          run_host_app_verbose "${CXX}" "sleepy-threads.cpp" -o "${prefix}sleepy-threads${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
        fi

        expect_target_output "abcd" "${prefix}sleepy-threads${suffix}${XBB_TARGET_DOT_EXE}" 4
        expect_target_output "abcdefgh" "${prefix}sleepy-threads${suffix}${XBB_TARGET_DOT_EXE}" 8
      fi

      if is_variable_set "XBB_SKIP_TEST_${prefix}sleepy-threads-cv${suffix}" \
                         "XBB_SKIP_TEST_${prefix}sleepy-threads-cv"
      then
        echo
        echo "Skipping ${prefix}sleepy-threads-cv${suffix}..."
      else
        if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
        then
          run_host_app_verbose "${CXX}" "sleepy-threads-cv.cpp" -o "${prefix}sleepy-threads-cv${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS} -lpthread
        else
          run_host_app_verbose "${CXX}" "sleepy-threads-cv.cpp" -o "${prefix}sleepy-threads-cv${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
        fi

        expect_target_output "abcd" "${prefix}sleepy-threads-cv${suffix}${XBB_TARGET_DOT_EXE}" 4
        expect_target_output "abcdefgh" "${prefix}sleepy-threads-cv${suffix}${XBB_TARGET_DOT_EXE}" 8
      fi

      # -----------------------------------------------------------------------

      if is_variable_set "XBB_SKIP_TEST_${prefix}atomic${suffix}" \
                         "XBB_SKIP_TEST_${prefix}atomic"
      then
        echo
        echo "Skipping ${prefix}atomic${suffix}..."
      else
        # Test borrowed from https://gist.github.com/floooh/10160514
        if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
        then
          run_host_app_verbose "${CXX}" "atomic.cpp" -o "${prefix}atomic${suffix}${XBB_TARGET_DOT_EXE}" -Wno-format -latomic ${LDXXFLAGS}
        else
          run_host_app_verbose "${CXX}" "atomic.cpp" -o "${prefix}atomic${suffix}${XBB_TARGET_DOT_EXE}" -Wno-format ${LDXXFLAGS}
        fi
        show_target_libs_develop "${prefix}atomic${suffix}${XBB_TARGET_DOT_EXE}"
        expect_target_succeed "${prefix}atomic${suffix}${XBB_TARGET_DOT_EXE}"
      fi

      # -----------------------------------------------------------------------
      # Tests borrowed from the llvm-mingw project.

      if is_variable_set "XBB_SKIP_TEST_${prefix}hello${suffix}" \
                         "XBB_SKIP_TEST_${prefix}hello"
      then
        echo
        echo "Skipping ${prefix}hello${suffix}..."
      else
        run_host_app_verbose "${CC}" "hello.c" -o "${prefix}hello${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} -lm
        show_target_libs_develop "${prefix}hello${suffix}${XBB_TARGET_DOT_EXE}"
        expect_target_succeed "${prefix}hello${suffix}${XBB_TARGET_DOT_EXE}"
      fi

      if is_variable_set "XBB_SKIP_TEST_${prefix}setjmp${suffix}" \
                         "XBB_SKIP_TEST_${prefix}setjmp"
      then
        echo
        echo "Skipping ${prefix}setjmp${suffix}..."
      else
        # run_host_app_verbose "${CC}" "setjmp-patched.c" -o "${prefix}setjmp${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} -lm
        run_host_app_verbose "${CC}" "setjmp.c" -o "${prefix}setjmp${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} -lm
        show_target_libs_develop "${prefix}setjmp${suffix}${XBB_TARGET_DOT_EXE}"
        expect_target_succeed "${prefix}setjmp${suffix}${XBB_TARGET_DOT_EXE}"
      fi

      if is_variable_set "XBB_SKIP_TEST_${prefix}hello-cpp${suffix}" \
                         "XBB_SKIP_TEST_${prefix}hello-cpp"
      then
        echo
        echo "Skipping ${prefix}hello-cpp${suffix}..."
      else
        run_host_app_verbose "${CXX}" "hello-cpp.cpp" -o "${prefix}hello-cpp${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
        show_target_libs_develop "${prefix}hello-cpp${suffix}${XBB_TARGET_DOT_EXE}"
        expect_target_succeed "${prefix}hello-cpp${suffix}${XBB_TARGET_DOT_EXE}"
      fi

      if is_variable_set "XBB_SKIP_TEST_${prefix}global-terminate${suffix}" \
                         "XBB_SKIP_TEST_${prefix}global-terminate"
      then
        echo
        echo "Skipping ${prefix}global-terminate${suffix}..."
      else
        run_host_app_verbose "${CXX}" "global-terminate.cpp" -o "${prefix}global-terminate${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
        show_target_libs_develop "${prefix}global-terminate${suffix}${XBB_TARGET_DOT_EXE}"

        if is_variable_set "XBB_SKIP_RUN_TEST_${prefix}global-terminate${suffix}" \
                          "XBB_SKIP_RUN_TEST_${prefix}global-terminate"
        then
          echo
          echo "Skipping running ${prefix}global-terminate${suffix}..."
        else
          expect_target_succeed "${prefix}global-terminate${suffix}${XBB_TARGET_DOT_EXE}"
        fi
      fi


      if is_variable_set "XBB_SKIP_TEST_${prefix}longjmp-cleanup${suffix}" \
                         "XBB_SKIP_TEST_${prefix}longjmp-cleanup"
      then
        echo
        echo "Skipping ${prefix}longjmp-cleanup${suffix}..."
      else
        run_host_app_verbose "${CXX}" "longjmp-cleanup.cpp" -o "${prefix}longjmp-cleanup${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
        show_target_libs_develop "${prefix}longjmp-cleanup${suffix}${XBB_TARGET_DOT_EXE}"
        expect_target_succeed "${prefix}longjmp-cleanup${suffix}${XBB_TARGET_DOT_EXE}"
      fi

      if is_variable_set "XBB_SKIP_TEST_${prefix}hello-exception${suffix}" \
                         "XBB_SKIP_TEST_${prefix}hello-exception"
      then
        echo
        echo "Skipping ${prefix}hello-exception${suffix}..."
      else
        run_host_app_verbose "${CXX}" "hello-exception.cpp" -o "${prefix}hello-exception${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
        show_target_libs_develop "${prefix}hello-exception${suffix}${XBB_TARGET_DOT_EXE}"
        expect_target_succeed "${prefix}hello-exception${suffix}${XBB_TARGET_DOT_EXE}"
      fi

      if is_variable_set "XBB_SKIP_TEST_${prefix}exception-locale${suffix}" \
                         "XBB_SKIP_TEST_${prefix}exception-locale"
      then
        echo
        echo "Skipping ${prefix}exception-locale${suffix}..."
      else
        run_host_app_verbose "${CXX}" "exception-locale.cpp" -o "${prefix}exception-locale${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
        show_target_libs_develop "${prefix}exception-locale${suffix}${XBB_TARGET_DOT_EXE}"
        expect_target_succeed "${prefix}exception-locale${suffix}${XBB_TARGET_DOT_EXE}"
      fi

      if is_variable_set "XBB_SKIP_TEST_${prefix}exception-reduced${suffix}" \
                         "XBB_SKIP_TEST_${prefix}exception-reduced"
      then
        echo
        echo "Skipping ${prefix}exception-reduced${suffix}..."
      else
        run_host_app_verbose "${CXX}" "exception-reduced.cpp" -o "${prefix}exception-reduced${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
        show_target_libs_develop "${prefix}exception-reduced${suffix}${XBB_TARGET_DOT_EXE}"

        if is_variable_set "XBB_SKIP_RUN_TEST_${prefix}exception-reduced${suffix}" \
                           "XBB_SKIP_RUN_TEST_${prefix}exception-reduced"
        then
          echo
          echo "Skipping running ${prefix}exception-reduced${suffix}..."
        else
          expect_target_succeed "${prefix}exception-reduced${suffix}${XBB_TARGET_DOT_EXE}"
        fi
      fi


      if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
      then
        if is_variable_set "XBB_SKIP_TEST_${prefix}hello-tls${suffix}" \
                           "XBB_SKIP_TEST_${prefix}hello-tls"
        then
          echo
          echo "Skipping ${prefix}hello-tls${suffix}..."
        else
          run_host_app_verbose "${CC}" "hello-tls.c" -o "${prefix}hello-tls${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}
          show_target_libs_develop "${prefix}hello-tls${suffix}${XBB_TARGET_DOT_EXE}"
          expect_target_succeed "${prefix}hello-tls${suffix}${XBB_TARGET_DOT_EXE}"
        fi

        if false
        then
          # -lssp not available.
          run_host_app_verbose "${CC}" "bufferoverflow.c" -o "${prefix}bufferoverflow${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} -D_FORTIFY_SOURCE=2 -lssp
          show_target_libs_develop "${prefix}bufferoverflow${suffix}${XBB_TARGET_DOT_EXE}"
          expect_target_succeed "${prefix}bufferoverflow${suffix}${XBB_TARGET_DOT_EXE}"
          expect_target_succeed "${prefix}bufferoverflow${suffix}${XBB_TARGET_DOT_EXE}" 1
          expect_target_succeed "${prefix}bufferoverflow${suffix}${XBB_TARGET_DOT_EXE}" 2
          expect_target_succeed "${prefix}bufferoverflow${suffix}${XBB_TARGET_DOT_EXE}" 3
          expect_target_succeed "${prefix}bufferoverflow${suffix}${XBB_TARGET_DOT_EXE}" 4
          expect_target_succeed "${prefix}bufferoverflow${suffix}${XBB_TARGET_DOT_EXE}" 5
          expect_target_succeed "${prefix}bufferoverflow${suffix}${XBB_TARGET_DOT_EXE}" 6
          expect_target_succeed "${prefix}bufferoverflow${suffix}${XBB_TARGET_DOT_EXE}" 7
          expect_target_succeed "${prefix}bufferoverflow${suffix}${XBB_TARGET_DOT_EXE}" 8
          expect_target_succeed "${prefix}bufferoverflow${suffix}${XBB_TARGET_DOT_EXE}" 9
          expect_target_succeed "${prefix}bufferoverflow${suffix}${XBB_TARGET_DOT_EXE}" 10

          # Control Flow Guard is _not_ enabled!
          run_host_app_verbose "${CC}" "cfguard-test.c" -o "${prefix}cfguard-test${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} -mguard=cf
          show_target_libs_develop "${prefix}cfguard-test${suffix}${XBB_TARGET_DOT_EXE}"
          expect_target_succeed "${prefix}cfguard-test${suffix}${XBB_TARGET_DOT_EXE}"
          expect_target_succeed "${prefix}cfguard-test${suffix}${XBB_TARGET_DOT_EXE}" check_enabled
          expect_target_succeed "${prefix}cfguard-test${suffix}${XBB_TARGET_DOT_EXE}" normal_icall
          expect_target_succeed "${prefix}cfguard-test${suffix}${XBB_TARGET_DOT_EXE}" invalid_icall
          expect_target_succeed "${prefix}cfguard-test${suffix}${XBB_TARGET_DOT_EXE}" invalid_icall_nocf
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
        expect_target_succeed "${prefix}crt-test${suffix}${XBB_TARGET_DOT_EXE}"
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

      # Test weak.
      (
        run_verbose_develop cd weak

        for name in add1-weak-dummy-chained dummy expected3-add1-weak expected5 main add2 expected1 expected3 main-weak
        do
          run_host_app_verbose "${CC}" -c "${name}.c" -o "${prefix}${name}${suffix}.c.o" ${CFLAGS}
        done

        for name in overload-new unwind-main unwind-strong unwind-weak-dummy unwind-weak
        do
          run_host_app_verbose "${CXX}" -c "${name}.cpp" -o "${prefix}${name}${suffix}.cpp.o" ${CXXFLAGS}
        done

        if is_variable_set "XBB_SKIP_TEST_ALL_normal${suffix}" \
                           "XBB_SKIP_TEST_${prefix}normal${suffix}" \
                           "XBB_SKIP_TEST_${prefix}normal"
        then
          echo
          echo "Skipping ${prefix}normal${suffix}..."
        else
          # normal
          run_host_app_verbose "${CC}" "${prefix}main${suffix}.c.o" "${prefix}add2${suffix}.c.o" "${prefix}expected3${suffix}.c.o" "${prefix}dummy${suffix}.c.o" -o "${prefix}normal${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}

          show_target_libs_develop "${prefix}normal${suffix}${XBB_TARGET_DOT_EXE}"
          expect_target_succeed "${prefix}normal${suffix}${XBB_TARGET_DOT_EXE}"
        fi

        # TODO: investigate why it fails with GCC 14 on macOS.
        if is_variable_set "XBB_SKIP_TEST_ALL_weak-undef-c${suffix}" \
                           "XBB_SKIP_TEST_${prefix}weak-undef-c${suffix}" \
                           "XBB_SKIP_TEST_${prefix}weak-undef-c"
        then
          echo
          echo "Skipping ${prefix}weak-undef-c${suffix}..."
        else
          # weak-undef
          run_host_app_verbose "${CC}" "${prefix}main-weak${suffix}.c.o" "${prefix}expected1${suffix}.c.o" "${prefix}dummy${suffix}.c.o" -o "${prefix}weak-undef${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}

          show_target_libs_develop "${prefix}weak-undef${suffix}${XBB_TARGET_DOT_EXE}"
          expect_target_succeed "${prefix}weak-undef${suffix}${XBB_TARGET_DOT_EXE}"
        fi

        if is_variable_set "XBB_SKIP_TEST_ALL_weak-defined-c${suffix}" \
                           "XBB_SKIP_TEST_ALL_weak-defined-c" \
                           "XBB_SKIP_TEST_${prefix}weak-defined-c${suffix}" \
                           "XBB_SKIP_TEST_${prefix}weak-defined-c"
        then
          echo
          echo "Skipping ${prefix}weak-defined-c${suffix}..."
        else
          # weak-defined
          run_host_app_verbose "${CC}" "${prefix}main-weak${suffix}.c.o" "${prefix}add2${suffix}.c.o" "${prefix}expected3${suffix}.c.o" "${prefix}dummy${suffix}.c.o" -o "${prefix}weak-defined${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}

          show_target_libs_develop "${prefix}weak-defined${suffix}${XBB_TARGET_DOT_EXE}"
          expect_target_succeed "${prefix}weak-defined${suffix}${XBB_TARGET_DOT_EXE}"
        fi

        if is_variable_set "XBB_SKIP_TEST_ALL_weak-use-c${suffix}" \
                           "XBB_SKIP_TEST_ALL_weak-use-c" \
                           "XBB_SKIP_TEST_${prefix}weak-use-c${suffix}" \
                           "XBB_SKIP_TEST_${prefix}weak-use-c"
        then
          echo
          echo "Skipping ${prefix}weak-use-c${suffix}..."
        else
          # weak-use
          run_host_app_verbose "${CC}" "${prefix}main${suffix}.c.o" "${prefix}add1-weak-dummy-chained${suffix}.c.o" "${prefix}expected3${suffix}.c.o" -o "${prefix}weak-use${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}

          show_target_libs_develop "${prefix}weak-use${suffix}${XBB_TARGET_DOT_EXE}"
          expect_target_succeed "${prefix}weak-use${suffix}${XBB_TARGET_DOT_EXE}"
        fi

        if is_variable_set "XBB_SKIP_TEST_ALL_weak-override-c${suffix}" \
                           "XBB_SKIP_TEST_ALL_weak-override-c" \
                           "XBB_SKIP_TEST_${prefix}weak-override-c${suffix}" \
                           "XBB_SKIP_TEST_${prefix}weak-override-c"
        then
          echo
          echo "Skipping ${prefix}weak-override-c${suffix}..."
        else
          # weak-override
          run_host_app_verbose "${CC}" "${prefix}main${suffix}.c.o" "${prefix}add1-weak-dummy-chained${suffix}.c.o" "${prefix}add2${suffix}.c.o" "${prefix}expected5${suffix}.c.o" -o "${prefix}weak-override${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}

          show_target_libs_develop "${prefix}weak-override${suffix}${XBB_TARGET_DOT_EXE}"
          expect_target_succeed "${prefix}weak-override${suffix}${XBB_TARGET_DOT_EXE}"
        fi

        if is_variable_set "XBB_SKIP_TEST_ALL_weak-duplicate-c${suffix}" \
                           "XBB_SKIP_TEST_ALL_weak-duplicate-c" \
                           "XBB_SKIP_TEST_${prefix}weak-duplicate-c${suffix}" \
                           "XBB_SKIP_TEST_${prefix}weak-duplicate-c"
        then
          echo
          echo "Skipping ${prefix}weak-duplicate-c${suffix}..."
        else
          # weak-duplicate
          run_host_app_verbose "${CC}" "${prefix}main${suffix}.c.o" "${prefix}add1-weak-dummy-chained${suffix}.c.o" "${prefix}expected3-add1-weak${suffix}.c.o" -o "${prefix}weak-duplicate${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}

          show_target_libs_develop "${prefix}weak-duplicate${suffix}${XBB_TARGET_DOT_EXE}"
          expect_target_succeed "${prefix}weak-duplicate${suffix}${XBB_TARGET_DOT_EXE}"
        fi

        if is_variable_set "XBB_SKIP_TEST_ALL_overload-new-cpp${suffix}" \
                           "XBB_SKIP_TEST_ALL_overload-new-cpp" \
                           "XBB_SKIP_TEST_${prefix}overload-new-cpp${suffix}" \
                           "XBB_SKIP_TEST_${prefix}overload-new-cpp"
        then
          echo
          echo "Skipping ${prefix}overload-new-cpp${suffix}..."
        else
          # overload-new
          run_host_app_verbose "${CXX}" "${prefix}overload-new${suffix}.cpp.o" -o "${prefix}overload-new${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}

          show_target_libs_develop "${prefix}overload-new${suffix}${XBB_TARGET_DOT_EXE}"
          expect_target_succeed "${prefix}overload-new${suffix}${XBB_TARGET_DOT_EXE}"
        fi

        if is_variable_set "XBB_SKIP_TEST_ALL_unwind-weak-cpp${suffix}" \
                           "XBB_SKIP_TEST_ALL_unwind-weak-cpp" \
                           "XBB_SKIP_TEST_${prefix}unwind-weak-cpp${suffix}" \
                           "XBB_SKIP_TEST_${prefix}unwind-weak-cpp"
        then
          echo
          echo "Skipping ${prefix}unwind-weak-cpp${suffix}..."
        else
          # unwind-weak
          run_host_app_verbose "${CXX}" "${prefix}unwind-weak${suffix}.cpp.o" "${prefix}unwind-main${suffix}.cpp.o" -o "${prefix}unwind-weak${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}

          show_target_libs_develop "${prefix}unwind-weak${suffix}${XBB_TARGET_DOT_EXE}"
          expect_target_succeed "${prefix}unwind-weak${suffix}${XBB_TARGET_DOT_EXE}"
        fi

        # TODO: investigate why it fails with GCC 14 on macOS.
        if is_variable_set "XBB_SKIP_TEST_ALL_unwind-strong-cpp${suffix}" \
                           "XBB_SKIP_TEST_ALL_unwind-strong-cpp" \
                           "XBB_SKIP_TEST_${prefix}unwind-strong-cpp${suffix}" \
                           "XBB_SKIP_TEST_${prefix}unwind-strong-cpp"
        then
          echo
          echo "Skipping ${prefix}unwind-strong-cpp${suffix}..."
        else
          # unwind-strong
          run_host_app_verbose "${CXX}" "${prefix}unwind-weak-dummy${suffix}.cpp.o" "${prefix}unwind-main${suffix}.cpp.o" "${prefix}unwind-strong${suffix}.cpp.o" -o "${prefix}unwind-strong${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}

          show_target_libs_develop "${prefix}unwind-strong${suffix}${XBB_TARGET_DOT_EXE}"
          expect_target_succeed "${prefix}unwind-strong${suffix}${XBB_TARGET_DOT_EXE}"
        fi

      )

      # Test if exceptions thrown from shared libraries are caught.
      if [ "${is_static}" != "y" ]
      then
        (
          if is_variable_set "XBB_SKIP_TEST_${prefix}throwcatch-main${suffix}" \
                             "XBB_SKIP_TEST_${prefix}throwcatch-main"
          then
            echo
            echo "Skipping ${prefix}throwcatch-main${suffix}..."
          else
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
              expect_target_succeed "${prefix}throwcatch-main${suffix}${XBB_TARGET_DOT_EXE}"
            fi
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
          expect_target_succeed "${prefix}tlstest-main${suffix}${XBB_TARGET_DOT_EXE}"
        fi

        if [ "${is_static}" != "y" ]
          then
          if is_variable_set "XBB_SKIP_TEST_${prefix}autoimport-main${suffix}" \
                             "XBB_SKIP_TEST_${prefix}autoimport-main"
          then
            echo
            echo "Skipping ${prefix}autoimport-main${suffix}..."
          else
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
              expect_target_succeed "${prefix}autoimport-main${suffix}${XBB_TARGET_DOT_EXE}"
            fi
          fi
        fi

        if is_variable_set "XBB_SKIP_TEST_${prefix}idltest${suffix}" \
                           "XBB_SKIP_TEST_${prefix}idltest"
        then
          echo
          echo "Skipping ${prefix}idltest${suffix}..."
        else
          # The IDL output isn't arch specific, but test each arch frontend
          run_host_app_verbose "${WIDL}" idltest.idl -o idltest.h -h
          run_host_app_verbose "${CC}" idltest.c -o "${prefix}idltest${suffix}${XBB_TARGET_DOT_EXE}" -I. -lole32 ${LDFLAGS}
          show_target_libs_develop "${prefix}idltest${suffix}${XBB_TARGET_DOT_EXE}"
          expect_target_succeed "${prefix}idltest${suffix}${XBB_TARGET_DOT_EXE}"
        fi
      fi

      # -----------------------------------------------------------------------

      if is_variable_set "XBB_SKIP_TEST_${prefix}simple-objc${suffix}" \
                         "XBB_SKIP_TEST_${prefix}simple-objc"
      then
        echo
        echo "Skipping ${prefix}simple-objc${suffix}..."
      else
        # Test a very simple Objective-C (a printf).
        run_host_app_verbose "${CC}" simple-objc.m -o "${prefix}simple-objc${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}
        expect_target_output "Hello World" "${prefix}simple-objc${suffix}${XBB_TARGET_DOT_EXE}"
      fi
    )

  )
}

# -----------------------------------------------------------------------------
