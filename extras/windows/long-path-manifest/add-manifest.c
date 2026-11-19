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
 * Embed an application manifest (RT_MANIFEST, ID 1) into existing
 * Windows executables, using the Win32 resource update API.
 *
 * Intended to run under Wine during the xPack post-processing step.
 * It does the same as `mt.exe -manifest m -outputresource:x.exe;1`,
 * except that executables that already have a manifest are left
 * untouched (reported as skipped).
 *
 * Usage:
 *   add-manifest.exe <manifest-file> <exe-file>...
 *
 * Exit code:
 *   0 - all files were updated or skipped
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

/* CREATEPROCESS_MANIFEST_RESOURCE_ID */
#define MANIFEST_RESOURCE_ID 1
/* RT_MANIFEST, explicitly in its wide form. */
#define MANIFEST_RESOURCE_TYPE MAKEINTRESOURCEW (24)

/* Sanity limit for the manifest size. */
#define MAX_MANIFEST_SIZE (64 * 1024)

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

static BOOL CALLBACK
found_manifest (HMODULE module, LPCWSTR type, LPWSTR name, LONG_PTR param)
{
  (void)module;
  (void)type;
  (void)name;

  *(BOOL*)param = TRUE;
  return FALSE; /* One is enough, stop the enumeration. */
}

/*
 * Return 1 if the file has any RT_MANIFEST resource (any ID, any
 * language), 0 if it has none, -1 if the file cannot be loaded.
 */
static int
has_manifest (const wchar_t* path)
{
  HMODULE module = LoadLibraryExW (path, NULL, LOAD_LIBRARY_AS_DATAFILE);
  if (module == NULL)
    {
      print_error (L"LoadLibraryEx", path);
      return -1;
    }

  BOOL found = FALSE;
  /* The return value is irrelevant: it is FALSE both when there are
     no manifests and when the callback stops the enumeration. */
  EnumResourceNamesW (module, MANIFEST_RESOURCE_TYPE, found_manifest,
                      (LONG_PTR)&found);

  /* Must be released before BeginUpdateResource() opens the file. */
  FreeLibrary (module);

  return found ? 1 : 0;
}

/* Return 0 on success (updated or skipped), 1 on failure. */
static int
add_manifest (const wchar_t* path, void* data, DWORD size)
{
  int has = has_manifest (path);
  if (has < 0)
    {
      return 1;
    }
  if (has > 0)
    {
      wprintf (L"%ls: already has a manifest, skipped\n", path);
      return 0;
    }

  HANDLE h = BeginUpdateResourceW (path, FALSE);
  if (h == NULL)
    {
      print_error (L"BeginUpdateResource", path);
      return 1;
    }

  if (!UpdateResourceW (h, MANIFEST_RESOURCE_TYPE,
                        MAKEINTRESOURCEW (MANIFEST_RESOURCE_ID),
                        MAKELANGID (LANG_NEUTRAL, SUBLANG_NEUTRAL), data,
                        size))
    {
      print_error (L"UpdateResource", path);
      EndUpdateResourceW (h, TRUE); /* Discard. */
      return 1;
    }

  if (!EndUpdateResourceW (h, FALSE))
    {
      print_error (L"EndUpdateResource", path);
      return 1;
    }

  /* Read it back, to be sure the image was actually rewritten. */
  if (has_manifest (path) != 1)
    {
      fwprintf (stderr, L"add-manifest: '%ls' has no manifest after update\n",
                path);
      return 1;
    }

  wprintf (L"%ls: manifest added\n", path);
  return 0;
}

int
wmain (int argc, wchar_t* argv[])
{
  if (argc < 3)
    {
      fwprintf (stderr, L"Usage: %ls <manifest-file> <exe-file>...\n",
                argv[0]);
      return 2;
    }

  DWORD size = 0;
  void* data = read_file (argv[1], &size);
  if (data == NULL)
    {
      return 2;
    }

  int failed = 0;
  for (int i = 2; i < argc; ++i)
    {
      failed |= add_manifest (argv[i], data, size);
    }

  free (data);
  return failed ? 1 : 0;
}
