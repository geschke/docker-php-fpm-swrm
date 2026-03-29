# geschke/php-fpm-swrm

Minimal **PHP-FPM Docker images based on Ubuntu LTS distributions**.

The images provide multiple PHP versions either from the official Ubuntu repositories or from the widely used
[https://launchpad.net/~ondrej/+archive/ubuntu/php/](https://launchpad.net/~ondrej/+archive/ubuntu/php/) repository.

The repository name still contains `swrm` for historical reasons. The image was originally created for Docker Swarm deployments, but today it is primarily used as a **general-purpose PHP-FPM container for standard Docker setups**. The repository name is kept for compatibility.


## Supported PHP Versions

Most PHP versions in these images are built using the packages from the
Ondřej Surý PHP repository:

https://launchpad.net/~ondrej/+archive/ubuntu/php/

This repository provides newer PHP versions for Ubuntu LTS releases than the
ones included in Ubuntu itself.

`n` represents the **build number**. Higher numbers indicate newer builds.

### Ubuntu 24.04 LTS based images (deb.sury.org packages)

* `8.4-fpm-ubuntu24.04-sury-n`
* `8.3-fpm-ubuntu24.04-sury-n`
* `8.2-fpm-ubuntu24.04-sury-n`

### Ubuntu 22.04 LTS based images (deb.sury.org packages)

* `8.3-fpm-ubuntu22.04-sury-n`
* `8.2-fpm-ubuntu22.04-sury-n`
* `8.1-fpm-ubuntu22.04-sury-n`

### Ubuntu packaged PHP versions

These variants use the PHP version included directly in Ubuntu.

* `8.3-fpm-n`, **latest** – PHP 8.3 included in Ubuntu 24.04 LTS
* `8.1-fpm-n` – PHP 8.1 included in Ubuntu 22.04 LTS

### Older / deprecated versions

These versions are kept for compatibility but are no longer actively maintained.

* `8.0-fpm-ubuntu22.04-sury-n`
* `7.4-fpm-ubuntu22.04-sury-n`
* `7.4-fpm-n`


## Image Tags

Two different tag schemes are used in this repository.

### Tags for images based on deb.sury.org packages

These tags are used for images that provide PHP versions from the Ondřej Surý repository:

```text
phpversion-fpm-ubuntuversion-sury-build
```

Example:

```text
8.3-fpm-ubuntu24.04-sury-9
```

### Tags for images based on the PHP version included in Ubuntu

These tags are used for images based directly on the PHP version shipped with Ubuntu:

```text
phpversion-fpm-build
```

Example:

```text
8.3-fpm-5
```

The `latest` tag always refers to the PHP version included in the **current Ubuntu LTS release maintained in this repository**, not to a deb.sury.org based image.


## Pulling the Image

```
docker pull geschke/php-fpm-swrm
```

## Running the Container

Example:

```
docker run -d 
--name phpfpm 
--restart unless-stopped 
-p 127.0.0.1:9000:9000 
-v /path/to/your/php/files:/var/www/html 
geschke/php-fpm-swrm:latest

```

This starts a container named `phpfpm` and mounts your PHP application files
into `/var/www/html`.

The option `-p 127.0.0.1:9000:9000` exposes the PHP-FPM port **only on localhost**.
This is typically used when a web server or reverse proxy (e.g. nginx) runs on
the same machine and connects to PHP-FPM locally.

If you want to expose the port to other hosts:

```
-p 9000:9000

```

Be careful when exposing PHP-FPM directly to the network. Without additional
protection (e.g. firewall rules), the service would be reachable from anywhere.


## Example Directory Layout

A typical project structure could look like this:

```text
project/
├── html
│   └── index.php
├── nginx
│   ├── conf.d
│   │   └── compression.conf
│   └── sites-enabled
│       └── default
├── php
│   └── conf.d
│       └── 99-custom.ini
└── compose.yml
```

In this example, `html/` contains the PHP application files.
The `nginx/` directory contains the local nginx configuration, and `php/conf.d/` contains optional custom PHP configuration files that can be mounted into the container.

## Docker Compose Example

A simple setup with nginx and PHP-FPM may look like this `compose.yaml` file:

```yaml
services:
  nginx:
    image: geschke/nginx-swrm:latest
    restart: unless-stopped
    depends_on:
      - php
    volumes:
      - ./html:/var/www/html
      - ./nginx/conf.d:/etc/nginx/conf.d
      - ./nginx/sites-enabled:/etc/nginx/sites-enabled
    networks:
      - website_net

  phpbackend:
    image: geschke/php-fpm-swrm:8.3-fpm-ubuntu24.04-sury-10
    restart: unless-stopped
    volumes:
      - ./html:/var/www/html
      - ./php/conf.d/99-custom.ini:/etc/php/8.3/fpm/conf.d/99-custom.ini:ro
    networks:
      - website_net

networks:
  website_net:
```

Start it with:

```bash
docker compose up -d
```

In this example, both containers mount `./html` to `/var/www/html`. This means the application files remain on the host system while both nginx and PHP-FPM access the same document root inside their containers.

The nginx-specific mounts follow the normal nginx directory layout inside the container:

* `./nginx/conf.d` → `/etc/nginx/conf.d`
* `./nginx/sites-enabled` → `/etc/nginx/sites-enabled`

The nginx configuration itself is not explained in detail here, because that belongs to the companion image and repository:

`geschke/nginx-swrm`

The PHP container uses the image tag `8.3-fpm-ubuntu24.04-sury-10`. That matters for the configuration path inside the container, because the PHP configuration layout follows the original Ubuntu and PHP package structure for the selected PHP version.

In this case, the local file

```text
./php/conf.d/99-custom.ini
```

is mounted to

```text
/etc/php/8.3/fpm/conf.d/99-custom.ini
```

inside the container.

This means that the mounted file directly extends or overrides the PHP-FPM configuration of the selected PHP version. If you use another PHP image tag, you must adjust the target path accordingly. For example, a PHP 8.4 image would use the matching `8.4` path inside `/etc/php/...`.

The file `99-custom.ini` is optional. If you do not mount such a file, the image simply uses the default PHP configuration shipped with that image.

A simple example for `99-custom.ini` could be:

```ini
upload_max_filesize = 20M
post_max_size = 20M
memory_limit = 256M
max_execution_time = 120
date.timezone = Europe/Berlin
```

You can use this file for typical PHP settings such as upload limits, memory limits, execution time, timezone settings, and similar adjustments.

Additional files or directories can be mounted in the same way if further customization is needed. The general idea is always the same: local configuration on the host system is mounted into the corresponding configuration path inside the container.



# Usage with Nginx

This image is typically used together with an Nginx frontend.

A minimal FastCGI configuration looks like this:

```
  # pass PHP scripts to FastCGI server
  location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    # Use the tcp connection
    fastcgi_pass phpbackend:9000;
    # ...but not the socket
    #fastcgi_pass unix:/run/php/php7.0-fpm.sock;
    fastcgi_index index.php;
    include fastcgi.conf;
  }
[...]
```

The example is from a working configuration of Nginx Ubuntu package. If not
set in the fastcgi.conf, maybe it's necessary to add the following options:

    fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
    fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;

These options are set as default in the fastcgi.conf file and could be
changed in the location settings.


# Credits

This image is based on:

* the official Ubuntu Docker image
* PHP packages from Ubuntu and deb.sury.org
* configuration snippets from the official PHP Docker image


# License

MIT License

