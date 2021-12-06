---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（一）：環境建置
permalink: 「Kubernetes-實作手冊：基礎入門篇」學習筆記（一）：環境建置
date: 2021-12-05 15:26:20
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 環境建置

下載課程所需要使用的檔案。

```BASH
git clone https://github.com/hwchiu/hiskio-course.git
```

進入到 `vagrant` 資料夾，檢查 `Vagrantfile` 檔。

```BASH
cat Vagrantfile
```

執行以下指令，啟動一個虛擬機器。

```BASH
vagrant up
```

Vagrant 會根據 `Vagrantfile` 檔，呼叫 VirtualBox 去建置一個虛擬機器。

```BASH
Bringing machine 'k8s' up with 'virtualbox' provider...
```

如果要進到虛擬機器中，使用以下指令。

```BASH
vagrant ssh
```

如果要銷毀虛擬機器，使用以下指令。

```BASH
vagrant destroy
```

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
