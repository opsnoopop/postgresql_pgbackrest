#!/bin/bash

# path in container
DIRPATH="/backup/pg_dumpall"

# ===== start delete rotate 30 day ago =====
strFormatDate=$(date --date='-29 day' +%Y-%m-%d)
find ${DIRPATH} -regextype posix-egrep -regex ".*(\.(sql|dump|tar))$" -not -newermt "${strFormatDate}" -exec rm -f {} +
# ===== end delete rotate 30 day ago =====

# way1
docker exec -e PGPASSWORD="kGrlCNYLHB" container-postgres18 \
pg_dumpall \
-h "localhost" \
-p "5432" \
-U "postgres" \
-v \
-f "${DIRPATH}/all_databases_$(date +%Y%m%d_%H%M%S).sql"


# way2
# docker exec container-postgres18 sh -c '
# PGPASSWORD="kGrlCNYLHB" \
# pg_dumpall \
# -h "localhost" \
# -p "5432" \
# -U "postgres" \
# -v \
# -f "${DIRPATH}/all_databases_$(date +%Y%m%d_%H%M%S).sql"
# '