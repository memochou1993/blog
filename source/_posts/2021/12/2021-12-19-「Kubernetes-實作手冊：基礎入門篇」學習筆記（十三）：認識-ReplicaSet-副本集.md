---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（十三）：認識 ReplicaSet 副本集
permalink: 「Kubernetes-實作手冊：基礎入門篇」學習筆記（十三）：認識-ReplicaSet-副本集
date: 2021-12-19 22:41:39
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

ReplicaSet 的目的是維護一組在任何時候都處於運行狀態的 Pod 副本的穩定集合。因此，它通常用來保證給定數量的、完全相同的 Pod 的可用性。

由於 Pod 本身並沒有複製能力，僅代表著一份應用程式，因此無法做到負載平衡的效果。如果希望應用程式能夠達到負載平衡的效果，就需要使用 ReplicaSet 來完成。

ReplicaSet 用於管理相同的 Pod，確保任何時間內都會有滿足數量的 Pod 運行。不過要注意的是，Pod 和 ReplicaSet 是不同的資源，它們透過選擇器綁定在一起。

## 實作

使用以下指令可以看到各種資源的縮寫。其中，ReplicaSet 的縮寫為 `rs`。

```BASH
kubectl api-resources
```

首先，查看範例資料夾中的 ReplicaSet 配置檔。

```BASH
cat introduction/rs/basic.yaml
```

以下是一個描述 ReplicaSet 的 YAML 範例檔，其中 `template` 的部分其實就是 Pod 的配置檔的格式，並透過標籤綁定在一起。

```BASH
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: test-rs
  labels:
    app: nginx-rs
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx-server
        image: nginx
```

先將主節點上的污點移除。

```BASH
kubectl taint node k8s-dev node-role.kubernetes.io/master:NoSchedule-
```

使用 `kubectl apply` 指令來創建 ReplicaSet 資源。

```BASH
kubectl apply -f introduction/rs/basic.yaml
```

列出 ReplicaSet 清單。

```BASH
kubectl get rs
```

- 狀態 `DESIRED` 表示期望要運行的 Pod 數量
- 狀態 `CURRENT` 表示目前運行的 Pod 數量
- 狀態 `READY` 表示目前已經就緒的 Pod 數量

如果刪除某一個 Pod 資源。

```BASH
kubectl delete pod test-rs-4fskw
```

因為有 ReplicaSet 的幫忙，可以看到馬上會有一個新的 Pod 資源被生成。

```BASH
kubectl get pods
```

可以使用 `kubectl edit rs` 指令修改 ReplicaSet 資源。

```BASH
kubectl edit rs test-rs
```

例如，將 Pod 的數量改為 5 個。

```YAML
spec:
  replicas: 5
```

再列出一次 Pod 清單，可以看到 Pod 的數量變為 5 個。

```BASH
kubectl get pods
```

如果觀察其中一個 Pod 資源。

```BASH
kubectl describe pod
```

可以看到此 Pod 是由 `ReplicaSet/test-rs` 這個 ReplicaSet 所控制。

```YAML
Controlled By:  ReplicaSet/test-rs
```

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
