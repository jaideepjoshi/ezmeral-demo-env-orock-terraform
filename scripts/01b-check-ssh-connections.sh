#!/bin/bash

echo "Checking ssh connectivty from Mac to instances. Please wait."

[ -e ~/.ssh/known_hosts ] && rm ~/.ssh/known_hosts 

source "./scripts/functions.sh"
source "./scripts/00b-load-env-variables.sh"

echo "Kicking off yum update on ECP Components"
for ECPHOSTS in `cat ./generated/novalist |grep $PROJECT_ID|grep -v vpnserver |grep -v adserver |grep -v externaldf |grep -v dnsserver| awk '{ split($12, v, "="); print v[2]}'`
do
#ssh -o StrictHostKeyChecking=no -i ./generated/controller.prv_key ubuntu@$ECPHOSTS "echo Connected to:;hostname"
ssh -o StrictHostKeyChecking=no -i ./generated/controller.prv_key centos@$ECPHOSTS "echo Kicking off yum update on:;hostname"
ssh -o StrictHostKeyChecking=no -i ./generated/controller.prv_key centos@$ECPHOSTS "hostname;sudo yum update -y" > /dev/null 2>&1 & 
done

echo "Kicking off apt-get update on ExternalDF Hosts"
for XDFHOSTS in `cat ./generated/novalist |grep $PROJECT_ID|grep externaldf | awk '{ split($12, v, "="); print v[2]}'`
do
#ssh -o StrictHostKeyChecking=no -i ./generated/controller.prv_key ubuntu@$XDFHOSTS "echo Connected to:;hostname"
ssh -o StrictHostKeyChecking=no -i ./generated/controller.prv_key ubuntu@$XDFHOSTS "echo Kicking off apt-get update update on:;hostname"
ssh -o StrictHostKeyChecking=no -i ./generated/controller.prv_key ubuntu@$XDFHOSTS "hostname;sudo apt-get update -y" > /dev/null 2>&1 & 
done

echo "Creating hostsfile for all instances"
cat ./generated/novalist | grep $PROJECT_ID| grep -v vpn|awk '{ split($12, v, "="); print v[2],$4".demo.com",$4}' > ./generated/hostsfile

echo "Copying the hostsfile and docker credentials files to all Centos instances"
for CENTOS in `cat ./generated/novalist |grep $PROJECT_ID|grep -v vpnserver|grep -v externaldf| awk '{ split($12, v, "="); print v[2]}'`; do 
    scp  -o StrictHostKeyChecking=no -i ./generated/controller.prv_key ./generated/hostsfile ./etc/config.json centos@$CENTOS:/home/centos/
    ssh  -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T centos@$CENTOS << ENDSSH
        cat hostsfile|sudo tee -a /etc/hosts >/dev/null
        sudo mkdir -p /root/.docker/ && sudo mkdir -p /.docker/ && sudo mkdir -p /var/lib/kubelet/
        sudo cp /home/centos/config.json /root/.docker/ && sudo cp /home/centos/config.json /.docker/ && sudo cp /home/centos/config.json /var/lib/kubelet/
ENDSSH
done
echo "echo Done setting up hostsfile etc. on all Centos instances"

echo "Copying the hostsfile and docker credentials files to all Ubuntu instances"
for UBUNTU in `cat ./generated/novalist |grep $PROJECT_ID|grep externaldf | awk '{ split($12, v, "="); print v[2]}'`; do
    scp  -o StrictHostKeyChecking=no -i ./generated/controller.prv_key ./generated/hostsfile ./etc/config.json ubuntu@$UBUNTU:/home/ubuntu/
    ssh  -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$UBUNTU << ENDSSH
        cat hostsfile|sudo tee -a /etc/hosts >/dev/null
        sudo mkdir -p /root/.docker/ && sudo mkdir -p /.docker/ && sudo mkdir -p /var/lib/kubelet/
        sudo cp /home/ubuntu/config.json /root/.docker/ && sudo cp /home/ubuntu/config.json /.docker/ && sudo cp /home/ubuntu/config.json /var/lib/kubelet/
ENDSSH
done
echo "echo Done setting up hostsfile etc. on all Ubuntu instances"

#for CENTOS in `cat ./generated/novalist |grep $PROJECT_ID|grep -v vpn|grep -v externaldf| awk '{ split($12, v, "="); print v[2]}'`
#do
#scp  -o StrictHostKeyChecking=no -i ./generated/controller.prv_key ./generated/hostsfile centos@$CENTOS:/home/centos/hosts
#ssh  -o StrictHostKeyChecking=no -i ./generated/controller.prv_key centos@$CENTOS "cat hosts|sudo tee -a /etc/hosts >/dev/null"
#scp -i ./generated/controller.prv_key -o StrictHostKeyChecking=no ./etc/config.json centos@$CENTOS:/tmp
#ssh  -i ./generated/controller.prv_key -o StrictHostKeyChecking=no centos@$CENTOS "sudo mkdir -p /root/.docker/ && sudo mkdir -p /.docker/ && sudo mkdir -p /var/lib/kubelet/"
#ssh  -i ./generated/controller.prv_key -o StrictHostKeyChecking=no centos@$CENTOS "sudo cp /tmp/config.json /root/.docker/ && sudo cp /tmp/config.json /.docker/ && sudo cp /tmp/config.json /var/lib/kubelet/"
#done

#echo "Copying the hostsfile and docker credentials files to all Ubuntu instances"
#for UBUNTU in `cat ./generated/novalist |grep $PROJECT_ID|grep externaldf | awk '{ split($12, v, "="); print v[2]}'`
#do
#scp  -o StrictHostKeyChecking=no -i ./generated/controller.prv_key ./generated/hostsfile ubuntu@$UBUNTU:/home/ubuntu/hosts
#ssh  -o StrictHostKeyChecking=no -i ./generated/controller.prv_key ubuntu@$UBUNTU "cat hosts|sudo tee -a /etc/hosts >/dev/null"
#scp -i ./generated/controller.prv_key -o StrictHostKeyChecking=no ./etc/config.json ubuntu@$UBUNTU:/tmp
#ssh  -i ./generated/controller.prv_key -o StrictHostKeyChecking=no ubuntu@$UBUNTU "sudo mkdir -p /root/.docker/ && sudo mkdir -p /.docker/ && sudo mkdir -p /var/lib/kubelet/"
#ssh  -i ./generated/controller.prv_key -o StrictHostKeyChecking=no ubuntu@$UBUNTU "sudo cp /tmp/config.json /root/.docker/ && sudo cp /tmp/config.json /.docker/ && sudo cp /tmp/config.json /var/lib/kubelet/"
#done