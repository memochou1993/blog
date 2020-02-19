---
title: 在 Windows 上安裝 Go
permalink: 在-Windows-上安裝-Go
date: 2020-02-18 08:50:55
tags: ["環境部署", "Windows", "Go"]
categories: ["環境部署", "Go"]
---

## 前言

由於公司無法安裝軟體、修改環境變數，所以需要手動下載 Go 壓縮檔，將環境變數加到 Cmder 中。

## 安裝

下載 Go 的[壓縮檔](https://dl.google.com/go/go1.13.8.windows-amd64.zip)，並解壓縮。

將資料夾移至 `C:\Users\<USER>\AppData\Roaming` 目錄，或任何自訂的目錄。

配置 Go 專案的目錄結構如下：

```BASH
|- Workspace/
  |- go/
    |- bin/
    |- pkg/
    |- src/
      |- github.com/
        |- memochou1993/
          |- project/
```

設定 Cmder 的環境變數：

```BASH
set PATH=%ConEmuBaseDir%\Scripts;%PATH%;C:\Users\<USER>\AppData\Roaming\go\bin;
set GOPATH=C:\Users\<USER>\Workspace\go
set GO111MODULE=on
```

重新啟動終端機。

確認 Go 的版本：

```BASH
go version
```

查看 Go 的環境變數：

```BASH
go env
```
