# Maintainer info

## Clone project

To get the project:

```sh
rm -rf ~/Work/xpack-dev-tools/xbb-helper-xpack.git && \
mkdir -p ~/Work/xpack-dev-tools && \
git clone \
  --branch xpack-development \
  https://github.com/xpack-dev-tools/xbb-helper-xpack.git \
  ~/Work/xpack-dev-tools/xbb-helper-xpack.git
xpm link -C ~/Work/xpack-dev-tools/xbb-helper-xpack.git
```

The helpers are automatically cloned by `--clone`.

To clone them manually, use:

```sh
rm -rf ~/Work/xpack/npm-packages-helper.git && \
mkdir -p ~/Work/xpack && \
git clone \
https://github.com/xpack/npm-packages-helper.git \
~/Work/xpack/npm-packages-helper.git

(cd ~/Work/xpack/npm-packages-helper.git; npm link --verbose)
```

```sh
rm -rf ~/Work/xpack/docusaurus-template-liquid.git && \
mkdir -p ~/Work/xpack && \
git clone \
https://github.com/xpack/docusaurus-template-liquid.git \
~/Work/xpack/docusaurus-template-liquid.git

(cd ~/Work/xpack/docusaurus-template-liquid.git; npm link --verbose)
```

To update already cloned projects:

```sh
git -C ~/Work/xpack-dev-tools/xbb-helper-xpack.git pull
git -C ~/Work/xpack/npm-packages-helper.git pull
git -C ~/Work/xpack/docusaurus-template-liquid.git pull
```

## Check space

Check if the build machines have enough free space and eventually
do some cleanups.

On Linux:

```sh
bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintenance-scripts/build-all.sh --check-space
```

If necessary, remove all build folders:

```sh
rm -rf ~/Work/xpack-dev-tools/*/build-assets/build
```

On `wksi` use:

```sh
rm -rf ~/Work/xpack-dev-tools-build
```

If necessary, remove the cached files:

```sh
rm -rf ~/Work/cache
```

## Clone all

To get all projects:

```sh
time bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintenance-scripts/build-all.sh --clone
```

To update top commons:

```sh
time bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintenance-scripts/build-all.sh --update-top
```

To remove all time stamps and restart all builds:

```sh
bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintenance-scripts/build-all.sh --restart
```

or, for the Windows build on GNU/Linux:

```sh
bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintenance-scripts/build-all.sh --windows --restart
```

### screen

To provide a persistent standard output for the build, create a screen session:

```sh
screen -S ba
```

To quit it, use `# Ctrl-a Ctrl-d`.

## Build all

To run all possible builds on the given platform from scratch:

```sh
time nice bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintenance-scripts/build-all.sh --deep-clean
```

or, on macOS:

```sh
time caffeinate nice bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintenance-scripts/build-all.sh --deep-clean
```

To only see the build commands without running them, use `--dry-run`.

On Linux, to build the Windows binaries:

```sh
time nice bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintenance-scripts/build-all.sh --windows --deep-clean
```

or, for the Windows build on GNU/Linux:

```sh
time nice bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintenance-scripts/build-all.sh --windows --deep-clean
```

On macOS, use:

```sh
time caffeinate nice bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintenance-scripts/build-all.sh --deep-clean
```

DO NOT RUN IT IN PARALLEL! `deep-clean` removes the entire build folder.

The full builds may take about half a day to complete (even more on a Raspberry Pi 5):

- `wksi`: 764m (12h44)
- `xbbmi`: 453m (7h33)
- `xbbma`: 239n (3h59)
- `xbbli` linux: 308m (5h08)
- `xbbli` windows: 222m (3h42)
- `ampere`: 670m (11h10)
- `berry5`: 17h20

To show the repos status:

```sh
bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintenance-scripts/build-all.sh --repos-status
```

To exclude some projects, use multiple `--exclude xyz`, for example:

```sh
time caffeinate nice bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintenance-scripts/build-all.sh \
--exclude clang \
\
--deep-clean
```

```sh
time nice bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintenance-scripts/build-all.sh \
--exclude clang \
--exclude gcc \
--exclude mingw-w64-gcc \
--exclude aarch64-none-elf-gcc \
--exclude arm-none-eabi-gcc \
--exclude riscv-none-elf-gcc \
\
--deep-clean
```

To exclude all:

```sh
time nice bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintenance-scripts/build-all.sh \
--exclude ninja-build \
--exclude cmake \
--exclude meson-build \
--exclude openocd \
--exclude qemu-arm \
--exclude qemu-riscv \
--exclude windows-build-tools \
--exclude patchelf \
--exclude pkg-config \
--exclude realpath \
--exclude m4 \
--exclude sed \
--exclude bison \
--exclude flex \
--exclude texinfo \
--exclude wine \
--exclude gcc \
--exclude mingw-w64-gcc \
--exclude aarch64-none-elf-gcc \
--exclude arm-none-eabi-gcc \
--exclude riscv-none-elf-gcc \
--exclude clang \
--deep-clean \
\
--windows

```

### ampere

On Ampere the space is tight and the previous builds must be
removed.

```sh
df -BG -H /

rm -rf ~/Work/xpack-dev-tools/*/build-assets/build
rm -rf ~/Work/cache
sudo rm -rf ~/actions-runners/xpack-dev-tools/*/_work
sudo rm -rf ~/actions-runners/xpack-dev-tools/_work

time nice bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintenance-scripts/build-all.sh --deep-clean --exclude clang
```

### wksi

```ah
df -g /
```

On `wksi`, when building  `qemu-arm` & `qemu-riscv`, meson fails with:

```ah
meson.build:2277:26: ERROR: <PythonExternalProgram '/Library/Frameworks/Python.framework/Versions/3.11/bin/python3' -> ['/Library/Frameworks/Python.framework/Versions/3.11/bin/python3']> is not a valid python or it is missing distutils
```

- https://stackoverflow.com/questions/69919970/no-module-named-distutils-but-distutils-installed

To fix it, install setuptools:

```sh
ilg@wksi ~ % sudo -H pip3 install setuptools
Password:
Requirement already satisfied: setuptools in /Library/Frameworks/Python.framework/Versions/3.11/lib/python3.11/site-packages (65.5.0)
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
```

## Repair links

In case the links were damaged, redo all:

```sh
for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*.git
do
  echo $f
  ln -sf $f /Users/ilg/Work/xpack-dev-tools/$(basename $f)
done
```

## More

More scripts are available in the `maintenance-scripts` of the
`npm-packages-helper.git` and `docusaurus-template-liquid.git`,
with their associated npm scripts or xpm actions.

For details how to invoke them, see the
[README-MAINTAINER.md](../README-MAINTAINER.md) file.
