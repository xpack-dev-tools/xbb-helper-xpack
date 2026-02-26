/*
 * This file is part of the xPack project (http://xpack.github.io).
 * Copyright (c) 2020-2026 Liviu Ionescu. All rights reserved.
 *
 * Permission to use, copy, modify, and/or distribute this software
 * for any purpose is hereby granted, under the terms of the MIT license.
 *
 * If a copy of the license was not distributed with this file, it can
 * be obtained from https://opensource.org/licenses/mit.
 */

#include <iostream>
#include <exception>

void
func(void)
{
  throw "MyStringException";
}

int
main(int argc, char* argv[])
{
  try {
    func();
  } catch(const char* msg) {
    std::cout << msg << std::endl;
  } catch(std::exception& e) {
    std::cout << "Other" << std::endl;
  }

  return 0;
}
