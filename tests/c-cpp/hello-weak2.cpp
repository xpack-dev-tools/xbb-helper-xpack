/*
 * This file is part of the xPack project (http://xpack.github.io).
 * Copyright (c) 2022 Liviu Ionescu. All rights reserved.
 *
 * Permission to use, copy, modify, and/or distribute this software
 * for any purpose is hereby granted, under the terms of the MIT license.
 *
 * If a copy of the license was not distributed with this file, it can
 * be obtained from https://opensource.org/licenses/MIT.
 */

#include <iostream>

extern const char* hello();

const char* __attribute__((weak))
world()
{
  return "there";
}

// The test checks if a weak alone is called,
// and if a non-weak overrides the local weak.
int main(int argc, char* argv[]) {
    std::cout << hello() << " " << world() << std::endl;
    return 0;
}
