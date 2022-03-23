#!/bin/bash
sudo brew services stop openvpn > ./generated/openvpn-stop.log 2>&1 &
sudo pkill openvpn
sleep 5