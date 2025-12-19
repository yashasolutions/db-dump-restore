# Database Backup & Restore System

This repository contains scripts for backing up a remote PostgreSQL database and restoring it to a local Docker container.

## Overview

The system consists of two main scripts:
- **Remote Dump**: Creates compressed backups from a remote PostgreSQL database
- **Local Restore**: Restores backups to a local PostgreSQL database running in Docker

## Files

- `db-remote-dump.sh` - Creates timestamped dumps from remote database using Docker
- `db-local-restore.sh` - Restores dumps to local Docker database with confirmation prompts
- `env-sample` - Template for environment configuration
- `.gitignore` - Excludes `.env` files and aider artifacts

## Setup

1. **Copy environment template:**
   ```bash
   cp env-sample .env
   ```

2. **Configure your environment variables in `.env`:**
   - Remote database connection details (host, port, database, user, password)
   - Local Docker container name and database details
   - Optional: custom backup/log directories

3. **Make scripts executable:**
   ```bash
   chmod +x db-remote-dump.sh db-local-restore.sh
   ```

## Usage

### Creating a Remote Database Dump

```bash
./db-remote-dump.sh
```

This will:
- Connect to your remote PostgreSQL database using Docker
- Create a compressed dump file with timestamp: `prod_YYYYMMDD_HHMMSS.dump`
- Store it in the backup directory (default: `/data/db-import`)
- Create/update a `prod_latest.dump` symlink pointing to the newest dump

### Restoring Database Locally

```bash
./db-local-restore.sh
```

This will:
- Prompt for confirmation (type "YES" to proceed)
- Restore the latest dump (or specified dump file) to your local Docker database
- Use `--clean --if-exists` flags to safely overwrite existing objects
- Log all output to timestamped log files

## Environment Variables

### Required
- `REMOTE_PGHOST` - Remote database hostname
- `REMOTE_PGDATABASE` - Remote database name
- `REMOTE_PGUSER` - Remote database username
- `REMOTE_PGPASSWORD` - Remote database password
- `LOCAL_DB_NAME` - Local database name
- `LOCAL_DB_USER` - Local database username

### Optional
- `REMOTE_PGPORT` - Remote database port (default: 5432)
- `LOCAL_DB_CONTAINER` - Local Docker container name (default: academy-db)
- `BACKUP_DIR` - Backup storage directory (default: /data/db-import)
- `LOG_DIR` - Log file directory (default: /var/log/db-migration)
- `DUMP_FILE` - Specific dump file to restore (default: latest)

## Safety Features

- **Confirmation prompts** before destructive operations
- **Comprehensive logging** with timestamps
- **Error handling** with `set -euo pipefail`
- **Clean restore** that safely handles existing database objects
- **Timestamped backups** to prevent accidental overwrites

## Requirements

- Docker (for running PostgreSQL client)
- Bash shell
- Access to remote PostgreSQL database
- Local Docker container running PostgreSQL
