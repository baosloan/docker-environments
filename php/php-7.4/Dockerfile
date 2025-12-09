FROM php:7.4-fpm

# 设置工作目录
WORKDIR /var/www/html

# 更换镜像源
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list

# 设置时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 安装系统依赖包
RUN apt update \
    && apt -y upgrade \
    && apt -y install \
    systemd \
    locales \
    wget \
    curl \
    vim \
    git \
    unzip \
    autoconf \
    pkg-config \
    libfreetype6-dev \
    libjpeg62-turbo \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libxpm-dev \
    libzip-dev \
    libpq-dev \
    libicu-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libzip-dev \
    libbz2-dev \
    libgmp-dev \
    libmcrypt-dev \
    libsodium-dev \
    librabbitmq-dev \
    libssh-dev \
    libonig-dev \
    libxslt1-dev \
    gettext \
    libyaml-dev \
    imagemagick \
    libmagickwand-dev \
    librdkafka-dev \
    libmemcached-dev  \
    zlib1g-dev  \
    && rm -rf /var/lib/apt/lists/*

RUN echo "set encoding=utf-8" >> /etc/vim/vimrc.local \
    && echo "set fileencoding=utf-8" >> /etc/vim/vimrc.local \
    && echo "set termencoding=utf-8" >> /etc/vim/vimrc.local

RUN docker-php-ext-configure gd  \
    --with-freetype  \
    --with-jpeg  \
    --with-webp  \
    --with-xpm

# 安装基础扩展
# RUN docker-php-ext-install -j$(nproc) bcmath gmp calendar filter ftp iconv pcntl shmop tokenizer gettext

# 安装数据库相关扩炸
# RUN docker-php-ext-install -j$(nproc) mysqli pdo_mysql pdo_pgsql

# 安装图形处理扩展
# RUN docker-php-ext-install -j$(nproc) gd

# 安装XML相关扩展
# RUN docker-php-ext-install -j$(nproc) dom exif soap xmlrpc xsl

# 安装系统相关扩展
# RUN docker-php-ext-install -j$(nproc) sysvmsg sysvsem sysvshm

# 安装其它扩展
# RUN docker-php-ext-install -j$(nproc) opcache
# RUN docker-php-ext-install -j$(nproc) fileinfo
# RUN docker-php-ext-install -j$(nproc) intl
# RUN docker-php-ext-install -j$(nproc) sockets
# RUN docker-php-ext-install -j$(nproc) zip
# 安装扩展
RUN docker-php-ext-install -j$(nproc) \
    bcmath \
    calendar \
    gd \
    dom \
    exif \
    fileinfo  \
    filter  \
    ftp  \
    gettext  \
    gmp  \
    iconv  \
    intl  \
    mysqli  \
    opcache  \
    pcntl  \
    pdo_mysql  \
    pdo_pgsql  \
    shmop  \
    soap  \
    sockets  \
    sysvmsg  \
    sysvsem  \
    sysvshm  \
    tokenizer  \
    xmlrpc  \
    xsl  \
    zip

# 然后安装 PECL 扩展
RUN pecl channel-update pecl.php.net \
    && pecl install igbinary \
    && docker-php-ext-enable igbinary \
    && pecl install msgpack \
    && docker-php-ext-enable msgpack

RUN printf "\n" | pecl install imagick && docker-php-ext-enable imagick
RUN printf "\n" | pecl install amqp && docker-php-ext-enable amqp
RUN printf "\n" | pecl install rdkafka && docker-php-ext-enable rdkafka
RUN printf "\n\n\n\n\n\n" | pecl install redis && docker-php-ext-enable redis
# enable igbinary serializer support? [no] :
# enable lzf compression support? [no] :
# enable zstd compression support? [no] :
# enable msgpack serializer support? [no] :
# enable lz4 compression? [no] :
# use system liblz4? [yes] :
RUN printf "no\nno\nno\nno\nno\nyes\nno\nno\nyes\n" | pecl install memcached && docker-php-ext-enable memcached
# libmemcached directory [no] : no
# zlib directory [no] : no
# use system fastlz [no] : no
# enable igbinary serializer [no] : no
# enable msgpack serializer [no] : no
# enable json serializer [no] : yes
# enable server protocol [no] : no
# enable sasl [yes] : no
# enable sessions [yes] : yes

RUN printf "yes\nyes\nyes\nyes\nyes\nyes\nno\n" | pecl install https://pecl.php.net/get/swoole-4.8.13.tgz && docker-php-ext-enable swoole

RUN rm -rf /tmp/pear



# 安装Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    chmod +x /usr/local/bin/composer
RUN composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/


RUN echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen \
        && locale-gen \
        && echo 'export LANG=en_US.UTF-8' >> /etc/bash.bashrc


# 复制配置文件
# COPY www.conf /usr/local/etc/php-fpm.d/www.conf
# COPY php.ini /usr/local/etc/php/php.ini

# 设置权限
RUN chown -R www-data:www-data /var/www/html

# 暴露端口
EXPOSE 9000

# 启动 PHP-FPM
CMD ["php-fpm"]
