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
# [--lto]
# [--gc]
# [--32|--64]
# [--static | --static-lib]
# [--crt]
# [--libunwind]
# [--lld]
# [--suffix="..."]
# [--bootstrap]

function test_compiler_c_cpp()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  echo "[${FUNCNAME[0]} $@]" >> "${XBB_TEST_RESULTS_SUMMARY_FILE_PATH}"

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

    local is_bootstrap=""

    PREFIX=""
    SUFFIX=""
    BITS_FLAGS=""

    while [ $# -gt 0 ]
    do
      case "$1" in

        --suffix=* )
          SUFFIX+=$(xbb_parse_option "$1")
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
          BITS_FLAGS="-m64"
          SUFFIX+="-64"
          shift
          ;;

        --32 )
          BITS_FLAGS="-m32"
          SUFFIX+="-32"
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

        --bootstrap )
          is_bootstrap="y"
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
      PREFIX="lld-${PREFIX}"
    fi

    if [ "${use_crt}" == "y" ]
    then
      LDFLAGS+=" -rtlib=compiler-rt"
      LDXXFLAGS+=" -rtlib=compiler-rt"
      PREFIX="crt-${PREFIX}"
    fi

    if [ "${use_libcxx}" == "y" ]
    then
      CXXFLAGS+=" -stdlib=libc++"
      LDXXFLAGS+=" -stdlib=libc++"
      PREFIX="libcxx-${PREFIX}"
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
      PREFIX="lto-${PREFIX}"
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
      PREFIX="gc-${PREFIX}"
    fi

    # --static takes precedence over --static-lib.
    if [ "${is_static}" == "y" ]
    then
      LDFLAGS+=" -static"
      LDXXFLAGS+=" -static"
      PREFIX="static-${PREFIX}"
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
      PREFIX="static-lib-${PREFIX}"
    fi

    if [ "${BITS_FLAGS}" != "" ]
    then
      CFLAGS+=" ${BITS_FLAGS}"
      CXXFLAGS+=" ${BITS_FLAGS}"
      LDFLAGS+=" ${BITS_FLAGS}"
      LDXXFLAGS+=" ${BITS_FLAGS}"
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

    if [ "${is_bootstrap}" == "y" ]
    then
      SUFFIX+="-bootstrap"
    fi

    export CFLAGS
    export CXXFLAGS
    export LDFLAGS
    export LDXXFLAGS
    export VERBOSE

    export PREFIX
    export SUFFIX
    export BITS_FLAGS

    (
      run_verbose_develop cd c-cpp

      set +o errexit  # Do not exit if commands fail, to allow continuation.

      # -----------------------------------------------------------------------

      test_case_simple_hello1_c_one
      test_case_simple_hello1_c_two

      # -----------------------------------------------------------------------

      test_case_simple_hello2_cpp_one
      test_case_simple_hello2_cpp_two

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

      # Unfortunately timings are unreliable on CI machines.
      # test_case_sleepy_threads_sl

      test_case_sleepy_threads_cv

      # -----------------------------------------------------------------------

      test_case_atomic

      # -----------------------------------------------------------------------
      # Tests borrowed from the llvm-mingw project.

      test_case_hello1_c
      test_case_setjmp
      test_case_hello2_cpp
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

      test_case_cnrt_test
      test_case_hello_weak1_c
      test_case_hello_weak2_cpp

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

function test_case_simple_hello1_c_one()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    # Test C compile and link in a single step.
    run_host_app_verbose "${CC}" "simple-hello1.c" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} ${VERBOSE}
    expect_target_output "Hello" "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_simple_hello1_c_two()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    # Test C compile and link in separate steps.
    run_host_app_verbose "${CC}" -c "simple-hello1.c" -o "simple-hello1.c.o" ${CFLAGS}
    run_host_app_verbose "${CC}" "simple-hello1.c.o" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}
    expect_target_output "Hello" "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

# -----------------------------------------------------------------------------

function test_case_simple_hello2_cpp_one()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    # Test C++ compile and link in a single step.
    run_host_app_verbose "${CXX}" "simple-hello2.cpp" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS} ${VERBOSE}
    expect_target_output "Hello" "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_simple_hello2_cpp_two()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    # Test C++ compile and link in separate steps.
    run_host_app_verbose "${CXX}" -c "simple-hello2.cpp" -o "${PREFIX}simple-hello2${SUFFIX}.cpp.o" ${CXXFLAGS}
    run_host_app_verbose "${CXX}" "${PREFIX}simple-hello2${SUFFIX}.cpp.o" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
    expect_target_output "Hello" "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

