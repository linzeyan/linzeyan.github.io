FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Taipei \
    LDAP_ORG=${LDAP_ORG:-LDAP} \
    LDAP_DOMAIN=${LDAP_DOMAIN:-example.com} \
    LDAP_ADMIN_PASS=${LDAP_ADMIN_PASS:-123qwe} \
    ID=${ID:-1} \
    PROVIDER=${PROVIDER:-127.0.0.1}

RUN apt-get update \
  && apt-get install -y \
    apache2 \
    php \
    php-cgi \
    libapache2-mod-php \
    php-mbstring \
    php-common \
    php-pear \
    php-ldap \
    php7.4-fpm \
# OpenLDAP
    slapd \
    ldap-utils \
# Generate certificate
    tcl \
    expect \
    openssl \
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
  && a2enconf php7.4-fpm \
  && rm -rf /tmp/* /var/lib/apt/* \
       /var/lib/ldap/* /etc/ldap/slapd.d/cn\=config/*

COPY --chown=root:root etc/php /etc/php
COPY --chown=root:root etc/apache2 /etc/apache2
COPY --chown=openldap:openldap etc/ldap /etc/ldap
COPY usr/bin /usr/bin
ADD --chown=www-data:www-data php.tar.gz /var/www/

EXPOSE 80 389 636
CMD ["/bin/bash", "/usr/bin/run.sh"]
