---
title: 使用 config 文件執行 SSH 連線
permalink: 使用-config-文件執行-SSH-連線
date: 2019-02-07 20:17:05
tags: ["其他", "SSH"]
categories: ["其他", "SSH"]
---

## 做法
新增 `~/.ssh/config` 檔：
```
Host xx.xxx.com
    HostName xx.xxx.xxx.xxx
    User ubuntu
    IdentityFile ~/.ssh/aws.pem
```

進行連線。
```
$ ssh xx.xxx.com
```
