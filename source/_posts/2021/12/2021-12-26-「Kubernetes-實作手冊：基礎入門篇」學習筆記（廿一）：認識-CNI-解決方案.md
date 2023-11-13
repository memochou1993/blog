---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（廿一）：認識 CNI 解決方案
date: 2021-12-26 14:45:58
tags: ["Deployment", "Kubernetes", "Docker"]
categories: ["Deployment", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」Study Notes"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

Flannel 是一個 Kubernetes 的其中一種 CNI 實作解決方案，安裝簡單，透過一個 YAML 檔就可以安裝，但現在已不被官方推薦。

CNI 最重要的能力就是能夠支援跨節點的溝通，如何讓不同節點內的 Pod 可以互相存取。過往 Docker 的單節點互相存取不會太困難，因為都在同個系統中，而跨節點的存取則是相對麻煩，因為中間牽涉到許多不同的節點和元件。

由於 Flannel 背後會起一個 Daemon 來處理跨節點的溝通，這種情況下不用起第二個 Container 來安裝資料。因此將初始化的工作放到 Init Container 並且透過 DaemonSet 的方式部署，就可以確保每個節點都會有一個 Pod 來處理安裝。

許多 CNI 實作都是以 Init Container 來達到類似 Daemon Job 的概念——在每個節點上都運行一個 Job。

除了 Flannel，還有有各式各樣的 CNI 實作與解決方案，有的實作並不支援 Network Policies，因次需要根據需求來挑選。

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
