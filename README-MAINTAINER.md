[![license](https://img.shields.io/github/license/xpack-dev-tools/xbb-helper-xpack)](https://github.com/xpack-dev-tools/xbb-helper-xpack/blob/xpack/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/xpack-dev-tools/xbb-helper-xpack.svg)](https://github.com/xpack-dev-tools/xbb-helper-xpack/issues/)
[![GitHub pulls](https://img.shields.io/github/issues-pr/xpack-dev-tools/xbb-helper-xpack.svg)](https://github.com/xpack-dev-tools/xbb-helper-xpack/pulls)

# Maintainer info

## Prerequisites

The build scripts run on GNU/Linux and macOS. The Windows binaries are
generated on x64 GNU/Linux, using [mingw-w64](https://mingw-w64.org).

For details on installing the prerequisites, please read the
[XBB prerequisites page](https://xpack.github.io/xbb/prerequisites/).

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

Link it to the central xPacks store:

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

Determine the next version (like `3.0.12`) and update the
`package.json` file; the format is `3.0.12-pre`.

### Fix possible open issues

Check GitHub issues and pull requests:

- <https://github.com/xpack-dev-tools/xbb-helper-xpack/issues/>

and fix them; assign them to a milestone (like `3.0.12`).

### Check `README.md`

Normally `README.md` should not need changes, but better check.
Information related to the new version should not be included here,
but in the version specific release page.

### Update versions in `README` files

- update version in `README-MAINTAINER.md`
- update version in `README.md`

### Update version in `package.json` to a pre-release

Use the new version, suffixed by `pre`, like `3.0.12-pre`.

### Update `CHANGELOG.md`

- open the `CHANGELOG.md` file
- check if all previous fixed issues are in
- add a new entry like _* v3.0.12 released_
- commit with a message like _prepare v3.0.12_

### Push changes

- commit and push

### Manual tests

- none

### Publish on the npmjs.com server

- select the `xpack-development` branch
- commit all changes
- `npm pack` and check the content of the archive;
  possibly adjust `.npmignore`
- `npm version patch`, `npm version minor`, `npm version major`
- push the `xpack-development` branch to GitHub
- the `postversion` npm script should also update tags via `git push origin --tags`

### Publish

- `npm publish --tag test` (use `npm publish --access public` when
  publishing for the first time)

The version is visible at:

- <https://www.npmjs.com/package/@xpack-dev-tools/xbb-helper?activeTab=versions>

### Update the repo

- merge `xpack-development` into `xpack`
- push to GitHub

### Tag the npm package as `latest`

When the release is considered stable, promote it as `latest`:

- `npm dist-tag ls @xpack-dev-tools/xbb-helper`
- `npm dist-tag add @xpack-dev-tools/xbb-helper@3.0.12 latest`
- `npm dist-tag ls @xpack-dev-tools/xbb-helper`

If necessary, unpublish previous releases:

- `npm unpublish @xpack-dev-tools/xbb-helper@3.0.12`
