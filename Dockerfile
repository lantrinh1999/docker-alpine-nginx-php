FROM alpine:3.16

# Setup document root
WORKDIR /var/www/html

# Install packages and remove default server definition
RUN apk update \
  && apk add \
  --no-cache \
  nano make wget zip unzip curl sqlite nodejs npm \
  nginx \
  php81 \
  php81-fpm \
  php81-tokenizer \
  php81-pear \
  php81-ctype \
  php81-pcntl \
  php81-iconv \
  php81-posix \
  php81-apcu \
  php81-json \
  php81-zlib \
  php81-curl \
  php81-dom \
  php81-gd \
  php81-intl \
  php81-mbstring \
  php81-pdo \
  php81-pdo_mysql \
  php81-pgsql \
  php81-pdo_pgsql \
  php81-mysqli \
  # php81-opcache \
  php81-openssl \
  php81-phar \
  php81-session \
  php81-xml \
  php81-xmlreader \
  php81-xmlwriter \
  php81-simplexml \
  php81-fileinfo \
  php81-zip \
  php81-gmp \
  php81-redis \
  php81-exif \
  php81-mongodb \
  # php81-pecl-imagick \
  composer \
  supervisor

# Create symlink so programs depending on `php` still function
RUN rm -rf /usr/bin/php
RUN ln -s /usr/bin/php81 /usr/bin/php

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf
ADD config/sites/*.conf /etc/nginx/conf.d/

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php81/php-fpm.d/www.conf
COPY config/php.ini /etc/php81/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN adduser -D -u 1000 -g 1000 -s /bin/sh www && \
  mkdir -p /var/www/html && \
  mkdir -p /var/cache/nginx && \
  chown -R www:www /var/www/html && \
  chown -R www:www /run && \
  chown -R www:www /var/lib/nginx && \
  chown -R www:www /var/log/nginx

# Add application
# COPY --chown=nobody src/ /var/www/html/

# Install Composer
# COPY  --from=composer/composer /usr/bin/composer /usr/bin/composer

# Run composer install to install the dependencies
# RUN composer install --optimize-autoloader --no-interaction --no-progress

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
