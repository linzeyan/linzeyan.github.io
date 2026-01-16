#!/usr/bin/env bash

export PATH=${PATH}:/usr/local/bin
sed -i -E 's|^PATH.+$|&:/usr/local/bin|g' /root/.bash_profile
instance_num=${1:-3}
cluster_IP='10.0.0'
VIP="${cluster_IP}.200"
etcd_cluster79=''
etcd_cluster80=''
etcd_per79=''
perIP=''
perIP_json=''
perIP_str=''

# Ensure Directories are present
echo 'Create Directory'
mkdir -p /etc/{calico,keepalived} \
         /etc/etcd/ssl \
         /etc/kubernetes/{manifests,pki,addon} \
         /opt/cni/bin \
         /var/lib/{etcd,kubelet} \
         /var/log/kubernetes \
         $HOME/.kube

# Define variables
for ((i=1;i<=${instance_num};i++));
#for i in $(seq 1 ${instance_num})
do
    declare "node${i}"="${cluster_IP}.$(($i+100))"
    eval "ip"="\$node${i}"
    echo "${ip}  node${i}" >> /etc/hosts
    etcd_per79="${etcd_per79}  - \"https:\/\/${ip}:2379\"\n"
    perIP="${perIP}  - \"${ip}\"\n"
    perIP_json="${perIP_json}\"node${i}\",\"${ip}\",\n"
    perIP_str="${perIP_json}node${i},${ip},"
    etcd_cluster79="${etcd_cluster79}https://${ip}:2379,"
    etcd_cluster80="${etcd_cluster80}node${i}=https://${ip}:2380,"
done

etcd_cluster79=$(echo $etcd_cluster79 | sed 's/,$//g')
etcd_cluster80=$(echo $etcd_cluster80 | sed 's/,$//g')
hostname_ALL="localhost,127.0.0.1,10.96.0.1,${perIP_str}${VIP},*.kubernetes.master,kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.default.svc.cluster.local"
eval ip="\$$(hostname)"

