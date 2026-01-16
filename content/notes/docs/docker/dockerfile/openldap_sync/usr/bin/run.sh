#!/bin/bash

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
sed -i "s/\${LDAP_ORG}/${LDAP_ORG}/g" /etc/ldap/slapd.conf /etc/ldap/domain.ldif
sed -i "s/\${LDAP_DOMAIN}/${LDAP_DOMAIN}/g" /etc/ldap/slapd.conf /etc/ldap/domain.ldif
sed -i "s/\${LDAP_ADMIN_PASS}/${LDAP_ADMIN_PASS}/g" /etc/ldap/slapd.conf /etc/ldap/domain.ldif
sed -i "s/\${LDAP_DC}/${LDAP_DC}/g" /etc/ldap/slapd.conf /etc/ldap/domain.ldif
sed -i "s/\${ID}/${ID}/g" /etc/ldap/slapd.conf
sed -i "s/\${PROVIDER}/${PROVIDER}/g" /etc/ldap/slapd.conf
sleep 1

echo 'Generate certificates'
mkdir -p /etc/ldap/certs
cd /etc/ldap/certs
generate.sh
sleep 1

echo 'Clean files'
cp /etc/ldap/DB_CONFIG /DB_CONFIG
rm -rf /var/lib/ldap/* /etc/ldap/slapd.d/cn\=config/*
cp /DB_CONFIG /var/lib/ldap/DB_CONFIG
cp /DB_CONFIG /etc/ldap/DB_CONFIG
chown -R openldap:openldap /var/lib/ldap/ /etc/ldap/
echo 'Generate configs'
slaptest -f /etc/ldap/slapd.conf -F /etc/ldap/slapd.d/ || true
echo 'Ensure permissions'
chown -R openldap:openldap /var/lib/ldap/ /etc/ldap/
chown -R root:root /etc/php /etc/apache2
chown -R www-data:www-data /var/www
sleep 1

echo 'Start service'
service slapd start
service php7.4-fpm start
sleep 1
echo 'Create DN'
ldapadd -axw ${LDAP_ADMIN_PASS} -D "cn=admin,${LDAP_DOMAIN}" -f /etc/ldap/domain.ldif
sleep 1
#echo 'Enable TLS'
#ldapmodify -Y EXTERNAL -H ldapi:/// -f /etc/ldap/tls.ldif
#sleep 1
echo 'Restart LDAP service'
killall -9 slapd
sleep 1
/usr/sbin/slapd -h "ldapi:/// ldap:/// ldaps:///" -g openldap -u openldap #-F /etc/ldap/slapd.d -f /etc/ldap/slapd.conf
/usr/sbin/apache2ctl -D FOREGROUND
