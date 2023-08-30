# The pthread library is referenced by various dependencies

Most of the dependencies have a reference to libpthread.so, which
means the thread libray must be always linked to the output.

Without it, the link fails with indirect misses, like:

```console
undefined reference to `ZSTD_compressBound'
```

## Workaround

Be sure `-lpthread`` is always passed to the linker.

For regular usage, it is already added to `XBB_LDFLAGS`, but fo special steps
it must be patched in:

```sh
    run_verbose sed -i.bak \
              -e "s|^\(POSTSTAGE1_LDFLAGS = .*\)$|\1 -lpthread|" \
              "Makefile"
```

## Console output

```console
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/build/gcc-12.3.0/./prev-gcc/xg++ -B/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/build/gcc-12.3.0/./prev-gcc/ -B/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ -nostdinc++ -B/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/build/gcc-12.3.0/prev-x86_64-pc-linux-gnu/libstdc++-v3/src/.libs -B/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/build/gcc-12.3.0/prev-x86_64-pc-linux-gnu/libstdc++-v3/libsupc++/.libs  -I/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/build/gcc-12.3.0/prev-x86_64-pc-linux-gnu/libstdc++-v3/include/x86_64-pc-linux-gnu  -I/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/build/gcc-12.3.0/prev-x86_64-pc-linux-gnu/libstdc++-v3/include  -I/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-12.3.0/libstdc++-v3/libsupc++ -L/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/build/gcc-12.3.0/prev-x86_64-pc-linux-gnu/libstdc++-v3/src/.libs -L/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/build/gcc-12.3.0/prev-x86_64-pc-linux-gnu/libstdc++-v3/libsupc++/.libs -no-pie   -g -O2 -fno-checking -gtoggle -DIN_GCC     -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -W -Wall -Wno-narrowing -Wwrite-strings -Wcast-qual -Wmissing-format-attribute -Woverloaded-virtual -pedantic -Wno-long-long -Wno-variadic-macros -Wno-overlength-strings   -DHAVE_CONFIG_H -static-libstdc++ -static-libgcc -Wl,-rpath,  -o cc1objplus \
	objcp/objcp-act.o objcp/objcp-lang.o objcp/objcp-decl.o objcp/objc-runtime-shared-support.o objcp/objc-gnu-runtime-abi-01.o objcp/objc-next-runtime-abi-01.o objcp/objc-next-runtime-abi-02.o objcp/objc-encoding.o objcp/objc-map.o cp/call.o cp/class.o cp/constexpr.o cp/constraint.o cp/coroutines.o cp/cp-gimplify.o cp/cp-objcp-common.o cp/cp-ubsan.o cp/cvt.o cp/cxx-pretty-print.o cp/decl.o cp/decl2.o cp/dump.o cp/error.o cp/except.o cp/expr.o cp/friend.o cp/init.o cp/lambda.o cp/lex.o cp/logic.o cp/mangle.o cp/mapper-client.o cp/mapper-resolver.o cp/method.o cp/module.o cp/name-lookup.o cp/optimize.o cp/parser.o cp/pt.o cp/ptree.o cp/rtti.o cp/search.o cp/semantics.o cp/tree.o cp/typeck.o cp/typeck2.o cp/vtable-class-hierarchy.o attribs.o incpath.o c-family/c-common.o c-family/c-cppbuiltin.o c-family/c-dump.o c-family/c-format.o c-family/c-gimplify.o c-family/c-indentation.o c-family/c-lex.o c-family/c-omp.o c-family/c-opts.o c-family/c-pch.o c-family/c-ppoutput.o c-family/c-pragma.o c-family/c-pretty-print.o c-family/c-semantics.o c-family/c-ada-spec.o c-family/c-ubsan.o c-family/known-headers.o c-family/c-attribs.o c-family/c-warn.o c-family/c-spellcheck.o i386-c.o glibc-c.o cc1objplus-checksum.o libbackend.a main.o libcommon-target.a libcommon.a ../libcpp/libcpp.a ../libdecnumber/libdecnumber.a \
	  ../libcody/libcody.a  libcommon.a ../libcpp/libcpp.a   ../libbacktrace/.libs/libbacktrace.a ../libiberty/libiberty.a ../libdecnumber/libdecnumber.a  -L/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/install/lib -lisl -L/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/install/lib -L/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/install/lib -L/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/install/lib -lmpc -lmpfr -lgmp -rdynamic -ldl  -lz -L/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/install/lib

/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: warning: libpthread.so.0, needed by /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/install/lib/libisl.so, not found (try using -rpath or -rpath-link)
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: warning: libpthread.so.0, needed by /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/install/lib/libisl.so, not found (try using -rpath or -rpath-link)
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: warning: libpthread.so.0, needed by /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/install/lib/libisl.so, not found (try using -rpath or -rpath-link)
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: warning: libpthread.so.0, needed by /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/install/lib/libisl.so, not found (try using -rpath or -rpath-link)
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: warning: libpthread.so.0, needed by /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/install/lib/libisl.so, not found (try using -rpath or -rpath-link)
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: warning: libpthread.so.0, needed by /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/install/lib/libisl.so, not found (try using -rpath or -rpath-link)
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: warning: libpthread.so.0, needed by /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/install/lib/libz.so, not found (try using -rpath or -rpath-link)
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.o: in function `lto_end_compression(lto_compression_stream*)':
lto-compress.cc:(.text+0x153): undefined reference to `ZSTD_compressBound'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x188): undefined reference to `ZSTD_compress'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x193): undefined reference to `ZSTD_isError'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x201): undefined reference to `ZSTD_maxCLevel'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x20f): undefined reference to `ZSTD_maxCLevel'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x21f): undefined reference to `ZSTD_getErrorName'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.o: in function `lto_end_uncompression(lto_compression_stream*, lto_compression)':
lto-compress.cc:(.text+0x408): undefined reference to `ZSTD_getFrameContentSize'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x43b): undefined reference to `ZSTD_decompress'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x446): undefined reference to `ZSTD_isError'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x4cd): undefined reference to `ZSTD_getErrorName'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.o: in function `lto_end_compression(lto_compression_stream*)':
lto-compress.cc:(.text+0x153): undefined reference to `ZSTD_compressBound'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x188): undefined reference to `ZSTD_compress'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x193): undefined reference to `ZSTD_isError'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x201): undefined reference to `ZSTD_maxCLevel'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x20f): undefined reference to `ZSTD_maxCLevel'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x21f): undefined reference to `ZSTD_getErrorName'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.o: in function `lto_end_uncompression(lto_compression_stream*, lto_compression)':
lto-compress.cc:(.text+0x408): undefined reference to `ZSTD_getFrameContentSize'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x43b): undefined reference to `ZSTD_decompress'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x446): undefined reference to `ZSTD_isError'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x4cd): undefined reference to `ZSTD_getErrorName'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.o: in function `lto_end_compression(lto_compression_stream*)':
lto-compress.cc:(.text+0x153): undefined reference to `ZSTD_compressBound'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x188): undefined reference to `ZSTD_compress'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x193): undefined reference to `ZSTD_isError'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x201): undefined reference to `ZSTD_maxCLevel'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x20f): undefined reference to `ZSTD_maxCLevel'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x21f): undefined reference to `ZSTD_getErrorName'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.o: in function `lto_end_uncompression(lto_compression_stream*, lto_compression)':
lto-compress.cc:(.text+0x408): undefined reference to `ZSTD_getFrameContentSize'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x43b): undefined reference to `ZSTD_decompress'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x446): undefined reference to `ZSTD_isError'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x4cd): undefined reference to `ZSTD_getErrorName'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.o: in function `lto_end_compression(lto_compression_stream*)':
lto-compress.cc:(.text+0x153): undefined reference to `ZSTD_compressBound'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x188): undefined reference to `ZSTD_compress'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x193): undefined reference to `ZSTD_isError'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x201): undefined reference to `ZSTD_maxCLevel'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x20f): undefined reference to `ZSTD_maxCLevel'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x21f): undefined reference to `ZSTD_getErrorName'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.o: in function `lto_end_uncompression(lto_compression_stream*, lto_compression)':
lto-compress.cc:(.text+0x408): undefined reference to `ZSTD_getFrameContentSize'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x43b): undefined reference to `ZSTD_decompress'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x446): undefined reference to `ZSTD_isError'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x4cd): undefined reference to `ZSTD_getErrorName'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.o: in function `lto_end_compression(lto_compression_stream*)':
lto-compress.cc:(.text+0x153): undefined reference to `ZSTD_compressBound'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x188): undefined reference to `ZSTD_compress'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x193): undefined reference to `ZSTD_isError'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x201): undefined reference to `ZSTD_maxCLevel'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x20f): undefined reference to `ZSTD_maxCLevel'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x21f): undefined reference to `ZSTD_getErrorName'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.o: in function `lto_end_uncompression(lto_compression_stream*, lto_compression)':
lto-compress.cc:(.text+0x408): undefined reference to `ZSTD_getFrameContentSize'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x43b): undefined reference to `ZSTD_decompress'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x446): undefined reference to `ZSTD_isError'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x4cd): undefined reference to `ZSTD_getErrorName'
collect2: error: ld returned 1 exit status
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-12.3.0/gcc/lto/Make-lang.in:101: recipe for target 'lto-dump' failed
make[3]: *** [lto-dump] Error 1
make[3]: *** Waiting for unfinished jobs....
collect2: error: ld returned 1 exit status
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-12.3.0/gcc/c/Make-lang.in:86: recipe for target 'cc1' failed
make[3]: *** [cc1] Error 1
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.o: in function `lto_end_compression(lto_compression_stream*)':
lto-compress.cc:(.text+0x153): undefined reference to `ZSTD_compressBound'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x188): undefined reference to `ZSTD_compress'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x193): undefined reference to `ZSTD_isError'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x201): undefined reference to `ZSTD_maxCLevel'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x20f): undefined reference to `ZSTD_maxCLevel'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x21f): undefined reference to `ZSTD_getErrorName'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.o: in function `lto_end_uncompression(lto_compression_stream*, lto_compression)':
lto-compress.cc:(.text+0x408): undefined reference to `ZSTD_getFrameContentSize'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x43b): undefined reference to `ZSTD_decompress'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x446): undefined reference to `ZSTD_isError'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x4cd): undefined reference to `ZSTD_getErrorName'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.o: in function `lto_end_compression(lto_compression_stream*)':
lto-compress.cc:(.text+0x153): undefined reference to `ZSTD_compressBound'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x188): undefined reference to `ZSTD_compress'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x193): undefined reference to `ZSTD_isError'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x201): undefined reference to `ZSTD_maxCLevel'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x20f): undefined reference to `ZSTD_maxCLevel'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x21f): undefined reference to `ZSTD_getErrorName'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.o: in function `lto_end_uncompression(lto_compression_stream*, lto_compression)':
lto-compress.cc:(.text+0x408): undefined reference to `ZSTD_getFrameContentSize'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x43b): undefined reference to `ZSTD_decompress'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x446): undefined reference to `ZSTD_isError'
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/x86_64-pc-linux-gnu/bin/ld: lto-compress.cc:(.text+0x4cd): undefined reference to `ZSTD_getErrorName'
collect2: error: ld returned 1 exit status
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-12.3.0/gcc/objc/Make-lang.in:77: recipe for target 'cc1obj' failed
make[3]: *** [cc1obj] Error 1
collect2: error: ld returned 1 exit status
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-12.3.0/gcc/cp/Make-lang.in:144: recipe for target 'cc1plus' failed
make[3]: *** [cc1plus] Error 1
collect2: error: ld returned 1 exit status
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-12.3.0/gcc/lto/Make-lang.in:95: recipe for target 'lto1' failed
make[3]: *** [lto1] Error 1
collect2: error: ld returned 1 exit status
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-12.3.0/gcc/fortran/Make-lang.in:97: recipe for target 'f951' failed
make[3]: *** [f951] Error 1
collect2: error: ld returned 1 exit status
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-12.3.0/gcc/objcp/Make-lang.in:80: recipe for target 'cc1objplus' failed
make[3]: *** [cc1objplus] Error 1
make[3]: Leaving directory '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/build/gcc-12.3.0/gcc'
Makefile:5004: recipe for target 'all-stage2-gcc' failed
make[2]: *** [all-stage2-gcc] Error 2
make[2]: Leaving directory '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/build/gcc-12.3.0'
Makefile:26076: recipe for target 'stage2-bubble' failed
make[1]: *** [stage2-bubble] Error 2
make[1]: Leaving directory '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/build/gcc-12.3.0'
Makefile:1071: recipe for target 'all' failed
make: *** [all] Error 2
```
