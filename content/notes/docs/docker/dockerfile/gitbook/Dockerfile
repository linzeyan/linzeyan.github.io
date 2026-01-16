FROM ubuntu:18.04
ARG NODE_VER=v12.13.0
ARG NVM_VER=v0.35.2
ENV DEBIAN_FRONTEND=noninteractive \
  PATH=${PATH}:/root/.nvm/versions/node/${NODE_VER}/bin \
  TZ=Asia/Taipei
## Install dependence packages
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      tzdata \
  && apt-get clean all \
  && rm -rf /tmp/* \
       /usr/share/doc \
       /usr/share/icons \
       /var/lib/apt/lists/*
ARG user=www
ARG home=/www
## Install NVM
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VER}/install.sh | bash \
  && . ~/.bashrc \
  && nvm install ${NODE_VER} \
  && npm install -g \
       gitbook-cli \
       npm@latest \
  && rm -rf /tmp/* \
       .nvm/.cache \
       .nvm/.git \
       .nvm/.github \
       .npm/_cacache \
  && useradd -m -d ${home} -s /bin/bash ${user} \
  && chown -R ${user}:${user} /root
USER ${user}
WORKDIR ${home}
COPY run.sh /bin/run.sh
EXPOSE 4000
CMD ["/bin/bash", "/bin/run.sh"]
