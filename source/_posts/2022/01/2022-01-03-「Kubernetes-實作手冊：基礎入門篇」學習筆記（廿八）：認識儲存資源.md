---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（廿八）：認識儲存資源
permalink: 「Kubernetes-實作手冊：基礎入門篇」學習筆記（廿八）：認識儲存資源
date: 2022-01-03 21:13:06
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」學習筆記"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

以 Docker 來說，預設情況下，容器內的修改都不會被保存起來，每次新的容器都是全新的空間。但是 Docker 可以透過掛載目錄的方式，來保存 Docker Container 內的修改。

而 Kubernetes 中則是將 Volume 的概念套用到 Pod 上，使 Pod 本身使用到的儲存空間可以被跨節點存取，或是使 Pod 可以讀取外部的檔案。

公有雲的 Volume 解決方案如：

- AzureDisk
- Amazon Elastic Block Store
- GCP Persistent Disk

地端的 Volume 解決方案如：

- CephFS
- Gluster
- NFS

但是並不是所有儲存設備都有被 Kubernetes 支援。

Kubernetes 有關儲存的概念有以下：

- CSI
- Downward API
- emptyDir
- hostPath
- ConfigMap
- Secret
- Persistent Volumes

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
