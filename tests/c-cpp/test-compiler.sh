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
  echo_develop "[${FUNCNAME[0]} $@]"

  echo "[${FUNCNAME[0]} $@]" >> "${XBB_TEST_RESULTS_FILE_PATH}"

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

    prefix=""
    suffix=""
    bits=""

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

    export CC
    export CXX

    export CFLAGS
    export CXXFLAGS
    export LDFLAGS
    export LDXXFLAGS
    export VERBOSE

    export prefix
    export suffix
    export bits

    (
      run_verbose_develop cd c-cpp

      set +o errexit  # Do not exit if commands fail, to allow continuation.

      # -----------------------------------------------------------------------

      test_case_simple_hello_c_one
      test_case_simple_hello_c_two

      # -----------------------------------------------------------------------

      test_case_simple_hello_cpp_one
      test_case_simple_hello_cpp_two

      # -----------------------------------------------------------------------

      if [ "${is_static}" != "y" ]
      then
        (
          # Sub-shell required by LD_LIBRARY_PATH.
          test_case_adder_static
          test_case_adder_shared
        )
      fi

      # -----------------------------------------------------------------------

      test_case_simple_exception
      test_case_simple_str_exception
      test_case_simple_int_exception

      # -----------------------------------------------------------------------

      test_case_sleepy_threads
      test_case_sleepy_threads_cv

      # -----------------------------------------------------------------------

      test_case_atomic

      # -----------------------------------------------------------------------
      # Tests borrowed from the llvm-mingw project.

      test_case_hello
      test_case_setjmp
      test_case_hello_cpp
      test_case_global_terminate
      test_case_longjmp_cleanup
      test_case_hello_exception
      test_case_exception_locale
      test_case_exception_reduced

      if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
      then
        test_case_hello_tls

        if true # false
        then
          # -lssp not available.
          test_case_bufferoverflow
        fi
      fi

      test_case_crt_test
      test_case_hello_weak_c
      test_case_hello_weak_cpp

      # Test weak.
      (
        run_verbose_develop cd weak

        test_case_weak_common
        test_case_normal
        # TODO: investigate why it fails with GCC 14 on macOS.
        test_case_weak_undef_c
        test_case_weak_defined_c
        test_case_weak_use_c
        test_case_weak_override_c
        test_case_weak_duplicate_c
        test_case_overload_new_cpp
        test_case_unwind_weak_cpp
        # TODO: investigate why it fails with GCC 14 on macOS.
        test_case_unwind_strong_cpp
      )

      # Test if exceptions thrown from shared libraries are caught.
      if [ "${is_static}" != "y" ]
      then
        (
          # Sub-shell required by LD_LIBRARY_PATH.
          test_case_throwcatch_main
        )
      fi

      if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
      then

        test_case_tlstest_main

        if [ "${is_static}" != "y" ]
        then
          test_case_autoimport_main
        fi

        test_case_idltest

      fi

      # -----------------------------------------------------------------------

      test_case_simple_objc
    )

  )
}

# -----------------------------------------------------------------------------

function test_case_simple_hello_c_one()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  # Test C compile and link in a single step.
  run_host_app_verbose "${CC}" "simple-hello.c" -o "${prefix}simple-hello-c-one${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} ${VERBOSE}
  expect_target_output "Hello" "${prefix}simple-hello-c-one${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_simple_hello_c_two()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  # Test C compile and link in separate steps.
  run_host_app_verbose "${CC}" -c "simple-hello.c" -o "simple-hello.c.o" ${CFLAGS}
  run_host_app_verbose "${CC}" "simple-hello.c.o" -o "${prefix}simple-hello-c-two${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}
  expect_target_output "Hello" "${prefix}simple-hello-c-two${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

# -----------------------------------------------------------------------------

