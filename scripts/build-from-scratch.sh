#!/bin/bash

set -e # abort on error
set -u # abort on undefined variable

#these old entries can cause issues later
[ -e ~/.ssh/known_hosts ] && rm ~/.ssh/known_hosts

source "./scripts/functions.sh"

tput setaf 3
echo "Begin Install"
tput sgr0

sleep 10

# Install basic infrastructure
./scripts/01-create-infra.sh

#####Choose a Block to Install###########################

###########################  Begin Block 1 #######################################################
# Install ADserver
#./scripts/02-adserver-install.sh
# Install DNSserver
#./scripts/03-dnsserver-install.sh
#OR
# Install ADserver and DNSserver in Parallel
parallel -u ::: './scripts/02-adserver-install.sh 1' './scripts/03-dnsserver-install.sh 2'

# Install Runtime Controller & Gateway 
#./scripts/04-controller-install.sh
# Setup ExternalDF
#./scripts/09b-externaldf-ansible-install.sh 1
#OR
# Install Runtime Controller & Gateway and ExternalDF in Parallel
parallel -u ::: './scripts/04-controller-install.sh 1' './scripts/09-externaldf-install.sh 1 2'

# Register ExternalDF as Tenant Storage
#./scripts/06e-register-xdf-tenant-storage


################ End of Block1 ##########################################################################


################ Begin Block2 ##########################################################################

# Add hosts, Create K8s (Spark+Isti+KF) cluster - WITH PicassoDF 
./scripts/05-k8sdfcompute-cluster-create.sh
echo "Waiting for Services to start before Registering Tenant Storage"
sleep 1800

# Add hosts, Create K8s (Spark+Isti+KF) cluster - WITH PicassoDF And Install XDF
#parallel -u ::: './scripts/05-k8sdfmlops-cluster-create.sh 1' './scripts/09-externaldf-install.sh 1 2'

# Register PicassoDF as Tenant Storage
./scripts/05f-register-k8sdf-tenant-storage.sh /api/v2/k8scluster/1


################ End of Block2 ##########################################################################


# Add hosts, Create MLOps K8s cluster - NO PicassoDF
#./scripts/06-k8smlops-cluster-create.sh

# Setup MLOps Environment and Spark
#./scripts/08-*

# Setup Spark Environment only
#./scripts/07-*

# Other (or experimental) scripts

tput setaf 3
echo "Wow! Got this far??!!"
tput sgr0
