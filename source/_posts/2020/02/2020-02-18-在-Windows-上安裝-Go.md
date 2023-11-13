---
title: 在 Windows 上安裝 Go
date: 2020-02-18 08:50:55
tags: ["Programming", "Go"]
categories: ["Programming", "Go", "Installation"]
---

## 前言

由於公司無法安裝軟體、修改環境變數，所以需要手動下載 Go 壓縮檔，將環境變數加到 Cmder 中。

## 安裝

下載 Go 的[壓縮檔](https://dl.google.com/go/go1.13.8.windows-amd64.zip)，並解壓縮。

將資料夾移至 `C:\Users\<USER>\AppData\Roaming` 目錄，或任何自訂的目錄。

配置 Go 專案的目錄結構如下：

```bash
|- Workspace/
  |- go/
    |- bin/
    |- pkg/
    |- src/
      |- github.com/
        |- memochou1993/
          |- project/
```

設定 Cmder 終端機的環境變數：

```bash
set PATH=%ConEmuBaseDir%\Scripts;%PATH%;C:\Users\<USER>\AppData\Roaming\go\bin;
set GOPATH=C:\Users\<USER>\Workspace\go
set GO111MODULE=on
```

重新啟動終端機。

確認 Go 的版本：

```bash
go version
```

查看 Go 的環境變數：

```bash
go env
```

## 設定 VS Code 編輯器

修改 `settings.json` 檔：

```json
{
    "go.goroot": "C:\\Users\\<USER>\\AppData\\Roaming\\go",
    "go.gopath": "C:\\Users\\<USER>\\Workspace\\go"
}
```
