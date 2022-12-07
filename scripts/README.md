# scripts

There are multiple scripts, most of them being included with `source`.

## `scripts/common-build.sh`

A script that defines the `build_perform_common()` function, which can be
called in the application build scripts to perform the full build.

## `scripts/test-common.sh`

A script that defines the `tests_perform_common()` function, which can be
called in the application test scripts.

## Native dependencies

By default, the build target is automatically set to macOS, Linux or
mingw-w64, based on the configuration used.

On macOS and Linux this is always the native target.

On Windows, if there are native dependencies to build before the Windows
binaries, the following variable can be set in `application.sh`:

```sh
XBB_APPLICATION_INITIAL_TARGET="native"
```

After the native dependencies are built, set the target:

```sh
xbb_set_target "requested"

xbb_set_executables_install_path "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}"
xbb_set_libraries_install_path "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}"
```

To access the native binaries, the packages should invoke:

```sh
xbb_activate_installed_bin
```

Note: the `XBB_DEPENDENCIES_INSTALL_FOLDER_PATH` is redefined, so the
`xbb_set_*` need to be set again.

