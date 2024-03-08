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
time bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer/build-all.sh --clone
```

To run all possible builds on the given platform from scratch:

```sh
git -C ~/Work/xpack-dev-tools/xbb-helper-xpack.git pull
time bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer/build-all.sh --deep-clean
```

To only see the build command without running it, use `--dry-run`.

On Linux, to build the Windows binaries:

```sh
git -C ~/Work/xpack-dev-tools/xbb-helper-xpack.git pull
time bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer/build-all.sh --windows
```

The full builds may take more than 1 day to complete:

- `xbbmi`: 7h03 (nuc)
- `xbbma`: 3h37
- `xbbli`: 316m (5h16) Linux, 395m (6h35) Windows
- `berry5`: 1086m (18h06)
- `xbbla`: 24h10 + 11h06 clang
- `xbbla32`: 21h22 + 9h07 clang

To show the repos status:

```sh
bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer/build-all.sh --repos-status
```

To exclude some projects, use multiple `--exclude xyz`, for example:

```sh
git -C ~/Work/xpack-dev-tools/xbb-helper-xpack.git pull
time bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer/build-all.sh --deep-clean --exclude clang
```

To exclude all:

```sh
git -C ~/Work/xpack-dev-tools/xbb-helper-xpack.git pull
time bash ~/Work/xpack-dev-tools/xbb-helper-xpack.git/maintainer/build-all.sh \
--exclude gcc \
--exclude mingw-w64-gcc \
--exclude cmake \
--exclude meson-build \
--exclude ninja-build \
--exclude openocd \
--exclude qemu-arm \
--exclude qemu-riscv \
--exclude arm-none-eabi-gcc \
--exclude aarch64-none-elf-gcc \
--exclude riscv-none-elf-gcc \
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
--exclude clang \
--windows \
--deep-clean \

```
