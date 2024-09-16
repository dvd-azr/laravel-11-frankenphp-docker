# FROM php:8.1-cli

# # Install sysem dependencies
# RUN apt-get update && apt-get install -y \
#     build-essential \
#     libpng-dev \
#     libjpeg62-turbo-dev \
#     libfreetype6-dev \
#     libzip-dev \
#     libonig-dev \
#     locales \
#     zip \
#     jpegoptim optipng pngquant gifsicle \
#     vim \
#     unzip \
#     curl \
#     git
    
# # Clear Cache
# RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# # Install PHP extensions
# RUN docker-php-ext-install \
#     mbstring \
#     pdo_mysql \
#     exif \
#     pcntl \
#     bcmatch \
#     gd \
#     zip


# GPT
# .docker/php/Dockerfile.local
# FROM php:8.0-fpm

# # Install dependencies, PHP extensions, etc.
# RUN apt-get update && apt-get install -y \
#     libpng-dev libjpeg-dev libfreetype6-dev \
#     && docker-php-ext-configure gd --with-freetype --with-jpeg \
#     && docker-php-ext-install gd \
#     && docker-php-ext-install mysqli pdo pdo_mysql

# # Set working directory
# # WORKDIR /var/www/html
# WORKDIR /var/www

# RUN rm -rf /var/www/html
# # Copy application code
# # COPY . .

# # copy existing app dir permission
# COPY --chown=www-data:www-data . /var/www
# RUN ls
# # change current user to www
# USER www-data

# # 
# RUN curl -sS https://getcomposer.org/instaler | php -- --install-dir=/usr/local/bin --filename=composer
# # install depedencies
# RUN composer install

# # Copy over the .env file and generate the app key
# COPY .env.example .env
# RUN php artisan key:generate

# # Expose ports
# EXPOSE 8000 5173

# # Start the application
# CMD ["php-fpm"]
# # CMD php atisan serve --host=0.0.0.0 --port=8000



# copy dari  .docker/php/Dockerfile.local
FROM dunglas/frankenphp:1.1-builder-php8.2.16

# Set Caddy server name to "http://" to serve on 80 and not 443
# Read more: https://frankenphp.dev/docs/config/#environment-variables
ENV SERVER_NAME="http://"

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git \
    unzip \
    librabbitmq-dev \
    libpq-dev \
    supervisor

RUN install-php-extensions \
    gd \
    pcntl \
    opcache \
    pdo \
    pdo_mysql \
    redis

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy the Laravel application files into the container.
COPY . .

# Copy over the .env file and generate the app key
COPY .env.example .env


# Start with base PHP config, then add extensions.
COPY ./.docker/php/php.ini /usr/local/etc/php/
COPY ./.docker/etc/supervisor.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Install PHP extensions
RUN pecl install xdebug

# Install Laravel dependencies using Composer.
RUN composer install

# Enable PHP extensions
RUN docker-php-ext-enable xdebug

# Set permissions for Laravel.
RUN chown -R www-data:www-data storage bootstrap/cache

EXPOSE 80 443

# Start Supervisor.
CMD ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisor/conf.d/supervisord.conf"]
