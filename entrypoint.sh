#!/bin/sh

set -e

export TRANSMISSION_RPC_AUTHENTICATION_REQUIRED=${TRANSMISSION_RPC_AUTHENTICATION_REQUIRED:-false}

CONFIG_DIR="/app/config"

DEFAULT_SLURP_PATH="/default-slurp.json"
SLURP_PATH="${CONFIG_DIR}/slurp.json"
DEFAULT_SETTINGS_PATH="/default-settings.json"
SETTINGS_PATH="${CONFIG_DIR}/settings.json"

if [ ! -f "${SETTINGS_PATH}" ]; then
    cp "${DEFAULT_SETTINGS_PATH}" "${SETTINGS_PATH}"
fi

cat "${DEFAULT_SLURP_PATH}" | envsubst > "${SLURP_PATH}"

jq --slurpfile slurp "${SLURP_PATH}" '. + $slurp[]' "${SETTINGS_PATH}" > "${SETTINGS_PATH}2"
mv "${SETTINGS_PATH}2" "${SETTINGS_PATH}"
rm "${SLURP_PATH}"

exec /usr/bin/transmission-daemon \
    --foreground \
    --config-dir "/app/config" \
    --watch-dir "/app/torrents" \
    --logfile /dev/stdout \
    "$@"
