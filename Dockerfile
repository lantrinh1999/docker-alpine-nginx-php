FROM alpine:3.15

# Setup document root
WORKDIR /var/www/html

# Install packages and remove default server definition
RUN apk add \
  # --no-cache \
  nano wget zip unzip curl sqlite nodejs npm yarn \
  curl \
  nginx \
  php8 \
  php8-pear \
  php8-ctype \
  php8-curl \
  php8-dom \
  php8-fpm \
  php8-gd \
  php8-intl \
  php8-mbstring \
  php8-pdo \
  php8-pdo_mysql \
  php8-mysqli \
  # php8-opcache \
  php8-openssl \
  php8-phar \
  php8-session \
  php8-xml \
  php8-xmlreader \
  php8-fileinfo \
  php8-zip \
  php8-gmp \
  php8-redis \
  # php8-pecl-imagick \
  composer \
  supervisor

# Create symlink so programs depending on `php` still function
# RUN ln -s /usr/bin/php8 /usr/bin/php

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf
ADD config/sites/*.conf /etc/nginx/conf.d/

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php8/php-fpm.d/www.conf
COPY config/php.ini /etc/php8/conf.d/custom.ini

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
