#!/bin/bash
ifup eth0	啟動eth0網卡
ls  | grep ls
ls -l  | more
ll
cat dmesg
cp /var/log/dmesg  /tmp/	複製dmesg至tmp下(絕對路徑)
ll /tmp/
rm -rf /tmp/dmesg	刪除tmp下dmesg
ll /tmp/
pwd	目前所在位址
cp ./dmesg /tmp/	複製dmesg至tmp下(相對路徑)
groupadd L1
groupadd L2
cat /etc/group
useradd -m -s /bin/bash -G L1 ming	新增使用者ming於L1群組
passwd ming	設定使用者ming的密碼
cat /etc/passwd
cat /etc/group
vi /etc/group
cat /etc/passwd
cat /etc/group
history	列出下過的指令
visudo	設定使用者權限
su - ming
w
who
last
visudo
su - ming
ps -ef  列出正在運行的程序
ps -aux
ps -aux | grep ssh
ps -aux | grep java
kill -9 pid	關掉第pid號的程序
fdisk -l  列出硬碟資訊
ll /dev/sdb
fdisk /dev/sdb
mkfs -t ext4 /dev/sdb1	格式化第二顆硬碟為ext4格式
fdisk -l
mkdir /test	建立test目錄
mount
mount /dev/sdb1 /test	掛載第二顆硬碟至test目錄
mount
df /test  顯示資料夾使用情況
df -h /test
umount /test	卸載第二顆硬碟
mount
du -h /bin  顯示資料夾下檔案使用容量
du -h /dev
du -sh /dev 顯示累加資料夾下檔案使用容量
du -sh /bin
du -sh /var
mount
vi /etc/fstab
mount -a
vi /etc/fstab
mount -a
mount
shutdown -h now 立即關機

vi /etc/sysconfig/network-scripts/ifcfg-eth0	設定網卡
tar zcvf audit.tar.gz /var/log/audit	壓縮絕對路徑
tar zcvf audit.tar.gz ./audit	壓縮相對路徑
tar zxvf audit.tar.gz	解壓縮
rm -rf audit.tar.gz	強制遞迴刪除
rm -rf ./audit
yum search zip	#搜尋zip套件
yum install -y zip*	#安裝zip相依套件
yum install mysql mysql-server
service mysqld start
netstat -an | grep 3306
mysql -uroot -p

chmod +x /tmp/jdk-7u79-linux-x64.rpm	#rpm安裝軟體
ll
mkdir /usr/java
cp jdk-7u79-linux-x64.rpm /usr/java
cd
cd /usr/java/
rpm -ivh jdk-7u79-linux-x64.rpm
java -version
rpm -qa | grep jdk	#搜尋jdk
rpm -e jdk-7u79-linux-x64.rpm		#刪除jdk(java)

date
yum install ntpdate
ntpdate time.stdtime.gov.tw && hwclock -w	#校時and寫入BIOS

#排程
cat /etc/crontab
vi /etc/crontab
cat /var/log/cron
ll /sbin/ntpdate
yum search updatedb
yum install mlocate.x86_64
updatedb
locate ntpdate
vi /etc/crontab
cat /var/log/cron


cd /tmp
vi test.sh
ll
chmod +x test.sh
ll
./test.sh # echo '123' >> 1.txt
vi /etc/crontab
cat 1.txt

vi ex.sh
chmod +x ex.sh
./ex.sh a b c
./ex.sh t gg c # $#  $ $ $

vi /etc/sysconfig/iptables
service iptables reload
useradd peter$






===============================================================
VI
指令模式
yy	複製一行
dd  刪除一行
p	貼上
:set nu	顯示行數
