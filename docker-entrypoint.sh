#!/bin/bash

set -ex

config=/etc/icingaweb2
if [ ! -e "$config"/config.ini ]; then
    echo "Setting setup token from ICINGAWEB_SETUP_TOKEN"
    echo "$ICINGAWEB_SETUP_TOKEN" > "$config"/setup.token

    echo "chowning $config"
    # TODO: check for virtualbox based docker environments
    chown -R www-data:www-data "$config"
fi

exec "$@"
