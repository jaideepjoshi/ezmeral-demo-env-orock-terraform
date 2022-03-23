#!/bin/bash

source "./scripts/functions.sh"
source "./scripts/00b-load-env-variables.sh"

# Copy SSH keys Local Mac to Controller
cat generated/controller.prv_key | \
   ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T centos@${CTRL_PUB_IP} "cat > ~/.ssh/id_rsa"
ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T centos@${CTRL_PUB_IP} "chmod 600 ~/.ssh/id_rsa"

cat generated/controller.pub_key | \
   ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T centos@${CTRL_PUB_IP} "cat > ~/.ssh/id_rsa.pub"
ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T centos@${CTRL_PUB_IP} "chmod 600 ~/.ssh/id_rsa.pub"

tput setaf 2
echo "Controller -> Gateway"
tput sgr0
#
# Controller -> Gateway
#
# Copy the Controller SSH key to the Gateway
ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T centos@${CTRL_PUB_IP} "cat /home/centos/.ssh/id_rsa.pub" | \
  ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T centos@${GATW_PUB_IP} "cat >> /home/centos/.ssh/authorized_keys" 

# Test passwordless SSH connection from Controller to Gateway
ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T centos@${CTRL_PUB_IP} << ENDSSH
echo CONTROLLER ${CTRL_PRV_IP} connecting to GATEWAY ${GATW_PRV_IP}...
ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa -T centos@${GATW_PRV_IP} "echo Controller connected to Gateway!"
ENDSSH

tput setaf 2
echo "Controller -> K8S Workers"
tput sgr0

#
# Controller -> Workers
#
# Copy the Controller SSH key to each Worker
set +u
WORKER_COUNT=$(cat ./generated/novalist |grep $PROJECT_ID|grep k8s|wc -l)

if [[ "$WORKER_COUNT" != "0" ]]; then
   export WRKR_INSTANCE_IDS=$(cat ./generated/novalist |grep $PROJECT_ID|grep k8s | awk '{ split($12, v, "="); print $2}'|awk 'BEGIN { ORS = " " } { print }')
   export WRKR_PRV_IPS=$(cat ./generated/novalist  |grep $PROJECT_ID|grep k8s | awk '{ split($12, v, "="); print v[2]}'|awk 'BEGIN { ORS = " " } { print }')
   export WRKR_PUB_IPS=$(cat ./generated/novalist  |grep $PROJECT_ID|grep k8s | awk '{ split($12, v, "="); print v[2]}'|awk 'BEGIN { ORS = " " } { print }')

else
   WRKR_INSTANCE_IDS=""
   WRKR_PRV_IPS=()
   WRKR_PUB_IPS=()
fi

for WRKR in `echo $WRKR_PUB_IPS|fmt -1`; do 
    ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T centos@${CTRL_PUB_IP} "cat /home/centos/.ssh/id_rsa.pub" | \
        ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T centos@${WRKR} "cat >> /home/centos/.ssh/authorized_keys"
done

# Test passwordless SSH connection from Controller to Workers
for WRKR in `echo $WRKR_PRV_IPS|fmt -1`; do 
    ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T centos@${CTRL_PUB_IP} << ENDSSH
        echo CONTROLLER ${CTRL_PRV_IP} connecting to K8S HOST ${WRKR}...
        ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa -T centos@${WRKR} "echo Connected to K8SHost!"
ENDSSH
done
set -u

# Copy SSH keys Local Mac to DNS Server
cat generated/controller.prv_key | \
   ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T centos@${DNSSRVR_PUB_IP} "cat > ~/.ssh/id_rsa"
ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T centos@${DNSSRVR_PUB_IP} "chmod 600 ~/.ssh/id_rsa"

cat generated/controller.pub_key | \
   ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T centos@${DNSSRVR_PUB_IP} "cat > ~/.ssh/id_rsa.pub"
ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T centos@${DNSSRVR_PUB_IP} "chmod 600 ~/.ssh/id_rsa.pub"

