variable "openstack_project" {
  type        = string
  description = "Openstack project/tenant name"
}
variable "openstack_username" {
  type        = string
  description = "Openstack username which resources will be created by"
}
variable "openstack_password" {
  type        = string
  description = "Openstack password"
}
variable "openstack_auth_url" {
  type        = string
  description = "Authentication url for openstack cli"
}
variable "openstack_domain" {
  type        = string
  description = "Openstack domain name which tenant exists on"
}

# Define required providers
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}

# Openstack provider to communicate with openstack apis
provider "openstack" {
  user_name   = var.openstack_username
  password    = var.openstack_password
  domain_name = var.openstack_domain
  tenant_name = var.openstack_project
  auth_url    = var.openstack_auth_url
  region      = "us-east-1"
}

