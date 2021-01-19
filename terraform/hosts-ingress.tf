data "openstack_images_image_v2" "ingress-image" {
  name        = "illume-ingress"
  most_recent = true
}

resource "openstack_compute_instance_v2" "illume-ingress-v2" {

  name  = "illume-ingress-v2"
  flavor_name = "c10-128GB-1440"
  key_pair    = "illume-new"
  security_groups = [ "illume-internal-v2", "illume" ]
  depends_on = [ openstack_compute_instance_v2.illume-proxy-v2 ]

  # boot device (ephemeral)
  block_device {
    uuid                  = data.openstack_images_image_v2.ingress-image.id
    source_type           = "image"
    volume_size           = "30"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = false
  }

  # Check out this article for creating a shared dir for podman images:
  # https://www.redhat.com/sysadmin/image-stores-podman

  # assign all ephemeral storage for this flavor (1440GB),
  # then split it up into partitions.

  block_device {
    boot_index            = -1
    delete_on_termination = true
    destination_type      = "local"
    source_type           = "blank"
    volume_size           = 1440
  }

  # split ephemeral storage into 2 parts:
  # 1368GB - ephemeral0.1 (95%)
  #  72GB - ephemeral0.2 (5%)
  # mount ephemeral storage #0.1 to /scratch
  # mount ephemeral storage #0.2 to /var/lib/cvmfs
  user_data = <<EOF
#cloud-config
disk_setup:
  ephemeral0:
    table_type: 'gpt'
    layout:
      - 95
      - 5
    overwrite: true

fs_setup:
  - label: ephemeral0.1
    filesystem: 'ext4'
    device: 'ephemeral0.1'
  - label: ephemeral0.2
    filesystem: 'ext4'
    device: 'ephemeral0.2'

mounts:
  - [ ephemeral0.1, /scratch ]
  - [ ephemeral0.2, /var/lib/cvmfs ]
EOF


  network {
    name = var.network
  }

  provisioner "remote-exec" {
    # Update the config with proxy info, pulling the IPs from the instances
    # Then update the LDAP with the openLDAP server IP
    
    inline = [
      "sudo sed -i 's/example1/${openstack_compute_instance_v2.illume-proxy-v2[0].network[0].fixed_ip_v4}/' /home/ubuntu/default.local",
      "sudo sed -i 's/example2/${openstack_compute_instance_v2.illume-proxy-v2[1].network[0].fixed_ip_v4}/' /home/ubuntu/default.local",
      "sudo mv /home/ubuntu/default.local /etc/cvmfs/default.local",
      "sudo systemctl restart autofs",
      "sudo cvmfs_config probe",
      "sudo sed -i 's/ldap_ip/${openstack_compute_instance_v2.illume-openLDAP-v2.network[0].fixed_ip_v4}/' /etc/ldap.conf",
      "echo ${var.ldap_admin_pass} | sudo tee /etc/ldap.secret > /dev/null",
      "sudo reboot"
    ]

    connection {
      type = "ssh"

      # Connect via the bastion to get into the internal network
      bastion_user = var.ssh_user_name
      bastion_private_key = file(var.ssh_key_file)
      bastion_host = openstack_networking_floatingip_v2.illume-bastion-v2.address

      # Connection details of this ingress instance
      user = var.ssh_user_name
      private_key = file(var.ssh_key_file)
      host = self.network[0].fixed_ip_v4
    }
  }
}

# attach a floating IP to this one
resource "openstack_networking_floatingip_v2" "illume-ingress-v2" {
  pool = var.floating-ip-pool
}

resource "openstack_compute_floatingip_associate_v2" "illume-ingress-v2" {
  floating_ip = openstack_networking_floatingip_v2.illume-ingress-v2.address
  instance_id = openstack_compute_instance_v2.illume-ingress-v2.id
}

