---
title: "openvpn部署之部署基於AD域認證"
date: 2020-09-17T13:15:33+08:00
menu:
  sidebar:
    name: "openvpn部署之部署基於AD域認證"
    identifier: linux-openvpn-pam-sssd-active-directory
    weight: 10
tags: ["URL", "Linux", "Windows", "AD", "LDAP", "VPN"]
categories: ["URL", "Linux", "Windows", "AD", "LDAP", "VPN"]
hero: images/hero/linux.png
---

- [openvpn 部署之部署基於 AD 域認證](https://www.twblogs.net/a/5b892a0b2b71775d1ce04eff)
- [OpenVPN + PAM + SSSD + Active Directory](https://jameschien.no-ip.biz/wordpress/2020/02/19/openvpn-pam-sssd-active-directory/)
- https://computingforgeeks.com/install-and-configure-openvpn-server-on-rhel-centos-8/
- https://www.redhat.com/en/blog/consistent-security-crypto-policies-red-hat-enterprise-linux-8
- https://medium.com/jerrynotes/linux-authentication-windows-ad-without-join-domain-7963c3fd44c5

```bash
# 安裝openvpn
yum install openvpn -y
yum -y install openssl openssl-devel -y
yum -y install lzo lzo-devel  -y
yum install -y libgcrypt libgpg-error libgcrypt-devel

# 安裝openvpn認證插件
yum install openvpn-auth-ldap -y

# 安裝easy-rsa
# 由於openvpn2.3之後，在openvpn裏面剔除了easy-rsa文件，所以需要單獨安裝
yum install easy-rsa
cp -rf /usr/share/easy-rsa/2.0 /etc/opevpn/

# 生成openvpn的key及證書
# 修改 `/opt/openvpn/etc/easy-rsa/2.0/vars` 參數
export KEY_COUNTRY="CN"                # 國家
export KEY_PROVINCE="ZJ"               # 省份
export KEY_CITY="NingBo"               # 城市
export KEY_ORG="TEST-VPN"              # 組織
exportKEY_EMAIL="81367070@qq.com"      # 郵件
export KEY_OU="baidu"                  # 單位

source vars
./clean-all
./build-ca
./build-dh
./build-key-server server
./build-key client1


# 編輯openvpn服務端配置文件：`/etc/openvpn/server.conf`
port 1194
proto udp
dev tun
ca keys/ca.crt
cert keys/server.crt
key keys/server.key  # This file should be kept secret
dh keys/dh2048.pem
server 10.8.0.0 255.255.255.0    //客戶端分配的ip地址
push "route 192.168.1.0 255.255.255.0"  //推送客戶端的路由
push "redirect-gateway"   //修改客戶端的網關，使其直接走vpn流量
ifconfig-pool-persist ipp.txt
keepalive 10 120
comp-lzo
persist-key
persist-tun
status openvpn-status.log
verb 3
plugin /usr/lib64/openvpn/plugin/lib/openvpn-auth-ldap.so "/etc/openvpn/auth/ldap.conf"
client-cert-not-required
username-as-common-name
log /var/log/openvpn.log


# 修改openvpn-ldap-auth的配置文件 `/etc/openvpn/auth/ldap.conf`
# /etc/openvpn/auth/ldap.conf

<LDAP>
    # LDAP server URL
    # 更改爲 AD 服務器的 IP
    URL ldap://172.16.76.238:389

    # Bind DN (If your LDAP server doesn't support anonymous binds)
    # BindDN uid=Manager,ou=People,dc=example,dc=com
    # 更改爲域管理的 DN, 可以通過 ldapsearch 進行查詢
    # -h 的 ip 替換爲服務器 ip，-D 換爲管理員的 dn，-b 爲基礎的查詢 dn，* 爲所有
    # ldapsearch -LLL -x -h 172.16.76.238 -D "administrator@xx.com" -W -b "dc=xx,dc=com" "*"
    BindDN "cn=administrator,cn=Users,dc=xx,dc=com"

    # Bind Password
    # Password SecretPassword
    # 域管理員的密碼
    Password passwd

    # Network timeout (in seconds)
    Timeout 15

    # Enable Start TLS
    TLSEnable no

    # Follow LDAP Referrals (anonymously)
    FollowReferrals no

    # TLS CA Certificate File
    # TLSCACertFile /usr/local/etc/ssl/ca.pem

    # TLS CA Certificate Directory
    # TLSCACertDir /etc/ssl/certs

    # Client Certificate and key
    # If TLS client authentication is required
    # TLSCertFile /usr/local/etc/ssl/client-cert.pem
    # TLSKeyFile /usr/local/etc/ssl/client-key.pem

    # Cipher Suite
    # The defaults are usually fine here
    # TLSCipherSuite ALL:!ADH:@STRENGTH
</LDAP>

<Authorization>
    # Base DN
    # 查詢認證的基礎 dn
    BaseDN "dc=boqii-inc,dc=com"

    # User Search Filter
    # SearchFilter "(&(uid=%u)(accountStatus=active))"
    # 其中 sAMAccountName=%u 的意思是把 sAMAccountName 的字段取值爲用戶名，
    # 後面 "memberof=CN=myvpn,DC=xx,DC=com" 指向要認證的 vpn 用戶組，
    # 這樣任何用戶使用 vpn，只要加入這個組就好了
    SearchFilter "(&(sAMAccountName=%u)(memberof=CN=myvpn,DC=boqii-inc,DC=com))"

    # Require Group Membership
    RequireGroup false

    # Add non-group members to a PF table (disabled)
    # PFTable ips_vpn_users

    <Group>
        # BaseDN "ou=Groups,dc=example,dc=com"
        # SearchFilter "(|(cn=developers)(cn=artists))"
        # MemberAttribute uniqueMember
        # Add group members to a PF table (disabled)
        # PFTable ips_vpn_eng

        BaseDN "ou=vpn,dc=boqii-inc,dc=com"
        SearchFilter "(cn=openvpn)"
        MemberAttribute "member"
    </Group>
</Authorization>

```

拷貝`/etc/openvpn/key`目錄下的`ca.crt`證書，以備客戶端使用。

注：客戶端使用 ca.crt 和客戶端配置文件即可正常使用 openvpn 了，客戶端使用方法，不在本文範圍之內

client.ovpn

```
client
dev tun
proto udp                  //注意協議，跟服務器保持一致
remote xx.xx.com 1194     //xx.xx.com替換爲你的服務器ip
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
auth-user-pass            //客戶端使用賬戶密碼登陸的選項，用於客戶端彈出認證用戶的窗口
comp-lzo
verb 3
```

---

https://github.com/Nyr/openvpn-install.git

##### 修改 `/etc/openvpn/server/server.conf` 讓 OpenVPN 支援 PAM

```
local 10.0.0.10 #主機IP
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
auth SHA512
tls-crypt tc.key
topology subnet
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 10.0.0.1"
keepalive 10 120
cipher AES-256-CBC
user nobody
group nobody
persist-key
persist-tun
status openvpn-status.log
verb 3
crl-verify crl.pem
explicit-exit-notify
plugin /usr/lib64/openvpn/plugins/openvpn-plugin-auth-pam.so login #啟用PAM驗證, 使用預設設定檔/etc/pam.d/login
```

##### 修改 Client 端的預設值, 由於用戶端要使用與主機不同網段 10.1.0.0/24 的資源故需要增加路由

`/etc/openvpn/server/client-common.txt`

```
client dev tun
proto udp
remote 1.2.3.4 1194 # 外部實體IP
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
auth SHA512
cipher AES-256-CBC
ignore-unknown-option block-outside-dns
block-outside-dns
auth-user-pass # 除了openvpn本身的金鑰驗證, 另外開啟AD使用者帳號密碼驗證
verb 3
route 10.1.0.0 255.255.255.0 10.0.0.253 # 增加通往10.1.0.0/24網斷路由, 網關為10.0.0.253
```

##### 更改完成後重新執行安裝命令產生新的 client 端 .ovpn 設定檔

`./openvpn-install.sh`

```bash
# 過程中選 Add a new user, 至於第一次產生的user設定可以選擇 Revoke an existing user
# 移除掉. 產生的 .ovpn 檔會在/root資料夾下

# 取得網域憑證伺服器的Public key ,通常會在以下位址且檔名類似
\\caserver\CertEnroll\caserver_MYDOMAIN Root Certification Authority.crt
使用cifs工具掛載目錄後 下載到centos8上並轉為PEM格式


# 掛載cifs, server2003使用smb1.0所以參數須加上vers=1.0
mount.cifs //ca_server/CertEnroll /mnt/cifs -o user=administrator,pass=password,dom=mydomain,vers=1.0
cp /mnt/cifs/xxxx.crt xxxx.crt
# 將der 轉換為 pem
openssl x509 -inform der -in xxxx.crt -out xxxx.pem
# 搬移到 trust資料夾
mv xxxx.pem /etc/pki/ca-trust/source/anchors
# 將憑證更新至主機信任憑證裡
update-ca-trust


# 設定sssd 連接 Active Directory
# 修改 `/etc/sssd/sssd.conf`


[sssd]
services = nss, pam, ssh
config_file_version = 2
domains = mydomain

[sudo]

[nss]

[pam]
offline_credentials_expiration = 60

[domain/mydomain]
cache_credentials = True
ldap_search_base = dc=mydomain,dc=com
id_provider = ldap
ldap_uri = ldaps://dc.mydomain.com:636   #AD主機, 使用ssl協定連線
ldap_schema = AD
ldap_default_bind_dn = cn=administrator,cn=users,dc= mydomain,dc=com  # 這裡為了方便使用管理員帳號, 為安全起見可以使用唯讀的網域帳號
ldap_default_authtok = password_for_administrator  # 管理員密碼
ldap_tls_reqcert = demand
ldap_tls_cacert = /etc/pki/tls/certs/ca-bundle.crt
ldap_tls_cacertdir = /etc/pki/tls/certs
ldap_search_timeout = 50
ldap_network_timeout = 60
ldap_id_mapping = True
ldap_referrals = false

enumerate = False
fallback_homedir = /home/%u
default_shell = /bin/bash


# 修改 `/etc/openlap/ldap.conf`

URI ldaps://dc.mydomain.com:636
base    dc=mydomain,dc=com
TLS_CACERT  /etc/pki/tls/certs/ca-bundle.crt
SASL_NOCANON    on


# 強制啟用sssd

authselect select sssd -force
systemctl enable --now sssd
systemctl restart sssd

# 由於Windows 2003 CA仍使用舊版SHA1, 因此需要改crypto政策
update-crypto-policies --set LEGACY


# 完成後重新開機

# 防火牆上設定允許連向1.2.3.4 UDP1194的流量並引導至內部10.0.0.10

# 用戶端安裝OpenVPN Client軟體後匯入.ovpn檔
Windows7/8/10 Client: OpenVPN-GUI (嘗試過OpenVPN Connect for Windows無法匯入.ovpn)
iOS/Android Client: OpenVPN Connect
```