echo 'Starting replace variable'
sed -i "s/\${hostname}/$(hostname)/g" /vagrant/conf/* /vagrant/pki/* /vagrant/service/*
sed -i "s/\${ip}/${ip}/g" /vagrant/conf/* /vagrant/pki/* /vagrant/service/*
sed -i "s/\${VIP}/${VIP}/g" /vagrant/conf/* /vagrant/pki/* /vagrant/service/*
sed -i "s|\${etcd_cluster79}|${etcd_cluster79}|g" /vagrant/addon/calico.yml /vagrant/conf/* /vagrant/service/*
sed -i "s|\${etcd_cluster80}|${etcd_cluster80}|g" /vagrant/service/etcd.service
sed -i "s/\${etcd_per79}/${etcd_per79}/g" /vagrant/conf/etcd-config.yml
sed -i "s/\${perIP}/${perIP}/g" /vagrant/conf/etcd-config.yml
sed -i "s/\${perIP_json}/${perIP_json}/g" /vagrant/pki/apiserver-csr.json /vagrant/pki/kubelet-csr.json

echo 'Copy files'
chmod 755 /vagrant/bin/*
cp /vagrant/conf/audit-policy.yml /etc/kubernetes/audit-policy.yml
cp /vagrant/conf/etcd-config.yml /etc/kubernetes/etcd-config.yml
cp /vagrant/conf/kubelet-config.yml /etc/kubernetes/kubelet-config.yml
cp /vagrant/conf/etcd.conf /etc/etcd/etcd.conf
cp -r /vagrant/bin/* /usr/local/bin/
cp -r /vagrant/service/* /lib/systemd/system/
cp -r /vagrant/ssh ~/.ssh
cp -r /vagrant/ssl/etcd/* /etc/etcd/ssl/
cp -r /vagrant/ssl/k8s/* /etc/kubernetes/pki/
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
echo 'Install packages'
yum install -y -q epel-release
yum install -y -q \
    bind-utils \
    ceph-common \
    chrony \
    conntrack-tools \
    curl \
    gcc \
    gcc-c++ \
    kmod \
    net-tools \
    openssl-devel \
    socat \
    telnet \
    tcpdump \
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
systemctl enable --now chronyd

# Disable selinux
echo 'disable selinux'
setenforce 0
sed -i 's/=enforcing/=disabled/g' /etc/selinux/config

# Enable ipv4 forward
echo 'enable iptable kernel parameter'
cat >> /etc/sysctl.conf <<EOF
net.ipv4.ip_forward=1
EOF
sysctl -p

# Set nameserver
echo 'set nameserver'
echo "nameserver 8.8.8.8">/etc/resolv.conf
cat /etc/resolv.conf

# Disable swap
echo 'disable swap'
swapoff -a
sed -i '/swap/s/^/#/' /etc/fstab

# Install Docker
echo 'Install Docker'
curl -sSL https://get.docker.com/ | sudo bash
usermod -aG docker vagrant
systemctl enable --now docker

# Install CNI
echo 'Install CNI'
cni_ver='v0.7.1'
cni_url="https://github.com/containernetworking/plugins/releases/download/${cni_ver}/cni-plugins-amd64-${cni_ver}.tgz"
tar xf /vagrant/$(echo ${cni_url} | awk -F '/' '{print $NF}') -C /opt/cni/bin

# Install keepalived
echo 'Install keepalived'
keep_ver='2.0.7'
keep_url="http://www.keepalived.org/software/keepalived-${keep_ver}.tar.gz"
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
systemctl enable --now keepalived

# Generate Etcd certificate
echo 'Generate Etcd certificate'
cfssl gencert -ca=/etc/etcd/ssl/etcd-ca.pem \
              -ca-key=/etc/etcd/ssl/etcd-ca-key.pem \
              -config=/vagrant/pki/etcd-ca-config.json \
              -profile=server /vagrant/pki/etcd-server-config.json | cfssljson -bare /etc/etcd/ssl/server
cfssl gencert -ca=/etc/etcd/ssl/etcd-ca.pem \
              -ca-key=/etc/etcd/ssl/etcd-ca-key.pem \
              -config=/vagrant/pki/etcd-ca-config.json \
              -profile=peer /vagrant/pki/etcd-server-config.json | cfssljson -bare /etc/etcd/ssl/peer

# Generate kubelet certificate
cfssl gencert -ca=/etc/kubernetes/pki/ca.pem \
              -ca-key=/etc/kubernetes/pki/ca-key.pem \
              -config=/vagrant/pki/ca-config.json \
              -hostname=${hostname_ALL} \
              -profile=kubernetes /vagrant/pki/kubelet-csr.json | cfssljson -bare /etc/kubernetes/pki/kubelet

# Copy Etcd certificate to calico
cp /etc/etcd/ssl/* /etc/calico

# Generate kubelet kubeconfig
echo 'Generate kubelet kubeconfig'
kubectl config set-cluster kubernetes \
        --certificate-authority=/etc/kubernetes/pki/ca.pem \
        --embed-certs=true \
        --server=https://${VIP}:5443 \
        --kubeconfig=/etc/kubernetes/kubelet.conf
kubectl config set-credentials system:node:$(hostname) \
        --client-certificate=/etc/kubernetes/pki/kubelet.pem \
        --client-key=/etc/kubernetes/pki/kubelet-key.pem \
        --embed-certs=true \
        --kubeconfig=/etc/kubernetes/kubelet.conf
kubectl config set-context system:node:$(hostname)@kubernetes \
        --cluster=kubernetes \
        --user=system:node:$(hostname) \
        --kubeconfig=/etc/kubernetes/kubelet.conf
kubectl config use-context system:node:$(hostname)@kubernetes \
        --kubeconfig=/etc/kubernetes/kubelet.conf

if [[ $(hostname) == "node${instance_num}" ]]; then
    tokenID=$(openssl rand 3 -hex)
    tokenSECRET=$(openssl rand 8 -hex)
    BOOTSTRAP_TOKEN="${tokenID}.${tokenSECRET}"
    sed -i "s/\${tokenID}/${tokenID}/g" /vagrant/addon/kubelet-bootstrap-secret.yml
    sed -i "s/\${tokenSECRET}/${tokenSECRET}/g" /vagrant/addon/kubelet-bootstrap-secret.yml
    cp addon/* /etc/kubernetes/addon/
    # Generate kubelet certificate
    cfssl gencert -ca=/etc/kubernetes/pki/ca.pem \
                  -ca-key=/etc/kubernetes/pki/ca-key.pem \
                  -config=/vagrant/pki/ca-config.json \
                  -hostname=${hostname_ALL} \
                  -profile=kubernetes /vagrant/pki/apiserver-csr.json | cfssljson -bare /etc/kubernetes/pki/apiserver
    echo 'Sync apiserver certificate to other nodes'
    for i in $(seq 1 $((${instance_num}-1)));
    do
        rsync -az /etc/kubernetes/pki/apiserver* node${i}:/etc/kubernetes/pki/
    done
    # Generate configs
    echo 'Generate k8s configs'
    # Admin
    kubectl config set-cluster kubernetes \
            --certificate-authority=/etc/kubernetes/pki/ca.pem \
            --embed-certs=true \
            --server=https://${VIP}:5443 \
            --kubeconfig=/etc/kubernetes/admin.conf
    kubectl config set-credentials kubernetes-admin \
            --client-certificate=/etc/kubernetes/pki/admin.pem \
            --client-key=/etc/kubernetes/pki/admin-key.pem \
            --embed-certs=true \
            --kubeconfig=/etc/kubernetes/admin.conf
    kubectl config set-context kubernetes-admin@kubernetes \
            --cluster=kubernetes \
            --user=kubernetes-admin \
            --kubeconfig=/etc/kubernetes/admin.conf
    kubectl config use-context kubernetes-admin@kubernetes \
            --kubeconfig=/etc/kubernetes/admin.conf
    # Controller Manager
    kubectl config set-cluster kubernetes \
            --certificate-authority=/etc/kubernetes/pki/ca.pem \
            --embed-certs=true \
            --server=https://${VIP}:5443 \
            --kubeconfig=/etc/kubernetes/controller-manager.conf
    kubectl config set-credentials system:kube-controller-manager \
            --client-certificate=/etc/kubernetes/pki/controller-manager.pem \
            --client-key=/etc/kubernetes/pki/controller-manager-key.pem \
            --embed-certs=true \
            --kubeconfig=/etc/kubernetes/controller-manager.conf
    kubectl config set-context system:kube-controller-manager@kubernetes \
            --cluster=kubernetes \
            --user=system:kube-controller-manager \
            --kubeconfig=/etc/kubernetes/controller-manager.conf
    kubectl config use-context system:kube-controller-manager@kubernetes \
            --kubeconfig=/etc/kubernetes/controller-manager.conf
    # Scheduler
    kubectl config set-cluster kubernetes \
            --certificate-authority=/etc/kubernetes/pki/ca.pem \
            --embed-certs=true \
            --server=https://${VIP}:5443 \
            --kubeconfig=/etc/kubernetes/scheduler.conf
    kubectl config set-credentials system:kube-scheduler \
            --client-certificate=/etc/kubernetes/pki/scheduler.pem \
            --client-key=/etc/kubernetes/pki/scheduler-key.pem \
            --embed-certs=true \
            --kubeconfig=/etc/kubernetes/scheduler.conf
    kubectl config set-context system:kube-scheduler@kubernetes \
            --cluster=kubernetes \
            --user=system:kube-scheduler \
            --kubeconfig=/etc/kubernetes/scheduler.conf
    kubectl config use-context system:kube-scheduler@kubernetes \
            --kubeconfig=/etc/kubernetes/scheduler.conf
    # Proxy
    kubectl config set-cluster kubernetes \
            --certificate-authority=/etc/kubernetes/pki/ca.pem \
            --embed-certs=true \
            --server=https://${VIP}:5443 \
            --kubeconfig=/etc/kubernetes/proxy.conf
    kubectl config set-credentials system:kube-proxy \
            --client-certificate=/etc/kubernetes/pki/kube-proxy.pem \
            --client-key=/etc/kubernetes/pki/kube-proxy-key.pem \
            --embed-certs=true \
            --kubeconfig=/etc/kubernetes/proxy.conf
    kubectl config set-context system:kube-proxy@kubernetes \
            --cluster=kubernetes \
            --user=system:kube-proxy \
            --kubeconfig=/etc/kubernetes/proxy.conf
    kubectl config use-context system:kube-proxy@kubernetes \
            --kubeconfig=/etc/kubernetes/proxy.conf
    # TLS Bootstrapping
    kubectl config set-cluster kubernetes \
            --certificate-authority=/etc/kubernetes/pki/ca.pem \
            --embed-certs=true \
            --server=https://${VIP}:5443 \
            --kubeconfig=/etc/kubernetes/bootstrap.conf
    kubectl config set-credentials tls-bootstrap-token-user \
            --token=${BOOTSTRAP_TOKEN} \
            --kubeconfig=/etc/kubernetes/bootstrap.conf
    kubectl config set-context tls-bootstrap-token-user@kubernetes \
            --cluster=kubernetes \
            --user=tls-bootstrap-token-user \
            --kubeconfig=/etc/kubernetes/bootstrap.conf
    kubectl config use-context tls-bootstrap-token-user@kubernetes \
            --kubeconfig=/etc/kubernetes/bootstrap.conf

    # Modify calico yaml
    ETCD_CA=$(cat /etc/etcd/ssl/etcd-ca.pem | base64 | tr -d '\n')
    sed -i "s@.*etcd-ca:.*@\ \ etcd-ca:\ ${ETCD_CA}@gi" /etc/kubernetes/addon/calico.yml
    ETCD_CERT=$(cat /etc/etcd/ssl/client.pem | base64 | tr -d '\n')
    sed -i "s@.*etcd-cert:.*@\ \ etcd-cert:\ ${ETCD_CERT}@gi" /etc/kubernetes/addon/calico.yml
    ETCD_KEY=$(cat /etc/etcd/ssl/client-key.pem | base64 | tr -d '\n')
    sed -i "s@.*etcd-key:.*@\ \ etcd-key:\ ${ETCD_KEY}@gi" /etc/kubernetes/addon/calico.yml;

    echo 'Sync k8s configs to other nodes'
    for f in admin controller-manager scheduler proxy bootstrap;
    do
        for i in $(seq 1 $((${instance_num}-1)));
        do
            rsync -az /etc/kubernetes/${f}.conf  node${i}:/etc/kubernetes/
        done
    done

    ln -sf /etc/kubernetes/admin.conf ~/.kube/config
    systemctl daemon-reload
    echo 'Enable kubelet'
    systemctl enable --now kubelet
    echo 'Sleep 300 secs to pull images'
    sleep 300
    for i in $(seq 1 $((${instance_num}-1)));
    do
        ssh node${i} "
          ln -sf /etc/kubernetes/admin.conf ~/.kube/config \
          && systemctl daemon-reload \
          && systemctl enable --now kubelet \
          && sleep 300" &
    done
    wait

    # Create TLS Bootstrap Secret
    echo 'Create pods'
    kubectl create -f /etc/kubernetes/addon/kubelet-bootstrap-secret.yml
    kubectl create -f /etc/kubernetes/addon/kubelet-bootstrap-rbac.yml
    kubectl create -f /etc/kubernetes/addon/apiserver-to-kubelet-rbac.yml
    kubectl create -f /etc/kubernetes/addon/calico-rbac.yml
    kubectl create -f /etc/kubernetes/addon/calico.yml
    kubectl create -f /etc/kubernetes/addon/kube-dns.yml
    kubectl create -f /etc/kubernetes/addon/kube-dns-autoscaler.yml

    echo 'Enable calico'
    systemctl enable --now calico-node
    for i in $(seq 1 $((${instance_num}-1)));
    do
        ssh node${i} "systemctl enable --now calico-node"
    done
fi
