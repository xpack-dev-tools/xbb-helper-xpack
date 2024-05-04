# Maintainer info

To get the project:

```sh
rm -rf ~/Work/xpack-dev-tools/xbb-helper-xpack.git && \
mkdir -p ~/Work/xpack-dev-tools && \
git clone \
  --branch xpack-develop \
  https://github.com/xpack-dev-tools/xbb-helper-xpack.git \
  ~/Work/xpack-dev-tools/xbb-helper-xpack.git
```

Check if the build machines have enough free space and eventually
do some cleanups (`df -BG -H /` on Linux, `df -gH /` on macOS).

To get all projects:

```sh
git -C ~/Work/xpack-dev-tools/xbb-helper-xpack.git pull
time bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer-scripts/build-all.sh --clone
```

To run all possible builds on the given platform from scratch:

```sh
git -C ~/Work/xpack-dev-tools/xbb-helper-xpack.git pull
time nice bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer-scripts/build-all.sh --deep-clean
```

To only see the build command without running it, use `--dry-run`.

On Linux, to build the Windows binaries:

```sh
git -C ~/Work/xpack-dev-tools/xbb-helper-xpack.git pull
time nice bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer-scripts/build-all.sh --windows
```

The full builds may take more than 1 day to complete:

- `wksi`: ?
- `xbbmi`: 7h03 (nuc)
- `xbbma`: 3h37
- `xbbli`: 316m (5h16) Linux, 395m (6h35) Windows
- `berry5`: 1086m (18h06)
- `ampere`: 546m (9h6) + 140m (2h20) clang
- `xbbla`: 24h10 + 11h06 clang
- `xbbla32`: 21h22 + 9h07 clang

To show the repos status:

```sh
bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer-scripts/build-all.sh --repos-status
```

To exclude some projects, use multiple `--exclude xyz`, for example:

```sh
git -C ~/Work/xpack-dev-tools/xbb-helper-xpack.git pull
time nice bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer-scripts/build-all.sh --deep-clean --exclude clang
```

To exclude all:

```sh
git -C ~/Work/xpack-dev-tools/xbb-helper-xpack.git pull
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
--windows \

```

## ampere

On Ampere the space is tight and the largest build must be
removed

```sh
git -C ~/Work/xpack-dev-tools/xbb-helper-xpack.git pull
time nice bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer-scripts/build-all.sh \
--exclude clang
--deep-clean \

xpm run deep-clean --config linux-arm64 -C ~/Work/xpack-dev-tools/arm-none-eabi-gcc-xpack.git

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
--deep-clean \

```

## wksi

On `wksi`, when building  `qemu-arm` & `qemu-riscv`, meson fails with:

```
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

### Repair links

In case the links were damaged, redo all:

```sh
for f in /Users/ilg/MyProjects/xpack-dev-tools.github/xPacks/*.git
do
  echo $f
  ln -sf $f /Users/ilg/Work/xpack-dev-tools/$(basename $f)
done
```
