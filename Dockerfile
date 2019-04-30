FROM nginx:alpine

# Set version label
LABEL maintainer="bigrob8181, tmp-hallenser"

# Environment variables
ENV PHP_TZ=America/New_York
ENV PHP_MAX_EXECUTION_TIME='200'
ENV PHP_POST_MAX_SIZE='100M'
ENV PHP_UPLOAD_MAX_FILESIZE='20M'
ENV PHP_MEMORY_LIMIT='256M'

# Install base dependencies, clone the repo and install php libraries
RUN \
    apk update && \
    apk add \
    php7  \
    php7-pdo_mysql \
    php7-pecl-imagick \
    php7-mbstring \
    php7-gd \
    php7-xml \
    php7-zip \
    php7-fpm \
    php7-exif \
    php7-json \
    php7-fileinfo \
    php7-tokenizer \
    php7-session \
    ffmpeg \ 
    git \
    composer && \
    cd /usr/share/nginx/html/ && \
    git clone --recurse-submodules https://github.com/LycheeOrg/Lychee-Laravel.git && \
    cd /usr/share/nginx/html/Lychee-Laravel && \
    composer install --no-dev && \
    apk del composer && \
    rm -rf /var/cache/apk/*

# Add custom site to apache
COPY default.conf /etc/nginx/nginx.conf

EXPOSE 80
VOLUME /conf /uploads

WORKDIR /usr/share/nginx/html/Lychee-Laravel

COPY entrypoint.sh inject.sh wait-for-it/wait-for-it.sh /

RUN chmod +x /entrypoint.sh && \
    chmod +x /inject.sh && \
    chmod +x /wait-for-it.sh && \
    mkdir /run/php

ENTRYPOINT [ "/wait-for-it.sh", "mysql:3306", "-t", "0", "--", "/entrypoint.sh" ]

CMD [ "nginx" ]

