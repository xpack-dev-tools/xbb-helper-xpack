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
 * Check whether long path support is active for this process.
 *
 * RtlAreLongPathsEnabled() (ntdll, Windows 10 1607+) returns TRUE only
 * if both the registry setting
 *   HKLM\SYSTEM\CurrentControlSet\Control\FileSystem\LongPathsEnabled
 * is 1 and the process manifest declares longPathAware=true.
 *
 * With --deep, it also creates a folder tree longer than MAX_PATH under
 * %TEMP%, using plain paths (no \\?\ prefix), makes it the current
 * folder and starts a program there. This is what Ninja does when it
 * fails with "CreateProcess: The parameter is incorrect".
 *
 * Usage:
 *   long-path-check.exe
 *   long-path-check.exe --deep
 *       (the started program is a copy of itself)
 *   long-path-check.exe --deep <program> [args...]
 *       (for example riscv-none-elf-gcc.exe --version)
 *
 * Exit code: 0 if long paths are enabled (and the deep test passed),
 * 1 otherwise.
 *
 * Build:
 *   x86_64-w64-mingw32-gcc -O2 -municode -static \
 *     -o long-path-check.exe long-path-check.c
 * then embed the manifest with add-manifest.exe; keep a copy without
 * the manifest for comparison (it should report FALSE).
 */

#define _WIN32_WINNT 0x0A00
#define WIN32_LEAN_AND_MEAN
#include <windows.h>

#include <stdio.h>
#include <string.h>
#include <wchar.h>

#define MANIFEST_RESOURCE_TYPE MAKEINTRESOURCEW (24)

/* Large enough for the deep tree and for the child command line. */
#define BUF_LEN 4096
/* Total length of the deep folder path; well above MAX_PATH (260). */
#define DEEP_PATH_LEN 320
#define DEEP_COMPONENT L"\\long-path-check-0123456789-0123456789"

typedef BOOLEAN (NTAPI* rtl_are_long_paths_enabled_t) (void);

static void
print_error (const wchar_t* what)
{
  DWORD err = GetLastError ();
  wchar_t* msg = NULL;

  FormatMessageW (FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM
                      | FORMAT_MESSAGE_IGNORE_INSERTS,
                  NULL, err, 0, (LPWSTR)&msg, 0, NULL);

  wprintf (L"    %ls failed, error %lu: %ls", what, (unsigned long)err,
           msg ? msg : L"\n");

  if (msg)
    {
      LocalFree (msg);
    }
}

static BOOL CALLBACK
found_manifest (HMODULE module, LPCWSTR type, LPWSTR name, LONG_PTR param)
{
  (void)module;
  (void)type;
  (void)name;

  *(BOOL*)param = TRUE;
  return FALSE;
}

static int
basic_checks (void)
{
  DWORD value = 0;
  DWORD size = sizeof (value);
  LSTATUS status = RegGetValueW (
      HKEY_LOCAL_MACHINE, L"SYSTEM\\CurrentControlSet\\Control\\FileSystem",
      L"LongPathsEnabled", RRF_RT_REG_DWORD, NULL, &value, &size);
  if (status == ERROR_SUCCESS)
    {
      wprintf (L"  registry LongPathsEnabled:  %lu\n", (unsigned long)value);
    }
  else
    {
      wprintf (L"  registry LongPathsEnabled:  not set\n");
    }

  BOOL found = FALSE;
  EnumResourceNamesW (GetModuleHandleW (NULL), MANIFEST_RESOURCE_TYPE,
                      found_manifest, (LONG_PTR)&found);
  wprintf (L"  embedded manifest:          %ls\n", found ? L"yes" : L"no");

  rtl_are_long_paths_enabled_t fn
      = (rtl_are_long_paths_enabled_t)(void*)GetProcAddress (
          GetModuleHandleW (L"ntdll.dll"), "RtlAreLongPathsEnabled");
  if (fn == NULL)
    {
      wprintf (L"  RtlAreLongPathsEnabled():   not available "
               L"(older than Windows 10 1607, or Wine)\n");
      return 0;
    }

  BOOLEAN enabled = fn ();
  wprintf (L"  RtlAreLongPathsEnabled():   %ls\n",
           enabled ? L"TRUE" : L"FALSE");
  return enabled ? 1 : 0;
}

/* Append one argument to the command line, quoted if needed. */
static void
append_arg (wchar_t* cmd, const wchar_t* arg)
{
  if (cmd[0] != L'\0')
    {
      wcscat (cmd, L" ");
    }
  if (arg[0] == L'\0' || wcspbrk (arg, L" \t") != NULL)
    {
      wcscat (cmd, L"\"");
      wcscat (cmd, arg);
      wcscat (cmd, L"\"");
    }
  else
    {
      wcscat (cmd, arg);
    }
}

