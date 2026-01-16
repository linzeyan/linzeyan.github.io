#!/usr/bin/env bash

export PATH=${PATH}:/usr/local/bin
sed -i -E 's|^PATH.+$|&:/usr/local/bin|g' /root/.bash_profile
instance_num=${1:-3}
cluster_IP='10.0.0'
VIP="${cluster_IP}.200"
etcd_cluster79=''
cluster2=''
cluster4=''

# Add kubernetes repo
echo 'Generate kubernetes repo'
cat << EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Ensure Directories are present
echo 'Create Directory'
mkdir -p $HOME/.kube \
         /etc/keepalived

# Define variables
for ((i=1;i<=${instance_num};i++));
#for i in $(seq 1 ${instance_num})
do
    declare "node${i}"="${cluster_IP}.$(($i+100))"
    eval "ip"="\$node${i}"
    echo "${ip}  node${i}" >> /etc/hosts
    etcd_cluster79="${etcd_cluster79}https://${ip}:2379,"
    cluster2="${cluster2}  - \"node${i}\"\n  - \"${ip}\"\n"
    cluster4="${cluster4}    - \"node${i}\"\n    - \"${ip}\"\n"
done

eval ip="\$$(hostname)"
etcd_2379=$(echo $etcd_cluster79 | sed 's/,$//g')
#VIP="${node1}"
echo 'Starting replace variable'
sed -i "s/\${hostname}/$(hostname)/g" /vagrant/conf/*
sed -i "s/\${ip}/${ip}/g" /vagrant/conf/*
sed -i "s/\${perip2}/${cluster2}/g" /vagrant/conf/*
sed -i "s/\${perip4}/${cluster4}/g" /vagrant/conf/*
sed -i "s/\${VIP}/${VIP}/g" /vagrant/conf/*
sed -i "s|\${etcd_2379}|${etcd_2379}|g" /vagrant/conf/*

echo 'Copy files'
cp -r /vagrant/ssh ~/.ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# Change time zone
echo 'Change time zone'
timezone='Asia/Taipei'
ln -sf /usr/share/zoneinfo/${timezone} /etc/localtime
timedatectl set-timezone ${timezone}

# Using socat to port forward in helm tiller
# Install  kmod and ceph-common for rook
echo 'Install dependent packages'
yum install -y -q epel-release
yum install -y -q \
    bind-utils \
    ceph-common \
    chrony \
    conntrack \
    conntrack-tools \
    curl \
    device-mapper-persistent-data \
    gcc \
    gcc-c++ \
    htop \
    ipvsadm \
    ipset \
    jq \
    kmod \
    libseccomp \
    lvm2 \
    net-tools \
    openssl-devel \
    socat \
    sysstat \
    tcpdump \
    telnet \
    tmux \
    vim \
    wget

# Ensure ssh key present
echo 'Get ssh key'
for u in root vagrant
do
    u_home="$(awk -F ':' "{if(\$1==\"${u}\")print \$6}" /etc/passwd)"
    echo '' >>  ${u_home}/.ssh/authorized_keys
    curl https://github.com/linzeyan.keys >>  ${u_home}/.ssh/authorized_keys
done

# Enable chronyd to sync time
echo 'sync time'
systemctl start chronyd
systemctl enable chronyd

# Install Docker
echo 'Install Docker'
curl -sSL https://get.docker.com/ | sudo bash
usermod -aG docker vagrant
systemctl enable docker
systemctl start docker

# Disable selinux
echo 'disable selinux'
setenforce 0
sed -i 's/=enforcing/=disabled/g' /etc/selinux/config

# Enable ipv4 forward
echo 'Genreate sysctl config'
cat > /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
vm.swappiness=0
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_watches=89100
EOF
sysctl -p /etc/sysctl.d/kubernetes.conf

# Set nameserver
echo 'set nameserver'
echo "nameserver 8.8.8.8">/etc/resolv.conf
cat /etc/resolv.conf

# Disable swap
echo 'disable swap'
swapoff -a
sed -i '/swap/s/^/#/' /etc/fstab

# Install kubernetes
echo 'Install kubernetes'
yum install -y -q \
  kubelet \
  kubeadm \
  kubectl
systemctl enable kubelet
systemctl start kubelet

# Install keepalived
echo 'Download keepalived'
keep_ver='2.0.7'
keep_url="http://www.keepalived.org/software/keepalived-${keep_ver}.tar.gz"
wget ${keep_url} -P /vagrant
echo 'Install keepalived'
keep_prefix='/usr/local/keepalived'
tar xf /vagrant/$(echo ${keep_url} | awk -F '/' '{print $NF}') -C /tmp/
cd /tmp/keepalived-${keep_ver}
./configure --prefix=${keep_prefix} && make && make install
ln -sf ${keep_prefix}/etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf
ln -sf ${keep_prefix}/etc/sysconfig/keepalived /etc/sysconfig/keepalived
ln -sf ${keep_prefix}/sbin/keepalived /sbin/keepalived

# Generate new keepalived config
if [[ $(hostname) == "node${instance_num}" ]]; then
    sed -i 's/state BACKUP/state MASTER/g' /vagrant/conf/keepalived.conf
    sed -i 's/priority 50/priority 100/g'  /vagrant/conf/keepalived.conf
fi
cat /vagrant/conf/keepalived.conf > /etc/keepalived/keepalived.conf
echo 'Enable keepalived'
systemctl enable keepalived
systemctl start keepalived

if [[ $(hostname) == "node${instance_num}" ]]; then

    echo 'Cluster init...'
    kubeadm init --config /vagrant/conf/kubeadm-config.yml --ignore-preflight-errors=all
    ln -sf /etc/kubernetes/admin.conf ~/.kube/config
    ## kubectl get cs
    ## scheduler Unhealthy Get "http://127.0.0.1:10251/healthz": dial tcp 127.0.0.1:10251: connect: connection refused
    sed -i '/- --port=0/d' /etc/kubernetes/manifests/kube-controller-manager.yaml /etc/kubernetes/manifests/kube-scheduler.yaml
    systemctl restart kubelet
    echo 'Sync k8s configs to other nodes'
    for i in $(seq 1 $((${instance_num}-1)));
    do
        rsync -az \
          --exclude 'apiserver*' \
          --exclude 'front-proxy-client.*' \
          --exclude 'etcd/healthcheck-client.*' \
          --exclude 'etcd/peer.*' \
          --exclude 'etcd/server.*' \
          /etc/kubernetes/pki node${i}:/etc/kubernetes/

        rsync -az /etc/kubernetes/admin.conf node${i}:/etc/kubernetes
    done

    echo 'Create flannel'
    # https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
    kubectl apply -f /vagrant/addon/flannel-v0.12.0.yml
    echo 'Other nodes join'
    token=$(kubeadm token list | awk 'NR==2{print $1}')
    key=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')
    for i in $(seq 1 $((${instance_num}-1)));
    do
        eval ip="\$node${i}"
        ssh node${i} 'ln -sf /etc/kubernetes/admin.conf ~/.kube/config'
        ssh node${i} "kubeadm join ${VIP}:6443 --token ${token} \
                        --discovery-token-ca-cert-hash sha256:${key} \
                        --apiserver-advertise-address ${ip} \
                        --control-plane --ignore-preflight-errors=all"
        #sudo chown $(id -u):$(id -g) $HOME/.kube/config
        sleep 10
    done
    kubectl taint nodes --all node-role.kubernetes.io/master-
    # Test
    #kubectl create deployment nginx --image=nginx
    #kubectl create service nodeport nginx --tcp=80:80
fi
