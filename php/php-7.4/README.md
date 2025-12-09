## 构建镜像

构建多架构镜像

```shell
# 先拉去所需构建平台的基础镜像
$ docker pull --platform=linux/amd64 php:7.4-fpm
$ docker pull --platform=linux/arm64 php:7.4-fpm

# 构建后立即推送，容易报错
$ docker buildx build --platform linux/amd64,linux/arm64 -t baosloan/php-fpm:7.4 -t baosloan/php-fpm:latest --push .
# 可以先构建，后推送
$ docker buildx build --platform linux/amd64,linux/arm64 -t baosloan/php-fpm:7.4 -t baosloan/php-fpm:latest .
$ docker push baosloan/php-fpm:7.4
$ docker push baosloan/php-fpm:latest
```

