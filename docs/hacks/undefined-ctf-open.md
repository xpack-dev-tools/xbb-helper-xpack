# macOS Apple Silicon fails with Undefined _ctf_open

The issue is caused by a misconfiguration that builds libctf without bfd
support:

```
libtool: link: /Users/ilg/Work/xpack-dev-tools/mingw-w64-gcc-xpack.git/build/darwin-arm64/xpacks/.bin/clang -dynamiclib  -o .libs/libctf-nobfd.0.dylib  .libs/libctf_nobfd_la-ctf-archive.o .libs/libctf_nobfd_la-ctf-dump.o .libs/libctf_nobfd_la-ctf-create.o .libs/libctf_nobfd_la-ctf-decl.o .libs/libctf_nobfd_la-ctf-error.o .libs/libctf_nobfd_la-ctf-hash.o .libs/libctf_nobfd_la-ctf-labels.o .libs/libctf_nobfd_la-ctf-dedup.o .libs/libctf_nobfd_la-ctf-link.o .libs/libctf_nobfd_la-ctf-lookup.o .libs/libctf_nobfd_la-ctf-open.o .libs/libctf_nobfd_la-ctf-serialize.o .libs/libctf_nobfd_la-ctf-sha1.o .libs/libctf_nobfd_la-ctf-string.o .libs/libctf_nobfd_la-ctf-subr.o .libs/libctf_nobfd_la-ctf-types.o .libs/libctf_nobfd_la-ctf-util.o   -L/Users/ilg/Work/xpack-dev-tools/mingw-w64-gcc-xpack.git/build/darwin-arm64/aarch64-apple-darwin20.6.0/x86_64-w64-mingw32/install/lib -L/Users/ilg/Library/xPacks/@xpack-dev-tools/flex/2.6.4-1.1/.content/lib -L/Users/ilg/Work/xpack-dev-tools/mingw-w64-gcc-xpack.git/build/darwin-arm64/aarch64-apple-darwin20.6.0/x86_64-w64-mingw32/build/i686-w64-mingw32-binutils-2.41/libctf/../libiberty/pic -liberty -lz  -mmacosx-version-min=11.0 -Wl,-macosx_version_min -Wl,11.0 -Wl,-headerpad_max_install_names -Wl,-dead_strip -Wl,-rpath -Wl,/Users/ilg/Work/xpack-dev-tools/mingw-w64-gcc-xpack.git/build/darwin-arm64/aarch64-apple-darwin20.6.0/x86_64-w64-mingw32/install/lib -Wl,-rpath -Wl,/Users/ilg/Work/xpack-dev-tools/mingw-w64-gcc-xpack.git/build/darwin-arm64/aarch64-apple-darwin20.6.0/x86_64-w64-mingw32/install/lib -Wl,-rpath -Wl,/Users/ilg/Work/xpack-dev-tools/mingw-w64-gcc-xpack.git/build/darwin-arm64/aarch64-apple-darwin20.6.0/x86_64-w64-mingw32/install/lib -Wl,-rpath -Wl,/Users/ilg/Library/xPacks/@xpack-dev-tools/clang/16.0.6-1.1/.content/lib/clang/16   -install_name  /Users/ilg/Work/xpack-dev-tools/mingw-w64-gcc-xpack.git/build/darwin-arm64/aarch64-apple-darwin20.6.0/x86_64-w64-mingw32/install/i686-w64-mingw32/lib/libctf-nobfd.0.dylib -compatibility_version 1 -current_version 1.0  -Wl,-exported_symbols_list,.libs/libctf-nobfd-symbols.expsym
ld: warning: passed two min versions (11.0, 11.0) for platform macOS. Using 11.0.
Undefined symbols for architecture arm64:
  "_ctf_open", referenced from:
      _ctf_link_add_ctf in libctf_nobfd_la-ctf-link.o
      _ctf_link_deduplicating_count_inputs in libctf_nobfd_la-ctf-link.o
ld: symbol(s) not found for architecture arm64
clang-16: error: linker command failed with exit code 1 (use -v to see invocation)
make[3]: *** [libctf-nobfd.la] Error 1
make[2]: *** [all] Error 2
make[1]: *** [all-libctf] Error 2
make: *** [all] Error 2
```

Probably due to a bug, the nobfd variant of the library still refers the
`_ctf_open` function.

The workaround is to do not pass `--enable-shared` for macOS.