# -----------------------------------------------------------------------------

function test_case_adder_static()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
    then
      run_host_app_verbose "${CC}" -c "add.c" -o "${PREFIX}add${SUFFIX}.c.o" ${CFLAGS}
    elif [ "${XBB_TARGET_PLATFORM}" == "linux" ] && [[ $(basename "${CC}") =~ .*clang.* ]]
    then
      # Old linkers (like Ubuntu 18, RedHat 8, Fedora 29)
      # are not happy with clang IR, use object files.
      CFLAGS_NO_LTO=$(echo ${CFLAGS} | sed -e 's|-flto||')
      run_host_app_verbose "${CC}" -c "add.c" -o "${PREFIX}add${SUFFIX}.c.o" ${CFLAGS_NO_LTO}
    else
      run_host_app_verbose "${CC}" -c "add.c" -o "${PREFIX}add${SUFFIX}.c.o" -fpic ${CFLAGS}
    fi

    rm -rf libadd-static.a
    run_host_app_verbose "${AR}" -r "lib${PREFIX}add-static${SUFFIX}.a" "${PREFIX}add${SUFFIX}.c.o"
    run_host_app_verbose "${RANLIB}" "lib${PREFIX}add-static${SUFFIX}.a"

    run_host_app_verbose "${CC}" "adder.c" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" -L . -l"${PREFIX}add-static${SUFFIX}" ${LDFLAGS}

    expect_target_output "42" "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" 40 2

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_adder_shared()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
    then
      # The `--out-implib` creates an import library, which can be
      # directly used with -l.
      run_host_app_verbose "${CC}" "${PREFIX}add${SUFFIX}.c.o" -shared -o "lib${PREFIX}add-shared${SUFFIX}.dll" -Wl,--out-implib,"lib${PREFIX}add-shared${SUFFIX}.dll.a" -Wl,--subsystem,windows ${LDFLAGS}

      # -ladd-shared is in fact libadd-shared.dll.a
      # The library does not show as DLL, it is loaded dynamically.
      run_host_app_verbose "${CC}" "adder.c" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" -L . -l"${PREFIX}add-shared${SUFFIX}" ${LDFLAGS}
    else
      run_host_app_verbose "${CC}" "${PREFIX}add${SUFFIX}.c.o" -shared -o "lib${PREFIX}add-shared${SUFFIX}.${XBB_TARGET_SHLIB_EXT}" ${LDFLAGS}

      # show_target_libs "lib${PREFIX}add-shared${SUFFIX}.${XBB_TARGET_SHLIB_EXT}"

      run_host_app_verbose "${CC}" "adder.c" -o "${PREFIX}${test_case_name}${SUFFIX}" -L . -l"${PREFIX}add-shared${SUFFIX}" ${LDFLAGS}

      if [ "${XBB_HOST_PLATFORM}" == "linux" ]
      then
        export LD_LIBRARY_PATH=$(pwd):${LD_LIBRARY_PATH:-}
        echo
        echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"
      fi
    fi

    expect_target_output "42" "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" 40 2

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

# -----------------------------------------------------------------------------

function test_case_simple_exception()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CXX}" "simple-exception.cpp" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
    expect_target_output "MyException" "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_simple_str_exception()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CXX}" "simple-str-exception.cpp" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
    expect_target_output "MyStringException" "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_simple_int_exception()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CXX}" "simple-int-exception.cpp" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
    expect_target_output "42" "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

# -----------------------------------------------------------------------------

function test_case_sleepy_threads_sl()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
    then
      run_host_app_verbose "${CXX}" "sleepy-threads-sl.cpp" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS} -lpthread
    else
      run_host_app_verbose "${CXX}" "sleepy-threads-sl.cpp" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
    fi

    expect_target_output "abcd" "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" 4
    expect_target_output "abcdefgh" "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" 8

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_sleepy_threads_cv()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
    then
      run_host_app_verbose "${CXX}" "sleepy-threads-cv.cpp" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS} -lpthread
    else
      run_host_app_verbose "${CXX}" "sleepy-threads-cv.cpp" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}
    fi

    expect_target_output "abcd" "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" 4
    expect_target_output "abcdefgh" "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" 8

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

