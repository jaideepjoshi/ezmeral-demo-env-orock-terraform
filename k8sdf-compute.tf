##################################
# Creating k8sdfcomputemaster volumes
#################################

resource "openstack_blockstorage_volume_v3" "demo-k8sdfcomputemaster-sda" {
  count       = var.count-k8sdfcomputemasters
  name        = "${var.prefix}-demo-k8sdfcomputemaster-${count.index + 1}-sda"
  size        = 551
  image_id    = var.hpe_node_image_id
  metadata = {
    User = var.openstack_username
  }
}

resource "openstack_blockstorage_volume_v3" "demo-k8sdfcomputemaster-sdb" {
  count       = var.count-k8sdfcomputemasters
  name        = "${var.prefix}-demo-k8sdfcomputemaster-${count.index + 1}-sdb"
  size        = 551
  metadata = {
    User = var.openstack_username
  }
}

#resource "openstack_blockstorage_volume_v3" "demo-k8sdfcomputemaster-sdc" {
#  count       = var.count-k8sdfcomputemasters
#  name        = "${var.prefix}-demo-k8sdfcomputemaster-${count.index + 1}-sdc"
#  size        = 551
#  metadata = {
#    User = var.openstack_username
#  }
#}

##################################
# Creating k8sdfcomputemaster nodes
##################################
resource "openstack_compute_instance_v2" "demo-k8sdfcomputemaster" {
  count           = var.count-k8sdfcomputemasters
  name            = "${var.prefix}-demo-k8sdfcomputemaster-${count.index + 1}"
  flavor_name     = var.demo-k8sdfcomputemaster-flavor
  key_pair        = openstack_compute_keypair_v2.demo-keypair.name
  security_groups = [openstack_networking_secgroup_v2.demo-secgroup.name]
  user_data       = data.template_file.cloud-config-master.rendered
  metadata = {
    User = var.openstack_username
  }

  # Booting from volumes, as some cloud-providers do not allow booting from image
  block_device {

    uuid                  = "${openstack_blockstorage_volume_v3.demo-k8sdfcomputemaster-sda.*.id[count.index]}"
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  } 

   # Add more disks
  block_device {

    uuid                  = "${openstack_blockstorage_volume_v3.demo-k8sdfcomputemaster-sdb.*.id[count.index]}"
    source_type           = "volume"
    boot_index            = 1
    destination_type      = "volume"
    delete_on_termination = true
  }

  #block_device {

  #  uuid                  = "${openstack_blockstorage_volume_v3.demo-k8sdfcomputemaster-sdc.*.id[count.index]}"
  #  source_type           = "volume"
  #  boot_index            = 2
  #  destination_type      = "volume"
  #  delete_on_termination = true
  #}

  network {
    name = openstack_networking_network_v2.demo-network.name
  }

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }

  depends_on = [openstack_compute_keypair_v2.demo-keypair, openstack_networking_subnet_v2.demo-subnet]
}

##################################
# Creating k8sdfworker volumes
#################################

resource "openstack_blockstorage_volume_v3" "demo-k8sdfworker-sda" {
  count       = var.count-k8sdfworkers
  name        = "${var.prefix}-demo-k8sdfworker-${count.index + 1}-sda"
  size        = 551
  image_id    = var.hpe_node_image_id
  metadata = {
    User = var.openstack_username
  }
}

resource "openstack_blockstorage_volume_v3" "demo-k8sdfworker-sdb" {
  count       = var.count-k8sdfworkers
  name        = "${var.prefix}-demo-k8sdfworker-${count.index + 1}-sdb"
  size        = 551
  metadata = {
    User = var.openstack_username
  }
}

resource "openstack_blockstorage_volume_v3" "demo-k8sdfworker-sdc" {
  count       = var.count-k8sdfworkers
  name        = "${var.prefix}-demo-k8sdfworker-${count.index + 1}-sdc"
  size        = 551
  metadata = {
    User = var.openstack_username
  }
}

