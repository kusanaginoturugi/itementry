#!/usr/bin/env bash
set -euo pipefail

APP_DIR=/home/onoue/src/itementry          # アプリパス
DB_PATH="$APP_DIR/storage/production.sqlite3"    # 本番DB
DEST_DIR="$APP_DIR/dbbackup" 
STAMP=$(date +"%Y%m%d-%H%M%S")
OUT="$DEST_DIR/production-$STAMP.sqlite3"

# SQLiteの安全なバックアップ
sqlite3 "$DB_PATH" ".backup '$OUT'"

# 圧縮（任意）
gzip -9 "$OUT" && OUT="$OUT.gz"

# 7日より古いバックアップを削除
find "$DEST_DIR" -name "production-*.sqlite3.gz" -mtime +7 -delete
