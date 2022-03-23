#!/bin/bash
for x in `openstack server list|grep $PROJECT_ID|grep vpn|awk '{print $9}'`
do 
echo "Getting client.ovpn from VPN Server"
scp  -o StrictHostKeyChecking=no -i ./generated/controller.prv_key ubuntu@$x:/home/ubuntu/client.ovpn ./generated/client.ovpn
done
echo "Starting openvpn on local Mac"
#sudo brew services restart openvpn
sudo brew services restart openvpn > ./generated/openvpn-start.log 2>&1 &
export PATH=$(brew --prefix openvpn)/sbin:$PATH
sudo openvpn --config ./generated/client.ovpn >> ./generated/openvpn-start.log 2>&1 &
