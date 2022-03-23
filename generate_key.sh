#!/bin/bash

set -e # abort on error
set -u # abort on undefined variable

rm -rf generated

if [[ ! -f  "./generated/controller.prv_key" ]]; then
   [[ -d "./generated" ]] || mkdir generated
   ssh-keygen -m pem -t rsa -b 4096 -N "" -f "./generated/controller.prv_key"
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





