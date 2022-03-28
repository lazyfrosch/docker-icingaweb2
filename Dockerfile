FROM alpine:3.15.2

RUN apk update \
	&& apk add \
		php7-fpm \
		ca-certificates \
		curl \
		nginx \
		openssl \
		gnu-libiconv \
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
		php7-pcntl \
		php7-pdo_mysql \
		php7-pdo_pgsql \
		php7-pear \
		php7-pgsql \
		php7-phar \
		php7-posix \
		php7-session \
		php7-sockets \
		php7-simplexml \
		php7-tokenizer \
		php7-xml \
		php7-pecl-redis \
		php7-pecl-yaml \
		php7-pecl-xdebug \
		yaml \
	&& mv /etc/php7/conf.d/50_xdebug.ini /etc/php7/conf.d/50_xdebug.ini.orig \
	&& php -m \
	&& rm -rf /var/cache/apk/*

#RUN (echo "en_US.UTF-8 UTF-8"; echo "de_DE.UTF-8 UTF-8"; echo "fr_FR.UTF-8 UTF-8") >> /etc/locale.gen \
# && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

ENV LD_PRELOAD="/usr/lib/preloadable_libiconv.so php-fpm7 php"
RUN cd /etc/php7 \
	&& echo 'date.timezone = UTC' > conf.d/timezone.ini \
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
		echo '; Session paths for a volume '; \
		echo 'session.save_path = "/sessions"'; \
	} | tee conf.d/docker.ini \
	&& { \
		echo '[global]'; \
		echo 'daemonize = no'; \
		echo; \
		echo '[www]'; \
		echo 'listen = /run/php-fpm.sock'; \
		echo 'listen.owner = nginx'; \
		echo 'listen.group = nginx'; \
	} | tee php-fpm.d/zz-docker.conf \
	&& php -m \
	&& mkdir /sessions \
	&& chown nobody:nobody /sessions

VOLUME /sessions

# renovate: datasource=github-releases depName=Icinga/icingaweb2
ENV ICINGAWEB_VERSION=v2.9.6
# renovate: datasource=github-releases depName=Icinga/icinga-php-library
ENV ICINGA_PHP_LIBRARY_VERSION=v0.7.0
# renovate: datasource=github-releases depName=Icinga/icinga-php-thirdparty
ENV ICINGA_PHP_THIRDPARTY_VERSION=v0.10.0
# renovate: datasource=github-releases depName=Icinga/icingadb-web
ENV ICINGA_ICINGADB_VERSION=v1.0.0-rc2
# ENV ICINGA_ICINGADB_GIT_REF=e14cf93de42f9efc41c098469f84cb7c2a3cfc08
# renovate: datasource=github-releases depName=Icinga/icingaweb2-module-director
ENV ICINGA_DIRECTOR_VERSION=v1.9.0
# renovate: datasource=github-releases depName=Icinga/icingaweb2-module-fileshipper
ENV ICINGA_FILESHIPPER_VERSION=v1.2.0
# renovate: datasource=github-releases depName=Icinga/icingaweb2-module-ipl
ENV ICINGA_IPL_VERSION=v0.5.0
# renovate: datasource=github-releases depName=Icinga/icingaweb2-module-incubator
ENV ICINGA_INCUBATOR_VERSION=v0.14.0
# renovate: datasource=github-releases depName=Icinga/icingaweb2-module-reactbundle
ENV ICINGA_REACTBUNDLE_VERSION=v0.9.0

RUN curl -o /tmp/icingaweb2.tar.gz -SL "https://github.com/Icinga/icingaweb2/archive/${ICINGAWEB_VERSION}.tar.gz" \
	&& mkdir /usr/share/icingaweb2 \
	&& tar xf /tmp/icingaweb2.tar.gz --strip-components=1 -C /usr/share/icingaweb2 \
	&& rm -f /tmp/icingaweb2.tar.gz \
	&& ln -s /usr/share/icingaweb2/bin/icingacli /usr/local/bin/icingacli

RUN curl -o /tmp/download.tar.gz -SL "https://github.com/Icinga/icinga-php-library/archive/${ICINGA_PHP_LIBRARY_VERSION}.tar.gz" \
	&& mkdir -p /usr/share/icinga-php/ipl \
	&& tar xf /tmp/download.tar.gz --strip-components=1 -C /usr/share/icinga-php/ipl \
	&& rm -f /tmp/download.tar.gz

RUN curl -o /tmp/download.tar.gz -SL "https://github.com/Icinga/icinga-php-thirdparty/archive/${ICINGA_PHP_THIRDPARTY_VERSION}.tar.gz" \
	&& mkdir -p /usr/share/icinga-php/vendor \
	&& tar xf /tmp/download.tar.gz --strip-components=1 -C /usr/share/icinga-php/vendor \
	&& rm -f /tmp/download.tar.gz

# icingadb dev - disabled because of incompatiblity with 2.8
#RUN apk add -U git \
#	&& git clone https://github.com/Icinga/icingadb-web.git /usr/share/icingaweb2/modules/icingadb \
#	&& cd /usr/share/icingaweb2/modules/icingadb \
#	&& git checkout -B local "${ICINGA_ICINGADB_GIT_REF}" \
#	&& git describe --tags

# newer module names
RUN for module in icingadb; do \
	version="ICINGA_$(echo "${module}" | tr '[a-z]' '[A-Z]')_VERSION" \
	&& curl -o /tmp/module.tar.gz -LS \
		"https://github.com/Icinga/${module}-web/archive/$(eval echo \$$version).tar.gz" \
	&& mkdir "/usr/share/icingaweb2/modules/${module}" \
	&& tar xf /tmp/module.tar.gz --strip-components=1 -C "/usr/share/icingaweb2/modules/${module}" \
	&& rm -f /tmp/module.tar.gz \
	;done

# old module names
RUN for module in director fileshipper ipl incubator reactbundle; do \
	version="ICINGA_$(echo "${module}" | tr '[a-z]' '[A-Z]')_VERSION" \
	&& curl -o /tmp/module.tar.gz -LS \
		"https://github.com/Icinga/icingaweb2-module-${module}/archive/$(eval echo \$$version).tar.gz" \
	&& mkdir "/usr/share/icingaweb2/modules/${module}" \
	&& tar xf /tmp/module.tar.gz --strip-components=1 -C "/usr/share/icingaweb2/modules/${module}" \
	&& rm -f /tmp/module.tar.gz \
	;done

# RUN mkdir /etc/icingaweb2 \
#  && chown nobody.nobody /etc/icingaweb2 \
#  && mkdir /var/lib/icingaweb2 \
#  && chown nobody.nobody /etc/icingaweb2

COPY root/ /

VOLUME /etc/icingaweb2
VOLUME /var/lib/icingaweb2

WORKDIR /etc/icingaweb2

EXPOSE 80

ENTRYPOINT ["docker-entrypoint"]
CMD ["nginx-with-php"]

# vi: ts=4 sw=4 noexpandtab
