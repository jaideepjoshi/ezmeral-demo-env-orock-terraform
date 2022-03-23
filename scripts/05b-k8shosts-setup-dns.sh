#!/bin/bash

source "./scripts/functions.sh"
source "./scripts/00b-load-env-variables.sh"

exec > >(tee -i generated/$(basename $0).log)
exec 2>&1

tput setaf 2
echo "Setup nameserver on all instances"
tput sgr0

#Create resolv.conf on K8s Workers
#

for WRKR in `cat ./generated/novalist |grep $PROJECT_ID|grep k8s | awk '{ split($12, v, "="); print v[2]}'`; do 
ssh -o StrictHostKeyChecking=no -i ./generated/controller.prv_key centos@$WRKR "sudo yum install -y bind-utils --disablerepo=epel" 
#ssh -o StrictHostKeyChecking=no -i ./generated/controller.prv_key centos@$WRKR "sudo yum install -y bind-utils" 
ssh -o StrictHostKeyChecking=no -i ./generated/controller.prv_key centos@$WRKR "sudo mv /etc/resolv.conf /etc/resolv.conf.bak" 
ssh -o StrictHostKeyChecking=no -i ./generated/controller.prv_key centos@$WRKR "echo nameserver $DNSSRVR_PRV_IP >> resolv.conf"
ssh -o StrictHostKeyChecking=no -i ./generated/controller.prv_key centos@$WRKR "echo nameserver 1.1.1.1 >> resolv.conf"
ssh -o StrictHostKeyChecking=no -i ./generated/controller.prv_key centos@$WRKR "cat resolv.conf|sudo tee -a /etc/resolv.conf"
ssh -o StrictHostKeyChecking=no -i ./generated/controller.prv_key centos@$WRKR "echo $WRKR configured with DNS"
done
echo "I am here"
for WRKR in `cat ./generated/novalist |grep $PROJECT_ID|grep k8s | awk '{ split($12, v, "="); print v[2]}'`; do 
ssh -o StrictHostKeyChecking=no -i ./generated/controller.prv_key centos@$WRKR "echo Resolving Gateway hostname from $WRKR"
ssh -o StrictHostKeyChecking=no -i ./generated/controller.prv_key centos@$WRKR "nslookup $GATW_PRV_HOST" 
done

set -u

tput setaf 2
echo "DNS Setup Complete"
tput sgr0