# Developer info

## macOS

To make the deployment target explicit, on
production machines use one of:

```sh
export XBB_ENVIRONMENT_MACOSX_DEPLOYMENT_TARGET="10.13"
export XBB_ENVIRONMENT_MACOSX_DEPLOYMENT_TARGET="11.0"
```

Minimum requirements and supported SDKs:

- <https://developer.apple.com/support/xcode/>

## Windows

### Long path support

During post-processing of Windows builds, after the binaries are
stripped, a manifest that declares `longPathAware` is embedded
in all `.exe` files. Windows can then let these programs use paths
longer than 260 characters (`MAX_PATH`), which happens with the
deep build folders of some IDEs; see
[discussion #55](https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/discussions/55).

The manifest takes effect only on Windows 10 1607 or later, when the
`HKLM\SYSTEM\CurrentControlSet\Control\FileSystem\LongPathsEnabled`
registry value is set to 1.

Executables that already have a manifest are left unchanged.
The step requires `wine` (or `wine64`) in the build environment.
It also checks each executable with `objdump` and fails the build if
any manifest is missing.

To disable this step for an application, add this line to its
`build-assets/scripts/application.sh`:

```sh
XBB_WITH_LONG_PATH_MANIFEST="n"
```

The default is `"y"`.

The manifest and the C sources are in
`extras/windows/long-path-manifest`:

- `long-path-aware.manifest` is the manifest that gets embedded.
- `add-manifest.c` is the program that embeds it. The build compiles
  it with the mingw-w64 compiler and runs it under Wine, using the
  Win32 `UpdateResource` API.
- `long-path-check.c` is a test program for real Windows machines.
  It is not used during builds. It reports whether long paths are
  enabled for its process. With `--deep [program [args...]]`, it also
  starts a program from a folder deeper than `MAX_PATH`.

## Prerequisites to run tests on docker images

### x64 and arm64 docker images

```sh
# https://hub.docker.com/u/redhat
docker run -it redhat/ubi8

# https://hub.docker.com/_/fedora
docker run -it fedora:41
docker run -it fedora:latest

# https://hub.docker.com/u/opensuse
docker run -it opensuse/leap:15
docker run -it opensuse/leap:latest
docker run -it opensuse/tumbleweed:latest

# https://hub.docker.com/_/debian
# 12=bookworm, 11=bullseye, 10=buster
docker run -it debian:10
docker run -it debian:11
docker run -it debian:12
docker run -it debian:latest
docker run -it debian:testing

# https://hub.docker.com/_/ubuntu
docker run -it ubuntu:20.04
docker run -it ubuntu:22.04
docker run -it ubuntu:24.04
docker run -it ubuntu:latest
docker run -it ubuntu:devel

# https://hub.docker.com/_/archlinux
docker run -it archlinux:latest
```

### arm32v7 docker images

```sh
# https://hub.docker.com/u/arm32v7

docker run -it arm32v7/fedora:latest

docker run -it arm32v7/debian:bullseye
docker run -it arm32v7/debian:buster
docker run -it arm32v7/debian:latest
docker run -it arm32v7/debian:testing

docker run -it arm32v7/ubuntu:20.04
docker run -it arm32v7/ubuntu:22.04
docker run -it arm32v7/ubuntu:24.04
docker run -it arm32v7/ubuntu:latest
docker run -it arm32v7/ubuntu:devel
```

### Minimum prerequisites

RedHat/Fedora:

```sh
yum update --assumeyes
yum install --assumeyes git
```

SuSE:

```sh
zypper --no-gpg-checks update --no-confirm
zypper --no-gpg-checks install --no-confirm git-core
```

Debian/Ubuntu:

```sh
apt-get update
apt-get install --yes git-core
```

Arch (-u --sysupgrade, -y --refresh, -yy force --refresh):

```sh
pacman-key --init
pacman-key --populate archlinux
pacman --sync --noconfirm --refresh
pacman --sync --noconfirm archlinux-keyring
pacman --sync --noconfirm --sysupgrade
pacman --sync --noconfirm --noprogressbar git
```
