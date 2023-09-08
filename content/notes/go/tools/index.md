---
title: Go Tools
weight: 100
menu:
  notes:
    name: tools
    identifier: notes-go-tools
    parent: notes-go
    weight: 10
---

{{< note title="tools" >}}

##### httpstat

- It's like curl -v, with colours.

```bash
go get github.com/davecheney/httpstat
```

##### jsonnet

- This an implementation of Jsonnet in pure Go

```bash
go get github.com/google/go-jsonnet/cmd/jsonnet
```

##### gosec

- Golang security checker

```bash
go get -u github.com/securego/gosec/cmd/gosec
```

##### vegeta

- HTTP load testing tool and library

```bash
go get -u github.com/tsenart/vegeta
```

##### dasel

- Select, put and delete data from JSON, TOML, YAML, XML and CSV files with a single tool. Supports conversion between formats and can be used as a Go package.

```bash
brew install dasel
go install github.com/tomwright/dasel/v2/cmd/dasel@master
```

##### hey

- HTTP load generator, ApacheBench (ab) replacement, formerly known as rakyll/boom

```bash
brew install hey
```

##### slides

- Terminal based presentation tool

```bash
brew install slides
go install github.com/maaslalani/slides@latest
```

##### gokart

- A static analysis tool for securing Go code

```bash
go install github.com/praetorian-inc/gokart@latest
```

##### structslop

- structslop is a static analyzer for Go that recommends struct field rearrangements to provide for maximum space/allocation efficiency.

```bash
go install -v github.com/orijtech/structslop/cmd/structslop@v0.0.8
go get github.com/orijtech/structslop/cmd/structslop
```

##### dive

- A tool for exploring each layer in a docker image

```bash
brew install dive
go get github.com/wagoodman/dive
```

##### sttr

- cross-platform, cli app to perform various operations on string

```bash
go install github.com/abhimanyu003/sttr@latest
```

##### gentool

- Gen Tool is a single binary without dependencies can be used to generate structs from database

```bash
go install gorm.io/gen/tools/gentool@latest
```

{{< /note >}}
