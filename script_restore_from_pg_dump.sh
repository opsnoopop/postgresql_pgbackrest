#!/bin/bash

# e.g.
# bash script_restore_from_pg_dump.sh "mydatabase_bk" "mydatabase_20260817_105855.dump"

strDatabaseName=$1
strFileSql=$2

if [[
  ${strDatabaseName} = "postgres"
  || ${strDatabaseName} = "mydatabase"
]]; then
  echo -e "Error database name not allow\npostgres\npostgres\nmydatabase"
  exit
fi

if [ ! -f "${strFileSql}" ]; then
  echo "Error file.dump not exists"
  echo -e "\nbash script_restore_from_pg_dump.sh {target_database_name} {file_dump}\ne.g.\nbash script_restore_from_pg_dump.sh \"mydatabase_bk\" \"mydatabase_20260817_105855.dump\""
  exit
fi


# way1 create database
docker exec -e PGPASSWORD="kGrlCNYLHB" container-postgres18 \
createdb \
-h "localhost" \
-p "5432" \
-U "postgres" \
"${strDatabaseName}"

# way1 restore database
docker exec -e PGPASSWORD="kGrlCNYLHB" container-postgres18 \
pg_restore \
-h "localhost" \
-p "5432" \
-U "postgres" \
-d "${strDatabaseName}" \
--clean \
--if-exists \
--no-owner \
"/backup/pg_dump/${strFileSql}"


# way2 create database
# docker exec container-postgres18 sh -c '
# PGPASSWORD="kGrlCNYLHB" \
# createdb \
# -h "localhost" \
# -p "5432" \
# -U "postgres" \
# "${strDatabaseName}"
# '

# way2 restore database
# docker exec container-postgres18 sh -c '
# PGPASSWORD="kGrlCNYLHB" \
# pg_restore \
# -h "localhost" \
# -p "5432" \
# -U "postgres" \
# -d "${strDatabaseName}" \
# --clean \
# --if-exists \
# --no-owner \
# "/backup/pg_dump/${strFileSql}"
# '