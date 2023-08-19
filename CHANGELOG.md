# Change & release log

Entries in this file are in reverse chronological order.

## 2023-08-19

* v1.8.0 released
* 35ea23f gdb-cross.sh: cosmetics
* 2d84796 gettext.sh: disable tools on windows
* 3f837c3 gdb-cross.sh: add -lmpfr for windows
* dd75d60 xbb.sh: always xbb_update_ld_library_path
* 5234486 xbb.sh: XBB_APPLICATION_USE_CLANG_LIBCXX & LLD
* aa56767 xbb.sh: XBB_APPLICATION_USE_CLANG_ON_LINUX
* 38c49a1 gettext.sh: cosmetics
* 5dc1be6 gdb-cross.sh: update arch url
* 919c687 gdb-cross.sh: patch for gcore-elf.c
* 487250b libxml2.sh: update versions
* 95f81f1 autotools.sh: disable pkg_config, use xpack

## 2023-08-18

* 3c1c9a9 xbb.sh: -stdlib=libc++
* d8a4a01 xbb.sh: XBB_APPLICATION_PREFER_GCC_ON_LINUX
* 6edad8b flex.sh: use REALPATH
* 969db86 gmp.sh: add $LDFLAGS sed patch
* ff7af22 gdb-cross.sh: update arch link
* 956025f gdb-cross.sh: libunistring_build
* 4cfdec1 gettext.sh: -Wno-incompatible-function-pointer-types
* 233f236 gdb-cross.sh: re-enable gettext
* ab2b1e1 build-common.sh: more # Build results
* 7ee794e 1.7.5
* 7b501d4 prepare v1.7.5
* 62f734c flex.sh: purge non static libs
* 3befd7c flex.sh: revert to --enable-shared
* 7441d18 1.7.4
* 15f0e07 prepare v1.7.4* 2cba4ab flex.sh: test -v
* c4b9113 flex.sh: rm *.la
* 694396f flex.sh: --disable-shared
* 7817562 1.7.3
* 914b637 prepare v1.7.3
* ffacbf3 flex.sh: test compute realpath

## 2023-08-17

