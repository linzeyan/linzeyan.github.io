---
title: "fortios_system_config_backup_restore 的拼寫錯誤、缺少 collection，或模組路徑不正確"
date: 2022-01-06T13:40:40+08:00
menu:
  sidebar:
    name: "fortios_system_config_backup_restore 的拼寫錯誤、缺少 collection，或模組路徑不正確"
    identifier: ansible-galaxy-fortios-collection-fortios_system_config_backup_restore
    weight: 10
tags: ["Links", "Ansible", "Fortinet"]
categories: ["Links", "Ansible", "Fortinet"]
hero: images/hero/ansible.png
---

- [fortios_system_config_backup_restore 的拼寫錯誤、缺少 collection，或模組路徑不正確](https://github.com/fortinet-ansible-dev/ansible-galaxy-fortios-collection/issues/95)

#### 問題

Hi,

我在嘗試使用 `fortios_system_config_backup_restore` 模組，並依照你的 playbook 範例從 Fortigate 取得設定。

我使用的是 `ansible 2.10.6`。

當我使用 `fortinet.fortios:1.1.8` 這個 collection 時，出現以下錯誤：`missing 1 required positional argument: 'mod'`

```shell
The full traceback is:
Traceback (most recent call last):
  File "/home/ansible/.ansible/tmp/ansible-local-8668osvgufxk/ansible-tmp-1615481963.0092971-8768-3877705280026/AnsiballZ_fortios_system_config_backup_restore.py", line 102, in <module>
    _ansiballz_main()
  File "/home/ansible/.ansible/tmp/ansible-local-8668osvgufxk/ansible-tmp-1615481963.0092971-8768-3877705280026/AnsiballZ_fortios_system_config_backup_restore.py", line 94, in _ansiballz_main
    invoke_module(zipped_mod, temp_path, ANSIBALLZ_PARAMS)
  File "/home/ansible/.ansible/tmp/ansible-local-8668osvgufxk/ansible-tmp-1615481963.0092971-8768-3877705280026/AnsiballZ_fortios_system_config_backup_restore.py", line 40, in invoke_module
    runpy.run_module(mod_name='ansible_collections.fortinet.fortios.plugins.modules.fortios_system_config_backup_restore', init_globals=None, run_name='__main__', alter_sys=True)
  File "/usr/lib/python3.8/runpy.py", line 207, in run_module
    return _run_module_code(code, init_globals, run_name, mod_spec)
  File "/usr/lib/python3.8/runpy.py", line 97, in _run_module_code
    _run_code(code, mod_globals, init_globals,
  File "/usr/lib/python3.8/runpy.py", line 87, in _run_code
    exec(code, run_globals)
  File "/tmp/ansible_fortinet.fortios.fortios_system_config_backup_restore_payload_mplamrs7/ansible_fortinet.fortios.fortios_system_config_backup_restore_payload.zip/ansible_collections/fortinet/fortios/plugins/modules/fortios_system_config_backup_restore.py", line 472, in <module>
  File "/tmp/ansible_fortinet.fortios.fortios_system_config_backup_restore_payload_mplamrs7/ansible_fortinet.fortios.fortios_system_config_backup_restore_payload.zip/ansible_collections/fortinet/fortios/plugins/modules/fortios_system_config_backup_restore.py", line 436, in main
TypeError: __init__() missing 1 required positional argument: 'mod'
fatal: [fortigate-01]: FAILED! => {
    "changed": false,
    "module_stderr": "Traceback (most recent call last):\n  File \"/home/ansible/.ansible/tmp/ansible-local-8668osvgufxk/ansible-tmp-1615481963.0092971-8768-3877705280026/AnsiballZ_fortios_system_config_backup_restore.py\", line 102, in <module>\n    _ansiballz_main()\n  File \"/home/ansible/.ansible/tmp/ansible-local-8668osvgufxk/ansible-tmp-1615481963.0092971-8768-3877705280026/AnsiballZ_fortios_system_config_backup_restore.py\", line 94, in _ansiballz_main\n    invoke_module(zipped_mod, temp_path, ANSIBALLZ_PARAMS)\n  File \"/home/ansible/.ansible/tmp/ansible-local-8668osvgufxk/ansible-tmp-1615481963.0092971-8768-3877705280026/AnsiballZ_fortios_system_config_backup_restore.py\", line 40, in invoke_module\n    runpy.run_module(mod_name='ansible_collections.fortinet.fortios.plugins.modules.fortios_system_config_backup_restore', init_globals=None, run_name='__main__', alter_sys=True)\n  File \"/usr/lib/python3.8/runpy.py\", line 207, in run_module\n    return _run_module_code(code, init_globals, run_name, mod_spec)\n  File \"/usr/lib/python3.8/runpy.py\", line 97, in _run_module_code\n    _run_code(code, mod_globals, init_globals,\n  File \"/usr/lib/python3.8/runpy.py\", line 87, in _run_code\n    exec(code, run_globals)\n  File \"/tmp/ansible_fortinet.fortios.fortios_system_config_backup_restore_payload_mplamrs7/ansible_fortinet.fortios.fortios_system_config_backup_restore_payload.zip/ansible_collections/fortinet/fortios/plugins/modules/fortios_system_config_backup_restore.py\", line 472, in <module>\n  File \"/tmp/ansible_fortinet.fortios.fortios_system_config_backup_restore_payload_mplamrs7/ansible_fortinet.fortios.fortios_system_config_backup_restore_payload.zip/ansible_collections/fortinet/fortios/plugins/modules/fortios_system_config_backup_restore.py\", line 436, in main\nTypeError: __init__() missing 1 required positional argument: 'mod'\n",
    "module_stdout": "",
    "msg": "MODULE FAILURE\nSee stdout/stderr for the exact error",
    "rc": 1
}
```

使用最新的預發布版 `fortinet.fortios:2.0.0` 時，我得到：

```shell
ERROR! couldn't resolve module/action 'fortinet.fortios.fortios_system_config_backup_restore'. This often indicates a misspelling, missing collection, or incorrect module path.

The error appears to be in '/home/ansible/backup.yml': line 46, column 7, but may
be elsewhere in the file depending on the exact syntax problem.

The offending line appears to be:

tasks:
  - name: backup global or a_specific_vdom settings
```

在 `~/.ansible/collections/ansible_collections/fortinet/fortios/plugins/modules/` 找不到模組。

#### 使用 1.1.9
