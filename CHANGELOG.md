# Change & release log

Entries in this file are in reverse chronological order.

## 2023-01-31

* v1.4.3 released
* 5b6b128 add libusb-win32-1.2.7.3.pc
* 6c45e93 readline.sh: 8.2 fails on mingw
* 3af16d0 pixman.sh: --disable-arm-a64-neon
* 4a4406a glib.sh: disable tests, they fail to build

## 2023-01-30

* fc523cc libpng.sh: fix bash syntax
* v1.4.2 released
* 3f22db9 add hidapi-0.13.1-windows.pc
* b2ef2dd libusb0.sh: add call to bootstrap.sh
* 899f117 hidapi.sh: update versions

## 2023-01-29

* v1.4.1 released

## 2023-01-28

* c640fff pkg-config.sh: fix -Wint-conversion

## 2023-01-27

* v1.4.0 released
* 4189880 dependencies: use versioning functions
* 96a75ee xbb.sh: add versioning functions
* 8b18127 xbb.sh: add xbb_strip_macosx_version_min
* 9888c49 download.sh: verbose Patch not found
* v1.3.2 released
* fa80da1 package.json: reorder scripts
* c16e0f0 add extras/pyconfig-win-3.1[01].*.h
* 135b723 dependencies: use MACOSX_DEPLOYMENT_TARGET
* 247409d xbb.sh: use Apple MACOSX_DEPLOYMENT_TARGET env

## 2023-01-24

* v1.3.1 released
* 4c9e0c5 templates: use xpm@next
* 102a12c test-common.sh: source download.sh

## 2023-01-23

* b91e9c5 templates: show xpm --version after install
* f0662ef README update
* af3d81a templates: rename job names to lower case

## 2023-01-22

* f0662ef README update
* af3d81a templates: rename job names to lower
* v1.3.0 released
* e116e99 use is_variable_set
* 01ade7a compiler-tests.sh: cleanup skip comments
* daceb7f compiler-tests.sh: use XBB_SKIP_*TEST
* aef28b3 is-something.sh: upper case in is_variable_set
* 7668d24 compiler-tests.sh: XBB_SKIP_*global-terminate*
* 9b3ca6b is-something.sh: add is_variable_set

## 2023-01-14

* v1.2.0 released
* b5059d0 xbb.sh: keep system strip on macos clang
* 7a963de xbb.sh: keep system linker on macos clang
* fd63b2c xbb.sh: rework xbb_prepare_clang_env to use llvm-*
* 80d8661 xbb.sh: optimise     xbb_prepare_gcc_env

## 2023-01-13

* 4ba203e xbb.sh: comments & cosmetics
* 6ea5732 xbb.sh: add ADDR2LINE to environment
* 63c7203 xbb.sh: extend *prepare_gcc_env with --lto
* 4781499 mingw.sh: no longer needed to clear CC

## 2023-01-12

* c097618 Merge branch 'xpack-develop' of https://github.com/xpack-dev-tools/xbb-helper-xpack into xpack-develop
* cfaa2f8 cmake -LAH
* 6a4a941 Merge branch 'xpack-develop' of https://github.com/xpack-dev-tools/xbb-helper-xpack into xpack-develop
* fb5a1ed machine.sh: validate requested vs build

## 2023-01-11

* d4165c6 xbb.sh: filter non-existent folders for -rpath mac
2023-01-11 * 33ae9d0 xbb.sh: filter non-existing folders in -rpath
2023-01-11 * e3adbcd xbb.sh: split rpath into multiple options

## 2023-01-10

* 5575b90 cosmetize xbb_adjust_ldflags_rpath
* 0e65e18 compiler-tests.sh: add -lpthread -ldl
* 514b19e xbb.sh: always empty XBB_LIBRARY_PATH
* 509f3ce compiler-tests.sh: throwcatch-main on all i686-*-gcc
* 1d9b61b xbb.sh: early use XBB_REQUESTED_HOST_PLATFORM
* 9d67166 xbb.sh:  XBB_LIBRARY_PATH only non win32
* 347717b compiler-tests.sh: fix pwd LD_LIBRARY_PATH
* 7aac415 gcc.sh: use xbb_get_libs_path
* 0a7efd1 xbb.sh: add clang to xbb_update_ld_library_path
* f9648ab xbb.sh: add xbb_get_libs_path()

