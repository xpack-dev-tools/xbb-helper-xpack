# gcc fails with binutils ansidecl.h

binutils has its own version of `ansidecl.h`. If this file is used
by gcc, it crashes due to a missing PTR macro.

The workaround is to remove the installed file from `${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include/ansidecl.h`.

```
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/sources/gcc-12.3.0/libiberty/objalloc.c:95:18: error: 'PTR' undeclared (first use in this function)
   95 |   ret->chunks = (PTR) malloc (CHUNK_SIZE);
```
