FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip libzip-dev libpng-dev libonig-dev libxml2-dev \
    nginx supervisor \
    && docker-php-ext-install pdo pdo_mysql zip mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy existing application directory contents
COPY . /var/www

# Set correct permissions
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www/storage

# Copy default nginx config
COPY ./docker/nginx.conf /etc/nginx/sites-available/default

# Copy supervisor config
COPY ./docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose port
EXPOSE 80

# Run Laravel setup
RUN composer install \
    && cp .env.example .env \
    && php artisan key:generate \
    && php artisan config:cache

# Start NGINX and PHP-FPM via supervisor
CMD ["/usr/bin/supervisord"]
