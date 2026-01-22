---
title: "Deploying OpenVPN with AD domain authentication"
date: 2020-09-17T13:15:33+08:00
menu:
  sidebar:
    name: "Deploying OpenVPN with AD domain authentication"
    identifier: linux-openvpn-pam-sssd-active-directory
    weight: 10
tags: ["Links", "Linux", "Windows", "AD", "LDAP", "VPN"]
categories: ["Links", "Linux", "Windows", "AD", "LDAP", "VPN"]
hero: images/hero/linux.png
---

- [Deploying OpenVPN with AD domain authentication](https://www.twblogs.net/a/5b892a0b2b71775d1ce04eff)
- [OpenVPN + PAM + SSSD + Active Directory](https://jameschien.no-ip.biz/wordpress/2020/02/19/openvpn-pam-sssd-active-directory/)
- https://computingforgeeks.com/install-and-configure-openvpn-server-on-rhel-centos-8/
- https://www.redhat.com/en/blog/consistent-security-crypto-policies-red-hat-enterprise-linux-8
- https://medium.com/jerrynotes/linux-authentication-windows-ad-without-join-domain-7963c3fd44c5

```bash
# Install OpenVPN
yum install openvpn -y
yum -y install openssl openssl-devel -y
yum -y install lzo lzo-devel  -y
yum install -y libgcrypt libgpg-error libgcrypt-devel

# Install OpenVPN auth plugin
yum install openvpn-auth-ldap -y

# Install easy-rsa
# Since openvpn 2.3 removed easy-rsa from the package, install it separately.
yum install easy-rsa
cp -rf /usr/share/easy-rsa/2.0 /etc/opevpn/

# Generate OpenVPN keys and certificates
# Edit `/opt/openvpn/etc/easy-rsa/2.0/vars` parameters
export KEY_COUNTRY="CN"                # Country
export KEY_PROVINCE="ZJ"               # Province
export KEY_CITY="NingBo"               # City
export KEY_ORG="TEST-VPN"              # Organization
exportKEY_EMAIL="81367070@qq.com"      # Email
export KEY_OU="baidu"                  # Unit

source vars
./clean-all
./build-ca
./build-dh
./build-key-server server
./build-key client1


# Edit the OpenVPN server config: `/etc/openvpn/server.conf`
port 1194
proto udp
dev tun
ca keys/ca.crt
cert keys/server.crt
key keys/server.key  # This file should be kept secret
dh keys/dh2048.pem
server 10.8.0.0 255.255.255.0    // client IP pool
push "route 192.168.1.0 255.255.255.0"  // push route to clients
push "redirect-gateway"   // change client gateway to route VPN traffic
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


# Edit openvpn-ldap-auth config: `/etc/openvpn/auth/ldap.conf`
# /etc/openvpn/auth/ldap.conf

<LDAP>
    # LDAP server URL
    # Change to the AD server IP
    URL ldap://172.16.76.238:389

    # Bind DN (If your LDAP server doesn't support anonymous binds)
    # BindDN uid=Manager,ou=People,dc=example,dc=com
    # Change to the domain admin DN; you can query it with ldapsearch
    # Replace the IP in -h with the server IP, -D with the admin DN, -b with the base DN, and * for all
    # ldapsearch -LLL -x -h 172.16.76.238 -D "administrator@xx.com" -W -b "dc=xx,dc=com" "*"
    BindDN "cn=administrator,cn=Users,dc=xx,dc=com"

    # Bind Password
    # Password SecretPassword
    # Domain admin password
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
    # Base DN for auth search
    BaseDN "dc=boqii-inc,dc=com"

    # User Search Filter
    # SearchFilter "(&(uid=%u)(accountStatus=active))"
    # sAMAccountName=%u uses the sAMAccountName value as the username,
    # and "memberof=CN=myvpn,DC=xx,DC=com" points to the VPN user group to authenticate,
    # so any user can use VPN once they are in this group.
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

Copy the `ca.crt` certificate under `/etc/openvpn/key` for client use.

Note: the client can use OpenVPN with ca.crt and the client configuration file. Client usage is out of scope here.

client.ovpn

```
client
dev tun
proto udp                  // protocol must match the server
remote xx.xx.com 1194     // replace with your server IP
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
auth-user-pass            // enable username/password auth prompt
comp-lzo
verb 3
```

---

https://github.com/Nyr/openvpn-install.git

##### Edit `/etc/openvpn/server/server.conf` to enable PAM for OpenVPN

```
local 10.0.0.10 # host IP
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
plugin /usr/lib64/openvpn/plugins/openvpn-plugin-auth-pam.so login # enable PAM auth using default profile /etc/pam.d/login
```

##### Update client defaults. Since clients need access to a different subnet (10.1.0.0/24), add a route.

`/etc/openvpn/server/client-common.txt`

```
client dev tun
proto udp
remote 1.2.3.4 1194 # public IP
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
auth SHA512
cipher AES-256-CBC
ignore-unknown-option block-outside-dns
block-outside-dns
auth-user-pass # enable AD username/password auth in addition to OpenVPN keys
verb 3
route 10.1.0.0 255.255.255.0 10.0.0.253 # add route to 10.1.0.0/24 via gateway 10.0.0.253
```

##### After changes, rerun the install script to generate a new client .ovpn file

`./openvpn-install.sh`

```bash
# During the process choose Add a new user. You can choose Revoke an existing user
# to remove the first one. The .ovpn file will be in /root.

# Get the domain CA public key. It is usually at the path below with a similar name
\\caserver\CertEnroll\caserver_MYDOMAIN Root Certification Authority.crt
Mount the share with cifs, download to CentOS 8, and convert to PEM.


# Mount CIFS; Server 2003 uses SMB 1.0 so add vers=1.0
mount.cifs //ca_server/CertEnroll /mnt/cifs -o user=administrator,pass=password,dom=mydomain,vers=1.0
cp /mnt/cifs/xxxx.crt xxxx.crt
# Convert der to pem
openssl x509 -inform der -in xxxx.crt -out xxxx.pem
# Move to the trust store directory
mv xxxx.pem /etc/pki/ca-trust/source/anchors
# Update the trusted certificates
update-ca-trust


# Configure sssd to connect to Active Directory
# Edit `/etc/sssd/sssd.conf`


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
ldap_uri = ldaps://dc.mydomain.com:636   # AD host, connect via SSL
ldap_schema = AD
ldap_default_bind_dn = cn=administrator,cn=users,dc= mydomain,dc=com  # using admin for convenience; use a read-only domain account for safety
ldap_default_authtok = password_for_administrator  # admin password
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


# Edit `/etc/openlap/ldap.conf`

URI ldaps://dc.mydomain.com:636
base    dc=mydomain,dc=com
TLS_CACERT  /etc/pki/tls/certs/ca-bundle.crt
SASL_NOCANON    on


# Force enable sssd

authselect select sssd -force
systemctl enable --now sssd
systemctl restart sssd

# Since Windows 2003 CA still uses SHA1, change crypto policy
update-crypto-policies --set LEGACY


# Reboot after completion

# Configure firewall to allow UDP 1194 to 1.2.3.4 and forward to internal 10.0.0.10

# Install OpenVPN Client and import .ovpn
Windows7/8/10 Client: OpenVPN-GUI (OpenVPN Connect for Windows could not import .ovpn)
iOS/Android Client: OpenVPN Connect
```
