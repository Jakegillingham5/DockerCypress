FROM php:7.3
LABEL maintainer="Jake Gillingham <jake.gillingham5@gmail.com>"

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# PHP-related things
ENV COMPOSER_ALLOW_SUPERUSER 1

# Cypress dependencies
RUN apt update && \
    apt install libgtk-3-0 xvfb libgconf2-dev libxtst-dev libxss-dev libnss3 libasound2 -y --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# PHP-related install
RUN docker-php-ext-install pdo_mysql \
    && docker-php-ext-install bcmath \
    && curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

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

# Server and Test Dependency
RUN apt-get update && apt-get -y install procps && apt-get -y install wget && apt-get install -y gnupg2

# install Chromebrowser
RUN \
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list && \
  apt-get update && \
  apt-get install -y dbus-x11 google-chrome-stable && \
  rm -rf /var/lib/apt/lists/*

# "fake" dbus address to prevent errors
# https://github.com/SeleniumHQ/docker-selenium/issues/87
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null

WORKDIR /var/www