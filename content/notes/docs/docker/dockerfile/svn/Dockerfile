FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Taipei \
    LDAP_HOSTS=${LDAP_HOSTS:-127.0.0.1} \
    SVN_DIR=${SVN_DIR:-/var/svn} \
    LDAP_BASE_DN=${LDAP_BASE_DN:-dc=example,dc=com} \
    LDAP_BIND_DN=${LDAP_BIND_DN:-cn=admin} \
    LDAP_ADMIN_PASS=${LDAP_ADMIN_PASS:-123qwe} \
    AUTH_FILE=${AUTH_FILE:-accessfile}

RUN apt-get update \
  && apt-get install -y \
    apache2 \
    php \
    php-ldap \
    php-xml \
    libapache2-mod-php \
    subversion \
    subversion-tools \
    libapache2-mod-svn \
  && cd /etc/apache2/mods-enabled \
  && ln -s ../mods-available/expires.load . \
  && ln -s ../mods-available/headers.load . \
  && ln -s ../mods-available/proxy.conf . \
  && ln -s ../mods-available/proxy_fcgi.load . \
  && ln -s ../mods-available/proxy.load . \
  && ln -s ../mods-available/socache_shmcb.load . \
  && ln -s ../mods-available/ssl.conf . \
  && ln -s ../mods-available/ssl.load . \
  && rm -f /etc/apache2/sites-enabled/000-default.conf \
  && rm -f /etc/apache2/conf-enabled/charset.conf \
  && rm -f /etc/apache2/conf-enabled/localized-error-pages.conf \
  && rm -f /etc/apache2/conf-enabled/other-vhosts-access-log.conf \
  && rm -f /etc/apache2/conf-enabled/serve-cgi-bin.conf \
  && a2enmod ldap \
  && a2enmod authnz_ldap \
  && a2enmod dav_svn \
  && rm -rf /tmp/* /var/lib/apt/*

ADD --chown=www-data:www-data svnadmin-1.6.2.tar.gz /var/www/html
COPY --chown=root:root subversion.conf /etc/apache2/sites-enabled/subversion.conf
COPY run.sh /usr/bin/run.sh

EXPOSE 80

CMD ["/bin/bash", "/usr/bin/run.sh"]
