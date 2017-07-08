#!/bin/bash

sudo apt-get update \
  && sudo apt-get upgrade \
  && sudo apt-get dist-upgrade \
  && sudo apt-get install ssh \
                          bridge-utils \
                          uml-utilities \
  && curl -sSL https://get.docker.com/ | sudo sh \
  && sudo apt-get update \
  && sudo apt-get upgrade \

sudo service docker start
sudo docker pull zeyanlin/rstudio:latest
sudo docker run -d --name Rstudio -p 8787:8787 zeyanlin/rstudio:latest
