---
title: "Articles"
date: 2026-04-15T09:22:42+08:00
menu:
  sidebar:
    name: "Articles"
    identifier: articles-recent-20260415
    weight: 10
tags: ["Links", "macOS", "Go", "Meilisearch", "Claude Code", "Linux", "Taiwan"]
categories:
  ["Links", "macOS", "Go", "Meilisearch", "Claude Code", "Linux", "Taiwan"]
---

- [SingleFlight](https://ganhua.wang/singleflight)
- [macOS 奇怪的安全扫码机制](https://catcoding.me/p/apple-gatekeeper-scan/)
- [Agentic Design Patterns](https://github.com/xindoo/agentic-design-patterns)
- [你不知道的 Claude Code：架构、治理与工程实践](https://tw93.fun/2026-03-12/claude.html)
- [你不知道的 Agent：原理、架构与工程实践](https://tw93.fun/2026-03-21/agent.html)
- [rtk: CLI proxy that reduces LLM token consumption by 60-90% on common dev commands. Single Rust binary, zero dependencies](https://github.com/rtk-ai/rtk)
- [difftastic: a structural diff that understands syntax](https://github.com/Wilfred/difftastic)
- [I Ditched Elasticsearch for Meilisearch. Here's What Nobody Tells You.](https://www.anisafifi.com/en/blog/i-ditched-elasticsearch-for-meilisearch-heres-what-nobody-tells-you/)
- [策展島嶼的深度敘事](https://taiwan.md/): https://github.com/frank890417/taiwan-md
- [Linux 中网络包的一生](https://colobu.com/2025/11/01/Linux%20%E4%B8%AD%E7%BD%91%E7%BB%9C%E5%8C%85%E7%9A%84%E4%B8%80%E7%94%9F/index/)
- [Gitingest: Turn any Git repository into a prompt-friendly text ingest for LLMs.](https://github.com/coderamp-labs/gitingest)
- [7 More Common Mistakes in Architecture Diagrams](https://www.ilograph.com/blog/posts/more-common-diagram-mistakes/)
- [Use Cases](https://claude.com/resources/use-cases)
- [Superpowers](https://github.com/obra/superpowers): Superpowers is a complete software development workflow for your coding agents, built on top of a set of composable "skills" and some initial instructions that make sure your agent uses them.
- [everything-claude-code](https://github.com/affaan-m/everything-claude-code): The agent harness performance optimization system. Skills, instincts, memory, security, and research-first development for Claude Code, Codex, Opencode, Cursor and beyond.
- [Agency Agents](https://github.com/msitarzewski/agency-agents): A complete AI agency at your fingertips - From frontend wizards to Reddit community ninjas, from whimsy injectors to reality checkers. Each agent is a specialized expert with personality, processes, and proven deliverables.
- [MiroFish: A Simple and Universal Swarm Intelligence Engine, Predicting Anything.](https://github.com/666ghj/MiroFish)
- [Lightpanda Browser: the headless browser designed for AI and automation](https://github.com/lightpanda-io/browser)
- [Anatomy of the .claude/ Folder](https://blog.dailydoseofds.com/p/anatomy-of-the-claude-folder)
- [Cocoa-Way: Native macOS Wayland Compositor written in Rust using Smithay. Experience seamless Linux app streaming on macOS without XQuartz.](https://github.com/J-x-Z/cocoa-way)
- [Pretext: Fast, accurate & comprehensive text measurement & layout](https://github.com/chenglou/pretext)
- [Ghostmoon.app: A Swiss Army Knife for your macOS menu bar](https://www.mgrunwald.com/ghostmoon/)
- [CodingFont: A game to help you pick a coding font](https://www.codingfont.com/)
- [The Git Commands I Run Before Reading Any Code](https://piechowski.io/post/git-commands-before-reading-code/)
- [Winhance: Application designed to optimize, customize and enhance your Windows experience.](https://github.com/memstechtips/Winhance)
- [Native Instant Space Switching on MacOS](https://arhan.sh/blog/native-instant-space-switching-on-macos/)
- [FluidCAD: Write CAD models in JavaScript. See the result in real time.](https://github.com/Fluid-CAD/FluidCAD)
- [Awesome DESIGN.md: Copy a DESIGN.md into your project, tell your AI agent "build me a page that looks like this" and get pixel-perfect UI that actually matches.](https://github.com/VoltAgent/awesome-design-md)
- [graphify](https://github.com/safishamsi/graphify): AI coding assistant skill (Claude Code, Codex, OpenCode, Cursor, Gemini CLI, GitHub Copilot CLI, OpenClaw, Factory Droid, Trae, Google Antigravity). Turn any folder of code, docs, papers, images, or videos into a queryable knowledge graph

---

## SingleFlight

```go
package analyzer

import (
    "context"
    "sync"

    "golang.org/x/sync/singleflight"
    "github.com/nathan/stock_bot/internal/storage"
)

type AnalysisService struct {
    genai      *GenAIClient
    d1Client   *storage.D1Client
    stockCache map[string]*StockAnalysisResult
    mu         sync.RWMutex
    sf         singleflight.Group
}

func (s *AnalysisService) analyzeStock(ctx context.Context, code, name string) (*StockAnalysisResult, error) {
    // 1. 第一層防護：檢查記憶體快取 (L1 Cache)
    s.mu.RLock()
    if result, ok := s.stockCache[code]; ok {
        s.mu.RUnlock()
        return result, nil
    }
    s.mu.RUnlock()

    // 2. 第二層防護：Singleflight (請求合併)
    key := "stock:" + code
    v, err, _ := s.sf.Do(key, func() (interface{}, error) {
        // 3. 執行昂貴的邏輯 (DB + Gemini API)
        result, err := s.doAnalyzeStock(ctx, code, name)
        if err != nil {
            return nil, err
        }

        // 4. 寫入快取 (務必在 singleflight 內部完成，防止下一波瞬間擊穿)
        s.mu.Lock()
        s.stockCache[code] = result
        s.mu.Unlock()

        return result, nil
    })

    if err != nil {
        return nil, err
    }
    return v.(*StockAnalysisResult), nil
}
func (s *AnalysisService) doAnalyzeStock(ctx context.Context, code, name string) (*StockAnalysisResult, error) {
    // 建立一個子 Context 用於內部的多個非同步任務
    g, ctx := errgroup.WithContext(ctx)

    var dbData string
    var aiResult string

    // 任務 1：查資料庫
    g.Go(func() error {
        // 隨時檢查 Context 是否已取消
        select {
        case <-ctx.Done():
            return ctx.Err()
        default:
            // 模擬資料庫查詢
            dbData = "Historical Data"
            return nil
        }
    })

    // 任務 2：呼叫 Gemini API
    g.Go(func() error {
        // 將 ctx 傳入 API 客戶端，讓它能跟隨整體的超時控制
        res, err := s.genai.Generate(ctx, "Analyze this: "+code)
        if err != nil {
            return err
        }
        aiResult = res
        return nil
    })

    // 等待所有任務完成或其中一個出錯
    if err := g.Wait(); err != nil {
        return nil, err
    }

    return &StockAnalysisResult{Data: dbData, Analysis: aiResult}, nil
}
func (s *AnalysisService) analyzeStockWithMetrics(ctx context.Context, code string) (*StockAnalysisResult, error) {
    key := "stock:" + code
    v, err, shared := s.sf.Do(key, func() (interface{}, error) {
        return s.doAnalyzeStock(ctx, code, "Name")
    })

    // 紀錄監控指標：分辨是「原始呼叫」還是「共享結果」
    status := "original"
    if shared {
        status = "shared"
    }

    s.sfCounter.Add(ctx, 1, metric.WithAttributes(
        attribute.String("stock_code", code),
        attribute.String("type", status),
    ))

    if err != nil {
        return nil, err
    }
    return v.(*StockAnalysisResult), nil
}

```

---

## macOS 奇怪的安全扫码机制

```shell
# 查看最近的 syspolicyd 扫描记录
log show --predicate 'subsystem == "com.apple.syspolicy.exec"' --last 5m --style compact | grep performScan
```

`System Settings → Privacy & Security → Full Disk Access，给 VS Code 完全磁盘访问权限有效`

---

## 你不知道的 Claude Code：架构、治理与工程实践

| 层                         | 职责                                     |
| -------------------------- | ---------------------------------------- |
| CLAUDE.md / rules / memory | 长期上下文，告诉 Claude "是什么"         |
| Tools / MCP                | 动作能力，告诉 Claude "能做什么"         |
| Skills                     | 按需加载的方法论，告诉 Claude "怎么做"   |
| Hooks                      | 强制执行某些行为，不依赖 Claude 自己判断 |
| Subagents                  | 隔离上下文的工作者，负责受控自治         |
| Verifiers                  | 验证闭环，让输出可验、可回滚、可审计     |

### 底层是怎么运行的

```
收集上下文 → 采取行动 → 验证结果 → [完成 or 回到收集]
     ↑                    ↓
  CLAUDE.md          Hooks / 权限 / 沙箱
  Skills             Tools / MCP
  Memory
```

### 概念边界：搞清楚六个概念，别混用

> 给 Claude 新动作能力用 Tool/MCP，给它一套工作方法用 Skill，需要隔离执行环境用 Subagent，要强制约束和审计用 Hook，跨项目分发用 Plugin。

### 上下文工程：最重要的系统约束

```
200K 总上下文
├── 固定开销 (~15-20K)
│   ├── 系统指令: ~2K
│   ├── 所有启用的 Skill 描述符: ~1-5K
│   ├── MCP Server 工具定义: ~10-20K  ← 最大隐形杀手
│   └── LSP 状态: ~2-5K
│
├── 半固定 (~5-10K)
│   ├── CLAUDE.md: ~2-5K
│   └── Memory: ~1-2K
│
└── 动态可用 (~160-180K)
    ├── 对话历史
    ├── 文件内容
    └── 工具调用结果
```

#### 推荐的上下文分层

```
始终常驻    → CLAUDE.md：项目契约 / 构建命令 / 禁止事项
按路径加载  → rules：语言 / 目录 / 文件类型特定规则
按需加载    → Skills：工作流 / 领域知识
隔离加载    → Subagents：大量探索 / 并行研究
不进上下文  → Hooks：确定性脚本 / 审计 / 阻断
```

#### 上下文最佳实践

- 保持 `CLAUDE.md` 短、硬、可执行，优先写命令、约束、架构边界。Anthropic 官方自己的 `CLAUDE.md` 大约只有 2.5K tokens，可以参考
- 把大型参考文档拆到 Skills 的 supporting files，不要塞进 SKILL.md 正文
- 使用 `.claude/rules/` 做路径/语言规则，不让根 `CLAUDE.md` 承担所有差异
- 长会话主动用 `/context` 观察消耗，不要等系统自动压缩后再补救

#### Tool Output 噪声：另一个隐形上下文杀手

Claude 真正需要知道的就是「过了还是挂了，挂在哪里」，其他都是噪声。它通过 Hook 透明重写命令，对 Claude Code 来说完全无感。RTK 干的就是这件事，只是覆盖面更广，不用每条命令自己加 `| head -30`，项目开源在 [GitHub](https://github.com/rtk-ai/rtk)。

#### 压缩机制的陷阱

```markdown
### Compact Instructions

When compressing, preserve in priority order:

1. Architecture decisions (NEVER summarize)
2. Modified files and their key changes
3. Current verification status (pass/fail)
4. Open TODOs and rollback notes
5. Tool outputs (can delete, keep pass/fail only)
```

### Skills 设计：不是模板库，是用的时候才加载的工作流

#### 好 Skill 应该满足什么

- 描述要让模型知道"何时该用我"，而不是"我是干什么的"，这两个差很多
- 有完整步骤、输入、输出和停止条件，别写了个开头没有结尾
- 正文只放导航和核心约束，大资料拆到 supporting files 里
- 有副作用的 Skill 要显式设置 `disable-model-invocation: true`，不然 Claude 会自己决定要不要跑

#### Skill 怎么做到"按需加载"

Claude Code 团队在内部设计中反复强调 "progressive disclosure"，意思不是让模型一次性看到所有信息，而是先获得索引和导航，再按需拉取细节：

- `SKILL.md` 负责定义任务语义、边界和执行骨架
- supporting files 负责提供领域细节
- 脚本负责确定性收集上下文或证据

```
.claude/skills/
└── incident-triage/
    ├── SKILL.md
    ├── runbook.md
    ├── examples.md
    └── scripts/
        └── collect-context.sh
```

#### Skill 的三种典型类型

**检查清单型（质量门禁）**

```markdown
---
name: release-check
description: Use before cutting a release to verify build, version, and smoke test.
---

## Pre-flight (All must pass)

- [ ] `cargo build --release` passes
- [ ] `cargo clippy -- -D warnings` clean
- [ ] Version bumped in Cargo.toml
- [ ] CHANGELOG updated
- [ ] `kaku doctor` passes on clean env

## Output

Pass / Fail per item. Any Fail must be fixed before release.
```

**工作流型（标准化操作）**

```markdown
---
name: config-migration
description: Migrate config schema. Run only when explicitly requested.
disable-model-invocation: true
---

## Steps

1. Backup: `cp ~/.config/kaku/config.toml ~/.config/kaku/config.toml.bak`
2. Dry run: `kaku config migrate --dry-run`
3. Apply: remove `--dry-run` after confirming output
4. Verify: `kaku doctor` all pass

## Rollback

`cp ~/.config/kaku/config.toml.bak ~/.config/kaku/config.toml`
```

**领域专家型（封装决策框架）**

```markdown
---
name: runtime-diagnosis
description: Use when kaku crashes, hangs, or behaves unexpectedly at runtime.
---

## Evidence Collection

1. Run `kaku doctor` and capture full output
2. Last 50 lines of `~/.local/share/kaku/logs/`
3. Plugin state: `kaku --list-plugins`

## Decision Matrix

| Symptom            | First Check                       |
| ------------------ | --------------------------------- |
| Crash on startup   | doctor output → Lua syntax error  |
| Rendering glitch   | GPU backend / terminal capability |
| Config not applied | Config path + schema version      |

## Output Format

Root cause / Blast radius / Fix steps / Verification command
```

### Hooks：在 Claude 执行操作前后，强制插入你自己的逻辑

适合：阻断修改受保护文件、Edit 后自动格式化/lint/轻量校验、SessionStart 后注入动态上下文（Git 分支、环境变量）、任务完成后推送通知。

不适合：需要读大量上下文的复杂语义判断、长时间运行的业务流程、需要多步推理和权衡的决策，这些该在 Skill 或 Subagent 里。

### Prompt Caching：Claude Code 内部架构的核心

Claude Code 的 Prompt 顺序：

1. System Prompt → 静态，锁定
2. Tool Definitions → 静态，锁定
3. Chat History → 动态，在后面
4. 当前用户输入 → 最后

### 验证闭环：没有 Verifier 就没有工程上的 Agent

Verifier 的层级

- 最低层：命令退出码、lint、typecheck、unit test
- 中间层：集成测试、截图对比、contract test、smoke test
- 更高层：生产日志验证、监控指标、人工审查清单

### 高频命令的工程意义

#### 会话连续性与并行

```shell
claude --continue               # 恢复当前目录最近会话，隔天接着做
claude --resume                 # 打开选择器恢复历史会话
claude --continue --fork    # 从已有会话分叉，同一起点不同方案
claude --worktree              # 创建隔离 git worktree
claude -p "prompt"            # 非交互模式，接入 CI / pre-commit / 脚本
claude -p --output-format json  # 结构化输出，便于脚本消费
```

#### 几个不常见但很好用的命令

- `/simplify`：对刚改完的代码做三维检查，代码复用、质量和效率，发现问题直接修掉。特别适合改完一段逻辑后立刻跑一遍，代替手动 review。
- `/rewind`：不是撤销，而是回到某个会话 checkpoint 重新总结。适合：Claude 已沿错误路径探索太久；想保留前半段共识但丢掉后半段失败。
- `/btw`：在不打断主任务的前提下快速问一个侧问题，适合两个命令有什么区别这类单轮旁路问答，不适合需要读仓库或调用工具的问题。
- `claude -p --output-format stream-json`：实时 JSON 事件流，适合长任务监控、增量处理、流式集成到自己的工具。
- `/insight`：让 Claude 分析当前会话，提炼出哪些内容值得沉淀到 CLAUDE.md。用法是会话做了一段之后跑一次，它会指出这个约定你们反复提到，但没有写进契约之类的盲点，是迭代优化 CLAUDE.md 的好手段。

### 配置健康检查

```shell
claude plugin marketplace add tw93/waza
claude plugin install health@waza
```

---

## I Ditched Elasticsearch for Meilisearch. Here's What Nobody Tells You.

### Honest Caveats

1. It is not a general-purpose search engine.
2. Index size is bounded by your infrastructure.
3. There is no distributed mode.
4. Vector search is in active development.

### Quick-Reference Checklist

- [ ] Run Meilisearch with --master-key set — never in keyless mode outside local dev
- [ ] Declare primary key explicitly on index creation, don't let Meilisearch infer it
- [ ] Configure searchableAttributes in priority order (most important field first)
- [ ] Add filterableAttributes and sortableAttributes before adding documents to avoid re-indexing
- [ ] Set --max-indexing-memory in production to prevent OOM during index rebuilds
- [ ] Generate scoped API keys — never expose the master key to clients
- [ ] Use tenant tokens for multi-tenant data isolation
- [ ] Automate dump exports to object storage for disaster recovery
- [ ] Use multiSearch for federated search across multiple indexes
- [ ] Monitor task queue — long-running tasks signal indexing pressure worth investigating
- [ ] Test typo tolerance and facets with real user queries before launch
- [ ] Review index size vs. available RAM at your target document count

---

## The Git Commands I Run Before Reading Any Code

- [ ] What Changes the Most: `git log --format=format: --name-only --since="1 year ago" | sort | uniq -c | sort -nr | head -20`
- [ ] Who Built This: `git shortlog -sn --no-merges`
- [ ] Where Do Bugs Cluster: `git log -i -E --grep="fix|bug|broken" --name-only --format='' | sort | uniq -c | sort -nr | head -20`
- [ ] Is This Project Accelerating or Dying: `git log --format='%ad' --date=format:'%Y-%m' | sort | uniq -c`
- [ ] How Often Is the Team Firefighting: `git log --oneline --since="1 year ago" | grep -iE 'revert|hotfix|emergency|rollback'`

---

## Native Instant Space Switching on MacOS

- Use a third-party virtual space manager facade, hiding and showing windows as needed when switching spaces.
  Some popular options are [FlashSpace](https://github.com/wojciech-kulik/FlashSpace) and [AeroSpace virtual workspaces](https://nikitabobko.github.io/AeroSpace/guide#emulation-of-virtual-workspaces). I actually offer no criticism other than that they are not native to MacOS, and feel unnecessary given that all we want to do is disable an animation.
- Without further ado, I managed to find [InstantSpaceSwitcher](https://github.com/jurplel/InstantSpaceSwitcher) by jurplel on GitHub. It is a simple menu bar application that achieves instant space switching while offering none of the aforementioned drawbacks. You can bind a keybind or use swipe gestures to instantly switch spaces.
  Here I have InstantSpaceSwitcher paired up with [SpaceName](https://github.com/ekalinin/SpaceName).
