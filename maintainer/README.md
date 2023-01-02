# Maintainer info

To run all possible builds on the given platform:

```sh
git -C ~/Work/xbb-helper-xpack.git pull
time bash ~/Work/xbb-helper-xpack.git/maintainer/build-all.sh --deep-clean
```

To only see the build command without running it, use `--dry-run`.

On Linux, to build the Windows binaries:

```sh
git -C ~/Work/xbb-helper-xpack.git pull
time bash ~/Work/xbb-helper-xpack.git/maintainer/build-all.sh --windows
```

The full builds may take more than 1 day to complete:

- `xbbmi`: 7h (vm)
- `xbbma`: 4h
- `xbbli`: Linux 5h, Windows 6h
- `xbbla64`: 19h + 9h clang
- `xbbla32`: 18h + 8h clang

To show the repos status:

```sh
bash ~/Work/xbb-helper-xpack.git/maintainer/build-all.sh --status
```

To exclude some projects, use multiple `--exclude xyz`, for example:

```sh
git -C ~/Work/xbb-helper-xpack.git pull
time bash ~/Work/xbb-helper-xpack.git/maintainer/build-all.sh --deep-clean --exclude clang
```

To exclude all:

```sh
git -C ~/Work/xbb-helper-xpack.git pull
time bash ~/Work/xbb-helper-xpack.git/maintainer/build-all.sh \
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
--exclude wine \
--exclude clang \
--windows \
--deep-clean \

```
