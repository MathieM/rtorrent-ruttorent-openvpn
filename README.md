# sawn/rtorrent-rutorrent-openvpn

Alpine Linux running rTorrent + RuTorrent WebUI for docker with OpenVPN support.
This container is inspired by the work of [wonderfall](https://github.com/Wonderfall/dockerfiles) ; [drgroot](https://github.com/drgroot/docker-containers/tree/master/rtorrent) ; [haugene](https://github.com/haugene/docker-transmission-openvpn)

I needed a container based on Alpine Linux using RuTorrent and OpenVPN

Listen to port 80 using NGinx + PHP-FPM (reverse proxy recommended for SSL and authentication, I recommend [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy)).

**Note:** Requires priviledged run in order to connect using OpenVPN (or just NET_ADMIN capability).

## CAUTION

It's my first docker build so it may be far from perfect. Don't hesitate to reach me if you find something that can be enhanced or corrected.

## Usage
```
docker create -t --name=rtorrent \
--add-cap NET_ADMIN \
-v <path to OpenVPN conf files>:/home/rtorrent/vpn \
-v <path to rTorrent session files>:/home/rtorrent/session \
-v <path to rTorrent downloads/complete>:/home/rtorrent/downloads/complete \
-v <path to rTorrent downloads/incomplete>:/home/rtorrent/downloads/incomplete \
-v <path to rTorrent watch directory>:/home/rtorrent/watch \
-v <path to RuTorrent plugins>:/var/www/rutorrent/plugins \
-v <path to RuTorrent themes>:/var/www/rutorrent/themes \
-p 80:80 -p 49161:49161 \
sawn/rtorrent-rutorrent-openvpn
```
Or using Docker-Compose v2+:

```
version: '2'
services:
  rtorrent:
    image: sawn/rtorrent-rutorrent-openvpn
    cap_add:
    - NET_ADMIN
    expose:
    - "80/tcp"
    ports:
    - 49161:49161
    volumes:
    - ./downloads/complete:/home/rtorrent/downloads/complete
    - ./downloads/incomplete:/home/rtorrent/downloads/incomplete
    - ./session:/home/rtorrent/session
    - ./watch:/home/rtorrent/watch
    - ./plugins:/var/www/rutorrent/plugins
    - ./themes:/var/www/rutorrent/themes
    - ./vpn:/home/rtorrent/vpn
    environment:
    - VPN_EXCLUDE_NETWORK=172.0.0.0
    - DNS_SERVER_IP=nnn.nnn.nnn.nnn
    - PHP_MEM=256M
    restart: unless-stopped
```

##Environment variables

* VPN_EXCLUDE_NETWORK: (Default empty) Network to exclude from being sent through the VPN, useful when accessing container from a reverse proxy (recommended setup).
* DNS_SERVER_IP: (Default: 8.8.8.8) Address for DNS Server of your choice.
* PHP_MEM: (Default: 256M) Memory allocated for PHP.
* UID: (Default: 991) UserID used for running the service.
* GID: (Default: 991) GroupID used for running the service.

##Volumes

Your volumes ownership must match the one used by this container services (default to 991:991).

## OpenVPN

Your personal OpenVPN configuration files should be stored in `/home/rtorrent/vpn`. They will be automatically loaded and properly routed. The configuration files for the openvpn must end in `ovpn`. This is because startup calls `openvpn --config *.ovpn`

## XML RPC

The XML RPC url is: `/RPC2`

## Debug

* rTorrent is logging to /home/rtorrent/rtorrent.log
* supervisor is logging to /home/rtorrent/supervisord.log
* NGinX is logging to /var/log/nginx/access.log and /var/log/nginx/error.log
* PHP-FPM is logging to /usr/local/var/log/php-fpm.log
