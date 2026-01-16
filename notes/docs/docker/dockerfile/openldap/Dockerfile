FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Taipei \
    LDAP_ORG=${LDAP_ORG:-LDAP} \
    LDAP_DOMAIN=${LDAP_DOMAIN:-example.com} \
    LDAP_ADMIN_PASS=${LDAP_ADMIN_PASS:-123qwe}

RUN apt-get update \
  && apt-get install -y \
    slapd \
    ldap-utils \
# Generate certificate
    tcl \
    expect \
    openssl \
# Listen port
    netcat \
  && apt-get clean \
  && rm -rf /tmp/* /var/lib/apt/* \
       /var/lib/ldap/* /etc/ldap/slapd.d/cn\=config/*

COPY --chown=openldap:openldap etc /etc
COPY --chown=root:root usr /usr
EXPOSE 389 636
CMD ["/bin/bash", "/usr/bin/run.sh"]