##################################
# Creating k8sdfworker nodes
##################################
resource "openstack_compute_instance_v2" "demo-k8sdfworker" {
  count           = var.count-k8sdfworkers
  name            = "${var.prefix}-demo-k8sdfworker-${count.index + 1}"
  flavor_name     = var.demo-k8sdfworker-flavor
  key_pair        = openstack_compute_keypair_v2.demo-keypair.name
  security_groups = [openstack_networking_secgroup_v2.demo-secgroup.name]
  user_data       = data.template_file.cloud-config-master.rendered
  metadata = {
    User = var.openstack_username
  }

  # Booting from volumes, as some cloud-providers do not allow booting from image
  block_device {

    #uuid                  = var.hpe_node_image_id
    uuid                  = "${openstack_blockstorage_volume_v3.demo-k8sdfworker-sda.*.id[count.index]}"
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

   # Add more disks
  block_device {

    uuid                  = "${openstack_blockstorage_volume_v3.demo-k8sdfworker-sdb.*.id[count.index]}"
    source_type           = "volume"
    boot_index            = 1
    destination_type      = "volume"
    delete_on_termination = true
  }

  block_device {

    uuid                  = "${openstack_blockstorage_volume_v3.demo-k8sdfworker-sdc.*.id[count.index]}"
    source_type           = "volume"
    boot_index            = 2
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    name = openstack_networking_network_v2.demo-network.name
  }

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }

  depends_on = [openstack_compute_keypair_v2.demo-keypair, openstack_networking_subnet_v2.demo-subnet]
}

##################################
# Creating k8scomputeworker volumes
#################################

resource "openstack_blockstorage_volume_v3" "demo-k8scomputeworker-sda" {
  count       = var.count-k8scomputeworkers
  name        = "${var.prefix}-demo-k8scomputeworker-${count.index + 1}-sda"
  size        = 151
  image_id    = var.hpe_node_image_id
  metadata = {
    User = var.openstack_username
  }
}

resource "openstack_blockstorage_volume_v3" "demo-k8scomputeworker-sdb" {
  count       = var.count-k8scomputeworkers
  name        = "${var.prefix}-demo-k8scomputeworker-${count.index + 1}-sdb"
  size        = 151
  metadata = {
    User = var.openstack_username
  }
}

#resource "openstack_blockstorage_volume_v3" "demo-k8scomputeworker-sdc" {
#  count       = var.count-k8scomputeworkers
#  name        = "${var.prefix}-demo-k8scomputeworker-${count.index + 1}-sdc"
#  size        = 91
#  metadata = {
#    User = var.openstack_username
#  }
#}

##################################
# Creating k8scomputeworker nodes
##################################
resource "openstack_compute_instance_v2" "demo-k8scomputeworker" {
  count           = var.count-k8scomputeworkers
  name            = "${var.prefix}-demo-k8scomputeworker-${count.index + 1}"
  flavor_name     = var.demo-k8scomputeworker-flavor
  key_pair        = openstack_compute_keypair_v2.demo-keypair.name
  security_groups = [openstack_networking_secgroup_v2.demo-secgroup.name]
  user_data       = data.template_file.cloud-config-master.rendered
  metadata = {
    User = var.openstack_username
  }

  # Booting from volumes, as some cloud-providers do not allow booting from image
  block_device {

    #uuid                  = var.hpe_node_image_id
    uuid                  = "${openstack_blockstorage_volume_v3.demo-k8scomputeworker-sda.*.id[count.index]}"
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

   # Add more disks
  block_device {

    uuid                  = "${openstack_blockstorage_volume_v3.demo-k8scomputeworker-sdb.*.id[count.index]}"
    source_type           = "volume"
    boot_index            = 1
    destination_type      = "volume"
    delete_on_termination = true
  }

  #block_device {

  #  uuid                  = "${openstack_blockstorage_volume_v3.demo-k8scomputeworker-sdc.*.id[count.index]}"
  #  boot_index            = 2
  #  destination_type      = "volume"
  #  delete_on_termination = true
  #}

  network {
    name = openstack_networking_network_v2.demo-network.name
  }

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }

  depends_on = [openstack_compute_keypair_v2.demo-keypair, openstack_networking_subnet_v2.demo-subnet]
}
