---
title: "Systemd Tutorial: Practical Part"
date: 2018-08-09T13:53:32+08:00
menu:
  sidebar:
    name: "Systemd Tutorial: Practical Part"
    identifier: linux-systemd-tutorial-part-two
    weight: 10
tags: ["Links", "Linux"]
categories: ["Links", "Linux"]
hero: images/hero/linux.png
---

- [Systemd Tutorial: Practical Part](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html)

```shell
$ systemctl cat sshd.service

[Unit]
Description=OpenSSH server daemon
Documentation=man:sshd(8) man:sshd_config(5)
After=network.target sshd-keygen.service
Wants=sshd-keygen.service

[Service]
EnvironmentFile=/etc/sysconfig/sshd
ExecStart=/usr/sbin/sshd -D $OPTIONS
ExecReload=/bin/kill -HUP $MAINPID
Type=simple
KillMode=process
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
```

#### [Unit] Section: Startup Order and Dependencies

`After` field: if `network.target` or `sshd-keygen.service` needs to start, then `sshd.service` should start after them.

Correspondingly, the `Before` field defines which services `sshd.service` should start before.

Note that After and Before only involve startup order, not dependency relationships.

To define dependencies, use the Wants and Requires fields.

`Wants` field: indicates a "weak dependency" between `sshd.service` and `sshd-keygen.service`. If `sshd-keygen.service` fails to start or stops running, it does not affect `sshd.service`.

`Requires` field indicates a "strong dependency". If the service fails to start or exits abnormally, then `sshd.service` must exit.

Note that Wants and Requires only involve dependencies, not startup order. By default they start at the same time.

#### [Service] Section: Start Behavior

`EnvironmentFile` field: specifies the environment parameter file for the current service. The `key=value` pairs in that file can be referenced as `$key` in the config.

`ExecStart` field: command executed when starting the process.

`ExecReload` field: command executed when reloading the service.

`ExecStop` field: command executed when stopping the service.

`ExecStartPre` field: command executed before starting the service.

`ExecStartPost` field: command executed after starting the service.

`ExecStopPost` field: command executed after stopping the service.

**example**

```
[Service]
ExecStart=/bin/echo execstart1
ExecStart=
ExecStart=/bin/echo execstart2
ExecStartPost=/bin/echo post1
ExecStartPost=/bin/echo post2
```

In the config above, the second line sets ExecStart to empty, which cancels the first line. The result is:

```shell
execstart2
post1
post2
```

All start settings can be prefixed with a dash (`-`), meaning "suppress errors". For example, `EnvironmentFile=-/etc/sysconfig/sshd` means that even if `/etc/sysconfig/sshd` does not exist, it will not raise an error.

---

`Type` field defines the startup type. Possible values:

- simple (default): the process started by ExecStart is the main process
- forking: ExecStart will start with fork(); the parent exits and the child becomes the main process
- oneshot: similar to simple, but runs only once; Systemd waits for it to finish before starting other services
- dbus: similar to simple, but waits for a D-Bus signal before starting
- notify: similar to simple, but sends a notification after startup and Systemd continues
- idle: similar to simple, but waits until other tasks finish so its output does not mix with others

**example**
The following is a oneshot example. At laptop startup, disable the touchpad. The config file can be:

```
[Unit]
Description=Switch-off Touchpad

[Service]
Type=oneshot
ExecStart=/usr/bin/touchpad-off

[Install]
WantedBy=multi-user.target
```

In the config above, type oneshot means the service only needs to run once, and does not need to run long-term.

If you want to enable it again later, update the config as follows:

```

[Unit]
Description=Switch-off Touchpad

[Service]
Type=oneshot
ExecStart=/usr/bin/touchpad-off start
ExecStop=/usr/bin/touchpad-off stop
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

In the config above, RemainAfterExit is set to yes, meaning the service remains active after the process exits. In this case, when you stop the service with `systemctl stop`, the ExecStop command runs, which turns the touchpad back on.

---

`KillMode` field: defines how Systemd stops the sshd service.

In the example above, KillMode is set to process, meaning only the main process is stopped. It does not stop any sshd child processes, so existing SSH sessions stay connected. This setting is uncommon but important for sshd; otherwise stopping the service would kill your own SSH session.

Possible values for `KillMode`:

- control-group (default): all child processes in the control group are killed
- process: only kill the main process
- mixed: main process receives SIGTERM, child processes receive SIGKILL
- none: no processes are killed; only the service stop command runs

`Restart` field: defines how Systemd restarts sshd after it exits.

In the example above, Restart is set to on-failure, meaning any unexpected failure will restart sshd. If sshd stops normally (for example, via `systemctl stop`), it will not restart.

Possible values for `Restart`:

- no (default): do not restart after exit
- on-success: restart only after normal exit (status code 0)
- on-failure: restart after non-zero exit, signal termination, or timeout
- on-abnormal: restart only after signal termination or timeout
- on-abort: restart only after an uncaught signal termination
- on-watchdog: restart after watchdog timeout
- always: always restart regardless of exit reason

`RestartSec` field: number of seconds Systemd waits before restarting the service. In the example above, it waits 42 seconds.

#### [Install] Section

The Install section defines how to install this config file, i.e., how to enable it at boot.

`WantedBy` field: indicates the target for this service.

A target is a service group. WantedBy=multi-user.target means sshd is in the multi-user.target group.

This is important because when you run `systemctl enable sshd.service`, a symlink for sshd.service is created under `/etc/systemd/system` in the `multi-user.target.wants` subdirectory.

Systemd has a default target.

```shell
$ systemctl get-default
multi-user.target

# List all services in multi-user.target
$ systemctl list-dependencies multi-user.target

# Switch to another target
# shutdown.target is the shutdown state
$ sudo systemctl isolate shutdown.target
```

#### Target Config File

```shell
$ systemctl cat multi-user.target

[Unit]
Description=Multi-User System
Documentation=man:systemd.special(7)
Requires=basic.target
Conflicts=rescue.service rescue.target
After=basic.target rescue.service rescue.target
AllowIsolate=yes
```

注意，Target 配置文件里面没有启动命令。

上面输出结果中，主要字段含义如下。

`Requires` 字段：要求 basic.target 一起运行。

`Conflicts` 字段：冲突字段。如果 rescue.service 或 rescue.target 正在运行，multi-user.target 就不能运行，反之亦然。

`After`：表示 multi-user.target 在 basic.target 、 rescue.service、 rescue.target 之后启动，如果它们有启动的话。

`AllowIsolate`：允许使用 systemctl isolate 命令切换到 multi-user.target。

#### 修改配置文件后重启

```shell
# 重新加载配置文件
$ sudo systemctl daemon-reload

# 重启相关服务
$ sudo systemctl restart foobar
```
