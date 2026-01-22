---
title: "Build a Lightweight Docker Image for Your Go App? | IT Man"
date: 2022-07-25T17:33:47+08:00
menu:
  sidebar:
    name: "Build a Lightweight Docker Image for Your Go App? | IT Man"
    identifier: golang-build-lightweight-docker-image-for-go-application
    weight: 10
tags: ["Links", "Go", "Docker"]
categories: ["Links", "Go", "Docker"]
hero: images/hero/go.svg
---

- [Build a Lightweight Docker Image for Your Go App? | IT Man](https://iter01.com/605065.html)

##### go build

```bash
# default
$ go build -o test1 main.go
$ du -sh test1
14M    test1


# You can add `-ldflags "-s -w"` during compilation to reduce the binary size by stripping some link and debug info. Details:
# -a: force rebuilding all dependencies
# -s: drop symbol table info; stack traces in panic will lose file/line info
# -w: drop DWARF debug info; you cannot debug with gdb
# If you don't need the symbol table, you can just use "-s"
# Note: it is not recommended to use -w and -s together
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

UPX compression options

- `-o`: specify output filename
- `-k`: keep a backup of the original file
- `-1`: fastest compression, levels 1-9
- `-9`: best compression, matches the above scale
- `-d`: decompress and restore original size
- `-l`: show details of the compressed file, e.g., upx -l main.exe
- `-t`: test the compressed file, e.g., upx -t main.exe
- `-q`: be quiet
- `-v`: show compression details (verbose)
- `-f`: force compression
- `-V`: show version
- `-h`: show help
- `--brute`: try all available compression methods, slow
- `--ultra-brute`: even more extreme, very slow

After UPX compression, the program can still run without decompression. This is called packed compression. It includes two parts:

- Insert decompression code at the beginning or another suitable place in the program
- Compress the rest of the program

At runtime, it also includes two parts:

- First run the inserted decompression code, which decompresses the program in memory
- Then run the decompressed program

In short, UPX adds an extra decompression step at runtime, but the overhead is usually negligible.

##### docker image

```dockerfile
FROM golang:alpine AS build

# Set required environment variables for the image
ENV GO111MODULE=on
    CGO_ENABLED=0
    GOOS=linux
    GOARCH=amd64
    GOPROXY="https://goproxy.io"

# Move to the working directory: /build
WORKDIR $GOPATH/src/gin_docker

# Copy the code into the container
ADD . ./

# Build the binary executable app
RUN go build -ldflags "-s -w" -o app


FROM scratch AS prod

# Copy /go/src/gin_docker from the builder image to the current directory
# Run the application as a non-root user
# User ID 65534 is usually the 'nobody' user
# The image user should still be specified during installation.
COPY --chown=65534:0  --from=build  /go/src/gin_docker .
USER 65534

# Command to run
CMD ["./app"]
```
