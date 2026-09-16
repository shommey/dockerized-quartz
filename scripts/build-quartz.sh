#!/bin/bash

QUARTZ_DIR="/usr/src/app/quartz"
VAULT_DIR=${VAULT_DIR:-/vault}

notify() {
  if [ -n "$NOTIFY_TARGET" ]; then
    apprise -vv --title="Dockerized Quartz" --body="$1" "$NOTIFY_TARGET"
  fi
}

if [ ! -d "$VAULT_DIR" ]; then
  echo "Error: vault directory '$VAULT_DIR' does not exist."
  echo "       Mount your vault there, or set VAULT_DIR to a directory that exists in the container."
  notify "Quartz build failed: vault directory '$VAULT_DIR' does not exist."
  exit 1
fi

if [ "$VAULT_DO_GIT_PULL_ON_UPDATE" = true ]; then
  echo "Executing git pull in $VAULT_DIR"
  cd "$VAULT_DIR" && git pull || echo "Warning: git pull in '$VAULT_DIR' failed. Building the vault as it stands."
fi

cd $QUARTZ_DIR

echo "Running Quartz build from $VAULT_DIR..."
notify "Quartz build has been started."

npx quartz build --directory "$VAULT_DIR" --output /usr/share/nginx/html
BUILD_EXIT_CODE=$?

if [ $BUILD_EXIT_CODE -eq 0 ]; then
  echo "Quartz build completed successfully."
  notify "Quartz build completed successfully."
else
  echo "Quartz build failed."
  notify "Quartz build failed!"
  exit 1
fi