* 69480b2 1.7.2
* 42fd5fd prepare v1.7.2
* 7ff22d1 test-common.sh: more tests_install_dependencies
* 6bd2c9e 1.7.1
* 5fc04d6 prepare v1.7.1
* 9631f16 test-common.sh:  tests_install_dependencies ok
* b7da686 bison.sh: which g++
* 9ea604e 1.7.0
* 90500fe package.json 1.7.0-pre
* e529060 prepare v1.7.0
* 3a89864 test-common.sh: add tests_install_dependencies
* 87843f0 1.6.0
* b09ca3f prepare v1.6.0
* 335d185 dot.ignore /*.tgz
* a3d6d9a bison.sh remove documentation
* 6b7fc78 flex.sh: remove documentation
* f050ade flex.sh: --disable-warnings
* d901c1a dot.* update
* da5ab57 gcc-cross.sh: temp xbb_activate_installed_bin
* afac4d7 gcc-cross.sh: temp xbb_activate_installed_bin
* a987c67 gettext.sh: add link to bug requiring libunistring
* cd9774e gdb-cross: temporarily disable gettext
* 69ef343 extract libunistring.sh
* 0f89a7e gettext.sh: rework with tools, for autopoint
* b612841 extract flex.sh

## 2023-08-16

* ad8268e gdb-13.2-cross.git.patch update for 12.3.rel1
* d6d6079 gdb-cross: update from aarch64 12.3.rel1
* 172c20a newlib-cross.sh: cosmetics
* 8131e0f gdb-cross.sh: xbb_activate_installed_bin
* f68300a extract bison.sh from legacy

## 2023-08-15

* 1b7ab11 add gdb-12.2/13.2-cross.git.patch
* 73ac6e5 1.5.2
* 657fa89 prepare v1.5.2
* dc0e75a rename build-xbbla-liquid.yml
* d681e38 1.5.1
* 82159ee rename xbbla (no 64)
* f3e1cab prepare v1.5.1
* d40b94c vde.sh: -Wno-implicit-int

## 2023-08-06

* 355987a dot.npmignore wrappers

## 2023-08-05

* 23c8d5b READMEs update

## 2023-08-03

* ea41ece templates/dot.* add build*
* 497e06e 1.5.0
* 871375d prepare v1.5.0
* a780ac9 compiler-tests.sh: run_host_app_verbose for atomic
* 630cca8 compiler-tests.sh: add suffix-less checks
* 294d437 compiler-tests.sh: fix -latomic only on linux

## 2023-08-02

* 8b7c82d xbb.sh: apple_clang_env() fix missing prefix
* 1bb95db atomic.cpp: (TYPE)-1
* efbcff8 xbb.sh: add xbb_prepare_apple_clang_env
* 9dab08c compiler-tests.sh: rename use_crt
* 1b6f42a compiler-tests.sh: add --libc+
* e4aa9ac compiler-tests.sh: add -latomic to linux tests
* eaca1e5 atomic.cpp: add asserts

## 2023-08-01

* 2f5c5fb add test/atomic.cpp
* 6cc6830 dependencies: run_verbose_develop cd
* 468b4e7 mingw.sh: run_verbose ls

## 2023-07-30

* f0e3dc5 libxml2.sh: explicit -liconv on linux
* b34509d wrappers.sh: add run_host_app()
* f49306c compiler-tests.sh: check hello-weak-c(pp)
* 782f898 is-something.sh is_variable_set $#
* cf4af65 gcc.sh: skip failing win32 tests
* 4487d43 gcc.sh: reorder xbb_adjust_ldflags_rpath
* 7d7dd60 gcc-mingw.sh: skip failing tests
* 14b7456 gcc-mingw.sh: add ${bits}
* 94b24a5 crt-test.c: skip lgamma & lgammaf on 10.13
* b2b2719 gcc.sh: reorder patch logic
* 563505b xbb.sh: xbb_prepare_clang_env() no llvm-as on mac

## 2023-07-28

* 659b567 gcc.sh: add 13.*, 12.3, 11.4
* 25c3480 1.4.15
* bd5351f prepare v1.4.15
* def4099 liquidjs --context --template
* ad2b88c 1.4.14
* d234836 prepare v1.4.14
* 3b2d102 1.4.13
* 7bcd7b2 CHANGELOG update
* ef06ba5 README update
* 486f2a5 sqlite.sh: add 3420000
* ad37ab7 add pyconfig-win-3.11.4.h

## 2023-07-27

* 30c8a40 1.4.12
* 452a140 prepare v1.4.12
* 7eb2adf xbb.sh: try to fix recursive chmod a+w
* 77be29f 1.4.11
* 9b99e0e prepare v1.4.11
* b76922a package.json: minXpm 0.16.3
* d32d572 @xpack-dev-tools/xbb-helper/
* v1.4.10 released
* af8336f templates: replace latest by explicit version

## 2023-07-26

* 7e2824c READMEs update xpack-dev-tools path
* ff581c7 READMEs update

## 2023-07-16

* 1.4.9
* 3b49185 more XBB_WITH_STRIP checks

## 2023-07-08

* 064c558 xpack-dev-tools
* 4ae07f9 xpack-dev-tools-build

## 2023-03-31

* 4a82860 dependencies CMAKE=$(which cmake)
* 79b970c pkg-config.sh: explicit --with-python=python3
* de170b4 pkg-config.sh: --with-system-include-path= for mac

## 2023-03-25

* 9549ed0 READMEs update
* 43dbb82 READMEs update prerequisites

## 2023-03-24

* 8971b59 libtool.sh: use ftpmirror.gnu.org

## 2023-02-22

* ba45132 generate-jekyll update txt
* bfcd30e READMEs update

## 2023-02-10

* fc4fb47 Merge branch 'xpack-develop' of https://github.com/xpack-dev-tools/xbb-helper-xpack into xpack-develop
* b0ce665 update Work/xpacks
* 7a03bec READMEs update

## 2023-02-07

* e819cbe READMEs update
* a9d3609 dependencies: update urls to https

## 2023-02-04

* v1.4.7 released
* bcc69c3 post-processing: fix folder vs file archive names
* 6ced03b post-processing.sh: fix syntax
* f271fec post-processing: always use cp for archive
* b3541f1 1.4.6
* 4d632ed prepare v1.4.6
* 0d1a527 post-processing.sh: avoid hard-links on macOS

## 2023-02-03

* v1.4.5 released
* c7545b3 xbb.sh: fix XBB_APPLICATION_MACOSX syntax

## 2023-02-02

* 1252400 xbb.sh: customizable macOS target

## 2023-02-01

* v1.4.4 released
* 6466383 1.4.4
* 1adfd44 .vscode/settings.json: ignoreWords
* c310b94 prepare v1.4.4
* fcf896a remove gcc-12.2.1-cross.git.patch, not needed
* 63683b6 dependencies: *-cross update for arm 12.2
* e139a52 gcc.sh: XBB_GCC_SRC_FOLDER_NAME
* 74f11f0 gcc-cross.sh: fix XBB_GCC_SRC_FOLDER_NAME
* 0535a14 gcc-cross.sh:  XBB_APPLICATION_WITHOUT_MULTILIB
* a1cc8b8 templates: fetch-depth: 3

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