## 2023-01-09

* caf71f6 xbb.sh: simplify XBB_LIBRARY_PATH
* b60a203 compiler-tests.sh: use XBB_LIBRARY_PATH on linux
* 2f9e23f binutils.sh: use XBB_LIBRARY_PATH for linux
* 2690fb2 xbb.sh: use XBB_LIBRARY_PATH for linux
* 96f754b zstd.sh: use XBB_LIBRARY_PATH on macOS
* 0cfe302 xbb.sh: use XBB_LIBRARY_PATH on macOS
* 60d482c _apps-xbb.sh: comment out LD_LIBRARY_PATH
* e780d6d zstd.sh: comment out -DCMAKE_INSTALL_RPATH
* fb73543 xbb.sh: comment out DYLD_LIBRARY_PATH
* f111743 libftdi.sh: set build_type
* ed99e51 xbb.sh: cosmetics
* 852afa3 xbb.sh: separate DYLD_LIBRARY_PATH for macOS
* 4e2d06a xbb.sh: no longer preserve initial LD_LIBRARY_PATH
* 5249b0e python3.sh: comment out unused XBB_HOST_PLATFORM
* 0fe54ba _addp-xbb.sh: comment out unused XBB_HOST_PLATFORM
* 9b9b2b3 zstd.sh: use DYLD_LIBRARY_PATH on macOS
* aaa9233 _libs.sh: use LD_LIBRARY_PATH only on linux
* 31b7130 compiler-tests.sh: LD_LIBRARY_PATH only on linux
* d5a83b7 binutils.sh: use LD_LIBRARY_PATH only on linux
* dd5b7d6 xbb.sh: no -rpath-link on macOS
* 7f4aa3c _apps-xbb.sh: : comment out explicit libs
* 61b6278 gcc.sh: comment out explicit libs
* 9652d3e glib.sh: : comment out explicit libs
* 9b12d76 libssh.sh: comment out explicit libs
* 724ea38 libusb1.sh: comment out explicit libs
* 9d1c1fc qemu.sh: comment out explicit libs
* 7b65287 xbb.sh: xbb_update_ld_library_path use all paths
* 83a899c xbb.sh: xbb_update_ld_library_path
* 3ffd7d2 xbb.sh: fix messages in xbb_set_extra_target_env

## 2023-01-08

* f8e3792 xbb.sh: fix xbb_set_extra_target_env display

## 2023-01-07

* d775daa fix typo
* 6c45631 mingw.sh: add explicit --libdir to winpthreads
* 5d44d29 xbb.sh: reimplement *_ALL_SYS_FOLDERS_TO_RPATH
* 13f3962 xbb.sh: fall back for gcc-ar, gcc-nm, gcc-ranlib
* d054940 xbb.sh: more empty lines in xbb_show_env
* 8971ac4 xbb.sh: FUNCNAME[0]
* cbb0fa5 define & use global REALPATH
* 7941892 build-tests.sh: verbose winecfg; sleep
2023-01-06 * 340058b vde.sh: rename vde_patch_file_name
2023-01-06 * c6d2ebf XBB_CXXFLAGS+=" -Wno-psabi" on linux-arm
2023-01-06 * d2cdc21 cmake -LH only when IS_DEVELOP
2023-01-05 * 75e065d hidapi.sh: -LH for cmake
2023-01-05 * 7e4e127 libftdi.sh: use ninja for build
2023-01-05 * c990266 libssh.sh: use ninja for build
2023-01-05 * fa59c8a zstd.sh: verbose cmake
2023-01-05 * f392ddd post-processing.sh: keep some >>> in log
2023-01-05 * c8ef3a8 post-processing.sh: skip linking itself

## 2023-01-03

