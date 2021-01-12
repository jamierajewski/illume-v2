The Packer configs all use the illume-bastion security group and most
use the bastion flavor for building - why?

Because it is simply using those to build the VM images, meaning it needs
permissions to access SSH and enough resources to build the image with. The
bastion security group has open network access so for ease of use (and limited
secgroups) it is used.

A flavor with GPUs is used to build the worker gpu image since it needs GPUs to
install drivers and other things correctly.