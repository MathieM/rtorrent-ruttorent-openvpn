FROM php:fpm-alpine
MAINTAINER Sawn

ENV VPN_EXCLUDE_NETWORK='' \
    DNS_SERVER_IP='8.8.8.8' \
    PHP_MEM='256M' \
    UID=991 \
    GID=991

VOLUME /home/rtorrent/downloads/complete /home/rtorrent/downloads/incomplete /home/rtorrent/session /home/rtorrent/vpn /home/rtorrent/watch

RUN addgroup -g ${GID} rtorrent && adduser -h /home/rtorrent -s /bin/sh -G rtorrent -D -u ${UID} rtorrent && \
#Install required packages
    apk --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ add \
    nginx \
    supervisor \
    rtorrent \
    openvpn \
    php7 \
    php7-cgi \
    fcgi \
    php7-json \
	unzip

#Copy OpenVPN start script and rtorrent conf
ADD start-openvpn.sh .rtorrent.rc /home/rtorrent/

#Setup FPM
COPY php.ini /etc/php7/fpm/php.ini
RUN /bin/rm -f /usr/local/etc/php-fpm.d/*
COPY fpm.conf /usr/local/etc/php-fpm.d/rutorrent.conf

#Setup NGinX
COPY nginx.conf /etc/nginx/nginx.conf

#Setup RuTorrent (there is a package but it depends on php5, so we get the zipfile from git)

RUN cd /var/www && \
    curl -LOk https://github.com/Novik/ruTorrent/archive/master.zip && \
	ls -alh && \
	unzip master.zip && rm -r master.zip && \
	mv ruTorrent-master rutorrent && \
    mkdir -p /home/rtorrent/session/.rutorrent/torrents && \
    chmod -R 777 /var/www/rutorrent/share/ 
COPY rutorrent_config.php /usr/share/webapps/rutorrent/conf/config.php

#Configure supervisor
ADD supervisord.conf /etc/supervisor/conf.d/

#Finalize
RUN chown -R rtorrent:rtorrent /var/www/rutorrent /home/rtorrent/

#WebUI
EXPOSE 80
#DHT
EXPOSE 49160
#Bittorrent listening ports range
EXPOSE 49161

WORKDIR /home/rtorrent

CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]