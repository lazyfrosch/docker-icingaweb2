FROM alpine

RUN apk update \
    && apk add \
		php7-fpm \
		ca-certificates \
		curl \
		nginx \
		openssl \
		php7-ctype \
		php7-curl \
		php7-dom \
		php7-fpm \
		php7-gettext \
		php7-gd \
		php7-gmp \
		php7-iconv \
		php7-intl \
		php7-json \
		php7-ldap \
		php7-mbstring \
		php7-openssl \
		php7-pdo_mysql \
		php7-pdo_pgsql \
		php7-pear \
		php7-pgsql \
		php7-phar \
		php7-session \
		php7-simplexml \
		php7-tokenizer \
		php7-xml \
		yaml \
	&& apk add build-base php7-dev yaml-dev \
	&& pecl channel-update pecl.php.net \
	&& sed -i 's|$PHP -C -n -q |$PHP -C -q |' /usr/bin/pecl \
	&& (yes '' | pecl install yaml) \
	&& (yes '' | pecl install xdebug) \
	&& apk del build-base php7-dev yaml-dev \
	&& rm -rf /var/cache/apk/*

#RUN (echo "en_US.UTF-8 UTF-8"; echo "de_DE.UTF-8 UTF-8"; echo "fr_FR.UTF-8 UTF-8") >> /etc/locale.gen \
# && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

RUN cd /etc/php7 \
	&& echo 'date.timezone = UTC' > conf.d/timezone.ini \
	&& echo 'extension=yaml.so' > conf.d/yaml.ini \
	&& { \
		echo 'zend_extension=/usr/lib/php7/modules/xdebug.so'; \
		echo; \
		echo '[Xdebug]'; \
		echo 'xdebug.remote_enable=true'; \
		echo 'xdebug.remote_connect_back=true'; \
		echo 'xdebug.profiler_enable=0'; \
		echo 'xdebug.profiler_output_dir=/tmp/profile'; \
		echo 'xdebug.profiler_enable_trigger=1'; \
	} | tee conf.d/xdebug.ini.disabled \
	&& { \
		echo '[global]'; \
		echo 'error_log = /proc/self/fd/2'; \
		echo 'log_level = warn'; \
		echo; \
		echo '[www]'; \
		echo 'access.log = /dev/null'; \
		echo; \
		echo 'clear_env = no'; \
		echo; \
		echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
		echo 'catch_workers_output = yes'; \
	} | tee php-fpm.d/docker.conf \
	&& { \
		echo '[global]'; \
		echo 'daemonize = no'; \
		echo; \
		echo '[www]'; \
		echo 'listen = /run/php-fpm.sock'; \
		echo 'listen.owner = nginx'; \
		echo 'listen.group = nginx'; \
	} | tee php-fpm.d/zz-docker.conf

ENV ICINGAWEB_VERSION=2.7.3 \
	ICINGA_DIRECTOR_VERSION=1.6.2 \
	ICINGA_IPL_VERSION=0.3.0 \
	ICINGA_INCUBATOR_VERSION=0.3.0

RUN curl -o /tmp/icingaweb2.tar.gz -SL "https://github.com/Icinga/icingaweb2/archive/v${ICINGAWEB_VERSION}.tar.gz" \
	&& mkdir /usr/share/icingaweb2 \
	&& tar xf /tmp/icingaweb2.tar.gz --strip-components=1 -C /usr/share/icingaweb2 \
	&& rm -f /tmp/icingaweb2.tar.gz \
	&& ln -s /usr/share/icingaweb2/bin/icingacli /usr/local/bin/icingacli

RUN for module in director ipl incubator; do \
	version="ICINGA_$(echo "${module}" | tr '[a-z]' '[A-Z]')_VERSION" \
	&& curl -o /tmp/module.tar.gz -LsS \
		"https://github.com/Icinga/icingaweb2-module-${module}/archive/v$(eval echo \$$version).tar.gz" \
	&& mkdir "/usr/share/icingaweb2/modules/${module}" \
	&& tar xf /tmp/module.tar.gz --strip-components=1 -C "/usr/share/icingaweb2/modules/${module}" \
	&& rm -f /tmp/module.tar.gz \
	;done

VOLUME /etc/icingaweb2

COPY root/ /
EXPOSE 80

ENTRYPOINT ["docker-entrypoint"]
CMD ["nginx-with-php"]

# vi: ts=4 sw=4 noexpandtab
