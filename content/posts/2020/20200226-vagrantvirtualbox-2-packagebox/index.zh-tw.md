---
title: "vagrant筆記"
date: 2020-02-26T10:52:19+08:00
menu:
  sidebar:
    name: "vagrant筆記"
    identifier: vagrant-virtualbox-2-packagebox
    weight: 10
tags: ["URL", "Vagrant"]
categories: ["URL", "Vagrant"]
---

- [vagrant 筆記](https://cwza.github.io/my_blog/2016/03/09/vagrant%E7%AD%86%E8%A8%98)
- [Vagrant+virtualbox (2): 實戰封裝自制 package.box](https://ben6.blogspot.com/2011/11/vagrantvirtualbox-2-packagebox.html)
- [Vagrant 學習筆記](https://vagrantpi.github.io/2018/02/11/vagrant/)

1 General
1.1 Path
下載的 box 預設放在~/.vagrant.d/boxes 裡
guest machine 的 data 放的地方根據 VM 設定而不同可開啟 VirtualBox 查看，VirtualBox 預設是在~/VirtualBox\ VMS

1.2 Shared Folder
guest machine 的/vagrant 將會自動 mount 到 host machine 的放 Vagrantfile 的那個 folder
此功能需要 guest machine 的 Box 的 VB guest additions 版本與 VM 中的一樣
若出現錯誤則需要更新 box 或用這個非官方的 plugin: https://github.com/dotless-de/vagrant-vbguest

2 Uninstall
2.1 REMOVING THE VAGRANT PROGRAM

```shell
rm -rf /Applications/Vagrant
rm -f /usr/bin/vagrant
sudo pkgutil --forget com.vagrant.vagrant
```

2.2 REMOVING USER DATA
`rm -rf  ~/.vagrant.d`
3 Command
https://www.vagrantup.com/docs/cli/

```
vagrant init #create Vagrantfile in current folder
vagrant box add USER/BOX #add a box from https://atlas.hashicorp.com/boxes/search
vagrant up #creates and configures guest machines according to your Vagrantfile
vagrant ssh #SSH into a running Vagrant machine and give you access to a shell
vagrant up --provider=vmware_fusion #indicate the provider

vagrant destroy #stops the running machine Vagrant is managing and destroys all resources that were created during the machine creation process.
vagrant halt #shutdown the running machine
vagrant box remove NAME --all #remove box
vagrant halt -f #force shutdown running maching that means to turn off the power
vagrant suspend #save the current running state of the machine and stop it

vagrant reload # == halt and up, use it after Vagrantfile modification
vagrant reload --provision #provision does not run again by default, this command force run provision
3.1 halt vs destory vs box remove
vagrant halt: 將machine關機
vagrant destroy: 將machine關機，且將該machine移除，但box還留著
vagrant box remove: 移除box
```

4 Provision
example: 安裝 apache server and 將 DocumentRoot 指向/vagrant when provision
bootstrap.sh

```bash
#!/usr/bin/env bash

apt-get update
apt-get install -y apache2
if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant /var/www
fi
```

Vagrantfile

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/precise64"
  config.vm.provision :shell, path: "bootstrap.sh"
end
```

記得 run vagrant reload -provision

5 Network
5.1 Port Forwarding

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/precise64"
  config.vm.provision :shell, path: "bootstrap.sh"
  config.vm.network :forwarded_port, guest: 80, host: 4567
end
```

then run vagrant reload

5.2 Private Network

```ruby
Vagrant.configure("2") do |config|
  config.vm.network "private_network", type: "dhcp"
end
```

6 Box
6.1 Create A Base Box
https://www.vagrantup.com/docs/virtualbox/boxes.html
