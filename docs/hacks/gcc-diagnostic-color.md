# abort() macro interfeares with <windows.h>

In `gcc/diagnostic-color.cc`, the header `system.h` defines the `abort()`
macro. This definition interferes with several methods in `windows.h`.

```c++
#include "config.h"
#include "system.h"
#include "diagnostic-color.h"
#include "diagnostic-url.h"

#ifdef __MINGW32__
#  include <windows.h>
#endif
```

Two solutions:

```c++
#ifdef __MINGW32__
#  include <windows.h>
#endif

#include "config.h"
#include "system.h"
#include "diagnostic-color.h"
#include "diagnostic-url.h"
```

or

```c++
#include "config.h"
#include "system.h"
#include "diagnostic-color.h"
#include "diagnostic-url.h"

#ifdef __MINGW32__
#  undef abort
#  include <windows.h>
#endif
```

The error looks like:

```console
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install/bin/x86_64-w64-mingw32-g++  -fno-PIE -c   -pipe -O2 -w -D__USE_MINGW_ACCESS     -DIN_GCC     -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -W -Wall -Wno-narrowing -Wwrite-strings -Wcast-qual -Wmissing-format-attribute -Woverloaded-virtual -pedantic -Wno-long-long -Wno-variadic-macros -Wno-overlength-strings   -DHAVE_CONFIG_H -I. -I. -I/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc -I/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/. -I/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../include -I/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libcpp/include -I/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libcody -I/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include -I/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include -I/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include  -I/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libdecnumber -I/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libdecnumber/bid -I../libdecnumber -I/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libbacktrace -I/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include -I/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include  -o diagnostic-color.o -MT diagnostic-color.o -MMD -MP -MF ./.deps/diagnostic-color.TPo /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/diagnostic-color.cc
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/system.h:782:30: error: expected identifier before string constant
  782 | #define abort() fancy_abort (__FILE__, __LINE__, __FUNCTION__)
      |                              ^~~~~~~~
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/system.h:782:30: error: expected ',' or '...' before string constant
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/system.h:782:30: error: expected identifier before string constant
  782 | #define abort() fancy_abort (__FILE__, __LINE__, __FUNCTION__)
      |                              ^~~~~~~~
/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/system.h:782:30: error: expected ',' or '...' before string constant
Makefile:1143: recipe for target 'diagnostic-color.o' failed
make[2]: *** [diagnostic-color.o] Error 1
make[2]: Leaving directory '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/build/gcc-12.3.0/gcc'
Makefile:4630: recipe for target 'all-gcc' failed
make[1]: *** [all-gcc] Error 2
make[1]: Leaving directory '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/build/gcc-12.3.0'
Makefile:1045: recipe for target 'all' failed
make: *** [all] Error 2
```


The offending command, verbose and with -E:

