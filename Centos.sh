#!/bin/bash
yum install -y mlocate.x86_64 epel-release nginx telnet nmap bind-utils gdisk* zip* ntpdate wget gcc jwhois
yum groupinstall -y "Development tools"
yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel
yum install -y readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel epel-release
yum install -y tcptraceroute && wget -O /usr/bin/tcpping http://www.vdberg.org/~richard/tcpping && chmod 755 /usr/bin/tcpping
yum  install -y lrzsz gcc-c++  make man vim unzip wget curl lua-devel lua-static patch libxml2-devel libxslt libxslt-devel gd gd-devel ntp ntpdate screen sysstat tree rsync lsof openssh-clients telnet htop libselinux-python


