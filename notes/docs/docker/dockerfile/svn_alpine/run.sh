#!/bin/sh

set -exu

sed -i "s|\${SVN_DIR}|${SVN_DIR}|g" /etc/apache2/conf.d/subversion.conf
sed -i "s|\${LDAP_HOSTS}|${LDAP_HOSTS}|g" /etc/apache2/conf.d/subversion.conf
sed -i "s|\${LDAP_BASE_DN}|${LDAP_BASE_DN}|g" /etc/apache2/conf.d/subversion.conf
sed -i "s|\${LDAP_BIND_DN}|${LDAP_BIND_DN}|g" /etc/apache2/conf.d/subversion.conf
sed -i "s|\${LDAP_ADMIN_PASS}|${LDAP_ADMIN_PASS}|g" /etc/apache2/conf.d/subversion.conf
sed -i "s|\${AUTH_FILE}|${AUTH_FILE}|g" /etc/apache2/conf.d/subversion.conf
mkdir -p ${SVN_DIR}
touch ${SVN_DIR}/${AUTH_FILE}
chown -R apache:apache ${SVN_DIR}
chown -R apache:apache /var/www

/usr/bin/svnserve --daemon --pid-file=/run/svnserve.pid -r ${SVN_DIR}
/usr/sbin/httpd -D FOREGROUND
