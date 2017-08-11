#!/bin/bash
yum install -y mlocate.x86_64 epel-release nginx telnet nmap bind-utils gdisk* zip* ntpdate wget gcc
yum groupinstall -y "Development tools"
yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel
yum install -y readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel epel-release
