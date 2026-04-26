# Star Wars Jedi Academy Dedicated Server — Pterodactyl Runtime Image
# 32-bit Debian (i386) for running the linuxjampded ELF 32-bit binary.
#
# Build (run from repo root):
#   docker build --platform linux/386 -f docker/Dockerfile -t ghcr.io/akiondev/jknexus-basejka:latest .
# Push:
#   docker push ghcr.io/akiondev/jknexus-basejka:latest

FROM        --platform=linux/386 i386/debian:bookworm-slim

LABEL       author="akiondev"
LABEL       org.opencontainers.image.source="https://github.com/akiondev/jknexus-basejka"
LABEL       org.opencontainers.image.licenses=MIT
LABEL       org.opencontainers.image.description="Pterodactyl runtime image for Star Wars Jedi Academy dedicated server (32-bit Debian)"

ENV         DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies required by linuxjampded (i386 ELF binary).
# All packages here are the native 32-bit variants since the image itself is i386.
RUN         apt-get update \
            && apt-get upgrade -y \
            && apt-get install -y \
                ca-certificates \
                curl \
                wget \
                tar \
                unzip \
                zip \
                bzip2 \
                xz-utils \
                iproute2 \
                net-tools \
                netcat-traditional \
                libgcc-s1 \
                libstdc++6 \
                libc6 \
                tzdata \
            && rm -rf /var/lib/apt/lists/* \
            && useradd -m -d /home/container -s /bin/bash container

# Install the dedicated server files outside /home/container. Pterodactyl mounts
# the server volume over /home/container, so entrypoint.sh copies these files
# into the mounted volume on first startup if they are missing.
COPY        --chown=container:container jalinuxded_1.011/linuxjampded /opt/jka-server/linuxjampded
COPY        --chown=container:container jalinuxded_1.011/jampgamei386.so /opt/jka-server/base/jampgamei386.so
COPY        --chown=container:container jalinuxded_1.011/server.cfg /opt/jka-server/base/server.cfg
RUN         chmod +x /opt/jka-server/linuxjampded

# Install libcxa.so.1 into the system library path (as root) and refresh
# the dynamic linker cache so linuxjampded can find it at runtime.
COPY        jalinuxded_1.011/libcxa.so.1 /usr/lib/libcxa.so.1
RUN         ldconfig

USER        container
ENV         USER=container HOME=/home/container
ENV         DEBIAN_FRONTEND=noninteractive

WORKDIR     /home/container

COPY        docker/entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]
