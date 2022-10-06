---
title: 在 macOS 上使用 Laradock 自動化腳本
date: 2019-08-19 20:06:25
tags: ["環境部署", "Docker", "Laradock"]
categories: ["環境部署", "Laradock"]
---

## 使用方法

安裝 docker-sync 鏡像同步工具。

```bash
sh sync.sh install
```

啟動服務。

```bash
sh sync.sh up <SERVICES>
```

關閉服務。

```bash
sh sync.sh down
```

以 `laradock` 的身份進入虛擬機。

```bash
sh sync.sh bash
```
