#!/usr/bin/env bash

set -e # abort on error
set -u # abort on undefined variable

[ -e ./generated/env-variables ] && rm ./generated/env-variables
env_variables=./generated/env-variables

nova list |grep $PROJECT_ID > ./generated/novalist

export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo SCRIPT_DIR=$SCRIPT_DIR >> $env_variables
export PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo PROJECT_DIR=$SCRIPT_DIR >> $env_variables
export PREFIX_ID=$(cat ./etc/*tfvars|grep "prefix ="|awk '{print $3}'|cut -d - -f 1|tr -d '"')
export PROJECT_ID=$(echo $PREFIX_ID-ecp)
echo PROJECT_ID=$PROJECT_ID >> $env_variables

export LOCAL_SSH_PUB_KEY_PATH=./generated/controller.pub_key
echo LOCAL_SSH_PUB_KEY_PATH=$LOCAL_SSH_PUB_KEY_PATH >> $env_variables
export LOCAL_SSH_PRV_KEY_PATH=./generated/controller.prv_key
echo LOCAL_SSH_PRV_KEY_PATH=$LOCAL_SSH_PRV_KEY_PATH >> $env_variables

export CA_KEY=./generated/ca-key.pem
echo CA_KEY=$CA_KEY >> $env_variables
export CA_CERT=./generated/ca-cert.pem
echo CA_CERT=$CA_CERT >> $env_variables

export INSTALL_WITH_SSL=True
echo INSTALL_WITH_SSL=$INSTALL_WITH_SSL >> $env_variables

export EMBEDDED_DF=False
echo EMBEDDED_DF=$EMBEDDED_DF >> $env_variables

export AD_SERVER_ENABLED=True
echo AD_SERVER_ENABLED=$AD_SERVER_ENABLED >> $env_variables
export AD_INSTANCE_ID=$(cat ./generated/novalist|grep adserver | awk '{print $2}')
echo AD_INSTANCE_ID=$AD_INSTANCE_ID >> $env_variables
export AD_PRV_IP=$(cat ./generated/novalist|grep adserver | awk '{ split($12, v, "="); print v[2]}')
echo AD_PRV_IP=$AD_PRV_IP >> $env_variables
export AD_PUB_IP=$(cat ./generated/novalist|grep adserver | awk '{ split($12, v, "="); print v[2]}')
echo AD_PUB_IP=$AD_PUB_IP >> $env_variables
export AD_MEMBER_GROUP=DemoTenantUsers
echo AD_MEMBER_GROUP=$AD_MEMBER_GROUP >> $env_variables
export AD_ADMIN_GROUP=DemoTenantAdmins
echo AD_ADMIN_GROUP=$AD_ADMIN_GROUP >> $env_variables

export DNSSRVR_INSTANCE_ID=$(cat ./generated/novalist|grep dnsserver | awk '{print $2}')
echo DNSSRVR_INSTANCE_ID=$DNSSRVR_INSTANCE_ID >> $env_variables
export DNSSRVR_PRV_IP=$(cat ./generated/novalist|grep dnsserver | awk '{ split($12, v, "="); print v[2]}')
echo DNSSRVR_PRV_IP=$DNSSRVR_PRV_IP >> $env_variables
export DNSSRVR_PUB_IP=$(cat ./generated/novalist|grep dnsserver | awk '{ split($12, v, "="); print v[2]}')
echo DNSSRVR_PUB_IP=$DNSSRVR_PUB_IP >> $env_variables

export RDP_SERVER_ENABLED=False
echo RDP_SERVER_ENABLED=$RDP_SERVER_ENABLED >> $env_variables


export CTRL_INSTANCE_ID=$(cat ./generated/novalist|grep controller | awk '{print $2}')
echo CTRL_INSTANCE_ID=$CTRL_INSTANCE_ID >> $env_variables
export CTRL_PRV_IP=$(cat ./generated/novalist|grep controller | awk '{ split($12, v, "="); print v[2]}')
echo CTRL_PRV_IP=$CTRL_PRV_IP >> $env_variables
export CTRL_PUB_IP=$(cat ./generated/novalist|grep controller | awk '{ split($12, v, "="); print v[2]}')
echo CTRL_PUB_IP=$CTRL_PRV_IP >> $env_variables
export CTRL_PRV_DNS=$(cat ./generated/novalist|grep controller | awk '{ split($12, v, "="); print $4".demo.com"}')
echo CTRL_PRV_DNS=$CTRL_PRV_DNS >> $env_variables
export CTRL_PUB_DNS=$(cat ./generated/novalist|grep controller | awk '{ split($12, v, "="); print $4".demo.com"}')
echo CTRL_PUB_DNS=$CTRL_PUB_DNS >> $env_variables
export CTRL_PUB_HOST=$(cat ./generated/novalist|grep controller | awk '{ split($12, v, "="); print $4".demo.com"}')
echo CTRL_PUB_HOST=$CTRL_PUB_HOST >> $env_variables
export CTRL_PRV_HOST=$(cat ./generated/novalist|grep controller | awk '{ split($12, v, "="); print $4".demo.com"}')
echo CTRL_PRV_HOST=$CTRL_PRV_HOST >> $env_variables

export GATW_INSTANCE_ID=$(cat ./generated/novalist|grep gateway | awk '{print $2}')
echo GATW_INSTANCE_ID=$GATW_INSTANCE_ID >> $env_variables
export GATW_PRV_IP=$(cat ./generated/novalist|grep gateway | awk '{ split($12, v, "="); print v[2]}')
echo GATW_PRV_IP=$GATW_PRV_IP >> $env_variables
export GATW_PUB_IP=$(cat ./generated/novalist|grep gateway | awk '{ split($12, v, "="); print v[2]}')
echo GATW_PUB_IP=$GATW_PUB_IP >> $env_variables
export GATW_PRV_DNS=$(cat ./generated/novalist|grep gateway | awk '{ split($12, v, "="); print $4".demo.com"}')
echo GATW_PRV_DNS=$GATW_PRV_DNS >> $env_variables
export GATW_PUB_DNS=$(cat ./generated/novalist|grep gateway | awk '{ split($12, v, "="); print $4".demo.com"}')
echo GATW_PUB_DNS=$GATW_PUB_DNS >> $env_variables
export GATW_PUB_HOST=$(cat ./generated/novalist|grep gateway | awk '{ split($12, v, "="); print $4".demo.com"}')
echo GATW_PUB_HOST=$GATW_PUB_HOST >> $env_variables
export GATW_PRV_HOST=$(cat ./generated/novalist|grep gateway | awk '{ split($12, v, "="); print $4".demo.com"}')
echo GATW_PRV_HOST=$GATW_PRV_HOST >> $env_variables

if [[ "$RDP_SERVER_ENABLED" == "True" ]]; then
   export RDP_INSTANCE_ID=$(cat ./generated/novalist|grep rdpserver | awk '{print $1}')
   echo RDP_INSTANCE_ID=$RDP_INSTANCE_ID >> $env_variables
   export RDP_PRV_IP=$(cat ./generated/novalist|grep rdpserver | awk '{ split($12, v, "="); print v[2]}')
   echo RDP_PRV_IP=$RDP_PRV_IP >> $env_variables
   export RDP_PUB_IP=$(cat ./generated/novalist|grep rdpserver | awk '{ split($12, v, "="); print v[2]}')
   echo RDP_PUB_IP=$RDP_PUB_IP >> $env_variables
else
   RDP_INSTANCE_ID=""
fi

WORKER_COUNT=$(nova list|grep $PROJECT_ID|grep k8s|wc -l)

if [[ "$WORKER_COUNT" != "0" ]]; then
   export WRKR_INSTANCE_IDS=$(cat ./generated/novalist|grep k8s | awk '{ split($12, v, "="); print $2}'|awk 'BEGIN { ORS = " " } { print }')
   export WRKR_PRV_IPS=$(cat ./generated/novalist|grep k8s | awk '{ split($12, v, "="); print v[2]}'|awk 'BEGIN { ORS = " " } { print }')
   export WRKR_PUB_IPS=$(cat ./generated/novalist|grep k8s | awk '{ split($12, v, "="); print v[2]}'|awk 'BEGIN { ORS = " " } { print }')

else
   WRKR_INSTANCE_IDS=""
   WRKR_PRV_IPS=()
   WRKR_PUB_IPS=()
fi

echo WRKR_PRV_HOSTS=$WRKR_PRV_IPS >> $env_variables
echo WRKR_PUB_HOSTS=$WRKR_PUB_IPS >> $env_variables
echo WRKR_INSTANCE_IDS=$WRKR_INSTANCE_IDS >> $env_variables

export DF_MASTER_HOSTS=$(cat ./generated/novalist|grep k8sdfcomputemaster | awk '{ split($12, v, "="); print v[2]}'|awk 'BEGIN { ORS = " " } { print }')
echo DF_MASTER_HOSTS=${DF_MASTER_HOSTS} >> $env_variables
export DF_MASTER_IDS=$(cat ./generated/novalist|grep k8sdfcomputemaster | awk '{ split($12, v, "="); print $2}'|awk 'BEGIN { ORS = " " } { print }')
echo DF_MASTER_IDS=${DF_MASTER_IDS} >> $env_variables

export DF_WORKER_HOSTS=$(cat ./generated/novalist|grep k8sdfworker | awk '{ split($12, v, "="); print v[2]}'|awk 'BEGIN { ORS = " " } { print }')
echo DF_WORKER_HOSTS=${DF_WORKER_HOSTS} >> $env_variables
export DF_WORKER_IDS=$(cat ./generated/novalist|grep k8sdfworker | awk '{ split($12, v, "="); print $2}'|awk 'BEGIN { ORS = " " } { print }')
echo DF_WORKER_IDS=${DF_WORKER_IDS} >> $env_variables

export compute_WORKER_HOSTS=$(cat ./generated/novalist|grep k8scomputeworker | awk '{ split($12, v, "="); print v[2]}'|awk 'BEGIN { ORS = " " } { print }')
echo compute_WORKER_HOSTS=${compute_WORKER_HOSTS} >> $env_variables
export compute_WORKER_IDS=$(cat ./generated/novalist|grep k8scomputeworker | awk '{ split($12, v, "="); print $2}'|awk 'BEGIN { ORS = " " } { print }')
echo compute_WORKER_IDS=${compute_WORKER_IDS} >> $env_variables

export EXTERNALDF_HOSTS=$(cat ./generated/novalist|grep externaldf | awk '{ split($12, v, "="); print v[2]}'|awk 'BEGIN { ORS = " " } { print }')
echo EXTERNALDF_HOSTS=${EXTERNALDF_HOSTS} >> $env_variables
export EXTERNALDF_IDS=$(cat ./generated/novalist|grep externaldf | awk '{ split($12, v, "="); print $2}'|awk 'BEGIN { ORS = " " } { print }')
echo EXTERNALDF_IDS=${EXTERNALDF_IDS} >> $env_variables

