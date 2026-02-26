#!/bin/bash
set -e
cd /build

# Configure live-build
lb config \
  --distribution bookworm \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --bootappend-live "boot=live components hostname=TaeniteOS username=taenite user-password=taenite quiet splash" \
  --iso-application "TaeniteOS" \
  --iso-publisher "Custom Distribution" \
  --iso-volume "TaeniteOS 1.0" \
  --mirror-bootstrap "http://deb.debian.org/debian" \
  --mirror-binary "http://deb.debian.org/debian" \
  --apt-recommends false \
  --debian-installer live

# Make hooks executable
find /build/config/hooks/ -type f -name "*.hook.*" -exec chmod +x {} \;

# Copy wallpapers into the live filesystem
mkdir -p /build/config/includes.chroot/usr/share/backgrounds/taenite
cp -r /build/assets/wallpapers/* /build/config/includes.chroot/usr/share/backgrounds/taenite/

# Copy icons into the live filesystem
mkdir -p /build/config/includes.chroot/usr/share/pixmaps/taenite
cp -r /build/assets/icons/* /build/config/includes.chroot/usr/share/pixmaps/taenite/

# Copy app environment config into skel home
mkdir -p /build/config/includes.chroot/etc/skel/.config/taenite/
cp /build/assets/configs/* /build/config/includes.chroot/etc/skel/.config/taenite/

# Copy custom printer PPDs into the live filesystem
mkdir -p /build/config/includes.chroot/etc/cups/ppd
cp /build/assets/ppds/* /build/config/includes.chroot/etc/cups/ppd/

# Copy custom CUPS filters into the live filesystem
mkdir -p /build/config/includes.chroot/usr/lib/cups/filter
cp /build/assets/filters/* /build/config/includes.chroot/usr/lib/cups/filter/

# Optional VirtualBox guest additions
INSTALL_VBOX_GUEST_ADDITIONS="${INSTALL_VBOX_GUEST_ADDITIONS:-false}"
echo "Install VirtualBox guest additions: $INSTALL_VBOX_GUEST_ADDITIONS"

VBOX_LIST_FILE="/build/config/package-lists/virtualbox-guest.list.chroot"
if [ "$INSTALL_VBOX_GUEST_ADDITIONS" != "true" ]; then
  rm -f "$VBOX_LIST_FILE"
fi

# Build the ISO
lb build

# Copy ISO to output directory
find /build -name "*.iso" -type f -exec cp -v {} /build/output/ \;

echo "Build completed. Check output directory for the ISO file."
