##################################
# Creating external df volumes
#################################

resource "openstack_blockstorage_volume_v3" "demo-externaldf-sda" {
  count       = var.count-externaldf-hosts
  name        = "${var.prefix}-demo-externaldf-host-${count.index + 1}-sda"
  size        = 51
  image_id    = var.externaldf-image-id
  metadata = {
    User = var.openstack_username
  }
}

resource "openstack_blockstorage_volume_v3" "demo-externaldf-sdb" {
  count       = var.count-externaldf-hosts
  name        = "${var.prefix}-demo-externaldf-host-${count.index + 1}-sdb"
  size        = 151
  metadata = {
    User = var.openstack_username
  }
}

##################################
# Creating external df hosts
##################################
resource "openstack_compute_instance_v2" "demo-externaldf" {
  count           = var.count-externaldf-hosts
  name            = "${var.prefix}-demo-externaldf-host-${count.index + 1}"
  flavor_name     = var.demo-externaldf-flavor
  key_pair        = openstack_compute_keypair_v2.demo-keypair.name
  security_groups = [openstack_networking_secgroup_v2.demo-secgroup.name]
  #user_data       = data.template_file.cloud-config-master.rendered
  metadata = {
    User = var.openstack_username
  }

  # Booting from volumes, as some cloud-providers do not allow booting from image
  block_device {

    uuid                  = "${openstack_blockstorage_volume_v3.demo-externaldf-sda.*.id[count.index]}"
    source_type           = "volume"
    volume_size           = 51
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  } 

   # Add more disks
  block_device {

    uuid                  = "${openstack_blockstorage_volume_v3.demo-externaldf-sdb.*.id[count.index]}"
    source_type           = "volume"
    boot_index            = 1
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
