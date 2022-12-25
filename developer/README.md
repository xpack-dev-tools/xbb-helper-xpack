# Developer info

For reproducible reasons, the production builds run inside Docker
containers, but for development and experimentation, it is perfectly
possible to run them on plain machines, GNU/Linux or macOS.

The Windows binaries are also compiled on GNU/Linux, using mingw-w64-gcc.

There are no native Windows builds; use WSL or virtual machines to run the
builds on Windows.

## Prerequisites

### node/npm/xpm

As for all xPack tools, to install the build dependencies and run the builds,
a recent [xpm](https://xpack.github.io/xpm/),
which is a portable [Node.js](https://nodejs.org/) command line application,
is needed.

It is recommended to update to the latest version with:

```sh
npm install --location=global xpm@latest
```

For details please follow the instructions in the
[xPack install](https://xpack.github.io/install/) page.

### GNU/Linux

The current binary packages are built on Ubuntu 18 LTS (both Intel and Arm),
and, in order to minimise surprises, it is recommended
to also use an Ubuntu, possibly newer;
however, with some tweaking, most modern distributions
should probably do it as well.

To install the Ubuntu 18 packages, use the available script:

```sh
bash ~/Work/xbb-helper-xpack.git/developer/ubuntu/install-dependencies.sh
```

### macOS

For macOS, a recent Xcode Command Line Tools (CLT) must be installed.

The xPack Build Box scripts do their best to manage dependencies to
local binary packages, but it is always a good idea to avoid
installing any other development tools (like HomeBrew) in
any system folders.

### Visual Studio Code

All steps in the workflow
can be run from a terminal, and the scripts can be editted with
any text editor, thus VSCode is not really a prerequisite.

However, all actions are also defined as **xPack actions** and can
be conveniently triggered via the VS Code graphical interface, using the
[xPack extension](https://marketplace.visualstudio.com/items?itemName=ilg-vscode.xpack).

## Native builds

TBD
