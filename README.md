# 1. init
```
git clone https://github.com/opsnoopop/postgresql_pgbackrest.git
cd postgresql_pgbackrest
docker compose up -d --build
```

## check archive_mode
```
docker exec container-postgres18 psql -U postgres -c "SHOW archive_mode;"
  e.g.
  archive_mode 
  --------------
  on
  (1 row)
```

## check archive_command
```
docker exec container-postgres18 psql -U postgres -c "SHOW archive_command;"
  e.g.
  archive_command                
  -----------------------------------------------
  pgbackrest --stanza=mystanza archive-push %p
  (1 row)
```

## check archive_timeout
```
docker exec container-postgres18 psql -U postgres -c "SHOW archive_timeout;"
  e.g.
  archive_timeout 
  -----------------
  1min
  (1 row)
```

## create database mydatabase
```
docker exec container-postgres18 psql -U postgres -c "CREATE DATABASE mydatabase;"
  e.g.
  CREATE DATABASE
```

## create table mytable
```
docker exec container-postgres18 psql -U postgres -d mydatabase -c "CREATE TABLE mytable (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );"
  e.g.
  CREATE TABLE
```

## test insert manual
```
docker exec container-postgres18 psql -U postgres -d mydatabase -c "INSERT INTO mytable (name) VALUES ('Test 1');"
  e.g.
  INSERT 0 1
```



# 2. Backup
## create stanza
```
docker exec -u root container-postgres18 chown -R postgres:postgres /backup/pgbackrest
docker exec container-postgres18 sudo -u postgres pgbackrest --stanza=mystanza stanza-create
  e.g.
  ...
  INFO: stanza-create command end: completed successfully
```

## check stanza
```
docker exec container-postgres18 sudo -u postgres pgbackrest --stanza=mystanza check
  e.g.
  ...
  INFO: check command end: completed successfully
```

## start full backup
```
docker exec container-postgres18 sudo -u postgres pgbackrest --stanza=mystanza --type=full backup
  e.g.
  ...
  INFO: expire command end: completed successfully
```

## stanza info
```
docker exec container-pgbackrest pgbackrest --stanza=mystanza info
```

## edit crontab
vim /etc/crontab
``` crontab
# Full Backup — ทุกวันอาทิตย์ เวลา 03:05
5 3 * * 0 root docker exec container-postgres18 sudo -u postgres pgbackrest --stanza=mystanza --type=full backup >/dev/null 2>&1

# Differential Backup — จันทร์-เสาร์ เวลา 03:05
5 3 * * 1-6 root docker exec container-postgres18 sudo -u postgres pgbackrest --stanza=mystanza --type=diff backup >/dev/null 2>&1

# Incremental Backup — ทุกชั่วโมง เวลา xx:05 ยกเว้น 03:05 เพราะหลบให้ FULL หรือ DIFF
5 0-2,4-23 * * * root docker exec container-postgres18 sudo -u postgres pgbackrest --stanza=mystanza --type=incr backup >/dev/null 2>&1

# Insert Test Data — ทุกนาที
* * * * * root /root/postgresql_pgbackrest/bash test_insert.sh >/dev/null 2>&1
```



# 3. Restore
## step restore 1 stop container-postgres18
docker stop container-postgres18

## step restore 2 delete data
docker exec container-pgbackrest \
  bash -c '
    find /var/lib/postgresql/18/docker \
      -mindepth 1 \
      -maxdepth 1 \
      -exec rm -rf {} +
  '

## step restore 3 check entry data 
docker exec container-pgbackrest ls -la /var/lib/postgresql/18/docker

## step restore 4 stanza info
docker exec container-pgbackrest pgbackrest --stanza=mystanza info

## step restore 5 restore
docker exec container-pgbackrest \
  pgbackrest \
  --stanza=mystanza \
  --type=time \
  --target="2026-08-14 09:47:49+00" \
  --target-action=promote \
  restore

## step restore 6 start container-postgres18
docker start container-postgres18