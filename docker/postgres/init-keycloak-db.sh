#!/bin/bash
set -e

# Creates the Keycloak database on first initialization of the Postgres volume.
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
  -c "CREATE DATABASE \"${KEYCLOAK_DB_NAME:-keycloak}\""
