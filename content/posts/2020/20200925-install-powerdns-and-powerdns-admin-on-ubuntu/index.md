---
title: "Install PowerDNS and PowerDNS-Admin on Ubuntu 22.04|20.04|18.04"
date: 2020-09-25T09:38:17+08:00
menu:
  sidebar:
    name: "Install PowerDNS and PowerDNS-Admin on Ubuntu 22.04|20.04|18.04"
    identifier: linux-install-powerdns-and-powerdns-admin-on-ubuntu
    weight: 10
tags: ["URL", "DNS", "Linux", "PowerDNS"]
categories: ["URL", "DNS", "Linux", "PowerDNS"]
hero: images/hero/linux.png
---

- [Install PowerDNS and PowerDNS-Admin on Ubuntu 22.04|20.04|18.04](https://computingforgeeks.com/install-powerdns-and-powerdns-admin-on-ubuntu/)
- [Master-Master PowerDNS with Galera Replication](https://blog.zswap.net/master-master-powerdns-with-galera-replication/)
- [https://www.scaleway.com/en/docs/installing-powerdns-server-on-ubuntu-bionic/](https://www.scaleway.com/en/docs/installing-powerdns-server-on-ubuntu-bionic/)

#### Install PowerDNS

```shell
$ sudo apt update
$ sudo apt install mariadb-server -y

$ sudo mysql -u root
```

```sql
CREATE DATABASE powerdns;
GRANT ALL ON powerdns.* TO 'powerdns'@'localhost' IDENTIFIED BY 'Str0ngPasswOrd';
FLUSH PRIVILEGES;
USE powerdns;
CREATE TABLE domains (
  id                    INT AUTO_INCREMENT,
  name                  VARCHAR(255) NOT NULL,
  master                VARCHAR(128) DEFAULT NULL,
  last_check            INT DEFAULT NULL,
  type                  VARCHAR(6) NOT NULL,
  notified_serial       INT UNSIGNED DEFAULT NULL,
  account               VARCHAR(40) CHARACTER SET 'utf8' DEFAULT NULL,
  PRIMARY KEY (id)
) Engine=InnoDB CHARACTER SET 'latin1';

CREATE UNIQUE INDEX name_index ON domains(name);


CREATE TABLE records (
  id                    BIGINT AUTO_INCREMENT,
  domain_id             INT DEFAULT NULL,
  name                  VARCHAR(255) DEFAULT NULL,
  type                  VARCHAR(10) DEFAULT NULL,
  content               VARCHAR(64000) DEFAULT NULL,
  ttl                   INT DEFAULT NULL,
  prio                  INT DEFAULT NULL,
  change_date           INT DEFAULT NULL,
  disabled              TINYINT(1) DEFAULT 0,
  ordername             VARCHAR(255) BINARY DEFAULT NULL,
  auth                  TINYINT(1) DEFAULT 1,
  PRIMARY KEY (id)
) Engine=InnoDB CHARACTER SET 'latin1';

CREATE INDEX nametype_index ON records(name,type);
CREATE INDEX domain_id ON records(domain_id);
CREATE INDEX ordername ON records (ordername);


CREATE TABLE supermasters (
  ip                    VARCHAR(64) NOT NULL,
  nameserver            VARCHAR(255) NOT NULL,
  account               VARCHAR(40) CHARACTER SET 'utf8' NOT NULL,
  PRIMARY KEY (ip, nameserver)
) Engine=InnoDB CHARACTER SET 'latin1';

CREATE TABLE comments (
  id                    INT AUTO_INCREMENT,
  domain_id             INT NOT NULL,
  name                  VARCHAR(255) NOT NULL,
  type                  VARCHAR(10) NOT NULL,
  modified_at           INT NOT NULL,
  account               VARCHAR(40) CHARACTER SET 'utf8' DEFAULT NULL,
  comment               TEXT CHARACTER SET 'utf8' NOT NULL,
  PRIMARY KEY (id)
) Engine=InnoDB CHARACTER SET 'latin1';

CREATE INDEX comments_name_type_idx ON comments (name, type);
CREATE INDEX comments_order_idx ON comments (domain_id, modified_at);


CREATE TABLE domainmetadata (
  id                    INT AUTO_INCREMENT,
  domain_id             INT NOT NULL,
  kind                  VARCHAR(32),
  content               TEXT,
  PRIMARY KEY (id)
) Engine=InnoDB CHARACTER SET 'latin1';

CREATE INDEX domainmetadata_idx ON domainmetadata (domain_id, kind);


CREATE TABLE cryptokeys (
  id                    INT AUTO_INCREMENT,
  domain_id             INT NOT NULL,
  flags                 INT NOT NULL,
  active                BOOL,
  content               TEXT,
  PRIMARY KEY(id)
) Engine=InnoDB CHARACTER SET 'latin1';

CREATE INDEX domainidindex ON cryptokeys(domain_id);


CREATE TABLE tsigkeys (
  id                    INT AUTO_INCREMENT,
  name                  VARCHAR(255),
  algorithm             VARCHAR(50),
  secret                VARCHAR(255),
  PRIMARY KEY (id)
) Engine=InnoDB CHARACTER SET 'latin1';

CREATE UNIQUE INDEX namealgoindex ON tsigkeys(name, algorithm);
```

```shell
$ sudo systemctl disable systemd-resolved
$ sudo systemctl stop systemd-resolved

$ ls -lh /etc/resolv.conf
lrwxrwxrwx 1 root root 39 Jul 24 15:50 /etc/resolv.conf -> ../run/systemd/resolve/stub-resolv.conf
$ sudo unlink /etc/resolv.conf

$ echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

Add official PowerDNS repository for Ubuntu 22.04|20.04|18.04.

```shell
# Ubuntu 22.04
$ echo "deb [arch=amd64] http://repo.powerdns.com/ubuntu jammy-auth-master main" | sudo tee /etc/apt/sources.list.d/pdns.list

# Ubuntu 20.04
$ echo "deb [arch=amd64] http://repo.powerdns.com/ubuntu focal-auth-master main" | sudo tee /etc/apt/sources.list.d/pdns.list

# Ubuntu 18.04
$ echo "deb [arch=amd64] http://repo.powerdns.com/ubuntu bionic-auth-master main" | sudo tee /etc/apt/sources.list.d/pdns.list


$ curl -fsSL https://repo.powerdns.com/CBC8B383-pub.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/powerdns.gpg

$ sudo apt update
$ sudo apt install pdns-server pdns-backend-mysql
```

When asked whether to configure the PowerDNS database with **dbconfig-common**, answer **No**

```shell
$ sudo vim /etc/powerdns/pdns.d/pdns.local.gmysql.conf
# MySQL Configuration
# Launch gmysql backend
launch+=gmysql
# gmysql parameters
gmysql-host=localhost
gmysql-port=3306
gmysql-dbname=powerdns
gmysql-user=powerdns
gmysql-password=Str0ngPasswOrd
gmysql-dnssec=yes
# gmysql-socket=

$ sudo systemctl restart pdns
$ sudo systemctl enable pdns
```

#### Install PowerDNS-Admin

```shell
sudo apt install python3-dev
sudo apt install -y libmysqlclient-dev libsasl2-dev libldap2-dev libssl-dev libxml2-dev libxslt1-dev libxmlsec1-dev libffi-dev pkg-config apt-transport-https virtualenv build-essential python3-venv

curl -sL https://deb.nodesource.com/setup_16.x | sudo bash -
sudo apt install -y nodejs

curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/yarn-keyring.gpg
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install -y yarn

sudo su -
git clone https://github.com/ngoduykhanh/PowerDNS-Admin.git /opt/web/powerdns-admin
cd /opt/web/powerdns-admin
python3 -mvenv ./venv

cp /opt/web/powerdns-admin/configs/development.py /opt/web/powerdns-admin/configs/production.py
```

```shell
vim /opt/web/powerdns-admin/configs/production.py

### DATABASE CONFIG
SQLA_DB_USER = 'powerdns'
SQLA_DB_PASSWORD = 'Str0ngPasswOrd'
SQLA_DB_HOST = '127.0.0.1'
SQLA_DB_NAME = 'powerdns'
SQLALCHEMY_TRACK_MODIFICATIONS = True

### DATABASE - MySQL
#SQLALCHEMY_DATABASE_URI = 'sqlite:///' + os.path.join(basedir, 'pdns.db')
SQLALCHEMY_DATABASE_URI = 'mysql://'+SQLA_DB_USER+':'+SQLA_DB_PASSWORD+'@'+SQLA_DB_HOST+'/'+SQLA_DB_NAME
```

```shell
(flask) $ export FLASK_APP=powerdnsadmin/__init__.py
(flask) $ export FLASK_CONF=../configs/production.py
(flask)$ flask db upgrade
INFO  [alembic.runtime.migration] Context impl MySQLImpl.
INFO  [alembic.runtime.migration] Will assume non-transactional DDL.
INFO  [alembic.runtime.migration] Running upgrade  -> 787bdba9e147, Init DB
INFO  [alembic.runtime.migration] Running upgrade 787bdba9e147 -> 59729e468045, Add view column to setting table
INFO  [alembic.runtime.migration] Running upgrade 59729e468045 -> 1274ed462010, Change setting.value data type
INFO  [alembic.runtime.migration] Running upgrade 1274ed462010 -> 4a666113c7bb, Adding Operator Role
INFO  [alembic.runtime.migration] Running upgrade 4a666113c7bb -> 31a4ed468b18, Remove all setting in the DB
INFO  [alembic.runtime.migration] Running upgrade 31a4ed468b18 -> 654298797277, Upgrade DB Schema
INFO  [alembic.runtime.migration] Running upgrade 654298797277 -> 0fb6d23a4863, Remove user avatar
INFO  [alembic.runtime.migration] Running upgrade 0fb6d23a4863 -> 856bb94b7040, Add comment column in domain template record table
INFO  [alembic.runtime.migration] Running upgrade 856bb94b7040 -> b0fea72a3f20, Update domain serial columns type
INFO  [alembic.runtime.migration] Running upgrade b0fea72a3f20 -> 3f76448bb6de, Add user.confirmed column
INFO  [alembic.runtime.migration] Running upgrade 3f76448bb6de -> 0d3d93f1c2e0, Add domain_id to history table
```

##### Fixing error "ImportError: cannot import name 'json' from 'itsdangerous'"

```shell
# Only if you have error ImportError: cannot import name 'json' from 'itsdangerous'
$ pip uninstall itsdangerous
$ pip install  itsdangerous==2.0.1
$ flask db upgrade
```

```shell
(flask)$ flask db migrate -m "Init DB"
INFO  [alembic.runtime.migration] Context impl MySQLImpl.
INFO  [alembic.runtime.migration] Will assume non-transactional DDL.
INFO  [alembic.autogenerate.compare] Detected removed index 'name_index' on 'domains'
INFO  [alembic.autogenerate.compare] Detected removed table 'domains'
INFO  [alembic.autogenerate.compare] Detected removed index 'comments_name_type_idx' on 'comments'
INFO  [alembic.autogenerate.compare] Detected removed index 'comments_order_idx' on 'comments'
INFO  [alembic.autogenerate.compare] Detected removed table 'comments'
INFO  [alembic.autogenerate.compare] Detected removed index 'namealgoindex' on 'tsigkeys'
INFO  [alembic.autogenerate.compare] Detected removed table 'tsigkeys'
INFO  [alembic.autogenerate.compare] Detected removed index 'domainidindex' on 'cryptokeys'
INFO  [alembic.autogenerate.compare] Detected removed table 'cryptokeys'
INFO  [alembic.autogenerate.compare] Detected removed table 'supermasters'
INFO  [alembic.autogenerate.compare] Detected removed index 'domainmetadata_idx' on 'domainmetadata'
INFO  [alembic.autogenerate.compare] Detected removed table 'domainmetadata'
INFO  [alembic.autogenerate.compare] Detected removed index 'nametype_index' on 'records'
INFO  [alembic.autogenerate.compare] Detected removed table 'records'
INFO  [alembic.autogenerate.compare] Detected added index 'ix_history_created_on' on '['created_on']'
  Generating /opt/web/powerdns-admin/migrations/versions/57130833385e_init_db.py ...  done

(flask)$ yarn install --pure-lockfile
yarn install v1.22.17
[1/4] Resolving packages...
[2/4] Fetching packages...
[3/4] Linking dependencies...
[4/4] Building fresh packages...
Done in 15.49s.

(flask)$ flask assets build
Building bundle: generated/login.js
[2022-02-21 22:45:55,106] [script.py:167] INFO - Building bundle: generated/login.js
Building bundle: generated/validation.js
[2022-02-21 22:45:55,267] [script.py:167] INFO - Building bundle: generated/validation.js
Building bundle: generated/login.css
[2022-02-21 22:45:55,270] [script.py:167] INFO - Building bundle: generated/login.css
Building bundle: generated/main.js
[2022-02-21 22:46:28,632] [script.py:167] INFO - Building bundle: generated/main.js
Building bundle: generated/main.css
[2022-02-21 22:46:29,536] [script.py:167] INFO - Building bundle: generated/main.css

(flask)$ ./run.py
[INFO] * Running on http://127.0.0.1:9191/ (Press CTRL+C to quit)
[INFO] * Restarting with stat
[WARNING] * Debugger is active!
[INFO] * Debugger PIN: 466-405-858
```

##### Configure systemd service and Nginx

```shell
$ sudo vim /etc/systemd/system/powerdns-admin.service
[Install]
WantedBy=multi-user.target

[Unit]
Description=PowerDNS-Admin
Requires=powerdns-admin.socket
After=network.target

[Service]
PIDFile=/run/powerdns-admin/pid
User=pdns
Group=pdns
WorkingDirectory=/opt/web/powerdns-admin
ExecStart=/opt/web/powerdns-admin/venv/bin/gunicorn --pid /run/powerdns-admin/pid --bind unix:/run/powerdns-admin/socket 'powerdnsadmin:create_app()'
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

Create override file

```shell
sudo tee /etc/systemd/system/powerdns-admin.service.d/override.conf<<EOF
[Service]
Environment="FLASK_CONF=../configs/production.py"
EOF
```

Create socket file

```shell
$ sudo vim /etc/systemd/system/powerdns-admin.socket
[Unit]
Description=PowerDNS-Admin socket

[Socket]
ListenStream=/run/powerdns-admin/socket

[Install]
WantedBy=sockets.target

```

Create environment file

```shell
$ sudo vim /etc/tmpfiles.d/powerdns-admin.conf
d /run/powerdns-admin 0755 pdns pdns -
```

```shell
sudo systemctl daemon-reload
sudo systemctl restart powerdns-admin.socket
sudo systemctl enable powerdns-admin.socket

sudo chown -R pdns:pdns /run/powerdns-admin
sudo chown -R pdns:pdns /opt/web/powerdns-admin


sudo apt install nginx
sudo vim /etc/nginx/conf.d/powerdns-admin.conf

```

```nginx
server {
  listen *:80;
  server_name               powerdns-admin.example.com;

  index                     index.html index.htm index.php;
  root                      /opt/web/powerdns-admin;
  access_log                /var/log/nginx/powerdns_admin_access.log combined;
  error_log                 /var/log/nginx/powerdns_admin_error.log;

  client_max_body_size              10m;
  client_body_buffer_size           128k;
  proxy_redirect                    off;
  proxy_connect_timeout             90;
  proxy_send_timeout                90;
  proxy_read_timeout                90;
  proxy_buffers                     32 4k;
  proxy_buffer_size                 8k;
  proxy_set_header                  Host $host;
  proxy_set_header                  X-Real-IP $remote_addr;
  proxy_set_header                  X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_headers_hash_bucket_size    64;

  location ~ ^/static/  {
    include  /etc/nginx/mime.types;
    root /opt/web/powerdns-admin/powerdnsadmin;

    location ~*  \.(jpg|jpeg|png|gif)$ {
      expires 365d;
    }

    location ~* ^.+.(css|js)$ {
      expires 7d;
    }
  }

  location / {
    proxy_pass            http://unix:/run/powerdns-admin/socket;
    proxy_read_timeout    120;
    proxy_connect_timeout 120;
    proxy_redirect        off;
  }
}

```

##### Configure PowerDNS API

```shell
$ sudo vim /etc/powerdns/pdns.conf
# Configure like below
webserver-port=8081
api=yes
api-key=f5ee4390-6542-48c9-a2a0-e5d0bd399490 #You can generate one from https://codepen.io/corenominal/pen/rxOmMJ
```

`sudo systemctl restart powerdns-admin`
