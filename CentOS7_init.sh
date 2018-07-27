#!/bin/bash
yum upgrade -y
yum install -y  epel-release && yum install -y mlocate.x86_64 nmap bind-utils gdisk* zip* ntpdate wget whois ansible lrzsz make man vim jq python-pip
yum groupinstall -y "Development tools"
yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel lua-devel lua-static patch libxml2-devel libxslt libxslt-devel gd gd-devel ntpscreen sysstat tree rsync lsof openssh-clients gcc gcc-c++ htop libselinux-python 
yum install -y tcptraceroute && wget -O /usr/bin/tcpping http://www.vdberg.org/~richard/tcpping && chmod 755 /usr/bin/tcpping
pip install ansible-lint

cat << EOF >> /etc/crontab
1 * * * * root ntpdate 1.tw.pool.ntp.org
EOF

cat << EOF > /etc/selinux/config
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=disabled
# SELINUXTYPE= can take one of three two values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected.
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
EOF

yum remove docker docker-common container-selinux docker-selinux docker-engine docker-engine-selinux
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum makecache fast
yum install -y docker-ce
systemctl enable docker
curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
rpm -U http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-2.noarch.rpm && yum install -y git
cat <<EOF>>/root/.bashrc
export PS1="\[\e[35;1m\][\[\e[31;1m\]\u\[\e[35;1m\]@\[\e[33;1m\]\h \[\e[32;1m\]\w \[\e[33;1m\]\t\[\e[35;1m\]&&\[\e[36;1m\]\#\[\e[35;1m\]]\[\e[34;1m\]\$\[\e[m\]"
EOF
cat <<EOF>/etc/hostname
Ricky
EOF
hostname Ricky
