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

To show the repos status:

```sh
bash ~/Work/xbb-helper-xpack.git/maintainer/build-all.sh --status
```
