#!/bin/bash
source "./scripts/functions.sh"
source "./scripts/00b-load-env-variables.sh"

y=$(cat ./generated/novalist |grep $PROJECT_ID|grep k8sdfworker-1 | awk '{ split($12, v, "="); print v[2]}')

ssh -o StrictHostKeyChecking=no -i ./generated/controller.prv_key centos@$y
