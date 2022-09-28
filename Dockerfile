FROM alpine:3.15

# Setup document root
WORKDIR /var/www/html

# Install packages and remove default server definition
RUN apk add \
  # --no-cache \
  nano wget zip unzip curl sqlite nodejs npm yarn \
  curl \
  nginx \
  php7 \
  php7-fpm \
  php7-tokenizer \
  php7-pear \
  php7-ctype \
  php7-pcntl \
  php7-iconv \
  php7-posix \
  php7-apcu \
  php7-json \
  php7-zlib \
  php7-curl \
  php7-dom \
  php7-gd \
  php7-intl \
  php7-mbstring \
  php7-pdo \
  php7-pdo_mysql \
  php7-pgsql \
  php7-pdo_pgsql \
  php7-mysqli \
  # php7-opcache \
  php7-openssl \
  php7-phar \
  php7-session \
  php7-xml \
  php7-xmlreader \
  php7-xmlwriter \
  php7-simplexml \
  php7-fileinfo \
  php7-zip \
  php7-gmp \
  php7-redis \
  # php7-pecl-imagick \
  composer \
  supervisor

# Create symlink so programs depending on `php` still function
RUN rm -rf /usr/bin/php
RUN ln -s /usr/bin/php7 /usr/bin/php

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf
ADD config/sites/*.conf /etc/nginx/conf.d/

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY config/php.ini /etc/php7/conf.d/custom.ini

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
COPY  --from=composer/composer /usr/bin/composer /usr/bin/composer

# Run composer install to install the dependencies
# RUN composer install --optimize-autoloader --no-interaction --no-progress

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
