---
title: "Python install module issues"
date: 2020-03-04T15:43:38+08:00
menu:
  sidebar:
    name: "Python install module issues"
    identifier: python-pip-install-requirements-issues
    weight: 10
tags: ["URL", "Python", "pip", "issue"]
categories: ["URL", "Python", "pip", "issue"]
hero: images/hero/python.png
---

- [I can't install python-ldap](https://stackoverflow.com/questions/4768446/i-cant-install-python-ldap)

#### python-ldap

> https://www.python-ldap.org/en/latest/installing.html

```shell
$ pip install python-ldap
In file included from Modules/LDAPObject.c:9:


Modules/errors.h:8: fatal error: lber.h: No such file or directory
```

- Debian/Ubuntu:
  `sudo apt-get install libsasl2-dev python-dev libldap2-dev libssl-dev`

- RedHat/CentOS:

```shell
sudo yum install python-devel openldap-devel
sudo yum groupinstall "Development tools"
```

#### molecule

```shell
$ pip install molecule
error: command 'gcc' failed with exit status 1


    ----------------------------------------
Command "/usr/bin/python2 -u -c "import setuptools, tokenize;__file__='/tmp/pip-install-I5DGC3/psutil/setup.py';f=getattr(tokenize, 'open', open)(__file__);code=f.read().replace('\r\n', '\n');f.close();exec(compile(code, __file__, 'exec'))" install --record /tmp/pip-record-Fy7V4X/install-record.txt --single-version-externally-managed --compile" failed with error code 1 in /tmp/pip-install-I5DGC3/psutil/
```

- RedHat/CentOS:

```shell
yum -y install gcc gcc-c++ kernel-devel
yum -y install python-devel libxslt-devel libffi-devel openssl-devel
```

#### ansible

```shell
$ pip install ansible
ImportError: No module named pkg_resources
```

```shell
yum install -y python-setuptools
```

---

#### `import pandas`

```shell
ModuleNotFoundError: No module named '_bz2'

```

```shell
apt-get install -y libbz2-dev
yum install -y bzip2-devel
```

#### `from .cv2 import *`

```shell
ImportError: libSM.so.6: cannot open shared object file: No such file or directory
ImportError: libXrender.so.1: cannot open shared object file: No such file or directory
ImportError: libXext.so.6: cannot open shared object file: No such file or directory
```

- Ubuntu:

```shell
apt-get install libsm6
apt-get install libxrender1
apt-get install libxext-dev
```

- CentOS:

```shell
yum install libSM
yum install libXrender-devel
yum install libXext
```
