#!/usr/bin/env bash

instance_num=${1:-3}
cluster_IP='10.0.0'
VIP="${cluster_IP}.200"
etcd_cluster79=''
etcd_cluster80=''
etcd_per79=''
perIP=''
perIP_json=''
perIP_str=''

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

if [[ $(hostname) != "node1" ]]; then
    echo 'Sleep 30 secs'
    sleep 30
fi

if [[ $(hostname) == "node1" ]]; then
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
    for i in $(seq 2 ${instance_num});
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

    echo 'Sync k8s configs to other nodes'
    for f in admin controller-manager scheduler proxy bootstrap;
    do
        for i in $(seq 2 ${instance_num});
        do
            rsync -az /etc/kubernetes/${f}.conf  node${i}:/etc/kubernetes/
        done
    done

    ETCD_CA=$(cat /etc/etcd/ssl/etcd-ca.pem | base64 | tr -d '\n')
    sed -i "s@.*etcd-ca:.*@\ \ etcd-ca:\ ${ETCD_CA}@gi" /etc/kubernetes/addon/calico.yml
    ETCD_CERT=$(cat /etc/etcd/ssl/client.pem | base64 | tr -d '\n')
    sed -i "s@.*etcd-cert:.*@\ \ etcd-cert:\ ${ETCD_CERT}@gi" /etc/kubernetes/addon/calico.yml
    ETCD_KEY=$(cat /etc/etcd/ssl/client-key.pem | base64 | tr -d '\n')
    sed -i "s@.*etcd-key:.*@\ \ etcd-key:\ ${ETCD_KEY}@gi" /etc/kubernetes/addon/calico.yml;
fi


ln -sf /etc/kubernetes/admin.conf ~/.kube/config
systemctl daemon-reload
echo 'Enable kubelet'
systemctl enable kubelet
systemctl start kubelet
echo 'Sleep 600 secs to pull images'
sleep 600

# Create TLS Bootstrap Secret
echo 'Create pods'
if [[ $(hostname) == "node1" ]]; then
    kubectl create -f /etc/kubernetes/addon/kubelet-bootstrap-secret.yml
    kubectl create -f /etc/kubernetes/addon/kubelet-bootstrap-rbac.yml
    kubectl create -f /etc/kubernetes/addon/apiserver-to-kubelet-rbac.yml
    kubectl create -f /etc/kubernetes/addon/calico-rbac.yml
    kubectl create -f /etc/kubernetes/addon/calico.yml
    kubectl create -f /etc/kubernetes/addon/kube-dns.yml
    kubectl create -f /etc/kubernetes/addon/kube-dns-autoscaler.yml
fi

echo 'Enable calico'
systemctl enable calico-node
systemctl start calico-node
