---
title: "CDN 相关 https 证书的申请"
date: 2018-07-24T18:35:39+08:00
menu:
  sidebar:
    name: "CDN 相关 https 证书的申请"
    identifier: cdn-related-https-certificate-application
    weight: 10
tags: ["DNS-01", "dehydrated", "SSL"]
categories: ["DNS-01", "dehydrated", "SSL"]
---

- [dehydrated](https://github.com/lukas2511/dehydrated)
- [letsencrypt-cloudflare-hook](https://github.com/kappataumu/letsencrypt-cloudflare-hook)

由于我们不能上传文件到 CDN 服务器，所以我们不能采用文件验证方式来申请 https 证书。所幸 Let's Encrypt 支持 dns-01 challenge 通过 DNS 验证方式来申请 https 证书。我们使用 Dehydrated 配合 CloudFlare hook 来申请 https 证书。

```shell
# 首先 clone dehydrated 这个仓库

git clone https://github.com/lukas2511/dehydrated

# 在 clone 出来的 dehydrated 目录下创建 config 文件，内容参考 config 文件(https://github.com/dehydrated-io/dehydrated/blob/master/docs/examples/config)
# 在 config 文件的末尾加上 Cloudflare 相关的信息
echo "export CF_EMAIL=user@example.com" >> config
echo "export CF_KEY=K9uX2HyUjeWg5AhAb" >> config

# clone Cloudflare hook
mkdir hooks
git clone https://github.com/kappataumu/letsencrypt-cloudflare-hook hooks/cloudflare


# 安装依赖

pip install -r hooks/cloudflare/requirements-python-2.txt

# 创建 domains.txt 文件，每行一个域名

[root@db-slave01 dehydrated]# cat domains.txt
apk.kosungames.com
sp-res.kosungames.com
cpweb.kosungames.com

# 申请 https 证书

./dehydrated -c -k hooks/cloudflare/hook.py

# 使用 Python 脚本上传证书。脚本需在 dehydrated 目录下
```

```python
#!/usr/bin/env python

from aliyunsdkcore import client
from aliyunsdkcdn.request.v20141111 import SetDomainServerCertificateRequest
import uuid


def upload(domain):
  cli = client.AcsClient("LTAI7zSXga2D", "ed03Mt9xcNkRgmadx0XtpyDje", "cn-hongkong")
  request = SetDomainServerCertificateRequest.SetDomainServerCertificateRequest()
  request.set_accept_format("json")
  request.set_DomainName(domain)
  request.set_CertName(domain + str(uuid.uuid1()))
  #request.set_CertName(domain)
  #certificate = open("certs/" + domain + "/fullchain.pem").read()
  certificate = open("certs/" + domain + "/cert.pem").read()
  with open("certs/" + domain + "/chain.pem") as f:
    f.readline()
    f.readline()
    chain = f.read()
  certificate += chain
  key = open("certs/" + domain + "/privkey.pem").read()
  request.set_ServerCertificateStatus('on')
  request.set_ServerCertificate(certificate)
  request.set_PrivateKey(key)

  result = cli.do_action_with_exception(request)

domain_file="domains.txt"
with open(domain_file) as f:
  for line in f:
    domain = line.split()[0]
    upload(domain)
```
