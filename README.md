# Packer CentOS

This repository contains files used by [Packer][packer] to create CentOS images for VMware (vmware) and vbox

## Variables available

    Optional variables and their defaults:

      build_number      = {{timestamp}}
      centos_arch       = x86_64
      disk_size         = 10000
      headless          = true
      iso_base_url      = iso
      iso_checksum_type = sha256
      password          = password
      timeout           = 30m
      username          = root

In addition, several variables files are available in order to precise which version of CentOS you want to use. The Packer *-var-file* option has to be used with one of these files.

## Examples

To create an image of CentOS 7 for all the hypervisors :

    packer build -var-file centos7.json packer-centos.json
    packer build -only vbox -var-file centos7.json packer-centos.json
