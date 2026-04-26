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
copy_if_missing() {
    local source_file="$1"
    local destination_file="$2"
    local copy_error

    if [ -f "$destination_file" ]; then
        return
    fi

    if [ ! -f "$source_file" ]; then
        echo "Missing required seed file: $source_file. Verify the Docker image contains the required server files in /opt/jka-server." >&2
        exit 1
    fi

    if ! copy_error=$(cp "$source_file" "$destination_file" 2>&1); then
        echo "Failed to copy $source_file to $destination_file: $copy_error" >&2
        exit 1
    fi
}

mkdir -p /home/container/base

copy_if_missing /opt/jka-server/linuxjampded /home/container/linuxjampded
copy_if_missing /opt/jka-server/base/jampgamei386.so /home/container/base/jampgamei386.so
copy_if_missing /opt/jka-server/base/server.cfg /home/container/base/server.cfg

if ! chmod +x /home/container/linuxjampded; then
    echo "Failed to make /home/container/linuxjampded executable. Verify the file exists and /home/container is writable." >&2
    exit 1
fi

# Convert all of the "{{VARIABLE}}" parts of the startup command into the
# expected shell variable format "${VARIABLE}" and evaluate the string so that
# environment variables are expanded.
PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

# Display the command we're running in the output, then execute it.
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0m%s\n" "$PARSED"
# shellcheck disable=SC2086
exec env ${PARSED}
