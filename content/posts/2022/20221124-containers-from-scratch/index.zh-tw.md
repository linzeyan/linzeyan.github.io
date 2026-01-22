---
title: "從零開始的容器"
date: 2022-11-24T13:10:14+08:00
menu:
  sidebar:
    name: "從零開始的容器"
    identifier: linux-containers-from-scratch
    weight: 10
tags: ["Links", "Linux", "container"]
categories: ["Links", "Linux", "container"]
hero: images/hero/linux.png
---

- [從零開始的容器](https://ericchiang.github.io/post/containers-from-scratch/)

### 容器檔案系統

```bash
$ wget https://github.com/ericchiang/containers-from-scratch/releases/download/v0.1.0/rootfs.tar.gz
$ sha256sum rootfs.tar.gz
c79bfb46b9cf842055761a49161831aee8f4e667ad9e84ab57ab324a49bc828c  rootfs.tar.gz
$ # tar needs sudo to create /dev files and setup file ownership
$ sudo tar -zxf rootfs.tar.gz
$ ls rootfs
bin   dev  home  lib64  mnt  proc  run   srv  tmp  var
boot  etc  lib   media  opt  root  sbin  sys  usr
$ ls -al rootfs/bin/ls
-rwxr-xr-x. 1 root root 118280 Mar 14  2015 rootfs/bin/ls
```

### chroot

它可以限制某個程序對檔案系統的視野。這裡我們把程序限制在 "rootfs" 目錄，然後執行一個 shell。

```bash
$ sudo chroot rootfs /bin/bash
root@localhost:/# ls /
bin   dev  home  lib64  mnt  proc  run   srv  tmp  var
boot  etc  lib   media  opt  root  sbin  sys  usr
root@localhost:/# which python
/usr/bin/python
root@localhost:/# /usr/bin/python -c 'print "Hello, container world!"'
Hello, container world!
root@localhost:/#
```

當我們執行 Python 直譯器時，實際上是執行 `rootfs/usr/bin/python`，而不是宿主機的 Python。

### 使用 unshare 建立 namespaces

```bash
$ sudo unshare -p -f --mount-proc=$PWD/rootfs/proc \
    chroot rootfs /bin/bash
root@localhost:/# ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0  20268  3240 ?        S    22:34   0:00 /bin/bash
root         2  0.0  0.0  17504  2096 ?        R+   22:34   0:00 ps aux
root@localhost:/#
```

在這個例子中，我們為 shell 建立 PID namespace，然後像上一個例子一樣執行 chroot。

### 使用 nsenter 進入 namespaces

- 先找出上一個例子中在 chroot 裡執行的 shell。

```bash
$ # From the host, not the chroot.
$ ps aux | grep /bin/bash | grep root
...
root     29840  0.0  0.0  20272  3064 pts/5    S+   17:25   0:00 /bin/bash
```

Kernel 會在 /proc/(PID)/ns 底下以檔案的形式暴露 namespace。在這裡，/proc/29840/ns/pid 就是我們要加入的程序 namespace。

- nsenter 指令提供 setns 的封裝以進入 namespace。我們會指定 namespace 檔案，然後執行 unshare 重新掛載 `/proc` 並 chroot。這次不是建立新 namespace，而是加入既有的 namespace。

```bash
$ sudo nsenter --pid=/proc/29840/ns/pid \
    unshare -f --mount-proc=$PWD/rootfs/proc \
    chroot rootfs /bin/bash
root@localhost:/# ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0  20272  3064 ?        S+   00:25   0:00 /bin/bash
root         5  0.0  0.0  20276  3248 ?        S    00:29   0:00 /bin/bash
root         6  0.0  0.0  17504  1984 ?        R+   00:30   0:00 ps aux
```

### 用 mounts 繞過 chroot

- 先建立一個要掛載到 chroot 的新目錄，並在其中建立檔案。

```bash
$ sudo mkdir readonlyfiles
$ echo "hello" > readonlyfiles/hi.txt
```

- 接著在容器內建立目標目錄，並用 bind mount 掛載到該目錄，搭配 `-o ro` 讓它唯讀。

```bash
$ sudo mkdir -p rootfs/var/readonlyfiles
$ sudo mount --bind -o ro $PWD/readonlyfiles $PWD/rootfs/var/readonlyfiles
```

### cgroups

Kernel 透過 /sys/fs/cgroup 目錄暴露 cgroups。如果你的機器沒有，你可能需要掛載 memory cgroup 才能跟著做。

```bash
$ ls /sys/fs/cgroup/
blkio  cpuacct      cpuset   freezer  memory   net_cls,net_prio  perf_event  systemd
cpu    cpu,cpuacct  devices  hugetlb  net_cls  net_prio          pids
```

建立 cgroup 很簡單，只要建立目錄即可。這裡我們建立一個名為 "demo" 的 memory group。建立後，Kernel 會在該目錄中放入用來配置 cgroup 的檔案。

```bash
$ sudo su
# mkdir /sys/fs/cgroup/memory/demo
# ls /sys/fs/cgroup/memory/demo/
cgroup.clone_children               memory.memsw.failcnt
cgroup.event_control                memory.memsw.limit_in_bytes
cgroup.procs                        memory.memsw.max_usage_in_bytes
memory.failcnt                      memory.memsw.usage_in_bytes
memory.force_empty                  memory.move_charge_at_immigrate
memory.kmem.failcnt                 memory.numa_stat
memory.kmem.limit_in_bytes          memory.oom_control
memory.kmem.max_usage_in_bytes      memory.pressure_level
memory.kmem.slabinfo                memory.soft_limit_in_bytes
memory.kmem.tcp.failcnt             memory.stat
memory.kmem.tcp.limit_in_bytes      memory.swappiness
memory.kmem.tcp.max_usage_in_bytes  memory.usage_in_bytes
memory.kmem.tcp.usage_in_bytes      memory.use_hierarchy
memory.kmem.usage_in_bytes          notify_on_release
memory.limit_in_bytes               tasks
memory.max_usage_in_bytes
```

要調整數值，只要寫入對應檔案即可。這裡把 cgroup 設為 100MB，並關閉 swap。

```bash
# echo "100000000" > /sys/fs/cgroup/memory/demo/memory.limit_in_bytes
# echo "0" > /sys/fs/cgroup/memory/demo/memory.swappiness
```

tasks 檔案很特別，裡面列出被指派到此 cgroup 的程序。要加入 cgroup，可以把自己的 PID 寫入。

```bash
# echo $$ > /sys/fs/cgroup/memory/demo/tasks
```

最後我們需要一個吃記憶體的程式。

```python
# hungry.py
f = open("/dev/urandom", "r")
data = ""

i=0
while True:
    data += f.read(10000000) # 10mb
    i += 1
    print "%dmb" % (i*10,)
```

```bash
# python hungry.py
10mb
20mb
30mb
40mb
50mb
60mb
70mb
80mb
Killed
```

在 tasks 檔案中的程序全部結束或被重新指派到其他群組前，cgroups 不能被刪除。離開 shell 後用 `rmdir` 刪除目錄（不要用 `rm -r`）。

```bash
# exit
exit
$ sudo rmdir /sys/fs/cgroup/memory/demo
```

### 容器安全與 capabilities

```go
package main

import (
    "fmt"
    "net"
    "os"
)

func main() {
    if _, err := net.Listen("tcp", ":80"); err != nil {
        fmt.Fprintln(os.Stdout, err)
        os.Exit(2)
    }
    fmt.Println("success")
}
```

```bash
$ go build -o listen listen.go
$ ./listen
listen tcp :80: bind: permission denied

# In this case, CAP_NET_BIND_SERVICE allows executables to listen on lower ports.
$ sudo setcap cap_net_bind_service=+ep listen
$ getcap listen
listen = cap_net_bind_service+ep
$ ./listen
success
```

對於已經以 root 執行的東西（例如多數容器化應用），我們更關心的是移除 capabilities，而非新增。

```bash
$ sudo su
# capsh --print
Current: = cap_chown,cap_dac_override,cap_dac_read_search,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_linux_immutable,cap_net_bind_service,cap_net_broadcast,cap_net_admin,cap_net_raw,cap_ipc_lock,cap_ipc_owner,cap_sys_module,cap_sys_rawio,cap_sys_chroot,cap_sys_ptrace,cap_sys_pacct,cap_sys_admin,cap_sys_boot,cap_sys_nice,cap_sys_resource,cap_sys_time,cap_sys_tty_config,cap_mknod,cap_lease,cap_audit_write,cap_audit_control,cap_setfcap,cap_mac_override,cap_mac_admin,cap_syslog,cap_wake_alarm,cap_block_suspend,37+ep
Bounding set =cap_chown,cap_dac_override,cap_dac_read_search,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_linux_immutable,cap_net_bind_service,cap_net_broadcast,cap_net_admin,cap_net_raw,cap_ipc_lock,cap_ipc_owner,cap_sys_module,cap_sys_rawio,cap_sys_chroot,cap_sys_ptrace,cap_sys_pacct,cap_sys_admin,cap_sys_boot,cap_sys_nice,cap_sys_resource,cap_sys_time,cap_sys_tty_config,cap_mknod,cap_lease,cap_audit_write,cap_audit_control,cap_setfcap,cap_mac_override,cap_mac_admin,cap_syslog,cap_wake_alarm,cap_block_suspend,37
Securebits: 00/0x0/1'b0
 secure-noroot: no (unlocked)
 secure-no-suid-fixup: no (unlocked)
 secure-keep-caps: no (unlocked)
uid=0(root)
gid=0(root)
groups=0(root)
```

例如，我們用 capsh 移除幾個 capabilities（包含 CAP_CHOWN）。若一切正常，即使是 root，我們也無法變更檔案擁有者。

```bash
$ sudo capsh --drop=cap_chown,cap_setpcap,cap_setfcap,cap_sys_admin --chroot=$PWD/rootfs --
root@localhost:/# whoami
root
root@localhost:/# chown nobody /bin/ls
chown: changing ownership of '/bin/ls': Operation not permitted
```
