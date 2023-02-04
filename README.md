[![GitHub package.json version](https://img.shields.io/github/package-json/v/xpack-dev-tools/xbb-helper-xpack)](https://github.com/xpack-dev-tools/xbb-helper-xpack/blob/xpack/package.json)
[![npm (scoped)](https://img.shields.io/npm/v/@xpack-dev-tools/xbb-helper.svg?color=blue)](https://www.npmjs.com/package/@xpack-dev-tools/xbb-helper/)
[![license](https://img.shields.io/github/license/xpack-dev-tools/xbb-helper-xpack)](https://github.com/xpack-dev-tools/xbb-helper-xpack/blob/xpack/LICENSE)

# A source xPack with helper files for the XBB builds

This project provides common scripts and other files useful during
**xPack Build Box (XBB)** builds.

This open source project is hosted on GitHub as
[`xpack-dev-tools/xbb-helper-xpack`](https://github.com/xpack-dev-tools/xbb-helper-xpack).

## Overview

This projects includes:

- shell scripts to build various projects as dependencies
(see the `dependencies` folder)
- templates used to generate project configurations
- tests
- patches
- other files

## Maintainer info

This page is addressed to developers who plan to include this package
into their own projects.

For maintainer info, please see:

- [How to publish](https://github.com/xpack-dev-tools/xbb-helper-xpack/blob/xpack/README-MAINTAINER.md)

## Install

As a source xPack, the easiest way to add it to a project is via
**xpm**, but it can also be used as any Git project, for example as a submodule.

### Prerequisites

A recent [xpm](https://xpack.github.io/xpm/),
which is a portable [Node.js](https://nodejs.org/) command line application.

It is recommended to update to the latest version with:

```sh
npm install --global xpm@latest
```

For details please follow the instructions in the
[xPack install](https://xpack.github.io/install/) page.

### xpm

This package is available as
[`@xpack-dev-tools/xbb-helper`](https://www.npmjs.com/package/@xpack-dev-tools/xbb-helper)
from the `npmjs.com` registry:

```sh
cd my-project
xpm init # Unless a package.json is already present

xpm install --save-dev @xpack-dev-tools/xbb-helper@latest --verbose

ls -l xpacks/xpack-dev-tools-xbb-helper
```

### Git submodule

If, for any reason, **xpm** is not available, the next recommended
solution is to link it as a Git submodule below an `xpacks` folder.

```sh
cd my-project
git init # Unless already a Git project
mkdir -p xpacks

git submodule add https://github.com/xpack-dev-tools/xbb-helper-xpack.git \
  xpacks/xpack-dev-tools-xbb-helper
```

## Branches

Apart from the unused `master` branch, there are two active branches:

- `xpack`, with the latest stable version (default)
- `xpack-develop`, with the current development version

All development is done in the `xpack-develop` branch, and contributions via
Pull Requests should be directed to this branch.

When new releases are published, the `xpack-develop` branch is merged
into `xpack`.

## Developer info

This project includes several bash scripts with functions that can be
used for common jobs in application builds.

### Integration info

A typical use case is to define an xPack action that copies, among
other things, the build scripts from the helper templates:

```json
  "cp xpacks/xpack-dev-tools-xbb-helper/templates/build.sh scripts/",
  "cp xpacks/xpack-dev-tools-xbb-helper/templates/test.sh scripts/"
```

The resulting `scripts/build.sh` requires two application scripts:

- `scripts/application.sh` - with common definitions
- `scripts.versioning.sh` - with details how to build different versions

The resulting `scripts/test.sh` requires:

- `scripts/application.sh` - with common definitions
- `tests/run.sh` - the code to run the validation tests
- `tests/update.sh` - optional updates for different docker environments

### Known problems

- none

### Tests

There are currently no CI tests specific for this package.

The files in the `tests` folder are used during native compilers tests.

### Examples

Please see any of the existing projects, like:

- <https://github.com/xpack-dev-tools/gcc-xpack/>

## Change log - incompatible changes

According to [semver](https://semver.org) rules:

> Major version X (X.y.z | X > 0) MUST be incremented if any
backwards incompatible changes are introduced to the public API.

The incompatible changes, in reverse chronological order,
are:

- v0.x: pre-release versions

## Support

For support, please use GitHub
[Discussions](https://github.com/xpack-dev-tools/xbb-helper-xpack/discussions/).

## License

The original content is released under the
[MIT License](https://opensource.org/licenses/MIT/),
with all rights reserved to
[Liviu Ionescu](https://github.com/ilg-ul/).
