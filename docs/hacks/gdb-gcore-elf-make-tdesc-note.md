# The missing `-lpthread` prevented a file to be included in the build

This was a tricky one.

gdb failed with:

```console
linux-tdep.c:(.text._ZL25linux_make_corefile_notesP7gdbarchP3bfdPi+0x4a9): undefined reference to `gcore_elf_make_tdesc_note(bfd*, std::unique_ptr<char, gdb::xfree_deleter<char> >*, int*)'
```

The related bug was not very useful:

- https://sourceware.org/bugzilla/show_bug.cgi?id=30295

The reason was the `gcore-elf.c`` file which was missing from the build.

The reason it was missing, was the `gdb_cv_var_elf` variable,  incorectly
set due to a linker error:

```console
warning: libpthread.so.0, needed by /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/x86_64-pc-linux-gnu/install/lib/libzstd.so, not found (try using -rpath or -rpath-link)
resulting in incomplete configurations like `gdb_cv_var_elf`
```

## Workaround

The fix was to add -lpthread to the linker flags.

