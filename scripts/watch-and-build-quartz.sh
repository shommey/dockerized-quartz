#!/bin/bash

# Directory where the Obsidian notes are located
WATCH_DIR=${VAULT_DIR:-/vault}

BUILD_SCRIPT="/usr/src/app/scripts/build-quartz.sh"

# Delay in seconds before triggering a build after detecting file changes
BUILD_UPDATE_DELAY=${BUILD_UPDATE_DELAY:-300}

# Timestamp of the last detected change
LAST_CHANGE=0

# PID of the scheduled build process (if any)
BUILD_SCHEDULED_PID=0

rebuild_site() {
    echo "Rebuilding site..."
    
    # Lock the build process by setting BUILD_SCHEDULED_PID to 0
    BUILD_SCHEDULED_PID=0

    $BUILD_SCRIPT

    echo "Build complete!"
}

schedule_build() {
    # If a build is already scheduled, kill the previous waiting process
    if [[ $BUILD_SCHEDULED_PID -ne 0 ]]; then
        kill $BUILD_SCHEDULED_PID 2>/dev/null
        echo "Resetting scheduled build."
    fi

    # Start the delay in the background and capture its PID
    (
        sleep $BUILD_UPDATE_DELAY

        # Once delay expires, trigger the build if no new changes occur
        rebuild_site
    ) &

    # Store the PID of the background delay process
    BUILD_SCHEDULED_PID=$!
}

# Watch the directory for changes. -r covers subfolders, which is how most
# vaults are laid out, and it picks up folders added later on its own.
echo "Watching $WATCH_DIR for changes, including subfolders..."

inotifywait -m -r -e modify,move,create,delete --exclude '.*\.swp$' --format '%w%f' "$WATCH_DIR" | \
while read file; do
    if [[ "$file" =~ \.md$ && "$file" != *"Untitled.md"* ]]; then
        LAST_CHANGE=$(date +%s)

        schedule_build
    fi
done
