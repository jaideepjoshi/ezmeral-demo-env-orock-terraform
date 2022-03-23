##################################
# Creating ecp adserver volumes
#################################

resource "openstack_blockstorage_volume_v3" "demo-adserver-sda" {
  name        = "${var.prefix}-demo-adserver-sda"
  size        = 51
  image_id    = var.hpe_node_image_id
  metadata = {
    User = var.openstack_username
  }
}

##################################
# Creating ecp adserver instance
#################################
resource "openstack_compute_instance_v2" "demo-adserver" {
  count           = "1"
  name            = "${var.prefix}-demo-adserver"
  flavor_name     = var.demo-adserver-flavor
  key_pair        = openstack_compute_keypair_v2.demo-keypair.name
  security_groups = [openstack_networking_secgroup_v2.demo-secgroup.name]
  #user_data       = data.template_file.cloud-config-adserver.rendered
  metadata = {
    User = var.openstack_username
  }

  # Booting from volumes, as someyy cloud-providers do not allow booting from image
  block_device {

    uuid                  = "${openstack_blockstorage_volume_v3.demo-adserver-sda.id}"
    source_type           = "volume"
    boot_index            = 0
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
