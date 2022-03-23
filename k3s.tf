
##################################
# Creating volumes for k3s hosts
#################################

resource "openstack_blockstorage_volume_v3" "demo-k3s-sda" {
  count       = var.count-k3s-hosts
  name        = "${var.prefix}-demo-k3s-host-${count.index + 1}-sda"
  size        = 51
  image_id    = var.k3s-node-image-id
  metadata = {
    User = var.openstack_username
  }
}

##################################
# Creating k3s hosts
##################################
resource "openstack_compute_instance_v2" "demo-k3s" {
  count           = var.count-k3s-hosts
  name            = "${var.prefix}-demo-k3s-host-${count.index + 1}"
  flavor_name     = var.demo-k3s-flavor
  key_pair        = openstack_compute_keypair_v2.demo-keypair.name
  security_groups = [openstack_networking_secgroup_v2.demo-secgroup.name]
  #user_data       = data.template_file.cloud-config-master.rendered
  metadata = {
    User = var.openstack_username
  }

  # Booting from volumes, as some cloud-providers do not allow booting from image
  block_device {

    uuid                  = "${openstack_blockstorage_volume_v3.demo-k3s-sda.*.id[count.index]}"
    source_type           = "volume"
    volume_size           = 51
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
