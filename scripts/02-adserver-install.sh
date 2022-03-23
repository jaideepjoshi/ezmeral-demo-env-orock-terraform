#!/bin/bash

tput setaf 2
echo "Installing/Configuring AD Server"
tput sgr0

source "./scripts/functions.sh"
source "./scripts/00b-load-env-variables.sh"

exec > >(tee -i generated/$(basename $0).log)
exec 2>&1

date
#############################
#Install AD Server
#############################
for ADSRVR in `cat ./generated/novalist |grep $PROJECT_ID|grep adserver | awk '{ split($12, v, "="); print v[2]}'`
do
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$ADSRVR "hostname"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$ADSRVR "sudo sed -i --follow-symlinks 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$ADSRVR "sudo yum install -y deltarpm --nogpgcheck"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$ADSRVR "sudo yum install -y -q wget git --nogpgcheck"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$ADSRVR "sudo yum install -y openldap-clients --nogpgcheck"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$ADSRVR "wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$ADSRVR "sudo yum install -y -q epel-release-latest-7.noarch.rpm --nogpgcheck"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$ADSRVR "echo Copying Files to AD Server"
scp -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH ./files/adserver/* centos@$ADSRVR:/home/centos/
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$ADSRVR "sed -i s/AD_ADMIN_GROUP/DemoTenantAdmins/g /home/centos/ad_user_setup.sh"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$ADSRVR "sed -i s/AD_MEMBER_GROUP/DemoTenantUsers/g /home/centos/ad_user_setup.sh"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$ADSRVR "sed -i s/AD_ADMIN_GROUP/DemoTenantAdmins/g /home/centos/ad_set_posix_classes.ldif"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$ADSRVR "sed -i s/AD_MEMBER_GROUP/DemoTenantUsers/g /home/centos/ad_set_posix_classes.ldif"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$ADSRVR "echo Installing Docker"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$ADSRVR "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo" 
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$ADSRVR "sudo yum install -y -q docker-ce docker-ce-cli containerd.io --nogpgcheck"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$ADSRVR "sudo systemctl start docker"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$ADSRVR "echo Now running run_ad.sh. It can take 5 minutes getting docker images. Please be patient."
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$ADSRVR ". /home/centos/run_ad.sh"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$ADSRVR "sleep 120"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$ADSRVR "echo Now running ldif_modify.sh"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$ADSRVR ". /home/centos/ldif_modify.sh"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$ADSRVR "echo AD Server setup complete"
done

tput setaf 2
echo "AD Server Ready"
tput sgr0

#verify AD server config
./scripts/02a-adserver-verify-config.sh
