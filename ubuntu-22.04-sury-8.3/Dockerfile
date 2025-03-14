FROM ubuntu:jammy-20250126

LABEL maintainer="Ralf Geschke <ralf@kuerbis.org>"

LABEL last_changed="2025-03-14"

# necessary to set default timezone Etc/UTC
ENV DEBIAN_FRONTEND=noninteractive 

# Install PHP 8.3 with some libraries from sury PPA
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
	&& apt-get install -y php8.3-fpm \
	php8.3-curl php8.3-mysql php8.3-intl \
    php8.3-mbstring php8.3-bz2 php8.3-pgsql php8.3-xml php8.3-xsl php8.3-sqlite3 \
	php8.3-opcache php8.3-zip php8.3-gd php8.3-redis php8.3-memcache php8.3-memcached \
	php8.3-mongodb php8.3-mcrypt php8.3-bcmath php8.3-protobuf php8.3-imagick \
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
	&& cd /etc/php/8.3/fpm \
	&& mkdir /run/php \
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

CMD ["php-fpm8.3"]
