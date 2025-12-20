---
title: "為你的Go應用建立輕量級Docker映象？ | IT人"
date: 2022-07-25T17:33:47+08:00
menu:
  sidebar:
    name: "為你的Go應用建立輕量級Docker映象？ | IT人"
    identifier: golang-build-lightweight-docker-image-for-go-application
    weight: 10
tags: ["URL", "Go", "Docker"]
categories: ["URL", "Go", "Docker"]
hero: images/hero/go.svg
---

- [為你的 Go 應用建立輕量級 Docker 映象？ | IT 人](https://iter01.com/605065.html)

##### go build

```bash
# default
$ go build -o test1 main.go
$ du -sh test1
14M    test1


# 在程式編譯的時候可以加上 `-ldflags "-s -w"` 引數來優化編譯，原理是通過去除部分連結和除錯等資訊來減小編譯生成的可執行程式體積，具體引數如下：
# -a：強制編譯所有依賴包
# -s：去掉符號表資訊，不過 panic 的時候 stack trace 就沒有任何檔名/行號資訊了
# -w：去掉 DWARF 除錯資訊，不過得到的程式就不能使用 gdb 進行除錯了
# 若對符號表無需求，-ldflags 直接新增 "-s" 即可
# 注：不建議-w和-s同時使用
$ go build -ldflags "-s -w" -o test2 main.go
$ du -sh test2
11M    test2
```

##### upx(`brew/yum install upx`)

```bash
$ upx test2
                         Ultimate Packer for eXecutables
                            Copyright (C) 1996 - 2020
UPX 3.96        Markus Oberhumer, Laszlo Molnar & John Reiser   Jan 23rd 2020
        File size         Ratio      Format      Name
  --------------------   ------   -----------   -----------
  11490768 ->   4063248   35.36%   macho/amd64   test2
Packed 1 file.

$ upx --brute test2
$ du -sh test2
4.6M    test2
```

upx 的壓縮選項

- `-o`: 指定輸出的檔名
- `-k`: 保留備份原檔案
- `-1`: 最快壓縮，共 1-9 九個級別
- `-9`: 最優壓縮，與上面對應
- `-d`: 解壓縮 decompress，恢復原體積
- `-l`: 顯示壓縮檔案的詳情，例如 upx -l main.exe
- `-t`: 測試壓縮檔案，例如 upx -t main.exe
- `-q`: 靜默壓縮 be quiet
- `-v`: 顯示壓縮細節 be verbose
- `-f`: 強制壓縮
- `-V`: 顯示版本號
- `-h`: 顯示幫助資訊
- `--brute`: 嘗試所有可用的壓縮方法，slow
- `--ultra-brute`: 比樓上更極端，very slow

upx 壓縮後的程式和壓縮前的程式一樣，無需解壓仍然能夠正常地執行，這種壓縮方法稱之為帶殼壓縮，壓縮包含兩個部分:

- 在程式開頭或其他合適的地方插入解壓程式碼；
- 將程式的其他部分壓縮;

執行時，也包含兩個部分:

- 首先執行的是程式開頭的插入的解壓程式碼，將原來的程式在記憶體中解壓出來；
- 再執行解壓後的程式;

也就是說，upx 在程式執行時，會有額外的解壓動作，不過這個耗時幾乎可以忽略。

##### docker image

```dockerfile
FROM golang:alpine AS build

# 為我們的映象設定必要的環境變數
ENV GO111MODULE=on
    CGO_ENABLED=0
    GOOS=linux
    GOARCH=amd64
    GOPROXY="https://goproxy.io"

# 移動到工作目錄：/build
WORKDIR $GOPATH/src/gin_docker

# 將程式碼複製到容器中
ADD . ./

# 將我們的程式碼編譯成二進位制可執行檔案 app
RUN go build -ldflags "-s -w" -o app


FROM scratch AS prod

# 從builder映象中把/go/src/gin_docker 拷貝到當前目錄
# 設定應用程式以非 root 使用者身份運行
# User ID 65534 通常是 'nobody' 使用者
# 映像的執行者仍應在安裝過程中指定一個使用者。
COPY --chown=65534:0  --from=build  /go/src/gin_docker .
USER 65534

# 需要執行的命令
CMD ["./app"]
```
