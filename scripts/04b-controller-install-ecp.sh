#!/bin/bash

exec > >(tee -i generated/$(basename $0).log)
exec 2>&1
date

tput setaf 2
echo "Installing/Configuring ECP Controller"
tput sgr0

set -e # abort on error
set -u # abort on undefined variable
set -o pipefail

#SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source "./scripts/functions.sh"
source "./scripts/00b-load-env-variables.sh"

#############################
#Install ECP Controller
#############################
for CONTROLLER in `cat ./generated/novalist |grep $PROJECT_ID|grep controller | awk '{ split($12, v, "="); print v[2]}'`
do
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$CONTROLLER "wget -c --progress=bar -e dotbytes=1M https://ezmeral-platform-releases.s3.amazonaws.com/5.4/3064/hpe-cp-rhel-release-5.4-3064.bin"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$CONTROLLER "chmod +x hpe-cp-rhel-release-5.4-3064.bin"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$CONTROLLER "./hpe-cp-rhel-release-5.4-3064.bin --default-password admin123 --skipeula --ssl-cert /home/centos/minica.pem --ssl-priv-key /home/centos/minica-key.pem"

ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$CONTROLLER << ENDSSH
   set -e
   set -u
   # do initial configuration
   KERB_OPTION="-k no"
   LOCAL_TENANT_STORAGE="--no-local-tenant-storage"
   LOCAL_FS_TYPE=""
   WORKER_LIST=""
   CLUSTER_IP=""
   HA_OPTION=""
   PROXY_LIST=""
   FLOATING_IP="--routable no"
   DOMAIN_NAME="demo.ezmeral"
   CONTROLLER_IP="-c ${CONTROLLER}"
   CUSTOM_INSTALL_NAME="--cin demo-hpecp"
   echo "*************************************************************************************"
   echo "The next step can take 10 mins or more to run without any output - please be patient."
   echo "*************************************************************************************"
   #
   # WARNING: This script is an internal API and is not supported being used directly by users
   #
   /opt/bluedata/common-install/scripts/start_install.py \$CONTROLLER_IP \
      \$WORKER_LIST \$PROXY_LIST \$KERB_OPTION \$HA_OPTION \
      \$FLOATING_IP -t 60 -s docker -d \$DOMAIN_NAME \$CUSTOM_INSTALL_NAME \$LOCAL_TENANT_STORAGE
ENDSSH
done