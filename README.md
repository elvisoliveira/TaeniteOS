# TaeniteOS - Debian Live CD Builder

A Docker-based build system for creating minimal, customizable Debian live ISOs with a functional desktop environment.

## What This Does

This project provides a simple boilerplate for building your own Debian-based live CD/USB that can be booted and installed on physical or virtual machines. It uses Debian's official `live-build` tool to assemble a bootable ISO image with:

- **Base**: Debian 12 (Bookworm)
- **Desktop**: Openbox window manager + LightDM display manager
- **File Manager**: PCManFM (with desktop icon support)
- **Minimal X11**: Just enough to run a graphical environment without bloat
- **Live User**: Pre-configured with autologin
- **Installer**: Debian installer included for permanent installation

## Quick Start

Build the ISO:

```bash
docker build -t taenite-builder .
docker run --rm --privileged \
  --security-opt apparmor=unconfined \
  --security-opt seccomp=unconfined \
  --network=host \
  -v ./output:/build/output \
  taenite-builder
```

Your ISO will be in the `output/` directory.

### Optional VirtualBox Guest Additions

Use `INSTALL_VBOX_GUEST_ADDITIONS` to control whether VirtualBox guest packages are included.

- `false` (default): no VirtualBox guest additions
- `true`: includes `virtualbox-guest-utils` and `virtualbox-guest-x11`

Build with VirtualBox guest additions enabled:

```bash
docker build --build-arg INSTALL_VBOX_GUEST_ADDITIONS=true -t taenite-builder:vbox .
docker run --rm --privileged \
  --security-opt apparmor=unconfined \
  --security-opt seccomp=unconfined \
  --network=host \
  -v ./output:/build/output \
  taenite-builder:vbox
```

You can also override at runtime (works for either image):

```bash
docker run --rm --privileged \
  --security-opt apparmor=unconfined \
  --security-opt seccomp=unconfined \
  --network=host \
  -e INSTALL_VBOX_GUEST_ADDITIONS=true \
  -v ./output:/build/output \
  taenite-builder
```

**Note**: This also works with `nerdctl` (containerd) by simply replacing `docker` with `nerdctl` in the commands above.

## Why Use This?

Instead of manually learning live-build's complex configuration, this project provides a working template you can immediately customize. Perfect for:

- Creating kiosk systems
- Building custom rescue/recovery disks
- Deploying pre-configured Linux environments
- Learning how Debian live systems work
