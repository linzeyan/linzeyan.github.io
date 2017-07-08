#!/bin/bash

sudo apt-get update \
  && sudo apt-get upgrade \
  && sudo apt-get dist-upgrade \
  && sudo apt-get install  -y --no-install-recommends \
  ssh \
  bridge-utils \
  uml-utilities \
  file \
  git \
  libapparmor1 \
  libcurl4-openssl-dev \
  libedit2 \
  libssl-dev \
  lsb-release \
  psmisc \
  python-setuptools \
  sudo \
  wget \  
  && curl -sSL https://get.docker.com/ | sudo sh \
  && sudo apt-get update \
  && sudo apt-get upgrade \
  && rm -rf /tmp/*

sudo service docker start
sudo docker pull zeyanlin/rstudio:latest
sudo docker run -d --name Rstudio -p 8787:8787 zeyanlin/rstudio:latest
