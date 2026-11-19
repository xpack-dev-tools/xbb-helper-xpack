# autoreconf fails with missing m4_ifdef

While re-configuring libxml2, autoreconf fails, complaining that
`m4_ifdef` is not defined.

According to autoconf, it should be part of m4sugar:

https://www.gnu.org/software/autoconf/manual/autoconf-2.68/html_node/Redefined-M4-Macros.html#Redefined-M4-Macros

## Workaround

None known, so far.

## Console output

```console
[autoreconf -vfi]
autoreconf: export WARNINGS=
autoreconf: Entering directory '.'
autoreconf: configure.ac: not using Gettext
autoreconf: running: aclocal --force -I m4
autoreconf: configure.ac: tracing
autoreconf: running: libtoolize --copy --force
libtoolize: putting auxiliary files in '.'.
libtoolize: copying file './ltmain.sh'
libtoolize: putting macros in AC_CONFIG_MACRO_DIRS, 'm4'.
libtoolize: copying file 'm4/libtool.m4'
libtoolize: copying file 'm4/ltoptions.m4'
libtoolize: copying file 'm4/ltsugar.m4'
libtoolize: copying file 'm4/ltversion.m4'
libtoolize: copying file 'm4/lt~obsolete.m4'
autoreconf: configure.ac: not using Intltool
autoreconf: configure.ac: not using Gtkdoc
autoreconf: running: aclocal --force -I m4
autoreconf: running: /Users/ilg/Work/xpack-dev-tools-build/qemu-riscv-8.1.0-1/darwin-x64/x86_64-apple-darwin21.6.0/install/bin/autoconf --force
configure.ac:1087: error: possibly undefined macro: m4_ifdef
      If this token and others are legitimate, please use m4_pattern_allow.
      See the Autoconf documentation.
autoreconf: error: /Users/ilg/Work/xpack-dev-tools-build/qemu-riscv-8.1.0-1/darwin-x64/x86_64-apple-darwin21.6.0/install/bin/autoconf failed with exit status: 1
```
