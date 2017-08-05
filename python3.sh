#!/bin/bash
# 为了防止出错，先安装编译python的组件gcc等
yum install -y gcc
yum groupinstall -y "Development tools"
# 安装依赖包
yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel \ 
  readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel wget
# 安装 Python 3
# 创建安装目录
sudo mkdir /usr/local/python3 
# 下载 Python 源文件，注意：wget获取https的时候要加上：--no-check-certificate
cd /tmp
wget --no-check-certificate https://www.python.org/ftp/python/3.6.0/Python-3.6.0.tgz
# 解压缩包
tar -xzvf Python-3.6.0.tgz 
# 进入解压目录
cd Python-3.6.0 
# 指定创建的目录
sudo ./configure --prefix=/usr/local/python3 
sudo make
sudo make install
# 创建 python3 的软链接，这样就可以通过 python 命令使用 Python 2，python3 来使用 Python 3。
sudo ln -s /usr/local/python3/bin/python3 /usr/bin/python3
# 安装 pip
# 首先安装 epel 扩展源
sudo yum -y install epel-release
# 安装 python-pip
sudo yum -y install python-pip
# 清除 cache
sudo yum clean all
# 下载源代码
cd /tmp
wget --no-check-certificate https://github.com/pypa/pip/archive/9.0.1.tar.gz
# 解压文件
tar -zvxf 9.0.1.tar.gz
cd pip-9.0.1
# 使用 Python 3 安装
python3 setup.py install
# 创建链接
sudo ln -s /usr/local/python3/bin/pip /usr/bin/pip3
# 升级 pip
pip install --upgrade pip
# 
pip3 install python-telegram-bot