tput setaf 2
echo "DNS Server -> Gateway"
tput sgr0
# Test passwordless SSH connection from DNS Server to Gateway
ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T centos@${DNSSRVR_PUB_IP} << ENDSSH
echo DNS Server ${DNSSRVR_PUB_IP} connecting to GATEWAY ${GATW_PRV_IP}...
ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa -T centos@${GATW_PRV_IP} "echo DNS Server connected to Gateway!"
ENDSSH

tput setaf 2
echo "DNS Server -> K8S Workers"
tput sgr0

# DNS Server -> Workers
#
set +u
WORKER_COUNT=$(nova list|grep $PROJECT_ID|grep k8s|wc -l)

if [[ "$WORKER_COUNT" != "0" ]]; then
   export WRKR_INSTANCE_IDS=$(cat ./generated/novalist |grep $PROJECT_ID|grep k8s | awk '{ split($12, v, "="); print $2}'|awk 'BEGIN { ORS = " " } { print }')
   export WRKR_PRV_IPS=$(cat ./generated/novalist |grep $PROJECT_ID|grep k8s | awk '{ split($12, v, "="); print v[2]}'|awk 'BEGIN { ORS = " " } { print }')
   export WRKR_PUB_IPS=$(cat ./generated/novalist |grep $PROJECT_ID|grep k8s | awk '{ split($12, v, "="); print v[2]}'|awk 'BEGIN { ORS = " " } { print }')

else
   WRKR_INSTANCE_IDS=""
   WRKR_PRV_IPS=()
   WRKR_PUB_IPS=()
fi

# Test passwordless SSH connection from DNS Server to Workers
for WRKR in `echo $WRKR_PRV_IPS|fmt -1`; do 
    ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T centos@${DNSSRVR_PUB_IP} << ENDSSH
        echo DNS Server ${DNSSRVR_PUB_IP} connecting to K8S HOST ${WRKR}...
        ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa -T centos@${WRKR} "echo Connected to K8SHost!"
ENDSSH
done
set -u

# Copy the Controller SSH key to each External DF Host
set +u

tput setaf 2
echo "DNS Server -> External DF Hosts"
tput sgr0
EXT_DF_COUNT=$(cat ./generated/novalist |grep $PROJECT_ID|grep externaldf|wc -l)

if [[ "$WORKER_COUNT" != "0" ]]; then
   export EXT_DF_INSTANCE_IDS=$(cat ./generated/novalist |grep $PROJECT_ID|grep externaldf | awk '{ split($12, v, "="); print $2}'|awk 'BEGIN { ORS = " " } { print }')
   export EXT_DF_PRV_IPS=$(cat ./generated/novalist |grep $PROJECT_ID|grep externaldf | awk '{ split($12, v, "="); print v[2]}'|awk 'BEGIN { ORS = " " } { print }')
   export EXT_DF_PUB_IPS=$(cat ./generated/novalist |grep $PROJECT_ID|grep externaldf| awk '{ split($12, v, "="); print v[2]}'|awk 'BEGIN { ORS = " " } { print }')

else
   EXT_DF_INSTANCE_IDS=""
   EXT_DF_PRV_IPS=()
   EXT_DF_PUB_IPS=()
fi

#For Ubnutu ExternalDF hosts
for EXT_DF in `echo $EXT_DF_PUB_IPS|fmt -1`; do 
    ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T centos@${CTRL_PUB_IP} "cat /home/centos/.ssh/id_rsa.pub" | \
        ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T ubuntu@${EXT_DF} "cat >> /home/ubuntu/.ssh/authorized_keys"
done

# Test passwordless SSH connection from Controller to Ubuntu EXTERNAL DF
for EXT_DF in `echo $EXT_DF_PUB_IPS|fmt -1`; do 
    ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T centos@${DNSSRVR_PUB_IP} << ENDSSH
        echo DNS Server ${DNSSRVR_PUB_IP} connecting to External DF Host ${EXT_DF}...
        ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa -T ubuntu@${EXT_DF} "echo Connected to External DF Host!"
ENDSSH
done