# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /
COPY system_files /system_files
COPY homefiles /homefiles

# Base Image
FROM ghcr.io/ublue-os/bluefin-dx:stable-daily
## Other possible base images:
# FROM ghcr.io/ublue-os/bluefin-dx:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia-open:stable
# FROM ghcr.io/ublue-os/aurora:stable
# FROM ghcr.io/ublue-os/bazzite:stable

### [IM]MUTABLE /opt
## Uncomment to make /opt immutable (required for some packages like google-chrome):
# RUN rm /opt && mkdir /opt

### MODIFICATIONS
## build.sh installs packages, copies system_files to /, and seeds /etc/skel
## with the homefiles tree so every new user gets the full Sway config.

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

### LINTING
RUN bootc container lint
