#!/bin/bash

# path in container
DIRPATH="/backup/pg_dump"

# ===== start delete rotate 30 day ago =====
strFormatDate=$(date --date='-29 day' +%Y-%m-%d)
find ${DIRPATH} -regextype posix-egrep -regex ".*(\.(sql|dump|tar))$" -not -newermt "${strFormatDate}" -exec rm -f {} +
# ===== end delete rotate 30 day ago =====

# way1
docker exec -e PGPASSWORD="kGrlCNYLHB" container-postgres18 \
pg_dump \
-h "localhost" \
-p "5432" \
-U "postgres" \
-d "mydatabase" \
-Fc \
-b \
-v \
-f "${DIRPATH}/mydatabase_$(date +%Y%m%d_%H%M%S).dump"


# way2
# docker exec container-postgres18 sh -c '
# PGPASSWORD="kGrlCNYLHB" \
# pg_dump \
# -h "localhost" \
# -p "5432" \
# -U "postgres" \
# -d "mydatabase" \
# -Fc \
# -b \
# -v \
# -f "${DIRPATH}/mydatabase_$(date +%Y%m%d_%H%M%S).dump"
# '