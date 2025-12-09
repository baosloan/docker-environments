FROM php:8.3-fpm-bookworm

LABEL maintainer="baosloan@gmail.com" \
      description="PHP 8.3 FPM with common extensions" \
      version="8.3"

# 设置工作目录
WORKDIR /var/www/html

# 更换镜像源
RUN sed -i 's|http://deb.debian.org|https://mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources && \
    sed -i 's|http://security.debian.org|https://mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources


# 设置时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 安装系统依赖包
RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install --no-install-recommends \
    locales \
    wget \
    curl \
    vim \
    git \
    zip \
    unzip \
    autoconf \
    pkg-config \
    libfreetype6-dev \ 
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libxpm-dev \
    imagemagick \
    libmagickwand-dev \
    libpq-dev \
    libzip-dev \
    libbz2-dev \
    zlib1g-dev \
    libicu-dev \
    gettext \
    libxml2-dev \
    libxslt1-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libsodium-dev \
    libssh-dev \    
    libgmp-dev \
    libonig-dev \
    libedit-dev \
    libreadline-dev \  
    libyaml-dev \
    librabbitmq-dev \
    librdkafka-dev \
    libmemcached-dev \
    libnghttp2-dev \
    && rm -rf /var/lib/apt/lists/*

RUN echo "set encoding=utf-8" >> /etc/vim/vimrc.local \
    && echo "set fileencoding=utf-8" >> /etc/vim/vimrc.local \
    && echo "set termencoding=utf-8" >> /etc/vim/vimrc.local

# 配置GD扩展
RUN docker-php-ext-configure gd  \
    --with-freetype  \
    --with-jpeg  \
    --with-webp  \
    --with-xpm


# 安装基础扩展
# RUN docker-php-ext-install -j$(nproc) bcmath gmp calendar filter ftp iconv pcntl shmop tokenizer gettext

# 安装数据库相关扩展
# RUN docker-php-ext-install -j$(nproc) mysqli pdo_mysql pdo_pgsql pgsql

# 安装图形处理扩展
# RUN docker-php-ext-install -j$(nproc) gd

# 安装XML相关扩展
# RUN docker-php-ext-install -j$(nproc) dom exif soap xsl

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
    ftp  \
    gettext  \
    gmp  \
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
    xsl  \
    zip

# 然后安装 PECL 扩展
RUN pecl channel-update pecl.php.net \
    && pecl install igbinary \
    && docker-php-ext-enable igbinary \
    && pecl install msgpack \
    && docker-php-ext-enable msgpack \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && pecl install amqp-2.1.2 \
    && docker-php-ext-enable amqp \
    && pecl install rdkafka-6.0.5 \
    && docker-php-ext-enable rdkafka \
    && pecl install redis-6.3.0 \
    && docker-php-ext-enable redis \
    && pecl install memcached-3.4.0 \
    && docker-php-ext-enable memcached \
    && pecl install swoole-5.1.8 \
    && docker-php-ext-enable swoole \
    && rm -rf /tmp/pear

# 安装Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    chmod +x /usr/local/bin/composer
RUN composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

RUN echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen \
        && locale-gen \
        && echo 'export LANG=en_US.UTF-8' >> /etc/bash.bashrc

# 清理不必要的文件
RUN apt autoremove -y && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# 复制配置文件
# COPY www.conf /usr/local/etc/php-fpm.d/www.conf
# COPY php.ini /usr/local/etc/php/php.ini

# 设置权限
RUN chown -R www-data:www-data /var/www/html

# 暴露端口
EXPOSE 9000

# 启动 PHP-FPM
CMD ["php-fpm"]
