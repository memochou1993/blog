---
title: 使用 config 檔案執行 SSH 連線
date: 2019-02-07 20:17:05
tags: ["SSH"]
categories: ["Others", "SSH"]
---

## 做法

在 `~/.ssh` 資料夾新增 `config` 檔：

```env
Host xx.xxx.com
    HostName xx.xxx.xxx.xxx
    User ubuntu
    IdentityFile ~/.ssh/aws.pem
```

進行連線。

```bash
ssh xx.xxx.com
```
