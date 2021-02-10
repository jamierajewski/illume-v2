resource "openstack_compute_instance_v2" "illume-worker-980ti-v2" {

  count = 1
  name  = format("illume-worker-980ti-%02d-v2", count.index + 1)

  flavor_name = "c16-116gb-3400-4.980ti"
  image_id = data.openstack_images_image_v2.worker-image-gpu.id
  key_pair    = "illume-new"
  security_groups = [ "illume-internal-v2" ]
  depends_on = [ openstack_compute_instance_v2.illume-control-v2 ]

  # boot device (ephemeral)
  block_device {
    uuid                  = data.openstack_images_image_v2.worker-image-gpu.id
    source_type           = "image"
    boot_index            = 0
    destination_type      = "local"
    delete_on_termination = true
  }

  # assign all ephemeral storage for this flavor (3400GB),
  # then split it up into partitions.

  block_device {
    boot_index            = -1
    delete_on_termination = true
    destination_type      = "local"
    source_type           = "blank"
    volume_size           = 3400
  }

  # split ephemeral storage into 3 parts:
  # 3060GB - ephemeral0.1 (90%)
  #  170GB - ephemeral0.2 (5%)  
  #  170GB - ephemeral0.3 (5%)
  # mount ephemeral storage #0.1 to /scratch
  # mount ephemeral storage #0.2 to /var/lib/condor
  # mount ephemeral storage #0.3 to /var/lib/cvmfs
  user_data = <<EOF
#cloud-config
disk_setup:
  ephemeral0:
    table_type: 'gpt'
    layout:
      - 90
      - 5
      - 5
    overwrite: true

fs_setup:
  - label: ephemeral0.1
    filesystem: 'ext4'
    device: 'ephemeral0.1'
  - label: ephemeral0.2
    filesystem: 'ext4'
    device: 'ephemeral0.2'
  - label: ephemeral0.3
    filesystem: 'ext4'
    device: 'ephemeral0.3'

mounts:
  - [ ephemeral0.1, /scratch ]
  - [ ephemeral0.2, /var/lib/condor ]
  - [ ephemeral0.3, /var/lib/cvmfs ]
EOF

  network {
    name = var.network
  }

  provisioner "remote-exec" {
    inline = [
      # Set up condor to use scratch securely
      "sudo chmod -R a+rwx /scratch",
      "sudo mkdir -p /scratch/condor/execute",
      "sudo chown -R condor /scratch/condor",
      "sudo chgrp -R condor /scratch/condor",
      "sudo chmod -R g+rwx /scratch/condor",
      # And set the log dir with proper permissions
      "sudo chown -R condor /var/log/condor",
      "sudo chgrp -R condor /var/log/condor",
      "sudo chmod -R g+rwx /var/log/condor",
      # Set up CVMFS with the proxy IPs
      "sudo sed -i 's/example1/${openstack_compute_instance_v2.illume-proxy-v2[0].network[0].fixed_ip_v4}/' /home/ubuntu/default.local",
      "sudo sed -i 's/example2/${openstack_compute_instance_v2.illume-proxy-v2[1].network[0].fixed_ip_v4}/' /home/ubuntu/default.local",
      "sudo mv /home/ubuntu/default.local /etc/cvmfs/default.local",
      "sudo systemctl restart autofs",
      "sudo cvmfs_config probe",
      # Enable LDAP so that we can see usernames in debugging jobs etc. with openLDAP IP...
      "sudo sed -i 's/ldap_ip/${openstack_compute_instance_v2.illume-openLDAP-v2.network[0].fixed_ip_v4}/' /etc/ldap.conf",
      "echo ${var.ldap_admin_pass} | sudo tee /etc/ldap.secret > /dev/null",
      "sudo sed -i 's/ldap_ip/${openstack_compute_instance_v2.illume-openLDAP-v2.network[0].fixed_ip_v4}/' /etc/ldap/ldap.conf",
      "sudo systemctl restart nscd",
      # ...but disable SSH so non-root users can't log in manually to workers
      "echo 'AllowGroups root' | sudo tee -a /etc/ssh/sshd_config",
      # Set up condor with control node's IP and the pool password
      "sudo sed -i 's/condor_host_ip/${openstack_compute_instance_v2.illume-control-v2.network[0].fixed_ip_v4}/' /etc/condor/condor_config.local",
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