function test_case_simple_hello_cpp_one()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  # Test C++ compile and link in a single step.
  run_host_app_verbose "${CXX}" "simple-hello.cpp" -o "${prefix}simple-hello-cpp-one${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS} ${VERBOSE}
  expect_target_output "Hello" "${prefix}simple-hello-cpp-one${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_simple_hello_cpp_two()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  # Test C++ compile and link in separate steps.
  run_host_app_verbose "${CXX}" -c "simple-hello.cpp" -o "${prefix}simple-hello${suffix}.cpp.o" ${CXXFLAGS}
  run_host_app_verbose "${CXX}" "${prefix}simple-hello${suffix}.cpp.o" -o "${prefix}simple-hello-cpp-two${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
  expect_target_output "Hello" "${prefix}simple-hello-cpp-two${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

# -----------------------------------------------------------------------------

function test_case_adder_static()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

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

  test_case_pass "${test_case_name}"
}

function test_case_adder_shared()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

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

  test_case_pass "${test_case_name}"
}

# -----------------------------------------------------------------------------

function test_case_simple_exception()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  run_host_app_verbose "${CXX}" "simple-exception.cpp" -o "${prefix}simple-exception${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
  expect_target_output "MyException" "${prefix}simple-exception${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_simple_str_exception()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  run_host_app_verbose "${CXX}" "simple-str-exception.cpp" -o "${prefix}simple-str-exception${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
  expect_target_output "MyStringException" "${prefix}simple-str-exception${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_simple_int_exception()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  run_host_app_verbose "${CXX}" "simple-int-exception.cpp" -o "${prefix}simple-int-exception${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
  expect_target_output "42" "${prefix}simple-int-exception${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

# -----------------------------------------------------------------------------

function test_case_sleepy_threads()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
  then
    run_host_app_verbose "${CXX}" "sleepy-threads.cpp" -o "${prefix}sleepy-threads${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS} -lpthread
  else
    run_host_app_verbose "${CXX}" "sleepy-threads.cpp" -o "${prefix}sleepy-threads${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
  fi

  expect_target_output "abcd" "${prefix}sleepy-threads${suffix}${XBB_TARGET_DOT_EXE}" 4
  expect_target_output "abcdefgh" "${prefix}sleepy-threads${suffix}${XBB_TARGET_DOT_EXE}" 8

  test_case_pass "${test_case_name}"
}

function test_case_sleepy_threads_cv()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
  then
    run_host_app_verbose "${CXX}" "sleepy-threads-cv.cpp" -o "${prefix}sleepy-threads-cv${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS} -lpthread
  else
    run_host_app_verbose "${CXX}" "sleepy-threads-cv.cpp" -o "${prefix}sleepy-threads-cv${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
  fi

  expect_target_output "abcd" "${prefix}sleepy-threads-cv${suffix}${XBB_TARGET_DOT_EXE}" 4
  expect_target_output "abcdefgh" "${prefix}sleepy-threads-cv${suffix}${XBB_TARGET_DOT_EXE}" 8

  test_case_pass "${test_case_name}"
}

# -----------------------------------------------------------------------------

function test_case_atomic()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  # Test borrowed from https://gist.github.com/floooh/10160514
  if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
  then
    run_host_app_verbose "${CXX}" "atomic.cpp" -o "${prefix}atomic${suffix}${XBB_TARGET_DOT_EXE}" -Wno-format -latomic ${LDXXFLAGS}
  else
    run_host_app_verbose "${CXX}" "atomic.cpp" -o "${prefix}atomic${suffix}${XBB_TARGET_DOT_EXE}" -Wno-format ${LDXXFLAGS}
  fi
  show_target_libs_develop "${prefix}atomic${suffix}${XBB_TARGET_DOT_EXE}"
  expect_target_succeed "${prefix}atomic${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

# -----------------------------------------------------------------------------

function test_case_hello()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  run_host_app_verbose "${CC}" "hello.c" -o "${prefix}hello${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} -lm
  show_target_libs_develop "${prefix}hello${suffix}${XBB_TARGET_DOT_EXE}"
  expect_target_succeed "${prefix}hello${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

# -----------------------------------------------------------------------------

