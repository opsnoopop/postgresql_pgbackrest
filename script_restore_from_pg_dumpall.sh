#!/bin/bash

# e.g.
# bash script_restore_from_pg_dumpall.sh "all_databases_20260817_110739.sql"

strFileSql=$1

if [ ! -f "${strFileSql}" ]; then
  echo "Error file.sql not exists"
  echo -e "\nbash script_restore_from_pg_dumpall.sh {file_sql}\ne.g.\nbash script_restore_from_pg_dumpall.sh \"mydatabase_20260817_105855.dump\""
  exit
fi


# way1 restore database
docker exec -i -e PGPASSWORD="kGrlCNYLHB" container-postgres18 \
psql \
-U postgres \
-f "/backup/pg_dumpall/${strFileSql}"

# way2 restore database
# docker exec -i container-postgres18 sh -c '
# PGPASSWORD="kGrlCNYLHB" \
# psql \
# -U postgres \
# -f "/backup/pg_dumpall/${strFileSql}"
# '