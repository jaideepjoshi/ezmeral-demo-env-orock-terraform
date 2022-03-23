#!/bin/bash

exec > >(tee -i generated/$(basename $0).log)
exec 2>&1
date

WRKR_PUB_IPS=$(cat ./generated/novalist|grep $PROJECT_ID|grep k8s | awk '{ split($12, v, "="); print v[2]}')

set -e # abort on error
set -u # abort on undefined variable
set -o pipefail

./scripts/check_prerequisites.sh
source "./scripts/functions.sh"
source "./scripts/00b-load-env-variables.sh"
export HPECP_CONFIG_FILE="./generated/hpecp.conf"

for WRKR in `echo $WRKR_PUB_IPS`; do  
{  
    # install falco
    ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" centos@${WRKR} "echo Installing RPMs on K8shosts;hostname"
    ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" centos@${WRKR} "sudo yum-config-manager --enable repository cr" 
    ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" centos@${WRKR} "sudo rpm --import https://falco.org/repo/falcosecurity-3672BA8F.asc" 
    ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" centos@${WRKR} "sudo curl -s -o /etc/yum.repos.d/falcosecurity.repo https://falco.org/repo/falcosecurity-rpm.repo" > /dev/null 2>&1 & 
    ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" centos@${WRKR} "sudo yum -y install --enablerepo=extras epel-release" 
    ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" centos@${WRKR} "sudo yum -y install --enablerepo=epel dkms" 
    ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" centos@${WRKR} "sudo yum update -y -q"  
    ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" centos@${WRKR} "sudo yum -y install kernel*" 
    ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@${WRKR} "echo Rebooting K8sHost;hostname"
    ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" centos@${WRKR} "nohup sudo reboot </dev/null &" 
     ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T centos@${WRKR} "nohup sudo reboot </dev/null &" || true
} &
done

wait

for WRKR in `echo $WRKR_PUB_IPS`; do 
    echo "Waiting for Worker ${WRKR} ssh session"
    while ! nc -w5 -z ${WRKR} 22; do printf "." -n ; done;
    echo 'Worker has rebooted'
done

set +u
for WRKR in `echo $WRKR_PUB_IPS`; do 
{
      ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" centos@${WRKR} "echo Installing Falco"
      ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" centos@${WRKR} "sudo yum -y install falco"
      ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" centos@${WRKR} "sudo systemctl enable falco"
      ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" centos@${WRKR} "sudo systemctl start falco"
      ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" centos@${WRKR} "echo Falco Started"
} &
done

wait

tput setaf 2
echo "k8shosts Configured"
tput sgr0