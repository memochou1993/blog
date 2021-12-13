---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（八）：認識 Pod 部署單元
permalink: 「Kubernetes-實作手冊：基礎入門篇」學習筆記（八）：認識-Pod-部署單元
date: 2021-12-13 23:39:17
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 筆記

Kubernetes workloads 被分成兩個主要的元件：Pods 和 Pod Controllers。

Pod 是 Kubernetes 裡最小的部署單元，可以被簡單視為一個應用程式。一個 Pod 中可以有多個 Container。在 Pod 之間共享的資源有 Network、Storage 和 IPC（Inter Process Communication）。

在 Network 的部分，IP address、port space、routing system 等是共享的，所以在同一個 Pod 中，不同的 Container 需要有各自的埠號；在 Storage 的部分，可以共享相同的儲存空間；而在 IPC 的部分，則可以共享記憶體。

Pod 中的 Container 有各自的狀態，像是 Running、Terminated 和 Waiting；而 Pod 也有其狀態，像是 Pending、Running、Succeeded、Failed、Unknown。Container 的狀態會影響 Pod 的狀態。

Pod 和 Container 一樣，也有所謂的重啟機制，像是 Never、Always、OnFailure。

總結來說，Pod 是 Kubernetes 裡最小的部署單元，可以包含一個或多個 Container，在 Container 之間會分享 Network、Storage 和 IPC。

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
