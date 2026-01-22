---
title: "Day 28 - Introduction to Useful Third-Party Kubernetes Tools"
date: 2021-12-02T13:28:09+08:00
menu:
  sidebar:
    name: "Day 28 - Introduction to Useful Third-Party Kubernetes Tools"
    identifier: k8s-introduction-to-useful-third-party-tools
    weight: 10
tags: ["Links", "Kubernetes", "Plugin"]
categories: ["Links", "Kubernetes", "Plugin"]
hero: images/hero/kubernetes.png
---

- [Day 28 - Introduction to Useful Third-Party Kubernetes Tools](https://ithelp.ithome.com.tw/articles/10252675)

```shell
$ kubectl get pods
NAME                      READY   STATUS    RESTARTS   AGE
ithome-6564f65698-947rv   1/1     Running   0          84s
ithome-6564f65698-fglr9   1/1     Running   0          84s
ithome-6564f65698-k5wtg   1/1     Running   0          84s
ithome-6564f65698-rrvk4   1/1     Running   0          84s
ithome-6564f65698-zhwlj   1/1     Running   0          84s
```

#### [Stern](https://github.com/wercker/stern)/Kail

> The names of created pods often contain some unreadable random strings.
>
> If you use kubectl to observe logs for individual pods, you need to switch between different pods.
>
> There are many tools for this, such as Stern, Kube-tail, and Kail.

In the example above, there are five pods and their names all start with ithome, so I can use `stern ithome` to capture their logs. The result is shown below.

```bash
$ stern ithome
...
ithome-6564f65698-zhwlj netutils Hello! 369 secs elapsed...
ithome-6564f65698-fglr9 netutils Hello! 369 secs elapsed...
ithome-6564f65698-947rv netutils Hello! 367 secs elapsed...
ithome-6564f65698-k5wtg netutils Hello! 368 secs elapsed...
ithome-6564f65698-rrvk4 netutils Hello! 369 secs elapsed...
ithome-6564f65698-zhwlj netutils Hello! 370 secs elapsed...
ithome-6564f65698-fglr9 netutils Hello! 370 secs elapsed...
ithome-6564f65698-947rv netutils Hello! 368 secs elapsed...
ithome-6564f65698-k5wtg netutils Hello! 370 secs elapsed...
ithome-6564f65698-rrvk4 netutils Hello! 370 secs elapsed...
ithome-6564f65698-zhwlj netutils Hello! 371 secs elapsed...
ithome-6564f65698-fglr9 netutils Hello! 371 secs elapsed...
ithome-6564f65698-947rv netutils Hello! 369 secs elapsed...

ithome-6564f65698-k5wtg netutils Hello! 371 secs elapsed...
ithome-6564f65698-rrvk4 netutils Hello! 371 secs elapsed...
ithome-6564f65698-zhwlj netutils Hello! 372 secs elapsed...
ithome-6564f65698-fglr9 netutils Hello! 372 secs elapsed...
^C
```

#### K9S

> In the past, I used kubectl commands to jump between resources and namespaces, especially when running `exec`, `get`, `describe`, `logs`, `delete`, and so on. It is easy to get overwhelmed or feel tired. If you have the same pain, you can consider using k9s.

#### Ksniff

> A tool for capturing network packets.

```bash
$ sudo apt install tshark
$ kubectl sniff ithome-6564f65698-947rv -o - | tshark -r -
$ kubectl sniff ithome-6564f65698-947rv -o - | tshark -r -
INFO[0000] sniffing method: upload static tcpdump
INFO[0000] using tcpdump path at: '/home/ubuntu/.krew/store/sniff/v1.4.2/static-tcpdump'
INFO[0000] no container specified, taking first container we found in pod.
INFO[0000] selected container: 'netutils'
INFO[0000] sniffing on pod: 'ithome-6564f65698-947rv' [namespace: 'default', container: 'netutils', filter: '', interface: 'any']
INFO[0000] uploading static tcpdump binary from: '/home/ubuntu/.krew/store/sniff/v1.4.2/static-tcpdump' to: '/tmp/static-tcpdump'
INFO[0000] uploading file: '/home/ubuntu/.krew/store/sniff/v1.4.2/static-tcpdump' to '/tmp/static-tcpdump' on container: 'netutils'
INFO[0000] executing command: '[/bin/sh -c ls -alt /tmp/static-tcpdump]' on container: 'netutils', pod: 'ithome-6564f65698-947rv', namespace: 'default'
INFO[0000] command: '[/bin/sh -c ls -alt /tmp/static-tcpdump]' executing successfully exitCode: '0', stdErr :''
INFO[0000] file found: '-rwxr-xr-x 1 root root 2696368 Jan  1  1970 /tmp/static-tcpdump
'
INFO[0000] file was already found on remote pod
INFO[0000] tcpdump uploaded successfully
INFO[0000] output file option specified, storing output in: '-'
INFO[0000] start sniffing on remote container
INFO[0000] executing command: '[/tmp/static-tcpdump -i any -U -w - ]' on container: 'netutils', pod: 'ithome-6564f65698-947rv', namespace: 'default'

```
