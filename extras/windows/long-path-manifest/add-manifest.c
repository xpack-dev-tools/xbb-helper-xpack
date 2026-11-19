/*
 * This file is part of the xPack project (http://xpack.github.io).
 * Copyright (c) 2026 Liviu Ionescu. All rights reserved.
 *
 * Permission to use, copy, modify, and/or distribute this software
 * for any purpose is hereby granted, under the terms of the MIT license.
 *
 * If a copy of the license was not distributed with this file, it can
 * be obtained from https://opensource.org/licenses/mit.
 */

/*
 * Make existing Windows executables long path aware, by embedding an
 * application manifest (RT_MANIFEST, ID 1) that declares
 * longPathAware=true, using the Win32 resource update API.
 *
 * Intended to run under Wine during the xPack post-processing step.
 *
 * For each executable:
 * - without a manifest, the given manifest file is embedded;
 * - with a manifest that already declares longPathAware=true (for example
 *   a hard link to a file processed before), nothing is changed;
 * - with another manifest (for example the UTF-8 activeCodePage manifest
 *   that GCC 13+ embeds in its drivers and compilers), the longPathAware
 *   element is merged into it, preserving the existing settings.
 *
 * Usage:
 *   add-manifest.exe <manifest-file> <exe-file>...
 *   add-manifest.exe --check <exe-file>...
 *       (only verify that each file declares longPathAware=true)
 *
 * Exit code:
 *   0 - all files were updated, already up to date, or passed the check
 *   1 - at least one file failed
 *   2 - usage error or unreadable manifest
 *
 * Build:
 *   x86_64-w64-mingw32-gcc -O2 -municode -static \
 *     -o add-manifest.exe add-manifest.c
 */

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* CREATEPROCESS_MANIFEST_RESOURCE_ID, the one used for the process. */
#define MANIFEST_RESOURCE_ID 1
/* RT_MANIFEST, explicitly in its wide form. */
#define MANIFEST_RESOURCE_TYPE MAKEINTRESOURCEW (24)

/* Sanity limit for the manifest size. */
#define MAX_MANIFEST_SIZE (64 * 1024)

/* The element merged into existing manifests. */
#define LONG_PATH_AWARE_ELEMENT                                               \
  "<longPathAware "                                                           \
  "xmlns=\"http://schemas.microsoft.com/SMI/2016/WindowsSettings\">"          \
  "true</longPathAware>"

typedef struct
{
  char* data; /* NUL terminated copy. */
  DWORD size; /* Without the terminator. */
  WORD lang;
} manifest_t;

static void
print_error (const wchar_t* what, const wchar_t* path)
{
  DWORD err = GetLastError ();
  wchar_t* msg = NULL;

  FormatMessageW (FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM
                      | FORMAT_MESSAGE_IGNORE_INSERTS,
                  NULL, err, 0, (LPWSTR)&msg, 0, NULL);

  fwprintf (stderr, L"add-manifest: %ls '%ls' failed, error %lu: %ls",
            what, path, (unsigned long)err, msg ? msg : L"\n");

  if (msg)
    {
      LocalFree (msg);
    }
}

