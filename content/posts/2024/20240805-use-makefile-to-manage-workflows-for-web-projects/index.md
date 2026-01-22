---
title: "Makefiles for Web Projects: Manage Your Environment Workflow"
date: 2024-08-05T17:21:24+08:00
menu:
  sidebar:
    name: "Makefiles for Web Projects: Manage Your Environment Workflow"
    identifier: shell-use-makefile-to-manage-workflows-for-web-projects
    weight: 10
tags: ["Links", "BASH", "SHELL"]
categories: ["Links", "BASH", "SHELL"]
hero: images/hero/shell.png
---

- [Makefiles for Web Projects: Manage Your Environment Workflow](https://blog.goodjack.tw/2023/01/use-makefile-to-manage-workflows-for-web-projects.html)
- [How I stopped worrying and loved Makefiles](https://gagor.pro/2024/02/how-i-stopped-worrying-and-loved-makefiles/)

**Note: Makefile indentation must use tabs, otherwise you'll get syntax errors.**

## The Core of a Makefile: Targets

```makefile
up:
	cp .env.example .env
	docker compose up -d workspace

stop:
	docker compose stop

zsh:
	docker compose exec workspace zsh
```

- This example has three targets: `up`, `stop`, and `zsh`. By default, Make treats the first target as the [Goal](https://www.gnu.org/software/make/manual/html_node/Goals.html) (it cannot start with a dot), which is the project's primary workflow. In this case, `make` and `make up` do the same thing.
- But the copy step above is not a typical Make use case. Make shines at deciding whether each target needs to run. For example, we often store secrets in `.env`. If `.env` already exists, we shouldn't overwrite it by copying `.env.example` again. In that case, we can make `.env` a target:

```makefile
up: .env
	docker compose up -d workspace

.env:
	cp .env.example .env
```

- By default, target names are treated as filenames. The name "make" implies building a target; it will only execute the target's recipe when the conditions are met (like the file not existing).
  - In this example, when you run the `up` target, if `.env` doesn't exist it will run the `.env` target first to create it, then start the workspace container. If `.env` already exists, it skips the `.env` target and starts the container directly.
  - Likewise, if there is a file named `up` in the directory, the `up` target won't run. You can define [Phony Targets](https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html) to tell Make that certain targets aren't filenames, but named workflows instead:

```makefile
.PHONY: up stop zsh
```

## Add Some Variables

Make supports variables ([Variable](https://www.gnu.org/software/make/manual/html_node/Setting.html)). Following common Unix environment variable conventions, we usually write them in SCREAMING_SNAKE_CASE. When used, variables are wrapped in `$()`.

For example, to start specific containers, you can rewrite `up` like this:

```makefile
CONTAINERS ?= workspace mysql

up:
	docker compose up -d $(CONTAINERS)
.PHONY: up
```

Here we define `CONTAINERS`. If we don't set it, it defaults to `workspace mysql`. So `make up` will execute:

```bash
docker compose up -d workspace mysql
```

To change the value, say to start a Redis container, run:

```bash
make up CONTAINERS="redis"
```

Make will then execute:

```bash
docker compose up -d redis
```

Another common pattern is to use variables to pass Docker Compose options, for example:

```makefile
CONTAINER_USER ?= default
CONTAINERS ?= workspace

zsh:
	docker compose exec --user=$(CONTAINER_USER) $(CONTAINERS) zsh
.PHONY: zsh
```

By default, it enters the container as `default`. If you want `root`, run:

```bash
make zsh CONTAINER_USER="root"
```

Make will execute the command using `root`:

```bash
docker compose exec --user=root workspace zsh
```

## Add Some Conditionals

Need slightly more complex logic? Make supports conditionals ([Conditional](https://www.gnu.org/software/make/manual/html_node/Conditional-Syntax.html)), most commonly `ifeq` and `ifneq`. Here's an example:

```makefile
IS_ROOT ?= false

zsh:
ifeq ($(IS_ROOT), true)
	docker compose exec --user=root workspace zsh
else
	docker compose exec workspace zsh
endif
.PHONY: zsh
```

In this example, when you run `make zsh`, Make checks whether `$(IS_ROOT)` equals `"true"`. If it does, it enters as root; otherwise, it uses the default user.

Note: only the commands you want to execute should be tab-indented. The conditional statements must remain unindented because they are part of Make syntax. Also, Make does not have a boolean type, so this is just a string comparison.

## Control Output Strings

You can add some output to make workflows easier to follow. Make provides [Control Function](https://www.gnu.org/software/make/manual/html_node/Make-Control-Functions.html), such as `info`:

```makefile
IS_ROOT ?= false

zsh:
ifeq ($(IS_ROOT), true)
	$(info Enter workspace as root)
	docker compose exec --user=root workspace zsh
else
	$(info Enter workspace as default user)
	docker compose exec workspace zsh
endif
.PHONY: zsh
```

Now when you run `make zsh`, you'll see output like:

```bash
Enter workspace as default user
docker compose exec workspace zsh
# Docker Compose output follows
```

This lets you customize what Make prints. There are also `warning` and `error` outputs; see the docs for details.

If you don't want commands to clutter the output, you can prefix them with `@` to suppress [Echoing](https://www.gnu.org/software/make/manual/html_node/Echoing.html). Here is the classic Hello World example rewritten:

```makefile
hello:
	@echo "Hello World"
.PHONY: hello
```

Now `make hello` outputs:

```bash
Hello World
```

## Combined Pattern: Manage Different Environments

At this point we've covered the basics. Next, let's discuss managing different environment workflows.

Suppose we have a development environment (`dev`) and a production environment (`production`), with the following startup flow:

- Both environments require a `.env` file. If it doesn't exist, dev copies from `.env.example` while production copies from `.env.example.production`.
- Both environments start the workspace container; dev also starts Redis.
- Show the current environment name when starting.
- Don't show commands in output; use English descriptions instead.

Here's one possible Makefile:

```makefile
ENVIRONMENT ?= dev

up: .env
	$(info Current environment: $(ENVIRONMENT))
	$(info Start workspace)
	docker compose up -d workspace
ifeq ($(ENVIRONMENT), dev)
	$(info Start redis)
	docker compose up -d redis
endif
.PHONY: up

.env:
	$(info .env does not exist, create .env)
ifeq ($(ENVIRONMENT), dev)
	cp .env.example .env
else
	cp .env.example.production .env
endif
```

Now you can build workflows for different environments. You can also add phony targets to organize common commands, like `stop` and `zsh` from earlier, or run Laravel tests:

```makefile
test:
	docker compose exec workspace php artisan test
.PHONE: test
```

---

### Using Comments

Use `#` just like in shell scripts.

Note that if you put a `#` after a tab-indented command line, it will be treated as a shell comment.

### Get the Current Target Name

Use `$@`.

```makefile
up:
	$(info Current target is $@) # displays up
	docker compose up -d $(CONTAINERS)
.PHONY: up
```

### Mixing Make Variables and Shell Variables

If you need to use a shell variable inside a command, escape `$` as `$$` rather than `\$`.

### Variable Values Can Be Shell Command Output

Example:

```makefile
MY_IP = $(shell curl -s ipinfo.io/ip)

get-ip:
	$(info My IP: $(MY_IP))
.PHONY: get-ip
```

### Variables Can Be Extended

You can use `+=` and `ifeq` to manage environments more easily:

```makefile
ENVIRONMENT ?= dev
CONTAINERS ?= workspace

ifeq ($(ENVIRONMENT), dev)
# Force redis to start in dev
CONTAINERS += redis
endif

up:
	$(info Current environment: $(ENVIRONMENT))
	$(info Start $(CONTAINERS))
	# dev starts workspace and redis by default
	docker compose up -d $(CONTAINERS)
.PHONY: up
```

### Want to Extract a Function?

If you repeat command prefixes, extract them as variables. You can also extract arguments into variables to make them easy to override:

```makefile
COMPOSE_FLAGS ?= -d
EXEC_CONTAINER ?= workspace
EXEC ?= docker compose exec $(COMPOSE_FLAGS) $(EXEC_CONTAINER)

zsh:
	$(EXEC) zsh
.PHONY: zsh

bash:
	$(EXEC) bash
.PHONY: bash
```

You can then run:

```bash
make zsh COMPOSE_FLAGS="-d -T"
```

You can also use `+=` to combine flags.

Beyond simple variables, Make supports multi-line variables (`define`) combined with the [Call Function](https://www.gnu.org/software/make/manual/html_node/Call-Function.html) `$(call [variable])`.

### Other Useful Functions

There are many, such as `filter`, `subst`, `realpath`, and more. See the [Function](https://www.gnu.org/software/make/manual/html_node/Functions.html) docs for details.

A handy index of built-in functions, variables, and directives is [here](https://www.gnu.org/software/make/manual/html_node/Name-Index.html).

### Run a Prerequisite in the Middle

Use [Double-Colon Rules](https://www.gnu.org/software/make/manual/html_node/Double_002dColon.html). Change `:` to `::` and split the target in two parts. Example:

```makefile
up::
	$(info I want to show this before making .env)
up:: .env
	$(info Start workspace after .env is created)
	docker compose up -d workspace
.PHONY: up

.env:
	cp .env.example .env
```

### More Prerequisite Patterns

You can use variables to decide prerequisites, and targets can be paths:

```makefile
PREREQUISITE ?= .env ../laravel/.env

up: $(PREREQUISITE)
	docker compose up -d workspace
.PHONY: up

.env:
	# Docker .env
	cp .env.example .env

../laravel/.env:
	# .env from the sibling directory
	cp ../laravel/.env.example ../laravel/.env
```

### Advanced Variable Usage

Variable assignment also supports `=` and `:=`.

Targets can be assigned values by placing them before the target name (see the example). This style can be hard to maintain, so I avoid it.

Makefile example 1:

```makefile
TEXT ?= default

hello: hey
	$(info hello: $(TEXT))
.PHONY: hello

hey: TEXT ?= hey
hey:
	$(info hey: $(TEXT))
.PHONY: hey
```

Example 1 output: since `hey` thinks `TEXT` was already set, it won't override it:

```bash
# Run make
hey: default
hello: default

# Run make TEXT=Jack
hey: Jack
hello: Jack
```

Makefile example 2: change `?=` to `=` for `hey`:

```makefile
TEXT ?= default

hello: hey
	$(info hello: $(TEXT))
.PHONY: hello

hey: TEXT = hey
hey:
	$(info hey: $(TEXT))
.PHONY: hey
```

Example 2 output: now `hello` isn't affected:

```bash
# Run make
hey: hey
hello: default
```

If you assign values in the workflow, `=` expands first and keeps values consistent throughout the run. Here's example 3, assigning `TEXT` in `hello`:

```makefile
TEXT ?= default

hello: TEXT = hello
hello: hey
	$(info hello: $(TEXT))
.PHONY: hello

hey:
	$(info hey: $(TEXT))
.PHONY: hey
```

Example 3 output: because it's `=`, even though `hello` runs later it still affects `hey`:

```bash
# Run make
hey: hello
hello: hello
```

The Make manual also has an [official example](https://www.gnu.org/software/make/manual/html_node/Recursive-Assignment.html) explaining how `=` expands:

```makefile
foo = $(bar)
bar = $(ugh)
ugh = Huh?

all:
	@echo $(foo) # output is Huh?
```

The `:=` operator is closer to normal assignment in programming languages. If we change `=` to `:=` in the example above:

```makefile
foo := $(bar)
bar := $(ugh)
ugh := Huh?

all:
	@echo $(foo) # output is empty
```
