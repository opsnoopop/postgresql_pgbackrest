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

## (Optional) create database mydatabase
```
docker exec container-postgres18 psql -U postgres -c "CREATE DATABASE mydatabase;"
  
  e.g.
  CREATE DATABASE
```

## (Optional) create table mytable
```
docker exec container-postgres18 psql -U postgres -d mydatabase -c "CREATE TABLE mytable (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );"
  
  e.g.
  CREATE TABLE
```

## (Optional) test insert manual
```
docker exec container-postgres18 psql -U postgres -d mydatabase -c "INSERT INTO mytable (name) VALUES ('Test 1');"
  
  e.g.
  INSERT 0 1
```



# 2. Backup
## create stanza
```
docker exec -u root container-postgres18 chown -R postgres:postgres /backup/pgbackrest /backup/pg_dumpall /backup/pg_dump
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
# ========== start way1 pgBackRest backup ==========
# pgBackRest Full backup — ทุกวันอาทิตย์ 03:05 UTC +07:00 (20:05 UTC +00:00)
5 20 * * 6 root docker exec container-postgres18 sudo -u postgres pgbackrest --stanza=mystanza --type=full backup >/dev/null 2>&1

# pgBackRest Differential backup — จันทร์-เสาร์ 03:05 UTC +07:00 (20:05 UTC +00:00)
5 20 * * 0-5 root docker exec container-postgres18 sudo -u postgres pgbackrest --stanza=mystanza --type=diff backup >/dev/null 2>&1

# pgBackRest Incremental backup — ทุกชั่วโมง เวลา xx:05 ยกเว้น 03:05 UTC +07:00 (20:05 UTC +00:00) เพราะหลบให้ FULL หรือ Differential
5 0-19,21-23 * * * root docker exec container-postgres18 sudo -u postgres pgbackrest --stanza=mystanza --type=incr backup >/dev/null 2>&1
# ========== end way1 pgBackRest backup ==========

# ========== start way2 pg_dumpall backup ==========
# pg_dumpall backup ทุก Databases ในเครื่องพร้อมกัน, backup User/Roles, backup Tablespaces, ได้เป็นข้อความ SQL (.sql) เท่านั้น ## คำสั่งที่ใช้กู้คืน psql เท่านั้น
10 20 * * * root bash /root/postgresql_pgbackrest/script_backup_pg_dumpall.sh >/dev/null 2>&1
# ========== end way2 pg_dumpall backup ==========

# ========== start way3 pg_dump backup ==========
# pg_dump backup ได้ทีละ 1 Database, ไม่่ backup User/Roles, ไม่ backup Tablespaces, Format (.sql, .dump, .tar) ## คำสั่งที่ใช้กู้คืน pg_restore (สำหรับ .dump) หรือ psql 
15 20 * * * root bash /root/postgresql_pgbackrest/script_backup_pg_dump.sh >/dev/null 2>&1
# ========== end way3 pg_dump backup ==========

# ========== start (Optional) auto insert ==========
* * * * * root bash /root/postgresql_pgbackrest/script_insert.sh >/dev/null 2>&1
# ========== end (Optional) auto insert ==========
```



# 3. Restore
## step restore 1 stop container-postgres18
```
docker stop container-postgres18
```

## step restore 2 must be delete entry data !!! before run command please check your have backup
```
docker exec container-pgbackrest \
  bash -c '
    find /var/lib/postgresql/18/docker \
      -mindepth 1 \
      -maxdepth 1 \
      -exec rm -rf {} +
  '
```

## step restore 3 check entry data 
```
docker exec container-pgbackrest ls -la /var/lib/postgresql/18/docker
```

## step restore 4 stanza info
```
docker exec container-pgbackrest pgbackrest --stanza=mystanza info
```

## step restore 5 วิธีหา เวลามากสุด last_archived_time ทีสามารถ restore ได้
```
docker exec container-postgres18 psql -U postgres -x -c "SELECT * FROM pg_stat_archiver;"
  
  e.g.
  -[ RECORD 1 ]------+------------------------------
  archived_count     | 25
  last_archived_wal  | 0000000100000000000000B2
  last_archived_time | 2026-08-15 07:55:09.315321+00
  failed_count       | 0
  last_failed_wal    | 
  last_failed_time   | 
  stats_reset        | 2026-08-15 07:31:01.95737+00
```


## step restore 6 choice time to restore
```
docker exec container-pgbackrest \
  pgbackrest \
  --stanza=mystanza \
  --type=time \
  --target="2026-08-15 07:55:09+00" \
  --target-action=promote \
  restore
```

## step restore 7 start container-postgres18
```
docker start container-postgres18
```