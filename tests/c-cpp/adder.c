/*
 * This file is part of the xPack project (http://xpack.github.io).
 * Copyright (c) 2020 Liviu Ionescu. All rights reserved.
 *
 * Permission to use, copy, modify, and/or distribute this software
 * for any purpose is hereby granted, under the terms of the MIT license.
 *
 * If a copy of the license was not distributed with this file, it can
 * be obtained from https://opensource.org/licenses/mit/.
 */

#include <stdio.h>
#include <stdlib.h>

extern int
#if defined(_WIN32)
__declspec(dllimport)
#endif
add(int a, int b);

int
main(int argc, char* argv[])
{
  int sum = atoi(argv[1]) + atoi(argv[2]);
  printf("%d\n", sum);

  return 0;
}
