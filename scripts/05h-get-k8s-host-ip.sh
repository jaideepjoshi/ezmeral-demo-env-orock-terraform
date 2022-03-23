#!/usr/bin/env bash

exec > >(tee -i generated/$(basename $0).log)
exec 2>&1

set -e
set -o pipefail

if [[ -z $1 ]]; then
  echo Usage: $0 WORKER_ID
  echo Where: WORKER_ID = /api/v2/worker/k8shost/[0-9]*
  exit 1
fi

WORKER_ID=$1

set -u

./scripts/check_prerequisites.sh
source "./scripts/functions.sh"
source "./scripts/00b-load-env-variables.sh"

hpecp k8sworker list -query "[?_links.self.href == '${WORKER_ID}'] | [0] | [ipaddr]" -o text