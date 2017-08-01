#!/bin/bash
ifup eth0	#啟動eth0網卡
ls  | grep ls
ls -l  | more
ll
cat dmesg
cp /var/log/dmesg  /tmp/	#複製dmesg至tmp下(絕對路徑)
ll /tmp/
rm -rf /tmp/dmesg	#刪除tmp下dmesg
ll /tmp/
pwd	目前所在位址
cp ./dmesg /tmp/	#複製dmesg至tmp下(相對路徑)
groupadd L1
groupadd L2
cat /etc/group
useradd -m -s /bin/bash -G L1 ming	#新增使用者ming於L1群組
passwd ming	#設定使用者ming的密碼
cat /etc/passwd
cat /etc/group
vi /etc/group
cat /etc/passwd
cat /etc/group
history	#列出下過的指令
visudo	#設定使用者權限
su - ming
w
who
whoami
last
visudo
su - ming
ps -ef  #列出正在運行的程序
ps -aux
ps -aux | grep ssh
ps -aux | grep java
kill -9 pid	#關掉第pid號的程序
fdisk -l  #列出硬碟資訊
ll /dev/sdb #查看有無掛載
fdisk /dev/sdb #寫入格式化硬碟資訊，m。n，add a new partition；p，primary partition；else default。m，w，write table to disk and exit。
mkfs -t ext4 /dev/sdb1	#格式化
fdisk -l  #查看是否格式化完成並掛載
mkdir /test	#建立test目錄
mount
mount /dev/sdb1 /test	#掛載第二顆硬碟至test目錄
mount #查看是否掛載到目錄
df /test  #顯示資料夾free space
df -h /test
umount /test	#卸載第二顆硬碟
mount
du -h /bin  #顯示資料夾下檔案使用容量
du -h /dev
du -sh /dev #顯示累加資料夾下檔案使用容量
du -sh /bin
du -sh /var
mount
vi /etc/fstab #建立預設開機掛載
mount -a
vi /etc/fstab
mount -a
mount
shutdown -h now #立即關機

vi /etc/sysconfig/network-scripts/ifcfg-eth0	#設定網卡
tar zcvf audit.tar.gz /var/log/audit	#壓縮絕對路徑，-z gz、-c create、-v verbose、-f file
tar zcvf audit.tar.gz ./audit	#壓縮相對路徑
tar zxvf audit.tar.gz	#解壓縮，-z gz、-x 解壓、-v verbose、-f file
rm -rf audit.tar.gz	#強制遞迴刪除
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
rpm -ivh jdk-7u79-linux-x64.rpm #-i install、-v verbose、-h human mode、--force強制
java -version
rpm -qa | grep jdk	#查詢jdk
rpm -e jdk-7u79-linux-x64.rpm		#刪除jdk(java)

date
yum install ntpdate
ntpdate time.stdtime.gov.tw && hwclock -w	#校時and寫入BIOS

#排程
#*/5 * * * * 使用者 指令
#每5分鐘      root 絕對路徑
cat /etc/crontab
vi /etc/crontab
cat /var/log/cron
ll /sbin/ntpdate
yum search updatedb
yum install mlocate.x86_64
updatedb
locate ntpdate
vi /etc/crontab
cat /var/log/cron #驗證排程


cd /tmp
vi test.sh
ll
chmod +x test.sh
ll
./test.sh # echo '123' >> 1.txt； > 清除再寫入； >> 不斷寫入
vi /etc/crontab
cat 1.txt

vi ex.sh
chmod +x ex.sh
./ex.sh a b c
./ex.sh t gg c # $#  $ $ $

vi /etc/sysconfig/iptables
service iptables reload
useradd peter$



/etc/ssh/sshd_config # #Port 22，拿掉#可更改port
/etc/sysconfig/iptables # -A INPUT -m state --state NEW -m tcp -p tcp --dport 要改的PORT -j ACCEPT
service iptables reload
service sshd restart
/etc/init.d/network restart

netstat -tulpn



chmod 777 * #修改目錄下所有的資料夾屬性，把資料夾名稱用*來代替就可以了
chmod -R 777 /upload  #要修改資料夾內所有的檔和資料夾及子資料夾屬性為可寫可讀可執行

#!/bin/bash
nowa=$(date +"%Y%m%d%h%m%s")"a"
nowb=$(date +"%Y%m%d%h%m%s")"b"
nowc=$(date +"%Y%m%d%h%m%s")"c"
FILEa="$nowa.tar.gz"
FILEb="$nowb.tar.gz"
FILEb="$nowb.tar.gz"
tar zcvf "$FILEa" /var/log
tar zcvf "$FILEb" /var/log
tar zcvf "$FILEc" /var/log

#!/bin/bash
for char in a b c
do
now=$(date +"%Y%m%d%H%M%S")$char
FILE="$now.tar.gz"
tar zcvf "$FILE" /var/log
done

rm -rf ./*a.tar.gz

===============================================================
VI
指令模式
yy	複製一行
dd  刪除一行
p	貼上
:set nu	顯示行數
/ 搜尋
