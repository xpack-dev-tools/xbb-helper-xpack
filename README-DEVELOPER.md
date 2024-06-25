# Developer info

## macOS

To make the deployment target explicit, on
production machines use one of:

```sh
XBB_ENVIRONMENT_MACOSX_DEPLOYMENT_TARGET="10.13"
XBB_ENVIRONMENT_MACOSX_DEPLOYMENT_TARGET="11.0"
```

Minimum requirements and supported SDKs:

- <https://developer.apple.com/support/xcode/>

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
