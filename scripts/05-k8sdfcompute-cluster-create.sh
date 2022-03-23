#!/bin/bash

./scripts/check_prerequisites.sh
source "./scripts/functions.sh"
source "./scripts/00b-load-env-variables.sh"
export HPECP_CONFIG_FILE="./generated/hpecp.conf"

exec > >(tee -i generated/$(basename $0).log)
exec 2>&1
date

tput setaf 2
echo "Preparing k8shosts: Installing RPMS Falco Driver"
tput sgr0
#Prepare K8shosts with RPMs and falco
./scripts/05a-k8shosts-prepare.sh

#Setup DNS
./scripts/05b-k8shosts-setup-dns.sh

################################################################################
#
# DF setup
#
################################################################################

# select the IP addresses of the k8s hosts
DF_MASTER_HOSTS=$(cat ./generated/novalist |grep $PROJECT_ID|grep k8sdfcomputemaster | awk '{ split($12, v, "="); print v[2]}'|awk 'BEGIN { ORS = " " } { print }')
DF_WORKER_HOSTS=$(cat ./generated/novalist |grep $PROJECT_ID|grep k8sdfworker | awk '{ split($12, v, "="); print v[2]}'|awk 'BEGIN { ORS = " " } { print }')
COMPUTE_WORKER_HOSTS=$(cat ./generated/novalist |grep $PROJECT_ID|grep k8scomputeworker | awk '{ split($12, v, "="); print v[2]}'|awk 'BEGIN { ORS = " " } { print }')

DF_MASTER_HOSTS_1=$(cat ./generated/novalist |grep $PROJECT_ID|grep k8sdfcomputemaster | awk '{ split($12, v, "="); print "\047"v[2]"\047"}'| tr "\n" "," | sed 's/,$/ /' | tr " " "\n")
DF_WORKER_HOSTS_1=$(cat ./generated/novalist |grep $PROJECT_ID|grep k8sdfworker | awk '{ split($12, v, "="); print "\047"v[2]"\047"}'| tr "\n" "," | sed 's/,$/ /' | tr " " "\n")
COMPUTE_WORKER_HOSTS_1=$(cat ./generated/novalist |grep $PROJECT_ID|grep k8scomputeworker | awk '{ split($12, v, "="); print "\047"v[2]"\047"}'| tr "\n" "," | sed 's/,$/ /' | tr " " "\n")

DF_MASTER_IDS=$(cat ./generated/novalist |grep $PROJECT_ID|grep k8sdfcomputemaster | awk '{ split($12, v, "="); print $2}'|awk 'BEGIN { ORS = " " } { print }')
DF_WORKER_IDS=$(cat ./generated/novalist |grep $PROJECT_ID|grep k8sdfworker | awk '{ split($12, v, "="); print $2}'|awk 'BEGIN { ORS = " " } { print }')
COMPUTE_WORKER_IDS=$(cat ./generated/novalist |grep $PROJECT_ID|grep k8scomputeworker | awk '{ split($12, v, "="); print $2}'|awk 'BEGIN { ORS = " " } { print }')

# Add DF Masters without tags
./scripts/05c-k8sdfcomputemasters-add.sh $DF_MASTER_HOSTS &
DF_MASTER_HOSTS_ADD_PID=$!

# Add DF Workers with DF tags
./scripts/05d-k8sdfworkers-add.sh $DF_WORKER_HOSTS &
WORKER_DF_HOSTS_ADD_PID=$!

# Add COMPUTE Workers without DF tags
./scripts/05e-k8scomputeworkers-add.sh $COMPUTE_WORKER_HOSTS &
WORKER_NON_DF_HOSTS_ADD_PID=$!

wait $DF_MASTER_HOSTS_ADD_PID
wait $WORKER_DF_HOSTS_ADD_PID
wait $WORKER_NON_DF_HOSTS_ADD_PID


QUERY="[*] | @[?contains('${DF_MASTER_HOSTS}', ipaddr)] | [*][_links.self.href] | [] | sort(@)"
DF_MASTER_IDS=$(hpecp k8sworker list --query "${QUERY}" --output text | tr '\n' ' ')
echo DF_MASTER_HOSTS=$DF_MASTER_HOSTS
echo DF_MASTER_IDS=$DF_MASTER_IDS