function test_case_setjmp()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  # run_host_app_verbose "${CC}" "setjmp-patched.c" -o "${prefix}setjmp${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} -lm
  run_host_app_verbose "${CC}" "setjmp.c" -o "${prefix}setjmp${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} -lm
  show_target_libs_develop "${prefix}setjmp${suffix}${XBB_TARGET_DOT_EXE}"
  expect_target_succeed "${prefix}setjmp${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_hello_cpp()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  run_host_app_verbose "${CXX}" "hello-cpp.cpp" -o "${prefix}hello-cpp${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
  show_target_libs_develop "${prefix}hello-cpp${suffix}${XBB_TARGET_DOT_EXE}"
  expect_target_succeed "${prefix}hello-cpp${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_global_terminate()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  run_host_app_verbose "${CXX}" "global-terminate.cpp" -o "${prefix}global-terminate${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
  show_target_libs_develop "${prefix}global-terminate${suffix}${XBB_TARGET_DOT_EXE}"

  expect_target_succeed "${prefix}global-terminate${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_longjmp_cleanup()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  run_host_app_verbose "${CXX}" "longjmp-cleanup.cpp" -o "${prefix}longjmp-cleanup${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
  show_target_libs_develop "${prefix}longjmp-cleanup${suffix}${XBB_TARGET_DOT_EXE}"
  expect_target_succeed "${prefix}longjmp-cleanup${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_hello_exception()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  run_host_app_verbose "${CXX}" "hello-exception.cpp" -o "${prefix}hello-exception${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
  show_target_libs_develop "${prefix}hello-exception${suffix}${XBB_TARGET_DOT_EXE}"
  expect_target_succeed "${prefix}hello-exception${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_exception_locale()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  run_host_app_verbose "${CXX}" "exception-locale.cpp" -o "${prefix}exception-locale${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
  show_target_libs_develop "${prefix}exception-locale${suffix}${XBB_TARGET_DOT_EXE}"
  expect_target_succeed "${prefix}exception-locale${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_exception_reduced()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  run_host_app_verbose "${CXX}" "exception-reduced.cpp" -o "${prefix}exception-reduced${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
  show_target_libs_develop "${prefix}exception-reduced${suffix}${XBB_TARGET_DOT_EXE}"

  expect_target_succeed "${prefix}exception-reduced${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_hello_tls()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  run_host_app_verbose "${CC}" "hello-tls.c" -o "${prefix}hello-tls${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}
  show_target_libs_develop "${prefix}hello-tls${suffix}${XBB_TARGET_DOT_EXE}"
  expect_target_succeed "${prefix}hello-tls${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_bufferoverflow()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

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

  test_case_pass "${test_case_name}"
}

function test_case_crt_test()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  # This test uses math functions. On Windows -lm is not mandatory.
  run_host_app_verbose "${CC}" crt-test.c -o "${prefix}crt-test${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} -lm
  show_target_libs_develop "${prefix}crt-test${suffix}${XBB_TARGET_DOT_EXE}"
  expect_target_succeed "${prefix}crt-test${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_hello_weak_c()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  run_host_app_verbose "${CC}" -c "hello-weak.c" -o "${prefix}hello-weak${suffix}.c.o" ${CFLAGS}
  run_host_app_verbose "${CC}" -c "hello-f-weak.c" -o "${prefix}hello-f-weak${suffix}.c.o" ${CFLAGS}
  run_host_app_verbose "${CC}" "${prefix}hello-weak${suffix}.c.o" "${prefix}hello-f-weak${suffix}.c.o" -o "${prefix}hello-weak-c${suffix}${XBB_TARGET_DOT_EXE}" -lm ${LDFLAGS}
  expect_target_output "Hello World!" "./${prefix}hello-weak-c${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_hello_weak_cpp()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  run_host_app_verbose "${CXX}" -c "hello-weak-cpp.cpp" -o "${prefix}hello-weak-cpp${suffix}.cpp.o" ${CXXFLAGS}
  run_host_app_verbose "${CXX}" -c "hello-f-weak-cpp.cpp" -o "${prefix}hello-f-weak-cpp${suffix}.cpp.o" ${CXXFLAGS}
  run_host_app_verbose "${CXX}" "${prefix}hello-weak-cpp${suffix}.cpp.o" "${prefix}hello-f-weak-cpp${suffix}.cpp.o" -o "${prefix}hello-weak-cpp${suffix}${XBB_TARGET_DOT_EXE}" -lm ${LDXXFLAGS}
  expect_target_output "Hello World!" "./${prefix}hello-weak-cpp${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_normal()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  run_host_app_verbose "${CC}" "${prefix}main${suffix}.c.o" "${prefix}add2${suffix}.c.o" "${prefix}expected3${suffix}.c.o" "${prefix}dummy${suffix}.c.o" -o "${prefix}normal${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}

  show_target_libs_develop "${prefix}normal${suffix}${XBB_TARGET_DOT_EXE}"
  expect_target_succeed "${prefix}normal${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_weak_undef_c()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  run_host_app_verbose "${CC}" "${prefix}main-weak${suffix}.c.o" "${prefix}expected1${suffix}.c.o" "${prefix}dummy${suffix}.c.o" -o "${prefix}weak-undef-c${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}

  show_target_libs_develop "${prefix}weak-undef-c${suffix}${XBB_TARGET_DOT_EXE}"
  expect_target_succeed "${prefix}weak-undef-c${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_weak_defined_c()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  run_host_app_verbose "${CC}" "${prefix}main-weak${suffix}.c.o" "${prefix}add2${suffix}.c.o" "${prefix}expected3${suffix}.c.o" "${prefix}dummy${suffix}.c.o" -o "${prefix}weak-defined-c${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}

  show_target_libs_develop "${prefix}weak-defined-c${suffix}${XBB_TARGET_DOT_EXE}"
  expect_target_succeed "${prefix}weak-defined-c${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_weak_use_c()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  run_host_app_verbose "${CC}" "${prefix}main${suffix}.c.o" "${prefix}add1-weak-dummy-chained${suffix}.c.o" "${prefix}expected3${suffix}.c.o" -o "${prefix}weak-use-c${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}

  show_target_libs_develop "${prefix}weak-use-c${suffix}${XBB_TARGET_DOT_EXE}"
  expect_target_succeed "${prefix}weak-use-c${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_weak_override_c()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  run_host_app_verbose "${CC}" "${prefix}main${suffix}.c.o" "${prefix}add1-weak-dummy-chained${suffix}.c.o" "${prefix}add2${suffix}.c.o" "${prefix}expected5${suffix}.c.o" -o "${prefix}weak-override-c${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}

  show_target_libs_develop "${prefix}weak-override-c${suffix}${XBB_TARGET_DOT_EXE}"
  expect_target_succeed "${prefix}weak-override-c${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_weak_duplicate_c()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  run_host_app_verbose "${CC}" "${prefix}main${suffix}.c.o" "${prefix}add1-weak-dummy-chained${suffix}.c.o" "${prefix}expected3-add1-weak${suffix}.c.o" -o "${prefix}weak-duplicate-c${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}

  show_target_libs_develop "${prefix}weak-duplicate-c${suffix}${XBB_TARGET_DOT_EXE}"
  expect_target_succeed "${prefix}weak-duplicate-c${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_overload_new_cpp()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  run_host_app_verbose "${CXX}" "${prefix}overload-new${suffix}.cpp.o" -o "${prefix}overload-new-cpp${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}

  show_target_libs_develop "${prefix}overload-new-cpp${suffix}${XBB_TARGET_DOT_EXE}"
  expect_target_succeed "${prefix}overload-new-cpp${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_unwind_weak_cpp()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  run_host_app_verbose "${CXX}" "${prefix}unwind-weak${suffix}.cpp.o" "${prefix}unwind-main${suffix}.cpp.o" -o "${prefix}unwind-weak-cpp${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}

  show_target_libs_develop "${prefix}unwind-weak-cpp${suffix}${XBB_TARGET_DOT_EXE}"
  expect_target_succeed "${prefix}unwind-weak-cpp${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_unwind_strong_cpp()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  run_host_app_verbose "${CXX}" "${prefix}unwind-weak-dummy${suffix}.cpp.o" "${prefix}unwind-main${suffix}.cpp.o" "${prefix}unwind-strong${suffix}.cpp.o" -o "${prefix}unwind-strong-cpp${suffix}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}

  show_target_libs_develop "${prefix}unwind-strong-cpp${suffix}${XBB_TARGET_DOT_EXE}"
  expect_target_succeed "${prefix}unwind-strong-cpp${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_weak_common()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  for name in add1-weak-dummy-chained dummy expected3-add1-weak expected5 main add2 expected1 expected3 main-weak
  do
    run_host_app_verbose "${CC}" -c "${name}.c" -o "${prefix}${name}${suffix}.c.o" ${CFLAGS}
  done

  for name in overload-new unwind-main unwind-strong unwind-weak-dummy unwind-weak
  do
    run_host_app_verbose "${CXX}" -c "${name}.cpp" -o "${prefix}${name}${suffix}.cpp.o" ${CXXFLAGS}
  done

  test_case_pass "${test_case_name}"
}

function test_case_throwcatch_main()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

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
  expect_target_succeed "${prefix}throwcatch-main${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_tlstest_main()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  # tlstest-lib.dll is dynamically loaded by tltest-main.cpp.
  run_host_app_verbose "${CXX}" tlstest-lib.cpp -o tlstest-lib.dll -shared -Wl,--out-implib,libtlstest-lib.dll.a ${LDXXFLAGS}
  show_target_libs_develop "tlstest-lib.dll"

  run_host_app_verbose "${CXX}" tlstest-main.cpp -o "${prefix}tlstest-main${suffix}${XBB_TARGET_DOT_EXE}"${LDXXFLAGS}
  show_target_libs_develop ${prefix}tlstest-main${suffix}
  expect_target_succeed "${prefix}tlstest-main${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_autoimport_main()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  run_host_app_verbose "${CC}" autoimport-lib.c -o autoimport-lib.dll -shared  -Wl,--out-implib,libautoimport-lib.dll.a ${LDFLAGS}
  show_target_libs_develop autoimport-lib.dll

  run_host_app_verbose "${CC}" autoimport-main.c -o "${prefix}autoimport-main${suffix}${XBB_TARGET_DOT_EXE}" -L. -lautoimport-lib ${LDFLAGS}

  show_target_libs_develop "${prefix}autoimport-main${suffix}${XBB_TARGET_DOT_EXE}"
  expect_target_succeed "${prefix}autoimport-main${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

function test_case_idltest()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  # The IDL output isn't arch specific, but test each arch frontend
  run_host_app_verbose "${WIDL}" idltest.idl -o idltest.h -h
  run_host_app_verbose "${CC}" idltest.c -o "${prefix}idltest${suffix}${XBB_TARGET_DOT_EXE}" -I. -lole32 ${LDFLAGS}
  show_target_libs_develop "${prefix}idltest${suffix}${XBB_TARGET_DOT_EXE}"
  expect_target_succeed "${prefix}idltest${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

# -----------------------------------------------------------------------------

function test_case_simple_objc()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR

  # Test a very simple Objective-C (a printf).
  run_host_app_verbose "${CC}" simple-objc.m -o "${prefix}simple-objc${suffix}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}
  expect_target_output "Hello World" "${prefix}simple-objc${suffix}${XBB_TARGET_DOT_EXE}"

  test_case_pass "${test_case_name}"
}

# -----------------------------------------------------------------------------

# Template to acc new test cases.

# -----------------------------------------------------------------------------

function test_case_()
{
  local test_case_name="$(test_case_get_name)"
  local skips=""

  trap "test_case_trap_handler ${test_case_name} ${skips}; return" ERR


  test_case_pass "${test_case_name}"
}
