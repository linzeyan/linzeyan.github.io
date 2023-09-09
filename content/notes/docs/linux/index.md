---
title: Linux docs
weight: 100
menu:
  notes:
    name: linux
    identifier: notes-linux-docs
    parent: notes-docs
    weight: 10
---

{{< note title="docker.service" >}}

```bash
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --bip 10.255.0.1/16 --containerd=/run/containerd/containerd.sock --insecure-registry hub.srjob.co:8888 --insecure-registry registry.knowhow.fun
```

{{< /note >}}

{{< note title="gd.service" >}}

```bash
[Unit]
Description=Fetch DNS
After=network.target
After=mysql.service

[Service]
WorkingDirectory=/data/dns
ExecStart=/data/dns/gd -o hourly
ExecReload=/bin/kill -s HUP $MAINPID
Restart=always

[Install]
WantedBy=multi-user.target
```

{{< /note >}}

{{< note title="openresty.service" >}}

```bash
[Unit]
Description=The OpenResty Application Platform
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
WorkingDirectory=/data/config/nginx
PIDFile=/data/config/nginx/logs/nginx.pid
ExecStartPre=/usr/bin/chown -R root:root /data/nginx
ExecStartPre=/usr/bin/rm -f /data/nginx/logs/nginx.pid
ExecStartPre=/usr/local/openresty/nginx/sbin/nginx -p /data/nginx -t
ExecStart=/usr/local/openresty/nginx/sbin/nginx -p /data/nginx
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /data/nginx/logs/nginx.pid
#ExecStop=/bin/kill -s QUIT $MAINPID
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
```

{{< /note >}}

{{< note title="pm2.service" >}}

```bash
[Unit]
Description=PM2 process manager
Documentation=https://pm2.keymetrics.io/
After=network.target

[Service]
Type=forking
User=root
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
Environment=PM2_HOME=/root/.pm2
PIDFile=/root/.pm2/pm2.pid
WorkingDirectory=/game/publish
ExecStart=/lib/node_modules/pm2/bin/pm2 start game_api.json manage.json
ExecReload=/lib/node_modules/pm2/bin/pm2 reload all
ExecStop=/lib/node_modules/pm2/bin/pm2 kill

[Install]
WantedBy=multi-user.target
```

{{< /note >}}

{{< note title="logrotate" >}}

```
/data/gameapi/logs/*.log {
    create 0644 nobody root
    daily
    rotate 30
    dateext
    missingok
    notifempty
    compress
    sharedscripts
    postrotate
    /bin/kill -USR1 `cat /data/gameapi/logs/nginx.pid 2>/dev/null` 2>/dev/null || true
    endscript
}
```

{{< /note >}}
