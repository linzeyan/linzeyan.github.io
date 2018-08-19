#!/bin/bash
Ansible_Path='/home/Git_repository/ansible/host_vars/'
Target=`cat /tmp/script/list`

echo "Duplicate in list"
cat /tmp/script/list | sort -n | uniq -d -c
echo "#=======================#"
cd /home/Git_repository/ansible/host_vars
for item in $Target
do
	echo $item
	grep -r -w "$item" #$Ansible_Path
	echo "#----------#"
done
