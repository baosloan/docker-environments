FROM centos:8.4.2105

RUN cd /etc/yum.repos.d/
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
RUN dnf clean all && dnf makecache

RUN dnf -y install vim \
wget net-tools lsof tree \
gcc gcc-c++ make cmake autoconf \
automake curl-devel gettext-devel \
bash-completion expat-devel bzip2 \
openssl-devel perl-devel zlib-devel \
pcre-devel libtool socat libjpeg libjpeg-devel \
libpng-devel freetype-devel libzip-devel gd-devel \
chrony tcl-devel libffi-devel systemd-devel

RUN cd /usr/local/src

RUN wget https://nginx.org/download/nginx-1.26.3.tar.gz

RUN useradd nginx -s /sbin/nologin -M
RUN tar -zxvf nginx-1.26.3.tar.gz

RUN cd nginx-1.26.3


RUN ./configure \
--user=nginx \
--group=nginx \
--prefix=/usr/local/nginx-1.26.3 \
--with-pcre \
--with-threads \
--with-stream \
--with-file-aio \
--with-http_v2_module \
--with-http_ssl_module \
--with-http_realip_module \
--with-stream_ssl_module \
--with-http_stub_status_module \
--with-http_gzip_static_module

RUN make && make install

