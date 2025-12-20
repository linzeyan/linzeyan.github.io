---
title: "Python's many command-line utilities"
date: 2024-07-06T20:39:01+08:00
menu:
  sidebar:
    name: "Python's many command-line utilities"
    identifier: python-pythons-many-command-line-utilities
    weight: 10
tags: ["URL", "Python"]
categories: ["URL", "Python"]
hero: images/hero/python.png
---

- [Python's many command-line utilities](https://www.pythonmorsels.com/cli-tools/)

These are Python's most helpful general-purpose command-line tools.

| Command                 | Purpose                      | More                                                                             |
| ----------------------- | ---------------------------- | -------------------------------------------------------------------------------- |
| `python -m http.server` | Start a simple web server    | [Video](https://www.pythonmorsels.com/http-server/)                              |
| `python -m webbrowser`  | Launch your web browser      | [Docs](https://docs.python.org/3/library/webbrowser.html#command-line-interface) |
| `python -m json.tool`   | Nicely format JSON data      | [Docs](https://docs.python.org/3/library/json.html#module-json.tool)             |
| `python -m calendar`    | Show a command-line calendar | [Docs](https://docs.python.org/3/library/calendar.html#command-line-usage)       |

### `http.server`

Running the `http.server` module as a script will start a web server on port 8000 that hosts files from the current directory. I use this _all the time_ to preview Sphinx documentation sites (especially when using Sphinx's `dirhtml` option which is _all about_ subdirectories of `index.html` files).

```text
$ python -m http.server
Serving HTTP on 0.0.0.0 port 8000 (http://0.0.0.0:8000/) ...
```

### `webbrowser`

Running the `webbrowser` module as a script will open a given URL in your default web browser. For example, this would open the page https://pseudorandom.name:

```text
$ python -m webbrowser pseudorandom.name
```

### `json.tool`

Python's `json.tool` module can be run as a script to parse a JSON document and print out a version that's formatted nicely for human readability.

```shell
$ python -m json.tool /home/trey/Downloads/download.json
[
    {
        "title": "Python's walrus operator",
        "is_premium": false,
        "url": "/using-walrus-operator/"
    },
    {
        "title": "Refactoring long boolean expressions",
        "is_premium": true,
        "url": "/refactoring-boolean-expressions/"
    }
]
```

### `calendar`

Running the `calendar` module as a script will print a calendar of the current year by default. It also accepts various arguments to customize its output. Here's a calendar of just one month:

```text
$ python -m calendar 2024 04
     April 2024
Mo Tu We Th Fr Sa Su
 1  2  3  4  5  6  7
 8  9 10 11 12 13 14
15 16 17 18 19 20 21
22 23 24 25 26 27 28
29 30
```

Those 4 scripts are general-purpose tools that I find helpful on _any_ machine. Python also includes a number of tools that are commonly available (or easily installable) on Linux and Mac machines.

## Especially handy on Windows machines

Running Python on Windows? Or running Python on a Linux/Mac machine without the ability to easily install common command-line utilities like `uuid`, `sqlite3` and `gzip`?

These tools are all equivalent to command-line tools that are common on many Linux machines, though the equivalent Linux commands are usually more powerful and more user-friendly.

| Command                 | Purpose                              | More                                                                          |
| ----------------------- | ------------------------------------ | ----------------------------------------------------------------------------- |
| `python3.12 -m uuid`    | Like `uuidgen` CLI utility           | [Docs](https://docs.python.org/3/library/uuid.html#command-line-usage)        |
| `python3.12 -m sqlite3` | Like `sqlite3` CLI utility           | [Docs](https://docs.python.org/3/library/sqlite3.html#command-line-interface) |
| `python -m zipfile`     | Like `zip` & `unzip` CLI utilities   | [Docs](https://docs.python.org/3/library/zipfile.html#command-line-interface) |
| `python -m gzip`        | Like `gzip` & `gunzip` CLI utilities | [Docs](https://docs.python.org/3/library/gzip.html#command-line-interface)    |
| `python -m tarfile`     | Like the `tar` CLI utility           | [Docs](https://docs.python.org/3/library/tarfile.html#command-line-interface) |
| `python -m base64`      | Like the `base64` CLI utility        |                                                                               |
| `python -m ftplib`      | Like the `ftp` utility               |                                                                               |
| `python -m smtplib`     | Like the `sendmail` utility          |                                                                               |
| `python -m poplib`      | Like using `curl` to read email      |                                                                               |
| `python -m imaplib`     | Like using `curl` to read email      |                                                                               |
| `python -m telnetlib`   | Like the `telnet`utility             |                                                                               |

## Analyzing Python code

Python also includes a handful of other Python-related tools that are specifically for analyzing Python code.

If you wanted to analyze some Python code to see how it ticks, these tools can be useful.

| Command              | Purpose                                | More                                                                          |
| -------------------- | -------------------------------------- | ----------------------------------------------------------------------------- |
| `python -m tokenize` | Break Python module into "tokens"      | [Docs](https://docs.python.org/3/library/tokenize.html#command-line-usage)    |
| `python -m ast`      | Show abstract syntax tree for code     | [Docs](https://docs.python.org/3/library/ast.html#command-line-usage)         |
| `python -m dis`      | Disassemble Python code to bytecode    | [Docs](https://docs.python.org/3/library/dis.html#command-line-interface)     |
| `python -m inspect`  | inspect source code of a Python object | [Docs](https://docs.python.org/3/library/inspect.html#command-line-interface) |
| `python -m pyclbr`   | See overview of a module's objects     |                                                                               |

## Just for fun

These are Python Easter Eggs that work as Python scripts.

| Command                 | Purpose                            |
| ----------------------- | ---------------------------------- |
| `python -m __hello__`   | Print `Hello world!`               |
| `python -m this`        | Display the Zen of Python (PEP 20) |
| `python -m antigravity` | Open XKCD 353 in a web browser     |
| `python -m turtledemo`  | See `turtle` module demos          |
