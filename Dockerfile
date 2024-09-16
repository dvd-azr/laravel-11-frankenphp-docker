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
FROM php:8.0-fpm

# Install dependencies, PHP extensions, etc.
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && docker-php-ext-install mysqli pdo pdo_mysql

# Set working directory
# WORKDIR /var/www/html
WORKDIR /var/www

RUN rm -rf /var/www/html
# Copy application code
# COPY . .

# copy existing app dir permission
COPY --chown=www-data:www-data . /var/www
RUN ls
# change current user to www
USER www-data

# Copy over the .env file and generate the app key
COPY .env.example .env
RUN php artisan key:generate

# Expose ports
EXPOSE 8000 5173

# Start the application
CMD ["php-fpm"]
# CMD php atisan serve --host=0.0.0.0 --port=8000
