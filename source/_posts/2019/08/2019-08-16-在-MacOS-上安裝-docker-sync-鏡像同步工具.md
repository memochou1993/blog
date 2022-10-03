---
title: 在 macOS 上安裝 docker-sync 鏡像同步工具
date: 2019-08-16 00:05:23
tags: ["環境部署", "Docker", "Laradock"]
categories: ["環境部署", "Laradock"]
---

## 前言

在使用 Laradock 的時候，可以執行 `sync.sh` 腳本來啟動或關閉服務。以下安裝 `sync.sh` 腳本所使用到的 `docker-sync` 工具，來加速 Docker 鏡像同步。

## 步驟

安裝。

```BASH
gem install --user-install docker-sync
```

將指令加進環境變數。

```ENV
if which ruby >/dev/null && which gem >/dev/null; then
  PATH="$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:$PATH"
fi
```

啟動。

```ENV
docker-sync start
```

停止。

```ENV
docker-sync stop
```
