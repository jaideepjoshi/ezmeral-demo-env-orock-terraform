variable "prefix" {
  type        = string
  description = "A prefix for created resources to avoid clashing names"
}

variable "count-demo-controllers" {
  type        = string
  description = "Number of ecp controllers"
  default     = "1"
}

variable "count-demo-gateways" {
  type        = string
  description = "Number of ecp gateways"
  default     = "1"
}

variable "count-k8sdfcomputemasters" {
  type        = string
  description = "Number of worker nodes"
  default     = "3"
}

variable "count-k8sdfworkers" {
  type        = string
  description = "Number of worker nodes"
  default     = "5"
}

variable "count-k8scomputeworkers" {
  type        = string
  description = "Number of master nodes"
  default     = "3"
}

variable "count-k8smasters" {
  type        = string
  description = "Number of master nodes"
  default     = "0"
}

variable "count-k8sworkers" {
  type        = string
  description = "Number of master nodes"
  default     = "0"
}

variable "count-externaldf-hosts" {
  type        = string
  description = "Number of master nodes"
  default     = "3"
}

variable "count-k3s-hosts" {
  type        = string
  description = "Number of k3s nodes"
  default     = "0"
}

variable "demo-vpn-flavor" {
  type        = string
  description = "Worker nodes types, in term CPU, Memory and Bandwith"
  default     = "R1-Generic-8"
}

variable "demo-dnsserver-flavor" {
  type        = string
  description = "Worker nodes types, in term CPU, Memory and Bandwith"
  default     = "R1-Generic-8"
}

variable "demo-k8sworker-flavor" {
  type        = string
  description = "Worker nodes types, in term CPU, Memory and Bandwith"
  default     = "R1-Generic-8"
}

variable "demo-k8sdfworker-flavor" {
  type        = string
  description = "Worker nodes types, in term CPU, Memory and Bandwith"
  default     = "R1-Generic-8"
}

variable "demo-k8scomputeworker-flavor" {
  type        = string
  description = "Worker nodes types, in term CPU, Memory and Bandwith"
  default     = "R1-Generic-8"
}

variable "demo-k8smaster-flavor" {
  type        = string
  description = "Master nodes types, in term CPU, Memory and Bandwith"
  default     = "R1-Generic-8"
}

variable "demo-k8sdfcomputemaster-flavor" {
  type        = string
  description = "Master nodes types, in term CPU, Memory and Bandwith"
  default     = "R1-Generic-8"
}

variable "demo-externaldf-flavor" {
  type        = string
  description = "Master nodes types, in term CPU, Memory and Bandwith"
  default     = "R1-Generic-8"
}
variable "demo-controller-flavor" {
  type        = string
  description = "hpe2 server node types, in term CPU, Memory and Bandwith"
  default     = "R1-Generic-8"
}

variable "demo-gateway-flavor" {
  type        = string
  description = "hpe2 server node types, in term CPU, Memory and Bandwith"
  default     = "R1-Generic-8"
}

variable "demo-adserver-flavor" {
  type        = string
  description = "hpe2 server node types, in term CPU, Memory and Bandwith"
  default     = "R1-Generic-8"
}

variable "demo-rdpserver-flavor" {
  type        = string
  description = "hpe2 server node types, in term CPU, Memory and Bandwith"
  default     = "R1-Generic-8"
}

variable "demo-k3s-flavor" {
  type        = string
  description = "hpe2 server node types, in term CPU, Memory and Bandwith"
  default     = "R1-Generic-8"
}

variable "hpe_node_image_id" {
  type        = string
  description = "Centos 7 Image ID for ADserver,DNSServer, Runtime and K8s hosts"
}

variable "demo-vpn-image-id" {
  type        = string
  description = "Ubuntu Image ID for VPN Server"
}

variable "externaldf-image-id" {
  type        = string
  description = "Centos 8 Image ID for ExternalDF servers"
}

variable "k3s-node-image-id" {
  type        = string
  description = "Image ID which instances will created from."
}

variable "external_network" {
  type        = string
  description = "Openstack External network name to connect nodes to outside world"
  default     = "Public_Network"

}

variable "subnet_cidr" {
  type        = string
  description = "Openstack subnet CIDR where instances IPs will be assigned"
  default     = "192.168.200.0/24"

}

variable "ip_pool_name" {
  type        = string
  description = "Openstack Floating IP allocation pool name"
  default     = "Public_Network"
}

variable "private_key" {
  type        = string
  description = "SSH Public key content to be imported and used into created instances"
}
