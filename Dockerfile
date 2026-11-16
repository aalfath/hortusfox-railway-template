# HortusFox for Railway: the official image, pinned by version and digest,
# plus a small start script (Apache on $PORT, all app data on one volume at /data).
FROM ghcr.io/danielbrendel/hortusfox-web:v6.4@sha256:bea58ac1f2884d672277ad2444de372b0a5032ef827bdc51d2b368285dbdb4dd

COPY --chmod=755 railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
COPY --chmod=755 railway-apache.sh /usr/local/bin/railway-apache.sh
COPY railway-proxy.php /usr/local/etc/php/railway-proxy.php
COPY zz-railway.ini /usr/local/etc/php/conf.d/zz-railway.ini

# railway-entrypoint.sh prepares Apache and /data, then hands over to the image's
# own docker-entrypoint.sh (migrations, admin user), which finally runs railway-apache.sh.
ENTRYPOINT ["railway-entrypoint.sh"]
CMD ["railway-apache.sh"]
