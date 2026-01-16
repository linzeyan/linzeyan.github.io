FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Taipei \
    LDAP_HOSTS=${LDAP_HOSTS:-127.0.0.1}

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
    inetutils-ping \
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
  && rm -rf /tmp/* /var/lib/apt/*

COPY --chown=root:root etc /etc
ADD --chown=www-data:www-data php.tar.gz /var/www/
COPY run.sh /usr/bin/run.sh

EXPOSE 80

CMD ["/bin/bash", "/usr/bin/run.sh"]
