FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Taipei

COPY --chown=root:root install.sh /tmp/install.sh
RUN apt-get update \
  && apt-get install -y curl \
  && /bin/bash /tmp/install.sh \
  && rm -rf /var/lib/apt /tmp/*

EXPOSE 53/udp 53/tcp 5380

CMD ["/usr/bin/dotnet","/etc/dns/DnsServerApp.dll"]
