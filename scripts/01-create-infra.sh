#!/bin/bash

set -e # abort on error
set -u # abort on undefined variable

#these old entries can cause issues later
if [ -f "~/.ssh/known_hosts" ] ; then
    rm "~/.ssh/known_hosts"
fi

source "scripts/functions.sh"
./scripts/check_prerequisites.sh

tput setaf 1
print_term_width '='
echo "IMPORTANT: Please ensure you are NOT connected to a corporate VPN."
print_term_width '='
tput sgr0

sleep 10

if [[ -f terraform.tfstate ]]; then

   python3 -mjson.tool "terraform.tfstate" > /dev/null || {
     echo "The file terraform.tfstate does not appear to be valid json. Aborting."
     exit 1
   } 

   TF_RESOURCES=$(cat  terraform.tfstate | python3 -c 'import json,sys;obj=json.load(sys.stdin);print(len(obj["resources"]))')

   if [[ "$TF_RESOURCES" == "0" ]]; then
      echo "Found 0 terraform resources in terraform.tfstate - presuming this is a clean envrionment"
   else
      print_term_width '='
      echo "Refusing to create environment because existing ./terraform.tfstate file found."
      echo "Please destroy your environment (./bin/terraform_destroy.sh) and then remove all terraform.tfstate files"
      echo "before trying again."
      print_term_width '='
      exit 1
   fi
fi

tput setaf 2
echo "Creating necessary keys"
tput sgr0

if [[ ! -f  "./generated/controller.prv_key" ]]; then
   [[ -d "./generated" ]] || mkdir generated
   ssh-keygen -m pem -t rsa -N "" -f "./generated/controller.prv_key"
   mv "./generated/controller.prv_key.pub" "./generated/controller.pub_key"
   chmod 600 "./generated/controller.prv_key"
fi

if [[ ! -f  "./generated/ca-key.pem" ]]; then
   openssl genrsa -out "./generated/ca-key.pem" 2048
   openssl req -x509 \
      -new -nodes \
      -key "./generated/ca-key.pem" \
      -subj "/C=US/ST=CA/O=MyOrg, Inc./CN=mydomain.com" \
      -sha256 -days 1024 \
      -out "./generated/ca-cert.pem"
   chmod 660 "./generated/ca-key.pem"
fi

exec > >(tee -i generated/$(basename $0).log)
exec 2>&1
date

export PREFIX_ID=$(cat ./etc/*tfvars|grep "prefix ="|awk '{print $3}'|cut -d - -f 1|tr -d '"')
export PROJECT_ID=$(echo $PREFIX_ID-ecp)

tput setaf 2
echo "Deploying infrastructure using Terraform for $PROJECT_ID"
tput sgr0

#terraform apply -var-file=<(cat etc/*.tfvars)  -var="client_cidr_block=$(curl -s http://ipinfo.io/ip)/32" -auto-approve=true
terraform apply -var-file=<(cat etc/*.tfvars) -auto-approve=true

tput setaf 2
echo "Terraform complete. The following instances have been created"
tput sgr0

openstack server list --sort-column Name |grep $PROJECT_ID

tput setaf 2
echo "Gathering Environment Variables"
tput sgr0
source "./scripts/00a-gen-env-variables.sh"

tput setaf 2
echo "Establishing VPN connection to OpenVPN Server"
echo "Please provide your local Mac Password if/when Prompted"
tput sgr0

nohup ./scripts/01a-start-vpn-connection.sh &
sleep 15

# test ssh connectivity
./scripts/01b-check-ssh-connections.sh

tput setaf 2
echo "Setting Passwordless SSH between Controller, Gateway , DNS Server & K8S Hosts"
tput sgr0

./scripts/01c-setup-passwordless-ssh.sh

tput setaf 2
echo "Passwordless SSH setup complete"
tput sgr0

