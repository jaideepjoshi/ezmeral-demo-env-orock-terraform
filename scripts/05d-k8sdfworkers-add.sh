#!/bin/bash

exec > >(tee -i generated/$(basename $0).log)
exec 2>&1
date


HOST_IPS=( "$@" )

set -e # abort on error
set -u # abort on undefined variable
set -o pipefail

if [[ ! -d generated ]]; then
   echo "This file should be executed from the project directory"
   exit 1
fi

./scripts/check_prerequisites.sh
source "./scripts/functions.sh"
source "./scripts/00b-load-env-variables.sh"

#pip3 install --quiet --upgrade --user hpecp

# use the project's HPECP CLI config file
export HPECP_CONFIG_FILE="./generated/hpecp.conf"

# Test CLI is able to connect
echo "Platform ID: $(hpecp license platform-id)"

echo "Fetching 'DF' tag ID"
DF_TAG_ID=$(hpecp httpclient get /api/v2/tag | python3 -c 'import json,sys;obj=json.load(sys.stdin);[ print(t["_links"]["self"]["href"]) for t in obj["_embedded"]["tags"] if t["label"]["name"] == "Datafabric"]')
echo DF_TAG_ID=$DF_TAG_ID

echo "Adding k8sdfworkers"
WRKR_IDS=()
for WRKR in ${HOST_IPS[@]}; do
    echo "   worker $WRKR"
    CMD="hpecp k8sworker create-with-ssh-key --ip ${WRKR} --ssh-key-file ./generated/controller.prv_key --tags ${DF_TAG_ID}:true"
    echo $CMD
    WRKR_ID="$($CMD)"
    echo "       id $WRKR_ID"
    WRKR_IDS+=($WRKR_ID)
done

echo "Configuring ${#WRKR_IDS[@]} k8sdfworkers in parallel"

for WRKR in ${WRKR_IDS[@]}; do
{
    echo "Waiting for ${WRKR} to have state 'storage_pending'"
    hpecp k8sworker wait-for-status ${WRKR} --status  "['storage_pending']" --timeout-secs 1800
    echo "Setting ${WRKR} storage"
    PERSISTENT_DISK=$(hpecp k8sworker get ${WRKR} --output json | python3 -c 'import json,sys;obj=json.load(sys.stdin);print([ storage["info"]["ConsistentName"] for storage in obj["sysinfo"]["storage"] if storage["name"] == "/dev/sdc" ][0])')
    echo PERSISTENT_DISK=${PERSISTENT_DISK}
    hpecp k8sworker set-storage --id ${WRKR} --persistent-disks=${PERSISTENT_DISK} --ephemeral-disks=/dev/sdb
    echo "Waiting for k8sdfworker ${WRKR} to have state 'ready'"
    hpecp k8sworker wait-for-status ${WRKR} --status  "['ready']" --timeout-secs 1800
} &
done

wait # don't quit until all workers are configured

echo "${WRKR_IDS[@]}"
