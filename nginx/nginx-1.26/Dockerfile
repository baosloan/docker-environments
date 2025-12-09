FROM debian:12.12 AS builder

# 设置环境变量
ENV NGINX_VERSION=1.26.2 \
    OPENSSL_VERSION=3.0.13 \
    PCRE_VERSION=8.45 \
    ZLIB_VERSION=1.3.1

# 安装编译依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    git \
    libpcre3 \
    libpcre3-dev \
    zlib1g \
    zlib1g-dev \
    libssl-dev \
    libgd-dev \
    libgeoip-dev \
    libxml2 \
    libxml2-dev \
    libxslt1-dev \
    libperl-dev \
    libpam0g-dev \
    libgoogle-perftools-dev \
    libbrotli-dev \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /tmp

# 下载Nginx源码
RUN wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar -zxf nginx-${NGINX_VERSION}.tar.gz

# 下载常用第三方模块
# Headers More模块
RUN git clone --depth=1 https://github.com/openresty/headers-more-nginx-module.git

# Brotli压缩模块
RUN git clone --depth=1 https://github.com/google/ngx_brotli.git && \
    cd ngx_brotli && git submodule update --init

# Cache Purge模块
RUN git clone --depth=1 https://github.com/FRiCKLE/ngx_cache_purge.git

# VTS (Virtual Host Traffic Status)模块 - 流量统计
RUN git clone --depth=1 https://github.com/vozlt/nginx-module-vts.git

# Echo模块 - 用于调试
RUN git clone --depth=1 https://github.com/openresty/echo-nginx-module.git

# 编译Nginx
WORKDIR /tmp/nginx-${NGINX_VERSION}

RUN ./configure \
    # 基础配置
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    # 核心功能模块
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-pcre \
    --with-pcre-jit \
    # HTTP相关模块
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_v3_module \
    # 图片处理
    --with-http_image_filter_module \
    # GeoIP
    --with-http_geoip_module \
    # XSLT
    --with-http_xslt_module \
    # Perl
    --with-http_perl_module \
    # 性能优化
    --with-google_perftools_module \
    # Stream模块（TCP/UDP代理）
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-stream_geoip_module \
    --with-stream_ssl_preread_module \
    # Mail代理模块
    --with-mail \
    --with-mail_ssl_module \
    # 调试
    --with-debug \
    # 第三方模块
    --add-module=/tmp/headers-more-nginx-module \
    --add-module=/tmp/ngx_brotli \
    --add-module=/tmp/ngx_cache_purge \
    --add-module=/tmp/nginx-module-vts \
    --add-module=/tmp/echo-nginx-module \
    && make -j$(nproc) \
    && make install

# 创建Nginx配置目录
RUN mkdir -p /etc/nginx/conf.d \
    /etc/nginx/sites-available \
    /etc/nginx/sites-enabled \
    /etc/nginx/snippets

# ===================================
# 最终运行镜像
# ===================================
FROM debian:12-slim

LABEL maintainer="your-email@example.com" \
      description="Full-featured Nginx 1.26 based on Debian 12" \
      version="1.26.2"

# 安装运行时依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libpcre3 \
    zlib1g \
    libssl3 \
    libgd3 \
    libgeoip1 \
    libxml2 \
    libxslt1.1 \
    libperl5.36 \
    libgoogle-perftools4 \
    libbrotli1 \
    curl \
    vim-tiny \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# 创建nginx用户和组
RUN groupadd -r nginx --gid=101 \
    && useradd -r -g nginx --uid=101 --home-dir=/var/cache/nginx --shell=/sbin/nologin nginx

# 从builder复制编译好的文件
COPY --from=builder /etc/nginx /etc/nginx
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /usr/lib/nginx /usr/lib/nginx

# 创建必要的目录
RUN mkdir -p \
    /var/cache/nginx/client_temp \
    /var/cache/nginx/proxy_temp \
    /var/cache/nginx/fastcgi_temp \
    /var/cache/nginx/uwsgi_temp \
    /var/cache/nginx/scgi_temp \
    /var/log/nginx \
    /usr/share/nginx/html \
    && chown -R nginx:nginx /var/cache/nginx \
    && chown -R nginx:nginx /var/log/nginx

# 复制默认配置文件（见下方配置文件）
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

# 创建默认首页
RUN echo '<!DOCTYPE html>\n\
<html>\n\
<head>\n\
    <title>Welcome to Nginx!</title>\n\
    <style>\n\
        body { font-family: Arial, sans-serif; margin: 50px; }\n\
        h1 { color: #009688; }\n\
    </style>\n\
</head>\n\
<body>\n\
    <h1>Welcome to Nginx 1.26 (Full-Featured)</h1>\n\
    <p>If you see this page, the nginx web server is successfully installed and working.</p>\n\
    <p><strong>Enabled Modules:</strong></p>\n\
    <ul>\n\
        <li>HTTP/2, HTTP/3 Support</li>\n\
        <li>SSL/TLS</li>\n\
        <li>Brotli Compression</li>\n\
        <li>GeoIP</li>\n\
        <li>Image Filter</li>\n\
        <li>Stream (TCP/UDP Proxy)</li>\n\
        <li>VTS (Traffic Statistics)</li>\n\
        <li>Cache Purge</li>\n\
        <li>And more...</li>\n\
    </ul>\n\
</body>\n\
</html>' > /usr/share/nginx/html/index.html

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# 暴露端口
EXPOSE 80 443

# 停止信号
STOPSIGNAL SIGQUIT

# 启动nginx
CMD ["nginx", "-g", "daemon off;"]