static void*
read_file (const wchar_t* path, DWORD* size)
{
  HANDLE h = CreateFileW (path, GENERIC_READ, FILE_SHARE_READ, NULL,
                          OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
  if (h == INVALID_HANDLE_VALUE)
    {
      print_error (L"open", path);
      return NULL;
    }

  LARGE_INTEGER li;
  if (!GetFileSizeEx (h, &li))
    {
      print_error (L"GetFileSizeEx", path);
      CloseHandle (h);
      return NULL;
    }

  if (li.QuadPart <= 0 || li.QuadPart > MAX_MANIFEST_SIZE)
    {
      fwprintf (stderr, L"add-manifest: '%ls' has an unexpected size\n",
                path);
      CloseHandle (h);
      return NULL;
    }

  DWORD len = (DWORD)li.QuadPart;
  void* buf = malloc (len);
  if (buf == NULL)
    {
      fwprintf (stderr, L"add-manifest: out of memory\n");
      CloseHandle (h);
      return NULL;
    }

  DWORD got = 0;
  if (!ReadFile (h, buf, len, &got, NULL) || got != len)
    {
      print_error (L"read", path);
      free (buf);
      CloseHandle (h);
      return NULL;
    }

  CloseHandle (h);
  *size = len;
  return buf;
}

/* Like strstr(), but limited to `len` bytes, which may include NULs. */
static char*
find_text (char* hay, size_t len, const char* needle)
{
  size_t n = strlen (needle);
  if (n == 0 || n > len)
    {
      return NULL;
    }
  for (size_t i = 0; i + n <= len; ++i)
    {
      if (hay[i] == needle[0] && memcmp (hay + i, needle, n) == 0)
        {
          return hay + i;
        }
    }
  return NULL;
}

typedef struct
{
  int count;
  WORD lang;
} languages_t;

static BOOL CALLBACK
found_language (HMODULE module, LPCWSTR type, LPCWSTR name, WORD lang,
                LONG_PTR param)
{
  (void)module;
  (void)type;
  (void)name;

  languages_t* langs = (languages_t*)param;
  if (langs->count == 0)
    {
      langs->lang = lang;
    }
  ++langs->count;
  return TRUE;
}

/*
 * Read the process manifest (RT_MANIFEST, ID 1).
 * Return 1 if found (the caller must free m->data), 0 if there is none,
 * -1 on error.
 */
static int
get_manifest (const wchar_t* path, manifest_t* m)
{
  memset (m, 0, sizeof (*m));

  HMODULE module = LoadLibraryExW (path, NULL, LOAD_LIBRARY_AS_DATAFILE);
  if (module == NULL)
    {
      print_error (L"LoadLibraryEx", path);
      return -1;
    }

  int ret = 0;
  languages_t langs = { 0, 0 };
  /* The return value is irrelevant, FALSE also means not found. */
  EnumResourceLanguagesW (module, MANIFEST_RESOURCE_TYPE,
                          MAKEINTRESOURCEW (MANIFEST_RESOURCE_ID),
                          found_language, (LONG_PTR)&langs);

  if (langs.count > 1)
    {
      fwprintf (stderr,
                L"add-manifest: '%ls' has %d manifests with ID 1 "
                L"(different languages), not supported\n",
                path, langs.count);
      ret = -1;
    }
  else if (langs.count == 1)
    {
      HRSRC res
          = FindResourceExW (module, MANIFEST_RESOURCE_TYPE,
                             MAKEINTRESOURCEW (MANIFEST_RESOURCE_ID),
                             langs.lang);
      HGLOBAL g = res ? LoadResource (module, res) : NULL;
      const void* p = g ? LockResource (g) : NULL;
      DWORD size = res ? SizeofResource (module, res) : 0;

      if (p == NULL || size == 0 || size > MAX_MANIFEST_SIZE)
        {
          print_error (L"LoadResource", path);
          ret = -1;
        }
      else if ((m->data = malloc (size + 1)) == NULL)
        {
          fwprintf (stderr, L"add-manifest: out of memory\n");
          ret = -1;
        }
      else
        {
          memcpy (m->data, p, size);
          m->data[size] = '\0';
          m->size = size;
          m->lang = langs.lang;
          ret = 1;
        }
    }

  /* Must be released before BeginUpdateResource() opens the file. */
  FreeLibrary (module);
  return ret;
}

/*
 * Return 1 if the manifest has a longPathAware element with the value
 * true (any namespace prefix), 0 if it has none, -1 if it has one with
 * another value.
 */
static int
declares_long_path_aware (const manifest_t* m)
{
  char* p = find_text (m->data, m->size, "longPathAware");
  if (p == NULL)
    {
      return 0;
    }

  /* Skip the rest of the start tag, then any white space. */
  char* end = m->data + m->size;
  while (p < end && *p != '>')
    {
      ++p;
    }
  if (p < end)
    {
      ++p;
    }
  while (p < end && (*p == ' ' || *p == '\t' || *p == '\r' || *p == '\n'))
    {
      ++p;
    }

  if (end - p >= 4 && _strnicmp (p, "true", 4) == 0)
    {
      return 1;
    }
  return -1;
}

/* Return a new buffer with `text` inserted before `where`. */
static char*
insert_text (const manifest_t* m, const char* where, const char* text,
             DWORD* new_size)
{
  size_t head = (size_t)(where - m->data);
  size_t ins = strlen (text);
  size_t tail = m->size - head;

  char* buf = malloc (head + ins + tail + 1);
  if (buf == NULL)
    {
      fwprintf (stderr, L"add-manifest: out of memory\n");
      return NULL;
    }
  memcpy (buf, m->data, head);
  memcpy (buf + head, text, ins);
  memcpy (buf + head + ins, where, tail);
  buf[head + ins + tail] = '\0';

  *new_size = (DWORD)(head + ins + tail);
  return buf;
}

/*
 * Add the longPathAware element to an existing manifest. Only the
 * unprefixed layouts are handled; anything else is reported, not guessed.
 * Return the new buffer, or NULL on failure.
 */
static char*
merge_manifest (const wchar_t* path, const manifest_t* m, DWORD* new_size)
{
  if (m->size >= 2
      && ((m->data[0] == '\xFF' && m->data[1] == '\xFE')
          || (m->data[0] == '\xFE' && m->data[1] == '\xFF')))
    {
      fwprintf (stderr,
                L"add-manifest: '%ls' has an UTF-16 manifest, "
                L"not supported\n",
                path);
      return NULL;
    }

  char* p;
  if ((p = find_text (m->data, m->size, "</windowsSettings>")) != NULL)
    {
      return insert_text (m, p, "  " LONG_PATH_AWARE_ELEMENT "\n    ",
                          new_size);
    }
  if (find_text (m->data, m->size, "windowsSettings") != NULL)
    {
      /* Prefixed or empty (<windowsSettings/>) element. */
      fwprintf (stderr,
                L"add-manifest: '%ls' has a windowsSettings element "
                L"in an unsupported form\n",
                path);
      return NULL;
    }

  if ((p = find_text (m->data, m->size, "</application>")) != NULL)
    {
      return insert_text (m, p,
                          "  <windowsSettings>\n      " LONG_PATH_AWARE_ELEMENT
                          "\n    </windowsSettings>\n  ",
                          new_size);
    }
  if (find_text (m->data, m->size, "application") != NULL)
    {
      fwprintf (stderr,
                L"add-manifest: '%ls' has an application element "
                L"in an unsupported form\n",
                path);
      return NULL;
    }

  if ((p = find_text (m->data, m->size, "</assembly>")) != NULL)
    {
      return insert_text (
          m, p,
          "  <application xmlns=\"urn:schemas-microsoft-com:asm.v3\">\n"
          "    <windowsSettings>\n      " LONG_PATH_AWARE_ELEMENT "\n"
          "    </windowsSettings>\n  </application>\n",
          new_size);
    }

  fwprintf (stderr,
            L"add-manifest: '%ls' has a manifest without "
            L"</assembly>, not supported\n",
            path);
  return NULL;
}

/*
 * COFF symbol table handling.
 *
 * Stripped mingw-w64 executables may still have a COFF symbol table
 * (followed by its string table) after the last section. When
 * EndUpdateResource() grows a .rsrc section that is not the last one,
 * Wine moves the following sections and the symbol table, but does not
 * update PointerToSymbolTable in the COFF header. Windows ignores the
 * symbol table, but objdump and gdb complain ("file truncated"), so
 * the pointer is repaired here.
 */

/* The PE format allows at most 96 sections. */
#define MAX_SECTIONS 96

typedef struct
{
  LONGLONG file_size;
  DWORD psym_field_offset; /* File offset of PointerToSymbolTable. */
  DWORD psym;
  DWORD nsym;
  DWORD raw_end; /* End of the last section raw data. */
  WORD nsec;
  DWORD raw_ptr[MAX_SECTIONS];
  DWORD raw_size[MAX_SECTIONS];
} coff_info_t;

static int
read_at (HANDLE h, LONGLONG offset, void* buf, DWORD len)
{
  LARGE_INTEGER li;
  li.QuadPart = offset;
  DWORD got = 0;
  return SetFilePointerEx (h, li, NULL, FILE_BEGIN)
         && ReadFile (h, buf, len, &got, NULL) && got == len;
}

/* Return 1 on success, 0 on failure (already reported). */
static int
get_coff_info (const wchar_t* path, HANDLE h, coff_info_t* ci)
{
  memset (ci, 0, sizeof (*ci));

  LARGE_INTEGER li;
  if (!GetFileSizeEx (h, &li))
    {
      print_error (L"GetFileSizeEx", path);
      return 0;
    }
  ci->file_size = li.QuadPart;

  DWORD pe = 0;
  BYTE sig[4];
  /* COFF file header fields. */
  WORD nsec = 0;
  WORD optsz = 0;
  if (!read_at (h, 0x3C, &pe, 4) || !read_at (h, pe, sig, 4)
      || memcmp (sig, "PE\0\0", 4) != 0 || !read_at (h, pe + 6, &nsec, 2)
      || !read_at (h, pe + 12, &ci->psym, 4)
      || !read_at (h, pe + 16, &ci->nsym, 4)
      || !read_at (h, pe + 20, &optsz, 2))
    {
      fwprintf (stderr, L"add-manifest: '%ls' has an invalid PE header\n",
                path);
      return 0;
    }
  ci->psym_field_offset = pe + 12;

  if (nsec > MAX_SECTIONS)
    {
      fwprintf (stderr, L"add-manifest: '%ls' has too many sections\n",
                path);
      return 0;
    }
  ci->nsec = nsec;

  DWORD sections = pe + 24 + optsz;
  for (WORD i = 0; i < nsec; ++i)
    {
      DWORD raw[2]; /* SizeOfRawData, PointerToRawData */
      if (!read_at (h, sections + 40 * i + 16, raw, sizeof (raw)))
        {
          fwprintf (stderr,
                    L"add-manifest: '%ls' has an invalid section table\n",
                    path);
          return 0;
        }
      ci->raw_size[i] = raw[0];
      ci->raw_ptr[i] = raw[1];
      if (raw[0] != 0 && raw[1] + raw[0] > ci->raw_end)
        {
          ci->raw_end = raw[1] + raw[0];
        }
    }
  return 1;
}

/*
 * A symbol table at `offset` must be followed by a string table that
 * fits in the file, and the two must not overlap any section raw data.
 * Wine may place a new .rsrc section after the symbol table, so it is
 * not necessarily after the last section.
 */
static int
symbol_table_valid_at (HANDLE h, const coff_info_t* ci, DWORD offset)
{
  LONGLONG str_offset = (LONGLONG)offset + (LONGLONG)ci->nsym * 18;
  DWORD str_size = 0;
  if (str_offset + 4 > ci->file_size
      || !read_at (h, str_offset, &str_size, 4))
    {
      return 0;
    }
  LONGLONG end = str_offset + str_size;
  if (str_size < 4 || end > ci->file_size)
    {
      return 0;
    }

  for (WORD i = 0; i < ci->nsec; ++i)
    {
      LONGLONG start = ci->raw_ptr[i];
      LONGLONG stop = start + ci->raw_size[i];
      if (ci->raw_size[i] != 0 && (LONGLONG)offset < stop && end > start)
        {
          return 0;
        }
    }
  return 1;
}

/*
 * Check the COFF symbol table pointer; if `repair`, re-point it to the
 * end of the last section when a valid table is found there.
 * Return 1 if the pointer is (now) valid or there is no table, 0 if not.
 */
static int
check_symbol_table (const wchar_t* path, int repair)
{
  HANDLE h = CreateFileW (path, GENERIC_READ | (repair ? GENERIC_WRITE : 0),
                          FILE_SHARE_READ, NULL, OPEN_EXISTING,
                          FILE_ATTRIBUTE_NORMAL, NULL);
  if (h == INVALID_HANDLE_VALUE)
    {
      print_error (L"open", path);
      return 0;
    }

  coff_info_t ci;
  int ok = get_coff_info (path, h, &ci);
  if (ok && ci.psym != 0 && ci.nsym != 0
      && !symbol_table_valid_at (h, &ci, ci.psym))
    {
      ok = 0;
      if (repair && symbol_table_valid_at (h, &ci, ci.raw_end))
        {
          LARGE_INTEGER li;
          li.QuadPart = ci.psym_field_offset;
          DWORD written = 0;
          if (SetFilePointerEx (h, li, NULL, FILE_BEGIN)
              && WriteFile (h, &ci.raw_end, 4, &written, NULL)
              && written == 4)
            {
              wprintf (L"%ls: COFF symbol table pointer moved from "
                       L"0x%lx to 0x%lx\n",
                       path, (unsigned long)ci.psym,
                       (unsigned long)ci.raw_end);
              ok = 1;
            }
          else
            {
              print_error (L"write", path);
            }
        }
      if (!ok)
        {
          fwprintf (stderr,
                    L"add-manifest: '%ls' has an invalid COFF symbol "
                    L"table pointer (0x%lx)\n",
                    path, (unsigned long)ci.psym);
        }
    }

  CloseHandle (h);
  return ok;
}

static int
write_manifest (const wchar_t* path, WORD lang, void* data, DWORD size)
{
  HANDLE h = BeginUpdateResourceW (path, FALSE);
  if (h == NULL)
    {
      print_error (L"BeginUpdateResource", path);
      return 0;
    }

  /* The same ID and language replaces the existing resource. */
  if (!UpdateResourceW (h, MANIFEST_RESOURCE_TYPE,
                        MAKEINTRESOURCEW (MANIFEST_RESOURCE_ID), lang, data,
                        size))
    {
      print_error (L"UpdateResource", path);
      EndUpdateResourceW (h, TRUE); /* Discard. */
      return 0;
    }

  if (!EndUpdateResourceW (h, FALSE))
    {
      print_error (L"EndUpdateResource", path);
      return 0;
    }

  return check_symbol_table (path, 1);
}

/* Return 0 if the file declares longPathAware=true, 1 otherwise. */
static int
check_file (const wchar_t* path, int quiet)
{
  manifest_t m;
  int has = get_manifest (path, &m);
  if (has < 0)
    {
      return 1;
    }
  if (has == 0)
    {
      fwprintf (stderr, L"add-manifest: '%ls' has no manifest\n", path);
      return 1;
    }

  int lpa = declares_long_path_aware (&m);
  free (m.data);

  if (lpa != 1)
    {
      fwprintf (stderr,
                L"add-manifest: '%ls' manifest does not declare "
                L"longPathAware=true\n",
                path);
      return 1;
    }
  if (!check_symbol_table (path, 0))
    {
      return 1;
    }
  if (!quiet)
    {
      wprintf (L"%ls: longPathAware\n", path);
    }
  return 0;
}

/* Return 0 on success (updated or already up to date), 1 on failure. */
static int
process_file (const wchar_t* path, void* data, DWORD size)
{
  manifest_t m;
  int has = get_manifest (path, &m);
  if (has < 0)
    {
      return 1;
    }

  const wchar_t* action;
  if (has == 0)
    {
      if (!write_manifest (path, MAKELANGID (LANG_NEUTRAL, SUBLANG_NEUTRAL),
                           data, size))
        {
          return 1;
        }
      action = L"manifest added";
    }
  else
    {
      int lpa = declares_long_path_aware (&m);
      if (lpa == 1)
        {
          free (m.data);
          /* Also repairs files updated by older versions of this tool. */
          if (!check_symbol_table (path, 1))
            {
              return 1;
            }
          wprintf (L"%ls: already longPathAware, skipped\n", path);
          return 0;
        }
      if (lpa < 0)
        {
          free (m.data);
          fwprintf (stderr,
                    L"add-manifest: '%ls' explicitly declares longPathAware "
                    L"with a value other than true, not changed\n",
                    path);
          return 1;
        }

      DWORD new_size = 0;
      char* merged = merge_manifest (path, &m, &new_size);
      WORD lang = m.lang;
      free (m.data);
      if (merged == NULL)
        {
          return 1;
        }

      int ok = write_manifest (path, lang, merged, new_size);
      free (merged);
      if (!ok)
        {
          return 1;
        }
      action = L"longPathAware merged into the existing manifest";
    }

  /* Read it back, to be sure the image was actually rewritten. */
  if (check_file (path, 1) != 0)
    {
      fwprintf (stderr, L"add-manifest: '%ls' verification after update "
                        L"failed\n",
                path);
      return 1;
    }

  wprintf (L"%ls: %ls\n", path, action);
  return 0;
}

int
wmain (int argc, wchar_t* argv[])
{
  if (argc < 3)
    {
      fwprintf (stderr,
                L"Usage: %ls <manifest-file> <exe-file>...\n"
                L"       %ls --check <exe-file>...\n",
                argv[0], argv[0]);
      return 2;
    }

  int failed = 0;

  if (wcscmp (argv[1], L"--check") == 0)
    {
      for (int i = 2; i < argc; ++i)
        {
          failed |= check_file (argv[i], 1);
        }
      if (!failed)
        {
          wprintf (L"%d files checked, all declare longPathAware\n",
                   argc - 2);
        }
      return failed ? 1 : 0;
    }

  DWORD size = 0;
  void* data = read_file (argv[1], &size);
  if (data == NULL)
    {
      return 2;
    }

  for (int i = 2; i < argc; ++i)
    {
      failed |= process_file (argv[i], data, size);
    }

  free (data);
  return failed ? 1 : 0;
}
