FROM php:8.2-fpm-alpine

RUN apk add --no-cache \
    git \
    curl \
    libzip-dev \
    mysql-client \
    bash \
    && docker-php-ext-install \
    pdo_mysql \
    zip \
    bcmath \
    session \
    dom \
    tokenizer \
    fileinfo \
    && php -m | grep -i pdo_mysql

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Copy composer files first
COPY composer.json composer.lock* ./

# Install dependencies
RUN composer install --no-interaction --optimize-autoloader --no-dev --prefer-dist 2>&1 || true

# Copy application
COPY . .

# Setup directories
RUN mkdir -p /var/www/storage/logs /var/www/bootstrap/cache && \
    chown -R www-data:www-data /var/www && \
    chmod -R 755 /var/www/storage /var/www/bootstrap/cache

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
