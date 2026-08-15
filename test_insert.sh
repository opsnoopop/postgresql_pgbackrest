#!/bin/bash

NAME="Auto Insert $(date '+%Y-%m-%d %H:%M:%S')"
docker exec container-postgres18 psql -U postgres -d mydatabase -c "INSERT INTO mytable (name) VALUES ('$NAME');"