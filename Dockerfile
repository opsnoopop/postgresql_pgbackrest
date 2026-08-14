FROM postgres:18

RUN apt-get update \
    && apt-get install -y vim sudo \
    && apt-get install -y --no-install-recommends \
       pgbackrest \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /backup/pgbackrest /var/log/pgbackrest \
    && chown -R postgres:postgres \
       /backup/pgbackrest \
       /var/log/pgbackrest