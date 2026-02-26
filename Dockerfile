FROM debian:12

# Basic setup
RUN apt-get update && apt-get install -y \
    live-build

# Optional feature toggle for VirtualBox guest additions
ARG INSTALL_VBOX_GUEST_ADDITIONS=false
ENV INSTALL_VBOX_GUEST_ADDITIONS=${INSTALL_VBOX_GUEST_ADDITIONS}

WORKDIR /build

# Copy config and build script
COPY config/ /build/config/
COPY assets/ /build/assets/
COPY build.sh /build/build.sh

# Create output directory
RUN mkdir -p /build/output

# Make script executable
RUN chmod +x /build/build.sh

CMD ["/build/build.sh"]
