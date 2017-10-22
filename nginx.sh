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
# */5 * * * * root /sbin/ntpdate time.stdtime.gov.tw && /sbin/hwclock -w
# 每5分鐘校時一次，並寫入BIOS
#------------------------------------------------------------
ntpdate time.stdtime.gov.tw && hwclock -w
yum -y update && yum clean packages
yum groupinstall -y "Development Tools"
#------------------------------------------------------------
# install nginx
#------------------------------------------------------------
yum install -y epel-release nginx telnet nmap bind-utils mysql mysql-server gdisk* zip* ntpdate mlocate.x86_64 python-pip* wget && yum clean packages 
#------------------------------------------------------------
# service start and open 80 port
#------------------------------------------------------------
/etc/init.d/nginx start
#開80 port：
iptables -I INPUT -p tcp --dport 80 -j ACCEPT && service iptables save
#------------------------------------------------------------
# 編輯 NGINX 設定檔，例: nginx.conf
# ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
#------------------------------------------------------------

