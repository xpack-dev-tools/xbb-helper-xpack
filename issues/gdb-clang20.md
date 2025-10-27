
```
  CXX    probe.o
  CXX    process-stratum-target.o
In file included from <built-in>In file included from <built-in>:1:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/defs.h:63:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |    :1:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/defs.h:63:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
 i   nteger_for_size<sizeof (T), static_ca97 |     integer_for_size<sizeof (T), statisct<_cast<bobool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<ui_out_flag>' requested here
  134 |   typedefol> typename enum_underlying_type(T (-1) < T (0)<enum_)type>::type underlying_type;
      |                    ^
>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/ui-out.h:385:16: note: in instantiation of template class 'enum_flags<ui_out_flag>' requested here
  385 |   ui_ou/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.ht:_134f:l20a:gs m_flags;
      |                ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 15] for the enumeration type 'ui_out_flag'
   97 |     i note: in instantiation of template class 'enum_underlying_type<ui_out_flag>' requested here
  134 |   typedef typenteger_for_sname enum_underlying_type<eize<sizenum_type>::type undeof (T), static_castrlying_<botypeol>(;
T       |                    ^
(-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/ui-out.h:385:16: note: in instantiation of template class 'enum_flags<ui_out_flag>' requested here
  385 |   ui_out_flags m_flags;
      |                ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 15] for the enumeration type 'ui_out_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
In file included from <built-in>:1:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/defs.h:63:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<ui_out_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/ui-out.h:385:16: note: in instantiation of template class 'enum_flags<ui_out_flag>' requested here
  385 |   ui_out_flags m_flags;
      |                ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 15] for the enumeration type 'ui_out_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
In file included from <built-in>:1:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/defs.h:63:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<ui_out_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/ui-out.h:385:16: note: in instantiation of template class 'enum_flags<ui_out_flag>' requested here
  385 |   ui_out_flags m_flags;
      |                ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 15] for the enumeration type 'ui_out_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
In file included from <built-in>:1:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/defs.h:63:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<ui_out_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/ui-out.h:385:16: note: in instantiation of template class 'enum_flags<ui_out_flag>' requested here
  385 |   ui_out_flags m_flags;
      |                ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 15] for the enumeration type 'ui_out_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
In file included from <built-in>:1:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/defs.h:63:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<ui_out_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/ui-out.h:385:16: note: in instantiation of template class 'enum_flags<ui_out_flag>' requested here
  385 |   ui_out_flags m_flags;
      |                ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 15] for the enumeration type 'ui_out_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
In file included from <built-in>:1:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/defs.h:63:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<ui_out_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/ui-out.h:385:16: note: in instantiation of template class 'enum_flags<ui_out_flag>' requested here
  385 |   ui_out_flags m_flags;
      |                ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 15] for the enumeration type 'ui_out_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
In file included from <built-in>:1:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/defs.h:63:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<ui_out_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/ui-out.h:385:16: note: in instantiation of template class 'enum_flags<ui_out_flag>' requested here
  385 |   ui_out_flags m_flags;
      |                ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 15] for the enumeration type 'ui_out_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<domain_search_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:31: note: in instantiation of template class 'enum_flags<domain_search_flag>' requested here
  920 | constexpr domain_search_flags SEARCH_ALL_DOMAINS
      |                               ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 255] for the enumeration type 'domain_search_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<domain_search_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:31: note: in instantiation of template class 'enum_flags<domain_search_flag>' requested here
  920 | constexpr domain_search_flags SEARCH_ALL_DOMAINS
      |                               ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 255] for the enumeration type 'domain_search_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/p-typeprint.c:24:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:31: error: constexpr variable 'SEARCH_ALL_DOMAINS' must be initialized by a constant expression
  920 | constexpr domain_search_flags SEARCH_ALL_DOMAINS
      |                               ^
  921 |     = ((domain_search_flags) 0
      |       ~~~~~~~~~~~~~~~~~~~~~~~~
  922 | #define SYM_DOMAIN(X) | SEARCH_ ## X ## _DOMAIN
      | ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  923 | #include "sym-domains.def"
      | ~~~~~~~~~~~~~~~~~~~~~~~~~~
  924 | #undef SYM_DOMAIN
      | ~~~~~~~~~~~~~~~~~
  925 |        );
      |        ~
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/p-lang.c:24:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:31: error: constexpr variable 'SEARCH_ALL_DOMAINS' must be initialized by a constant expression
  920 | constexpr domain_search_flags SEARCH_ALL_DOMAINS
      |                               ^
  921 |     = ((domain_search_flags) 0
      |       ~~~~~~~~~~~~~~~~~~~~~~~~
  922 | #define SYM_DOMAIN(X) | SEARCH_ ## X ## _DOMAIN
      | ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  923 | #include "sym-domains.def"
      | ~~~~~~~~~~~~~~~~~~~~~~~~~~
  924 | #undef SYM_DOMAIN
      | ~~~~~~~~~~~~~~~~~
  925 |        );
      |        ~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:961:16: error: static assertion expression is not an integral constant expression
  961 | static_assert (SCRIPTING_SEARCH_FLAG > SEARCH_ALL_DOMAINS);
      |                ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:961:40: note: initializer of 'SEARCH_ALL_DOMAINS' is not a constant expression
  961 | static_assert (SCRIPTING_SEARCH_FLAG > SEARCH_ALL_DOMAINS);
      |                                        ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:31: note: declared here
  920 | constexpr domain_search_flags SEARCH_ALL_DOMAINS
      |                               ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:961:16: error: static assertion expression is not an integral constant expression
  961 | static_assert (SCRIPTING_SEARCH_FLAG > SEARCH_ALL_DOMAINS);
      |                ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:961:40: note: initializer of 'SEARCH_ALL_DOMAINS' is not a constant expression
  961 | static_assert (SCRIPTING_SEARCH_FLAG > SEARCH_ALL_DOMAINS);
      |                                        ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:31: note: declared here
  920 | constexpr domain_search_flags SEARCH_ALL_DOMAINS
      |                               ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<domain_search_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:31: note: in instantiation of template class 'enum_flags<domain_search_flag>' requested here
  920 | constexpr domain_search_flags SEARCH_ALL_DOMAINS
      |                               ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 255] for the enumeration type 'domain_search_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/p-valprint.c:24:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:31: error: constexpr variable 'SEARCH_ALL_DOMAINS' must be initialized by a constant expression
  920 | constexpr domain_search_flags SEARCH_ALL_DOMAINS
      |                               ^
  921 |     = ((domain_search_flags) 0
      |       ~~~~~~~~~~~~~~~~~~~~~~~~
  922 | #define SYM_DOMAIN(X) | SEARCH_ ## X ## _DOMAIN
      | ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  923 | #include "sym-domains.def"
      | ~~~~~~~~~~~~~~~~~~~~~~~~~~
  924 | #undef SYM_DOMAIN
      | ~~~~~~~~~~~~~~~~~
  925 |        );
      |        ~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:961:16: error: static assertion expression is not an integral constant expression
  961 | static_assert (SCRIPTING_SEARCH_FLAG > SEARCH_ALL_DOMAINS);
      |                ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:961:40: note: initializer of 'SEARCH_ALL_DOMAINS' is not a constant expression
  961 | static_assert (SCRIPTING_SEARCH_FLAG > SEARCH_ALL_DOMAINS);
      |                                        ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:31: note: declared here
  920 | constexpr domain_search_flags SEARCH_ALL_DOMAINS
      |                               ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<domain_search_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:31: note: in instantiation of template class 'enum_flags<domain_search_flag>' requested here
  920 | constexpr domain_search_flags SEARCH_ALL_DOMAINS
      |                               ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 255] for the enumeration type 'domain_search_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/parse.c:33:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/arch-utils.h:23:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/gdbarch.h:28:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/infrun.h:21:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/gdbthread.h:26:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/breakpoint.h:23:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/value.h:1035:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:31: error: constexpr variable 'SEARCH_ALL_DOMAINS' must be initialized by a constant expression
  920 | constexpr domain_search_flags SEARCH_ALL_DOMAINS
      |                               ^
  921 |     = ((domain_search_flags) 0
      |       ~~~~~~~~~~~~~~~~~~~~~~~~
  922 | #define SYM_DOMAIN(X) | SEARCH_ ## X ## _DOMAIN
      | ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  923 | #include "sym-domains.def"
      | ~~~~~~~~~~~~~~~~~~~~~~~~~~
  924 | #undef SYM_DOMAIN
      | ~~~~~~~~~~~~~~~~~
  925 |        );
      |        ~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:961:16: error: static assertion expression is not an integral constant expression
  961 | static_assert (SCRIPTING_SEARCH_FLAG > SEARCH_ALL_DOMAINS);
      |                ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:961:40: note: initializer of 'SEARCH_ALL_DOMAINS' is not a constant expression
  961 | static_assert (SCRIPTING_SEARCH_FLAG > SEARCH_ALL_DOMAINS);
      |                                        ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:31: note: declared here
  920 | constexpr domain_search_flags SEARCH_ALL_DOMAINS
      |                               ^
In file included from <built-in>:1:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/defs.h:63:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<innermost_block_tracker_type>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/expression.h:279:33: note: in instantiation of template class 'enum_flags<innermost_block_tracker_type>' requested here
  279 |   innermost_block_tracker_types m_types;
      |                                 ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 3] for the enumeration type 'innermost_block_tracker_type'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<parser_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/expression.h:317:25: note: in instantiation of template class 'enum_flags<parser_flag>' requested here
  317 |                                        parser_flags flags = 0);
      |                                                     ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 15] for the enumeration type 'parser_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
In file included from <built-in>:1:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/defs.h:63:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<innermost_block_tracker_type>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/expression.h:279:33: note: in instantiation of template class 'enum_flags<innermost_block_tracker_type>' requested here
  279 |   innermost_block_tracker_types m_types;
      |                                 ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 3] for the enumeration type 'innermost_block_tracker_type'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<parser_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/expression.h:317:25: note: in instantiation of template class 'enum_flags<parser_flag>' requested here
  317 |                                        parser_flags flags = 0);
      |                                                     ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 15] for the enumeration type 'parser_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<domain_search_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:31: note: in instantiation of template class 'enum_flags<domain_search_flag>' requested here
  920 | constexpr domain_search_flags SEARCH_ALL_DOMAINS
      |                               ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 255] for the enumeration type 'domain_search_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/printcmd.c:23:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:31: error: constexpr variable 'SEARCH_ALL_DOMAINS' must be initialized by a constant expression
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<domain_search_flag>' requested here
  920 | co  134 |   typedef typename enum_underlying_type<enum_type>::type nstexpr underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:domain_sea31: note: in instantiation of template class 'enum_flags<domain_search_flag>' requested here
  920 | constexpr domain_search_flags SEARCH_ALL_DOMAINS
      |                               ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 255] for the enumeration type 'domain_search_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
rch_flags SEARCH_ALL_DOMAINS
      |                               ^
  921 |     = ((domain_search_flags) 0
      |       ~~~~~~~~~~~~~~~~~~~~~~~~
  922 | #define SYM_DOMAIN(X) | SEARCH_ ## X ## _DOMAIN
      | ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  923 | #include "sym-domains.def"
      | ~~~~~~~~~~~~~~~~~~~~~~~~~~
  924 | #undef SYM_DOMAIN
      | ~~~~~~~~~~~~~~~~~
  925 |        );
      |        ~
In file included from <built-in>:1:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/defs.h:63:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<innermost_block_tracker_type>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/expression.h:279:33: note: in instantiation of template class 'enum_flags<innermost_block_tracker_type>' requested here
  279 |   innermost_block_tracker_types m_types;
      |                                 ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 3] for the enumeration type 'innermost_block_tracker_type'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:1) < T961:16: error: static assertion expression is not an integral constant expression
  961 | static_assert (SC (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
R/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.hI:134:20: note: in instantiation of template class 'enum_underlying_type<parser_flag>' requested here
  134 |  P tTyIpNeGd_eSfE typeARCH_Fname enum_underlyingL_tAyGpe<enum_type>: :type u>nderlying_type;
      |                    ^
 /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/expression.h:317:25: note: in instantiation of template class 'enum_flags<parser_flag>' requested here
  317S |                 E                       parser_flaARCH_ALL_DOMAgs flags = IN0);
      |                                                     ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97S);
      |                ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
:52: note: integer value -1 is outside the valid range of values [0, 15] for the enumeration type 'parser_flag'
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h   97 |  :961:  40 :i nnote: teinitializer of 'SEARCH_ALL_DOMAINS' is not a constant expression
  961 | static_assert (SCRIPTING_SEARCH_FLAG > SEARCH_ALL_DOMgAIeNrS_for_size<size)of (T), static_c;
      |                                        ^
ast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:31: note: declared here
  920 | constexpr domain_search_flags SEARCH_ALL_DOMAINS
      |                               ^
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/posix-hdep.c:22:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/inferior.h:40:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/breakpoint.h:23:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/value.h:1035:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:31: error: constexpr variable 'SEARCH_ALL_DOMAINS' must be initialized by a constant expression
  920 | constexpr domain_search_flags SEARCH_ALL_DOMAINS
      |                               ^
  921 |     = ((domain_search_flags) 0
      |       ~~~~~~~~~~~~~~~~~~~~~~~~
  922 | #define SYM_DOMAIN(X) | SEARCH_ ## X ## _DOMAIN
      | ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  923 | #include "sym-domains.def"
      | ~~~~~~~~~~~~~~~~~~~~~~~~~~
  924 | #undef SYM_DOMAIN
      | ~~~~~~~~~~~~~~~~~
  925 |        );
      |        ~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:961:16: error: static assertion expression is not an integral constant expression
  961 | static_assert (SCRIPTING_SEARCH_FLAG > SEARCH_ALL_DOMAINS);
      |                ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:961:40: note: initializer of 'SEARCH_ALL_DOMAINS' is not a constant expression
  961 | static_assert (SCRIPTING_SEARCH_FLAG > SEARCH_ALL_DOMAINS);
      |                                        ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:31: note: declared here
  920 | constexpr domain_search_flags SEARCH_ALL_DOMAINS
      |                               ^
In file included from <built-in>:1:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/defs.h:63:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<innermost_block_tracker_type>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/expression.h:279:33: note: in instantiation of template class 'enum_flags<innermost_block_tracker_type>' requested here
  279 |   innermost_block_tracker_types m_types;
      |                                 ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 3] for the enumeration type 'innermost_block_tracker_type'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<parser_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/expression.h:317:25: note: in instantiation of template class 'enum_flags<parser_flag>' requested here
  317 |                                        parser_flags flags = 0);
      |                                                     ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 15] for the enumeration type 'parser_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
In file included from <built-in>:1:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/defs.h:63:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<innermost_block_tracker_type>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/expression.h:279:33: note: in instantiation of template class 'enum_flags<innermost_block_tracker_type>' requested here
  279 |   innermost_block_tracker_types m_types;
      |                                 ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 3] for the enumeration type 'innermost_block_tracker_type'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<parser_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/expression.h:317:25: note: in instantiation of template class 'enum_flags<parser_flag>' requested here
  317 |                                        parser_flags flags = 0);
      |                                                     ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 15] for the enumeration type 'parser_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
In file included from <built-in>:1:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/defs.h:63:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<innermost_block_tracker_type>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/expression.h:279:33: note: in instantiation of template class 'enum_flags<innermost_block_tracker_type>' requested here
  279 |   innermost_block_tracker_types m_types;
      |                                 ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 3] for the enumeration type 'innermost_block_tracker_type'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<parser_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/expression.h:317:25: note: in instantiation of template class 'enum_flags<parser_flag>' requested here
  317 |                                        parser_flags flags = 0);
      |                                                     ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 15] for the enumeration type 'parser_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<btrace_insn_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/btrace.h:81:21: note: in instantiation of template class 'enum_flags<btrace_insn_flag>' requested here
   81 |   btrace_insn_flags flags;
      |                     ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 1] for the enumeration type 'btrace_insn_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<btrace_function_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/btrace.h:186:25: note: in instantiation of template class 'enum_flags<btrace_function_flag>' requested here
  186 |   btrace_function_flags flags = 0;
      |                         ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 3] for the enumeration type 'btrace_function_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<btrace_insn_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/btrace.h:81:21: note: in instantiation of template class 'enum_flags<btrace_insn_flag>' requested here
   81 |   btrace_insn_flags flags;
      |                     ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 1] for the enumeration type 'btrace_insn_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<domain_search_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:31: note: in instantiation of template class 'enum_flags<domain_search_flag>' requested here
  920 | constexpr domain_search_flags SEARCH_ALL_DOMAINS
      |                               ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 255] for the enumeration type 'domain_search_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<btrace_function_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/btrace.h:186:25: note: in instantiation of template class 'enum_flags<btrace_function_flag>' requested here
  186 |   btrace_function_flags flags = 0;
      |                         ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 3] for the enumeration type 'btrace_function_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/probe.c:20:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/probe.h:23:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:31: error: constexpr variable 'SEARCH_ALL_DOMAINS' must be initialized by a constant expression
  920 | constexpr domain_search_flags SEARCH_ALL_DOMAINS
      |                               ^
  921 |     = ((domain_search_flags) 0
      |       ~~~~~~~~~~~~~~~~~~~~~~~~
  922 | #define SYM_DOMAIN(X) | SEARCH_ ## X ## _DOMAIN
      | ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  923 | #include "sym-domains.def"
      | ~~~~~~~~~~~~~~~~~~~~~~~~~~
  924 | #undef SYM_DOMAIN
      | ~~~~~~~~~~~~~~~~~
  925 |        );
      |        ~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:961:16: error: static assertion expression is not an integral constant expression
  961 | static_assert (SCRIPTING_SEARCH_FLAG > SEARCH_ALL_DOMAINS);
      |                ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:961:40: note: initializer of 'SEARCH_ALL_DOMAINS' is not a constant expression
  961 | static_assert (SCRIPTING_SEARCH_FLAG > SEARCH_ALL_DOMAINS);
      |                                        ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:31: note: declared here
  920 | constexpr domain_search_flags SEARCH_ALL_DOMAINS
      |                               ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<btrace_insn_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/btrace.h:81:21: note: in instantiation of template class 'enum_flags<btrace_insn_flag>' requested here
   81 |   btrace_insn_flags flags;
      |                     ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 1] for the enumeration type 'btrace_insn_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<domain_search_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:31: note: in instantiation of template class 'enum_flags<domain_search_flag>' requested here
  920 | constexpr domain_search_flags SEARCH_ALL_DOMAINS
      |                               ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 255] for the enumeration type 'domain_search_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<btrace_function_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/btrace.h:186:25: note: in instantiation of template class 'enum_flags<btrace_function_flag>' requested here
  186 |   btrace_function_flags flags = 0;
      |                         ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 3] for the enumeration type 'btrace_function_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/process-stratum-target.c:20:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/process-stratum-target.h:23:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/target.h:68:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/infrun.h:21:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/gdbthread.h:26:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/breakpoint.h:23:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/value.h:1035:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:31: error: constexpr variable 'SEARCH_ALL_DOMAINS' must be initialized by a constant expression
  920 | constexpr domain_search_flags SEARCH_ALL_DOMAINS
      |                               ^
  921 |     = ((domain_search_flags) 0
      |       ~~~~~~~~~~~~~~~~~~~~~~~~
  922 | #define SYM_DOMAIN(X) | SEARCH_ ## X ## _DOMAIN
      | ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  923 | #include "sym-domains.def"
      | ~~~~~~~~~~~~~~~~~~~~~~~~~~
  924 | #undef SYM_DOMAIN
      | ~~~~~~~~~~~~~~~~~
  925 |        );
      |        ~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:961:16: error: static assertion expression is not an integral constant expression
  961 | static_assert (SCRIPTING_SEARCH_FLAG > SEARCH_ALL_DOMAINS);
      |                ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:961:40: note: initializer of 'SEARCH_ALL_DOMAINS' is not a constant expression
  961 | static_assert (SCRIPTING_SEARCH_FLAG > SEARCH_ALL_DOMAINS);
      |                                        ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/symtab.h:920:31: note: declared here
  920 | constexpr domain_search_flags SEARCH_ALL_DOMAINS
      |                               ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<btrace_insn_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/btrace.h:81:21: note: in instantiation of template class 'enum_flags<btrace_insn_flag>' requested here
   81 |   btrace_insn_flags flags;
      |                     ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 1] for the enumeration type 'btrace_insn_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<btrace_insn_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/btrace.h:81:21: note: in instantiation of template class 'enum_flags<btrace_insn_flag>' requested here
   81 |   btrace_insn_flags flags;
      |                     ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 1] for the enumeration type 'btrace_insn_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<btrace_function_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/btrace.h:186:25: note: in instantiation of template class 'enum_flags<btrace_function_flag>' requested here
  186 |   btrace_function_flags flags = 0;
      |                         ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 3] for the enumeration type 'btrace_function_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<btrace_function_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/btrace.h:186:25: note: in instantiation of template class 'enum_flags<btrace_function_flag>' requested here
  186 |   btrace_function_flags flags = 0;
      |                         ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 3] for the enumeration type 'btrace_function_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<btrace_insn_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/btrace.h:81:21: note: in instantiation of template class 'enum_flags<btrace_insn_flag>' requested here
   81 |   btrace_insn_flags flags;
      |                     ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 1] for the enumeration type 'btrace_insn_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<btrace_function_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/btrace.h:186:25: note: in instantiation of template class 'enum_flags<btrace_function_flag>' requested here
  186 |   btrace_function_flags flags = 0;
      |                         ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 3] for the enumeration type 'btrace_function_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
In file included from <built-in>:1:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/defs.h:63:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<innermost_block_tracker_type>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/expression.h:279:33: note: in instantiation of template class 'enum_flags<innermost_block_tracker_type>' requested here
  279 |   innermost_block_tracker_types m_types;
      |                                 ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 3] for the enumeration type 'innermost_block_tracker_type'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<parser_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/expression.h:317:25: note: in instantiation of template class 'enum_flags<parser_flag>' requested here
  317 |                                        parser_flags flags = 0);
      |                                                     ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 15] for the enumeration type 'parser_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
In file included from <built-in>:1:
In file included from /Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/defs.h:63:
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<innermost_block_tracker_type>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/expression.h:279:33: note: in instantiation of template class 'enum_flags<innermost_block_tracker_type>' requested here
  279 |   innermost_block_tracker_types m_types;
      |                                 ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 3] for the enumeration type 'innermost_block_tracker_type'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<parser_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/expression.h:317:25: note: in instantiation of template class 'enum_flags<parser_flag>' requested here
  317 |                                        parser_flags flags = 0);
      |                                                     ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 15] for the enumeration type 'parser_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<btrace_insn_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/btrace.h:81:21: note: in instantiation of template class 'enum_flags<btrace_insn_flag>' requested here
   81 |   btrace_insn_flags flags;
      |                     ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 1] for the enumeration type 'btrace_insn_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<btrace_function_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/btrace.h:186:25: note: in instantiation of template class 'enum_flags<btrace_function_flag>' requested here
  186 |   btrace_function_flags flags = 0;
      |                         ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 3] for the enumeration type 'btrace_function_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<btrace_insn_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/btrace.h:81:21: note: in instantiation of template class 'enum_flags<btrace_insn_flag>' requested here
   81 |   btrace_insn_flags flags;
      |                     ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 1] for the enumeration type 'btrace_insn_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:34: error: non-type template argument is not a constant expression
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:134:20: note: in instantiation of template class 'enum_underlying_type<btrace_function_flag>' requested here
  134 |   typedef typename enum_underlying_type<enum_type>::type underlying_type;
      |                    ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/btrace.h:186:25: note: in instantiation of template class 'enum_flags<btrace_function_flag>' requested here
  186 |   btrace_function_flags flags = 0;
      |                         ^
/Users/ilg/Work/xpack-dev-tools/aarch64-none-elf-gcc-xpack.git/build-assets/build/darwin-x64/sources/binutils-gdb-gdb-15-arm-none-eabi-14.2.rel1/gdb/../gdbsupport/enum-flags.h:97:52: note: integer value -1 is outside the valid range of values [0, 3] for the enumeration type 'btrace_function_flag'
   97 |     integer_for_size<sizeof (T), static_cast<bool>(T (-1) < T (0))>::type
      |                                                    ^
8 errors generated.
make[1]: *** [p-typeprint.o] Error 1
make[1]: *** Waiting for unfinished jobs....
8 errors generated.
make[1]: *** [posix-hdep.o] Error 1
8 errors generated.
make[1]: *** [p-valprint.o] Error 1
8 errors generated.
make[1]: *** [process-stratum-target.o] Error 1
8 errors generated.
make[1]: *** [p-lang.o] Error 1
8 errors generated.
make[1]: *** [probe.o] Error 1
8 errors generated.
make[1]: *** [parse.o] Error 1
8 errors generated.
make[1]: *** [printcmd.o] Error 1
make: *** [all-gdb] Error 2
```
