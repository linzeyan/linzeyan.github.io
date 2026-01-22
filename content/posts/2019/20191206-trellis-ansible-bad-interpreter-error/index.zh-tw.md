---
title: "Trellis Ansible 錯誤的解譯器"
date: 2019-12-06T22:34:31+08:00
menu:
  sidebar:
    name: "Trellis Ansible 錯誤的解譯器"
    identifier: ansible-trellis-ansible-bad-interpreter-error
    weight: 10
tags: ["Links", "Ansible"]
categories: ["Links", "Ansible"]
hero: images/hero/ansible.png
---

- [Trellis Ansible Bad Interpreter Error](https://wpvilla.in/trellis-ansible-bad-interpreter-error/)

#### Bad Interpreter Error

使用 Ansible 時遇到錯誤的解譯器問題。找不到 Python 2.7：

```shell
zsh: /usr/local/bin/ansible-vault: bad interpreter: /usr/local/opt/python@2/bin/python2.7: no such file or directory
```

這是正常的，因為我們檢查 /usr/local/opt 後只看到 Python 3。

#### 安裝 Python 2

```shell
brew install python@2
```

##### Python 嚴重崩潰

接著在檢查 Ansible 版本時又出現錯誤：

```shell
➜  trellis git:(master) ansible --version
[1]    19153 abort      ansible --version
```

它在 Python 2.7 上崩潰了，但理論上應該可以正常執行。我決定升級 Ansible。

```shell
sudo pip install ansible --upgrade
.....
Requirement already satisfied, skipping upgrade: six>=1.4.1 in /usr/local/lib/python2.7/site-packages (from cryptography->ansible) (1.11.0)
 Requirement already satisfied, skipping upgrade: pycparser in /usr/local/lib/python2.7/site-packages (from cffi>=1.7; platform_python_implementation != "PyPy"->cryptography->ansible) (2.18)
 Installing collected packages: ansible
   Found existing installation: ansible 2.7.5
     Uninstalling ansible-2.7.5:
       Successfully uninstalled ansible-2.7.5
 Successfully installed ansible-2.9.1

Still I had the Python error and iTerm was showing a MacOS popup that Python was crashing unexpectedly:

Python quit unexpectedly.
Click Reopen to open the application again. Click Report to see more detailed information and send a report to Apple.
Application Specific Information:
 /usr/lib/libcrypto.dylib
 abort() called
 Invalid dylib load. Clients should not load the unversioned libcrypto dylib as it does not have a stable ABI.
```

##### Invalid DyLib

找到 https://stackoverflow.com/questions/58272830/python-crashing-on-macos-10-15-beta-19a582a-with-usr-lib-libcrypto-dylib 這篇，知道是動態函式庫載入錯誤，於是決定安裝 openssl。

`brew install openssl`

但其實已經安裝過了，所以不用重裝。然後我在 .zshrc 裡加入下面這行，讓 zsh 載入正確的函式庫：

```shell
# Python crash fix
export DYLD_LIBRARY_PATH=/usr/local/opt/openssl/lib:$DYLD_LIBRARY_PATH
```
