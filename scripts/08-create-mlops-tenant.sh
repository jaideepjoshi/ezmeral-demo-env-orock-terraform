#!/bin/bash

set -e
set -o pipefail

source "./scripts/functions.sh"
source "./scripts/00b-load-env-variables.sh"
export HPECP_CONFIG_FILE="./generated/hpecp.conf"
export env_variables=./generated/env-variables

exec > >(tee -i generated/$(basename $0).log)
exec 2>&1


tput setaf 2
echo "Setting up MLOPS Environment"
tput sgr0

CLUSTER_ID=$(hpecp k8scluster list|grep cluster|awk '{print $2}')
echo "Creating MLOps Tenant"
echo CLUSTER_ID=$CLUSTER_ID
echo CLUSTER_ID=$CLUSTER_ID >> $env_variables

TENANT_ID=$(hpecp tenant create --name "k8s-tenant-1" --description "MLOPS Example" --k8s-cluster-id $CLUSTER_ID  --tenant-type k8s --specified-namespace-name k8s-tenant-1 --features '{ ml_project: true }' --quota-cores 1000)
hpecp tenant wait-for-status --id $TENANT_ID --status [ready] --timeout-secs 1800
echo "K8S tenant created successfully - ID: ${TENANT_ID}"
echo TENANT_ID=$TENANT_ID
echo TENANT_ID=$TENANT_ID >> $env_variables

TENANT_NS=$(hpecp tenant get $TENANT_ID | grep "^namespace: " | cut -d " " -f 2)
echo TENANT_NS=$TENANT_NS
echo TENANT_NS=$TENANT_NS >> $env_variables

ADMIN_GROUP="CN=${AD_ADMIN_GROUP},CN=Users,DC=samdom,DC=example,DC=com"
ADMIN_ROLE=$(hpecp role list  --query "[?label.name == 'Admin'][_links.self.href] | [0][0]" --output json | tr -d '"')
hpecp tenant add-external-user-group --tenant-id "$TENANT_ID" --group "$ADMIN_GROUP" --role-id "$ADMIN_ROLE"

MEMBER_GROUP="CN=${AD_MEMBER_GROUP},CN=Users,DC=samdom,DC=example,DC=com"
MEMBER_ROLE=$(hpecp role list  --query "[?label.name == 'Member'][_links.self.href] | [0][0]" --output json | tr -d '"')
hpecp tenant add-external-user-group --tenant-id "$TENANT_ID" --group "$MEMBER_GROUP" --role-id "$MEMBER_ROLE"
echo "Configured tenant with AD groups Admins=${AD_ADMIN_GROUP}... and Members=${AD_MEMBER_GROUP}..."

echo "Setting up MLFLOW cluster"
retry ./scripts/08b-launch-mlflow-cluster.sh $TENANT_ID

echo "Waiting for mlflow KD app to have state==configured"
#retry ./scripts/08c-check-mlflow-configured-state.sh $TENANT_ID mlflow

echo "Setting up Notebook"
#retry ./scripts/08g-launch-jupyter-notebook-env.sh $TENANT_ID

echo "Retrieving minio gateway host and port"
#MINIO_HOST_AND_PORT="$(./scripts/08h-minio-get-gw-host-and-port.sh $TENANT_ID mlflow)"
#echo MINIO_HOST_AND_PORT=$MINIO_HOST_AND_PORT

echo "Creating minio bucket"
#retry ./scripts/08i-minio-create-bucket.sh "$MINIO_HOST_AND_PORT"

echo "Verifying KubeFlow"
#./scripts/08j-verify-kf.sh $TENANT_ID

echo "Setting up Spark Environment"
echo "Hive Metastore"
#retry ./scripts/07a-setup-spark-hivemetastore.sh $TENANT_ID 

echo "Spark History Server"
#retry ./scripts/07b-setup-spark-historyserver.sh $TENANT_ID 

echo "Spark Livy Server"
#retry ./scripts/07c-setup-spark-livyserver.sh $TENANT_ID 

echo "Setting up Gitea server"
#retry ./scripts/08k-gitea-setup.sh $TENANT_ID apply

echo "May have to re-run Gitea server setup if URI error is encountered."
#retry ./scripts/08k-gitea-setup.sh $TENANT_ID apply

echo "Verifying KubeFlow"
#./scripts/08j-verify-kf.sh $TENANT_ID