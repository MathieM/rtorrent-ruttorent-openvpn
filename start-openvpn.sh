#!/bin/sh

set -x

#Prepare OpenVPN
#Setup local network exclusion from VPN (based on https://github.com/haugene/docker-transmission-openvpn/blob/master/openvpn/start.sh)
if [ -n "${VPN_EXCLUDE_NETWORK-}" ]; then
  eval $(/sbin/ip r l m 0.0.0.0 | awk '{if($5!="tun0"){print "GW="$3"\nINT="$5; exit}}')
  if [ -n "${GW-}" -a -n "${INT-}" ]; then
    echo "adding route to local network $VPN_EXCLUDE_NETWORK via $GW dev $INT"
    /sbin/ip r a "$VPN_EXCLUDE_NETWORK" via "$GW" dev "$INT"
  fi
fi


#Start openvpn 
echo "Starting OpenVPN..."
cd /home/rtorrent/vpn
openvpn --config *.ovpn

OPENVPN_EXIT_CODE=$?

#Route all traffic through VPN
sleep 20
IP=`/sbin/ifconfig tun0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'`
ip route replace 0.0.0.0/0 via $IP

#Little time to ensure the VPN connection is up
sleep 10

#Change DNS to provided (or default) one
echo "nameserver ${DNS_SERVER_IP}" > /etc/resolv.conf
chattr +i /etc/resolv.conf

exit $OPENVPN_EXIT_CODE