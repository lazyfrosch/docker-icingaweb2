#!/bin/sh

set -e

CONFIG_GROUP=${CONFIG_GROUP:-65534} # nobody on alpine
ICINGAWEB_CONFIGDIR=${ICINGAWEB_CONFIGDIR:-'/etc/icingaweb2'}
ICINGAWEB_SETUP_TOKEN=${ICINGAWEB_SETUP_TOKEN:-'docker'}
ICINGAWEB_TIMEZONE=${ICINGAWEB_TIMEZONE='UTC'}
XDEBUG_ENABLED=${XDEBUG_ENABLED:-''}

export ICINGAWEB_CONFIGDIR

if [ ! -e "$ICINGAWEB_CONFIGDIR"/config.ini ]; then
  echo "Setting setup token from ICINGAWEB_SETUP_TOKEN"
  echo "$ICINGAWEB_SETUP_TOKEN" > "$ICINGAWEB_CONFIGDIR"/setup.token
fi

if [ -n "$ICINGAWEB_TIMEZONE" ]; then
    echo "date.timezone = $ICINGAWEB_TIMEZONE" > /etc/php7/conf.d/timezone.ini
fi

if [ `stat -c %g "$ICINGAWEB_CONFIGDIR"` != "$CONFIG_GROUP" ]; then
  echo "Updating permissions in $ICINGAWEB_CONFIGDIR"
  chgrp -R "$CONFIG_GROUP" "$ICINGAWEB_CONFIGDIR"
  find "$ICINGAWEB_CONFIGDIR" -type d -exec chmod g+ws {} \;
  find "$ICINGAWEB_CONFIGDIR" -type f -exec chmod g+w {} \;
fi

if [ -n "$XDEBUG_ENABLED" ]; then
  echo "Enabling xdebug"
  cp /etc/php7/conf.d/xdebug.ini.disabled /etc/php7/conf.d/xdebug.ini
fi

exec "$@"
