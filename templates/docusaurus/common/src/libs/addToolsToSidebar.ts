/*
 * DO NOT EDIT!
 * Automatically generated from xbb-helper/templates/docusaurus/common.
 *
 * This file is part of the xPack project (http://xpack.github.io).
 * Copyright (c) 2024 Liviu Ionescu. All rights reserved.
 *
 * Permission to use, copy, modify, and/or distribute this software
 * for any purpose is hereby granted, under the terms of the MIT license.
 *
 * If a copy of the license was not distributed with this file, it can
 * be obtained from https://opensource.org/licenses/MIT/.
 */

import logger from '@docusaurus/logger';

import tools from './tools';
import sidebars from '../../sidebars'

// Not yet functional, the sidebars are currently static.
export default function addToolsToSidebar() {
  for (const entry of sidebars.toolsSidebar) {
    if (entry.type === 'category') {
      if (entry.label === 'Main Tools') {
        logger.info(entry.label)
        entry.items = tools().mainTools.map((tool) => {
          logger.info('  ' + tool.appName)
          return {
            type: 'link',
            label: `xPack ${tool.appName}`,
            href: `https://xpack-dev-tools.github.io/${tool.appLcName}-xpack/`
          }
        })
      } else if (entry.label === 'Supplementary Tools') {
        logger.info(entry.label)
        entry.items = tools().supplementaryTools.map((tool) => {
          logger.info('  ' + tool.appName)
          return {
            type: 'link',
            label: `xPack ${tool.appName}`,
            href: `https://xpack-dev-tools.github.io/${tool.appLcName}-xpack/`
          }
        })
      }
    }
  }
}
