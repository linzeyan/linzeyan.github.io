---
title: "寫 Web 也可以用 Makefile：好好管理你的環境流程"
date: 2024-08-05T17:21:24+08:00
menu:
  sidebar:
    name: "寫 Web 也可以用 Makefile：好好管理你的環境流程"
    identifier: shell-use-makefile-to-manage-workflows-for-web-projects
    weight: 10
tags: ["URL", "BASH", "SHELL"]
categories: ["URL", "BASH", "SHELL"]
hero: images/hero/shell.png
---

- [寫 Web 也可以用 Makefile：好好管理你的環境流程](https://blog.goodjack.tw/2023/01/use-makefile-to-manage-workflows-for-web-projects.html)
- [How I stopped worrying and loved Makefiles](https://gagor.pro/2024/02/how-i-stopped-worrying-and-loved-makefiles/)

**注意：Makefile 的縮排應使用 Tab，否則會出現語法問題。**

## Makefile 的主要本體：Target

```makefile
up:
	cp .env.example .env
	docker compose up -d workspace

stop:
	docker compose stop

zsh:
	docker compose exec workspace zsh
```

- 本例有三個 Target：`up`、`stop`、`zsh`。Makefile 預設將第一個 Target 視為 [Goal](https://www.gnu.org/software/make/manual/html_node/Goals.html)(不能是點（dot）開頭的 Target)，是專案的最主要流程，可以直接用 `make` 執行。以本例來說，執行 `make` 和 `make up` 是一樣的結果。
- 但其實剛剛複製檔案的例子不是常見的 Make 用法。Make 的強項是在自動判斷有沒有必要執行每個 Target 的流程。例如我們常常將機敏資料放在 .env 中，若 .env 已經存在，就不應該再複製 .env.example 覆寫過去了。這時候我們可以把 .env 做成一個 Target：

```makefile
up: .env
	docker compose up -d workspace

.env:
	cp .env.example .env
```

- Target 名稱預設是被視為檔名的。Make 之所以稱為 make，就是想要「製作」出指定的 Target，當符合指定條件時（如檔案不存在）才會執行 Target 的內容。
  - 以本例來說，我們執行 `up` Target 時，如果 .env 不存在，就會先執行 `.env` Target 以複製出 .env，接著才會啟動 workspace container。如果執行 `up` Target 時 .env 已經存在，就會略過 `.env` Target，直接啟動 workspace container。
  - 同樣地，如果我們目錄中有「up」這個檔案， `up` Target 就不會被執行了。這時我們可以設定 [Phony Target](https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html)，告訴 Make 哪些 Target 不是檔案的名稱，而是單純流程的命名。寫法如下：

```makefile
.PHONY: up stop zsh
```

## 來點變數

Make 當然也支援變數（[Variable](https://www.gnu.org/software/make/manual/html_node/Setting.html)），與常見的 Unix 環境變數慣例相同，我們習慣用 SCREAMING_SNAKE_CASE 表示法（全大寫和底線的表示法）。並且在使用時以 `$()` 包裹變數名稱。

例如我們想要方便啟動指定的 container，可以將 `up` 改寫成：

```makefile
CONTAINERS ?= workspace mysql

up:
	docker compose up -d $(CONTAINERS)
.PHONY: up
```

這裡我們設定了一個變數 `CONTAINERS`，當我們未指定時，預設值為 「workspace mysql」。例如我們呼叫 `make up` 時會執行以下指令：

```bash
docker compose up -d workspace mysql
```

當我們想要給予該變數一個值，例如我們想用 `up` Target 開啟 redis container，可以這樣呼叫：

```bash
make up CONTAINERS="redis"
```

這時 Make 就會幫我們執行以下指令：

```bash
docker compose up -d redis
```

另一種常見的用法是透過變數指定 Docker Compose 的參數，如以下範例：

```makefile
CONTAINER_USER ?= default
CONTAINERS ?= workspace

zsh:
	docker compose exec --user=$(CONTAINER_USER) $(CONTAINERS) zsh
.PHONY: zsh
```

這裡預設是以「default」來進入 container。這時我們可以透過指定 `CONTAINER_USER` 來更改執行指令的使用者，以指定成「root」為例：

```bash
make zsh CONTAINER_USER="root"
```

這時 Make 就會幫我們執行以下指令，以「root」進入 container：

```bash
docker compose exec --user=root workspace zsh
```

## 做一些條件判斷

想要有一些稍微複雜的邏輯判斷？Make 也支援條件式（[Conditional](https://www.gnu.org/software/make/manual/html_node/Conditional-Syntax.html)），最常見的是 `ifeq` 和 `ifneq`，分別對應「如果等於」和「如果不等於」，以下是範例：

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

以此例來說，當我們執行 `make zsh` 時，Make 會判斷 `$(IS_ROOT)` 是否等於 "true"，若相等的話，就會以 root 的身份進入 workspace container，否則就改以預設的 user 進入。

首先要注意的是，只有被執行的指令部分需要 Tab 縮排，條件式相關的語句應該要保持不縮排，因為他是屬於 Make 語法的一部分。另外提醒，雖然本例中使用的是 true/false，但其實 Make 是沒有布林值型態的，在這裡是比對字串有無相等。

## 控制字串的輸出

接著我們來加一些輸出，讓我們能更容易辨識流程。以下是 Make 標準輸出的 [Control Function](https://www.gnu.org/software/make/manual/html_node/Make-Control-Functions.html)，稱之為 `info`：

```makefile
IS_ROOT ?= false

zsh:
ifeq ($(IS_ROOT), true)
	$(info 以 Root 身份進入 workspace)
	docker compose exec --user=root workspace zsh
else
	$(info 以預設身份進入 workspace)
	docker compose exec workspace zsh
endif
.PHONY: zsh
```

此時若我們執行 `make zsh`，看到的輸出如下：

```bash
以預設身份進入 workspace
docker compose exec workspace zsh
# 接者是 Docker Compose 執行結果
```

如此透過 Control Function 我們就能更客製化顯示的內容，另外還有 `warning` 和 `error` 兩種輸出，可以參考說明文件。

另外，有時不想要我們的指令干擾畫面的呈現，這時候我們可以在行首加上 `@` 符號，阻止 Make [Echoing](https://www.gnu.org/software/make/manual/html_node/Echoing.html)。以文章開始的 Hello World 範例改寫如下：

```makefile
hello:
	@echo "Hello World"
.PHONY: hello
```

這時當我們執行 `make hello`，呈現的結果如下：

```bash
Hello World
```

就不會出現 `echo "Hello World"` 字樣了。

## 組合技：管理不同環境的流程

讀到這裡，我們已經掌握了 Make 的基本用法。接者我們來討論看看該怎麼管理不同環境的流程。

假設我們分成「開發環境（dev）」與「正式環境（production）」，啟動專案的流程如下：

- 兩者環境啟動前都需要 .env 檔，若檔案不存在，dev 環境從 .env.example 複製建立，production 環境從 .env.example.production 複製建立
- 兩者環境都需要啟動 workspace container，dev 環境還要額外啟用 redis container
- 啟動時呈現當前環境名稱
- 啟動流程不顯示指令，但以中文描述動作

以下為其中一種 Makefile 寫法：

```makefile
ENVIRONMENT ?= dev

up: .env
	$(info 目前環境為 $(ENVIRONMENT))
	$(info 啟動 workspace)
	docker compose up -d workspace
ifeq ($(ENVIRONMENT), dev)
	$(info 啟動 redis)
	docker compose up -d redis
endif
.PHONY: up

.env:
	$(info .env 不存在，建立 .env 檔)
ifeq ($(ENVIRONMENT), dev)
	cp .env.example .env
else
	cp .env.example.production .env
endif
```

到這裡，我們已經可以開始撰寫針對不同環境的流程了！我們還可以加上一些 Phony Target 來整理常用的指令，例如前面範例提過的 `stop` 和 `zsh`，或是執行 Laravel 測試：

```makefile
test:
	docker compose exec workspace php artisan test
.PHONE: test
```

---

### 註解的使用

跟 Shell Script 一樣使用 `#`。

值得注意的是，如果在 Target 中使用 Tab 縮排後的 `#` ，會被視為是 Shell Script 的註解。

### 取得當前 Target 名

使用 `$@`。

```makefile
up:
	$(info 目前執行的 Target 是 $@) # 顯示 up
	docker compose up -d $(CONTAINERS)
.PHONY: up
```

### Make 變數與 Shell Script 變數混用

也許你在流程中想使用 Shell Script 變數，如果要使用 `$` 在指令中，跳脫的方法不是 `\$`，而是 `$$`。

### 變數內容可以為 Shell 執行結果

請看範例：

```makefile
MY_IP = $(shell curl -s ipinfo.io/ip)

get-ip:
	$(info 我的 IP：$(MY_IP))
.PHONY: get-ip
```

### 變數可以擴充

透過 `+=` 和 `ifeq` 可以更簡單的管理環境，請看範例：

```makefile
ENVIRONMENT ?= dev
CONTAINERS ?= workspace

ifeq ($(ENVIRONMENT), dev)
# 強制 dev 環境會開啟 redis
CONTAINERS += redis
endif

up:
	$(info 目前環境為 $(ENVIRONMENT))
	$(info 啟動 $(CONTAINERS))
	# dev 環境預設會開啟 workspace 和 redis
	docker compose up -d $(CONTAINERS)
.PHONY: up
```

### 想要抽成 function？

如果有一直重複的指令前綴可以抽成變數，參數也可以抽成另一個變數方便執行時替換：

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

我們也許可以這樣執行：

```bash
make zsh COMPOSE_FLAGS="-d -T"
```

當然 flags 也可以用前面提到的 `+=` 概念去組合。

除了一般變數的用法外，還有多行變數（[`define`](https://www.gnu.org/software/make/manual/html_node/Multi_002dLine.html)）搭配 [Call Function](https://www.gnu.org/software/make/manual/html_node/Call-Function.html) `$(call [variable])` 的用法。

### 剛提到了 info、shell 和 call，還有沒有其他神奇 Function

還蠻多的，例如 filter、subst、realpath⋯⋯。想看各種 Function 的介紹請參考 [Function](https://www.gnu.org/software/make/manual/html_node/Functions.html) 說明文件。

另外，所有 Make 內建的 Function、變數、指令可以 [在此查表](https://www.gnu.org/software/make/manual/html_node/Name-Index.html)。

### 如果想要中間才執行 Prerequisite？

可以使用 [Double-Colon Rules](https://www.gnu.org/software/make/manual/html_node/Double_002dColon.html) 語法，主要是把 `:` 改成 `::`，將 Target 拆開成兩部分，例如：

```makefile
up::
	$(info 我先顯示這句後才想製作 .env)
up:: .env
	$(info 製作 .env 後才啟動 workspace)
	docker compose up -d workspace
.PHONY: up

.env:
	cp .env.example .env
```

### 更多 Prerequisite 用法

可以使用變數決定 Prerequisite，Target 也可以是路徑：

```makefile
PREREQUISITE ?= .env ../laravel/.env

up: $(PREREQUISITE)
	docker compose up -d workspace
.PHONY: up

.env:
	# Docker 的 .env
	cp .env.example .env

../laravel/.env:
	# 隔壁目錄的 .env
	cp ../laravel/.env.example ../laravel/.env
```

### 進階變數使用

變數宣告另外還有 `=`、`:=` 等用法。

另外 Target 是可以給定值的，要附在 Target 前（請見範例）。但這種寫法我覺得維護上有很多問題，我都盡量避免使用。

Makefile 範例一：

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

Makefile 範例一執行結果，hey 認為 `TEXT` 已經給過值，就不會套用 hey 值：

```bash
# 執行 make
hey: default
hello: default

# 執行 make TEXT=Jack
hey: Jack
hello: Jack
```

Makefile 範例二，將 hey 給值由 `?=` 改為 `=`：

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

Makefile 範例二執行結果，此時 hello 不受影響：

```bash
# 執行 make
hey: hey
hello: default
```

若在流程中改值， `=` 的用法是會先展開取得最終結果，才確定整個流程的變數內容是什麼，從頭到尾值都會保持一致，請見範例三。

Makefile 範例三，改成 hello 給值：

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

Makefile 範例三執行結果，因為是 `=`，即使 hello 執行順序比較後面，依然影響到前面的 hey 取值：

```bash
# 執行 make
hey: hello
hello: hello
```

Makefile 也有個 [官方範例](https://www.gnu.org/software/make/manual/html_node/Recursive-Assignment.html) 說明 `=` 展開的概念：

```makefile
foo = $(bar)
bar = $(ugh)
ugh = Huh?

all:
	@echo $(foo) # 輸出結果為 Huh?
```

`:=` 的用法與一般程式語言的等號賦值比較類似。讓我們修改一下剛剛的官方範例，將 `=` 改成 `:=`：

```makefile
foo := $(bar)
bar := $(ugh)
ugh := Huh?

all:
	@echo $(foo) # 輸出結果為空白行
```
