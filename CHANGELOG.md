# Changelog

## v6.4 (2026-11-16)

- First release of the Railway template: HortusFox v6.4 (`ghcr.io/danielbrendel/hortusfox-web:v6.4`, pinned by digest) with MariaDB 11.8.9.
- Apache listens on Railway's `PORT`. All app data (photos, attachments, backups, themes, migration list, logs) lives on one volume at `/data`.
- The first admin account is created from `APP_ADMIN_EMAIL` and a generated `APP_ADMIN_PASSWORD`. `APP_DEBUG` defaults to `false`.
