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

# Build the ISO
lb build

# Copy ISO to output directory
find /build -name "*.iso" -type f -exec cp -v {} /build/output/ \;

echo "Build completed. Check output directory for the ISO file."
