# gcc fails with binutils ansidecl.h

binutils has its own version of `ansidecl.h`. If this file is used
by gcc, it crashes due to a missing PTR macro.

## Workaround

The workaround is to remove the installed file from `${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/ansidecl.h`.

## Console output

```console
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-12.3.0/libiberty/objalloc.c:95:18: error: 'PTR' undeclared (first use in this function)
   95 |   ret->chunks = (PTR) malloc (CHUNK_SIZE);
```

and also while building gcc:

```console
In file included from ./tm.h:22,
                 from /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-13.2.0/gcc/backend.h:28,
                 from /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-13.2.0/gcc/lto-compress.cc:25:
./options.h:4283:42: error: expected ')' before '.' token
 4283 | #define warn_unused_result global_options.x_warn_unused_result
      |                                          ^
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/install/include/ansidecl.h:282:56: note: in expansion of macro 'warn_unused_result'
  282 | #  define ATTRIBUTE_WARN_UNUSED_RESULT __attribute__ ((warn_unused_result))
      |                                                        ^~~~~~~~~~~~~~~~~~
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-13.2.0/gcc/tree.h:1302:1: note: in expansion of macro 'ATTRIBUTE_WARN_UNUSED_RESULT'
 1302 | ATTRIBUTE_WARN_UNUSED_RESULT
      | ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
In file included from ./config.h:8,
                 from /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-13.2.0/gcc/lto-compress.cc:22:
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/install/include/ansidecl.h:282:55: note: to match this '('
  282 | #  define ATTRIBUTE_WARN_UNUSED_RESULT __attribute__ ((warn_unused_result))
      |                                                       ^
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-13.2.0/gcc/tree.h:1302:1: note: in expansion of macro 'ATTRIBUTE_WARN_UNUSED_RESULT'
 1302 | ATTRIBUTE_WARN_UNUSED_RESULT
      | ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
./options.h:4283:42: error: expected ')' before '.' token
 4283 | #define warn_unused_result global_options.x_warn_unused_result
      |                                          ^
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/install/include/ansidecl.h:282:56: note: in expansion of macro 'warn_unused_result'
  282 | #  define ATTRIBUTE_WARN_UNUSED_RESULT __attribute__ ((warn_unused_result))
      |                                                        ^~~~~~~~~~~~~~~~~~
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-13.2.0/gcc/tree.h:1302:1: note: in expansion of macro 'ATTRIBUTE_WARN_UNUSED_RESULT'
 1302 | ATTRIBUTE_WARN_UNUSED_RESULT
      | ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/install/include/ansidecl.h:282:54: note: to match this '('
  282 | #  define ATTRIBUTE_WARN_UNUSED_RESULT __attribute__ ((warn_unused_result))
      |                                                      ^
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-13.2.0/gcc/tree.h:1302:1: note: in expansion of macro 'ATTRIBUTE_WARN_UNUSED_RESULT'
 1302 | ATTRIBUTE_WARN_UNUSED_RESULT
      | ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
./options.h:4283:42: error: expected ')' before '.' token
 4283 | #define warn_unused_result global_options.x_warn_unused_result
      |                                          ^
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/install/include/ansidecl.h:282:56: note: in expansion of macro 'warn_unused_result'
  282 | #  define ATTRIBUTE_WARN_UNUSED_RESULT __attribute__ ((warn_unused_result))
      |                                                        ^~~~~~~~~~~~~~~~~~
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-13.2.0/gcc/tree.h:1302:1: note: in expansion of macro 'ATTRIBUTE_WARN_UNUSED_RESULT'
 1302 | ATTRIBUTE_WARN_UNUSED_RESULT
      | ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/install/include/ansidecl.h:282:55: note: to match this '('
  282 | #  define ATTRIBUTE_WARN_UNUSED_RESULT __attribute__ ((warn_unused_result))
      |                                                       ^
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-13.2.0/gcc/tree.h:1302:1: note: in expansion of macro 'ATTRIBUTE_WARN_UNUSED_RESULT'
 1302 | ATTRIBUTE_WARN_UNUSED_RESULT
      | ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
./options.h:4283:42: error: expected ')' before '.' token
 4283 | #define warn_unused_result global_options.x_warn_unused_result
      |                                          ^
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/install/include/ansidecl.h:282:56: note: in expansion of macro 'warn_unused_result'
  282 | #  define ATTRIBUTE_WARN_UNUSED_RESULT __attribute__ ((warn_unused_result))
      |                                                        ^~~~~~~~~~~~~~~~~~
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-13.2.0/gcc/tree.h:1302:1: note: in expansion of macro 'ATTRIBUTE_WARN_UNUSED_RESULT'
 1302 | ATTRIBUTE_WARN_UNUSED_RESULT
      | ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/install/include/ansidecl.h:282:54: note: to match this '('
  282 | #  define ATTRIBUTE_WARN_UNUSED_RESULT __attribute__ ((warn_unused_result))
      |                                                      ^
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-13.2.0/gcc/tree.h:1302:1: note: in expansion of macro 'ATTRIBUTE_WARN_UNUSED_RESULT'
 1302 | ATTRIBUTE_WARN_UNUSED_RESULT
      | ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
In file included from /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-13.2.0/gcc/lto-compress.cc:26:
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-13.2.0/gcc/tree.h:1303:66: error: declaration does not declare anything [-fpermissive]
 1303 | extern tree protected_set_expr_location_unshare (tree, location_t);
      |                                                                  ^
```
