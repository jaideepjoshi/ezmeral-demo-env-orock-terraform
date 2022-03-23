#!/bin/bash
source "./scripts/functions.sh"
source "./scripts/00b-load-env-variables.sh"

ssh -o StrictHostKeyChecking=no -i "./generated/controller.prv_key" centos@$CTRL_PUB_IP "$@"