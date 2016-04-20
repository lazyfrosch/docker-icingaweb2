FROM php:5.6-apache

RUN apt-get update && apt-get install -y libicu-dev libldap2-dev libpng12-dev libpq-dev libjpeg-dev && rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd gettext intl ldap mysql pdo_mysql pdo_pgsql pgsql

ENV ICINGAWEB_VERSION 2.3.1
ENV ICINGAWEB_SETUP_TOKEN docker

RUN curl -o /tmp/icingaweb2.tar.gz -SL "https://github.com/Icinga/icingaweb2/archive/v${ICINGAWEB_VERSION}.tar.gz" \
	&& mkdir /usr/share/icingaweb2 \
	&& tar xf /tmp/icingaweb2.tar.gz --strip-components=1 -C /usr/share/icingaweb2 \
	&& rm -f /tmp/icingaweb2.tar.gz

RUN cp /usr/share/icingaweb2/packages/files/apache/icingaweb2.conf /etc/apache2/conf-enabled/ \
	&& echo "RedirectMatch ^/$ /icingaweb2" >> /etc/apache2/conf-enabled/redirect.conf \
	&& a2enmod rewrite \
	&& echo "date.timezone = UTC" > /usr/local/etc/php/conf.d/timeszone.ini

VOLUME /etc/icingaweb2

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "apache2-foreground" ]
