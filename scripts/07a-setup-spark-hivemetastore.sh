#!/bin/bash

exec > >(tee -i generated/$(basename $0).txt)
exec 2>&1

set -e
set -u
set -o pipefail

source "./scripts/functions.sh"
source "./scripts/00b-load-env-variables.sh"
export HPECP_CONFIG_FILE="./generated/hpecp.conf"

if [[ ! -d generated ]]; then
   echo "This file should be executed from the project directory"
   exit 1
fi

if [[ -z $1 ]]; then
  echo Usage: $0 TENANT_ID
  exit 1
fi

TENANT_ID=$1

export TENANT_NS=$(hpecp tenant get $TENANT_ID | grep "^namespace: " | cut -d " " -f 2)
echo TENANT_NS=$TENANT_NS

#export KUBEATNS=${1}
#export TENANT_NS=${KUBEATNS##* }
export HIVECLUSTERNAME=hivems
export AD_USER_NAME=ad_user1
export AD_USER_PASS=pass123

export AD_USER_ID=$(hpecp user list --query "[?label.name=='$AD_USER_NAME'] | [0] | [_links.self.href]" --output text | cut -d '/' -f 5 | sed '/^$/d')
echo AD_USER_NAME=$AD_USER_NAME
echo AD_USER_ID=$AD_USER_ID
export AD_USER_SECRET_HASH=$(python3 -c "import hashlib; print(hashlib.md5('$AD_USER_ID-$AD_USER_NAME'.encode('utf-8')).hexdigest())")
export AD_USER_KC_SECRET="hpecp-kc-secret-$AD_USER_SECRET_HASH"
echo AD_USER_KC_SECRET=$AD_USER_SECRET_HASH

ssh -q -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T centos@${DNSSRVR_PRV_IP} <<-EOF1

set -x
###
### Hive Metastore
###

echo "Creating Hive MetaStore"
cat <<EOF_YAML | kubectl --kubeconfig <(hpecp k8scluster --id $CLUSTER_ID admin-kube-config) -n $TENANT_NS apply -f -
apiVersion: v1 
kind: "ConfigMap"
metadata: 
  name: "${HIVECLUSTERNAME}"
  namespace: "${TENANT_NS}"
  labels: 
    kubedirector.hpe.com/cmType: "hivemetastore238"
data: 
  mysqlDB: "false"
  mysql_host: ""
  mysql_user: ""
  #Note: "Provide mysql_password as Base64-encoded value in Yaml."
  mysql_password: ""
  airgap: ""
  baserepository: ""
  imagename: ""
  tag: ""
  imagepullsecretname: ""
EOF_YAML

echo "Launching Hive MetaStore"
cat <<EOF_YAML | kubectl --kubeconfig <(hpecp k8scluster --id $CLUSTER_ID admin-kube-config) -n $TENANT_NS apply -f -
apiVersion: "kubedirector.hpe.com/v1beta1"
kind: "KubeDirectorCluster"
metadata: 
  name: "${HIVECLUSTERNAME}"
  namespace: "${TENANT_NS}"
  labels: 
    description: ""
spec: 
  app: "hivemetastore238"
  namingScheme: "CrNameRole"
  appCatalog: "local"
  connections: 
    secrets: 
      - ${AD_USER_KC_SECRET}
    configmaps: 
      - "${HIVECLUSTERNAME}"
  roles: 
    - 
      id: "hivemetastore"
      members: 1
      serviceAccountName: "ecp-tenant-member-sa"
      resources: 
        requests: 
          cpu: "2"
          memory: "8Gi"
          nvidia.com/gpu: "0"
        limits: 
          cpu: "2"
          memory: "8Gi"
          nvidia.com/gpu: "0"
      #Note: "if the application is based on hadoop3 e.g. using StreamCapabilities interface, then change the below dtap label to 'hadoop3', otherwise for most applications use the default 'hadoop2'"
      #podLabels: 
        #hpecp.hpe.com/dtap: "hadoop2"
EOF_YAML

  echo Waiting for Hive Metastore to have state=configured
  
  COUNTER=0
  while [ \$COUNTER -lt 5 ]; 
  do
    STATE=\$(kubectl --kubeconfig <(hpecp k8scluster --id $CLUSTER_ID admin-kube-config) \
                get kubedirectorcluster -n $TENANT_NS $HIVECLUSTERNAME -o 'jsonpath={.status.state}')
    echo STATE=\$STATE
    [[ \$STATE == "configured" ]] && break
    sleep 1m
    let COUNTER=COUNTER+1 
  done

EOF1
echo "Created Hive MetStore"

