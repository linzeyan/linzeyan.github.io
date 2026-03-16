---
title: "Tools"
date: 2026-03-15T17:52:24+08:00
menu:
  sidebar:
    name: "Tools"
    identifier: tools-github-command-lines-tools-20260315
    weight: 10
tags: ["Links", "Tools", "command line"]
categories: ["Links", "Tools", "command line"]
---

- [tirith](https://github.com/sheeki03/tirith): Tirith guards the gate and intercepts suspicious URLs, ANSI injection, and pipe-to-shell attacks before they execute.
- [subtrace](https://github.com/subtrace/subtrace): Inspect HTTP requests in any server with just a single command.
- [prek](https://github.com/j178/prek): ⚡ Better `pre-commit`, re-engineered in Rust
- [sandbox-exec](https://igorstechnoclub.com/sandbox-exec/): macOS's Little-Known Command-Line Sandboxing Tool
- [babyshark](https://github.com/vignesh07/babyshark): Flows-first PCAP TUI (case files, gorgeous UX).
- [llmfit](https://github.com/AlexsJones/llmfit): A terminal tool that right-sizes LLM models to your system's RAM, CPU, and GPU. Detects your hardware, scores each model across quality, speed, fit, and context dimensions, and tells you which ones will actually run well on your machine.

## sandbox-exec(Deprecated)

> `sandbox-exec -f profile.sb command_to_run`

### example

#### Sandboxed Terminal Session

```shell
# Create terminal-sandbox.sb:
(version 1)
(allow default)
(deny network*)
(deny file-read-data (regex "^/Users/[^/]+/(Documents|Pictures|Desktop)"))

# Run a sandboxed terminal
sandbox-exec -f terminal-sandbox.sb zsh
```

#### Using Pre-built System Profiles

> macOS includes several pre-built sandbox profiles in `/System/Library/Sandbox/Profiles`

```shell
# Run a command with the system's no-network profile
sandbox-exec -f /System/Library/Sandbox/Profiles/weatherd.sb command
```

### debugging

Using the Console App

1. Open Console.app (Applications → Utilities → Console)
2. Search for "sandbox" and your application name
3. Look for lines containing "deny" to identify blocked operations
4. Using Terminal for Real-time Logs
   1. For real-time monitoring of sandbox violations: `log stream --style compact --predicate 'sender=="Sandbox"'`
   2. To filter for a specific application: `log stream --style compact --predicate 'sender=="Sandbox" and eventMessage contains "python"'`

### advanced

#### Creating a Sandbox Alias

> but did the same for UI applications it didn't work for some reason
>
> `sandbox-no-network /Applications/Firefox.app/Contents/MacOS/firefox`

```shell
# Add to ~/.zshrc or ~/.bash_profile
alias sandbox-no-network='sandbox-exec -p "(version 1)(allow default)(deny network*)"'

# Then use it as:
sandbox-no-network curl -v https://google.com
```

#### Importing Existing Profiles

```shell
(version 1)
(import "/System/Library/Sandbox/Profiles/bsd.sb")
(deny network*)  # Add additional restrictions
```
