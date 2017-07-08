sudo apt-get update \
  && sudo apt-get upgrade \
  && sudo apt-get dist-upgrade \
  && sudo apt-get install ssh \
                          bridge-utils \
                          uml-utilities \
  && curl -sSL https://get.docker.com/ | sudo sh \
  && sudo apt-get update \
  && sudo apt-get upgrade \
