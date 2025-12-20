---
title: "How to automatically resize virtual box disk with vagrant"
date: 2020-08-25T09:40:34+08:00
menu:
  sidebar:
    name: "How to automatically resize virtual box disk with vagrant"
    identifier: how-to-automatically-resize-virtual-box-disk-with-vagrant
    weight: 10
tags: ["URL", "Vagrant"]
categories: ["URL", "Vagrant"]
---

- [How to automatically resize virtual box disk with vagrant](https://medium.com/@kanrangsan/how-to-automatically-resize-virtual-box-disk-with-vagrant-9f0f48aa46b3)
- [Increasing Disk Space of a Linux-based Vagrant Box on Provisioning](https://marcbrandner.com/blog/increasing-disk-space-of-a-linux-based-vagrant-box-on-provisioning/)

```ruby
Vagrant.configure(2) do |config|
config.vm.box = "centos/7"
config.disksize.size = '20GB'
end
```

```shell
$ sudo parted /dev/sda resizepart 2 100%

$ sudo lvextend -l +100%FREE /dev/centos/root

$ sudo xfs_growfs /dev/centos/root
```

##### Automate Part

```ruby
Vagrant.configure(2) do |config|
common = <<-SCRIPT
sudo parted /dev/sda resizepart 2 100%
sudo pvresize /dev/sda2
sudo lvextend -l +100%FREE /dev/centos/root
sudo xfs_growfs /dev/centos/root
SCRIPT
config.vm.define "node01" do |node1|
node1.vm.hostname = "node01"
node1.vm.network "private_network", ip: "192.168.56.121"
config.vm.provision :shell, :inline => common
end
end
```

---

`vagrant plugin install vagrant-disksize`

##### Vagrantfile

```ruby
# Fail if the vagrant-disksize plugin is not installed
unless Vagrant.has_plugin?("vagrant-disksize")
  raise 'vagrant-disksize is not installed!'
end
Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |vb|
    vb.name = "DISKEXTEND"
	vb.memory = 2048
	vb.cpus = 2
  end
    config.vm.define :"DISKEXTEND" do |t|
  end
  config.vm.hostname = "DISKEXTEND"
  config.vm.box = "bento/ubuntu-18.04"
  # Increase the default disk size of the bento image (64GB) to 96GB
  config.disksize.size = "96GB"
  # Run a script on provisioning the box to format the file system
  config.vm.provision "shell", path: "disk-extend.sh"
end
```

##### Provisioning Script: disk-extend.sh

```bash
#!/bin/bash
echo "> Installing required tools for file system management"
if  [ -n "$(command -v yum)" ]; then
    echo ">> Detected yum-based Linux"
    sudo yum makecache
    sudo yum install -y util-linux
    sudo yum install -y lvm2
    sudo yum install -y e2fsprogs
fi
if [ -n "$(command -v apt-get)" ]; then
    echo ">> Detected apt-based Linux"
    sudo apt-get update -y
    sudo apt-get install -y fdisk
    sudo apt-get install -y lvm2
    sudo apt-get install -y e2fsprogs
fi
ROOT_DISK_DEVICE="/dev/sda"
ROOT_DISK_DEVICE_PART="/dev/sda1"
LV_PATH=`sudo lvdisplay -c | sed -n 1p | awk -F ":" '{print $1;}'`
FS_PATH=`df / | sed -n 2p | awk '{print $1;}'`
ROOT_FS_SIZE=`df -h / | sed -n 2p | awk '{print $2;}'`
echo "The root file system (/) has a size of $ROOT_FS_SIZE"
echo "> Increasing disk size of $ROOT_DISK_DEVICE to available maximum"
sudo fdisk $ROOT_DISK_DEVICE <<EOF
d
n
p
1
2048
no
w
EOF
sudo pvresize $ROOT_DISK_DEVICE_PART
sudo lvextend -l +100%FREE $LV_PATH
sudo resize2fs -p $FS_PATH
ROOT_FS_SIZE=`df -h / | sed -n 2p | awk '{print $2;}'`
echo "The root file system (/) has a size of $ROOT_FS_SIZE"
exit 0
```
