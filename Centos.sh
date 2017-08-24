#!/bin/bash
yum install -y mlocate.x86_64 epel-release nginx telnet nmap bind-utils gdisk* zip* ntpdate wget gcc jwhois
yum groupinstall -y "Development tools"
yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel
yum install -y readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel epel-release
#1 rpm -ivh ftp://195.220.108.108/linux/dag/redhat/el7/en/x86_64/dag/RPMS/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm
#2 yum -y install tcptraceroute
#3 cd /usr/bin
#4 wget http://www.vdberg.org/~richard/tcpping
#5 chmod 755 tcpping

