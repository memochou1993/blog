---
title: 學習使用 Go Modules 套件管理工具
permalink: 學習使用-Go-Modules-套件管理工具
date: 2019-12-15 14:20:45
tags: ["程式寫作", "Go"]
categories: ["程式寫作", "Go"]
---

## 環境

- macOS
- Go 1.13.4

## 修改環境變數

修改 `~/.zshrc` 檔的環境變數：

```ENV
export GO111MODULE=on
export GOPATH=$HOME/Workspace/go
export GOBIN=$GOPATH/bin
export PATH=$GOBIN:$PATH
```

## 建立專案

在 `src` 資料夾新增 `main.go` 檔：

```GO
package main

import (
	"fmt"

	"github.com/appleboy/com/random"
)

func main() {
	fmt.Println(random.String(10))
}
```

## 做法

可以使用 Go 1.11 版本以後推出的 Go Modules 套件管理工具，或使用第三方套件，例如  `kardianos/govendor`。

### 使用 Go Modules

在專案目錄底下初始化。

```BASH
go mod init github.com/memochou1993/example
```

下載依賴套件。

```BASH
go mod download
```

或者直接執行，也會下載依賴套件。

```BASH
go run main.go
```

若要清除快取，使用以下指令：

```BASH
go clean -i -x -modcache
```

若要找回遺失的套件，或刪除未使用的套件，使用以下指令：

```BASH
go mod tidy
```

### 使用 govendor

安裝 `kardianos/govendor` 套件。

```BASH
go get -u github.com/kardianos/govendor
```

在專案目錄底下初始化。

```BASH
govendor init
```

下載依賴套件。

```BASH
govendor fetch github.com/appleboy/com/random
```

執行應用。

```GO
go run main.go
```

## 參考資料

- [Go 語言 1.11 版本新功能 Go Modules](https://www.youtube.com/watch?v=MXjYRrZnHh0)
