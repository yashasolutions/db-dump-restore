# dump_remote_db.sh
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: .env file not found at $ENV_FILE"
  exit 1
fi

# Load env vars from .env
set -a
source "$ENV_FILE"
set +a

BACKUP_DIR="${BACKUP_DIR:-/data/db-import}"
TIMESTAMP="$(date +"%Y%m%d_%H%M%S")"
DUMP_BASENAME="prod_${TIMESTAMP}.dump"
DUMP_FILE="$BACKUP_DIR/$DUMP_BASENAME"
LATEST_LINK="$BACKUP_DIR/prod_latest.dump"

mkdir -p "$BACKUP_DIR"

echo "▶ Dumping remote DB to $DUMP_FILE"

docker run --rm \
  -e PGHOST="$REMOTE_PGHOST" \
  -e PGPORT="${REMOTE_PGPORT:-5432}" \
  -e PGDATABASE="$REMOTE_PGDATABASE" \
  -e PGUSER="$REMOTE_PGUSER" \
  -e PGPASSWORD="$REMOTE_PGPASSWORD" \
  -v "$BACKUP_DIR:/backup" \
  postgres:15 \
  bash -lc "pg_dump -Fc > /backup/$DUMP_BASENAME"

# Update "latest" symlink
ln -sf "$DUMP_BASENAME" "$LATEST_LINK"

echo "✔ Dump completed"
echo "   Latest: $LATEST_LINK -> $DUMP_BASENAME"
