<?php
// Railway terminates HTTPS at its edge and forwards plain HTTP to Apache on $PORT.
// HortusFox builds absolute links from HTTPS and SERVER_PORT, so without this they
// would read http://YOUR-DOMAIN:8080/... Loaded through auto_prepend_file.
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO'])
    && strtolower(trim(explode(',', $_SERVER['HTTP_X_FORWARDED_PROTO'])[0])) === 'https') {
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['REQUEST_SCHEME'] = 'https';
    $_SERVER['SERVER_PORT'] = '443';
}
