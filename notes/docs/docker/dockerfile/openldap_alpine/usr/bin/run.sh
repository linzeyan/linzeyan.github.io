#!/bin/bash

set -eux
chmod -R 755 /usr/bin
set -e
echo 'Generate variables'
sed -i "s/\${LDAP_DOMAIN}/${LDAP_DOMAIN}/g" /usr/bin/servercsr.et
domain=($(echo ${LDAP_DOMAIN} | sed 's/\./ /g'))
LDAP_DC=${domain[$(( ${#domain[@]} - 2 ))]}

LDAP_DOMAIN=''
for (( i=0 ; i < ${#domain[@]} ; i++ ))
do
  LDAP_DOMAIN="${LDAP_DOMAIN}dc=${domain[$i]},"
done
LDAP_DOMAIN=$(echo ${LDAP_DOMAIN} | sed 's/,$//')
sleep 1

echo 'Replace variables with value'
sed -i "s/\${LDAP_ORG}/${LDAP_ORG}/g" /etc/openldap/slapd.conf /etc/openldap/domain.ldif
sed -i "s/\${LDAP_DOMAIN}/${LDAP_DOMAIN}/g" /etc/openldap/slapd.conf /etc/openldap/domain.ldif
sed -i "s/\${LDAP_ADMIN_PASS}/${LDAP_ADMIN_PASS}/g" /etc/openldap/slapd.conf /etc/openldap/domain.ldif
sed -i "s/\${LDAP_DC}/${LDAP_DC}/g" /etc/openldap/slapd.conf /etc/openldap/domain.ldif
sed -i "s/\${ID}/${ID}/g" /etc/openldap/slapd.conf
sed -i "s/\${PROVIDER}/${PROVIDER}/g" /etc/openldap/slapd.conf
sleep 1

echo 'Generate certificates'
mkdir -p /etc/openldap/certs
cd /etc/openldap/certs
generate.sh
sleep 1

echo 'Clean files'
cp /etc/openldap/DB_CONFIG /DB_CONFIG
rm -rf /var/lib/openldap/* /etc/openldap/slapd.d/cn\=config/*
cp /DB_CONFIG /var/lib/openldap/DB_CONFIG
cp /DB_CONFIG /etc/openldap/DB_CONFIG
mkdir -p /etc/openldap/slapd.d
chown -R ldap:ldap /var/lib/openldap/ /etc/openldap/
echo 'Generate configs'
slaptest -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d/ || true
echo 'Ensure permissions'
chown -R ldap:ldap /var/lib/openldap/ /etc/openldap/
chown -R root:root /etc/php7 /etc/nginx
chown -R nginx:nginx /www
sleep 1

echo 'Start service'
/usr/sbin/slapd -h "ldaps:/// ldap:///" -g ldap -u ldap -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d
php-fpm7 -D
chown nginx:nginx /run/php-fpm.sock
sleep 1
echo 'Create DN'
ldapadd -axw ${LDAP_ADMIN_PASS} -D "cn=admin,${LDAP_DOMAIN}" -f /etc/openldap/domain.ldif
sleep 1
#echo 'Enable TLS'
#ldapmodify -Y EXTERNAL -H ldapi:/// -f /etc/openldap/tls.ldif
#sleep 1
echo 'Restart LDAP service'
killall -9 slapd
sleep 1
/usr/sbin/slapd -h "ldap:/// ldaps:///" -g ldap -u ldap -F /etc/openldap/slapd.d -f /etc/openldap/slapd.conf
/usr/sbin/nginx -c /etc/nginx/nginx.conf