static int
run_child (int argc, wchar_t* argv[])
{
  static wchar_t cmd[BUF_LEN];
  cmd[0] = L'\0';

  size_t total = 0;
  for (int i = 0; i < argc; ++i)
    {
      total += wcslen (argv[i]) + 3;
    }
  if (total >= BUF_LEN)
    {
      wprintf (L"    command line too long\n");
      return 0;
    }
  for (int i = 0; i < argc; ++i)
    {
      append_arg (cmd, argv[i]);
    }

  wprintf (L"  starting: %ls\n", cmd);
  fflush (stdout);

  STARTUPINFOW si;
  PROCESS_INFORMATION pi;
  memset (&si, 0, sizeof (si));
  si.cb = sizeof (si);
  memset (&pi, 0, sizeof (pi));

  /* Inherit the current (long) folder, like Ninja does. */
  if (!CreateProcessW (NULL, cmd, NULL, NULL, TRUE, 0, NULL, NULL, &si,
                       &pi))
    {
      print_error (L"CreateProcess");
      return 0;
    }

  WaitForSingleObject (pi.hProcess, INFINITE);
  DWORD code = 1;
  GetExitCodeProcess (pi.hProcess, &code);
  CloseHandle (pi.hThread);
  CloseHandle (pi.hProcess);

  wprintf (L"  child exit code: %lu\n", (unsigned long)code);
  return code == 0 ? 1 : 0;
}

static int
deep_test (int argc, wchar_t* argv[], const wchar_t* self)
{
  static wchar_t temp[MAX_PATH + 1];
  static wchar_t top[BUF_LEN];
  static wchar_t path[BUF_LEN];

  DWORD n = GetTempPathW (MAX_PATH + 1, temp);
  if (n == 0 || n > MAX_PATH)
    {
      print_error (L"GetTempPath");
      return 0;
    }

  /* GetTempPath() ends with a backslash. */
  swprintf (top, BUF_LEN, L"%lslong-path-check-%lu", temp,
            (unsigned long)GetCurrentProcessId ());
  wcscpy (path, top);

  wprintf (L"\nDeep folder test:\n");

  if (!CreateDirectoryW (top, NULL))
    {
      print_error (L"CreateDirectory");
      return 0;
    }

  int ok = 1;
  int levels = 0;
  while (wcslen (path) < DEEP_PATH_LEN)
    {
      wcscat (path, DEEP_COMPONENT);
      if (!CreateDirectoryW (path, NULL))
        {
          wprintf (L"  path length %zu:\n", wcslen (path));
          print_error (L"CreateDirectory");
          ok = 0;
          /* Remove the component that was not created. */
          *wcsrchr (path, L'\\') = L'\0';
          break;
        }
      ++levels;
    }

  if (ok)
    {
      wprintf (L"  created folder, path length %zu\n", wcslen (path));

      if (!SetCurrentDirectoryW (path))
        {
          print_error (L"SetCurrentDirectory");
          ok = 0;
        }
    }

  if (ok)
    {
      wprintf (L"  current folder changed\n");

      HANDLE h = CreateFileW (L"test.txt", GENERIC_WRITE, 0, NULL,
                              CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
      if (h == INVALID_HANDLE_VALUE)
        {
          print_error (L"CreateFile (relative)");
          ok = 0;
        }
      else
        {
          CloseHandle (h);
          DeleteFileW (L"test.txt");
          wprintf (L"  relative file created and deleted\n");
        }
    }

  if (ok)
    {
      if (argc > 0)
        {
          ok = run_child (argc, argv);
        }
      else
        {
          wchar_t* child_argv[] = { (wchar_t*)self, L"--child" };
          ok = run_child (2, child_argv);
        }
    }

  /* Clean up, deepest first. */
  SetCurrentDirectoryW (temp);
  for (; levels > 0; --levels)
    {
      RemoveDirectoryW (path);
      *wcsrchr (path, L'\\') = L'\0';
    }
  RemoveDirectoryW (top);

  wprintf (L"  deep folder test %ls\n", ok ? L"PASSED" : L"FAILED");
  return ok;
}

int
wmain (int argc, wchar_t* argv[])
{
  if (argc >= 2 && wcscmp (argv[1], L"--child") == 0)
    {
      DWORD len = GetCurrentDirectoryW (0, NULL);
      wprintf (L"  child started, current folder length %lu\n",
               (unsigned long)(len > 0 ? len - 1 : 0));
      return 0;
    }

  static wchar_t self[BUF_LEN];
  DWORD n = GetModuleFileNameW (NULL, self, BUF_LEN);
  if (n == 0 || n >= BUF_LEN)
    {
      wcscpy (self, argv[0]);
    }

  wprintf (L"Windows long path support check (%ls)\n", self);

  int ok = basic_checks ();

  if (argc >= 2 && wcscmp (argv[1], L"--deep") == 0)
    {
      ok = deep_test (argc - 2, argv + 2, self) && ok;
    }

  return ok ? 0 : 1;
}
