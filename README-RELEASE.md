[![license](https://img.shields.io/github/license/xpack-dev-tools/xbb-helper-xpack)](https://github.com/xpack-dev-tools/xbb-helper-xpack/blob/xpack/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/xpack-dev-tools/xbb-helper-xpack.svg)](https://github.com/xpack-dev-tools/xbb-helper-xpack/issues/)
[![GitHub pulls](https://img.shields.io/github/issues-pr/xpack-dev-tools/xbb-helper-xpack.svg)](https://github.com/xpack-dev-tools/xbb-helper-xpack/pulls)

# How to make a new release (maintainer info)

## Release schedule

There are no scheduled releases, the project is updated when necessary.

## Project repository

The project is hosted on GitHub:

- <https://github.com/xpack-dev-tools/xbb-helper-xpack.git>

To clone the stable branch (`xpack`), run the following commands in a
terminal (on Windows use the _Git Bash_ console):

```sh
rm -rf ~/Work/xbb-helper-xpack.git; \
mkdir -p ~/Work; \
git clone \
  https://github.com/xpack-dev-tools/xbb-helper-xpack.git \
  ~/Work/xbb-helper-xpack.git
```

For development purposes, clone the `xpack-develop` branch:

```sh
rm -rf ~/Work/xbb-helper-xpack.git; \
mkdir -p ~/Work; \
git clone \
  --branch xpack-develop \
  https://github.com/xpack-dev-tools/xbb-helper-xpack.git \
  ~/Work/xbb-helper-xpack.git
```

## Prerequisites

A recent [xpm](https://xpack.github.io/xpm/), which is a portable
[Node.js](https://nodejs.org/) command line application.

## Prepare the build

Before starting the build, perform some checks and tweaks.

### Check Git

In the `xpack-dev-tools/xbb-helper-xpack` Git repo:

- switch to the `xpack-develop` branch
- pull new changes
- if needed, merge the `xpack` branch

No need to add a tag here, it'll be added when the release is created.

### Increase the version

Determine the upstream version (like `0.8.6`) and eventually update the
`package.json` file; the format is `0.8.6-pre`.

### Fix possible open issues

Check GitHub issues and pull requests:

- <https://github.com/xpack-dev-tools/xbb-helper-xpack/issues/>

and fix them; assign them to a milestone (like `0.8.6`).

### Check `README.md`

Normally `README.md` should not need changes, but better check.
Information related to the new version should not be included here,
but in the version specific release page.

### Update versions in `README` files

- update version in `README-RELEASE.md`
- update version in `README.md`

### Update `CHANGELOG.md`

- open the `CHANGELOG.md` file
- check if all previous fixed issues are in
- add a new entry like _* v0.8.6 released_
- commit with a message like _prepare v0.8.6_

### Push changes

- commit and push

### Manual tests

TBD

### Publish on the npmjs.com server

- select the `xpack-develop` branch
- commit all changes
- `npm pack` and check the content of the archive, which should list
  only `package.json`, `README.md`, `LICENSE`, `CHANGELOG.md`,
  the `config`, `scripts` folders;
  possibly adjust `.npmignore`
- `npm version patch`, `npm version minor`, `npm version major`
- push the `xpack-develop` branch to GitHub
- the `postversion` npm script should also update tags via `git push origin --tags`

### Publish

- `npm publish --tag next` (use `npm publish --access public` when
  publishing for the first time)

The version is visible at:

- <https://www.npmjs.com/package/@xpack-dev-tools/xbb-helper?activeTab=versions>

### Update the repo

- merge `xpack-develop` into `xpack`
- push to GitHub

### Tag the npm package as `latest`

When the release is considered stable, promote it as `latest`:

- `npm dist-tag ls @xpack-dev-tools/xbb-helper`
- `npm dist-tag add @xpack-dev-tools/xbb-helper@0.8.6 latest`
- `npm dist-tag ls @xpack-dev-tools/xbb-helper`

If necessary, unpublish previous releases:

- `npm unpublish @xpack-dev-tools/xbb-helper@0.8.6`
