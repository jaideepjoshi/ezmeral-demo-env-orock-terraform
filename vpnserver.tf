# Allocating public Ip addresses for ecp controller
resource "openstack_networking_floatingip_v2" "demo-vpnserver-ip" {
  pool = var.ip_pool_name
}

# Attaching Floating IP to vpn server
resource "openstack_compute_floatingip_associate_v2" "demo-vpnserver-ip-attach" {
  floating_ip = openstack_networking_floatingip_v2.demo-vpnserver-ip.address
  instance_id = openstack_compute_instance_v2.demo-vpnserver[0].id
  depends_on  = [openstack_compute_instance_v2.demo-vpnserver]
}

resource "openstack_blockstorage_volume_v3" "demo-vpnserver-sda" {
  name        = "${var.prefix}-demo-vpnserver-sda"
  size        = 51
  image_id    = var.demo-vpn-image-id
  metadata = {
    User = var.openstack_username
  }
}


##################################
# Creating vpn instance
#################################
resource "openstack_compute_instance_v2" "demo-vpnserver" {
  count           = "1"
  name            = "${var.prefix}-demo-vpnserver"
  flavor_name     = var.demo-vpn-flavor
  key_pair        = openstack_compute_keypair_v2.demo-keypair.name
  security_groups = [openstack_networking_secgroup_v2.demo-secgroup.name]
  #user_data       = data.template_file.cloud-config-vpnserver.rendered
  metadata = {
    User = var.openstack_username
  }
 
  # Booting from volumes, as someyy cloud-providers do not allow booting from image
  block_device {

    uuid                  = "${openstack_blockstorage_volume_v3.demo-vpnserver-sda.id}"
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    name = openstack_networking_network_v2.demo-network.name
  }
}

resource "null_resource" "provision_vpnserver" {
  depends_on = [openstack_compute_floatingip_associate_v2.demo-vpnserver-ip-attach]
    connection {
      type          = "ssh"
      user          = "ubuntu"
      host          = openstack_networking_floatingip_v2.demo-vpnserver-ip.address
      private_key   = file("./generated/controller.prv_key")
      #private_key   = var.private_key
      #private_key   = file("./generated/controller.prv_key") 
      agent         = false
    }
  provisioner "remote-exec" {
    inline = [
      <<EOT
      sudo cd /root
      sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
      sudo curl -O https://raw.githubusercontent.com/ajgoade/openvpn-install/master/openvpn-install.sh
      sudo chmod +x openvpn-install.sh
      sudo DEBIAN_FRONTEND=noninteractive AUTO_INSTALL=y ./openvpn-install.sh
      sudo cp /home/ubuntu/client.ovpn /tmp/client.ovpn
      EOT
    ]
 }
}
