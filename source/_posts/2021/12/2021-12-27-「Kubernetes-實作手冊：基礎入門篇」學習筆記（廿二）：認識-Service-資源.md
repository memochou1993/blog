---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（廿二）：認識 Service 資源
permalink: 「Kubernetes-實作手冊：基礎入門篇」學習筆記（廿二）：認識-Service-資源
date: 2021-12-27 14:34:15
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」學習筆記"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

Service 在一組 Pod 前面再封裝一層抽象層，確保外部應用程式存取服務時，都能夠連結到正在運行的 Pod。具體來說，Kubernetes Service 為 Pod 提供自己的 IP 位址，並為一組 Pod 提供相同的 DNS 名稱，並且可以在它們之間進行負載平衡。

Service 對外會提供 Virtual IP（VIP）給應用程式存取，底層則透過 Endpoints 維護所有 Pod 的資訊。總結來說，Service 是一種抽象方法，讓外部應用程式能夠存取 Pod。應用程式只需使用 Service 提供的 VIP 即可。

VIP 和 Endpoints 的轉換有許多不同的實作方法，不同的實作對於負載平衡有不同的支援，例如：

- Iptables（預設）
- Userspace
- IPVS

Kubernetes Service 有 5 種類型（Type）如下：

- ClusterIP
- NodePort：基於 ClusterIP
- LoadBalancer：基於 NodePort
- ExternalName
- Headless

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
