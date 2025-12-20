---
title: "Day 28 - Kubernetes 第三方好用工具介紹"
date: 2021-12-02T13:28:09+08:00
menu:
  sidebar:
    name: "Day 28 - Kubernetes 第三方好用工具介紹"
    identifier: k8s-introduction-to-useful-third-party-tools
    weight: 10
tags: ["URL", "Kubernetes", "Plugin"]
categories: ["URL", "Kubernetes", "Plugin"]
hero: images/hero/kubernetes.png
---

- [Day 28 - Kubernetes 第三方好用工具介紹](https://ithelp.ithome.com.tw/articles/10252675)

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

> 創建出來的 Pod 名稱上面都會有一些不好閱讀的亂數
>
> 如果使用 kubectl 來觀察個別 Pod 的 log 就必須要於不同的 pod 之間來回切換
>
> 這方面的工具滿多的，譬如 Stern, Kube-tail, Kail 等都可以

上述範例會有五個 pod，而且這五個 pod 的名稱都是 ithome 開頭，因此我可以直接用 `stern ithom` 的方式來抓取這些 pod 的資訊，結果如下圖

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

> 過往總是透過 kubectl 指令於各個資源，各 namespace 間切來切去，特別是要使用 `exec`, `get`, `describe`, `logs`, `delete` 等指令時，常常打的手忙腳亂或是覺得心累，有這種困擾的人可以考慮使用看看 k9s 這個工具

#### Ksniff

> 抓取網路封包的工具

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
