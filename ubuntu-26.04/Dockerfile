# SPDX-License-Identifier: MIT
# Copyright (c) 2018-2026 Ralf Geschke

FROM ubuntu:resolute-20260421

LABEL org.opencontainers.image.authors="Ralf Geschke <ralf@kuerbis.org>"
LABEL org.opencontainers.image.licenses="MIT"

LABEL maintainer="Ralf Geschke <ralf@kuerbis.org>"
LABEL last_changed="2026-05-10"

# Install PHP 8.5 with some libraries
RUN export DEBIAN_FRONTEND=noninteractive  \
  && apt-get update \
	&& apt-get -y upgrade \
	&& apt-get -y dist-upgrade \
  && apt-get install -y ca-certificates locales \
  && sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen \
  && locale-gen \
  && update-locale LANG=en_US.UTF-8 \
	&& apt-get install -y git ssmtp wget php-fpm php-bcmath php-bz2 php-enchant php-gd php-gmp php-intl php-json \
  php-mbstring php-mysql php-pgsql php-readline php-soap php-snmp php-soap php-sqlite3 php-tidy php-xml php-zip \
	php-redis php-memcache php-memcached \
	&& rm -rf /var/lib/apt/lists/* 
#	&& cp /usr/share/zoneinfo/Etc/UTC /etc/localtime
# php-recode

ENV LANG=en_US.utf8

# Install composer
COPY install-composer.sh /tmp 
RUN cd /tmp/ \
  && sh install-composer.sh \
	&& mv /tmp/composer.phar /usr/local/bin/composer \
	&& rm install-composer.sh

# taken from official Docker PHP image
RUN set -ex \
	&& cd /etc/php/8.5/fpm \
	#&& mkdir /run/php \
	&& { \
	echo '[global]'; \
	echo 'error_log = /proc/self/fd/2'; \
	echo; \
	echo '[www]'; \
	echo '; if we send this to /proc/self/fd/1, it never appears'; \
	echo 'access.log = /proc/self/fd/2'; \
	echo; \
	echo 'clear_env = no'; \
	echo; \
	echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
	echo 'catch_workers_output = yes'; \
	} | tee pool.d/docker.conf \
	&& { \
	echo '[global]'; \
	echo 'daemonize = no'; \
	echo; \
	echo '[www]'; \
	echo 'listen = [::]:9000'; \
	} | tee pool.d/zz-docker.conf


WORKDIR /usr/share/nginx/html

EXPOSE 9000

CMD ["php-fpm8.5"]
