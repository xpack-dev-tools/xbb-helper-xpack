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

import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';
import Link from '@docusaurus/Link';

type FeatureItem = {
  title: string;
  Svg: React.ComponentType<React.ComponentProps<'svg'>>;
  description: JSX.Element;
};

{% assign platforms_array = platforms | split: "," -%}

{% assign names_array = "" | split: "" -%}

{% for platform in platforms_array -%}
{% if platform == "win32-x64" %}{% assign names_array = names_array | concat: "Windows" %}{% endif -%}
{% if platform == "darwin-x64" or platform == "darwin-arm64" %}{% assign names_array = names_array | concat: "macOS" %}{% endif -%}
{% if platform == "linux-x64" or platform == "linux-arm64" or platform == "linux-arm" %}{% assign names_array = names_array | concat: "GNU/Linux" %}{% endif -%}
{% endfor -%}

{% assign names_array = names_array | uniq -%}
const FeatureList: FeatureItem[] = [
  {
    title: 'Multi-version{% if names_array.size > 1 %}, cross-platform{% endif %}',
    Svg: require('@site/static/img/mosaic.svg').default,
    description: (
      <>
        <b>Binary xPacks</b> are packages with executables.
        By design, <b>multiple versions</b> of the same programs can be
        installed at the same time on the same
        system. {% if names_array.size > 1 %}The supported platforms are: <b>{{ names_array | join: "</b>, <b>" }}</b>.{% else %}The binaries run on  <b>{{ names_array | first }}</b>.{% endif %}
        The packages include <b>all required libraries</b> and can be <b>installed in any folder</b>.
      </>
    ),
  },
  {
    title: 'Easy to Use & Reproducible',
    Svg: require('@site/static/img/check-badge.svg').default,
    description: (
      <>
        The binary xPacks can be added to projects
        as <b>development dependencies</b>,
        and conveniently installed with <code>xpm install</code>.
        This feature also ensures reproducibility, which is particularly
        beneficial in <b>CI/CD</b> environments.
      </>
    ),
  },
  {
    title: 'Part of the Node.js ecosystem',
    Svg: require('@site/static/img/globe.svg').default,
    description: (
      <>
        The <b><Link to="https://xpack.github.io/xpm/">xpm</Link></b> CLI tool
        complements <b><Link to="https://docs.npmjs.com/cli/">npm</Link></b> with
        several extra features specific to <b>C/C++ projects</b>.
        This allows the
        binary xPacks to nicely integrate into the Node.js ecosystem,
        while still allowing the binary archives to be installed manually.
      </>
    ),
  },
];

function Feature({title, Svg, description}: FeatureItem) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <Svg className={styles.featureSvg} role="img" />
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): JSX.Element {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