```console
Using built-in specs.
COLLECT_GCC=/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install/bin/x86_64-w64-mingw32-g++
Target: x86_64-w64-mingw32
Configured with: /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/configure --prefix=/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install --with-sysroot=/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install --libexecdir=/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install/lib --infodir=/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/x86_64-w64-mingw32/install/share/info --mandir=/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/x86_64-w64-mingw32/install/share/man --htmldir=/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/x86_64-w64-mingw32/install/share/html --pdfdir=/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/x86_64-w64-mingw32/install/share/pdf --build=x86_64-pc-linux-gnu --host=x86_64-pc-linux-gnu --target=x86_64-w64-mingw32 --with-pkgversion='xPack MinGW-w64 GCC x86_64' --with-default-libstdcxx-abi=new --with-diagnostics-color=auto --with-dwarf2 --with-gmp=/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/x86_64-w64-mingw32/install --with-mpfr=/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/x86_64-w64-mingw32/install --with-mpc=/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/x86_64-w64-mingw32/install --with-isl=/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/x86_64-w64-mingw32/install --with-libiconv-prefix=/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/x86_64-w64-mingw32/install --with-zstd=/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/x86_64-w64-mingw32/install --with-system-zlib --without-cuda-driver --enable-languages=c,c++,fortran,objc,obj-c++,lto --enable-shared --enable-static --enable-__cxa_atexit --enable-checking=release --enable-cloog-backend=isl --enable-fully-dynamic-string --enable-libgomp --enable-libatomic --enable-graphite --enable-libquadmath --enable-libquadmath-support --enable-libssp --enable-libstdcxx --enable-libstdcxx-time=yes --enable-libstdcxx-visibility --enable-libstdcxx-threads --enable-libstdcxx-filesystem-ts=yes --enable-libstdcxx-time=yes --enable-lto --enable-pie-tools --enable-threads=posix --disable-install-libiberty --disable-libstdcxx-debug --disable-libstdcxx-pch --disable-multilib --disable-nls --disable-sjlj-exceptions --disable-werror
Thread model: posix
Supported LTO compression algorithms: zlib zstd
gcc version 12.3.0 (xPack MinGW-w64 GCC x86_64)
COLLECT_GCC_OPTIONS='-fno-PIE' '-c' '-pipe' '-O2' '-w' '-D' '__USE_MINGW_ACCESS' '-D' 'IN_GCC' '-fno-exceptions' '-fno-rtti' '-fasynchronous-unwind-tables' '-Wextra' '-Wall' '-Wno-narrowing' '-Wwrite-strings' '-Wcast-qual' '-Wsuggest-attribute=format' '-Woverloaded-virtual' '-Wpedantic' '-Wno-long-long' '-Wno-variadic-macros' '-Wno-overlength-strings' '-D' 'HAVE_CONFIG_H' '-I' '.' '-I' '.' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/.' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../include' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libcpp/include' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libcody' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libdecnumber' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libdecnumber/bid' '-I' '../libdecnumber' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libbacktrace' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include' '-o' 'diagnostic-color.o.cc' '-MT' 'diagnostic-color.o' '-MMD' '-MP' '-MF' './.deps/diagnostic-color.TPo' '-E' '-v' '-shared-libgcc' '-mtune=generic' '-march=x86-64'
 /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install/lib/gcc/x86_64-w64-mingw32/12.3.0/cc1plus -E -quiet -v -I . -I . -I /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc -I /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/. -I /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../include -I /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libcpp/include -I /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libcody -I /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include -I /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include -I /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include -I /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libdecnumber -I /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libdecnumber/bid -I ../libdecnumber -I /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libbacktrace -I /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include -I /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include -MMD diagnostic-color.o.d -MF ./.deps/diagnostic-color.TPo -MP -MT diagnostic-color.o -D_REENTRANT -D __USE_MINGW_ACCESS -D IN_GCC -D HAVE_CONFIG_H /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/diagnostic-color.cc -o diagnostic-color.o.cc -mtune=generic -march=x86-64 -Wextra -Wall -Wno-narrowing -Wwrite-strings -Wcast-qual -Wsuggest-attribute=format -Woverloaded-virtual -Wpedantic -Wno-long-long -Wno-variadic-macros -Wno-overlength-strings -w -fno-PIE -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -O2 -dumpbase diagnostic-color.o.cc -dumpbase-ext .cc
ignoring nonexistent directory "/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install/usr/local/include"
ignoring nonexistent directory "/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install/mingw/include"
ignoring duplicate directory "."
ignoring duplicate directory "/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/."
ignoring duplicate directory "/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include"
ignoring duplicate directory "/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include"
ignoring duplicate directory "/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include"
ignoring duplicate directory "/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include"
#include "..." search starts here:
#include <...> search starts here:
 .
 /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc
 /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../include
 /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libcpp/include
 /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libcody
 /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include
 /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libdecnumber
 /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libdecnumber/bid
 ../libdecnumber
 /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libbacktrace
 /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install/lib/gcc/x86_64-w64-mingw32/12.3.0/../../../../x86_64-w64-mingw32/include/c++/12.3.0
 /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install/lib/gcc/x86_64-w64-mingw32/12.3.0/../../../../x86_64-w64-mingw32/include/c++/12.3.0/x86_64-w64-mingw32
 /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install/lib/gcc/x86_64-w64-mingw32/12.3.0/../../../../x86_64-w64-mingw32/include/c++/12.3.0/backward
 /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install/lib/gcc/x86_64-w64-mingw32/12.3.0/include
 /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install/lib/gcc/x86_64-w64-mingw32/12.3.0/include-fixed
 /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install/lib/gcc/x86_64-w64-mingw32/12.3.0/../../../../x86_64-w64-mingw32/include
End of search list.
COMPILER_PATH=/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install/lib/gcc/x86_64-w64-mingw32/12.3.0/:/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install/lib/gcc/x86_64-w64-mingw32/12.3.0/:/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install/lib/gcc/x86_64-w64-mingw32/:/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install/lib/gcc/x86_64-w64-mingw32/12.3.0/:/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install/lib/gcc/x86_64-w64-mingw32/:/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install/lib/gcc/x86_64-w64-mingw32/12.3.0/../../../../x86_64-w64-mingw32/bin/
LIBRARY_PATH=/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install/lib/gcc/x86_64-w64-mingw32/12.3.0/:/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install/lib/gcc/x86_64-w64-mingw32/12.3.0/../../../../x86_64-w64-mingw32/lib/../lib/:/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-pc-linux-gnu/install/lib/gcc/x86_64-w64-mingw32/12.3.0/../../../../x86_64-w64-mingw32/lib/
COLLECT_GCC_OPTIONS='-fno-PIE' '-c' '-pipe' '-O2' '-w' '-D' '__USE_MINGW_ACCESS' '-D' 'IN_GCC' '-fno-exceptions' '-fno-rtti' '-fasynchronous-unwind-tables' '-Wextra' '-Wall' '-Wno-narrowing' '-Wwrite-strings' '-Wcast-qual' '-Wsuggest-attribute=format' '-Woverloaded-virtual' '-Wpedantic' '-Wno-long-long' '-Wno-variadic-macros' '-Wno-overlength-strings' '-D' 'HAVE_CONFIG_H' '-I' '.' '-I' '.' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/.' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../include' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libcpp/include' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libcody' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libdecnumber' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libdecnumber/bid' '-I' '../libdecnumber' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/sources/gcc-12.3.0/gcc/../libbacktrace' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include' '-I' '/home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/win32-x64/x86_64-w64-mingw32/install/include' '-o' 'diagnostic-color.o.cc' '-MT' 'diagnostic-color.o' '-MMD' '-MP' '-MF' './.deps/diagnostic-color.TPo' '-E' '-v' '-shared-libgcc' '-mtune=generic' '-march=x86-64' '-dumpdir' 'diagnostic-color.o.'
```
