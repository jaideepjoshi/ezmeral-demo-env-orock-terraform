# ezmeral-demo-env-orock-terraform
https://github.com/jaideepjoshi/ezmeral-demo-env-orock-terraform

# Prerequisites:
Terraform and other tools will be needed to run these scripts.

# Notes and Warnings
1. You must not be connected to the corporate VPN or this script may fail.  
2. You will be asked to enter your laptop credentials after the VPN is deployed.  This connects you to your 'VPC'.   
3. Please do not leave your environment running for an extended period.  Just like AWS this costs $$$$.

# How these scripts work:

## First:
Sign in to ORock and generate your API Credentials.  Make sure you are in HPE-Ezmeral East – us-east-1 before downloading the credentials.  
![ORock Environment](https://github.com/jaideepjoshi/ezmeral-demo-env-orock-terraform/blob/master/images/Instance_Overview_-_OpenStack_Dashboard.png)

Go to API Access and download OpenStack RC File  
![ORock Creds](https://github.com/jaideepjoshi/ezmeral-demo-env-orock-terraform/blob/master/images/API_Access_-_OpenStack_Dashboard_and_Inbox_%E2%80%A2_andrew_goade_hpe_com.png)

Once you’ve download the credentials, put them in the root directory of this cloned project.

## Second:
Edit the scripts for your environment:

Copy `$root_dir/etc/terraform.tfvars.template` to `$root_dir/etc/terraform.tfvars`  
Edit the openstack_username, openstack_password, prefix and subnet_cidr with your variables.  
![Customize Env](https://github.com/jaideepjoshi/ezmeral-demo-env-orock-terraform/blob/master/images/ezmeral-demo-env-orock-terraform_terraform_tvars_template_at_master_%C2%B7_jaideepjoshi_ezmeral-demo-env-orock-terraform.png)


### OPTIONAL:
#### Install different version of runtime:
Edit `$root_dir/scripts/04b-controller-install-ecp.sh` to download location and version of your selection:   
![Runtime Version](https://github.com/jaideepjoshi/ezmeral-demo-env-orock-terraform/blob/master/images/ezmeral-demo-env-orock-terraform_04b-controller-install-ecp_sh_at_master_%C2%B7_jaideepjoshi_ezmeral-demo-env-orock-terraform.png)


### OPTIONAL:
#### Limit what is installed.  Comment out sections that you don’t want run:
Edit `$root_dir/scripts/build-from-scratch.sh`    
![Limit Install](https://github.com/jaideepjoshi/ezmeral-demo-env-orock-terraform/blob/master/images/ezmeral-demo-env-orock-terraform_build-from-scratch_sh_at_master_%C2%B7_jaideepjoshi_ezmeral-demo-env-orock-terraform.png)

## Third:
#### Initialized the environment
From the root of this project:
`source HPE-Ezmeral-East-openrc.sh`

Then:
`terraform init`

## Finally:
#### Install the environment

Run `$root_dir/scripts/build-from-scratch.sh`  

## To destroy the environment

Run `$root_dir/scripts/10-destroy-infra.sh`

