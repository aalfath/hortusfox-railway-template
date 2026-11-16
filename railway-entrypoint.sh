#!/bin/bash
# Railway wrapper for the official HortusFox image (ghcr.io/danielbrendel/hortusfox-web).
set -e

# Safe defaults for settings the template doesn't ask for.
# The image's setup CLI (migrations, seed data) refuses to run unless APP_DEBUG=true,
# so setup runs in debug mode and railway-apache.sh applies the real value
# (default false) before Apache starts.
export RAILWAY_APP_DEBUG="${APP_DEBUG:-false}"
export APP_DEBUG=true
export APP_TIMEZONE="${APP_TIMEZONE:-UTC}"
export DB_PORT="${DB_PORT:-3306}"
export DB_CHARSET="${DB_CHARSET:-utf8mb4}"

if [ -z "$APP_ADMIN_EMAIL" ] || [ -z "$APP_ADMIN_PASSWORD" ]; then
  echo "APP_ADMIN_EMAIL and APP_ADMIN_PASSWORD must be set (the first admin account)." >&2
  exit 1
fi
for v in DB_HOST DB_DATABASE DB_USERNAME DB_PASSWORD; do
  if [ -z "${!v}" ]; then echo "$v must be set." >&2; exit 1; fi
done

# Apache listens on Railway's PORT (80 when it isn't set).
PORT="${PORT:-80}"
sed -ri "s/^Listen [0-9]+$/Listen ${PORT}/" /etc/apache2/ports.conf
sed -ri "s/<VirtualHost \*:[0-9]+>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf

# Railway gives a service one volume, so every data directory the image declares
# as a VOLUME lives in a subfolder of /data, linked into place.
DATA_DIR="${DATA_DIR:-/data}"
mkdir -p "$DATA_DIR"
link_dir() {
  local path="$1" name="$2"
  mkdir -p "$DATA_DIR/$name"
  if [ -L "$path" ]; then
    return 0
  fi
  if mountpoint -q "$path" 2>/dev/null; then
    echo "$path is a separate mount, leaving it as it is."
    return 0
  fi
  rm -rf "$path"
  ln -s "$DATA_DIR/$name" "$path"
}
link_dir /var/www/html/public/img         img
link_dir /var/www/html/public/attachments attachments
link_dir /var/www/html/public/backup      backup
link_dir /var/www/html/public/themes      themes
link_dir /var/www/html/app/migrations     migrations
link_dir /var/www/html/app/logs           logs

exec /usr/local/bin/docker-entrypoint.sh "$@"
