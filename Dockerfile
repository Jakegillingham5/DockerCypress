FROM php:7.1.27-fpm
LABEL maintainer="Jake Gillingham <jake.gillingham5@gmail.com>"

# Configure PHP
RUN echo "php_admin_flag[log_errors] = On">>/usr/local/etc/php-fpm.conf

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# PHP-related things
ENV COMPOSER_ALLOW_SUPERUSER 1

# Cypress dependencies
RUN apt update && \
    apt install libgtk-3-0 xvfb libgconf2-dev libxtst-dev libxss-dev libnss3 libasound2 -y --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Server and Test Dependency
RUN apt-get update && apt-get -y install procps

# Install GD -taken from Pickstar fpm dockerfile : to allow mysql migratation
RUN apt-get update && apt-get install -y libfreetype6-dev libjpeg-dev libpng-dev libwebp-dev libfontconfig1 libxrender1 git zip mysql-client && \
    docker-php-ext-configure gd \
          --enable-gd-native-ttf \
          --with-freetype-dir=/usr/include/freetype2 \
          --with-jpeg-dir=/usr/lib \
          --with-webp-dir=/usr/lib \
    && docker-php-ext-install gd \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install zip

# PHP-related install
RUN docker-php-ext-install bcmath && \
    curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

# Install Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN dpkg -i google-chrome-stable_current_amd64.deb; apt-get -fy i

# Node install
ENV NODE_VERSION 10.13.0
ENV NVM_DIR /usr/local/nvm

RUN mkdir ${NVM_DIR} && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash && \
    . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN npm install -g yarn

WORKDIR /var/www