---
title: 在 MacOS 上安裝 Vagrant 虛擬機管理工具
permalink: 在-MacOS-上安裝-Vagrant-虛擬機管理工具
date: 2021-12-05 15:00:38
tags: ["環境部署", "Vagrant"]
categories: ["環境部署", "Vagrant"]
---

## 安裝 VirtualBox 虛擬機軟體

進到 VirtualBox 的[下載頁面](https://www.virtualbox.org/wiki/Downloads)，依序下載並安裝以下軟體。

- VirtualBox platform packages：點選 OS X hosts 下載連結。
- VirtualBox Extension Pack：點選 All supported platforms 下載連結。

安裝 VirtualBox 後，再安裝擴充包。

## 安裝 Vagrant 虛擬機管理工具

使用 `brew` 指令安裝。

```BASH
brew install vagrant
```

確認版本。

```BASH
vagrant -v
```
