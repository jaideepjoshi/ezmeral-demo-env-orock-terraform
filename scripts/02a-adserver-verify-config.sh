#!/usr/bin/env bash

# Ensure the AD server is correctly configured

source "./scripts/functions.sh"
source "./scripts/00b-load-env-variables.sh"

tput setaf 2
echo "Verifying AD Server Configuration"
tput sgr0

if [[ "$AD_SERVER_ENABLED" == False ]]; then
   echo "Skipping script '$0' because AD Server is not enabled"
   exit 1
fi

set +e
#ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -tt -T centos@${CTRL_PUB_IP} <<-SSH_EOF

	set -x
	
	# Apply the posix classes ldif.  This should have been applied by terraform when the EC2 instance was created.
	# If it was applied, it will return 20 here.  If not, it will be run for the first time and return 0 if successful.	

	ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -tt -T centos@${AD_PUB_IP} \
		"ldapmodify -H ldap://localhost:389 -D 'cn=Administrator,CN=Users,DC=samdom,DC=example,DC=com' -f /home/centos/ad_set_posix_classes.ldif -w '5ambaPwd@' -c 2>&1 > /dev/null"
#SSH_EOF

ret_val=$?

# response code is 20 if the ldif has already been applied

if [[ "$ret_val" == "0" || "$ret_val" == "20" ]]; then
	tput setaf 2
	echo "AD Server appears to be correctly configured."
	tput sgr0
else
	tput setaf 2
	echo "Aborting. AD Server is not correctly configured."
	tput sgr0
	exit 1
fi

