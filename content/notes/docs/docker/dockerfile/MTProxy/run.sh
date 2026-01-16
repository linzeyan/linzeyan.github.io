#!/bin/sh

set -e

curl -s https://core.telegram.org/getProxySecret -o psec
curl -s https://core.telegram.org/getProxyConfig -o plist
secret=$(head -c 16 /dev/urandom | xxd -p)
ip=$(curl http://api.ip.sb/api)
echo "tg://proxy?server=${ip}&port=443&secret=${secret}" > /tmp/link
cat /tmp/link
/usr/bin/mtproto-proxy -u nobody -p 8888 -H 443 -S ${secret} --nat-info $(hostname -i):${ip} --aes-pwd psec plist -M 1
