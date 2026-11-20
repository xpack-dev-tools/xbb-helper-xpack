# Long path support for Windows executables

This folder has the files used during xPack post-processing to make
Windows executables long path aware. With this, they can work with
paths longer than 260 characters (`MAX_PATH`).

- [The problem](#the-problem)
- [How long path support works in Windows](#how-long-path-support-works-in-windows)
- [Options considered](#options-considered)
- [The manifest](#the-manifest)
- [Where it runs in the build](#where-it-runs-in-the-build)
- [The `add-manifest` tool](#the-add-manifest-tool)
- [Executables that already have a manifest](#executables-that-already-have-a-manifest)
- [How Wine rewrites the executables](#how-wine-rewrites-the-executables)
- [Checks](#checks)
- [Testing](#testing)
- [Known limits and future work](#known-limits-and-future-work)
- [Files](#files)

## The problem

See
[riscv-none-elf-gcc-xpack discussion #55](https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/discussions/55).

Some IDEs and build systems create very deep build folders. When the
current folder is longer than 260 characters, Ninja 1.12 and later
(which is itself long path aware) fails to start the xPack
compiler:

```
CreateProcess: The parameter is incorrect
```

The child process inherits the long current folder. Windows refuses
to start it with that folder, unless the child is also long path
aware. The xPack executables had no application manifest, so they
were not.

The fix must cover **all** executables, not only the one Ninja
starts: `gcc.exe` starts `cc1.exe`, `as.exe`, `collect2.exe`, and
`collect2.exe` starts `ld.exe`, all with the same current folder.

The fix is done once, in xbb-helper. This way all xPack projects get
it, without changes in each project.

## How long path support works in Windows

On Windows 10 1607 and later, a process can use paths longer than
`MAX_PATH` without the `\\?\` prefix, but only if **both** of these
are true:

1. the registry value
   `HKLM\SYSTEM\CurrentControlSet\Control\FileSystem\LongPathsEnabled`
   (`REG_DWORD`) is 1;
2. the executable has an application manifest that declares
   `longPathAware` as `true`.

The `RtlAreLongPathsEnabled()` function from `ntdll.dll` returns
`TRUE` only when both conditions are true. The `long-path-check.exe`
test program prints its value.

The manifest is a resource in the executable, with the type
`RT_MANIFEST` (24) and the ID 1 (`CREATEPROCESS_MANIFEST_RESOURCE_ID`).
Windows reads it when the process starts. DLLs use the ID 2, but long
path support is a setting of the whole process, so only executables
need the manifest.

The manifest removes the limit of the operating system only. Code
that uses fixed buffers of `MAX_PATH` or `PATH_MAX` characters can
still fail with long paths.

## Options considered

| Option | Advantages | Disadvantages |
|---|---|---|
| A. `mt.exe` (from the Windows SDK) under Wine | Official tool, can merge manifests. | Not redistributable (see below). It calls the same `UpdateResource` API under Wine, so it is not more reliable than B. |
| **B. Own small C program under Wine** (chosen) | In this repository, no license issues, no downloads. Same mechanism as `mt.exe`. | Needs Wine, and depends on how Wine rewrites the PE file (see [below](#how-wine-rewrites-the-executables)). |
| C. Link the manifest (`windres` object in `LDFLAGS`) | The normal way; no rewrite of binaries. | Every project must be rebuilt. libtool can drop objects from `LDFLAGS`. Causes duplicate resource errors where the project has its own manifest. Misses copied executables. |
| C′. `default-manifest.o` in the toolchain | Applies to all executables automatically. | A change of the toolchain, not of the post-processing. |
| D. A Linux PE editor (LIEF, `pefile`, own code) | No Wine. | New dependency, or about 150 lines of own PE code to maintain. |
| `objcopy --add-section .rsrc=...` | — | Does not work: the resource offsets in the object are relocations that `objcopy` does not apply, so the result is invalid. |

The `mt.exe` license: the
[Windows SDK license](https://learn.microsoft.com/en-us/legal/windows-sdk/license)
lets you redistribute only the files on the
[REDIST list](https://learn.microsoft.com/en-us/legal/windows-sdk/redist)
(§2.a), and `mt.exe` is not on it. §7 forbids you to "publish the
software for others to copy". Using the SDK on build servers (§1.c)
is allowed, but then each build must download it.

Option B is the current solution. Options C and C′ may be done later,
as a separate step.

## The manifest

`long-path-aware.manifest` is embedded in executables that have no
manifest:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
  <trustInfo xmlns="urn:schemas-microsoft-com:asm.v2">
    <security>
      <requestedPrivileges xmlns="urn:schemas-microsoft-com:asm.v3">
        <requestedExecutionLevel level="asInvoker" uiAccess="false"/>
      </requestedPrivileges>
    </security>
  </trustInfo>
  <application xmlns="urn:schemas-microsoft-com:asm.v3">
    <windowsSettings xmlns:ws2="http://schemas.microsoft.com/SMI/2016/WindowsSettings">
      <ws2:longPathAware>true</ws2:longPathAware>
    </windowsSettings>
  </application>
</assembly>
```

- The `longPathAware` block is the one from the Microsoft
  [Application manifests](https://learn.microsoft.com/en-us/windows/win32/sbscs/application-manifests)
  page. The namespace starts with `http://`, not `https://`.
- The `trustInfo` block, also from that page, sets the `asInvoker`
  execution level. It is optional. It stops the UAC installer
  detection from asking to elevate programs with names like
  `patch.exe` or `install.exe`. MSYS2 has the same block in its
  default manifest. Installer detection applies only to 32-bit
  processes, so for the 64-bit xPack executables the block is
  redundant but harmless. It is kept in case a 32-bit build is
  added. The merge does not add it (see below).
- The Microsoft page shows `assemblyIdentity` as required, but the
  manifests that MSVC embeds by default do not have it, and Windows
  accepts them. It is not used here.

The file was checked with `xmllint --noout`.

## Where it runs in the build

The step is `windows_add_long_path_manifests()` in
`build-scripts/post-processing.sh`. `build_common_run()` in
`build-scripts/build-common.sh` calls it only for Windows builds:

```sh
strip_binaries

if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "win32" ]
then
  # Must be after strip, which rewrites the binaries.
  windows_add_long_path_manifests
fi

copy_distro_files
...
check_binaries
...
create_archive
```

It runs after `strip_binaries`, so `strip` does not rewrite the
executables after the manifest is added. It runs before
`check_binaries`, the archive and the tests, so these use the final
executables.

The function:

1. returns for other platforms, and is skipped when
   `XBB_WITH_LONG_PATH_MANIFEST` is not `"y"`;
2. finds `wine64`, or `wine` (recent Wine releases have only `wine`),
   and fails if neither is available;
3. calls `windows_build_manifest_tool()`, which compiles
   `add-manifest.c` with the mingw-w64 `${CC}` into
   `${XBB_TARGET_WORK_FOLDER_PATH}/long-path-manifest/add-manifest.exe`.
   It uses explicit flags (`-O2 -municode -static`), not the
   application flags. The tool is built again when `add-manifest.c`
   is newer than it;
4. lists the files in the application folder with `find -type f
   -name '*.exe'`, keeping only PE files (`is_pe`). Symbolic links are
   not included;
5. uses a separate Wine prefix,
   `${XBB_TARGET_WORK_FOLDER_PATH}/long-path-manifest/wine-prefix`,
   with `WINEDEBUG=-all`, and with `WINEDLLOVERRIDES="mscoree,mshtml="`
   to avoid the Mono and Gecko install prompts. In a new prefix, the
   `Z:` drive is the Linux root, so the Linux path `/a/b` is passed as
   `Z:/a/b`;
6. runs `add-manifest.exe <manifest> <exe>...` (the update pass), then
   `add-manifest.exe --check <exe>...` (the check pass). The Windows
   command line is limited to 32767 characters, so the files are
   passed in groups of about 24000 characters;
7. checks each file again with `${OBJDUMP} -p`, which is a different
   PE parser (BFD), for an `RT_MANIFEST` entry at the top of the
   resource tree;
8. fails the build if any step fails.

In the xPack projects, Wine comes from the `@xpack-dev-tools/wine`
development dependency of the `win32-x64` build configuration, not
from the Docker image.

### Configuration

To disable the step for an application, add this line to its
`build-assets/scripts/application.sh`:

```sh
XBB_WITH_LONG_PATH_MANIFEST="n"
```

The default is `"y"`.

## The `add-manifest` tool

`add-manifest.c` is a Windows program that runs under Wine. It uses
the Win32 resource API, so Wine's code does the actual rewrite of the
PE file. It cannot be a Linux program for this reason.

```
add-manifest.exe <manifest-file> <exe-file>...
add-manifest.exe --check <exe-file>...
```

Exit codes:

- 0: all files were updated, already up to date, or passed the check;
- 1: at least one file failed;
- 2: usage error, or the manifest file cannot be read.

For each file, the update mode:

1. opens the file as data (`LoadLibraryExW` with
   `LOAD_LIBRARY_AS_DATAFILE`) and reads the manifest with ID 1, if
   there is one (`EnumResourceLanguagesW`, `FindResourceExW`);
2. decides what to do (see the
   [next section](#executables-that-already-have-a-manifest));
3. writes the new manifest with `BeginUpdateResourceW`,
   `UpdateResourceW` and `EndUpdateResourceW`. If `UpdateResourceW`
   fails, the update is discarded and the file is not changed;
4. checks the COFF symbol table pointer, and repairs it if needed (see
   [below](#the-coff-symbol-table-pointer));
5. reads the file again, to confirm that it now declares
   `longPathAware` as `true`.

It prints one line for each file:

```
<file>: manifest added
<file>: longPathAware merged into the existing manifest
<file>: already longPathAware, skipped
<file>: COFF symbol table pointer moved from 0x... to 0x...
```

Errors go to `stderr`, with the reason.

The `--check` mode changes nothing. It fails for each file that has
no manifest, or whose manifest does not declare `longPathAware` as
`true`, or that has an invalid COFF symbol table pointer.

## Executables that already have a manifest

There are three cases:

| Existing manifest with ID 1 | Action |
|---|---|
| None | `long-path-aware.manifest` is embedded as is, with the language `LANG_NEUTRAL`. |
| Declares `longPathAware` as `true` | Nothing is changed. |
| Any other manifest | The `longPathAware` element is merged into it. |

### Hard links

binutils installs `<triplet>/bin/*.exe` as hard links to
`bin/<triplet>-*.exe`. Some GCC drivers are hard linked to each
other too, such as `gcc.exe` and `gcc-<version>.exe`, or `c++.exe`
and `g++.exe`. Wine updates the file in place, so after the first
name is processed, the other names already have the manifest, and
they are reported as `already longPathAware, skipped`.

### The merge

The merge is needed for GCC 13 and later. GCC embeds a manifest that
sets the UTF-8 `activeCodePage` in its drivers (`gcc`, `g++`, `c++`,
`cpp`, `gfortran`, ...) and compilers (`cc1`, `cc1plus`, `f951`,
`lto1`, ...). The source is `gcc/config/i386/winnt-utf8.manifest`:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly manifestVersion="1.0" xmlns="urn:schemas-microsoft-com:asm.v1">
  <application>
    <windowsSettings>
      <activeCodePage xmlns="http://schemas.microsoft.com/SMI/2019/WindowsSettings">UTF-8</activeCodePage>
    </windowsSettings>
  </application>
</assembly>
```

The first version of the step skipped all executables that had a
manifest. So exactly these programs, which are the ones that need
long paths most, were left without `longPathAware`. The merge fixes
this.

The merge is a text insertion; the rest of the manifest is not
changed. This element is inserted:

```xml
<longPathAware xmlns="http://schemas.microsoft.com/SMI/2016/WindowsSettings">true</longPathAware>
```

It goes in the first of these places that exists:

1. before `</windowsSettings>`;
2. before `</application>`, in a new `<windowsSettings>` element;
3. before `</assembly>`, in new
   `<application xmlns="urn:schemas-microsoft-com:asm.v3">` and
   `<windowsSettings>` elements.

The merged manifest replaces the original one, with the same ID (1)
and the same language (0x409 for the GCC manifest), so the
executable still has a single manifest.

After the merge, the manifest of the GCC 15 `cc1.exe` is:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly manifestVersion="1.0" xmlns="urn:schemas-microsoft-com:asm.v1">
  <application>
    <windowsSettings>
      <activeCodePage xmlns="http://schemas.microsoft.com/SMI/2019/WindowsSettings">UTF-8</activeCodePage>
      <longPathAware xmlns="http://schemas.microsoft.com/SMI/2016/WindowsSettings">true</longPathAware>
    </windowsSettings>
  </application>
</assembly>
```

Both settings are in the same `windowsSettings` element, but in
different namespaces (2019 and 2016), as the Microsoft documentation
specifies.

The merge does not add the `trustInfo` block (the `asInvoker`
execution level), and it is not needed:

- The execution level has no effect on long paths. Only the
  `longPathAware` element and the `LongPathsEnabled` registry value
  are checked.
- The UAC installer detection and the file and registry
  virtualization, which `asInvoker` turns off, apply only to 32-bit
  processes. The xPack Windows executables are 64-bit (`win32-x64`),
  so they are not affected, with or without the block.
- The original manifest is changed only as much as necessary. GCC's
  manifest has no `trustInfo` block, and the GCC executables were
  released that way.

### Cases that fail

The tool does not guess. In these cases the file is not changed, and
the build fails:

- the manifest is UTF-16 encoded;
- `application` or `windowsSettings` has an XML namespace prefix (for
  example `<asmv3:windowsSettings>`), or is an empty element
  (`<windowsSettings/>`);
- the manifest declares `longPathAware` with a value other than
  `true`; this is probably intentional;
- there is more than one manifest with ID 1, in different languages.

To build such an application, set `XBB_WITH_LONG_PATH_MANIFEST="n"`,
and handle it separately.

The `longPathAware` element is found by its name, with any namespace
prefix, and its value is compared with `true` (case is ignored).

## How Wine rewrites the executables

This was tested with the xPack Wine 10.0.0-3.1. `EndUpdateResourceW`
writes the file again; the result depends on the layout of the file.

### The file has no `.rsrc` section

This is the case for most executables (binutils, gdb, ninja).

Wine adds a new `.rsrc` section after all the other data in the file.
The existing sections do not move.

Example, `ninja.exe`, before and after:

```
before:  .text .data .rdata ... .idata .tls .reloc
after:   .text .data .rdata ... .idata .tls .reloc .rsrc
```

If the file has a COFF symbol table after the last section (see
below), two layouts were seen in different builds:

- Wine adds `.rsrc` after the symbol table and the string table, and
  they stay where they were, with a valid pointer;
- Wine adds `.rsrc` where the symbol table was, moves the table after
  it, and updates the pointer.

Both are valid, and the tool accepts both.

### The file has a `.rsrc` section that is not the last one

This is the case for the GCC drivers and compilers. GNU ld places
`.rsrc` before `.reloc`.

Wine writes the resources in the existing `.rsrc` section. If the new
resources do not fit, the section grows, by multiples of the file
alignment (0x200). The following data in the file (`.reloc` and the
COFF symbol table) moves by the same amount. The addresses in memory
of the sections do not change, because `.rsrc` is still smaller than
one memory page (0x1000).

Example, `cc1.exe`. The GCC manifest is 0x147 bytes; with the
resource directory, `.rsrc` uses 0x1a0 bytes, in a 0x200 byte section.
The merge adds 0x68 bytes, so the manifest becomes 0x1af bytes, and
`.rsrc` needs a 0x400 byte section:

```
         .rsrc                  .reloc                  symbol table
before:  0x3391c00 size 0x200   0x3391e00 size 0xec000  0x347de00
after:   0x3391c00 size 0x400   0x3392000 size 0xec000  0x347e000
```

### The COFF symbol table pointer

The stripped mingw-w64 executables still have a COFF symbol table and
its string table, after the last section (`cc1.exe` has 436 symbols).
The `PointerToSymbolTable` field of the COFF header gives its offset
in the file.

When the `.rsrc` section grows, Wine moves the symbol table with the
other data, but does not update `PointerToSymbolTable`. The pointer
then shows a location in `.reloc`. Windows does not use the COFF
symbol table, so the program still runs. But `objdump` and `gdb`
report:

```
objdump: failed to read symbol table from: cc1.exe
objdump: error message was: file truncated
```

The tool repairs this, after each update. The pointer is valid when
the symbol table and its string table fit in the file, and do not
overlap any section. (The first 4 bytes of the string table give its
size.) If the pointer is not valid, the tool checks for a valid table
at the end of the last section, where Wine moved it. If there is one,
it writes the new offset in the header, and prints a message:

```
cc1.exe: COFF symbol table pointer moved from 0x347de00 to 0x347e000
```

If there is no valid table there either, the file fails.

The symbol table is not always after the last section: when Wine adds
a new `.rsrc` (the first case above), `.rsrc` can come after the
symbol table. For this reason, the rule is "does not overlap any
section", not "is after the last section". An earlier version of the
tool used the second rule, and failed for these files.

The repair also runs for files that are skipped as `already
longPathAware`. This repairs files that an older version of the tool
updated.

### The `PADDINGXX` bytes

Wine fills the end of the `.rsrc` section with the text
`PADDINGXXPADDING...`, as the Microsoft resource tools do. objdump
prints a warning about it:

```
WARNING: Extra data in .rsrc section - it will be ignored by Windows
```

This warning is harmless: Windows ignores these bytes, as the warning
says.

## Checks

The build fails unless all of these pass:

1. the update pass reads each changed file again, and confirms that
   it declares `longPathAware` as `true`;
2. the `--check` pass confirms the same for all files, and also checks
   the COFF symbol table pointer;
3. `objdump -p` shows an `RT_MANIFEST` entry (`ID: 0x000018`) at the
   top of the resource tree of each file.

The application tests then run the final executables under Wine.

## Testing

### In the build container

Tested with xPack Wine 10.0.0-3.1 and xPack mingw-w64 GCC 15.2.0:

- ninja-build, `win32-x64`: the manifest is added to `ninja.exe`; the
  archive has it; the tests pass. A second build skips the file.
  The `linux-x64` build does not run the step.
- riscv-none-elf-gcc 15.2.0, `win32-x64`, from a new `application`
  folder: 48 executables; 29 get the manifest added; 7 get the merge
  and the symbol table repair (`gcc-15.2.0`, `c++`, `cpp`,
  `gfortran`, `cc1`, `cc1plus`, `f951`, `lto1`); 12 hard links are
  skipped. The check passes, objdump reports no symbol table errors,
  and the tests pass.
- The patched riscv toolchain compiles and links C, C++ and LTO
  programs under Wine.
- Separate test programs for each case: no resources; existing
  resources before `.reloc` (version information); the GCC UTF-8
  manifest, made from `gcc/config/i386/utf8-mingw32.rc`; with and
  without a COFF symbol table.

To run the tool manually in the container, use the tools of the
build configuration:

```sh
B=<project>/build-assets/build/win32-x64
export PATH="${B}/xpacks/.bin:${PATH}"
export WINEPREFIX="$(mktemp -d)/wine-prefix" WINEDEBUG=-all WINEDLLOVERRIDES="mscoree,mshtml="

x86_64-w64-mingw32-gcc -O2 -municode -static -o add-manifest.exe add-manifest.c

wine64 add-manifest.exe Z:$(pwd)/long-path-aware.manifest Z:/path/to/program.exe
wine64 add-manifest.exe --check Z:/path/to/program.exe
x86_64-w64-mingw32-objdump -p /path/to/program.exe | grep 'Entry: ID: 0x000018'
```

Wine does not limit paths to `MAX_PATH` as Windows does, so the effect
of the manifest cannot be tested in the container.

### On Windows

`long-path-check.c` is a test program for Windows. It is not used
during builds. Build it with:

```sh
x86_64-w64-mingw32-gcc -O2 -municode -static -o long-path-check.exe long-path-check.c
```

Embed the manifest in it with `add-manifest.exe`, and keep a copy
without the manifest, to compare.

```
long-path-check.exe
long-path-check.exe --deep
long-path-check.exe --deep <program> [args...]
```

Without arguments, it prints:

- the `LongPathsEnabled` registry value;
- whether the executable has a manifest;
- the result of `RtlAreLongPathsEnabled()`.

With `--deep`, it also creates a folder tree longer than 320
characters in `%TEMP%`, with plain paths (no `\\?\` prefix). It makes
this folder the current folder, creates and deletes a file there, and
then starts a program, which inherits the long current folder, as
with Ninja. Without a program, it starts a copy of itself. Then it
removes the folder tree.

The exit code is 0 if long paths are enabled and the deep test
passes.

A test for the original problem, with `LongPathsEnabled` set to 1:

```
long-path-check.exe --deep riscv-none-elf-gcc.exe --version
```

Then build a CMake and Ninja project in a folder longer than 260
characters, and check that the compiler, the assembler and the linker
all run.

## Known limits and future work

- The manifest has no effect unless `LongPathsEnabled` is set to 1,
  on Windows 10 1607 or later.
- Code with fixed `MAX_PATH` or `PATH_MAX` buffers can still fail with
  long paths (possible places: libiberty `pex-win32`,
  `make_relative_prefix`, `_getcwd`). Only tests on Windows can show
  this.
- Not tested yet on Windows.
- Not tested yet with a file list longer than one group (about 24000
  characters).
- Adding the manifest in the toolchain (options C and C′) may be done
  later, as a separate step. The post-processing step can stay, for
  executables that the toolchain does not build.

## Files

| File | Purpose |
|---|---|
| `long-path-aware.manifest` | The manifest embedded in executables that have none. |
| `add-manifest.c` | The tool that embeds or merges the manifest, and checks the result. Runs under Wine during the build. |
| `long-path-check.c` | A test program for Windows. Not used during builds. |
| `README.md` | This document. |

The build code is in `build-scripts/post-processing.sh`
(`windows_build_manifest_tool()`, `windows_add_long_path_manifests()`)
and in `build-scripts/build-common.sh` (`build_common_run()`).
