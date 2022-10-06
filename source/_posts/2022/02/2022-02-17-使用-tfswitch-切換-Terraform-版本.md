---
title: 使用 tfswitch 切換 Terraform 版本
date: 2022-02-17 19:28:58
tags: ["環境部署", "Terraform"]
categories: ["環境部署", "Terraform"]
---

## 安裝指令

安裝 `tfswitch` 指令。

```bash
brew install warrensbox/tap/tfswitch
```

確認 `tfswitch` 版本。

```bash
tfswitch -v
```

列出並選擇一個版本。

```bash
tfswitch -l
```

確認 `terraform` 的版本。

```bash
terraform -v
```

- [terraform-switcher](https://github.com/warrensbox/terraform-switcher)
