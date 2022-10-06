---
title: 在 macOS 上安裝 VirtualBox 虛擬機器軟體與 Vagrant 管理工具
date: 2021-12-04 15:00:38
tags: ["環境部署", "Vagrant"]
categories: ["環境部署", "Vagrant"]
---

## VirtualBox

VirtualBox 是一套由 Oracle 所開發的 VM 軟體，VirtualBox 可以在電腦新增多個虛擬機器，並且在虛擬機器中安裝不同的作業系統。

進到 VirtualBox 的[下載頁面](https://www.virtualbox.org/wiki/Downloads)，依序下載並安裝以下軟體。

- VirtualBox platform packages：點選 OS X hosts 下載連結。
- VirtualBox Extension Pack：點選 All supported platforms 下載連結。

安裝 VirtualBox 後，安裝擴充包。

## Vagrant

Vagrant 是一個虛擬機器管理工具，可以使用 `brew` 安裝。

```bash
brew install vagrant
```

確認版本。

```bash
vagrant -v
```
