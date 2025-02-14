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

To get the helpers:

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
df -BG -H /
```

On macOS:

```sh
df -gH /
```

## Clone all

To get all projects:

```sh
time bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer-scripts/build-all.sh --clone
```

To update top commons:

```sh
time bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer-scripts/build-all.sh --update-top
```

To restart all builds:

```sh
time bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer-scripts/build-all.sh --restart
```

## Build all

To run all possible builds on the given platform from scratch:

```sh
time nice bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer-scripts/build-all.sh --deep-clean
time caffeinate nice bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer-scripts/build-all.sh --deep-clean
```

To only see the build command without running it, use `--dry-run`.

On Linux, to build the Windows binaries:

```sh
time nice bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer-scripts/build-all.sh --windows
time caffeinate nice bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer-scripts/build-all.sh --windows
```

DO NOT RUN IT IN PARALLEL!

The full builds may take more than 1 day to complete:

- `wksi`: ?
- `xbbmi`: ? [was 7h03 (nuc)]
- `xbbma`: 2h25 + 43m clang [was 3h37]
- `xbbli` linux: 244m (4h04) + 67m (1h07)
- `xbbli` windows: ? [was 395m (6h35)]
- `berry5`: ? [was 1086m (18h06)]
- `ampere`: 507m (9h27) + 157m (2h37)
- `xbbla`:  ? [was 24h10 + 11h06 clang]
- `xbbla32`: ? [was 21h22 + 9h07 clang]

To show the repos status:

```sh
bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer-scripts/build-all.sh --repos-status
```

To exclude some projects, use multiple `--exclude xyz`, for example:

```sh
time caffeinate nice bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer-scripts/build-all.sh \
--exclude clang \
\
--deep-clean
```

```sh
time nice bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer-scripts/build-all.sh \
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
time nice bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer-scripts/build-all.sh \
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

On Ampere the space is tight and the largest build must be
removed

```sh
df -BG -H /

rm -rf ~/Work/xpack-dev-tools/*/build-assets/build
sudo rm -rf ~/actions-runners/xpack-dev-tools/*/_work
sudo rm -rf ~/actions-runners/xpack-dev-tools/_work

time nice bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer-scripts/build-all.sh --deep-clean --exclude clang

time nice bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer-scripts/build-all.sh \
--exclude clang \
--exclude gcc \
--exclude mingw-w64-gcc \
--exclude aarch64-none-elf-gcc \
--exclude arm-none-eabi-gcc \
--exclude riscv-none-elf-gcc \
\
--deep-clean

xpm run deep-clean --config linux-arm64 -C ~/Work/xpack-dev-tools/arm-none-eabi-gcc-xpack.git
xpm run deep-clean --config linux-arm64 -C ~/Work/xpack-dev-tools/riscv-none-elf-gcc-xpack.git

time nice bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer-scripts/build-all.sh \
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
\
--deep-clean

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
