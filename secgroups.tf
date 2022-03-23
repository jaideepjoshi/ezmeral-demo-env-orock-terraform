# Creating Openstack security groups
resource "openstack_networking_secgroup_v2" "demo-secgroup" {
  name        = "${var.prefix}-demo-secgroup"
  description = "${var.prefix} demo security group"
}

# Creating Openstack security group rule for https 443
resource "openstack_networking_secgroup_rule_v2" "https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  security_group_id = openstack_networking_secgroup_v2.demo-secgroup.id
  depends_on        = [openstack_networking_secgroup_v2.demo-secgroup]
}

# Creating Openstack security group rule for ssh 22
resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  security_group_id = openstack_networking_secgroup_v2.demo-secgroup.id
  depends_on        = [openstack_networking_secgroup_v2.demo-secgroup]
}

# Creating Openstack security group rule for http 80
resource "openstack_networking_secgroup_rule_v2" "http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  security_group_id = openstack_networking_secgroup_v2.demo-secgroup.id
  depends_on        = [openstack_networking_secgroup_v2.demo-secgroup]
}

# Creating Openstack security group rule for http 943
resource "openstack_networking_secgroup_rule_v2" "tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 943
  port_range_max    = 943
  security_group_id = openstack_networking_secgroup_v2.demo-secgroup.id
  depends_on        = [openstack_networking_secgroup_v2.demo-secgroup]
}

resource "openstack_networking_secgroup_rule_v2" "icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  security_group_id = openstack_networking_secgroup_v2.demo-secgroup.id
  depends_on        = [openstack_networking_secgroup_v2.demo-secgroup]
}

# Creating Openstack security group rule for tcp 8088
#resource "openstack_networking_secgroup_rule_v2" "tcp" {
#  direction         = "ingress"
#  ethertype         = "IPv4"
#  protocol          = "tcp"
#  port_range_min    = 8088
#  port_range_max    = 8088
#  security_group_id = openstack_networking_secgroup_v2.demo-secgroup.id
#  depends_on        = [openstack_networking_secgroup_v2.demo-secgroup]
#}

# Creating Openstack security group rule for udp 1194
resource "openstack_networking_secgroup_rule_v2" "udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1194
  port_range_max    = 1194
  security_group_id = openstack_networking_secgroup_v2.demo-secgroup.id
  depends_on        = [openstack_networking_secgroup_v2.demo-secgroup]
}

# Creating Openstack security group rule for all ports in same security group tcp
resource "openstack_networking_secgroup_rule_v2" "same_secgroup_ingress_tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_group_id   = openstack_networking_secgroup_v2.demo-secgroup.id
  security_group_id = openstack_networking_secgroup_v2.demo-secgroup.id
  depends_on        = [openstack_networking_secgroup_v2.demo-secgroup]
}

# Creating Openstack security group rule for all ports in same security group udp
resource "openstack_networking_secgroup_rule_v2" "same_secgroup_ingress_udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  remote_group_id   = openstack_networking_secgroup_v2.demo-secgroup.id
  security_group_id = openstack_networking_secgroup_v2.demo-secgroup.id
  depends_on        = [openstack_networking_secgroup_v2.demo-secgroup]
}
