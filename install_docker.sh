#!/bin/bash
# ubuntu 14. LTS
#------------------------------------------------------------
# system update and install some tools
#------------------------------------------------------------
sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade
sudo apt-get install  -y \
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
#------------------------------------------------------------
# install docker and remove temmp files
#------------------------------------------------------------
curl -sSL https://get.docker.com/ | sudo sh \
sudo apt-get update
sudo apt-get upgrade
rm -rf /tmp/* \
#------------------------------------------------------------
# recognize docker is running and pull rstudio image
#------------------------------------------------------------
sudo service docker start
sudo docker pull zeyanlin/rstudio:latest
