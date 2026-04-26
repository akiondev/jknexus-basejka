#!/bin/bash
#
# Pterodactyl entrypoint for the JKA dedicated server.
#
set -e

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Switch to the container's working directory
cd /home/container || exit 1

# Seed the Pterodactyl server volume from the image when the required files are
# missing. Existing user files are preserved, including custom server.cfg.
for seed_file in \
    /opt/jka-server/linuxjampded \
    /opt/jka-server/base/jampgamei386.so \
    /opt/jka-server/base/server.cfg
do
    if [ ! -f "$seed_file" ]; then
        echo "Missing required seed file: $seed_file" >&2
        exit 1
    fi
done

mkdir -p /home/container/base

if [ ! -f /home/container/linuxjampded ]; then
    cp /opt/jka-server/linuxjampded /home/container/linuxjampded
fi

if [ ! -f /home/container/base/jampgamei386.so ]; then
    cp /opt/jka-server/base/jampgamei386.so /home/container/base/jampgamei386.so
fi

if [ ! -f /home/container/base/server.cfg ]; then
    cp /opt/jka-server/base/server.cfg /home/container/base/server.cfg
fi

chmod +x /home/container/linuxjampded

# Convert all of the "{{VARIABLE}}" parts of the startup command into the
# expected shell variable format "${VARIABLE}" and evaluate the string so that
# environment variables are expanded.
PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

# Display the command we're running in the output, then execute it.
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0m%s\n" "$PARSED"
# shellcheck disable=SC2086
exec env ${PARSED}
