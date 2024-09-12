# Change & release log

Entries in this file are in reverse chronological order.

## 2024-09-12

* v3.0.16 released
* 6b5deab templates/docusaurus update
* 30dcb1b templates/docusaurus update
* f0f9349 templates/docusaurus add support for platforms
* ea90b99 git-commit.sh: update scripts
* b83dba7 website-*.sh: add platforms
* 1360cbd test-common.sh: install file on suse
* ed2b24b website-convert-release-post.sh update
* ecc3979 templates/docusaurus update

## 2024-09-11

2024-09-11 * 058976f website-convert-release-post.sh update
2024-09-11 * b7f5a34 templates/docusaurus update
2024-09-11 * f74b029 3.0.15
2024-09-11 * 7836486 prepare v3.0.15
* 8cbdb0d templates/docusaurus updates
* 3e88b1b qemu.sh: -DHWCAP_USCAT for arm64
* 25119d5 update copyright notices

## 2024-09-10

* 84a0100 qemu.sh: update for upstream source location
* f681584 add qemu-8.2.6.git.patch
* 1bb87db maintainer-scripts updates
* 028306f 3.0.14
* f85b9fb prepare v3.0.14

## 2024-09-09

* eff9278 openssl.sh: add new github urls
* 960ee50 test-common.sh: install which on suse

## 2024-09-06

* af3f986 3.0.13
* fa2d9be prepare v3.0.13
* c2039c4 templates/docusaurus updates
* f1e649f website-generate-commons.sh: move top README-long.md
* f29831d xbb.sh: use symlink when inside WORK_FOLDER_PATH
* c437623 gdb-cross.sh: enable tui on windows too
* 747f992 ncurses.sh: update win32 config

## 2024-09-05

* 1e3e968 templates/docusaurus: move badges around

* b9b6af5 test-xpm-liquid.yml update
* a86b684 README update
* ee0475f templates/docusaurus update
* fc4f4f8 test-parse-options: version "test"

## 2024-09-01

* 0545fd4 3.0.12
* 841fb62 prepare v3.0.12
* 561933b binutils-cross.sh: build ld.gold only for arm.

## 2024-08-31

* 91c5906 make-test-skips: remove 'coverage-'
* 26a371f test-xpm-liquid: remove permalink & comments
* 3160a53 templates/publish-release fix substitution

## 2024-08-30

* 94b99d5 3.0.11
* ec56117 prepare v3.0.11
* 2ae1264 tests/c-cpp/test-compiler.sh: --clang-coverage

## 2024-08-29

* c0810fc test-compiler.sh: add --coverage
* c081fcc post-processing.sh: more generic api-ms-win-*.dll

## 2024-08-17

* ce5b085 git-commit.sh update
* f3e430e xpm-run-generate-workflows.sh update
* f91ad04 templates/workflows cleanups prefix & branch
* 93611df generate-workflows.sh cleanups prefix & branch
* 6681863 website-convert-release-post.sh update
* ff46b50 templates/docusaurus updates
* f957232 templates/workflows updates
* c3cb2ee website-*.sh updates
* c50af27 git-commit.sh: updates
* 2212332 generate-workflows.sh add quotes to filenames
* af72be8 github-actions: update macro names
* ab8049c templates/workflows: cleanup spaces

## 2024-08-16

* f91f865 templates/docusaurus update
* 4417ed0 templates/docusaurus update
* 2eb33f2 templates/docusaurus update
* 8a573f5 templates/docusaurus update

## 2024-08-15

* 9cacbcd generate-website-blog-post.sh: add customFields
* 60d0cc0 generate-website-blog-post.sh: update output to .mdx
* ff3fdbe 3.0.10
* 26720ee prepare v3.0.10
* 8fba44c build-scripts/test-common.sh: fix syntax
* f1de1be templates/docusaurus update
* 36b5b25 3.0.9
* c0ab67d prepare v3.0.9* cca81c5 build-scripts/test-common.sh: tar x --no-same-owner

## 2024-08-14

* 6e45a2d git-commit.sh update
* 72b1678 3.0.8
* a0e9a5f prepare v3.0.8
* ea1f75a templates/docusaurus update
* 608b76a gcc-cross.sh: cleanup ${VERBOSE[@]}
* 3379fec dependencies: *-cross.sh: add config from abe manifests
* e6d8bd3 binutils-cross.sh: test ld.gold
* 19dde59 binutils-cross.sh: add sysroot
* c742091 gcc-cross.sh: disable fortran
* 401ec00 templates/docusaurus update
* 637a8c2 templates/docusaurus update
* 4cf74b9 templates/docusaurus update
* 813a5b7 templates/docusaurus update
* c88cbe8 templates/docusaurus update
* 3c87181 templates/docusaurus update
* 1dad63b newlib-cross.sh: simplify
* e6ef624 gdbcross.sh: simplify
* f150783 templates/docusaurus update
* c36cfed gcc-cross.sh: comment out --disable-libssp & other

## 2024-08-13

