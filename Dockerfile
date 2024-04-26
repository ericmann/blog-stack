FROM wordpress:php8.3-apache

RUN apt-get update \
    && apt-get install -y libmemcached-dev zlib1g-dev libssl-dev memcached \
    && pecl install memcached \
    && docker-php-ext-enable memcached \
    && rm -rf /var/lib/apt/lists/*