* v1.1.4 released
* 3471e71 gcc.sh: use cxx_lib_path in PATH on windows
* 758369f gcc-mingw.sh: use cxx_lib_path in PATH on windows
* fb4d2fe gcc-mingw.sh: update tests when running on windows
* 651ae9b gcc-cross.sh: update tests when running on windows
* 2f8ebfa binutils.sh: update tests when running on windows
* 2f68746 README update
* v1.1.3 released
* b27b4a9 Revert "wrappers.sh: use wine64 to run 32-bit exe"
* 89e542e timer.sh: replace missing XBB_REQUESTED_TARGET
* v1.1.2 released
* 9bbc384 trigger-workflow-build.sh: fix json syntax
* 3d85765 workflow inputs require underscore

## 2023-01-02

* v1.0.0 released
* f42987d wrappers.sh: use wine64 to run 32-bit exe
* 990b251 maintainer/README update
* ca027ed zstd.sh: -DCMAKE_SYSTEM_NAME=Windows
* 8271240 cosmetics remove trailing dot
* 72a726c timer.sh: show requested target in timer stop
* 4052a2b maintainer/README update

## 2023-01-01

* b9289ea build-all.sh: init excluded
* 4f356a4 build-all.sh: check excluded array length
* 7002b2a build-all.sh: re-enable bulk of actions
* 322da75 build-all.sh: use IFS in exclusion test
* adf9690 build-all.sh: add run_verbose
* 468f9c0 build-all.sh: rework for bash 3.x
* f5c3ef6 cosmetics
* 139bfc5 libftdi.sh: cosmetics -DCMAKE_INSTALL_PREFIX
* e94646a cosmetics --prefix, sysroot, program-prefix/suffix
* 6d77270 cleanup *_STATIC_GCC
* bf1798b gcc-cross.sh: add -lphread to final step
* c69fdbd gcc-cross.sh: cleanup
* e688cbe gcc-cross.sh: add -lpthread for zstd
* 5d2e82a build-all.sh: implement exclusion properly
* 58155ee gcc-mingw.sh: fix ZSTD with -lpthread
* cf4ca61 gcc.sh: fix ZSTD with -lpthread
* a7237e1 build-all.sh: add --exclude
* f64dd8e gcc.sh: re-enable LIBS=-lzstd
* be567b0 gcc-mingw.sh: re-enable LIBS=-lzstd
* 626183b gcc-cross.sh: explicit --with-gmp, etc
* cd8aab5 re-enable zstd
* cbd3c43 gcc-mingw.sh: re-enable zstd
* 77ad863 gcc.sh: remove --without-zstd
* c715331 gcc.sh: re-enable --with-zstd
* a06627c builds-all.sh: sort list of files

## 2022-12-31

* 2e45d6b maintainer/README: prefix builds with time
* d8fb2eb maintainer/README update
* c633d1c build-all.sh: show full command on dry run
* aff28bb build-all.sh: rename --dry-run
* 84fbc7c build-all.sh: add --deep-clean
* e2fdd44 build-all.sh: reformat summaries
* cebb39a build-all.sh: show copied files summary
* 697b989 binutils.sh: add application/lib after triplet/lib
* 1657d9f build-all.sh: ad an extra line to duration report
* 14bfedb build-all.sh: wine only on linux-x64
* f883685 build-all.sh: add explicit exit 0
* a39d1d4 build-all.sh: add --status
* 00b8472 build-all.sh: add docker-remove

## 2022-12-30

* dc5f0e5 build-all.sh: use ${HOME}
* 99ecdec build-all.sh: clone if not already there
* 65c9515 build-all.sh: re-enable first packages
* ff72c2c python3.sh: remove echo_develop from helpers
* 50811dc python3.sh: remove echo_develop from helpers
* 5bc4d40 ncurses.sh: -ldl
* 74e2453 sqlite.sh: --disable-readline
* 516d285 build-all.sh: xpm run install
* fbe7809 qemu.sh: LDFLAGS+=" -ldl -ludev -lpthread -lrt"
* 388b8f1 libssh.sh: LDFLAGS+=" -lpthread -ldl -lrt"
* 03b5f14 glib.sh: LDFLAGS+=" -lpthread -ldl -lresolv"
* ffb4966 glib.sh: fix build folder
* f306b92 libusb1.sh: export LIBS="-lrt -lpthread" on linux
* 07d62cf README update
* e0b88a8 gcc.sh: disable zstd
* d259a3e gcc-mingw.sh: disable zstd

