A project for area 18, "Oracle compatibility and incremental migration" for the [MariaDB student database projects, 2026-09](https://mariadb.org/bachelor_hackathon_2026-09/).

# QuerySync

We test how much real Oracle PL/SQL runs on MariaDB with `sql_mode=ORACLE`, using Oracle Database Free as the reference. Work in progress.

## Requirements

- Docker Desktop (on Windows, WSL2 must be enabled)
- Git

## Setup

1. Clone the repo and enter the folder:
   ```bat
   git clone https://github.com/Vrindapvt16/QuerySync.git
   cd QuerySync
   ```
2. Create your own `.env` **before the first start** and edit the values:
   ```bat
   copy .env.example .env
   ```
3. Start both databases (the first start downloads a few GB):
   ```bat
   docker compose up -d
   docker compose ps
   ```
4. Wait until `oracle-free` shows `(healthy)`.

## Connect

Oracle (use the user and password from your `.env`):
```bat
docker exec -it oracle-free sqlplus YOUR_USER/YOUR_PASSWORD@FREEPDB1
```

MariaDB (asks for `MARIADB_ROOT_PASSWORD` from your `.env`):
```bat
docker exec -it mariadb-oracle-mode mariadb -uroot -p
```

## Notes

- Passwords in `.env` are only applied when a database is first created. If you change them later, run `docker compose down -v` so the databases are recreated. This deletes their data.
- Versions used so far: MariaDB 11.8.9 (`sql_mode=ORACLE`) and Oracle Database Free 23.26.

## Repository contents

- `sql/oracle/`: PL/SQL practice scripts
- `findings.md`: what we have observed so far, Oracle versus MariaDB