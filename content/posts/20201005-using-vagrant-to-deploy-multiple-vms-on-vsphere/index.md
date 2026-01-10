---
title: "Using Vagrant to Deploy Multiple VMs on vSphere"
date: 2020-10-05T09:53:03+08:00
menu:
  sidebar:
    name: "Using Vagrant to Deploy Multiple VMs on vSphere"
    identifier: using-vagrant-to-deploy-multiple-vms-on-vsphere
    weight: 10
tags: ["URL", "vagrant"]
categories: ["URL", "vagrant"]
---

- [Using Vagrant to Deploy Multiple VMs on vSphere](https://buildvirtual.net/using-vagrant-to-deploy-multiple-vms-on-vsphere/)

```ruby
vm1 = { 'name' => "PhotonVM1", 'ip' => "192.168.5.224" }
vm2 = { 'name' => "PhotonVM2", 'ip' => "192.168.5.225" }
vms = [ vm1, vm2]

Vagrant.configure(2) do |config|
  vms.each do |node|
    vm_name = node['name']
    vm_ip = node['ip']
    config.vm.define vm_name do |node_config|
        node_config.vm.network 'private_network', ip: "#{vm_ip}"
        node_config.vm.box = "dummy"
        node_config.vm.box_url = "./example_box/dummy.box"
        node_config.vm.provider :vsphere do |vsphere|
        vsphere.host = 'vc01.testlab.local'
        vsphere.compute_resource_name = 'esxi01.testlab.local'
        vsphere.name = vm_name
        vsphere.customization_spec_name = 'centos66'
        vsphere.template_name = 'PhotonTemplate'
        vsphere.user = 'administrator@vsphere.local'
        vsphere.password = 'password'
        vsphere.insecure = true
        end
        end
  end
end
```
