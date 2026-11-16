[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/hortusfox-1?utm_medium=integration&utm_source=button&utm_campaign=hortusfox)

# HortusFox on Railway

A Railway template for [HortusFox](https://github.com/danielbrendel/hortusfox-web), a self-hosted, collaborative plant management app: plants, locations, tasks, a calendar, inventory, photos and a group chat for everyone who looks after the plants.

## What it deploys

| Service | Source | Volume |
|---|---|---|
| **HortusFox** | this repo: `ghcr.io/danielbrendel/hortusfox-web:v6.4`, pinned by digest, plus a small start script | `/data` (photos, attachments, backups, themes, migration list, logs) |
| **MariaDB** | `mariadb:11.8.9`, pinned by digest | `/var/lib/mysql` |

The web service listens on Railway's `PORT` and gets a public Railway domain. HortusFox reaches MariaDB over Railway's private network. The health check path is `/auth` (the login page).

## Variables

| Variable | Default | Notes |
|---|---|---|
| `APP_ADMIN_EMAIL` | (you enter it) | E-mail of the first admin account. You log in with it. |
| `APP_ADMIN_PASSWORD` | generated secret | Password of the first admin account. Read it from the service's Variables tab, then change it in your profile. Changing the variable later doesn't change an existing account. |
| `APP_TIMEZONE` | `UTC` | Time zone for reminders and dates, for example `Europe/Berlin`. |
| `DB_HOST`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD` | references to the MariaDB service | Leave as they are. |

Other image settings keep the upstream defaults. `APP_DEBUG` defaults to `false`. SMTP (password resets, task reminders) and the cron jobs for reminders and automatic backups are set up later in HortusFox's admin area: see the [HortusFox docs](https://github.com/danielbrendel/hortusfox-web#readme).

## What the wrapper changes

- `railway-entrypoint.sh` keeps only Apache's prefork MPM (Railway's image unpacking otherwise brings back `mpm_event`, and Apache refuses to start), makes Apache listen on `PORT`, links every data folder the image keeps (`public/img`, `public/attachments`, `public/backup`, `public/themes`, `app/migrations`, `app/logs`) into the one volume at `/data`, and then runs the image's own `docker-entrypoint.sh` (database migrations, first admin).
- HortusFox's setup commands only run with `APP_DEBUG=true`, so setup runs in debug mode and `railway-apache.sh` switches debug off before Apache starts. It also stops the deploy if setup didn't create an admin account, so a broken setup fails the deploy instead of passing the health check.
- `railway-proxy.php` (loaded with `auto_prepend_file`) tells PHP the request came in over HTTPS when Railway's edge says so, so links use `https://YOUR-DOMAIN/` and not `http://YOUR-DOMAIN:8080/`.

## Updates

Changes to this template are merged to `main`. Railway then shows everyone who deployed it an "update available" notice, and you choose when to apply it. Read `CHANGELOG.md` first: HortusFox runs its database migrations on start, so back up the `/data` and MariaDB volumes before a major update.
