---
title: 認識 Go Modules 套件管理工具
date: 2019-12-15 14:20:45
tags: ["程式設計", "Go"]
categories: ["程式設計", "Go", "其他"]
---

## 環境

- macOS
- Go 1.13.4

## 修改環境變數

修改 `~/.zshrc` 檔：

```env
export GO111MODULE=on
export GOPATH=$HOME/Workspace/go
export GOBIN=$GOPATH/bin
export PATH=$GOBIN:$PATH
```

重新加載啟動文件。

```bash
source ~/.bashrc
```

## 使用

建立專案。

```bash
mkdir go-mod-example
cd go-mod-example
```

初始化 Go Modules。

```bash
go mod init github.com/memochou1993/go-mod-example
```

在 `src` 資料夾新增 `main.go` 檔：

```go
package main

import (
	"fmt"

	"github.com/appleboy/com/random"
)

func main() {
	fmt.Println(random.String(10))
}
```

下載依賴套件。

```bash
go mod download
```

直接執行應用程式，也會下載依賴套件。

```bash
go run main.go
```

若要清除快取，使用以下指令：

```bash
go clean -modcache
```

若要刪除未使用的套件，或找回遺失的套件，使用以下指令：

```bash
go mod tidy
```
