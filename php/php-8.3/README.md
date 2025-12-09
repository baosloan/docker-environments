## 官方镜像

```shell
$ docker pull php:8.3-fpm
```

### php -m查看已加载模块

如果想查看官方PHP镜像启用了哪些模块

```shell
$ docker run --rm php:8.3-fpm php -m
[PHP Modules]
Core
ctype
curl
date
dom
fileinfo
filter
hash
iconv
json
libxml
mbstring
mysqlnd
openssl
pcre
PDO
pdo_sqlite
Phar
posix
random
readline
Reflection
session
SimpleXML
sodium
SPL
sqlite3
standard
tokenizer
xml
xmlreader
xmlwriter
Zend OPcache
zlib

[Zend Modules]
Zend OPcache
```

### php -i查看完整配置信息

```shell
# 查看完整phpinfo信息
$ docker run --rm php:8.3-fpm php -i

# 只查看编译配置
$ docker run --rm php:8.3-fpm php -i | grep -i "configure command"

# 查看编译选项（格式化输出）
$ docker run --rm php:8.3-fpm php -i | grep "Configure Command" -A 1
'./configure'  '--build=aarch64-linux-gnu' '--with-config-file-path=/usr/local/etc/php' '--with-config-file-scan-dir=/usr/local/etc/php/conf.d' '--enable-option-checking=fatal' '--with-mhash' '--with-pic' '--enable-mbstring' '--enable-mysqlnd' '--with-password-argon2' '--with-sodium=shared' '--with-pdo-sqlite=/usr' '--with-sqlite3=/usr' '--with-curl' '--with-iconv' '--with-openssl' '--with-readline' '--with-zlib' '--disable-phpdbg' '--with-pear' '--with-libdir=lib/aarch64-linux-gnu' '--disable-cgi' '--enable-fpm' '--with-fpm-user=www-data' '--with-fpm-group=www-data' 'build_alias=aarch64-linux-gnu'
```



## 构建镜像

```shell
$ docker build -t php-fpm:8.3 .
```

将镜像里的配置文件复制出来

```shell
$ docker run -itd --name php83 php-fpm:8.3
$ docker cp php83:/usr/local/etc/php/php.ini-production ./conf/php.ini
$ docker cp php83:/usr/local/etc/php-fpm.d/www.conf ./conf/www.conf
```

构建多架构镜像

```shell
# 先拉去所需构建平台的基础镜像
$ docker pull --platform=linux/amd64 php:8.3-fpm-bookworm
$ docker pull --platform=linux/arm64 php:8.3-fpm-bookworm

# 可以先构建，后推送
$ docker buildx build --platform linux/amd64,linux/arm64 -t baosloan/php-fpm:8.3 -t baosloan/php-fpm:latest .
$ docker push baosloan/php-fpm:8.3
$ docker push baosloan/php-fpm:latest
```

