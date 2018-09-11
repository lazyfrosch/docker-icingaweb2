#!/bin/sh

set -e

CONFIG_GROUP=${CONFIG_GROUP:-65534} # nobody on alpine
ICINGAWEB_CONFIGDIR=${ICINGAWEB_CONFIGDIR:-'/etc/icingaweb2'}
ICINGAWEB_SETUP_TOKEN=${ICINGAWEB_SETUP_TOKEN:-'docker'}
ICINGAWEB_TIMEZONE=${ICINGAWEB_TIMEZONE='UTC'}
XDEBUG_ENABLED=${XDEBUG_ENABLED:-''}

: "${ICINGAWEB_MEMORY_LIMIT:=512M}"

export ICINGAWEB_CONFIGDIR

if [ ! -e "$ICINGAWEB_CONFIGDIR"/config.ini ]; then
  echo "Setting setup token from ICINGAWEB_SETUP_TOKEN"
  echo "$ICINGAWEB_SETUP_TOKEN" > "$ICINGAWEB_CONFIGDIR"/setup.token
fi

phpini() {
  echo "$1 = $2" >> /etc/php7/conf.d/local-docker.ini
}

if [ -n "$ICINGAWEB_TIMEZONE" ]; then
  phpini date.timezone "$ICINGAWEB_TIMEZONE"
fi

if [ -n "$ICINGAWEB_MEMORY_LIMIT" ]; then
  phpini memory_limit "$ICINGAWEB_MEMORY_LIMIT"
fi

if [ "$(stat -c %g "$ICINGAWEB_CONFIGDIR")" != "$CONFIG_GROUP" ]; then
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
