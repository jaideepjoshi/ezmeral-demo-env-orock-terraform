#!/bin/bash

tput setaf 2
echo "Installing/Configuring ECP Gateway"
tput sgr0

set -e # abort on error
set -u # abort on undefined variable

source "./scripts/functions.sh"
source "./scripts/00b-load-env-variables.sh"

exec > >(tee -i generated/$(basename $0).log)
exec 2>&1

if [[ ! -d generated ]]; then
   echo "This file should be executed from the project directory"
   exit 1
fi

./scripts/check_prerequisites.sh

echo "Install packages on ECP Gateway"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$GATW_PRV_IP "hostname"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$GATW_PRV_IP "sudo yum install -y deltarpm --nogpgcheck"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$GATW_PRV_IP "echo Patience. Running Yum Update"
#ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$GATW_PRV_IP "sudo yum update -y"
ssh -o StrictHostKeyChecking=no -i $LOCAL_SSH_PRV_KEY_PATH centos@$GATW_PRV_IP "sudo yum install -y wget git --nogpgcheck"

# use the project's HPECP CLI config file
export HPECP_CONFIG_FILE="./generated/hpecp.conf"

echo "Configuring the ECP Gateway"
echo "Deleting and creating lock"
hpecp lock delete-all
hpecp lock create "Install Gateway"

CONFIG_GATEWAY_DNS=$GATW_PUB_DNS

echo "Configuring the Gateway"
GATEWAY_ID=$(hpecp gateway create-with-ssh-key "$GATW_PRV_IP" "$CONFIG_GATEWAY_DNS" --ssh-key-file ./generated/controller.prv_key)

echo "Waiting for gateway to have state 'installed'"
hpecp gateway wait-for-state "${GATEWAY_ID}" --states "['installed']" --timeout-secs 1800

echo "Removing locks"
hpecp gateway list
hpecp lock delete-all --timeout-secs 1800

tput setaf 2
echo "ECP Gateway Installed"
tput sgr0

tput setaf 2
echo "Set Gateway SSL"
tput sgr0
./scripts/04f-gateway-set-ssl.sh
