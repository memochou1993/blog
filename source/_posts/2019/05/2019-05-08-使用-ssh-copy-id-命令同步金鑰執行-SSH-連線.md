---
title: 使用 ssh-copy-id 命令同步金鑰執行 SSH 連線
date: 2019-05-08 21:12:57
tags: ["SSH"]
categories: ["Others", "SSH"]
---

## 做法

生成 SSH 金鑰。

```bash
ssh-keygen
```

將公開金鑰同步到遠端伺服器。

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub root@xxx.xxx.xxx.xxx
```

使用 SSH 登入，不再需要密碼。

```bash
ssh root@xxx.xxx.xxx.xxx
```
