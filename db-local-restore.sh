# restore_local_db.sh
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
DUMP_FILE="${DUMP_FILE:-$BACKUP_DIR/prod_latest.dump}"

LOCAL_DB_CONTAINER="${LOCAL_DB_CONTAINER:-academy-db}"
LOCAL_DB_NAME="${LOCAL_DB_NAME:?Missing LOCAL_DB_NAME in .env}"
LOCAL_DB_USER="${LOCAL_DB_USER:?Missing LOCAL_DB_USER in .env}"

if [ ! -f "$DUMP_FILE" ]; then
  echo "ERROR: Dump file not found: $DUMP_FILE"
  exit 1
fi

# Logs
LOG_DIR="${LOG_DIR:-/var/log/db-migration}"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/restore_$(date +"%Y%m%d_%H%M%S").log"

# Tee all output to log (and keep exit codes from pipelines)
set -o pipefail
exec > >(tee -a "$LOG_FILE") 2>&1

echo "▶ Restore starting at $(date -Is)"
echo "   Dump:      $DUMP_FILE"
echo "   Container: $LOCAL_DB_CONTAINER"
echo "   Target DB: $LOCAL_DB_NAME"
echo "   Log file:  $LOG_FILE"
echo

# Confirmation
echo "⚠️  WARNING: This will overwrite objects in '$LOCAL_DB_NAME' inside '$LOCAL_DB_CONTAINER'."
read -r -p "Type YES to continue: " CONFIRM
if [ "$CONFIRM" != "YES" ]; then
  echo "✖ Aborted by user."
  exit 1
fi

echo
echo "▶ Running pg_restore..."

cat "$DUMP_FILE" | docker exec -i "$LOCAL_DB_CONTAINER" pg_restore \
  -U "$LOCAL_DB_USER" -d "$LOCAL_DB_NAME" \
  --clean --if-exists \
  --no-owner --no-privileges

echo
echo "✔ Restore completed at $(date -Is)"
