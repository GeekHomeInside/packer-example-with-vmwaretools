#!/usr/bin/env bash

# Install dependencies
echo "Install dependencies"
yum install -y perl net-tools gcc fuse-libs bzip2 gcc-c++ kernel-devel-`uname -r` make perl

# Mount VMware Tools ISO file
echo "Mount VMware Tools ISO file"
mount -t iso9660 -o loop /root/linux.iso /mnt

# Execute the installer
echo "Execute the installer"
cd /tmp
cp /mnt/VMwareTools-*.gz .
tar zxvf VMwareTools-*.gz
./vmware-tools-distrib/vmware-install.pl -d

# Unmount ISO file
echo "Unmount ISO file"
umount /mnt

# Delete ISO file
echo "Delete ISO file"
rm -f /root/linux.iso

# Delete copied files from ISO
echo "Delete copied files from ISO"
rm -rf VMwareTools-.gz vmware-tools-distrib
