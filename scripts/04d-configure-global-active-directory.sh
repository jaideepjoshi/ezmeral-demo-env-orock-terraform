#!/bin/bash

exec > >(tee -i generated/$(basename $0).log)
exec 2>&1
date

set -e # abort on error
set -u # abort on undefined variable

source "./scripts/functions.sh"
source "./scripts/00b-load-env-variables.sh"

if [[ ! -d generated ]]; then
   echo "This file should be executed from the project directory"
   exit 1
fi

./scripts/check_prerequisites.sh

if [[ "$AD_SERVER_ENABLED" == False ]]; then
   echo "Skipping script '$0' because AD Server is not enabled"
   exit
fi

# use the project's HPECP CLI config file. Do not comment out this line.
export HPECP_CONFIG_FILE="./generated/hpecp.conf"

AD_PRV_IP=$(cat ./generated/novalist |grep $PROJECT_ID|grep adserver | awk '{ split($12, v, "="); print v[2]}')
echo "AD_PRV_IP=$AD_PRV_IP"

AD_PRIV_IP=\"${AD_PRV_IP}\"

echo "Configuring AD Authentication On ECP Controller"
JSON_FILE=$(mktemp)
trap '{ rm -f $JSON_FILE; }' EXIT
cat >"$JSON_FILE"<<-EOF
{ 
    "external_identity_server":  {
        "bind_pwd":"5ambaPwd@",
        "user_attribute":"sAMAccountName",
        "bind_type":"search_bind",
        "bind_dn":"cn=Administrator,CN=Users,DC=samdom,DC=example,DC=com",
        "host": $AD_PRIV_IP,
        "security_protocol":"ldaps",
        "base_dn":"CN=Users,DC=samdom,DC=example,DC=com",
        "verify_peer": false,
        "type":"Active Directory",
        "port":636 
    }
}
EOF
hpecp httpclient post /api/v2/config/auth --json-file "${JSON_FILE}"

tput setaf 2
echo "ECP Controller now configured with AD Authentication"
tput sgr0
