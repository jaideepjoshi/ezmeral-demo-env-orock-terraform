#!/bin/bash 

exec > >(tee -i generated/$(basename $0).txt)
exec 2>&1

set -e

if [[ -z $1 || -z $2 ]]; then
  echo Usage: $0 TENANT_ID MLFLOW_KD_CLUSTERNAME
  exit 1
fi

set -u

echo "Running script: $0 $@"

./scripts/check_prerequisites.sh
source "./scripts/functions.sh"
source "./scripts/00b-load-env-variables.sh"
export HPECP_CONFIG_FILE="./generated/hpecp.conf"

export TENANT_ID=$1
export MLFLOW_CLUSTER_NAME=$2


ssh -q -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T centos@${DNSSRVR_PRV_IP} <<-EOF1

  set -eu
  set -o pipefail

  export CLUSTER_ID=\$(hpecp tenant list --query "[?_links.self.href == '$TENANT_ID'] | [0] | [_links.k8scluster]" --output text)
  export TENANT_NS=\$(hpecp tenant list --query "[?_links.self.href == '$TENANT_ID'] | [0] | [namespace]" --output text)
  
  echo Waiting for MLOps Cluster to have state=configured
  COUNTER=0
  while [ \$COUNTER -lt 30 ]; 
  do
    STATE=\$(kubectl --kubeconfig <(hpecp k8scluster --id \$CLUSTER_ID admin-kube-config) \
                get kubedirectorcluster -n \$TENANT_NS $MLFLOW_CLUSTER_NAME -o 'jsonpath={.status.state}')
    echo STATE=\$STATE
    [[ \$STATE == "configured" ]] && break
    sleep 1m
    let COUNTER=COUNTER+1 
  done
  
  if [[ \$STATE != "configured" ]];
  then
    echo "State is not configured after 30 minutes.  Raising an error."
    exit 1
  fi

EOF1