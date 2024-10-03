FROM ubuntu:noble-20240904.1

LABEL maintainer="Ralf Geschke <ralf@kuerbis.org>"

LABEL last_changed="2024-10-03"

# necessary to set default timezone Etc/UTC
ENV DEBIAN_FRONTEND=noninteractive 

# Install PHP 8.4 with some libraries from sury PPA
RUN apt-get update \
	&& apt-get -y upgrade \
	&& apt-get -y dist-upgrade \
	&& apt-get install -y ca-certificates \
	&& apt-get install -y --no-install-recommends \
	&& apt-get install -y locales software-properties-common \
	&& add-apt-repository -y ppa:ondrej/php \
	&& apt-get update \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
	&& apt-get install -y git ssmtp wget \
	&& apt-get install -y php8.4-fpm \
	php8.4-curl php8.4-mysql php8.4-intl \
    php8.4-mbstring php8.4-bz2 php8.4-pgsql php8.4-xml php8.4-xsl php8.4-sqlite3 \
	php8.4-opcache php8.4-zip php8.4-gd php8.4-mongodb php8.4-mcrypt php8.4-bcmath php-predis \
	&& apt-get -y upgrade \
	&& rm -rf /var/lib/apt/lists/* 
	
# currently not available:
# php8.4-protobuf, php8.4-imagick, php8.4-redis, php8.4-memcache, php8.4-memcached

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
	&& cd /etc/php/8.4/fpm \
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

CMD ["php-fpm8.4"]
