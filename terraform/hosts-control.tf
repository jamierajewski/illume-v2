# Fetch the image so that we can get the ID, since the ID changes
# whenever it is rebuilt in Packer
data "openstack_images_image_v2" "control-image" {
  name        = "illume-control"
  most_recent = true
}

resource "openstack_compute_instance_v2" "illume-control-v2" {
  name = "illume-control-v2"
  flavor_name     = "c2-8GB-90"
  key_pair        = "illume-new"
  security_groups = ["illume-internal-v2"]
  depends_on = [ openstack_compute_instance_v2.illume-proxy-v2 ]

  # boot from volume (created from image)
  block_device {
    uuid                  = data.openstack_images_image_v2.control-image.id
    source_type           = "image"
    volume_size           = 30
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  # assign all ephemeral storage for this flavor (90GB),
  # then split it up into partitions.

  block_device {
    boot_index            = -1
    delete_on_termination = true
    destination_type      = "local"
    source_type           = "blank"
    volume_size           = 90
  }

  # split ephemeral storage into 1 part:
  #  90GB - ephemeral0.1 (100%)
  # mount ephemeral storage #0.1 to /var/lib/condor
  user_data = <<EOF
#cloud-config
disk_setup:
  ephemeral0:
    table_type: 'gpt'
    layout:
      - 100
    overwrite: true

fs_setup:
  - label: ephemeral0.1
    filesystem: 'ext4'
    device: 'ephemeral0.1'

mounts:
  - [ ephemeral0.1, /var/lib/condor ]
EOF

  network {
    name = var.network
  }

  provisioner "remote-exec" {

    inline = [
      # Set up the condor log directory on the large partition
      "sudo chown -R condor /var/log/condor",
      "sudo chgrp -R condor /var/log/condor",
      "sudo chmod -R g+rwx /var/log/condor",
      # Add condor CM IP to config and start, with token auto approval
      "sudo sed -i 's/condor_host_ip/${self.network[0].fixed_ip_v4}/' /etc/condor/condor_config.local",
      # Enable Condor and the auto-approval service, and reboot for them to take effect
      "sudo echo '${var.condor_pass}' > /home/ubuntu/pool_pass",
      "sudo condor_store_cred add -c -p /home/ubuntu/pool_pass",
      "sudo rm -f /home/ubuntu/pool_pass",
      "sudo systemctl enable condor",
      "sudo systemctl start condor",
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

