---
title: "Trellis Ansible Bad Interpreter Error"
date: 2019-12-06T22:34:31+08:00
menu:
  sidebar:
    name: "Trellis Ansible Bad Interpreter Error"
    identifier: ansible-trellis-ansible-bad-interpreter-error
    weight: 10
tags: ["URL", "Ansible"]
categories: ["URL", "Ansible"]
hero: images/hero/ansible.png
---

- [Trellis Ansible Bad Interpreter Error](https://wpvilla.in/trellis-ansible-bad-interpreter-error/)

#### Bad Interpreter Error

Error we got using Ansible was a bad interpreter error. Python 2.7 is not to be found:

```shell
zsh: /usr/local/bin/ansible-vault: bad interpreter: /usr/local/opt/python@2/bin/python2.7: no such file or directory
```

And that was correct because when we checked /usr/local/opt we only had Python 3.

#### Installation Python 2

```shell
brew install python@2
```

##### Python Crashing Hard

Next, on Ansible version check I got another error

```shell
➜  trellis git:(master) ansible --version
[1]    19153 abort      ansible --version
```

It was somehow crashing Python 2.7 though it should just work with it. I decided to upgrade Ansible as well

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

Found https://stackoverflow.com/questions/58272830/python-crashing-on-macos-10-15-beta-19a582a-with-usr-lib-libcrypto-dylib on the error with the Dynamic library loaded being the wrong one and decided to install openssl

`brew install openssl`

But it was already installed so no need for that. So then I added this line to .zshrc to load the correct library inside zsh:

```shell
# Python crash fix
export DYLD_LIBRARY_PATH=/usr/local/opt/openssl/lib:$DYLD_LIBRARY_PATH
```
