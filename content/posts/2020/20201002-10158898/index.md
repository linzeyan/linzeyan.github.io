---
title: "Vagrantfile and Provider"
date: 2020-10-02T19:41:23+08:00
menu:
  sidebar:
    name: "Vagrantfile and Provider"
    identifier: vagrant-vagrantfile-and-provider-introduct
    weight: 10
tags: ["URL", "vagrant"]
categories: ["URL", "vagrant"]
---

- [Day 8 - Vagrantfile and Provider](https://ithelp.ithome.com.tw/articles/10158898)
- [Day 9 - Advanced Vagrantfile(編輯中)](https://ithelp.ithome.com.tw/articles/10159037)

用以下這個範例
你只要使用 Vagrant up 加上 provider 參數，就可開啟不同來源的機器

例如我要開啟 Vsphere 的機器，我只要下 `vagrant up --provider=vsphere`

要開 AWS 的機器，我只要下 `vagrant up --provider=aws`

```ruby
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # 我們定義一個 Ubuntu 的機器
  # box 的需求是對於 local 的 VM 才需要的
  # 所以在 provider 是 vmware_fusion 或 Virtualbox 時，才會用到這個設定
  config.vm.box = "hashicorp/precise64"

  # vmware_fusion
  config.vm.provider "vmware_fusion" do |v, override|
      override.vm.box = "precise64_vmware"
      v.gui = false
  end

  # vsphere
  config.vm.provider :vsphere do |vsphere|
    # 對於私有雲及公有雲，要clone 的vm 是儲存在雲端上的
    # 所以 box 使用 dummy box 來達到這個目的
    vsphere.vm.box = "nkhasanov/vsphere-simple"
    vsphere.host = 'YOURIP'
    vsphere.compute_resource_name = 'YOUR DATACENTER'
    vsphere.resource_pool_name = 'YOUR RESOURCE POOL'
    vsphere.insecure = true
    vsphere.template_name = 'VM TEMPLATE'
    vsphere.name = "#{YOUR_NAME}-test-machine"
    vsphere.user = 'administrator'
    vsphere.password = '$p1unK_Lab'
    vsphere.vm_base_path = 'vmware_template'
    vsphere.linked_clone = true
  end

  # virtual box
  config.vm.provider "virtualbox" do |vb|
      vb.gui = false
  end

  # aws
  config.vm.provider :aws do |aws, override|
      # aws configurations
      aws.access_key_id = "#{YOUR_AWS_ACCESS_KEY_ID}"
      aws.secret_access_key = "#{YOUR_AWS_ACCESS_KEY}"
      aws.keypair_name = "#{YOUR_NAME}"
      aws.security_groups = "#{YOUR_NAME}"
      aws.instance_type = "t2.small"
      aws.region = "us-east-1"
      # ubuntu 14.04 x64
      aws.ami = "ami-864d84ee"

      # override info
      override.ssh.username = "ubuntu"
      override.ssh.private_key_path = "#{YOUR_AWS_PRIVATE_KEY_PATH}"
      override.vm.synced_folder "#{YOUR_SYNC_FOLDER}", "/vagrant", type: "rsync"
      override.vm.box = "dimroc/awsdummy"
  end

end
```

---

```ruby
LOCAL_BOXS = {
  "ubuntu1404x64" => "ubuntu/trusty64",
  "ubuntu1210x64" => "chef/ubuntu-12.10"
}

AWS_AMIS = {
  "ubuntu1404x64" => "ami-864d84ee",
  "ubuntu1210x64" => "ami-02df496b",
  "windows2012r2x64" => "ami-9ade1df2",
  "windows2012x64" => "ami-5ce32034",
  "windows2008r2x64" => "ami-2ae02342",
  "windows2008x64" => "ami-5e24e936",
  "windows2003r2x64" => "ami-b0e320d8"
}

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "precise64_vmware"

  # vmware_fusion
  config.vm.provider "vmware_fusion" do |v, override|
      override.vm.box = "precise64_vmware"
      v.gui = false
      v.vmx["memsize"] = "1024"
      v.vmx["numvcpus"] = "2"
  end

  # vsphere
  config.vm.provider :vsphere do |vsphere|
    vsphere.vm.box = "nkhasanov/vsphere-simple"
    vsphere.host = '#{}'
    vsphere.compute_resource_name = '#{}'
    # vsphere.resource_pool_name = 'YOUR RESOURCE POOL'
    vsphere.insecure = true
    vsphere.template_name = 'qasus-tw-centos7x64-01'
    vsphere.name = "#{YOUR_NAME}-test-machine"
    vsphere.user = 'administrator'
    vsphere.password = '#{}'
    vsphere.vm_base_path = 'vmware_template'
    vsphere.linked_clone = true
  end

  # virtual box
  config.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.memory = 1024
      vb.cpus = 2
  end

  # aws
  config.vm.provider :aws do |aws, override|
      # aws configurations
      aws.access_key_id = "#{YOUR_AWS_ACCESS_KEY_ID}"
      aws.secret_access_key = "#{YOUR_AWS_ACCESS_KEY}"
      aws.keypair_name = "#{YOUR_NAME}"
      aws.security_groups = "#{YOUR_NAME}"
      aws.instance_type = "t2.small"
      aws.region = "us-east-1"
      # ubuntu 14.04 x64
      aws.ami = "ami-864d84ee"

      # override info
      override.ssh.username = "ubuntu"
      override.ssh.private_key_path = "#{YOUR_AWS_PRIVATE_KEY_PATH}"
      override.vm.synced_folder "#{YOUR_SYNC_FOLDER}", "/vagrant", type: "rsync"
      override.vm.box = "dimroc/awsdummy"
  end

  # VMs
  (1..MAX_VM_NUMBER).each do |i|
    # define linux
    config.vm.define "l#{i}" do |node|
      # aws
      node.vm.provider :aws do |aws|
        aws.tags = {
          "Name" => "#{YOUR_NAME}-linux-#{i}"
        }
      end
      # local
      # node.vm.network "private_network", ip: "192.168.33.%d" % (i+2)
      node.vm.hostname = "ftan-linux-#{i}"
    end
    # define windows
    config.vm.define "w#{i}" do |node|
      node.vm.provider :aws do |aws|
        aws.ami = "ami-2ae02342"
        aws.tags = {
          "Name" => "#{YOUR_NAME}-windows-#{i}"
        }
      end
    end
  end

  # define customer
  YOUR_CUSTOMIZED_VM.each do |vm|
    config.vm.define "%s" % vm["name"] do |node|
      # aws
      node.vm.provider :aws do |aws|
        aws.ami = AWS_AMIS[vm["platform"]]
        aws.tags = {
          "Name" => "#{YOUR_NAME}-%s" % vm["name"]
        }
      end
      # vmware fusion
      # vmware workstation
      node.vm.provider :vmware_fusion do |fusion|
        fusion.vm.box = LOCAL_BOXS[vm["platform"]]
        fusion.vm.hostname = "#{YOUR_NAME}-%s" % vm["name"]
      end
      # vsphere
      # azure
    end
  end
end
```