# -----------------------------------------------------------------------------

function test_case_atomic()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    # Test borrowed from https://gist.github.com/floooh/10160514
    if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
    then
      run_host_app_verbose "${CXX}" "atomic.cpp" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" -Wno-format -latomic ${LDXXFLAGS}
    else
      run_host_app_verbose "${CXX}" "atomic.cpp" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" -Wno-format ${LDXXFLAGS}
    fi

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

# -----------------------------------------------------------------------------

function test_case_hello1_c()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CC}" "hello1.c" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} -lm

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

# -----------------------------------------------------------------------------

function test_case_setjmp()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    # The patch compares floats using fabs and a small epsilon.
    run_host_app_verbose "${CC}" "setjmp-patched.c" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} -lm
    # run_host_app_verbose "${CC}" "setjmp.c" -o "${PREFIX}setjmp${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} -lm

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_hello2_cpp()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CXX}" "hello2.cpp" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_global_terminate()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CXX}" "global-terminate.cpp" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_longjmp_cleanup()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CXX}" "longjmp-cleanup.cpp" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_hello_exception()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CXX}" "hello-exception.cpp" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_exception_locale()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CXX}" "exception-locale.cpp" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_exception_reduced()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CXX}" "exception-reduced.cpp" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_hello_tls()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CC}" "hello-tls.c" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_bufferoverflow()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CC}" "bufferoverflow.c" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} -D_FORTIFY_SOURCE=2 -lssp

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"
    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" 1
    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" 2
    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" 3
    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" 4
    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" 5
    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" 6
    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" 7
    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" 8
    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" 9
    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" 10

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_cnrt_test()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    # This test uses math functions. On Windows -lm is not mandatory.
    run_host_app_verbose "${CC}" cnrt-test.c -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDFLAGS} -lm

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_hello_weak1_c()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CC}" -c "hello-weak1.c" -o "${PREFIX}hello-weak1${SUFFIX}.c.o" ${CFLAGS}
    run_host_app_verbose "${CC}" -c "hello-f-weak1.c" -o "${PREFIX}hello-f-weak1${SUFFIX}.c.o" ${CFLAGS}
    run_host_app_verbose "${CC}" "${PREFIX}hello-weak1${SUFFIX}.c.o" "${PREFIX}hello-f-weak1${SUFFIX}.c.o" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" -lm ${LDFLAGS}
    expect_target_output "Hello World!" "./${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_hello_weak2_cpp()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CXX}" -c "hello-weak2.cpp" -o "${PREFIX}hello-weak2${SUFFIX}.cpp.o" ${CXXFLAGS}
    run_host_app_verbose "${CXX}" -c "hello-f-weak2.cpp" -o "${PREFIX}hello-f-weak2${SUFFIX}.cpp.o" ${CXXFLAGS}
    run_host_app_verbose "${CXX}" "${PREFIX}hello-weak2${SUFFIX}.cpp.o" "${PREFIX}hello-f-weak2${SUFFIX}.cpp.o" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" -lm ${LDXXFLAGS}
    expect_target_output "Hello World!" "./${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_normal()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CC}" "${PREFIX}main${SUFFIX}.c.o" "${PREFIX}add2${SUFFIX}.c.o" "${PREFIX}expected3${SUFFIX}.c.o" "${PREFIX}dummy${SUFFIX}.c.o" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_weak_undef_c()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CC}" "${PREFIX}main-weak${SUFFIX}.c.o" "${PREFIX}expected1${SUFFIX}.c.o" "${PREFIX}dummy${SUFFIX}.c.o" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_weak_defined_c()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CC}" "${PREFIX}main-weak${SUFFIX}.c.o" "${PREFIX}add2${SUFFIX}.c.o" "${PREFIX}expected3${SUFFIX}.c.o" "${PREFIX}dummy${SUFFIX}.c.o" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_weak_use_c()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CC}" "${PREFIX}main${SUFFIX}.c.o" "${PREFIX}add1-weak-dummy-chained${SUFFIX}.c.o" "${PREFIX}expected3${SUFFIX}.c.o" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_weak_override_c()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CC}" "${PREFIX}main${SUFFIX}.c.o" "${PREFIX}add1-weak-dummy-chained${SUFFIX}.c.o" "${PREFIX}add2${SUFFIX}.c.o" "${PREFIX}expected5${SUFFIX}.c.o" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_weak_duplicate_c()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CC}" "${PREFIX}main${SUFFIX}.c.o" "${PREFIX}add1-weak-dummy-chained${SUFFIX}.c.o" "${PREFIX}expected3-add1-weak${SUFFIX}.c.o" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_overload_new_cpp()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CXX}" "${PREFIX}overload-new${SUFFIX}.cpp.o" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_unwind_weak_cpp()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CXX}" "${PREFIX}unwind-weak${SUFFIX}.cpp.o" "${PREFIX}unwind-main${SUFFIX}.cpp.o" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_unwind_strong_cpp()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CXX}" "${PREFIX}unwind-weak-dummy${SUFFIX}.cpp.o" "${PREFIX}unwind-main${SUFFIX}.cpp.o" "${PREFIX}unwind-strong${SUFFIX}.cpp.o" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDXXFLAGS}

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_weak_common()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    for name in add1-weak-dummy-chained dummy expected3-add1-weak expected5 main add2 expected1 expected3 main-weak
    do
      run_host_app_verbose "${CC}" -c "${name}.c" -o "${PREFIX}${name}${SUFFIX}.c.o" ${CFLAGS}
    done

    for name in overload-new unwind-main unwind-strong unwind-weak-dummy unwind-weak
    do
      run_host_app_verbose "${CXX}" -c "${name}.cpp" -o "${PREFIX}${name}${SUFFIX}.cpp.o" ${CXXFLAGS}
    done

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_throwcatch_main()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

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
      run_host_app_verbose "${CXX}" "throwcatch-main.cpp" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" -L. -lthrowcatch-lib ${LDXXFLAGS}
    else
      run_host_app_verbose "${CXX}" "throwcatch-main.cpp" -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" -L. -lthrowcatch-lib ${LDXXFLAGS} -Wl,--allow-multiple-definition
    fi

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_tlstest_main()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    # tlstest-lib.dll is dynamically loaded by tltest-main.cpp.
    run_host_app_verbose "${CXX}" tlstest-lib.cpp -o tlstest-lib.dll -shared -Wl,--out-implib,libtlstest-lib.dll.a ${LDXXFLAGS}
    show_target_libs_develop "tlstest-lib.dll"

    run_host_app_verbose "${CXX}" tlstest-main.cpp -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"${LDXXFLAGS}
    show_target_libs_develop ${PREFIX}${test_case_name}${SUFFIX}
    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_autoimport_main()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    run_host_app_verbose "${CC}" autoimport-lib.c -o autoimport-lib.dll -shared  -Wl,--out-implib,libautoimport-lib.dll.a ${LDFLAGS}
    show_target_libs_develop autoimport-lib.dll

    run_host_app_verbose "${CC}" autoimport-main.c -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" -L. -lautoimport-lib ${LDFLAGS}

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

function test_case_idltest()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    # The IDL output isn't arch specific, but test each arch frontend
    run_host_app_verbose "${WIDL}" idltest.idl -o idltest.h -h
    run_host_app_verbose "${CC}" idltest.c -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" -I. -lole32 ${LDFLAGS}

    expect_target_succeed "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

# -----------------------------------------------------------------------------

function test_case_simple_objc()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR

    # Test a very simple Objective-C (a printf).
    run_host_app_verbose "${CC}" simple-objc.m -o "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}" ${LDFLAGS}
    expect_target_output "Hello World" "${PREFIX}${test_case_name}${SUFFIX}${XBB_TARGET_DOT_EXE}"

    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}

# -----------------------------------------------------------------------------

# Template to acc new test cases.

# -----------------------------------------------------------------------------

function test_case_()
{
  local test_case_name="$(test_case_get_name)"

  (
    trap 'test_case_trap_handler ${test_case_name} $? $LINENO; return 0' ERR


    test_case_pass "${test_case_name}"
  ) 2>&1 | tee "${XBB_TEST_RESULTS_FOLDER_PATH}/${PREFIX}${test_case_name}${SUFFIX}.txt"
}
