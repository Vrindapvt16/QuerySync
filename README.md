# QuerySync

A project for Area 18, **Oracle Compatibility and Incremental Migration**, for the [MariaDB Student Database Projects 2026-09](https://mariadb.org/bachelor_hackathon_2026-09/).

QuerySync investigates how much real Oracle PL/SQL can run on MariaDB using `sql_mode=ORACLE`, with Oracle Database Free as the reference environment.

**Status:** Work in progress.

## Requirements

- Docker Desktop (Windows users must have WSL2 enabled).
- Git.
- VS Code or another text editor (recommended).

## Setup

### 1. Clone the repository

```bat
git clone https://github.com/Vrindapvt16/QuerySync.git
cd QuerySync
```

### 2. Configure environment variables

Create your local `.env` file:

```bat
copy .env.example .env
```

Edit `.env` and configure your database credentials.

**Important:** Do this before the first startup.

### 3. Start the databases

```bat
docker compose up -d
```

Check container status:

```bat
docker compose ps
```

Wait until `oracle-free` reports `(healthy)` before connecting to Oracle.

The first startup downloads the database images and initializes the databases. This may take some time.

## Connect

### Oracle Database Free

```bat
docker exec -it oracle-free sqlplus YOUR_USER/YOUR_PASSWORD@FREEPDB1
```

Replace the credentials with those configured in `.env`.

### MariaDB

```bat
docker exec -it mariadb-oracle-mode mariadb -uroot -p
```

Enter the MariaDB root password from `.env`.

Check Oracle mode:

```sql
SELECT @@SESSION.sql_mode;
```

If necessary:

```sql
SET SESSION sql_mode = 'ORACLE';
```

## Running SQL files

MariaDB's `SOURCE` command executes SQL files directly from the container filesystem.

Our Docker configuration mounts:

```text
Host:      ./sql/mariadb/
Container: /scripts/
```

### 1. Independent SQL experiments

Connect to MariaDB and select the practice database:

```sql
CREATE DATABASE IF NOT EXISTS sql_practice;
USE sql_practice;
```

Run an individual script:

```sql
SOURCE /scripts/pra.sql;
```

Other scripts can be executed similarly:

```sql
SOURCE /scripts/f1.sql;
SOURCE /scripts/f2.sql;
```

Place your practice SQL files inside `sql/mariadb/`.

### 2. HR migration

The HR migration uses a separate database.

```sql
USE hr;
SET SESSION sql_mode = 'ORACLE';
```

Run the migration scripts in order:

```sql
SOURCE /scripts/hr_create.sql;
SOURCE /scripts/hr_populate.sql;
SOURCE /scripts/hr_code.sql;
```

**Note:** These scripts modify the HR database. Check their contents before rerunning them.

## Repository structure

```text
QuerySync/
│
├── corpus/                 # Test corpus
├── logs/                   # Execution logs
├── official/               # Official reference material
│
├── sql/
│   ├── oracle/              # Original Oracle scripts
│   └── mariadb/             # MariaDB scripts and experiments
│
├── findings.md              # Migration findings and test results
├── docker-compose.yml
├── .env.example
└── README.md
```

## Documentation

See [findings.md](findings.md) for:

- Oracle versus MariaDB compatibility results.
- SQL and PL/SQL migration issues.
- Tested features and unsupported syntax.
- Errors, workarounds and adapted implementations.
- Ongoing investigations.

## Important notes

- Never commit your `.env` file or database passwords.
- Changing `.env` does not automatically update credentials in already initialized database volumes.
- `docker compose down` stops the containers while preserving database data.
- **Avoid `docker compose down -v` unless you intentionally want to delete all database volumes and their data.**

## Project information

**Project:** QuerySync  
**Area:** 18 – Oracle Compatibility and Incremental Migration  
**Reference:** [MariaDB Student Database Projects 2026-09](https://mariadb.org/bachelor_hackathon_2026-09/)

*Work in progress.*


docker exec -it mariadb-oracle-mode mariadb -uroot -p
USE sql_practice;
SOURCE /scripts/t/type_varchar2.sql;
