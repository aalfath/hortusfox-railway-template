#!/bin/bash
# Runs after the image's docker-entrypoint.sh has migrated the database and created
# the first admin. That script doesn't stop on errors, so check the result here.
set -e
DATA_DIR="${DATA_DIR:-/data}"

admins=$(mysql -u "$DB_USERNAME" -p"$DB_PASSWORD" -h "$DB_HOST" -P "$DB_PORT" -D "$DB_DATABASE" \
  -N -s -e "SELECT COUNT(*) FROM UserModel WHERE admin = 1;" 2>/dev/null || echo 0)
if [ "${admins:-0}" -lt 1 ]; then
  echo "Setup failed: no admin account in the database (see the migration output above)." >&2
  exit 1
fi

# Apply the real APP_DEBUG value (setup needed it on).
if [ "$RAILWAY_APP_DEBUG" != "true" ]; then
  sed -ri 's/^([[:space:]]*)APP_DEBUG=.*/\1APP_DEBUG=false/' /var/www/html/.env
  printf 'error_reporting = E_ALL & ~E_NOTICE & ~E_WARNING & ~E_DEPRECATED\ndisplay_errors = Off\n' \
    > /usr/local/etc/php/conf.d/errors.ini
fi

# The image's chown calls don't follow the /data links, so give the web server the data folders.
chown -R www-data:www-data "$DATA_DIR"/img "$DATA_DIR"/attachments "$DATA_DIR"/backup \
  "$DATA_DIR"/themes "$DATA_DIR"/migrations "$DATA_DIR"/logs
exec apache2-foreground
