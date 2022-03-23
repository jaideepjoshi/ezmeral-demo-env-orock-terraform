#!/usr/bin/env bash

exec > >(tee -i generated/$(basename $0).log)
exec 2>&1


set -e
set -o pipefail

if [[ -z $1 ]]; then
  echo Usage: $0 CLUSTER_ID
  echo Where: CLUSTER_ID = /api/v2/k8scluster/[0-9]*
  exit 1
fi

CLUSTER_ID=$1

set -u

./scripts/check_prerequisites.sh
source "./scripts/functions.sh"
source "./scripts/00b-load-env-variables.sh"

hpecp k8scluster list --query "[?_links.self.href == '${CLUSTER_ID}'] | [0] | [k8shosts_config] | [0] | [?role == 'master'] | [*][node]" -o text