QUERY="[*] | @[?contains('${DF_WORKER_HOSTS}', ipaddr)] | [*][_links.self.href] | [] | sort(@)"
DF_WORKER_IDS=$(hpecp k8sworker list --query "${QUERY}" --output text | tr '\n' ' ')
echo DF_WORKER_HOSTS=$DF_WORKER_HOSTS
echo DF_WORKER_IDS=$DF_WORKER_IDS

QUERY="[*] | @[?contains('${COMPUTE_WORKER_HOSTS}', ipaddr)] | [*][_links.self.href] | [] | sort(@)"
COMPUTE_WORKER_IDS=$(hpecp k8sworker list --query "${QUERY}" --output text | tr '\n' ' ')
echo COMPUTE_WORKER_HOSTS=$COMPUTE_WORKER_HOSTS
echo COMPUTE_WORKER_IDS=$COMPUTE_WORKER_IDS

K8S_VERSION=$(hpecp k8scluster k8s-supported-versions --major-filter 1 --minor-filter 20 --output text)

AD_SERVER_PRIVATE_IP=$AD_PRV_IP

K8S_HOST_CONFIG="$(echo $DF_MASTER_IDS | sed 's/ /:master,/g'):master,$(echo $DF_WORKER_IDS $COMPUTE_WORKER_IDS | sed 's/ /:worker,/g'):worker"
echo K8S_HOST_CONFIG=$K8S_HOST_CONFIG

EXTERNAL_GROUPS=$(echo '["CN=AD_ADMIN_GROUP,CN=Users,DC=samdom,DC=example,DC=com","CN=AD_MEMBER_GROUP,CN=Users,DC=samdom,DC=example,DC=com"]' \
    | sed s/AD_ADMIN_GROUP/${AD_ADMIN_GROUP}/g \
    | sed s/AD_MEMBER_GROUP/${AD_MEMBER_GROUP}/g)

echo "Creating k8s cluster with version ${K8S_VERSION}"
CLUSTER_ID=$(hpecp k8scluster create \
   --name k8sdfcluster \
   --k8s-version $K8S_VERSION \
   --k8shosts-config "$K8S_HOST_CONFIG" \
   --addons '["spark-operator", "kubeflow", "istio"]' \
   --ext_id_svr_bind_pwd "5ambaPwd@" \
   --ext_id_svr_user_attribute "sAMAccountName" \
   --ext_id_svr_bind_type "search_bind" \
   --ext_id_svr_bind_dn "cn=Administrator,CN=Users,DC=samdom,DC=example,DC=com" \
   --ext_id_svr_host "${AD_SERVER_PRIVATE_IP}" \
   --ext_id_svr_group_attribute "member" \
   --ext_id_svr_security_protocol "ldaps" \
   --ext_id_svr_base_dn "CN=Users,DC=samdom,DC=example,DC=com" \
   --ext_id_svr_verify_peer false \
   --ext_id_svr_type "Active Directory" \
   --ext_id_svr_port 636 \
   --external-groups "$EXTERNAL_GROUPS" \
   --datafabric true \
   --datafabric-name=k8sdfdemo)
   
echo CLUSTER_ID=$CLUSTER_ID

#echo CONTROLLER URL: $(terraform output controller_public_url)

date
echo "Waiting up to 1 hour for status == error|ready"
hpecp k8scluster wait-for-status '[error,ready]' --id $CLUSTER_ID --timeout-secs 3600
date

hpecp k8scluster list

hpecp config get | grep  bds_global_

if hpecp k8scluster list | grep ready
then
     echo "K8SDF Cluster installed. Proceeding to register DF Cluster"
else
     set +e
     THE_DATE=$(date +"%Y-%m-%dT%H:%M:%S%z")
     ./bin/ssh-controller.sh sudo tar czf - /var/log/bluedata/ > ${THE_DATE}-controller-logs.tar.gz
     
     for i in "${!WRKR_PUB_IPS[@]}"; do
       ssh -o StrictHostKeyChecking=no -i "./generated/controller.prv_key" centos@${WRKR_PUB_IPS[$i]} sudo tar czf - /var/log/bluedata/ > ${THE_DATE}-${WRKR_PUB_IPS[$i]}-logs.tar.gz
     done
     exit 1
fi
