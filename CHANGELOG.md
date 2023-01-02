# Change & release log

Entries in this file are in reverse chronological order.

## 2023-01-03

* v1.1.1 released
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
* 5d2e82a build-all.sh: implement excludion properly
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
* a06627c buils-all.sh: sort list of files

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
* f5ab8b5 Merge branch 'xpack-develop' of https://github.com/xpack-dev-tools/xbb-helper-xpack into xpack-develop
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

## 2022-12-27

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
