#FROM phusion/baseimage
FROM ubuntu:bionic

LABEL maintainer="Ralf Geschke <ralf@kuerbis.org>"

LABEL last_changed="2018-04-29"

# necessary to set default timezone Etc/UTC
ENV DEBIAN_FRONTEND noninteractive 

# Install PHP 7.2 with some libraries
RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y dist-upgrade \
    && apt-get install -y ca-certificates \
    && apt-get install -y --no-install-recommends \
	&& apt-get install -y locales \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
	&& apt-get install -y git php-fpm \
	php-mysql php-curl php-intl \
	php-mbstring php-bz2 php-pgsql php-xml php-xsl php-sqlite3 \
	php-recode php-opcache php-zip php-gd php-redis php-memcache \
	php-json php-intl \
#        php7.0-mysql \
#        php7.0-intl \
#        php7.0-mbstring \
#        php7.0-mcrypt \
#        php7.0-xml \
#        php7.0-readline \
#        php7.0-curl \
    && rm -rf /var/lib/apt/lists/* 
#	&& cp /usr/share/zoneinfo/Etc/UTC /etc/localtime


ENV LANG en_US.utf8

# Install composer
RUN cd /tmp/ \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv /tmp/composer.phar /usr/local/bin/composer

# taken from official Docker PHP image
RUN set -ex \
	&& cd /etc/php/7.2/fpm \
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

CMD ["php-fpm7.2"]

