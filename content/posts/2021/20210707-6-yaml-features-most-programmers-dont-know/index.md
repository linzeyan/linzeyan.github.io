---
title: "6 YAML Features most programmers don't know"
date: 2021-07-07T15:08:31+08:00
menu:
  sidebar:
    name: "6 YAML Features most programmers don't know"
    identifier: 6-yaml-features-most-programmers-dont-know
    weight: 10
tags: ["URL", "YAML"]
categories: ["URL", "YAML"]
---

- [6 YAML Features most programmers don't know](https://levelup.gitconnected.com/6-yaml-features-most-programmers-dont-know-164762343af3)

#### There are more examples that are similarly dangerous as Tom Ritchford pointed out

- `013` is mapped to 11 as the leading zero triggers the octal notation
- `4:30` is mapped to 270. Max Werner Kaul-Gothe and Niklas Baumstark informed me that this is automatically converted to minutes (or seconds?) as it is interpreted as a duration: `4*60 + 30 = 270` . Interestingly, this pattern still "works" with `1:1:1:1:1:1:1:1:4:30` .

#### Multi-Line String

```yaml
mail_signature: |
  Martin Thoma
  Tel. +49 123 4567
```

```json
{ "mail_signature": "Martin Thoma\nTel. +49 123 4567" }
```

#### Anchor

> The `&` defined a variable `emailAddress` with the value `"info@example.de"`. The `*` then indicated that the name of a variable follows.

```yaml
email: &emailAddress "info@example.de"
id: *emailAddress
```

```json
{ "email": "info@example.de", "id": "info@example.de" }
```

##### You can do the same with mappings

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

#### Type Casting

> The double bang `!!` has a special meaning in YAML. It is called "secondary tag handle" and a shorthand for `!tag:yaml.org,2002`

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
