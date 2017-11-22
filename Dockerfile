FROM        ubuntu:16.04
MAINTAINER  Robert Reiz <reiz@versioneye.com>

WORKDIR /app

ADD sources.list /etc/apt/sources.list

RUN apt-get update; \
    apt-get install -y libfontconfig1; \
    apt-get install -y libpcre3; \ 
    apt-get install -y libpcre3-dev; \
    apt-get install -y git; \
    apt-get install -y dpkg-dev; \
    apt-get install -y libpng-dev; \
    apt-get autoclean && apt-get autoremove;

RUN cd /app && apt-get source nginx; \ 
    cd /app/ && git clone https://github.com/chobits/ngx_http_proxy_connect_module; \
    cd /app/nginx-* && patch -p1 < ../ngx_http_proxy_connect_module/proxy_connect.patch; \
    cd /app/nginx-* && ./configure --add-module=/app/ngx_http_proxy_connect_module && make && make install;

ADD nginx_whitelist.conf /usr/local/nginx/conf/nginx.conf

EXPOSE 8888

CMD /usr/local/nginx/sbin/nginx
