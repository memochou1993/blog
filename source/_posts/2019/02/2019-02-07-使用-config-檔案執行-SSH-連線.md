---
title: 使用 config 檔案執行 SSH 連線
date: 2019-02-07 20:17:05
tags: ["SSH"]
categories: ["其他", "SSH"]
---

## 做法

在 `~/.ssh` 資料夾新增 `config` 檔：

```ENV
Host xx.xxx.com
    HostName xx.xxx.xxx.xxx
    User ubuntu
    IdentityFile ~/.ssh/aws.pem
```

進行連線。

```BASH
ssh xx.xxx.com
```
