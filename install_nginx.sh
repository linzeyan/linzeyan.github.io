#!/bin/bash
# centos 6.8
# root
#------------------------------------------------------------
# install packages for example :
# yum grouplist
# yum groupinfo "Development Tools"
# yum groupinstall "Development Tools"
#------------------------------------------------------------
#------------------------------------------------------------
# 設定工作排程，讓 centOS 可以每天自動更新系統
# 使用 crontab -e ，或 vi /etc/crontab ，
# 40 5 * * * root yum -y update && yum clean packages
# 每天 5:40 ，自動更新完成後會主動的將下載的套件資料移除
#------------------------------------------------------------
yum -y update && yum clean packages
#------------------------------------------------------------
# install nginx
#------------------------------------------------------------
yum install -y --no-install-recommends \
  epel-release  \
  nginx \
  telnet \
  nmap
  && yum clean packages
#------------------------------------------------------------
# service start and open 80 port
#------------------------------------------------------------
/etc/init.d/nginx start
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
