---
title: "Applying HTTPS Certificates for CDN"
date: 2018-07-24T18:35:39+08:00
menu:
  sidebar:
    name: "Applying HTTPS Certificates for CDN"
    identifier: cdn-related-https-certificate-application
    weight: 10
tags: ["DNS-01", "dehydrated", "SSL"]
categories: ["DNS-01", "dehydrated", "SSL"]
---

- [dehydrated](https://github.com/lukas2511/dehydrated)
- [letsencrypt-cloudflare-hook](https://github.com/kappataumu/letsencrypt-cloudflare-hook)

Since we cannot upload files to the CDN server, we cannot use file validation to apply for HTTPS certificates. Fortunately, Let's Encrypt supports the dns-01 challenge via DNS validation. We use Dehydrated with the CloudFlare hook to apply for HTTPS certificates.

```shell
# First clone the dehydrated repository

git clone https://github.com/lukas2511/dehydrated

# In the cloned dehydrated directory, create a config file. See the example config file:
# https://github.com/dehydrated-io/dehydrated/blob/master/docs/examples/config
# Append Cloudflare info to the end of the config file

echo "export CF_EMAIL=user@example.com" >> config
echo "export CF_KEY=K9uX2HyUjeWg5AhAb" >> config

# Clone the Cloudflare hook
mkdir hooks
git clone https://github.com/kappataumu/letsencrypt-cloudflare-hook hooks/cloudflare


# Install dependencies

pip install -r hooks/cloudflare/requirements-python-2.txt

# Create domains.txt, one domain per line

[root@db-slave01 dehydrated]# cat domains.txt
apk.kosungames.com
sp-res.kosungames.com
cpweb.kosungames.com

# Request HTTPS certificates

./dehydrated -c -k hooks/cloudflare/hook.py

# Use a Python script to upload the certificates. The script must be in the dehydrated directory.
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
