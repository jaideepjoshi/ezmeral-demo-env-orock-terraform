#!/bin/bash

set -e # abort on error
set -u # abort on undefined variable

./scripts/check_prerequisites.sh
exec > >(tee -i generated/$(basename $0).log)
exec 2>&1

tput setaf 2
echo "Disconnecting VPN connection to VPN Server"
echo "Please provide your Mac Password if Prompted"
tput sgr0
nohup ./scripts/10a-stop-vpn-connection.sh &
sleep 15

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


#terraform destroy -var-file=<(cat etc/*.tfvars) -var="client_cidr_block=$(curl -s http://ipinfo.io/ip)/32" -auto-approve=true && \
terraform destroy -var-file=<(cat etc/*.tfvars) -auto-approve=true && \
rm -rf ./generated
