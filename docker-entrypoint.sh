#!/bin/bash

set -ex

config=/etc/icingaweb2
if [ ! -e "$config"/config.ini ]; then
    echo "Setting setup token from ICINGAWEB_SETUP_TOKEN"
    echo "$ICINGAWEB_SETUP_TOKEN" > "$config"/setup.token
fi

# TODO: check for virtualbox based docker environments
echo "fixing permissions in $config"
chgrp -R www-data "$config"
find "$config" -type d -exec chmod g+ws {} \;
find "$config" -type f -exec chmod g+w {} \;

exec "$@"
