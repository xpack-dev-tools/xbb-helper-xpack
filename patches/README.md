# Patches

Note: prefer `.git.patch`.

## gdb-X.Y.git.patch

Patches `gdb/python/python-config.py` to return `CONFIG_PYTHON_PREFIX`
as `--prefix`.

Otherwise the result is a non-relocatable gdb-py3:

```console
ilg@wksi ~ % /Users/ilg/Work/riscv-none-elf-gcc-11.3.0-1/darwin-x64-/install/riscv-none-elf-gcc/bin/riscv-none-elf-gdb-py3 --version
Could not find platform independent libraries <prefix>
Could not find platform dependent libraries <exec_prefix>
Consider setting $PYTHONHOME to <prefix>[:<exec_prefix>]
Python path configuration:
  PYTHONHOME = (not set)
  PYTHONPATH = (not set)
  program name = '/Users/ilg/Work/riscv-none-elf-gcc-11.3.0-1/darwin-x64/install/libs/bin/python'
  isolated = 0
  environment = 1
  user site = 1
  import site = 1
  sys._base_executable = '/Users/ilg/Work/riscv-none-elf-gcc-11.3.0-1/darwin-x64/install/libs/bin/python'
  sys.base_prefix = '/Users/ilg/Work/riscv-none-elf-gcc-11.3.0-1/darwin-x64/install/libs'
  sys.base_exec_prefix = '/Users/ilg/Work/riscv-none-elf-gcc-11.3.0-1/darwin-x64/install/libs'
  sys.platlibdir = 'lib'
  sys.executable = '/Users/ilg/Work/riscv-none-elf-gcc-11.3.0-1/darwin-x64/install/libs/bin/python'
  sys.prefix = '/Users/ilg/Work/riscv-none-elf-gcc-11.3.0-1/darwin-x64/install/libs'
  sys.exec_prefix = '/Users/ilg/Work/riscv-none-elf-gcc-11.3.0-1/darwin-x64/install/libs'
  sys.path = [
    '/Users/ilg/Work/riscv-none-elf-gcc-11.3.0-1/darwin-x64/install/libs/lib/python310.zip',
    '/Users/ilg/Work/riscv-none-elf-gcc-11.3.0-1/darwin-x64/install/libs/lib/python3.10',
    '/Users/ilg/Work/riscv-none-elf-gcc-11.3.0-1/darwin-x64/install/libs/lib/lib-dynload',
  ]
Fatal Python error: init_fs_encoding: failed to get the Python codec of the filesystem encoding
Python runtime state: core initialized
ModuleNotFoundError: No module named 'encodings'

Current thread 0x0000000115493600 (most recent call first):
  <no Python frame>
```

## libusb-win32-*-mingw-w64.patch

Make `libusb-win32` build without the Microsoft DDK; it was copied from the [JTAG Tools](https://gitorious.org/jtag-tools/openocd-mingw-build-scripts) project.

## libftdi-*.patch

Add `NO_DEFAULT_PATH` when searching libusb.

## hidapi-*.patch

Remove AC_CONFIG_MACRO_DIR([m4]).

## gcc-X.Y.Z.git.patch & gcc-X.Y.Z-cross.git.patch

For GCC 12 & 13, the `abort()` macro in `system.h` must be disabled when
compiling for mingw-w64.
