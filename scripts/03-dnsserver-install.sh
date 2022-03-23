#!/bin/bash

source "./scripts/functions.sh"
source "./scripts/00b-load-env-variables.sh"

exec > >(tee -i generated/$(basename $0).log)
exec 2>&1
date

tput setaf 2
echo "Installing/Configuring DNS Server"
tput sgr0

export LOCAL_SSH_PRV_KEY_PATH=./generated/controller.prv_key
#############################
#Install DNS Server
#############################
for DNSSRVR in `cat ./generated/novalist |grep $PROJECT_ID|grep dnsserver | awk '{ split($12, v, "="); print v[2]}'`
do
echo "using $LOCAL_SSH_PRV_KEY_PATH"
echo "Setting up DNS Server $DNSSRVR"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "hostname;sudo yum update -y"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "sudo cat /etc/resolv.conf"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "sudo sed -i --follow-symlinks 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "sudo yum -y install wget git"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "sudo yum install -y -q epel-release-latest-7.noarch.rpm --nogpgcheck"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "sudo yum -y install bind-utils"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "sudo yum -y install dnsmasq"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.bak" 
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "echo listen-address=::1,127.0.0.1,$DNSSRVR >> dnsmasq.conf"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "echo domain=demo.com >> dnsmasq.conf"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "echo address=/demo.com/127.0.0.1 >> dnsmasq.conf"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "echo address=/demo.com/$DNSSRVR >> dnsmasq.conf"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "cat dnsmasq.conf|sudo tee -a /etc/dnsmasq.conf" 
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "sudo mv /etc/resolv.conf /etc/resolv.conf.bak" 
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "echo nameserver $DNSSRVR >> resolv.conf"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "echo nameserver 1.1.1.1 >> resolv.conf"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "echo nameserver 1.0.0.1 >> resolv.conf"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "cat resolv.conf|sudo tee -a /etc/resolv.conf"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "sudo systemctl restart dnsmasq"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "sudo systemctl status dnsmasq"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "sudo dnsmasq --test"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "nslookup $CTRL_PRV_HOST"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "echo DNSmasq setup complete"
# Install KUBECTL
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "echo Installing kubectl"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "chmod +x ./kubectl"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "sudo mv ./kubectl /usr/local/bin/kubectl"
# Install HELM
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "echo Installing helm"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "chmod 700 get_helm.sh"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "./get_helm.sh"
 # Install HPECP   
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "echo Installing pip3/hpecp"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "sudo yum install python3-pip -y"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "pip3 install --upgrade --user hpecp"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$DNSSRVR "echo Installed pip3/hpecp"
done

tput setaf 2
echo "DNS Server Ready"
tput sgr0