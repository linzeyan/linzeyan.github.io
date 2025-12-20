---
title: "Containers from scratch"
date: 2022-11-24T13:10:14+08:00
menu:
  sidebar:
    name: "Containers from scratch"
    identifier: linux-containers-from-scratch
    weight: 10
tags: ["URL", "Linux", "container"]
categories: ["URL", "Linux", "container"]
hero: images/hero/linux.png
---

- [Containers from scratch](https://ericchiang.github.io/post/containers-from-scratch/)

### Container file systems

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

it allows us to restrict a process' view of the file system. In this case, we'll restrict our process to the "rootfs" directory then exec a shell.

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

When we execute the Python interpreter, we're executing `rootfs/usr/bin/python`, not the host's Python.

### Creating namespaces with unshare

```bash
$ sudo unshare -p -f --mount-proc=$PWD/rootfs/proc \
    chroot rootfs /bin/bash
root@localhost:/# ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0  20268  3240 ?        S    22:34   0:00 /bin/bash
root         2  0.0  0.0  17504  2096 ?        R+   22:34   0:00 ps aux
root@localhost:/#
```

In this case, we'll create a PID namespace for the shell, then execute the chroot like the last example.

### Entering namespaces with nsenter

- Let's find the shell running in a chroot from our last example.

```bash
$ # From the host, not the chroot.
$ ps aux | grep /bin/bash | grep root
...
root     29840  0.0  0.0  20272  3064 pts/5    S+   17:25   0:00 /bin/bash
```

The kernel exposes namespaces under /proc/(PID)/ns as files. In this case, /proc/29840/ns/pid is the process namespace we're hoping to join.

- The nsenter command provides a wrapper around setns to enter a namespace. We'll provide the namespace file, then run the unshare to remount `/proc` and `chroot` to setup a `chroot`. This time, instead of creating a new namespace, our shell will join the existing one.

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

### Getting around chroot with mounts

- First, let's make a new directory to mount into the chroot and create a file there.

```bash
$ sudo mkdir readonlyfiles
$ echo "hello" > readonlyfiles/hi.txt
```

- Next, we'll create a target directory in our container and bind mount the directory providing the -o ro argument to make it read-only.

```bash
$ sudo mkdir -p rootfs/var/readonlyfiles
$ sudo mount --bind -o ro $PWD/readonlyfiles $PWD/rootfs/var/readonlyfiles
```

### cgroups

The kernel exposes cgroups through the /sys/fs/cgroup directory. If your machine doesn't have one you may have to mount the memory cgroup to follow along.

```bash
$ ls /sys/fs/cgroup/
blkio  cpuacct      cpuset   freezer  memory   net_cls,net_prio  perf_event  systemd
cpu    cpu,cpuacct  devices  hugetlb  net_cls  net_prio          pids
```

Creating a cgroup is easy, just create a directory. In this case we'll create a memory group called "demo". Once created, the kernel fills the directory with files that can be used to configure the cgroup.

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

To adjust a value we just have to write to the corresponding file. Let's limit the cgroup to 100MB of memory and turn off swap.

```bash
# echo "100000000" > /sys/fs/cgroup/memory/demo/memory.limit_in_bytes
# echo "0" > /sys/fs/cgroup/memory/demo/memory.swappiness
```

The tasks file is special, it contains the list of processes which are assigned to the cgroup. To join the cgroup we can write our own PID.

```bash
# echo $$ > /sys/fs/cgroup/memory/demo/tasks
```

Finally we need a memory hungry application.

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

cgroups can't be removed until every processes in the tasks file has exited or been reassigned to another group. Exit the shell and remove the directory with `rmdir` (don't use `rm -r`).

```bash
# exit
exit
$ sudo rmdir /sys/fs/cgroup/memory/demo
```

### Container security and capabilities

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

For things already running as root, like most containerized apps, we're more interested in taking capabilities away than granting them.

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

As an example, we'll use capsh to drop a few capabilities including CAP_CHOWN. If things work as expected, our shell shouldn't be able to modify file ownership despite being root.

```bash
$ sudo capsh --drop=cap_chown,cap_setpcap,cap_setfcap,cap_sys_admin --chroot=$PWD/rootfs --
root@localhost:/# whoami
root
root@localhost:/# chown nobody /bin/ls
chown: changing ownership of '/bin/ls': Operation not permitted
```
