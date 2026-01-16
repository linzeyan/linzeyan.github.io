FROM alpine:3.12

ENV TZ=Asia/Taipei \
    LDAP_ORG=${LDAP_ORG:-LDAP} \
    LDAP_DOMAIN=${LDAP_DOMAIN:-example.com} \
    LDAP_ADMIN_PASS=${LDAP_ADMIN_PASS:-123qwe} \
    ID=${ID:-1} \
    PROVIDER=${PROVIDER:-127.0.0.1}

RUN apk add --no-cache bash \
  && apk add --no-cache nginx \
  && apk add --no-cache \
    php7 \
    php7-cgi \
    php7-common \
    php7-fpm \
    php7-gettext \
    php7-json \
    php7-ldap \
    php7-mbstring \
    php7-pear \
    php7-session \
  && apk add --no-cache \
    php7-xml \
  && apk add --no-cache \
# OpenLDAP
    openldap \
    openldap-back-bdb \
    openldap-back-dnssrv \
    openldap-back-ldap \
    openldap-back-meta \
    openldap-back-null \
    openldap-back-passwd \
    openldap-back-relay \
    openldap-back-shell \
    openldap-back-sock \
    openldap-backend-all \
    openldap-clients \
    openldap-overlay-all \
# Generate certificate
    tcl \
    expect \
    openssl \
  && sed -i -e 's/^root::/root:!:/' /etc/shadow \
  && rm -rf /etc/openldap/slapd.d/cn\=config/* \
  && rm -rf /etc/apk/cache


COPY --chown=root:root etc/php7 /etc/php7
COPY --chown=root:root etc/nginx /etc/nginx
COPY --chown=ldap:ldap etc/ldap /etc/openldap
COPY usr/bin /usr/bin
ADD --chown=nginx:nginx php.tar.gz /www/

EXPOSE 80 389 636

CMD ["/bin/bash", "/usr/bin/run.sh"]
