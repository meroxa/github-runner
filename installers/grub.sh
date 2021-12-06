#!/bin/bash

set -e

sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=\"/GRUB_CMDLINE_LINUX_DEFAULT=\"systemd.unified_cgroup_hierarchy=1/g'

update-initramfs -u -k all
update-grub

grub-install --no-floppy /dev/sda
