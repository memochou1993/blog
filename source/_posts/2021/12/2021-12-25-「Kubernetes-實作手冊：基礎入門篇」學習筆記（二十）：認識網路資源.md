---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（二十）：認識網路資源
date: 2021-12-25 15:40:55
tags: ["Deployment", "Kubernetes", "Docker"]
categories: ["Deployment", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」Study Notes"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

在使用 Docker 單一節點的情況下，透過 Linux Bridge 以及相關的系統操作，可以輕鬆地處理以下需求：

- Pod to Pod
- Wan to Pod
- Pod to Wan

而 Kubernetes 內以 Pod 為基本單位，就算有多個 Container，也因為會跟 Pause Container 共享網路空間，所以在操作上還是可以使用 Pod 作為一個最基本的單位。

實務上，為了順利存取到應用程式，需要考慮到不同的應用程式有不同的協定：

- Layer 4：TCP、UDP、SCTP
- Layer 7：HTTP、gRPC

Kubernetes 還有許多功能，例如：

- Load Balancing：需要探討透過 Deployment 去部署多副本的應用程式時，客戶端能夠在不修改任何設定的情況下，簡單地去存取這些副本，即使這些副本被重啟，或被部署到不同節點上。
- Firewall：Kubernetes 內可以有不同的 namespace，透過一些防火牆的設定，讓不同的 namespace 不能夠互相存取，這樣 namespace 的隔離意義才會更明顯。

關於網路資源，還有以下：

- EndpointSlices
- Service：使應用程式方便存取 Deployment 管理的多個副本，提供客戶端單一入口。
- Service Topology
- DNS
- Ingress
- Ingress Controller
- Network Policies：由 CNI 框架實作。
- IPv4/IPv6 dual-stack
- Federation：管理多個 Kubernetes 叢集，牽涉到網路、運算、儲存及管理。
- Public Cloud Providers：使用公有雲一條龍服務，可以確保各種資源高度整合，但可能會少一些彈性。

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
