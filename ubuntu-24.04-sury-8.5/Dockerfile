# SPDX-License-Identifier: MIT
# Copyright (c) 2018-2026 Ralf Geschke

FROM ubuntu:noble-20260410

LABEL org.opencontainers.image.authors="Ralf Geschke <ralf@kuerbis.org>"
LABEL org.opencontainers.image.licenses="MIT"

LABEL maintainer="Ralf Geschke <ralf@kuerbis.org>"
LABEL last_changed="2026-05-10"

# Install PHP 8.4 with some libraries from sury PPA
RUN export DEBIAN_FRONTEND=noninteractive  \
  && apt-get update \
	&& apt-get -y upgrade \
	&& apt-get -y dist-upgrade \
	&& apt-get install -y ca-certificates locales software-properties-common \
	&& add-apt-repository -y ppa:ondrej/php \
	&& apt-get update \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
	&& apt-get install -y git ssmtp wget \
	&& apt-get install -y php8.5-fpm \
	php8.5-curl php8.5-mysql php8.5-intl \
    php8.5-mbstring php8.5-bz2 php8.5-pgsql php8.5-xml php8.5-xsl php8.5-sqlite3 \
	php8.5-zip php8.5-gd php8.5-mongodb php8.5-mcrypt php8.5-bcmath  \
  php8.5-protobuf  php8.5-imagick php8.5-redis php8.5-memcache php8.5-memcached \
	&& apt-get -y upgrade \
	&& rm -rf /var/lib/apt/lists/* 
	
#\
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
	&& mkdir -p /run/php \
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
