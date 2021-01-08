# Fetch the image so that we can get the ID, since the ID changes
# whenever it is rebuilt in Packer
data "openstack_images_image_v2" "phpLDAPadmin-image" {
  name        = "illume-phpLDAPadmin"
  most_recent = true
}

resource "openstack_compute_instance_v2" "illume-phpLDAPadmin-v2" {
  depends_on = [ openstack_compute_instance_v2.illume-openLDAP-v2,
                 openstack_compute_instance_v2.illume-bastion-v2
  ]
  name = "illume-phpLDAPadmin-v2"
  flavor_id       = "11"
  key_pair        = "illume-new"
  security_groups = [
    "ssh",
    "illume-internal-v2",
  ]

  # boot from volume (created from image)
  block_device {
    uuid                  = data.openstack_images_image_v2.phpLDAPadmin-image.id
    source_type           = "image"
    volume_size           = "30"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    name = var.network
  }

  provisioner "remote-exec" {
    # Update the config with openLDAP info, pulling the IP from the instance
    inline = [
      "sudo sed -i 's/127.0.0.1/${openstack_compute_instance_v2.illume-openLDAP-v2.network[0].fixed_ip_v4}/' /etc/phpldapadmin/config.php",
      "sudo sed -i 's/dc=example,dc=com/dc=illume,dc=systems/' /etc/phpldapadmin/config.php",
      "sudo systemctl restart apache2"
    ]

    connection {
      type = "ssh"

      # Connect via the bastion to get into the internal network
      bastion_user = var.ssh_user_name
      bastion_private_key = file(var.ssh_key_file)
      bastion_host = openstack_networking_floatingip_v2.illume-bastion-v2.address

      # Connection details of this phpLDAPadmin instance
      user = var.ssh_user_name
      private_key = file(var.ssh_key_file)
      host = self.network[0].fixed_ip_v4
    }
  }
}

