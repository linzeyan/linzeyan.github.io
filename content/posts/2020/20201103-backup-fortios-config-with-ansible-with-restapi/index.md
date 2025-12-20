---
title: "Backup FortiOS config with Ansible - with RestAPI"
date: 2020-11-03T17:59:24+08:00
menu:
  sidebar:
    name: "Backup FortiOS config with Ansible - with RestAPI"
    identifier: ansible-backup-fortios-config-with-ansible-with-restapi
    weight: 10
tags: ["URL", "Ansible", "FortiOS"]
categories: ["URL", "Ansible", "FortiOS"]
hero: images/hero/ansible.png
---

- [Fortigate RestAPI Config Backup - FortiOS 6.0.4](http://shogokobayashi.com/2019/02/15/fortigate-restapi-config-backup-fortios-6-0-4/)
- [Backup FortiOS config with Ansible - with RestAPI](http://shogokobayashi.com/2019/04/05/backup-fortios-config-with-ansible-with-restapi/)

##### Create access profile

```
FGTAWS0004BE1ADE # config system accprofile
FGTAWS0004BE1ADE (accprofile) # edit readOnly
new entry 'readOnly' added
FGTAWS0004BE1ADE (readOnly) # set sysgrp read
FGTAWS0004BE1ADE (readOnly) # end
```

##### Create API user in Fortigate

```
FGTAWS0004BE1ADE # config system api-user
FGTAWS0004BE1ADE (api-user) # edit api-admin
new entry 'api-admin' added
FGTAWS0004BE1ADE (api-admin) # set accprofile "readOnly"
FGTAWS0004BE1ADE (api-admin) # set vdom root
FGTAWS0004BE1ADE (api-admin) # config trusthost
FGTAWS0004BE1ADE (trusthost) # edit 1
new entry '1' added
FGTAWS0004BE1ADE (1) # set ipv4-trusthost 'ip_address_of_your_machine' 255.255.255.255
FGTAWS0004BE1ADE (1) # end
FGTAWS0004BE1ADE (api-admin) # end
```

##### Generate API token

```
FGTAWS0004BE1ADE # execute api-user generate-key api-admin
New API key: 'your_api_token'
NOTE: The bearer of this API key will be granted all access privileges assigned to the api-user api-admin.
```

##### Test

```python
# fortigate.py
import requests
import urllib3 # disable security warning for SSL certificate
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning) # disable security warning for SSL certificate


def config_download(ipaddr, api_token, filename='backup.conf'):
    '''
    input: ipaddr(string) - target ip address of fortigate
    input: api_token(string) - api_token for api user(accprofile should have sysgrp.mnt)
    input: filename(string) - file name of the config to be saved. default backup.conf
    output: True if backup successfule. False if not successful.
    Tested on: Fortigate OnDemand on AWS - FortiOS6.0.4
    '''
    base_url = f'https://{ipaddr}/api/v2/'
    headers = {'Authorization': f'Bearer {api_token}'}
    params = {'scope': 'global'}
    uri = 'monitor/system/config/backup/'

    rep = requests.get(base_url + uri, headers=headers, params=params, verify=False)

    if rep.status_code != 200:
        print(f'Something went wrong. status_code: {rep.status_code}')
        return False

    with open(filename, 'w') as f:
        f.write(rep.text)

    return True
```

```
>>> import fortigate
>>>
>>> ip_addr = 'Fortigate_IP_Address'
>>> api_token = 'API_TOKEN'
>>>
>>> if (fortigate.config_download(ip_addr, api_token, 'backup20190215.conf')):
...   print('Done!')
... else:
...   print('Error!!')
...
Done!
>>>
>>> with open('backup20190215.conf', 'r') as f:
...   f.readline()
...
'#config-version=FGTAWS-6.0.4-FW-build0231-190107:opmode=0:vdom=0:user=api-admin\n'
>>>
```

---

##### Configure Ansible inventory and playbook

```bash
$ cat hosts
[fortigate]
x.x.x.x access_token=w4q9qtfbGry3Nbc40kHjsk9mxG****
y.y.y.y access_token=tfy8c9b8Nxw6N3Q5Q5bg9z69dn****
```

```yaml
$ cat fortigate_backup.yml
  - name: fortigate config backup
    connection: local
    hosts: fortigate

    tasks:
      - name: get current config
        uri:
          url: 'https://{{ ansible_host }}/api/v2/monitor/system/config/backup/?scope=global&access_token={{ access_token }}'
          return_content: yes
          validate_certs: no
        register: current_config

      - name: write config to local file
        local_action: copy content={{ current_config.content }} dest=./{{ inventory_hostname }}_{{ ansible_date_time.date }}.txt
```
