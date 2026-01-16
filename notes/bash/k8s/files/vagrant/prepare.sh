#!/bin/bash

# Install Kubernetes
k8s_ver='v1.13.0'
binary='kubectl kubelet kube-apiserver kube-controller-manager kube-proxy kube-scheduler'
kube_url="https://storage.googleapis.com/kubernetes-release/release/${k8s_ver}/bin/linux/amd64"
echo 'Create bin directory'
mkdir bin
echo 'Download k8s binary files'
for pack in ${binary}
do
    wget -P bin/ ${kube_url}/${pack}
done

# Install cfssl
echo 'Download cfssl'
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64

mv cfssl_linux-amd64 bin/cfssl
mv cfssljson_linux-amd64 bin/cfssljson

# Install Etcd
echo 'Download Etcd'
etcd_ver='v3.3.9'
etcd_url="https://github.com/coreos/etcd/releases/download/${etcd_ver}/etcd-${etcd_ver}-linux-amd64.tar.gz"
curl -sSL ${etcd_url} | tar -xz --strip-components=1 -C bin/
rm -rf bin/Documentation bin/README*

# Install CNI
echo 'Download CNI'
cni_ver='v0.7.1'
cni_url="https://github.com/containernetworking/plugins/releases/download/${cni_ver}/cni-plugins-amd64-${cni_ver}.tgz"
wget ${cni_url}

# Install keepalived
echo 'Download keepalived'
keep_ver='2.0.7'
keep_url="http://www.keepalived.org/software/keepalived-${keep_ver}.tar.gz"
wget ${keep_url}

echo 'Execute `vagrant up`'
vagrant up
