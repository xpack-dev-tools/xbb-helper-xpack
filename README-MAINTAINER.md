[![license](https://img.shields.io/github/license/xpack-dev-tools/xbb-helper-xpack)](https://github.com/xpack-dev-tools/xbb-helper-xpack/blob/xpack/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/xpack-dev-tools/xbb-helper-xpack.svg)](https://github.com/xpack-dev-tools/xbb-helper-xpack/issues/)
[![GitHub pulls](https://img.shields.io/github/issues-pr/xpack-dev-tools/xbb-helper-xpack.svg)](https://github.com/xpack-dev-tools/xbb-helper-xpack/pulls)

# Maintainer info

## Prerequisites

The build scripts run on GNU/Linux and macOS. The Windows binaries are
generated on x64 GNU/Linux, using [mingw-w64](https://mingw-w64.org).

For details on installing the prerequisites, please read the
[Build Prerequisites](https://xpack-dev-tools.github.io/docs/developer/install/prerequisites/)
page.

## Get project sources

The project is hosted on GitHub:

- <https://github.com/xpack-dev-tools/xbb-helper-xpack.git>

To clone the stable branch (`xpack`), run the following commands in a
terminal (on Windows use the _Git Bash_ console):

```sh
rm -rf ~/Work/xpack-dev-tools/xbb-helper-xpack.git && \
mkdir -p ~/Work/xpack-dev-tools && \
git clone \
  https://github.com/xpack-dev-tools/xbb-helper-xpack.git \
  ~/Work/xpack-dev-tools/xbb-helper-xpack.git
```

For development purposes, clone the `xpack-development` branch:

```sh
rm -rf ~/Work/xpack-dev-tools/xbb-helper-xpack.git && \
mkdir -p ~/Work/xpack-dev-tools && \
git clone \
  --branch xpack-development \
  https://github.com/xpack-dev-tools/xbb-helper-xpack.git \
  ~/Work/xpack-dev-tools/xbb-helper-xpack.git
```

Link it to the user global xPacks store:

```sh
xpm link -C ~/Work/xpack-dev-tools/xbb-helper-xpack.git
```

Further updates can be done with:

```sh
git -C ~/Work/xpack-dev-tools/xbb-helper-xpack.git pull
```

## Release schedule

There are no scheduled releases, the project is updated when necessary.

## How to make new releases

Before starting the build, perform some checks and tweaks.

### Check Git

In the `xpack-dev-tools/xbb-helper-xpack` Git repo:

- switch to the `xpack-development` branch
- pull new changes
- if needed, merge the `xpack` branch

No need to add a tag here, it'll be added when the release is created.

### Increase the version

Determine the next version (like `5.0.0`) and update the
`package.json` file; the format is `5.0.0-pre`.

### Fix possible open issues

Check GitHub issues and pull requests:

- <https://github.com/xpack-dev-tools/xbb-helper-xpack/issues/>

and fix them; assign them to a milestone (like `5.0.0`).

### Check `README.md`

Normally `README.md` should not need changes, but better check.
Information related to the new version should not be included here,
but in the version specific release page.

### Update versions in `README` files

- update version in `README-MAINTAINER.md`
- update version in `README.md`

### Update version in `package.json` to a pre-release

Use the new version, suffixed by `pre`, like `5.0.0-pre`.

### Update `CHANGELOG.md`

- open the `CHANGELOG.md` file
- check if all previous fixed issues are in
- add a new entry like _* v5.0.0 released_
- commit with a message like _prepare v5.0.0_

### Push changes

- commit and push

### Manual tests

- none

### Update the package version

- select the `xpack-development` branch
- commit all changes
- `npm pack` and check the content of the archive;
  possibly adjust `.npmignore`
- `npm version major`, `npm version minor`, `npm version patch`
- push the `xpack-development` branch to GitHub
- the `postversion` npm script should also update tags via `git push origin --tags`

### Check if the tag is published

- https://github.com/xpack-dev-tools/xbb-helper-xpack/releases/tag/v5.0.0

### Update the repo

- merge `xpack-development` into `xpack`
- push to GitHub

### Update npm-packages-helper.git template

Update the version in `templates/common/_xpack-dev-tools/build-assets/package-merge-liquid.json`.

```json
"@xpack-dev-tools/xbb-helper": "github:xpack-dev-tools/xbb-helper-xpack#v5.0.0"
```

### Update all xpacks references

Open the workspace with all packages, and update all references with

```json
"@xpack-dev-tools/xbb-helper": "github:xpack-dev-tools/xbb-helper-xpack#v5.0.0"
```

### Update top commons

Support is provided by the `xpacks/npm-packages-helper.git` project.

To run for all projects, remove the stamps in the `/xpack-dev-tools.github/stamps/projects-generate-commons-and-build` folder.

Run the following xpm actions:

- `xpack-dev-tools-generate-top-commons`
- `xpack-dev-tools-commit-and-push-top-commons`

### Update website commons

Support is provided by the `xpacks/docusaurus-template-liquid.git` project.

To run for all projects, remove the stamps in the `/xpack-dev-tools.github/stamps/websites-generate-commons-and-build` folder.

Run the following xpm actions:

- `xpack-dev-tools-generate-websites-commons-and-build`
- `xpack-dev-tools-commit-and-push-websites`