* 53adbc3 website update
* 01b1f1f templates/docusaurus updates
* c033a34 binutils-cross.sh: unset flags for make check
* 39bc29c binutils-cross.ld: --enable-gold
* 79e30f2 templates/docusaurus updates
* b0cf1bd gcc-cross.sh: update --with headers=yes for aarch64
* 67c710e templates/docusaurus updates
* b02b55c templates/docusaurus: `} </CodeBlock>
* ffa7842 templates/docusaurus: remove { } spaces
* 89b583b templates/docusaurus: add more _arm-toolchain-*.mdx
* 1fc460e templates/docusaurus: svg stroke-width="1.6"
* bd93ada templates/workflows: add build-assets/package.json

## 2024-08-12

* bafa87e templates/docusaurus cleanups
* c05afcf templates/docusaurus: add _arm-toolchain-versioning-liquid.mdx
* e3bf62b templates/docusaurus: process separate customFields
* bbd58f9 templates/docusaurus: add _first-production-run.mdx
* 6fcb51a templates/docusaurus: support uses documentation from getting started

## 2024-08-10

* d26ba53 template/docusaurus updates
* b8ba304 add xpm-run-website-*
* 083cb50 templates/docusaurus rework *-install-quick-test.mdx
* 3a28a18 website-generate-common.sh: cleanups

## 2024-08-09

* 5e27e32 templates/docusaurus updates
* e5836ec templates/workflows publish update
* a7fc292 website-convert-release.sh update
* 15a8fa6 git-commit.sh update
* 21fa456 post-processing.sh: chmod -R u+rw
* 09ba953 build-scripts: chmod ug+rw
* 801c7e8 move-to-build-assets.sh updates
* ca72e50 templates/docusaurus fix typo
* 3ac51e2 test-prime: update prefix
* eaf085e 3.0.7
* ad60da2 prepare v3.0.7
* 3e3f116 maintainer-scripts: rename *_path
* e181d7c travis: rename root_folder_path
* 3b3fa74 github-actions: rename root_folder_path
* 2f2fd80 3.0.6
* c2affa7 prepare v3.0.6
* 6d970cd templates/docusaurus updates
* f86631d website-generate-commons.sh: showTestsResults
* e243d24 generate-workflows: use platform

## 2024-08-08

* 8e8ebe6 templates/docusaurus update sidebar-liquid.ts
* bb00b04 README updates
* 5a403c1 package.json: update git+https
* b17c891 templates/workflows: test-xpm updates
* 92f5a9d templates/workflows: test-prime updates
* e2d3072 templates/docusaurus updates for showTestResults
* 5d8e685 website-generate-commons.sh: add showTestResults
* fc61692 templates/docusaurus updates
* 79f8bb0 templates/workflows: revert to ls -lLA
* 50c7568 xbb.sh: chmod -R a+rwx at the end
* eecb436 workflows: ls -lLA build-assets
* 7899357 website-convert-release-post.sh update
* af8a697 xbb.sh: add ls -l build at the end
* de19510 3.0.5
* 2a055f9 prepare v3.0.5
* f5279a5 try new 14.2.0-darwin.git.patch

## 2024-08-07

* da35a11 templates/docusaurus: updates
* d05f20d x64 cosmetics
* d173b17 3.0.4
* 3fcd4e9 prepare v3.0.4
* e6e86ab templates/docusaururs: updates
* 0d57b96 templates/docusaurus remove -info
* b8617b7 templates/docusaurus: Xxx Information
* a20f8c9 templates/docusaurus: How to xxx
* 77356d3 templates/docusaurus: user global store
* f905cd2 template/docusaurus fix syntax
* 6e82be0 template/docusaurus updates
* 791829b git-commit.sh update
* c36a91d github-actions: update
* c05cddd templates/docusaurus updates
* 16ec0f6 move-to-build-assets.sh update
* 3189619 website-convert-release-post.sh updates

## 2024-08-06

* 329cfe0 website-generate-commons.sh: add showDeprecatedGnuMcuAnalytics
2024-08-06 * 59c999f rename templates/docusaurus _github-actions-durations.mdx
2024-08-06 * 3b83822 templates/docusaurus updates
2024-08-06 * e8bdd1f 3.0.3
2024-08-06 * 843510a prepare v3.0.3
* 0397e13 templates/docusaurus updates
* 3da2cdd git-push.sh update

## 2024-08-05

* e78cd20 README update
* df74c7b add gcc-14.2.0-darwin.git.patch
* 3eb76f9 templates/docusaurus: install update
* 76daa0b templates/docusaurus: rework install
* 59caa23 move-to-build-assets.sh added
* 673272d git-commit.sh update

## 2024-08-04

* a7de65b templates/docusaurus developer-info update
* 1f99a8b build-all.sh update docker image
* fba4272 gcc-cross.sh: gcc --version
* b05e491 build-scripts: use XBB_BUILD_ROOT_PATH
* c71f200 templates/docusaurus updates
* 4662848 website-generate-commons.sh update for chmod -w
* a1c2759 templates/docusaurus updates
* d5a6375 website-generate-common: make files read-only

## 2024-08-03

* ea20e3b templates/docusaurus developer-info update
* 22234e3 templates/docusaurus maintainer-info updates
* 4eacd7d templates/docusaurus developer-info updates
* f3df69d templates/docusaurus maintainer-info add _common
* fed5dbc templates/docusaurus _gcc-release-schedule add DO NOT EDIT
* 6d9bdc2 templates/docusaurus remove work in progress
* dfcaddf templates/docusaurus config blogSidebarCount: 8
* d407937 templates/docusaurus maintainer-info updates
* b7a14b6 templates/blog: add common
* e235d7d website-generate-commons.sh add showGnuMcuAnalytics
* 3be7364 tmplates/docusaurus/maintainer-info updates
* 5448deb tmplates/docusaurus/user-info updates
* 5c6c9af website-convert-release-post.sh: change to .mdx
* 13dbfd7 github-actions: updates
* 33e8dd3 xbb.sh: fix xbb_get_current_package_version
* fe73b32 templates/docusaurus update
* f68e872 github-actions common.sh fix path
* 85a79cd githb-actions: update
* 9b438e5 github-actions update
* 723aeda github-actions updates

## 2024-08-02

* 80300a3 templates/workflows/publish: update
* a4d7c6f templates/workflows/publish: update
* 6a55403 templates/workflows/publish: update
* ea82544 3.0.2
* 6c9451f prepare v3.0.2
* c0f62fe templates/workflows/publish: update
* 079b025 templates/workflows/publish: update templates path
* 0d615fa travis/common.sh update for build-assets
* 53fdfb4 remove scripts link
* 4e7825c travis/common.sh update for build-assets
* 661485d 3.0.1
* d7289e3 prepare v3.0.1
* 27adf3d template/docusaurus: update config.ts logic for package.json
* bba4a4d templates/docusaurus updates
* 901240c 3.0.0
* 6aef52b package.json cleanups
* 04fb04d CHANGELOG update
* a554075 build-scripts: fix case syntax
* 6e31c88 is-something.sh: fix is_development
* d90c3a6 post-processing.sh: use root_folder_path
* 2633f79 templates: fix root_folder_path
* 1c43b78 rename is_development, xpack-development
* cce1a3b prepare v3.0.0
* 038226b CHANGELOG update
* 71ec8fb templates/docusaurus first-time updates
* 3c5f095 templates/docusaurus install updates

## 2024-08-01

* 0194b59 templates/docusaurus update
* 4c37e8c rename build-scripts
* 267ce33 package.json: postinstall ln -s
* c736055 add symlink to build-scripts
* 30b4fdf move to build-scripts
* a8fda82 .npmignore templates
* 49b2b86 build-common.sh: update
* f52ab37 build-common.sh: update
* 02e3213 build-common.sh: add tree -L 2
* 06ed418 add support for scripts-assets
* a8af17f templates/docusaurus update
* 9022f31 templates/docusaurus update
* 158ff50 templates/docusaurus update

## 2024-07-31

* 3a91a65 templates/docusaurus: updates
* 2180ce3 templates/docusaurus: update following Tommy's feedback

## 2024-07-30

* 03f250d templates/workflows/publish-github.yml: fetch-depth: 0

## 2024-07-29

* ee3c664 website-convert-release import CodeBlock
* 12a02c2 website-import-releases updates
* 641434b templates/docusaurus: fix manual install syntax

## 2024-07-28

* c5b8725 templates/docusaurus update
* bf50543 templates/docusaurus updates
* e7fcd5b templates: add README-TOP
* 8a0c156 templates/docusaurus: developer-info updates
* ce7b1d2 templates/docusaurus: menu Documentation
* 99933ce rename build-development*
* 0e2f2d7 website-convert-release-post update
* 725c00e git-commit.sh update

## 2024-07-27

* f47d950 templates/docusaurus: all except maintainer
* 02e742c maintainer-scripts updates
* bd7f7aa git-commit.sh update

## 2024-07-24

* f0c1f22 2.1.38
* 3f17ee0 prepare v2.1.38
* aa07b55 copyright-liquid.yml: cosmetics
* 5565bbe publish-github-pages.yml: add copyright
* 2bce042 generate-website-commons.sh: use liquidjs
* db1da92 gcc-cross.sh: unset IFS
* 64fee01 test-common.sh: fix url for releases

## 2024-07-23

* 862e216 git-commit.sh update
* e516f84 templates/docusaurus add top authors.yml
* 6130b7b templates/docusaurus: move content to common
* cde83b3 maintainer scripts updates
* 84376d6 2.1.37
* 76e264e prepare v2.1.37

## 2024-07-22

* a3f0656 move to templates/workflows
* e23ca6f patches: move all gcc here
* a0834ce Merge branch 'xpack-develop' of https://github.com/xpack-dev-tools/xbb-helper-xpack into xpack-develop
* 5780306 templates/build updates
* b5c59f6 Merge branch 'xpack-develop' of https://github.com/xpack-dev-tools/xbb-helper-xpack into xpack-develop
* 75d7c63 add gcc-12.4.0-cross.git.patch
* 0afddf0 add gcc-11.5.0-cross-darwin.git.patch
* b8135fb 2.1.36
* ecfb5bc prepare v2.1.36
* f885148 templates/docusaurus updates

## 2024-07-21

* 1cbf30c templates/docusaurus cleanups
* cb7985e add docusaurus template
* 2a68255 add gcc-11.5.0-cross.git.patch
* 468d2e0 gcc-cross.sh: add test_compiler_c_cpp()

## 2024-07-19

* 4d7552d gdb-15.1 patch update
* b3c5331 add gdb-15.1-cross.git.patch
* cd2bf3f patches/gcc-11.5.0 update
* c137ea4 gcc.sh: comments
* 3c97cf1 templates/publish update

## 2024-06-28

* 8f7bf9f 2.1.35
* a02c459 add templates/publish-github-pages.yml
* 8a6cbd8 prepare v2.1.35
* f2420ee Merge branch 'xpack-develop' of https://github.com/xpack-dev-tools/xbb-helper-xpack into xpack-develop
* b5bd96a gcc-mingw.sh: remove sed kludge
* c397b97 build-common.sh: ln -s Work work hack
* 663f6ae 2.1.34
* 73fb661 prepare v2.1.34* 5445b87 gcc-mingw.sh: re-enable binutils
* 8cc6162 gcc-mingw.sh: upper case /Work/ kludge
* b147b4e 2.1.33
* 2992f92 prepare v2.1.33

## 2024-06-27

* 963db64 test-common.sh: cosmetise update common
* 064ce8f 2.1.32
* d4fd3d5 prepare v2.1.32
* cfab534 gcc-mingw.sh: rework path for tests
* ffad969 2.1.31
* bcf6690 prepare v2.1.31
* b4d47a8 gc-mingw.sh: update ignores
* 0e8b953 2.1.30
* ef97792 prepare v2.1.30
* 753bd17 binutils.sh: fix tests

## 2024-06-26

* d8705f6 2.1.29
* 8fa5bca prepare v2.1.29
* 440420a gcc-mingw.sh: both skips and ignores
* 7028754 add skips for weak tests
* fc1d6d7 gcc-mingw.sh: set path even for --static-lib
* a5d3faa gcc-mingw.sh: improve logic to set PATH
* 1de8ae0 gcc-mingw.sh: print libstdc++.a path
* 78d5f6d gcc-mingw.sh: add ignores for gcc 10
* 3b9f8bf gcc-mingw.sh: add support for --system
* 4aa23fe binutils.sh: add support for --system
* 6153153 xbb.sh: improve logic for get_version_*
* 03e42da sleepy-threads-cv.cpp: add explicit include mutex
* d51d5d8 gcc-mingw.sh: add defs for system tests
* ea73fbe fortran/test-compiler.sh: ignore empty args
* 73da0cb test-compiler.sh: ignore empty args
* 14bdf24 gcc-mingw.sh: ignore empty args
* c742ab1 gcc-mingw.sh: update bootstrap_option, bits_option
* f4fffdb 2.1.28
* 4ea13d3 prepare v2.1.28
* f79f473 gcc.sh: update linux ignores for 12

## 2024-06-25

* 200e082 2.1.27
* da8af5a prepare v2.1.27
* 69c19b0 README update
* 050c1e6 gcc-12.4.0 simple patch added
* d854430 README update

## 2024-06-24

* d916315 2.1.26
* cfba6be prepare v2.1.26
* 028a884 README update
* 100dd3e README update
* 984bb20 README update
* 50ab85c test-compiler.sh: skip static sleepy-threads-cv
* 5b336ec 2.1.25
* b6833a3 prepare v2.1.25
* 9b0c281 remove gcc 12.4.0 patch

## 2024-06-23

* f95dff4 gcc.sh: update url

## 2024-06-22

* 17c17b4 build-tests.sh: cosmetics in messages
* 62ced57 gcc.sh: add support for XBB_TEST_SYSTEM_TOOLS
* cf5aa48 gcc.sh: separate _binaries_start & _configuration
* 8d1a691 gcc.sh: separate platform specific tests
* b1f8a9e gcc.sh: use --probe and 32/64 loop
* 9ba8626 xbb.sh: xbb_get_toolchain_library_path add fortran
* b58bb80 tests/c-cpp: add --probe
* 99af786 fortran/test-compiler.sh: inherit LDFLAGS
* 47146e0 2.1.24
* 4a7666d prepare v2.1.24
* a6e8b9d deep-clean-liquid.yml update
* 70081fa build-tests.sh: empty line after

## 2024-06-21

* b06f9ff test-xpm-liquid.yml update
* 61f73d4 2.1.23
* 8e3617d prepare v2.1.23
* 1e1454b build-tests.sh: fix skipped sed
* 3155de4 build-tests.sh: ### Skipped test cases
* 1455094 build-tests.sh: improve fail sed
* 88b4fe6 2.1.22
* f299aee prepare v2.1.22
* b9d7998 build-tests.sh: fix sed FAIL
* ae59685 test-compiler.sh: test_case_skip_all_static "atomic"
* f6da7f1 build-tests.sh: add test_case_skip_all_static
* bc97a35 build-tests.sh: fix sed for FAIL
* 4ee824a build-tests.sh: unconditional verbosity
* afea8ac test-common.sh: more verbosity

## 2024-06-20

* e1f00f3 2.1.21
* 5c7397f prepare v2.1.21
* 9e7d69f add XBB_WHILE_RUNNING_SEPARATE_TESTS to tests
* 625bbb6 git-commit.sh update

## 2024-06-17

* 4a69c90 templates/test-prime-liquid.yml: add tests report
* b764e11 templates/deep-clean-liquid.yml fix syntax
* 469f4f1 rework workflow templates

## 2024-06-16

* 56fff97 2.1.20
* c904060 Merge branch 'xpack-develop' of https://github.com/xpack-dev-tools/xbb-helper-xpack into xpack-develop
* 11548e5 prepare v2.1.20

## 2024-06-14

* 39ec27f test-compiler.sh: cosmetics
* cebbeb1 test-compiler.sh: weak_undef_c always
* 68aae01 test-compiler.sh: fix -lc++abi

## 2024-06-13

* v2.1.20 released
* 0018964 test-compiler.sh: use if ! test_case_skip
* 0dcd505 build-tests.sh: test_case_skip enhanced
* 75c474d test-compiler.sh: use --gc-sections on windows

## 2024-06-12

* 84f045c build-tests.sh: cosmetics in messages
* e49a755 test-parse-options.sh: add --skip-32
* 0b5063d install-dependencies.sh: cosmetics
* cb85448 test-common.sh: create tests folder
* d5c4579 test-compiler.sh: add -std=c++11
* 1983bf6 tests: parse --system & --external-bin-path
* c82eb34 test-compiler.sh: remove unused test_bin_path
* 5cba29d build-tests.sh: fix shift
* f720e53 test-compiler.sh: XBB_SKIP_TEST_BUFFEROVERFLOW
* 9eb7502 build-tests.sh: count skipped tests

## 2024-06-11

* 87084c2 build-tests.sh: cosmetics in messages
* 936ace5 test-compiler.sh: update file names
* d623b57 rename simple_hello_*
* 7032b99 test-compiler.sh: make PREFIX/SUFFIX optional
* 76fdf4a build-tests.sh: All tests successful with list
* de1c31f build-tests.sh: make PREFIX/SUFFIX optional

## 2024-06-10

* 8180832 build-tests.sh: cosmetics
* 48ba408 build-tests.sh: process -32 -64 in test case names
* 1a17b90 test-xpm-liquid.xml: cosmetics
* e548038 test-xpm-liquid.xml: cosmetics
* 34e3052 test-xpm-liquid.xml: cosmetics
* a13975d test-xpm-liquid.xml: add liquid header
* ae8725f rename files tests-report-*
* 066f07b test-xpm-liquid.xml: rename artefacts to report
* 2e22836 test-xpm-liquid.xml: rename artefacts to reports

## 2024-06-09

* f410758 templates cosmetics
* 4409b6b test-xpm-liquid.xml: add tests report
* 10f80bc build-tests.md: cosmetics in messages
* c422386 build-tests.md: block indentation 2
* 252d7ac build-tests.md: more verbosity

## 2024-06-08

* 75a85e2 build-tests.sh: cosmetics in messages
* 48cad83 build-tests.sh: Failed test
* f715b65 build-tests.sh: remove empty lines in lists
* e87c7d4 build-tests.sh: fix for syntax

## 2024-06-07

* c72d6c1 build-tests.sh: use cat -s
* c8a7c8e build-tests.sh: report successful tests
* 6c194ac test-compiler.sh: add -U,_func to macOS weak undef
* 707b6dc test-xpm-liquid.yml: add upload-artifact
* f71c423 templates/copyright-liquid.yml add links
* db4b6d4 templates: use actions/checkout@v4
* 4621891 build-tests.sh: tests-summary-*.md
* 884b5e3 actually XBB_ARTEFACTS_FOLDER_PATH
* 25c30ad build-tests.sh: create artefacts/tests-summary.md
* b9f38a4 xbb.sh: define XBB_ARTEFACTS_FOLDER_NAME
* 6a8111d test-compiler: skip weak_undef on macOS
* 17cac1a build-tests.sh: more verbose messages
* f59137a build-tests.sh: reorder messages
* ede230c trigger-workflow-test-xpm.yml: use package.json version
* 9c2b6f2 test-xpm.liquid.yml: xcode-select --switch
* 9ae2759 trigger-workflow-test-xpm.yml: use actual version, not current
* 2f46714 show-libs.sh: fix show_host_libs .exe
* d93f6bd templates.sh/test.sh: reorder parse options
* d69003b test-xpm-liquid.sh: add package-version
* f7c508b build-tests.sh: use tail -n +2
* f21bf75 test-xpm-liquid.yml: use macos-14
* 6562a43 test-parse-options.sh: fix missing is_develop
* 21d4ac7 test-parse-options.sh: local get version
* 0ce0099 split test-parse-options.sh

## 2024-06-06

* 042cf87 trigger-workflow-test-xpm.sh: fix sed
* 9e6665b trigger-workflow-test-xpm.sh: fix sed
* 6e17b50 test-common.sh: add XBB_NPM_PACKAGE_VERSION
* 207fefc trigger-workflow-test-xpm.sh: add package-version
* 9beb5b8 common.sh: add verbosity
* 391cb15 common.sh: add verbosity
* 20e43ca build-tests.sh: cosmetise messages
* 241367b 2.1.19
* 6054415 prepare v2.1.19
* 9f94023 test-compiler.sh: remove redundant show_libs
* cb6af1f build-tests.sh: cosmetise messages
* a88ae5f build-tests.sh: report failed tests output
* 2682b39 test-compiler.sh: save each test output in a file
* 66436e8 rename XBB_TEST_RESULTS_SUMMARY_FILE_PATH

## 2024-06-05

* f7f577d gcc.sh: cosmetic reorders
* a2901fa rename test cases aiming unicity
* 5ce50e7 2.1.18
* 39e3ca8 prepare v2.1.18
* 84a8794 machine.sh: fix detect xcodebuild
* 551e9d8 2.1.17
* c9a48db prepare v2.1.17* bfac2d2 travis/common.sh: add verbosity
* 2a48890 machine.sh: fix detect xcodebuild
* 4b08fe0 overload-new.cpp: add verbosity

## 2024-06-03

* 2a318c5 test-common.sh: show libm.* too
* d951c43 build-tests.sh: xfail
* 619f52e gcc.sh: exclude some static tests on fedora

## 2024-06-02

* 8bffaa1 2.1.16
* f36a830 prepare v2.1.16
* 2cb6c38 gdb.sh: fix path to saved
* 72d5271 2.1.15
* b79d223 prepare v2.1.15
* 66347f1 gdb.sh: use absolute path to system compiler
* f1754a0 2.1.14
* 3ec70ba prepare v2.1.14
* 2826a4d templates/*linux*: update -static
* 45303a9 test-prime: links to GA images & cosmetics
* ddb2e1d dot.npmignore: NOTES.md
* 78916e5 gdb.sh: compile test with system g++
* b6efc6d gcc.sh: enable static on redhat
* 0d930b6 test-common.sh: add more libs (static, etc)

## 2024-05-31

* 1b3972e templates: 'Show environment:'
* e029cd5 test-prime-liquid.yml: macos-14 for arm64
* a306107 test-prime-liquid.yml: sudo xcode-select --switch
* 174c3c3 2.1.13
* e362250 prepare v2.1.13
* 1ea14cb show-libs.sh: avoid .exe warning
* c71573f machine.sh: macOS capabilities
* 7c461c1 templates/*.yml: more verbose show environment

## 2024-05-30

* bd736a5 2.1.12
* d4f75ac prepare v2.1.12
* 6533ee8 machine.sh: add platform specific verbosity
* bc6d0d9 2.1.11
* 9c0973c prepare v2.1.11
* e5cff33 machine.sh: do not crash if no CLTools_Executables
* 712ceb3 2.1.10
* 989f370 prepare v2.1.10
* 4e31a83 templates: bump 5.2.1

## 2024-05-29

* dd7111b build-tests.sh: add 'reluctantly'
* 7de47bf build-tests.sh: rephrases
* ebc11b8 rename XBB_IGNORE_TEST_
* ba9ed90 build-tests.sh: suggest tests to ignore
* 5f19c25 test-compiler.sh: use setjmp-patched.c
* a6f1e14 gcc-mingw.sh: add -bootstrap
* 5664c8c build-tests.sh: add -bootstrap suffix
* fa36286 fortran/test-compiler.sh: make SUFFIX cumulative
* 5dfe3a5 build-tests.sh: cosmetise messages

## 2024-05-28

* 53ebadb 2.1.9
* 8812a2f * v2.1.9 released
* 0551fed machine.sh: fix win32 Msys
* 7c8db5e 2.1.8
* ad3119d prepare v2.1.8
* 24614db rework kernel & distro name & version
* dea6dc9 test-compiler.sh: rename test hello-c
* 6bfabb2 rename test cnrt
* 3854b5a make-test-skips.sh: iterate tests in order
* 6dc8ded fix log dates
* e49905b 2.1.7
* 981f366 prepare v2.1.7
* f1f8400 machine.sh: more elaborate logic for CLT version
* 3a5d7a3 sleepy-threads-cv.cpp: increase timeouts
* b77f404 common.sh: update create_macos_data_file
* 4a6d514 2.1.6
* 08af059 prepare v2.1.6

## 2024-05-27

* 8194463 test-compiler.sh: cosmetics order of -L .
* 07f7f8b test-compiler.sh: disable -flto for static libraries
* c2ca687 make-test-skips.sh: updates
* 745bd0c egrep -E
* f5697a5 2.1.5
* dcd5f55 prepare v2.1.5
* 9ec8242 test-compiler.sh: comment out sleepy threads
* 57c7cdb 2.1.4
* d59633f prepare v2.1.4
* 1f60eb1 sleepy threads: increase timeouts
* bf43779 2.1.3
* 3e62738 prepare v2.1.3* 520b9e3 miscellaneous.sh: fix pyrealpath
* 55708fe 2.1.2
* 57560b5 prepare v2.1.2
* f4b1e1a templates: chmod -Rf a+w * || true
* ae4cc96 xbb.sh: fix library path on native
* ffa6dfd 2.1.1
* dbacb2c prepare v2.1.1
* 37310c8 test-common.sh: add initialise & report results
* 961ec84 test-common.sh: source build-tests.sh
* 30ebba6 separate tests_report_results
* 6b630a7 templates.sh: chmod -R a+w
* 929f5e2 gcc*.sh: make c-cpp writeable

## 2024-05-26

* 253f818 2.1.0
* df4ed43 prepare v2.1.0
* b3b8ee2 build-tests.sh: show platform-arch

## 2024-05-25

* 9cf4098 add make-test-skips.sh
* 871ad51 build-tests.sh: show passed count
* c276563 build-tests.sh: extra empty lines
* efbb349 test-compiler.sh: rework trap invocation
* 592bc43 build-tests.sh: test_case_trap_handler return 0
* 88c1f7f test-compiler.sh: accumulate SUFFIX
* 16f1401 test-compiler.sh: fix --suffix

## 2024-05-24

* f9239e5 build-tests.sh: rework trap handler
* 5f92dc0 build-tests.sh: convert to upper case
* 8dc41a5 rework fortran/test-compiler.sh for continuation
* 874a888 upper case PREFIX/SUFFIX
* d2f6e25 test-compiler.sh: rework with continuation
* 7f6b59a build-tests.sh: rework to add continuation
* 2272e0d test-compiler.sh: add more conditionals
* a35448a test-compiler.sh: add conditional to adder-static|shared

## 2024-05-23

* 59d5f2b test-compiler.sh: fix verbosity for windows
* c8d679e Merge branch 'xpack-develop' of https://github.com/xpack-dev-tools/xbb-helper-xpack into xpack-develop
* ead054a gcc.sh: -Wl,-t,-t only for linux
* 870cf59 xbb.sh: -Wl,-t,-t only for linux
* 0f32f74 Merge branch 'xpack-develop' of https://github.com/xpack-dev-tools/xbb-helper-xpack into xpack-develop
* 5e5ec62 make set +/-o more explicit
* f691268 wrappers.sh: fix typo
* 68c1a5e wrappers.sh: more \r trimming
* 5d83a42 gcc-mingw.sh: cleanups for \r
* d010e68 gcc-mingw.sh: XBB_SKIP_TEST_ALL_OVERLOAD_NEW_CPP
* 27ac8af gcc.sh: update 13 skips
* d804380 gcc*.sh: show CC version
* b784cd4 wrappers.sh: filter out \r for wine output
* beb14f2 gcc-mingw.sh: more skips
* 3dc9b3c wrappers.sh: fix +/-e

## 2024-05-22

* 5c3f8c1 gcc.sh: cosmetics
* ad6adba gcc.sh: remove --disable-rpath on macOS
* 7cf2390 gdb.sh: add toolchain path on macOS
* 80887af post-processing.sh: rework macOS allowed sys
* ac84a75 gcc.sh: dismiss ENABLE_LINK_VERBOSE
* e8f590c wrappers.sh: add traps
* 6d56b71 test-compiler.sh: add -Wl,-t
* af3e20b fortran/test-compiler.sh: add SKIP_TEST_*
* c03112b more gcc patches
* 66ae2e6 gcc.sh: XBB_TOOLCHAIN_RPATH only for bootstrap
* 2839aea gcc.sh: -Wl,-t for various ldflags
* 8eb6b6a xbb.sh: conditional linker library path on macOS
* ab3ff69 xbb.sh: add -Wl,-t
* 85e0853 post-processing.sh: cosmetics in messages

## 2024-05-19

* 853df96 remove gcc-11.5 & 12.4 cross.git.patch
2024-05-19 * 34edc2b gcc-11.5*.patch update
2024-05-19 * b250700 gcc-mingw.sh: cosmetics
2024-05-19 * 320c19e Merge branch 'xpack-develop' of https://github.com/xpack-dev-tools/xbb-helper-xpack into xpack-develop
2024-05-19 * bd2b215 gcc-cross.sh: cosmetics
2024-05-19 * d670a21 gcc-12.4.*.patch: add conditional abort()
2024-05-19 * 1fb8b53 download.sh: verbosity
2024-05-19 * 041718e rework gcc-11.5* patches
2024-05-19 * b4570cd fix gcc-12.4* patches
2024-05-19 * a9d7348 rework gcc/system.h patch for 12.4
2024-05-19 * 51e6352 build-common.sh: more verbosity
2024-05-19 * 2742b5e post-processing.sh: filter OBJDUMP *.dll better

## 2024-05-18

* 6783423 add more gcc-*-cross.git.patch
* 4de54b8 download.sh: download_and_extract with empty patch
* b26b351 download.sh: more verbose download_and_extract
* 2062b96 rework git_clone with non-positional args
* 91da472 add gcc-11.5.0.git.patch
* 5a433d6 gcc.sh: skip tests for gcc 11
* 602b4da gcc-mingw.sh: check only major in tests skips
* de017a6 gcc*.sh: use thread win32 only if -ge 13

## 2024-05-17

* 98dfda5 add gcc-12.4.0.git.patch
* e6cc135 gcc.sh: use git_clone2
* cfcf22e download.sh: add git_clone2
* 3700216 gcc.sh: disable tests for 13.* on linux
* cb622f6 post-processing.sh: cleanup
* 1d858cf gcc-mingw.sh: more verbosity
* eb8ea49 post-processing.sh: cosmetics
* 3fd9d9e commented out XBB_LDFLAGS_STATIC_LIBS
* 25578f4 post-procesing.sh: create LOGS/post-processed
* d7cfe34 post-processing.sh: more verbosity
* 1fd8738 post-processing.sh: use LOGS/post-processed
* 7852afb xbb.sh: define XBB_LDFLAGS_STATIC_LIBS
* 1b5ea83 build-common.sh: use XBB_ENVIRONMENT_SKIP_CHECKS

## 2024-05-16

* 45ff9bc build-common.sh: adjust PATH on windows for bootstrap
* f972259 post-processing.sh: cosmetics
* e3c6bcc post-processing.sh: use ${CC} on windows
* 3c3444e xbb.sh: cosmetics
* 78263df xbb.sh: define XBB_MAKE_VERBOSITY
* 11a1c1a mingw.sh: configurable --with-default-win32-winnt
* 96f29a6 gdb.sh: define _WIN32_WINNT on windows
* a22fadb gdb.sh: APP_STATIC_GCC on windows
* ca56c02 post-processing.sh: show distribution file length
* 3ee2862 gcc.sh: --enable-threads=win32
* f8484b8 gcc-cross.sh: no need for --disable-lib-suffixes
* e13978e ncurses.sh: reverse rule for --enable-lib-suffixes
* eb329f6 gcc-cross.sh: ncurses --disable-lib-suffixes
* 7c8e991 build-common.sh: use XBB_ENVIRONMENT_WITH_TESTS

## 2024-05-15

* 4218282 gcc-mingw.sh: try --enable-threads=win32
* 912101c gcc-mingw.sh: try --enable-threads without value
* 2d22060 ncurses.sh: remove --with-versioned-syms
* 99189c6 libedit.sh: no reference to tinfo needed

## 2024-05-14

* 34c728e ncurses.sh: add option --with-termlib
* c6bd9b8 build-all.sh: add echo Done
* d960896 ncurses.sh: add --hack-links (take two)
* 8888897 ncurses.sh: --disable-lib-suffixes
* afc684f python3.sh: comment out include/ncurses
* 3524ba3 libedit.sh: comment out include/ncurses

## 2024-05-13

* db15adc ncurses.sh: comment out hack
* 092fe89 ncurses.sh: --enable-overwrite
* 93b6284 ncurses.sh: --disable-lib-suffixes
* 72e6773 ncurses.sh: options --disable-widec --hack-links
* 10e1ae9 test-compiler.sh: add -lc++-abi
* 5c7587c ncurses.sh: fix links
* 8387fab ncurses.sh: --with-termlib only for linux&macOS

## 2024-05-09

* e711235 libedit.sh: LIBS="-ltinfo" on macOS
* 81bae8b libedit.sh: comment out useless options
* e92ad9f libedit.sh: add libedit_test_libs
* 9eaca50 ncurses: fix libcurses.* sym links
* af014c8 use is_develop and with_strip
* 60b629d ignore test results only when is_debug

## 2024-05-08

* 92f8051 gcc-cross.sh: USE_GCC_FOR_GCC_ON_MACOS hack
* e6d7563 gmp.sh: skip tests on macOS arm64
* b83cc58 xbb.sh: XBB_APPLICATION_USE_GCC_ON_MACOS
* 061c87c gdb-cross.sh: patch only non-windows
* 8b9f787 gdb-cross.sh: no readline on windows
* b70494d gdb-cross.sh: --with-curses
* 595c0a6 Merge branch 'xpack-develop' of https://github.com/xpack-dev-tools/xbb-helper-xpack into xpack-develop
* 1a46099 python3.sh: cleanup
* 8802dce post-processing.sh: add propsys.dll

## 2024-05-07

* 3a17148 readline.sh: --with-shared-termcap-library
* b3506a9 gcc-mingw.sh: add 15.* to tests
* 397cb47 ncurses.sh: add --with-termlib for libtinfo
* 3a5edc8 bzip2.sh: add -id on macOS
* 3183f97 gcc.sh: skip static sleepy cv
* cd700d4 sleepy-threads-cv: add timeouts
* 553999d sleepy-threads.cpp: increase time
* b1280bd gcc-mingw.sh: mention sleepy-threads-cv.cpp
* b460a2d test-compiler.sh: fix typo
* ef2996b test-compiler.sh: add sleepy-threads-cv
* 1d82f3d README update
* 6fcee4e gcc*.sh: test regex
* 51d7e2e add gdb-14.2-cross.git.patch
* 5a628cc gcc-cross.sh: add _getentropy() to C++ test
* 3b4b972 gdb-cross.sh: re-enable all options
* 45d0ed3 gdb-cross.sh: use short --with-xxx
* dbc5a45 gdb-cross.sh: pass XBB_SQLITE_YEAR

## 2024-05-06

* abaa29e shlite.sh: comments
* f111ad4 gc-cross.sh: use git_clone for pre-releases
* af73143 gcc-cross.sh: add gcc_cross_build_common()
* 28ba294 gcc-cross.sh: cleanups -lpthread
* e04e3d9 gcc-cross.sh: run_verbose file * in tests
* d70c2a7 gcc-cross.sh: fix +=" ...

## 2024-05-05

* 4ab11a8 add sleepy-threads-cv.cpp
* ed2bf8f Revert "sleepy-threads.cpp: use condition variable"
* 17dda0f README update
* 35562ac sleepy-threads.cpp: use condition variable
* e6a8967 sleepy-threads.cpp: increase time

## 2024-05-04

* 896475b README update
* 60d1068 build-all.sh: reorder aarch64-none-elf-gcc
* 46c16cf openssl.sh: fix darwin64-*
* a30b3b4 openssl.sh: update for 3.x
* 653f71c build-all.sh: fix syntax
* 709989b texinfo.sh: disable tests
* eb3e7b2 build-all.sh: reorder ninja first
* 7123e5c post-processing.sh: use is_darwin_dylib
* 106dacc post-processing.sh: update dylib id to rpath relative
* f540380 build-all.sh: consider xpack-dev-tools-build
* 2ba0db9 show-libs.sh: objdump tail +2
* b7eec3f post-processing.sh: use OBJDUMP instead of otool -L
* c334318 xbb.sh: echo LDFLAGS in xbb_adjust_ldflags_rpath

## 2024-05-03

* 1bee608 xbb.sh: add toolchain rpath to LDFLAGS on macOS
* 3c2143d gcc.sh: add toolchain path to bootstrap
* 53af3f4 openssl.sh: disable tests, too long
* 44eefc7 xbb.sh: always add -L with -rpath
* 2e9b921 flex.sh: ignore check on macOS
* b2327d0 README update
* 23c775c mpfr.sh: check only if 4.x or later
* 42efb5a texinfo.sh: ignore check result on macOS
* 20f55d4 m4.sh: ignore diff exit code
* e3fafbd pcre2.sh: ignore check result
* c64a6e4 git-commit.sh update
* ddf6d2e gettext.sh: ignore check result

## 2024-05-02

* 06594c0 gcc.sh: update test skips for gcc 15
* fab1fa9 c-cpp/test-compiler.sh: inherit *FLAGS

## 2024-04-30

* 84cdb50 fortran/test-fortran.sh: use expect_target_succeed
* 33fcb82 test-compiler.sh: add exe to expect_target_succeed calls
* 3e168c7 test-compiler.sh: use expect_target_succeed()
* d7bfb0c test-compiler.sh: add -Wl,--verbose on non macOS
* 074dc1d wrappers.sh: add expect_target_succeed()
* 5d48245 wrappers.sh: rework expect_target_output
* 43ba123 gcc.sh: cosmetics
* 68614a3 test-compiler.sh: use VERBOSE

## 2024-04-29

* a9d0dc3 gcc.sh: cosmetics
* 0a6b7df test-compiler.sh: add more conditionals
* 66eea1a xbb.sh: fix xbb_get_toolchain_library_path fix "$@"
* 3b83deb is-something.sh: cosmetics

## 2024-04-27

* b8d3e0d c-cpp/test-compiler.sh: rework static-lib flags for macOS
* 37e5605 c-cpp/test-compiler.sh: reorder lld
* 64caf02 gcc.sh: cosmetics
* 7419636 gcc-mingw.sh: update for weak
* 8b6f977 gcc.sh: cosmetics

## 2024-04-26

* b8b4c1d fix unwind-strong test
* 64ca6a7 gcc.sh: add tests skips
* f5ae0b7 c-cpp/test-compiler.sh: add conditionals
* 1845858 remove alt weak-override
* c3f88a7 gcc.sh: fix syntax
* e4742ae move test functions to test-compiler.sh
* d218a69 README update
* 95de523 gcc.sh: cosmetics in tests
* 5055e68 gcc.sh: skip unwind-strong onlinux
* 0417528 compiler-tests.sh: add -g if is_develop
* 4483407 overload-new.cpp: add commented out message
* 2179fe5 gcc.sh: skip weak_undef & unwind_strong tests
* 351ea31 compiler-tests.sh: enable commented out weak tests
* 8437cd9 add README-DEVELOPER.md
* 82cbc8e gmp.sh: -Wl,-ld_classic

## 2024-04-25

* e8036b3 gmp.sh: fix LDFLAGS
* 2ad033e conditional -DCMAKE_OSX_DEPLOYMENT_TARGET
* d68a55a xbb.sh: XBB_ENVIRONMENT_MACOSX_DEPLOYMENT_TARGET
* 46d24df xbb.sh: fix rpath for clang
* f8794c4 gmp.sh: workaround for ld: branch8 out of range
* 393b3dc xbb.sh: conditional set MACOSX_DEPLOYMENT_TARGET
* ff764d1 test-common.sh: show CLT version on macOS
* d0b175b machine.sh: add XBB_BUILD_MACOS_VERSION
* 50beb31 gcc.sh: cleanup bootstrap ldflags

## 2024-04-24

* e7eef4d gcc.sh: experiment with -static
* 5fa6f1e add weak tests from Martin Storsjo

## 2024-04-23

* 25a03ae isl.sh: add isl_patch_file_name
* 345a277 add isl-0.26.git.patch
* 2120e6b sleepy-threads.sh: increase time
* 10fffd7 sleepy-threads.sh: increase time
* d5a1178 ncurses.sh: remove -ldl
* 3350323 gmp.sh: cosmetics

## 2024-04-22

* 5e0f3b6 cleanups
* 084ac86 rename test_compiler_*
* 42cfc83 binutils.sh: fix make -O
* e964f71 gcc-mingw.sh: cleanups
* a9a91ba gcc-mingw.sh: add XX_FOR_BUILD
* b62fb4e gcc.sh: cleanups
* bcd3eae gcc cleanups for static lib tests
* ed58aec mingw.sh: rm lib/libpthread.dll.a
* 131e5c1 mingw.sh: rm -rf libpthread.dll.a
* 4066e80 gcc.sh: cosmetics

## 2024-04-21

* 4a8c146 gcc.sh: --enable-host-shared for win32
* 0d4df3c gcc.sh: explicit -fPIC for win32
* 3708558 gdb test hacks
* 1fa502a gcc.sh: disable some lto tests on win32

## 2024-04-19

* ee6e1d2 download.sh: show git clone last date and commit
* 1494dd7 gcc.sh: rework report failures
* 64c906a cosmetics
* f9c0499 gcc.sh: add make check
* f1ccf13 extract autogen, gc, guile from legacy
* 8381e24 Merge branch 'xpack-develop' of https://github.com/xpack-dev-tools/xbb-helper-xpack into xpack-develop
* 8eaf3c3 pkg-config.sh: disable tests
* b5c44fa autotools.sh: bump autoconf 2.72

## 2024-04-18

* 3fe0f17 gdb.sh: ignore finale test on arm
* c592d19 ignore otool exit code
* b9cd17f sleepy-threads.cpp: increase sleep time
* 2b93913 sleepy-threads.cpp: increase time
* b6301f6 gcc.sh: cosmetics
* e575670 gcc.sh: define *_FOR_BUILD
* 431665a xbb.sh: define more XBB_NATIVE_*
* 651c258 gcc.sh: fix libiconv.a hack
* 927f251 gcc.sh: rework libiconv hack

## 2024-04-17

* b4b1396 binutils.sh: ignore test results on Arm
* d8ba2f3 gcc-mingw.sh: add compiler_tests_single_fortran
* 507411f binutils.sh: set LD_LIBRARY_PATH for checks
* e0945ec rename compiler_tests_single
* f553d6d gcc.sh use compiler_tests_single_fortran
* 59d54b3 gcc.sh: show libs for 32-bit
* bd55518 gcc.sh: include libiconv.a into libstdc++.a for linux
* b1117ac compiler-tests.sh: separate compiler_tests_single_fortran
* 3697f72 compiler-tests.sh: add -lpthread to sleepy-tests on linux
* 791b916 update xbb_get_toolchain_library_path
* 041219c libiconv.sh: add --32 --64
* e7b71b1 sleepy-threads.sh: double sleep time
* 72ce945 timer.sh: add line terminator
* 602b5c1 gcc.sh: conditional XBB_MARKER only on IS_DEVELOP
* b35b73e add sleepy-threads.cpp test
* f93ad82 gcc.sh: remove wrong --libdir
* c0c17be gcc*.sh: XBB_GCC_GIT
* 0edd0d5 xbb.sh: deprecate xbb_get_libs_path & co

## 2024-04-16

* 8b21097 compiler-tests.sh: fix --static-lib on macOS
* 3eaf687 gcc.sh: cleanups
* 4f5bfcf gcc.sh: add --static-lib to macOS tests
* 2b287dc gcc.sh: use xbb_get_toolchain_library_path
* 52aead4 gcc.sh: explicit --libdir
* 07168a9 gcc.sh: LDFLAGS_FOR_TARGET/*
* 4196e91 gcc.sh: simplify stage1/boot/target defs
* 962f1f2 xbb.sh: rework xbb_activate_dependencies_dev --with-flex
* 14e3dd5 xbb.sh: add XBB_APPLICATION_ENABLE_LINK_VERBOSE
* 2b0b613 xbb.sh: no more -lphtread for gcc
* 525ae0a xbb.sh: deprecate xbb_set_flex_package_paths
* 1be5dab gcc-mingw.sh: no more download stamp
* 8c05bc9 gcc.sh: no more download stamp
* ddda5e9 gdb.sh: which g++
* 88a0bf4 gmp.sh: enable tests
* 884af18 isl.sh: enable tests
* 312b3b5 mpfr.sh: cosmetics
* 27ca08c zstd.sh: enable first test only
* 2d395f7 build-common.sh: enable tests
* de2c149 binutils.sh: disable pic/libiberty
* f43d5db binutils.sh: add tests, but result ignored

## 2024-04-15

* 67ff1a7 binutils.sh: install pic/libiberty.a
* 54df087 gcc.sh: add -DXBB_MARKER_*
* 3a8410c xbb.sh: remove binutils TODO
* d6caa4b add application_check_binaries()
* b7d5368 rename application_copy_files()
* b04595b xbb.sh: always add to XBB_LIBRARY_PATH
* f9228a9 xbb.sh: skip -rpath for windows

## 2024-04-14

* 6e4992b zstd.sh: add empty win32 case
* 67d84f4 miscellaneous.sh: pyrealpath ignore options
* 4bf0bd2 download.sh: fix git_clone
* c561531 xbb.sh: fix toolchain rpath
* 78d6b9f xbb.sh: fix uninitialised variable
* 40c9824 xbb.sh: rework rpath
* 723a5fd gcc.sh: more linux settings
* 23c21af ssh.sh: fix clone args

## 2024-04-13

* e2a9dea download.sh: git_clone update
* 28c6486 gcc.sh: use git_clone
* 0feb177 xbb.sh: rework xbb_update_ld_library_path
* 4fdb82d gcc.sh: many comments
* 5039263 gcc.sh: LDFLAGS_FOR_TARGET macOS
* 6c350ca gcc.sh: download from git
* ac39734 gcc.sh: --enable-darwin-at-rpath=no
* 01b72c3 gcc.sh: disable --lld tests
* 9b97305 libiconv.sh: add --disable-shared
* 3a5ec43 zstd: sed patch @rpath
* f4bcefd zstd.sh: add zstd_test
* 1109c25 post-processing.sh: reluctantly accepted

## 2024-04-11

* 35b499b post-processing.sh: XBB_APPLICATION_HAS_LIBICONV2DYLIB
* db0acf5 gcc.sh: try tests without --lld
* 37ccd99 gcc.sh: add XBB_APPLICATION_TEST_PRERELEASE
* c93b475 download.sh: unzip -q

## 2024-04-09

* fd3f1fc xbb.sh: use realpath -m
* 35e82d0 gcc.sh: enable bootstrap for linux
* e03ae71 gcc.sh: comment out LDFLAGS_FOR_TARGET BOOT_LDFLAGS
* 28f4dc0 xbb.sh: no need to manually create lib64
* b500aea post-processing.sh: cosmetics
* a1acde3 post-processing.sh: optimize install name tool if same lib path
* aa69545 gcc.sh: cosmetics
* 7b64efe gcc.sh: --disable-rpath for macOS
* 8248011 gcc.sh: --enable-bootstrap for macOS

## 2024-04-08

* 30a8caa xbb.sh: pass all rpaths
* a699b93 binutils.sh: comment out mkdir */lib
* 1eefeff qemu.sh: re-install on macOS
* ae45dc6 README update

## 2024-04-07

* 469d6e8 xbb.sh: explicit rpath for darwin
* aef5f54 maintainer-scripts: add more git scripts
* fa4b889 rename maintainer-scripts
* cfc9563 xz.sh: add warning
* 0480771 timer.sh: show minutes and hours
* d1665f7 timer.sh: show minutes and hours
* c2e8b0a xbb.sh: fix typo
* 87112f5 binutils.sh: mkdir for rpath

## 2024-04-06

* 33d1549 xbb.sh: rework xbb_update_ld_library_path darwin

## 2024-04-05

* bddcbc1 maintainer/CHECKLIST.md reorder
* bac791d xbb.sh: add -L with -rpath
* ea2a15e xbb.sh: LDFLAGS -Wl,-v

## 2024-04-02

* d361423 build-common.sh: skip folders in xpack.bin definitions
* 6ba0622 2.0.9
* 5511609 prepare v2.0.9

## 2024-04-01

* ebba6d5 qemu.sh: switch to ninja
* 51ee8b2 qemu.sh: -DHWCAP_USCAT for 8.2.2
* 58ba685 qemu.sh: disable -ffunction-sections on windows
* f712cb8 glib.sh: run_verbose python3
* 909e253 glib.sh: pip install packaging
* 372854c 2.0.8
* aa3d97b prepare v2.0.8

## 2024-03-31

* 0ef07ea cp -R

## 2024-03-29

* 108fff1 qemu.sh: disable greetings patch
* ae2541a pixman.sh: add support for meson builds

## 2024-03-28

* 4ffbd15 post-processing.sh: HAS_LIBZ1DYLIB
* 57372b2 python3.sh: --with-ensurepip

## 2024-03-27

* b9d5114 python3.sh: --without-system-libmpdec
* c646640 python3.sh: darwin tweaks
* 2b36983 xbb.sh: -macos_version_min
* 4ca8ae5 machine.sh: compute XBB_BUILD_CLT_VERSION
* ebcb86c ncurses.sh: more elaborate fakes

## 2024-03-23

* 4b75866 add pyconfig-win-3.11.8.h
* 0afa3f4 python3: try 3.12.2; not yet functional
* df6be94 sqlite.sh: add sqlite_year
* 5f4a271 xbb.sh: mkdir install/lib
* b27f27f xbb.sh: mkdir install/lib64
* f378d5b maintainer/README update
* d2eb956 openssl.sh: add 3.2.1
* 5accd96 2.0.7
* c33105f prepare v2.0.7
* b8524ea maintainer/README update
* 263ccc3 maintainer/build-all.sh reorder

## 2024-03-08

* 463d354 README update
* 34d8409 maintainer --repos-status

## 2024-03-07

* 387b368 gcc.sh on Intel macOS: disable some exception tests
* cc41dff compiler-tests.sh: conditional exception-reduced

## 2024-03-06

* 795ce2f templates: ncipollo/release-action@v1.13.0

## 2024-02-23

* 6b26ef9 2.0.6
* a417d6a prepare v2.0.6
* 41f4591 binutils.sh: no sysroot for linux

## 2024-02-22

* 4115f35 Merge pull request #2 from juliaazziz/xpack
* bcfb575 Pass libyaml version from caller

## 2024-01-30

* 2bd6c23 dependencies: add libyaml

## 2023-12-05

* 56fe109 2.0.5
* b9cbe1e prepare v2.0.5
* 114de4f gdb.sh: skip gdb test on x64 macOS
* 32f78eb 2.0.4
* 398fddd prepare v2.0.4
* 5ad29f7 hacks: fix typo
* 184d7fd gcc.sh cleanup deprecated
* ec315a9 gcc.sh: cosmetics
* 50f692e gcc.sh: skip tests for 11.4
* a17f7e9 gcc-mingw.sh: skip tests for 11.4

## 2023-12-04

* 3acfd8b gcc.sh: use externally defined patch

## 2023-12-03

* d0b2126 2.0.3
* dfffb31 prepare v2.0.3
* 0b5a9d3 templates: bump xbb 5.1.1

## 2023-11-08

* 70a8434 2.0.2
* 585a188 prepare v2.0.2
* 009be84 gcc-cross.sh: use nosys.specs in aarch64 tests

## 2023-11-07

* 919a4b4 gcc-cross.sh: use nosys.specs in tests

## 2023-10-10

* 43203d4 libedit.sh: update release dates

## 2023-09-25

* c314088 download.sh: better id, random
* bdbb62e download.sh: better id, not yet unique
* efd549f download.sh: use $$ to make names unique

## 2023-09-20

* 14eb265 2.0.1
* 0f4ddd2 prepare v2.0.1
* abcbfd0 gdb-cross.sh: rework test for elf
* 7230ecd gdb.sh: test if a program can be executed
* d295305 gdb-cross.sh: riscv#23 test gdb elf
* 09c7bb1 gdb-cross.sh: --batch in gdb tests
* 6712ac9 gcc-cross.sh: add -g to hello.c* tests

## 2023-09-15

* 70b4c1c ncurses.sh: move --disable-root* to non-windows

## 2023-09-14

* 663fc9f ncurses.sh: cosmetics
* 90c2196 ncurses.sh: add w links if _DISABLE_WIDEC
* 62055d1 ncurses.sh: rework links with loop
* a65cbe9 ncurses.sh: add more --disable-root*
* f4a9b47 ncurses.sh: add --enable-pc-files for non-windows
* 88ae2b8 ncurses.sh: move *DISABLE_WIDEC to the top
* de18f2b update gitlab.archlinux.org links

## 2023-09-13

* 1452f03 maintainer/build-all.sh: add --patch-debian
* df927d5 README update
* 649864c CHANGELOG update

## 2023-09-11

* 8a2fac8 README update
* 719c1ab .vscode/settings.json: ignoreWords

## 2023-09-08

* 918109e 2.0.0
* f63d7b1 prepare v2.0.0
* c1b076f .vscode/settings.json: ignoreWords
* 6071868 autotools.sh: move libiconv out
* c5144e3 maintainer/README updates
* a5d86a4 build-all.sh: no final deep-clean (statistics)
* 03a010f binutils.sh: add default for has_triplet
* 7e18743 deprecate copy_build_files
* 8115ded add gcc 12.3 & 13.2 cross patches

## 2023-09-07

* 8428e93 add gcc-13.2.0.patch for mingw
* 4a41c9e rework gcc-12.3.* patches for mingw
* 5829296 rename hacks/mingw-define-abort.md
* e01726e $(xbb_get_libs_path "${CXX}")"
* 21dc5e2 _apps-xbb.sh: use LD_LIBRARY_PATH in re2c_test
* 72b6d9a flex.sh: use LD_LIBRARY_PATH in test
* 92a391d bison.sh: use LD_LIBRARY_PATH in test
* 9f31c81 miscellaneous.sh: explain no patchelf
* da866e4 miscellaneous.sh: do not patchelf libudev.so
* 41b5afa CHECKLIST.md update
* 4b88412 README fix typo
* 504e71e .vscode/settings.json: ignoreWords

## 2023-09-06

* 0f2b98a maintainer/CHECKLIST update
* 87d67af maintainer/CHECKLIST update
* 3dc253c add maintainer/CHECKLIST.md
* 2b1a8d4 maintainer/README update
* cf748b8 build-all.sh cosmetics
* 0d7d22a build-all.sh: deep-clean --config at the end
* 2f0796c build-all.sh: add bison flex texinfo
* b41ded8 build-all.sh: rm -rf package-lock.json
* a11311b build-all.sh: update WORK path
* 928e092 READMEs update

## 2023-09-05

* e869d5d 1.11.2
* ed49daa prepare v1.11.2
* bc1602b .vscode/settings.json: ignoreWords
* 89db9f2 .vscode/settings.json: ignoreWords
* 461e183 coreutils.sh: --disable-year2038 for 32-bit arm
* 6302d3d README update

## 2023-09-04

* 1012e2d 1.11.1
* 9afd463 prepare v1.11.1
* d545865 add pkgconfig/hidapi-0.14.0-windows.pc
* 56dcf1d README update
* ae21909 README update
* 84ae7de 1.11.0
* 9650878 prepare v1.11.0
* 7bb95b6 run_verbose diff
* 29f297b autotools.sh: re-enable pkg_config
* 1cfd9b3 miscellaneous.sh: fix copy_cmake_files
* 85839d8 zstd.sh: use copy_cmake_files
* 5f58028 hidapi.sh: use copy_cmake_files
* 6399d1c miscellaneous.sh: add copy_cmake_files()
* c708c7e README update
* d353614 templates: bump xbb 5.1.0

## 2023-09-03

* 7d12b44 1.10.8
* a6d2051 prepare v1.10.8

## 2023-09-02

* 51dff5c qemu.sh: define HWCAP_USCAT only for 8.1.0
* 87dcadf qemu.sh: -DHWCAP_USCAT=(1<<25) for arm64
* 8874c6c add docs/hacks/autoreconf-m4-ifdef.md
* b3e524a gdb-cross.sh comments
* bf0315b libxml2.sh: conditional autoreconf

## 2023-08-31

* e855091 compiler-tests.sh: verbose first test
* 59673b9 1.10.7
* e7fc112 prepare v1.10.7
* c31eec8 gcc.sh: disable bootstrap on linux too
* 84785d5 1.10.6
* 0913129 prepare v1.10.6
* fae0d46 gcc.sh: rework bootstrap --with-boot-*
* 885b7c7 gcc.sh: experiment with bootstrap on macOS

## 2023-08-30

* 3107968 gdb.sh: add link to hb
* 78be099 1.10.5
* d36d07c prepare v1.10.5
* 766d9f9 1.10.4
* e4dd4cd prepare v1.10.4
* d0a5d67 gcc.sh: pass deps path to POSTSTAGE1_LDFLAGS
* fb2b2c1 1.10.3
* 093d718 prepare v1.10.3
* dc94ccd gcc.sh: fix diff || true
* d0ff8e9 1.10.2
* 9bae2bf prepare v1.10.2
* 3c3585f add docs/hacks/gcc-undefined-zstd.md
* 895097f gcc.sh: patch -lpthread into POSTSTAGE1_LDFLAGS
* f997286 1.10.1
* 95b719a prepare v1.10.1
* 363f4de miscellaneous.sh: rework darwin_get_lc_rpaths
* c6e8755 post-processing.sh: darwin_get_dylibs in check bin
* 517eb9e miscellaneous.sh: no reexport in darwin_get_dylibs

## 2023-08-29

* 4dcb153 docs/hacks updates
* 5254164 binutils: re-enable remove ansidecl.h, for gcc
* a6eee10 binutils.sh: for mingw skip --enable-shared
* 8d80b6a docs/hacks: add undefined-ctf-open.md
* 86d01d5 binutils.sh: skip --enable-shared for macos
* 9e66b42 binutils.sh: add HB mingw link & comments
* e3d4a9d xbb.sh: set_target call xbb_set_flex_package_paths

## 2023-08-28

* c20ff19 binutils.sh: re-enable tests for non windows
* da8fe5e binutils.sh: comment out test_libs --version
* 6d72e14 binutils.sh: disable hacks
* d3fb0f8 binutils.sh: insert triplet into libs paths
* 37ad22c binutils.sh: add --verbose to test_libs
* bd81c59 xbb.sh: add priority_path to *ldflags_rpath()
* a1ddf29 xbb.sh: add priority_path to *devs_dep
* 9746796 xbb.sh: remove unused name suffix from *deps_dev
* f9c2f6e gcc.12.3.0.git.patch relocated from gcc

## 2023-08-27

* ce013aa xbb.sh: add xbb_set_flex_package_paths()
* d74fb1e gcc-mingw.sh: skip tests for 13.2
* 8903cdf gcc.sh: skip tests for 13.2
* 076d4ac dependencies: update homebrew urls
* 03ebe80 _apps-xbb.sh: fix names in comments
* fe31ed7 add docs/hacks
* 5c80a94 gcc.sh: skip some tests for 12.3
* f9dc753 gcc.sh: cleanup
* eee3803 gcc-mingw.sh: skip hello weak tests
* 6a9ced0 xbb.sh: add comments
* 974d74a binutils.sh: rm lib64/libiberty.a
* d1c6bcc binutils.sh: export XBB_LIBRARY_PATH

## 2023-08-26

* 0748c0c gcc.sh: rework LDFLAGS_FOR_TARGET
* 81a5f14 binutils.sh: remove ansidecl.h

## 2023-08-25

* b194a96 gdb-cross.sh: fix indentation
* 96d800c xbb.sh: XBB_LDFLAGS+=" -lpthread" for linux gcc
* a877249 gcc.sh: LDFLAGS_FOR_TARGET shorter
* 5782609 xbb.sh: export LEX
* 48b51c2 xbb.sh: update_ld_library_path for macOS too
* e5c5d01 newlib-cross.sh: reorder _define_flags_for_target

## 2023-08-23

* 93904cc 1.10.0
* 7f88754 prepare v1.10.0
* 60e1f48 gcc-cross.sh: add XX_FOR_BUILD
* 6902316 xbb.sh: add xbb_expand_rpath()
* ee97e3d xbb.sh: XBB_NATIVE_LD|AR|NM|RANLIB

## 2023-08-22

* 1eea6a1 1.9.0
* cb72b0b prepare v1.9.0
* 9b34ea5 .vscode/settings.json
* d46c157 gcc-cross.sh: gcc_cross_build_all installed_bin
* fba9316 add xbb_set_actual_commands
* 287608c texinfo.sh: no need for --disable-debug

## 2023-08-21

* 049c598 dot.npmignore: add extras

## 2023-08-20

* ae380e9 1.8.1
* 1babf16 prepare v1.8.1
* 110e29c test-common.sh: install g++ for tests

## 2023-08-19

* 9e134c5 1.8.0
* 3aebaa5 prepare v1.8.0
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
