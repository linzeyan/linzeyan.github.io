# https://github.com/geerlingguy/docker-centos7-ansible
FROM centos:7
ENV container=docker

# Install systemd -- See https://hub.docker.com/_/centos/
RUN yum -y update; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*; \
# Install requirements.
 yum makecache fast \
 && yum -y install deltarpm epel-release initscripts \
 && yum -y update \
 && yum -y install \
      gcc \
      make \
      git \
      sudo \
      which \
      python-pip \
      wget \
      zlib-devel \
      bzip2-devel \
      openssl-devel \
      ncurses-devel \
      sqlite-devel \
      readline-devel \
      tk-devel \
      libffi-devel \
 && yum clean all \
 && wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tgz -O /tmp/python3.tgz \
 && tar -zxf /tmp/python3.tgz -C /tmp/ \
 && cd /tmp/Python-3.7.0/ \
 && ./configure --prefix=/usr/local/python \
 && make altinstall \
 && echo 'export PATH=$PATH:/usr/local/python/bin' >> /root/.bashrc \
 && source /root/.bashrc \
 && cd /root \
 && rm -rf /tmp/* \
 && rm -rf /root/* \
# Install Ansible via Pip.
 && pip3.7 install ansible jinja2 ansible-lint yamllint \
# Disable requiretty.
 && sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers \
# Install Ansible inventory file.
 && mkdir -p /etc/ansible && echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]
