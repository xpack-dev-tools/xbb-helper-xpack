[![license](https://img.shields.io/github/license/xpack-dev-tools/xbb-helper-xpack)](https://github.com/xpack-dev-tools/xbb-helper-xpack/blob/xpack/LICENSE)

# A source library xPack with helper files for the XBB builds

This project provides files to be included during builds.

The project is hosted on GitHub as
[xpack-dev-tools/xbb-helper-xpack](https://github.com/xpack-dev-tools/xbb-helper-xpack).

## Maintainer info

This page is addressed to developers who plan to include this source
library into their own projects.

For maintainer info, please see the
[README-MAINTAINER](README-MAINTAINER.md) file.

## Install

As a source library xPack, the easiest way to add it to a project is via
**xpm**, but it can also be used as any Git project, for example as a submodule.

### Prerequisites

A recent [xpm](https://xpack.github.io/xpm/),
which is a portable [Node.js](https://nodejs.org/) command line application.

For details please follow the instructions in the
[xPack install](https://xpack.github.io/install/) page.

### xpm

This package is available as
[`@xpack-dev-tools/xbb-helper`](https://www.npmjs.com/package/@xpack-dev-tools/xbb-helper)
from the `npmjs.com` registry:

```sh
cd my-project
xpm init # Unless a package.json is already present

xpm install @xpack-dev-tools/xbb-helper@latest

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

### Overview

This project includes several bash scripts with functions that can be
used in application builds for common jobs.

### Integration info

There are multiple scripts, but the easiest way is to include
`scripts/helper.sh`.

For common operations, like builds, include `scripts/common-build.sh`.

### Known problems

- none

### Examples

A typical use case is to source the helper and the `common-*.sh` and
invoke it like:

```sh
#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2022 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Safety settings (see https://gist.github.com/ilg-ul/383869cbb01f61a51c4d).

if [[ ! -z ${DEBUG} ]]
then
  set ${DEBUG} # Activate the expand mode if DEBUG is anything but empty.
else
  DEBUG=""
fi

set -o errexit # Exit if command failed.
set -o pipefail # Exit if pipe failed.
set -o nounset # Exit if variable not set.

# Remove the initial space and instead use '\n'.
IFS=$'\n\t'

# -----------------------------------------------------------------------------
# Identify the script location, to reach, for example, the helper scripts.

build_script_path="$0"
if [[ "${build_script_path}" != /* ]]
then
  # Make relative path absolute.
  build_script_path="$(pwd)/$0"
fi

script_folder_path="$(dirname "${build_script_path}")"
script_folder_name="$(basename "${script_folder_path}")"

# =============================================================================

scripts_folder_path="${script_folder_path}"
project_folder_path="$(dirname ${script_folder_path})"
helper_folder_path="${project_folder_path}/xpacks/xpack-dev-tools-xbb-helper"

# -----------------------------------------------------------------------------

source "${scripts_folder_path}/definitions.sh"

source "${helper_folder_path}/scripts/helper.sh"
source "${helper_folder_path}/scripts/common-build.sh"

source "${scripts_folder_path}/versioning.sh"

source "${scripts_folder_path}/dependencies/ninja.sh"

# -----------------------------------------------------------------------------

host_detect

help_message="    bash $0 [--win] [--debug] [--develop] [--jobs N] [--help]"
host_parse_options "${help_message}" "$@"

common_build

exit 0
```

## Change log - incompatible changes

According to [semver](https://semver.org) rules:

> Major version X (X.y.z | X > 0) MUST be incremented if any
backwards incompatible changes are introduced to the public API.

The incompatible changes, in reverse chronological order,
are:

- v1.x: initial version

## License

The original content is released under the
[MIT License](https://opensource.org/licenses/MIT/),
with all rights reserved to
[Liviu Ionescu](https://github.com/ilg-ul/).
