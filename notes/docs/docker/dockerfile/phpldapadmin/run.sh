#!/bin/bash

set -e
#  && export LDAP_HOSTS=$(ping -c 1 ${LDAP_HOSTS} | awk 'NR==2{print $4}' | sed 's/:$//') \
sed -i "s/\${LDAP_HOSTS}/${LDAP_HOSTS}/g" /var/www/phpldapadmin/config/config.php
service php7.4-fpm start
/usr/sbin/apache2ctl -D FOREGROUND
