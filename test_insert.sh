#!/bin/bash

export PGPASSWORD="kGrlCNYLHB"

HOST="127.0.0.1"
PORT="5432"
USER="postgres"
DB="mydatabase"

NAME="Auto Insert $(date '+%Y-%m-%d %H:%M:%S')"
psql \
  -h "$HOST" \
  -p "$PORT" \
  -U "$USER" \
  -d "$DB" \
  -v ON_ERROR_STOP=1 \
  -c "INSERT INTO mytable (name, created_at)
      VALUES ('$NAME', NOW());"