## 2022-12-29

* 675f268 gcc-mingw.sh: cleanup
* d9bcb5f gcc-mingw.sh: document LIBS hack
* 73443b3 gcc.sh: re-enable bootstrap
* 45f0905 gcc.sh: conditional LIBS="-lzstd -lpthread"
* 6c70137 post-processing.sh: use realpath in install_file
* 0965659 gcc-mingw.sh: conditional LIBS="-lzstd -lpthread"
* fbf5a4a xbb.sh: conditional /usr/bin/g++ paths
* f19e14e build-common.sh: show copied files
* fc9459e post-processing.sh: use install_file on windows
* 8bbec2b gcc-mingw.sh: LIBS="-lzstd -lpthread"
* 6a81261 xbb.sh: shorten LD_LIBRARY_PATH
* 42e2d85 binutils.sh: elif is_cross for LD_LIBRARY_PATH
* f3da5fc xbb.sh: add comments in set target
* d81b4d0 trigger-workflow-build.sh: pass xpm-version
* 7cfdd99 binutils.sh: is_native LD_LIBRARY_PATH
* d5055ee trigger-workflow-build.sh: pass loglevel
* 044e407 templates/build-*.yml: xpm install --loglevel *
* c798691 templates/build-*.yml: rename xpm-install-options
* 6be1903 templates/build-*.yml: add input types & link
* d1fded3 templates/build-*.yml: add xpm-install-loglevel
* ed1d6da binutils.sh: adjust LD_LIBRARY_PATH for mingw
* 444b609 xbb.sh: move activate_cxx_rpath to deps_dev

## 2022-12-28

* 3901488 templates/build-*: add xpm-version & verbosity
* a523824 binutils.sh: skip 64-bit bfd for i686-w64-mingw32
* 28515a2 binutils.sh: cleanup
* f01a9a8 binutils.sh: pass ${triplet} to prepare_common_options

## 2022-12-27

* 66936b8 post-processing.sh: =~ .*[.]dylib
* ad0c4f4 regexp '[.].*'
* 29d8152 post-processing.sh: which install_name_tool
* 6dcfae1 show-libs.sh: use ${XBB_*_OBJDUMP}
* v1.0.0 released

## 2022-12-23

* v0.11.39 released

## 2022-12-22

* v0.11.36 released (deleted)

## 2022-12-21

* v0.11.35 released (deleted)

## 2022-12-20

* v0.11.30 released (deleted)

## 2022-12-19

* v0.11.29 released (deleted)

## 2022-12-15

* v0.11.28 released
* v0.11.27 released

## 2022-12-14

* v0.11.24 released (deleted)

## 2022-12-13

* v0.11.19 released (deleted)

## 2022-12-12

* v0.11.17 released

## 2022-12-11

* v0.11.15 released
* v0.11.14 released

## 2022-11-14

* v0.11.8 released

## 2022-11-12

* v0.11.7 released

## 2022-11-11

* v0.11.3 released

## 2022-11-04

* v0.10.1 released

## 2022-11-03

* v0.10.0 released

## 2022-10-27

* v0.9.6 released

## 2022-10-26

* v0.9.2 released

## 2022-10-25

* v0.8.7 released

## 2022-10-24

* v0.8.3 released

## 2022-10-23

* v0.8.1 released

## 2022-10-21

* v0.7.4 released

## 2022-10-20

* v0.7.1 released

## 2022-10-14

* v0.6.0 released
* v0.5.33 released

## 2022-10-13

* v0.5.29 released

## 2022-10-12

* v0.5.27 released

## 2022-10-11

* v0.5.16 released

## 2022-10-10

* v0.5.7 released

## 2022-10-09

* v0.5.5 released

## 2022-10-08

* v0.4.5 released

## 2022-10-07

* v0.4.1 released

## 2022-10-06

* v0.3.0 released
* v0.2.0 released

## 2022-10-05

* v0.1.0 released

## 2022-10-04

* created
