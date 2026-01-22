---
title: "多數程式設計師不知道的 6 個 YAML 特性"
date: 2021-07-07T15:08:31+08:00
menu:
  sidebar:
    name: "多數程式設計師不知道的 6 個 YAML 特性"
    identifier: 6-yaml-features-most-programmers-dont-know
    weight: 10
tags: ["Links", "YAML"]
categories: ["Links", "YAML"]
---

- [多數程式設計師不知道的 6 個 YAML 特性](https://levelup.gitconnected.com/6-yaml-features-most-programmers-dont-know-164762343af3)

#### 還有更多類似的危險例子，正如 Tom Ritchford 所指出

- `013` 會被對應為 11，因為前導 0 會觸發八進位表示法
- `4:30` 會被對應為 270。Max Werner Kaul-Gothe 與 Niklas Baumstark 告訴我，這會被自動轉換為分鐘（或秒）並被視為一段持續時間：`4*60 + 30 = 270`。有趣的是，這個模式在 `1:1:1:1:1:1:1:1:4:30` 仍然「可運作」。

#### 多行字串

```yaml
mail_signature: |
  Martin Thoma
  Tel. +49 123 4567
```

```json
{ "mail_signature": "Martin Thoma\nTel. +49 123 4567" }
```

#### 錨點

> `&` 會定義一個名為 `emailAddress` 的變數，值為 `"info@example.de"`。`*` 則表示接著的是變數名稱。

```yaml
email: &emailAddress "info@example.de"
id: *emailAddress
```

```json
{ "email": "info@example.de", "id": "info@example.de" }
```

##### 也可以對映射這樣做

```yaml
foo: &default_settings
  db:
    host: localhost
    name: main_db
    port: 1337
  email:
    admin: admin@example.com
prod:
  <<: *default_settings
  app:
    port: 80
dev: *default_settings
```

```json
{
	"foo": {
		"db": { "host": "localhost", "name": "main_db", "port": 1337 },
		"email": { "admin": "admin@example.com" }
	},
	"prod": {
		"app": { "port": 80 },
		"db": { "host": "localhost", "name": "main_db", "port": 1337 },
		"email": { "admin": "admin@example.com" }
	},
	"dev": {
		"db": { "host": "localhost", "name": "main_db", "port": 1337 },
		"email": { "admin": "admin@example.com" }
	}
}
```

#### 型別轉換

> 雙驚嘆號 `!!` 在 YAML 中有特殊意義。它稱為「secondary tag handle」，是 `!tag:yaml.org,2002` 的簡寫。

```yaml
tuple_example: !!python/tuple
  - 1337
  - 42
set_example: !!set { 1337, 42 }
date_example: !!timestamp 2020-12-31
```

```python
import yaml
import pprint
with open("example.yaml") as fp:
    data = fp.read()
pp = pprint.PrettyPrinter(indent=4)
pased = yaml.unsafe_load(data)
pp.pprint(pased)
```

```json
{   'date_example': datetime.date(2020, 12, 31),
    'set_example': {1337, 42},
    'tuple_example': (1337, 42)}
```

- [PyYaml](https://pyyaml.org/wiki/PyYAMLDocumentation#yaml-tags-and-python-types)

```
## Standard YAML tags
YAML               Python 3
!!null             None
!!bool             bool
!!int              int
!!float            float
!!binary           bytes
!!timestamp        datetime.datetime
!!omap, !!pairs    list of pairs
!!set              set
!!str              str
!!seq              list
!!map              dict
## Python-specific tags
YAML               Python 3
!!python/none      None
!!python/bool      bool
!!python/bytes     bytes
!!python/str       str
!!python/unicode   str
!!python/int       int
!!python/long      int
!!python/float     float
!!python/complex   complex
!!python/list      list
!!python/tuple     tuple
!!python/dict      dict
## Complex Python tags
!!python/name:module.name         module.name
!!python/module:package.module    package.module
!!python/object:module.cls        module.cls instance
!!python/object/new:module.cls    module.cls instance
!!python/object/apply:module.f    value of f(...)
```
