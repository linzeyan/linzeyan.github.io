FROM alpine:3.12

ENV TZ=Asia/Taipei \
    LDAP_HOSTS=${LDAP_HOSTS:-127.0.0.1} \
    SVN_DIR=${SVN_DIR:-/var/svn} \
    LDAP_BASE_DN=${LDAP_BASE_DN:-dc=example,dc=com} \
    LDAP_BIND_DN=${LDAP_BIND_DN:-cn=admin} \
    LDAP_ADMIN_PASS=${LDAP_ADMIN_PASS:-123qwe} \
    AUTH_FILE=${AUTH_FILE:-accessfile}

RUN apk add --no-cache subversion \
  && apk add --no-cache \
    apache2 \
    apache2-ldap \
    apache2-utils \
    apache2-webdav \
    mod_dav_svn \
  && apk add --no-cache \
    php7 \
    php7-ldap \
    php7-json \
    php7-session \
    php7-apache2 \
  && apk add --no-cache \
    php7-xml \
  && sed -i 's@;extension=ldap@extension=ldap@' /etc/php7/php.ini \
  && sed -i 's@ErrorLog logs/error.log@ErrorLog /dev/stderr@g' /etc/apache2/httpd.conf \
  && sed -i 's@CustomLog logs/access.log combined@CustomLog /dev/stdout combined@g' /etc/apache2/httpd.conf \
  && sed -i -e 's/^root::/root:!:/' /etc/shadow \
  && rm -rf /etc/apk/cache
#  && sed -i 's@modules\/@\/usr\/lib\/apache2\/@g' /etc/apache2/httpd.conf

ADD --chown=apache:apache svnadmin-1.6.2.tar.gz /var/www/localhost/htdocs/
COPY --chown=root:root subversion.conf /etc/apache2/conf.d/subversion.conf
COPY run.sh /bin/run.sh

EXPOSE 80

CMD ["/bin/sh", "/bin/run.sh"]
