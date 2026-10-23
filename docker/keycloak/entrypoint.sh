#!/bin/bash
set -e

KEYCLOAK_COMMAND=${KEYCLOAK_COMMAND:-start-dev}

if [ "$KEYCLOAK_COMMAND" = "start" ] && [ -z "$KC_HOSTNAME" ]; then
  echo "KC_HOSTNAME is required when KEYCLOAK_COMMAND=start" >&2
  exit 1
fi

# shellcheck disable=SC2086
exec /opt/keycloak/bin/kc.sh "$KEYCLOAK_COMMAND" ${KEYCLOAK_EXTRA_ARGS:-}
