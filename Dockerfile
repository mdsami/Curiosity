FROM composer:latest AS build

WORKDIR /var/www/html

COPY . .

RUN composer install

FROM php:8.0-fpm

WORKDIR /var/www/html

COPY --from=build /var/www/html /var/www/html

RUN chown -R www-data:www-data /var/www/html \
    && apt-get update \
    && apt-get install -y \
        libzip-dev \
        zip \
        unzip \
        nginx \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip \
    && rm /etc/nginx/sites-available/default \
    && rm /etc/nginx/sites-enabled/default

COPY ./nginx/nginx.conf /etc/nginx/sites-available/default.conf
RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

CMD ["nginx", "-g", "daemon off;"]
